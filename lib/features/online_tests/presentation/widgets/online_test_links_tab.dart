import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_snack_bar.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/online_tests/data/models/online_test_models.dart';
import 'package:moean/features/online_tests/presentation/cubit/online_test_cubit.dart';
import 'package:moean/features/online_tests/presentation/screens/online_test_screen.dart';
import 'package:share_plus/share_plus.dart';

class OnlineTestLinksTab extends StatefulWidget {
  const OnlineTestLinksTab({super.key});

  @override
  State<OnlineTestLinksTab> createState() => _OnlineTestLinksTabState();
}

class _OnlineTestLinksTabState extends State<OnlineTestLinksTab> {
  final TextEditingController _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = OnlineTestCubit.get(context);
    final state = context.watch<OnlineTestCubit>().state;
    final test = state.test!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final group in test.groups) ...[
          _LinkCard(test: test, group: group),
          verticalSpace12,
        ],
        if (test.groups.length < 10)
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _name,
                  maxLength: 60,
                  style: TextStylesManager.regular14.copyWith(color: ColorsManager.mainText),
                  decoration: InputDecoration(
                    hintText: appTranslation().get('online_tests_another_class'),
                    isDense: true,
                    filled: true,
                    fillColor: ColorsManager.surfacePrimary,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              horizontalSpace8,
              IconButton.filledTonal(
                icon: const Icon(Icons.add),
                onPressed: state.isBusy
                    ? null
                    : () {
                        cubit.addGroup(_name.text);
                        _name.clear();
                      },
              ),
            ],
          ),
      ],
    );
  }
}

class _LinkCard extends StatelessWidget {
  final OnlineTest test;
  final OnlineTestGroup group;

  const _LinkCard({required this.test, required this.group});

  void _project(BuildContext context, Uint8List? qr) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${test.title} — ${group.name}', textAlign: TextAlign.center, style: TextStylesManager.bold22.copyWith(color: Colors.black)),
                    verticalSpace16,
                    if (qr != null) Image.memory(qr, width: 320, height: 320),
                    verticalSpace16,
                    Text(group.url.replaceFirst(RegExp(r'^https?://'), ''), textDirection: TextDirection.ltr, style: TextStylesManager.bold18.copyWith(color: Colors.black)),
                    verticalSpace8,
                    Text(appTranslation().get('online_tests_tap_to_close'), style: TextStylesManager.regular12.copyWith(color: Colors.black54)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final qr = OnlineTestScreen.qrBytes(group.qr);
    final share = '${test.title} — ${group.name}\n${group.url}';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: ColorsManager.surfacePrimary, borderRadius: BorderRadius.circular(16), border: Border.all(color: ColorsManager.borderLightGray)),
      child: Column(
        children: [
          Text(group.name, style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText)),
          verticalSpace8,
          if (qr != null)
            Container(color: Colors.white, padding: const EdgeInsets.all(6), child: Image.memory(qr, width: 170, height: 170)),
          verticalSpace8,
          SelectableText(group.url, textDirection: TextDirection.ltr, style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText)),
          Text('${group.submissions} ${appTranslation().get('online_tests_submissions')}', style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText)),
          verticalSpace8,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: ColorsManager.primaryColor),
                icon: const Icon(Icons.share, size: 18),
                label: Text(appTranslation().get('online_tests_share_link')),
                onPressed: () => SharePlus.instance.share(ShareParams(text: share)),
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.copy, size: 18),
                label: Text(appTranslation().get('online_tests_copy')),
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: group.url));
                  if (context.mounted) showPrimarySnackBar(context, appTranslation().get('online_tests_copied'), isError: false);
                },
              ),
              if (qr != null)
                OutlinedButton.icon(
                  icon: const Icon(Icons.qr_code, size: 18),
                  label: Text(appTranslation().get('online_tests_share_qr')),
                  onPressed: () => SharePlus.instance.share(ShareParams(
                    files: [XFile.fromData(qr, mimeType: 'image/png', name: 'qr-${group.name}.png')],
                    fileNameOverrides: ['qr-${group.name}.png'],
                    text: share,
                  )),
                ),
              OutlinedButton.icon(
                icon: const Icon(Icons.fullscreen, size: 18),
                label: Text(appTranslation().get('online_tests_project')),
                onPressed: () => _project(context, qr),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
