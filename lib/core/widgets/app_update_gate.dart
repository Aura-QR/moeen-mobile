import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/update/app_update_service.dart';
import 'package:url_launcher/url_launcher.dart';

/// Prompts the teacher when a newer build is on the store.
///
/// Sits inside [MaterialApp.builder] alongside SessionMonitorWrapper, so the
/// prompt appears whatever screen the app opened on. The check runs once per
/// launch and never blocks startup: an unreachable server simply means no
/// prompt.
class AppUpdateGate extends StatefulWidget {
  const AppUpdateGate({super.key, required this.child});

  final Widget child;

  @override
  State<AppUpdateGate> createState() => _AppUpdateGateState();
}

class _AppUpdateGateState extends State<AppUpdateGate> {
  bool _handled = false;

  @override
  void initState() {
    super.initState();
    // After the first frame, so the prompt has a Navigator to attach to and
    // the teacher sees the app render rather than a dialog over a blank screen.
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  Future<void> _check() async {
    if (_handled) return;
    _handled = true;

    final update = await AppUpdateService.check();
    if (update == null || !mounted) return;

    // A forced update ignores the skip: it exists precisely for releases the
    // teacher cannot keep working without.
    if (!update.forceUpdate &&
        await AppUpdateService.wasSkipped(update.latestVersion)) {
      return;
    }

    if (!mounted) return;
    await _show(update);
  }

  Future<void> _show(AppUpdateInfo update) async {
    await showDialog<void>(
      context: context,
      // A forced update has no way out — not the back button either, or the
      // wall it exists to be would be one gesture wide.
      barrierDismissible: !update.forceUpdate,
      builder: (dialogContext) => PopScope(
        canPop: !update.forceUpdate,
        child: AlertDialog(
          title: Text(
            update.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(update.message),
              if (update.latestVersion.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'الإصدار ${update.latestVersion}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(dialogContext).hintColor,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            if (!update.forceUpdate)
              TextButton(
                onPressed: () {
                  AppUpdateService.skip(update.latestVersion);
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('لاحقاً'),
              ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: ColorsManager.themeActiveAccent,
              ),
              onPressed: () => _openStore(update.storeUrl),
              child: const Text('تحديث الآن'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openStore(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;

    // The dialog is left standing on purpose. The store opens outside the app,
    // and dismissing first would let a forced update be escaped by tapping
    // "update" and then coming straight back.
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
