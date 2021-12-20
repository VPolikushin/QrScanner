import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_scanner/models/user.dart';
import 'package:qr_scanner/views/auth_screen.dart';
import 'package:qr_scanner/views/scan_screen.dart';

class StartPage extends StatelessWidget {
  const StartPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _user = Provider.of<MyUser?>(context);
    final bool isLoggedIn = _user != null;
    return isLoggedIn ? ScanScreen() : AuthorizationScreen();
  }
}
