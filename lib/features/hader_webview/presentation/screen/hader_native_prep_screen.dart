import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/features/hader_webview/data/hader_bridge.dart';
import 'package:moean/features/hader_webview/data/hader_prep_models.dart';
import 'package:moean/features/hader_webview/presentation/cubit/hader_prep_cubit.dart';

/// Lesson preparation with a native UI and the WebView kept out of sight.
///
/// [HaderWebViewScreen] shows Madrasati's own desktop schedule, which works but
/// leaves a teacher pinching and panning a wide table on a phone. Here the
/// table never appears: a hidden WebView loads the page and runs content.js as
/// usual, and everything the teacher touches is Flutter.
///
/// The automation still runs in the page. `handleDashboardSave()` reads the
/// live DOM for subject ids, school ids and lesson tokens, so it stays where it
/// can see them — this screen only harvests what content.js rendered and writes
/// the teacher's choices back.
class HaderNativePrepScreen extends StatefulWidget {
  const HaderNativePrepScreen({super.key});

  @override
  State<HaderNativePrepScreen> createState() => _HaderNativePrepScreenState();
}

class _HaderNativePrepScreenState extends State<HaderNativePrepScreen> {
  static const String _defaultUrl =
      'https://schools.madrasati.sa/SchoolSchedule';
  static const String _urlOverride = String.fromEnvironment('HADER_URL');

  static String get _startUrl =>
      _urlOverride.isNotEmpty ? _urlOverride : _defaultUrl;

  static const String _desktopUserAgent =
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36';

  final HaderPrepCubit _cubit = HaderPrepCubit();

  late final HaderBridge _bridge = HaderBridge(
    onAutomationStatus: (status, _) => _cubit.onAutomationStatus(status),
  );

  UnmodifiableListView<UserScript>? _userScripts;
  String? _setupError;

  /// Height the off-screen engine is laid out at. Tall enough for Madrasati
  /// to render the whole schedule table so every card is found.
  static const double _engineHeight = 900;

  /// Height the page gets when the teacher chooses to look at it.
  static const double _peekHeight = 320;

  /// Lets the teacher watch the page when something goes wrong there — a
  /// Madrasati sign-in prompt, say, which a hidden WebView would swallow.
  bool _showWebView = false;

  @override
  void initState() {
    super.initState();
    _prepareUserScripts();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Future<void> _prepareUserScripts() async {
    try {
      final seed = await _bridge.buildSeed();
      final sources = await Future.wait([
        rootBundle.loadString(HaderAssets.desktopViewport),
        rootBundle.loadString(HaderAssets.shim),
        rootBundle.loadString(HaderAssets.constants),
        rootBundle.loadString(HaderAssets.content),
        rootBundle.loadString(HaderAssets.remoteControl),
      ]);

      final scripts = <UserScript>[
        UserScript(
          groupName: 'hader-seed',
          source: 'window.__HADER_SEED__ = ${jsonEncode(seed)};',
          injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
          forMainFrameOnly: false,
        ),
        for (final entry in <MapEntry<String, String>>[
          MapEntry('hader-viewport', sources[0]),
          MapEntry('hader-shim', sources[1]),
          MapEntry('hader-constants', sources[2]),
        ])
          UserScript(
            groupName: entry.key,
            source: entry.value,
            injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
            forMainFrameOnly: false,
          ),
        UserScript(
          groupName: 'hader-content',
          source: sources[3],
          injectionTime: UserScriptInjectionTime.AT_DOCUMENT_END,
          forMainFrameOnly: false,
        ),
        UserScript(
          groupName: 'hader-remote-control',
          source: sources[4],
          // Reads what content.js rendered, so it has to come after it. Top
          // frame only: the automation's hidden iframe has no panel to harvest.
          injectionTime: UserScriptInjectionTime.AT_DOCUMENT_END,
          forMainFrameOnly: true,
        ),
      ];

      if (!mounted) return;
      setState(() => _userScripts = UnmodifiableListView(scripts));
    } catch (error) {
      if (!mounted) return;
      setState(() => _setupError = error.toString());
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Build
  // ───────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: ColorsManager.backgroundColorLight,
          appBar: AppBar(
            backgroundColor: ColorsManager.white,
            elevation: 0,
            centerTitle: true,
            title: Text(
              'تحضير الحصص',
              style: TextStylesManager.bold20
                  .copyWith(color: ColorsManager.themeActiveAccent),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              color: ColorsManager.themeDarkPrimary,
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            actions: [
              IconButton(
                tooltip: _showWebView ? 'إخفاء صفحة مدرستي' : 'عرض صفحة مدرستي',
                icon: Icon(_showWebView
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded),
                color: ColorsManager.themeDarkPrimary,
                onPressed: () => setState(() => _showWebView = !_showWebView),
              ),
            ],
          ),
          body: SafeArea(child: _buildBody()),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_setupError != null) {
      return _CenteredMessage(
        icon: Icons.error_outline_rounded,
        color: ColorsManager.errorColor,
        title: 'تعذّر تجهيز حضر',
        body: _setupError!,
        actionLabel: 'إعادة المحاولة',
        onAction: () {
          setState(() => _setupError = null);
          _prepareUserScripts();
        },
      );
    }

    if (_userScripts == null) {
      return const _CenteredMessage(
        loading: true,
        title: 'جارٍ تجهيز حضر…',
      );
    }

    // The engine sits in the tree at a real size but is pushed off-screen when
    // hidden. Collapsing it to a sliver instead made the page report
    // innerWidth 0 — the layout stops, and content.js needs a laid-out DOM to
    // find the schedule cards in.
    return Stack(
      children: [
        Positioned.fill(
          top: _showWebView ? _peekHeight : 0,
          child: BlocBuilder<HaderPrepCubit, HaderPrepState>(
            builder: (context, state) => _buildNativeUi(state),
          ),
        ),
        Positioned(
          top: _showWebView ? 0 : -_engineHeight - 200,
          left: 0,
          right: 0,
          height: _showWebView ? _peekHeight : _engineHeight,
          child: _buildWebView(),
        ),
      ],
    );
  }

  Widget _buildWebView() {
    return InAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(_startUrl)),
      initialUserScripts: _userScripts,
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        domStorageEnabled: true,
        databaseEnabled: true,
        preferredContentMode: UserPreferredContentMode.DESKTOP,
        userAgent: _desktopUserAgent,
        useWideViewPort: true,
        loadWithOverviewMode: true,
        supportMultipleWindows: false,
        javaScriptCanOpenWindowsAutomatically: false,
        thirdPartyCookiesEnabled: true,
        sharedCookiesEnabled: true,
        safeBrowsingEnabled: false,
      ),
      onWebViewCreated: (controller) {
        _cubit.attach(controller);
        _bridge.register(controller);
        controller.addJavaScriptHandler(
          handlerName: 'haderScheduleUpdate',
          callback: (args) {
            if (args.isNotEmpty && args.first is Map) {
              _cubit.onSnapshot(args.first as Map);
            }
            return true;
          },
        );
      },
      onConsoleMessage: (controller, message) {
        debugPrint('[HaderPrep] ${message.message}');
      },
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Native UI
  // ───────────────────────────────────────────────────────────────────────────

  Widget _buildNativeUi(HaderPrepState state) {
    if (state.phase == HaderPrepPhase.blocked) {
      return _CenteredMessage(
        icon: Icons.lock_outline_rounded,
        color: ColorsManager.statusWarning,
        title: 'التحضير متوقف',
        body: state.message.isNotEmpty
            ? state.message
            : 'تحقق من حالة اشتراكك ثم أعد المحاولة.',
        actionLabel: 'عرض صفحة مدرستي',
        onAction: () => setState(() => _showWebView = true),
      );
    }

    if (state.slots.isEmpty) {
      return const _CenteredMessage(
        loading: true,
        title: 'جارٍ قراءة جدولك من مدرستي…',
        body: 'قد يطلب منك تسجيل الدخول في أول مرة.',
      );
    }

    final grouped = <String, List<HaderLessonSlot>>{};
    for (final slot in state.slots) {
      grouped
          .putIfAbsent(slot.day.isNotEmpty ? slot.day : 'الحصص', () => [])
          .add(slot);
    }

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              for (final entry in grouped.entries) ...[
                _DayHeader(day: entry.key, count: entry.value.length),
                const SizedBox(height: 8),
                for (final slot in entry.value) ...[
                  _SlotCard(
                    slot: slot,
                    enabled: state.phase == HaderPrepPhase.ready,
                    onPick: () => _pickLesson(slot),
                    onClear: () => _cubit.clear(slot.token),
                  ),
                  const SizedBox(height: 10),
                ],
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
        _BottomBar(state: state, onStart: _cubit.startPreparation),
      ],
    );
  }

  Future<void> _pickLesson(HaderLessonSlot slot) async {
    final chosen = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LessonPicker(slot: slot),
    );
    if (chosen == null) return;
    await _cubit.select(slot.token, chosen);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pieces
// ─────────────────────────────────────────────────────────────────────────────

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.day, required this.count});

  final String day;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: ColorsManager.themeActiveAccent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          day,
          style: TextStylesManager.bold16
              .copyWith(color: ColorsManager.themeDarkPrimary),
        ),
        const SizedBox(width: 8),
        Text(
          '($count)',
          style:
              TextStylesManager.bold13.copyWith(color: ColorsManager.textBody),
        ),
      ],
    );
  }
}

class _SlotCard extends StatelessWidget {
  const _SlotCard({
    required this.slot,
    required this.enabled,
    required this.onPick,
    required this.onClear,
  });

  final HaderLessonSlot slot;
  final bool enabled;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final chosen = slot.hasSelection;
    final chosenText = chosen
        ? slot.options
            .firstWhere(
              (o) => o.value == slot.selected,
              orElse: () => const HaderLessonOption(value: '', text: 'درس محدد'),
            )
            .text
        : '';

    return Material(
      color: ColorsManager.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: enabled ? onPick : null,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: chosen
                  ? ColorsManager.themeActiveAccent.withValues(alpha: 0.55)
                  : ColorsManager.themeDivider,
              width: chosen ? 1.6 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    chosen
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    size: 20,
                    color: chosen
                        ? ColorsManager.statusSuccess
                        : ColorsManager.textBody,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      slot.title,
                      style: TextStylesManager.bold16
                          .copyWith(color: ColorsManager.themeDarkPrimary),
                    ),
                  ),
                  if (slot.period.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: ColorsManager.themeActiveAccent
                            .withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        slot.period,
                        style: TextStylesManager.bold12
                            .copyWith(color: ColorsManager.themeActiveAccent),
                      ),
                    ),
                ],
              ),
              if (slot.detail.isNotEmpty) ...[
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 28),
                  child: Text(
                    slot.detail,
                    style: TextStylesManager.bold13
                        .copyWith(color: ColorsManager.textBody),
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 28),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        chosen ? chosenText : 'اضغط لاختيار الدرس',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStylesManager.bold14.copyWith(
                          color: chosen
                              ? ColorsManager.themeActiveAccent
                              : ColorsManager.textBody,
                        ),
                      ),
                    ),
                    if (chosen && enabled)
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.close_rounded, size: 18),
                        color: ColorsManager.textBody,
                        onPressed: onClear,
                      )
                    else
                      Icon(Icons.chevron_left_rounded,
                          color: ColorsManager.textBody),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LessonPicker extends StatefulWidget {
  const _LessonPicker({required this.slot});

  final HaderLessonSlot slot;

  @override
  State<_LessonPicker> createState() => _LessonPickerState();
}

class _LessonPickerState extends State<_LessonPicker> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final options = widget.slot.options
        .where((o) => _query.isEmpty || o.text.contains(_query))
        .toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.92,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: ColorsManager.white,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: ColorsManager.themeDivider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.slot.title,
                      style: TextStylesManager.bold18
                          .copyWith(color: ColorsManager.themeDarkPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'اختر الدرس المناسب لهذه الحصة',
                      style: TextStylesManager.bold13
                          .copyWith(color: ColorsManager.textBody),
                    ),
                  ],
                ),
              ),
              // A subject can carry a hundred lessons; scrolling to one on a
              // phone is the thing that made the web dropdown painful.
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(
                    hintText: 'ابحث عن درس…',
                    prefixIcon: const Icon(Icons.search_rounded),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (v) => setState(() => _query = v.trim()),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: options.isEmpty
                    ? Center(
                        child: Text(
                          'لا توجد دروس مطابقة',
                          style: TextStylesManager.bold14
                              .copyWith(color: ColorsManager.textBody),
                        ),
                      )
                    : ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
                        itemCount: options.length,
                        separatorBuilder: (_, _) => Divider(
                          height: 1,
                          color: ColorsManager.themeDivider,
                        ),
                        itemBuilder: (context, i) {
                          final option = options[i];
                          final isCurrent =
                              option.value == widget.slot.selected;
                          return ListTile(
                            title: Text(
                              option.text,
                              style: TextStylesManager.bold14.copyWith(
                                color: isCurrent
                                    ? ColorsManager.themeActiveAccent
                                    : ColorsManager.themeDarkPrimary,
                              ),
                            ),
                            trailing: isCurrent
                                ? Icon(Icons.check_rounded,
                                    color: ColorsManager.themeActiveAccent)
                                : null,
                            onTap: () =>
                                Navigator.of(context).pop(option.value),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.state, required this.onStart});

  final HaderPrepState state;
  final Future<void> Function() onStart;

  @override
  Widget build(BuildContext context) {
    final busy = state.phase == HaderPrepPhase.preparing;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: ColorsManager.white,
        border: Border(top: BorderSide(color: ColorsManager.themeDivider)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (state.message.isNotEmpty) ...[
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: TextStylesManager.bold13
                  .copyWith(color: ColorsManager.textBody),
            ),
            const SizedBox(height: 10),
          ],
          Row(
            children: [
              Text(
                'المختار: ${state.selectedCount} من ${state.slots.length}',
                style: TextStylesManager.bold14
                    .copyWith(color: ColorsManager.themeDarkPrimary),
              ),
              const Spacer(),
              SizedBox(
                height: 46,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsManager.themeActiveAccent,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        ColorsManager.themeActiveAccent.withValues(alpha: 0.35),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: state.canPrepare && !busy ? onStart : null,
                  icon: busy
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.auto_awesome_rounded, size: 18),
                  label: Text(
                    busy ? 'جارٍ التحضير…' : 'ابدأ التحضير',
                    style: TextStylesManager.bold14
                        .copyWith(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CenteredMessage extends StatelessWidget {
  const _CenteredMessage({
    this.icon,
    this.color,
    required this.title,
    this.body,
    this.actionLabel,
    this.onAction,
    this.loading = false,
  });

  final IconData? icon;
  final Color? color;
  final String title;
  final String? body;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (loading)
              CircularProgressIndicator(color: ColorsManager.themeActiveAccent)
            else if (icon != null)
              Icon(icon, size: 46, color: color ?? ColorsManager.textBody),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStylesManager.bold18
                  .copyWith(color: ColorsManager.themeDarkPrimary),
            ),
            if (body != null && body!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                body!,
                textAlign: TextAlign.center,
                style: TextStylesManager.bold14
                    .copyWith(color: ColorsManager.textBody),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              ElevatedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
