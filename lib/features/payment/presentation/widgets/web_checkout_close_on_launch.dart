import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/di/injections.dart';
import 'package:moean/features/payment/presentation/cubit/web_checkout_cubit.dart';
import 'package:moean/features/payment/presentation/cubit/web_checkout_state.dart';

/// Closes the dialog or sheet it sits in once the browser has opened on the
/// website's checkout. Until then it stays up so its button can show the
/// loader, and an error leaves it open to try again.
class WebCheckoutCloseOnLaunch extends StatelessWidget {
  const WebCheckoutCloseOnLaunch({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<WebCheckoutCubit, WebCheckoutState>(
      bloc: sl<WebCheckoutCubit>(),
      listenWhen: (_, s) => s is WebCheckoutLaunched,
      listener: (context, _) {
        if (ModalRoute.of(context)?.isCurrent ?? false) {
          Navigator.of(context).pop();
        }
      },
      child: child,
    );
  }
}
