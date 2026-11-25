import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/di/injections.dart';
import 'package:moean/features/payment/presentation/cubit/web_checkout_cubit.dart';
import 'package:moean/features/payment/presentation/cubit/web_checkout_state.dart';

/// Wraps every subscribe / upgrade / renew button.
///
/// When the server has paying `off`, [hidden] is shown instead: no button and
/// no mention of the website. Otherwise [builder] gets whether a link is being
/// fetched, so the button can show its loader.
class WebCheckoutBuilder extends StatelessWidget {
  const WebCheckoutBuilder({
    super.key,
    required this.builder,
    this.hidden = const SizedBox.shrink(),
  });

  final Widget Function(BuildContext context, bool isOpening) builder;
  final Widget hidden;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WebCheckoutCubit, WebCheckoutState>(
      bloc: sl<WebCheckoutCubit>(),
      buildWhen: (previous, current) =>
          previous.mode != current.mode ||
          (previous is WebCheckoutOpening) != (current is WebCheckoutOpening),
      builder: (context, state) => state.canPay
          ? builder(context, state is WebCheckoutOpening)
          : hidden,
    );
  }
}
