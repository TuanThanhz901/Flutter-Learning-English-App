import 'package:final_project/auths/auth_service.dart';
import 'package:final_project/pages/HomePage.dart';
import 'package:final_project/pages/SignUp.dart';
import 'package:final_project/pages/forgot_password.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:final_project/colors.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LogIn extends StatefulWidget {
  LogIn({Key? key}) : super(key: key);
  @override
  _LogInWidgetState createState() => _LogInWidgetState();
}

class _LogInWidgetState extends State<LogIn> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool _emailError = false;
  bool _passwordError = false;
  bool _isObscure = true;
  bool _isLoading = false;
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  final GoogleSignIn googleSignIn = GoogleSignIn();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(() {
      if (_emailFocusNode.hasFocus) {
        setState(() {
          _passwordError = false;
        });
      }
    });
    _passwordFocusNode.addListener(() {
      if (_passwordFocusNode.hasFocus) {
        setState(() {
          _passwordError = false;
        });
      }
    });
  }

  void _submit() {
    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
    FocusScope.of(context).unfocus();
  }

  void _submit1() {
    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
    FocusScope.of(context).unfocus();
  }

  Future<void> login() async {
    validateText();
    _submit1();
    if (!confirmEmail()) {
      try {
        _submit();
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
          (Route<dynamic> route) => false,
        );
      } on FirebaseAuthException catch (e) {
        print(e.code);
        setState(() {
          _passwordError = true;
        });
      }
    } else {
      setState(() {
        _passwordError = true;
      });
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isObscure = !_isObscure;
    });
  }

  bool confirmEmail() {
    return (!RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(_emailController.text.trim()));
  }

  String validateText() {
    if (confirmEmail() || _emailController.text.isEmpty) {
      return 'Email is Invalidate!';
    } else {
      return 'Password is not match or Not enough 6 characters!';
    }
  }

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
                Container(
                  width: double.infinity,
                  height: 300,
                  child: Stack(
                    children: <Widget>[
                      Container(
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/BgLogIn.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 9, 13, 72)
                              .withOpacity(0.2),
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
                            'Welcom Back!',
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
                Padding(
                  padding: const EdgeInsets.only(top: 220),
                  child: Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height - 220,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(30.0, 5, 30, 0),
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
                                  "Email",
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
                                    errorText:
                                        _emailError ? 'Email not found!' : null,
                                    focusColor: Colors.blue,
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        width: 2,
                                        color: ColorCustom.blueButton,
                                      ),
                                    ),
                                  ),
                                  onChanged: (text) => {
                                    setState(() {
                                      _passwordError = false;
                                    }),
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Password",
                                  style: TextStyle(
                                    color: ColorCustom.myGrey,
                                  ),
                                ),
                                TextField(
                                  focusNode: _passwordFocusNode,
                                  controller: _passwordController,
                                  obscureText: _isObscure,
                                  decoration: InputDecoration(
                                    hintText: 'Enter your password',
                                    errorText: _passwordError
                                        ? 'Incorrect Email or Password!'
                                        : null,
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
                                        color:
                                            Color.fromARGB(255, 103, 103, 103),
                                      ),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _isObscure
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: const Color.fromARGB(
                                            255, 200, 200, 200),
                                      ),
                                      onPressed: _togglePasswordVisibility,
                                    ),
                                  ),
                                  onChanged: (text) {
                                    setState(() {
                                      _passwordError = false;
                                    });
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 5.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ForgotPassword()),
                                          );
                                        },
                                        child: Text(
                                          "Forgot password?",
                                          style: TextStyle(
                                            fontStyle: FontStyle.italic,
                                            fontFamily: 'Nunito',
                                            color: Color.fromARGB(
                                                255, 116, 116, 116),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(height: 37),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorCustom.blueButton,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            onPressed: _isLoading
                                ? null
                                : () {
                                    login();
                                  },
                            child: _isLoading
                                ? CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  )
                                : Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                    child: Container(
                                      alignment: Alignment.center,
                                      width: 250,
                                      height: 55,
                                      child: const Text(
                                        'LOG IN',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: 'Nunito',
                                          color: Colors.white,
                                          fontSize: 18,
                                        ),
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
                                          (Route<dynamic> route) => false,
                                        );
                                      } else {
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
                                Text(
                                  'Don\'t have account?',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: ColorCustom.myGrey,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => SignUp()),
                                    );
                                  },
                                  child: Text(
                                    'Sign Up',
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w500,
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
