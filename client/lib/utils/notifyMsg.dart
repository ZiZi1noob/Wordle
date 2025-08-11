import 'package:flutter/material.dart';

Future<void> notifyMsg(
  String message,
  BuildContext context,
  color, [
  int seconds = 1,
]) async {
  //final scaffold = ScaffoldMessenger.of(context);

  final scaffold = ScaffoldMessenger.of(context);
  scaffold.removeCurrentSnackBar();

  final controller = scaffold.showSnackBar(
    SnackBar(
      content: Text(message),
      duration: Duration(seconds: seconds),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: color,
    ),
  );
  await controller.closed;
}
