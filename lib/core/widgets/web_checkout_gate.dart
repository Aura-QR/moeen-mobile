import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/di/injections.dart';
import 'package:moean/core/utils/constants/primary/primary_snack_bar.dart';
import 'package:moean/features/payment/presentation/cubit/web_checkout_cubit.dart';
import 'package:moean/features/payment/presentation/cubit/web_checkout_state.dart';
import 'package:moean/main.dart';

/// Sits inside [MaterialApp.builder], so a subscribe tap from any screen is
/// followed up the same way: when the teacher comes back from the website's
/// checkout, the subscription is checked again, and the outcome (or a failed
/// tap) is reported in a snackbar.
///
/// Stateful only to observe the app lifecycle; the logic is in
/// [WebCheckoutCubit].
class WebCheckoutGate extends StatefulWidget {
  const WebCheckoutGate({super.key, required this.child});

  final Widget child;

  @override
  State<WebCheckoutGate> createState() => _WebCheckoutGateState();
}

class _WebCheckoutGateState extends State<WebCheckoutGate>
    with WidgetsBindingObserver {
  /// Only a real trip away from the app counts as coming back: the brief
  /// `inactive` blip while a system sheet shows is not a return from paying.
  bool _wentAway = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _wentAway = true;
    } else if (state == AppLifecycleState.resumed && _wentAway) {
      _wentAway = false;
      sl<WebCheckoutCubit>().onAppResumed();
    }
  }

  void _report(BuildContext _, WebCheckoutState state) {
    final context = navigatorKey.currentContext;
    if (context == null) return;
    if (state is WebCheckoutFailed) {
      showPrimarySnackBar(context, state.message);
    } else if (state is WebCheckoutActivated) {
      showPrimarySnackBar(context, 'web_checkout_activated', isError: false);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WebCheckoutCubit, WebCheckoutState>(
      bloc: sl<WebCheckoutCubit>(),
      listenWhen: (_, s) => s is WebCheckoutFailed || s is WebCheckoutActivated,
      listener: _report,
      child: widget.child,
    );
  }
}
