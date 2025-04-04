import 'package:final_project/pages/HomePage.dart';
import 'package:final_project/pages/LogIn.dart';
import 'package:final_project/pages/SignUp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:final_project/colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../auths/auth_service.dart';
import 'package:quickalert/quickalert.dart';

class ForgotPassword extends StatefulWidget {
  // final VoidCallback showLoginPage;
  // const SignUp({Key? key, required this.showLoginPage}) : super(key: key);
  ForgotPassword({Key? key}) : super(key: key);
  @override
  _ForgotPasswordWidgetState createState() => _ForgotPasswordWidgetState();
}

class _ForgotPasswordWidgetState extends State<ForgotPassword> {
  TextEditingController _emailController = TextEditingController();
  bool _error = false;
  FocusNode _emailFocusNode = FocusNode();
  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  Future ResetPassword() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text.trim());
      if (mounted) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          text: 'Request Send Success!',
          confirmBtnText: 'Oke',
          confirmBtnColor: ColorCustom.blueButton,
          onConfirmBtnTap: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => LogIn()),
              (Route<dynamic> route) => false,
            );
          },
        );
      }
    } on FirebaseAuthException catch (e) {
      print(e.code);
      if (confirmEmail() ||
          e.code == 'missing-email' ||
          e.code == 'invalid-email') {
        setState(() {
          _error = true;
        });
      }
    }
  }

  bool confirmEmail() {
    return (!RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(_emailController.text.trim()));
  }

  ////old
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Stack(
              children: <Widget>[
                // Background layer
                Container(
                  width: double.infinity,
                  height: 300,
                  child: Stack(
                    children: <Widget>[
                      Container(
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/bgforgot.png'),
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 9, 13, 72)
                              .withOpacity(0.4),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 5, 0, 0),
                        child: Container(
                          width: double.infinity,
                          alignment: Alignment.topLeft,
                          child: IconButton(
                            icon: Icon(Icons.arrow_back_ios),
                            style: ButtonStyle(
                                iconSize: MaterialStateProperty.all<double>(33),
                                iconColor: MaterialStateProperty.all<Color>(
                                    Colors.white)),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 60),
                        child: Container(
                          width: double.infinity,
                          child: const Text(
                            'E.max',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: 'alpenable',
                                color: Colors.white,
                                fontStyle: FontStyle.italic,
                                fontSize: 60),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 170),
                        child: Container(
                          width: double.infinity,
                          child: const Text(
                            'Forgot Password!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: 'Nunito',
                                color: Colors.white,
                                fontStyle: FontStyle.italic,
                                fontSize: 22),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Overlay layer
                Padding(
                  padding: const EdgeInsets.only(top: 250),
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(30.0, 25, 30, 0),
                      child: Column(
                        children: <Widget>[
                          const SizedBox(
                            height: 25,
                          ),
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Verification Email",
                                  style: TextStyle(
                                    color: ColorCustom.myGrey,
                                  ),
                                ),
                                TextField(
                                    focusNode: _emailFocusNode,
                                    controller: _emailController,
                                    decoration: InputDecoration(
                                      fillColor: Colors.blue,
                                      hintText: 'Enter your email',
                                      errorText: _error
                                          ? "Email is Invalidate or Not found!"
                                          : null,
                                      focusColor: Colors.blue,
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          width: 2,
                                          color: ColorCustom.blueButton,
                                        ),
                                      ),
                                      focusedErrorBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          width: 2,
                                          color: ColorCustom.blueButton,
                                        ),
                                      ),
                                      errorBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          width: 1,
                                          color: Color.fromARGB(
                                              255, 103, 103, 103),
                                        ),
                                      ),
                                    ),
                                    onChanged: (text) => {
                                          setState(() {
                                            _error = false;
                                          }),
                                        }),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorCustom.blueButton,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            onPressed: ResetPassword,
                            child: Container(
                              alignment: Alignment.center,
                              width: 250,
                              height: 55,
                              child: const Text(
                                'SEND',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Nunito',
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 90,
                                    child: Divider(
                                      height: 20,
                                      indent: 10,
                                      endIndent: 20,
                                      color: Color.fromARGB(255, 220, 219, 219),
                                      thickness: 1,
                                    ),
                                  ),
                                  Text(
                                    'Or login with',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: ColorCustom.myGrey,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Container(
                                    width: 90,
                                    child: Divider(
                                      height: 20,
                                      indent: 20,
                                      endIndent: 10,
                                      color: Color.fromARGB(255, 220, 219, 219),
                                      thickness: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10.0, 25, 10, 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                IconButton(
                                  onPressed: () {},
                                  iconSize: 50,
                                  icon: Icon(Icons.facebook),
                                  color: ColorCustom.blueButton,
                                ),
                                Container(
                                  width: 45,
                                  height: 45,
                                  child: InkWell(
                                    onTap: () async {
                                      var userCredential =
                                          await AuthServer().signInWithGoogle();
                                      if (userCredential != null) {
                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => HomePage()),
                                          (Route<dynamic> route) =>
                                              false, // This never allows any route to be kept.
                                        );
                                      } else {
                                        // Xử lý lỗi hoặc thông báo cho người dùng về việc đăng nhập không thành công
                                        print("Đăng nhập không thành công.");
                                      }
                                    },
                                    child: Image.asset(
                                      'assets/images/google.png',
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {},
                                  iconSize: 50,
                                  icon: Icon(FontAwesomeIcons.squareTwitter),
                                  color: ColorCustom.blueButton,
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: ColorCustom.blueButton,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => SignUp()),
                                    );
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    width: 150,
                                    height: 55,
                                    child: const Text(
                                      'SIGN UP',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'Nunito',
                                        color: Colors.white,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
