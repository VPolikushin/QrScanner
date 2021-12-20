import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qr_scanner/services/auth.dart';
import 'package:qr_scanner/services/toast.dart';
import 'package:qr_scanner/services/validator.dart';

class ResetScreen extends StatefulWidget {
  static const routeName = '/resetScreen';
  const ResetScreen({Key? key, required this.email}) : super(key: key);
  final String email;

  @override
  _ResetScreenState createState() => _ResetScreenState();
}

class _ResetScreenState extends State<ResetScreen> with SingleTickerProviderStateMixin{

  late AnimationController animationController;
  final TextEditingController _emailController = TextEditingController();

  late String _email;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    animationController.forward();
    _emailController.text = widget.email;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    animationController.dispose();
    //_emailController.dispose();
  }


  Future<void> _resetPasswordButtonAction() async{
    _email = _emailController.text;

    final _emailError = Validator.validateEmail(email: _email);
    if(_emailError == null) {
      setState(() {
        isLoading = true;
      });

      final String? error = await AuthService().sendPasswordResetEmail(_email.trim());

      setState(() {
        isLoading = false;
      });

      if(error != null) {
        toastMsg('Неверная эл.почта ');
      }else {
        toastMsg('Письмо отправлено. Проверьте почту!');
        Navigator.of(context).pushNamed('/authScreen');
      }
    } else {
      if(_emailError != null) {
        toastMsg(Validator.validateEmail(email: _email)!);
      }
    }
    _emailController.clear();
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
      icon: const Icon(Icons.arrow_forward_ios, size: 23,),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Изменение пароля',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          onPressed: (){
            Navigator.of(context).pushNamed('/authScreen');
          },
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black,),
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
            const SizedBox(height: 30,),
            const Padding(
              padding: EdgeInsets.only(left: 35, right: 35),
              child: Text(
                  'Введите вашу эл.почту: ',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 18,
                    color: Colors.black87,
                  )
              ),
            ),
            form('Отправить', _resetPasswordButtonAction),
          ],
        ),
      ),
    );
  }
}
