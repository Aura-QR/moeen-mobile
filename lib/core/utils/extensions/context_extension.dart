import 'package:flutter/material.dart';

extension NavigationExtension on BuildContext {
  void push<ARG>(
    String routeName, {
    ARG? arguments,
  }) => Navigator.pushNamed(
    this,
    routeName,
    arguments: arguments,
  );

  void pushReplacement<ARG>(
    String routeName, {
    ARG? arguments,
  }) => Navigator.pushReplacementNamed(
    this,
    routeName,
    arguments: arguments,
  );

  void pushNamedAndRemoveUntil<ARG>(
    String routeName,
    RoutePredicate predicate, {
    ARG? arguments,
  }) => Navigator.pushNamedAndRemoveUntil(
    this,
    routeName,
    predicate,
    arguments: arguments,
  );

  void pop([Object? result]) => Navigator.pop(this, result);

  ARG? getArg<ARG>() {
    final args = ModalRoute.of(this)?.settings.arguments;
    if (args is ARG) {
      return args;
    }
    return null;
  }
}
