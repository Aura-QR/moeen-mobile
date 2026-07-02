import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/utils/constants/primary/circle_indecator.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/core/utils/extensions/context_extension.dart';
import 'package:moean/core/utils/platform_url/platform_url.dart';
import 'package:moean/features/login/presentation/cubit/madrasati_cubit.dart';

class MicrosoftLoginScreen extends StatefulWidget {
  const MicrosoftLoginScreen({super.key});

  @override
  State<MicrosoftLoginScreen> createState() => _MicrosoftLoginScreenState();
}

class _MicrosoftLoginScreenState extends State<MicrosoftLoginScreen>
    with TickerProviderStateMixin {
  // ── Mobile WebView fields ──────────────────────────────────────────────────
  final GlobalKey webViewKey = GlobalKey();
  InAppWebViewController? webViewController;
  double progress = 0;
  final String _madrasatiLoginUrl = 'https://schools.madrasati.sa/';
  bool _isConnecting = false;

  // ── Web manual-entry fields ────────────────────────────────────────────────
  int _webStep = 0; // 0 = intro, 1 = waiting, 2 = enter cookie
  final TextEditingController _cookieCtrl = TextEditingController();
  final TextEditingController _schoolIdCtrl = TextEditingController();
  bool _cookieObscured = true;
  final _formKey = GlobalKey<FormState>();

  // Animations
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _cookieCtrl.dispose();
    _schoolIdCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  // ── School-ID extractor (mobile) ───────────────────────────────────────────
  String _extractSchoolId(WebUri url) {
    final uri = Uri.tryParse(url.toString());
    if (uri == null) return '';
    final fromQuery = uri.queryParameters['schoolId'] ??
        uri.queryParameters['school_id'] ??
        uri.queryParameters['SchoolId'];
    if (fromQuery != null && fromQuery.isNotEmpty) return fromQuery;
    for (final segment in uri.pathSegments) {
      if (segment.length == 32 &&
          RegExp(r'^[a-zA-Z0-9]+$').hasMatch(segment)) {
        return segment;
      }
    }
    return '';
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  String _buildExpiresAt() {
    final exp = DateTime.now().add(const Duration(days: 30));
    return '${exp.year}-${exp.month.toString().padLeft(2, '0')}-'
        '${exp.day.toString().padLeft(2, '0')} '
        '${exp.hour.toString().padLeft(2, '0')}:'
        '${exp.minute.toString().padLeft(2, '0')}:00';
  }

  void _goToStep(int step) {
    _fadeCtrl.reverse().then((_) {
      setState(() => _webStep = step);
      _fadeCtrl.forward();
    });
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MadrasatiCubit(),
      child: BlocConsumer<MadrasatiCubit, MadrasatiState>(
        listener: _blocListener,
        builder: (context, state) {
          return Scaffold(
            backgroundColor: ColorsManager.background,
            appBar: AppBar(
              title: const Text('تسجيل الدخول في منصة مدرستي'),
              backgroundColor: ColorsManager.surfacePrimary,
              foregroundColor: ColorsManager.textPrimary,
              elevation: 0,
              centerTitle: true,
            ),
            body: SafeArea(
              child: kIsWeb
                  ? _buildWebBody(context, state)
                  : _buildMobileBody(context, state),
            ),
          );
        },
      ),
    );
  }

  void _blocListener(BuildContext context, MadrasatiState state) {
    if (state is MadrasatiSuccessState) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(state.message),
        backgroundColor: ColorsManager.successColor,
      ));
      context.pushNamedAndRemoveUntil(Routes.schedule, (r) => false);
    } else if (state is MadrasatiErrorState) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(state.message),
        backgroundColor: ColorsManager.errorColor,
      ));
      setState(() => _isConnecting = false);
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  MOBILE – InAppWebView (unchanged logic)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildMobileBody(BuildContext context, MadrasatiState state) {
    return Stack(
      children: [
        Column(
          children: [
            if (progress < 1.0)
              LinearProgressIndicator(
                value: progress,
                color: ColorsManager.primaryColor,
                backgroundColor:
                    ColorsManager.primaryColor.withValues(alpha: 0.2),
              ),
            Expanded(
              child: InAppWebView(
                key: webViewKey,
                initialUrlRequest:
                    URLRequest(url: WebUri(_madrasatiLoginUrl)),
                initialSettings: InAppWebViewSettings(
                  javaScriptEnabled: true,
                  domStorageEnabled: true,
                  databaseEnabled: true,
                  transparentBackground: true,
                  safeBrowsingEnabled: false,
                ),
                onWebViewCreated: (controller) {
                  webViewController = controller;
                  debugPrint('WebView Created');
                },
                onLoadStart: (controller, url) {
                  debugPrint('LOAD START – URL: $url');
                },
                onLoadStop: (controller, url) async {
                  setState(() => progress = 1.0);
                  final urlStr = url?.toString().toLowerCase() ?? '';
                  final isInsideMadrasati = urlStr.contains('teacher') ||
                      urlStr.contains('schoolschedule') ||
                      urlStr.contains('schoolmanagment');
                  if (!isInsideMadrasati || _isConnecting) {
                    debugPrint('Waiting for login… URL: $urlStr');
                    return;
                  }
                  setState(() => _isConnecting = true);
                  debugPrint('🎉 Login Detected! Extracting cookies…');
                  final cookieManager = CookieManager.instance();
                  final madrasatiCookies = await cookieManager.getCookies(
                      url: WebUri('https://schools.madrasati.sa/'));
                  final msCookies = await cookieManager.getCookies(
                      url: WebUri('https://login.microsoftonline.com/'));
                  final allCookies = [...madrasatiCookies, ...msCookies];
                  final sessionCookieStr =
                      allCookies.map((c) => '${c.name}=${c.value}').join('; ');
                  final schoolId = _extractSchoolId(url!);
                  // ignore: use_build_context_synchronously
                  MadrasatiCubit.get(context).connectMadrasati(
                    sessionCookie: sessionCookieStr,
                    madrasatiSchoolId: schoolId,
                    expiresAt: _buildExpiresAt(),
                  );
                },
                onReceivedError: (controller, request, error) {
                  debugPrint('WEBVIEW ERROR – ${error.description}');
                },
                onReceivedHttpError: (controller, request, response) {
                  debugPrint('HTTP ERROR – ${response.statusCode}');
                },
                onUpdateVisitedHistory: (controller, url, isReload) {
                  debugPrint('VISITED URL: $url');
                },
                onTitleChanged: (controller, title) {
                  debugPrint('PAGE TITLE: $title');
                },
                onProgressChanged: (controller, p) {
                  setState(() => progress = p / 100);
                },
              ),
            ),
          ],
        ),
        if (state is MadrasatiLoadingState)
          Container(
            color: Colors.black.withValues(alpha: 0.5),
            child: const Center(
              child: DiscreteCircle(
                size: 60,
                color: Color(0xFFD61F69),
                secondCircleColor: Color(0xFFE2AD3B),
                thirdCircleColor: Color(0xFF0E7A5E),
              ),
            ),
          ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  WEB – step-by-step manual cookie flow
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildWebBody(BuildContext context, MadrasatiState state) {
    return Stack(
      children: [
        Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: FadeTransition(
              opacity: _fadeAnim,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildWebHeader(),
                    const SizedBox(height: 32),
                    _buildStepIndicator(),
                    const SizedBox(height: 32),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      child: _webStep == 0
                          ? _buildWebStep0(context)
                          : _webStep == 1
                              ? _buildWebStep1(context)
                              : _buildWebStep2(context, state),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (state is MadrasatiLoadingState)
          Container(
            color: Colors.black.withValues(alpha: 0.5),
            child: const Center(
              child: DiscreteCircle(
                size: 60,
                color: Color(0xFFD61F69),
                secondCircleColor: Color(0xFFE2AD3B),
                thirdCircleColor: Color(0xFF0E7A5E),
              ),
            ),
          ),
      ],
    );
  }

  // ── Web header ─────────────────────────────────────────────────────────────
  Widget _buildWebHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorsManager.primaryColor.withValues(alpha: 0.12),
            ColorsManager.primaryColor.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: ColorsManager.primaryColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: ColorsManager.primaryColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.language_rounded,
                color: ColorsManager.primaryColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تسجيل الدخول عبر الويب',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: ColorsManager.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'موقع مدرستي لا يسمح بالتضمين داخل التطبيق على الويب،\nاتبع الخطوات أدناه للاتصال بحسابك.',
                  style: TextStyle(
                    fontSize: 13,
                    color: ColorsManager.textPrimary.withValues(alpha: 0.65),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Step indicator ─────────────────────────────────────────────────────────
  Widget _buildStepIndicator() {
    const steps = ['فتح الموقع', 'تسجيل الدخول', 'ربط الحساب'];
    return Row(
      children: List.generate(steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          return Expanded(
            child: Container(
              height: 2,
              color: i ~/ 2 < _webStep
                  ? ColorsManager.primaryColor
                  : ColorsManager.primaryColor.withValues(alpha: 0.2),
            ),
          );
        }
        final stepIdx = i ~/ 2;
        final done = stepIdx < _webStep;
        final active = stepIdx == _webStep;
        return Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done || active
                    ? ColorsManager.primaryColor
                    : ColorsManager.primaryColor.withValues(alpha: 0.12),
                border: Border.all(
                  color: ColorsManager.primaryColor,
                  width: active ? 2.5 : 0,
                ),
              ),
              child: Center(
                child: done
                    ? const Icon(Icons.check_rounded,
                        color: Colors.white, size: 18)
                    : Text(
                        '${stepIdx + 1}',
                        style: TextStyle(
                          color: active
                              ? Colors.white
                              : ColorsManager.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              steps[stepIdx],
              style: TextStyle(
                fontSize: 11,
                fontWeight:
                    active ? FontWeight.bold : FontWeight.normal,
                color: active
                    ? ColorsManager.primaryColor
                    : ColorsManager.textPrimary.withValues(alpha: 0.55),
              ),
            ),
          ],
        );
      }),
    );
  }

  // ── Step 0 – Intro ─────────────────────────────────────────────────────────
  Widget _buildWebStep0(BuildContext context) {
    return _stepCard(
      key: const ValueKey(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _infoTile(
            icon: Icons.open_in_new_rounded,
            color: const Color(0xFF2196F3),
            title: 'افتح موقع مدرستي',
            subtitle:
                'سيُفتح الموقع في تبويب جديد في المتصفح بشكل مستقل.',
          ),
          const SizedBox(height: 12),
          _infoTile(
            icon: Icons.login_rounded,
            color: const Color(0xFF4CAF50),
            title: 'سجّل الدخول بحساب Microsoft',
            subtitle: 'أكمل عملية تسجيل الدخول كاملاً حتى تصل للصفحة الرئيسية.',
          ),
          const SizedBox(height: 12),
          _infoTile(
            icon: Icons.link_rounded,
            color: ColorsManager.primaryColor,
            title: 'ارجع هنا وأدخل بيانات الجلسة',
            subtitle: 'سنوجّهك خطوة بخطوة لنسخ بيانات الجلسة من المتصفح.',
          ),
          const SizedBox(height: 28),
          _primaryButton(
            label: 'فتح موقع مدرستي',
            icon: Icons.open_in_new_rounded,
            onTap: () {
              openUrlInNewTab(_madrasatiLoginUrl);
              _goToStep(1);
            },
          ),
        ],
      ),
    );
  }

  // ── Step 1 – Waiting ───────────────────────────────────────────────────────
  Widget _buildWebStep1(BuildContext context) {
    return _stepCard(
      key: const ValueKey(1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.hourglass_top_rounded,
                  color: Color(0xFF4CAF50), size: 38),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'في انتظار تسجيل الدخول',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ColorsManager.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'يُرجى إتمام تسجيل الدخول في التبويب المفتوح.\nبعد الوصول للصفحة الرئيسية لمدرستي، عُد هنا.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: ColorsManager.textPrimary.withValues(alpha: 0.65),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 28),
          _primaryButton(
            label: 'لقد سجّلت الدخول، تابع',
            icon: Icons.arrow_forward_ios_rounded,
            onTap: () => _goToStep(2),
          ),
          const SizedBox(height: 12),
          _secondaryButton(
            label: 'إعادة فتح الموقع',
            icon: Icons.refresh_rounded,
            onTap: () => openUrlInNewTab(_madrasatiLoginUrl),
          ),
        ],
      ),
    );
  }

  // ── Step 2 – Cookie entry ──────────────────────────────────────────────────
  Widget _buildWebStep2(BuildContext context, MadrasatiState state) {
    return _stepCard(
      key: const ValueKey(2),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // How to get cookie - collapsible guide
            _cookieGuideCard(),
            const SizedBox(height: 24),

            // Cookie field
            Text(
              'كوكي الجلسة (.AspNetCore.Cookies)',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: ColorsManager.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _cookieCtrl,
              obscureText: _cookieObscured,
              maxLines: 1,
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'monospace',
                color: ColorsManager.textPrimary,
              ),
              decoration: _fieldDecoration(
                hint: 'الصق قيمة الكوكي هنا...',
                suffixIcon: IconButton(
                  icon: Icon(
                    _cookieObscured
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded,
                    color: ColorsManager.primaryColor,
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _cookieObscured = !_cookieObscured),
                ),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'يُرجى إدخال قيمة الكوكي';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // School ID field
            Text(
              'معرّف المدرسة (اختياري)',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: ColorsManager.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'يُمكن الحصول عليه من رابط URL بعد تسجيل الدخول (32 حرفاً)',
              style: TextStyle(
                fontSize: 11,
                color: ColorsManager.textPrimary.withValues(alpha: 0.55),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _schoolIdCtrl,
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'monospace',
                color: ColorsManager.textPrimary,
              ),
              decoration: _fieldDecoration(
                hint: 'مثال: a1b2c3d4e5f6... (32 حرف)',
              ),
            ),

            const SizedBox(height: 28),

            _primaryButton(
              label: 'ربط الحساب بمدرستي',
              icon: Icons.link_rounded,
              onTap: state is MadrasatiLoadingState
                  ? null
                  : () {
                      if (_formKey.currentState!.validate()) {
                        MadrasatiCubit.get(context).connectMadrasati(
                          sessionCookie: _cookieCtrl.text.trim(),
                          madrasatiSchoolId: _schoolIdCtrl.text.trim(),
                          expiresAt: _buildExpiresAt(),
                        );
                      }
                    },
            ),
            const SizedBox(height: 12),
            _secondaryButton(
              label: 'رجوع',
              icon: Icons.arrow_back_ios_rounded,
              onTap: () => _goToStep(1),
            ),
          ],
        ),
      ),
    );
  }

  // ── Cookie guide card ──────────────────────────────────────────────────────
  Widget _cookieGuideCard() {
    return Container(
      decoration: BoxDecoration(
        color: ColorsManager.primaryColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: ColorsManager.primaryColor.withValues(alpha: 0.2)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Icon(Icons.help_outline_rounded,
              color: ColorsManager.primaryColor, size: 22),
          title: Text(
            'كيف أحصل على كوكي الجلسة؟',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: ColorsManager.primaryColor,
            ),
          ),
          childrenPadding:
              const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          children: [
            _guideStep('١', 'في تبويب مدرستي، افتح أدوات المطوّر',
                'اضغط F12 أو كليك يمين ← "فحص" (Inspect)'),
            _guideStep('٢', 'اذهب إلى تبويب "Application"',
                'في الشريط العلوي لأدوات المطوّر'),
            _guideStep('٣', 'افتح Cookies ← schools.madrasati.sa',
                'في القائمة اليسرى تحت Storage'),
            _guideStep('٤', 'ابحث عن .AspNetCore.Cookies',
                'انقر عليها مرتين ثم انسخ القيمة كاملاً'),
            const SizedBox(height: 8),
            _cookieKeyBox('.AspNetCore.Cookies'),
          ],
        ),
      ),
    );
  }

  Widget _guideStep(String num, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            margin: const EdgeInsets.only(top: 2, left: 10),
            decoration: BoxDecoration(
              color: ColorsManager.primaryColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(num,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold)),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: ColorsManager.textPrimary)),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 12,
                        color:
                            ColorsManager.textPrimary.withValues(alpha: 0.6))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cookieKeyBox(String key) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.key_rounded,
              size: 16, color: ColorsManager.primaryColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              key,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: ColorsManager.textPrimary,
              ),
            ),
          ),
          IconButton(
            iconSize: 16,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: Icon(Icons.copy_rounded,
                color: ColorsManager.primaryColor, size: 16),
            onPressed: () =>
                Clipboard.setData(ClipboardData(text: key)),
          ),
        ],
      ),
    );
  }

  // ── Shared UI helpers ──────────────────────────────────────────────────────
  Widget _stepCard({required Widget child, required Key key}) {
    return Container(
      key: key,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ColorsManager.surfacePrimary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _infoTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: ColorsManager.textPrimary)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 12,
                        color:
                            ColorsManager.textPrimary.withValues(alpha: 0.6))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _primaryButton({
    required String label,
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorsManager.primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
      ),
      icon: Icon(icon, size: 18),
      label: Text(label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
    );
  }

  Widget _secondaryButton({
    required String label,
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return OutlinedButton.icon(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: ColorsManager.primaryColor,
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: BorderSide(
            color: ColorsManager.primaryColor.withValues(alpha: 0.4)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      icon: Icon(icon, size: 16),
      label: Text(label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
    );
  }

  InputDecoration _fieldDecoration({
    required String hint,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontSize: 12,
        color: ColorsManager.textPrimary.withValues(alpha: 0.4),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      filled: true,
      fillColor: ColorsManager.primaryColor.withValues(alpha: 0.04),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            BorderSide(color: ColorsManager.primaryColor.withValues(alpha: 0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            BorderSide(color: ColorsManager.primaryColor.withValues(alpha: 0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            BorderSide(color: ColorsManager.primaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: ColorsManager.errorColor),
      ),
      suffixIcon: suffixIcon,
    );
  }
}