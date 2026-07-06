part of 'extension_install_cubit.dart';

abstract class ExtensionInstallState {
  final bool isQuettaInstalled;
  const ExtensionInstallState({this.isQuettaInstalled = false});
}

/// Default state tracking whether Quetta is installed.
class ExtensionInstallReady extends ExtensionInstallState {
  const ExtensionInstallReady({required super.isQuettaInstalled});
}

/// Running on iOS — show the "desktop-only" dialog.
class ExtensionInstallIosNotSupported extends ExtensionInstallState {
  const ExtensionInstallIosNotSupported({super.isQuettaInstalled});
}

/// Unexpected error during the flow.
class ExtensionInstallError extends ExtensionInstallState {
  final String message;
  const ExtensionInstallError({
    required this.message,
    required super.isQuettaInstalled,
  });
}
