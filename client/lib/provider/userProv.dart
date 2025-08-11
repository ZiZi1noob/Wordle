import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _name;
  bool get isLoading => _isLoading;
  String? get name => _name;
}
