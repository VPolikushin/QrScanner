import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_scanner/models/qr_database.dart';
import 'package:qr_scanner/models/user.dart';
import 'package:qr_scanner/services/auth.dart';
import 'package:qr_scanner/services/start_page.dart';
import 'package:qr_scanner/views/auth_screen.dart';
import 'package:qr_scanner/views/redactor_screen.dart';
import 'package:qr_scanner/views/reset_screen.dart';
import 'package:qr_scanner/views/scan_screen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamProvider<MyUser?>.value(
      value: AuthService().currentUser,
      initialData: null,
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primaryColor: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        debugShowCheckedModeBanner: false,
        // initialRoute: '/redactorScreen',
        home: StartPage(),
        onGenerateRoute: (RouteSettings settings){
          switch(settings.name) {
            case ScanScreen.routeName:
              return MaterialPageRoute(builder: (BuildContext context){
                return ScanScreen();
              },);
            case AuthorizationScreen.routeName:
              return MaterialPageRoute(builder: (BuildContext context){
                return AuthorizationScreen();
              },);
            case ResetScreen.routeName:
              final args = settings.arguments as List<dynamic>;
              return MaterialPageRoute(builder: (BuildContext context){
                return ResetScreen(email: args[0].toString());
              },);
            case NoteRedactorScreen.routeName:
              final args = settings.arguments as List<dynamic>;
              return MaterialPageRoute(builder: (BuildContext context){
                return NoteRedactorScreen(qrId: args[0].toString(), noteId: args[1].toString() );
              },);
          }
        },
      ),
    );
  }
}


