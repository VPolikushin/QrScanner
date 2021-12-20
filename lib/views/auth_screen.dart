
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qr_scanner/models/user.dart';
import 'package:qr_scanner/models/user_database.dart';
import 'package:qr_scanner/services/auth.dart';
import 'package:qr_scanner/services/database.dart';
import 'package:qr_scanner/services/toast.dart';
import 'package:qr_scanner/services/validator.dart';

class AuthorizationScreen extends StatefulWidget {
  static const routeName = '/authScreen';
  const AuthorizationScreen({Key? key}) : super(key: key);

  @override
  _AuthorizationScreenState createState() => _AuthorizationScreenState();
}

class _AuthorizationScreenState extends State<AuthorizationScreen> with SingleTickerProviderStateMixin{
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late AnimationController animationController;

  late String _email;
  late String _password;
  bool showLogin = true;
  bool isLoading = false;

  AuthService _authService = AuthService();
  UserInformation _userinfo = UserInformation();

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    animationController.forward();
  }



  @override
  void dispose() {
    animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _loginButtonAction() async{
    _email = _emailController.text;
    _password = _passwordController.text;

    final _emailError = Validator.validateEmail(email: _email);
    final _passwordError = Validator.validatePassword(password: _password);

    if((_emailError == null) && (_passwordError == null)) {
      setState(() {
        isLoading = true;
      });

      final MyUser ? user = await _authService.signInWithEmailAndPassword(_email.trim(), _password.trim());

      setState(() {
        isLoading = false;
      });

      if(user == null) {
        toastMsg('Неверная эл.почта или пароль');
      }
    }
    else {
      if(_emailError != null) {
        toastMsg(Validator.validateEmail(email: _email)!);
      }
      if(_passwordError != null) {
        toastMsg(Validator.validatePassword(password: _password)!);
      }
    }

    _emailController.clear();
    _passwordController.clear();
  }

  void _registerButtonAction() async{
    _email = _emailController.text;
    _password = _passwordController.text;

    final _emailError = Validator.validateEmail(email: _email);
    final _passwordError = Validator.validatePassword(password: _password);

    if((_emailError == null) && (_passwordError == null)) {
      setState(() {
        isLoading = true;
      });

      final MyUser ? user = await _authService.registerInWithEmailAndPassword(_email.trim(), _password.trim());

      if(user == null) {
        setState(() {
          isLoading = false;
        });
        toastMsg('Неверная эл.почта или пароль');
      } else {
        _userinfo.isAdmin = false;
        await DatabaseService().addOrUpdateUserInformation(_userinfo);
        setState(() {
          isLoading = false;
        });
      }
    }
    else {
      if(_emailError != null) {
        toastMsg(Validator.validateEmail(email: _email)!);
      }
      if(_passwordError != null) {
        toastMsg(Validator.validatePassword(password: _password)!);
      }
    }

    _emailController.clear();
    _passwordController.clear();
  }

  void _resetPasswordButtonAction() {
    _email = _emailController.text;
    Navigator.of(context).pushNamed('/resetScreen', arguments: [_email]);
  }

  Widget logo(String icon) {
    return Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.01),
        child: Align(
          child: Image.asset(
            icon,
            fit: BoxFit.contain,
            width: MediaQuery.of(context).size.width / 4,
            height: MediaQuery.of(context).size.height / 4,
          ),
        ),
    );
  }

  Widget input(IconData icon, String hint, TextEditingController controller, bool obscure) {
    return Container(
      padding: const EdgeInsets.only(left: 35, right: 35,),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(
          fontSize: 18,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          hintStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black12,
          ),
          hintText: hint,
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(
                color: Colors.black26,
              width: 2.5,
            ),
          ),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(
              color: Colors.black12,
              width: 2,
            ),
          ),
          prefixIcon: Icon(icon, color: Colors.black87,),

        ),
      ),
    );
  }

  Widget button(String text, void Function() func){
    return ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40),
          ),
          primary: Colors.black87,

        ),
        onPressed: func,
        label: Text(
            text,
            style: const TextStyle(
              fontSize: 18,
            ),
        ),
        icon: Icon(showLogin ? Icons.login : Icons.app_registration, size: 23,),
    );
  }

  Widget form(String label, void Function() func){
    return Column(
      children: [
        Padding(
            padding: const EdgeInsets.only(bottom: 20, top: 10),
            child: input(Icons.email_outlined, 'Эл. почта', _emailController, false),
        ),
        Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: input(Icons.lock_outlined, 'Пароль', _passwordController, true),
        ),
        label == 'Войти' ? resetPass() : Container(),
        Padding(
            padding: const EdgeInsets.only(left: 35, right: 35, top: 20),
            child: SizedBox(
              height: 50,
              width: MediaQuery.of(context).size.width,
              child: button(label, func),
            ),
        ),
      ],
    );
  }

  Widget resetPass() {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
          padding: const EdgeInsets.only(right: 35, bottom: 20,),
          child: InkWell(
            onTap: (){
              _resetPasswordButtonAction();
            },
            child: const Text(
                'Забыли пароль?',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.black87,
                ),
            ),
          ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          showLogin
              ? 'Войти в кабинет'
              : 'Создание кабинета',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black,
          ),
        ),
      ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator(
                color: Colors.black,
              ),
            )
            : FadeTransition(
          opacity: animationController.drive(CurveTween(curve: Curves.linear)),
          child: ListView(
            children: [
              logo('assets/images/logo.png'),
              if (showLogin) Column(
                children: [
                  form('Войти', _loginButtonAction),
                  InkWell(
                    child: Container(
                      margin: const EdgeInsets.all(14),
                      child: const Text.rich(
                        TextSpan(
                          text: 'Еще нет аккаунта?  ',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black38,
                          ),
                          children: [
                            TextSpan(
                                text: 'Создать!',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                )
                            ),
                          ],
                        ),
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        showLogin = false;
                      });
                    },
                  ),
                ],
              ) else Column(
                children: [
                  form('Создать', _registerButtonAction),
                  InkWell(
                    child: Container(
                      margin: const EdgeInsets.all(14),
                      child: const Text.rich(
                        TextSpan(
                          text: 'Уже есть аккаунт?  ',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black38,
                          ),
                          children: [
                            TextSpan(
                              text: 'Войти!',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        showLogin = true;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        )
    );
  }
}
