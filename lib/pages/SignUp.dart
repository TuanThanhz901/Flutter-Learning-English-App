import 'package:final_project/auths/auth_service.dart';
import 'package:final_project/pages/HomePage.dart';
import 'package:final_project/pages/LogIn.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:final_project/colors.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class SignUp extends StatefulWidget {
  // final VoidCallback showLoginPage;
  // const SignUp({Key? key, required this.showLoginPage}) : super(key: key);
  SignUp({Key? key}) : super(key: key);
  @override
  _SignupWidgetState createState() => _SignupWidgetState();
}

class _SignupWidgetState extends State<SignUp> {
  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();
  TextEditingController _repassword = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  DatabaseReference? ref;
  bool _error = false;

  bool _isObscure = true;

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _repasswordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    ref = FirebaseDatabase.instance.ref().child('users');
    _emailFocusNode.addListener(() {
      if (_emailFocusNode.hasFocus) {
        setState(() {
          _error = false;
        });
      }
    });
    _passwordFocusNode.addListener(() {
      if (_passwordFocusNode.hasFocus) {
        setState(() {
          _error = false;
        });
      }
    });
    _repasswordFocusNode.addListener(() {
      if (_repasswordFocusNode.hasFocus) {
        setState(() {
          _error = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _repassword.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _repasswordFocusNode.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isObscure = !_isObscure;
    });
  }

  Future<void> signUp() async {
    validateText();
    if (confirmPassword() && !confirmEmail()) {
      try {
        await _auth.createUserWithEmailAndPassword(
            email: _email.text.trim(), password: _password.text.trim());

        List<String> name = _email.text.split('@');
        print(name[0]);

        addUser();
      } on FirebaseAuthException catch (e) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.warning,
          text: e.message,
          confirmBtnText: 'Oke',
          confirmBtnColor: ColorCustom.blueButton,
        );
        // ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(content: Text(e.message ?? 'An unknown error occurred')));
      }
    } else {
      setState(() {
        _error = true;
      });
    }
  }

  addUser() async {
    await ref!.push().set({
      "name": _email.text.split('@')[0],
      "email": _email.text.trim(),
    }).whenComplete(() => (
          Fluttertoast.showToast(
            msg: "Sign Up successfully!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0,
          ),
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LogIn()),
            (Route<dynamic> route) => false,
          ),
        ));
  }

  String validateText() {
    if (confirmEmail() || _email.text.isEmpty) {
      return 'Email is Invalidate!';
    } else {
      return 'Password is not match or Not enough 6 characters!';
    }
  }

  bool confirmPassword() {
    return _password.text.trim() == _repassword.text.trim() &&
        _password.text.length >= 6;
  }

  bool confirmEmail() {
    return (!RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(_email.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Stack(
            children: <Widget>[
              // Background layer
              Container(
                width: double.infinity,
                height: 280,
                child: Stack(
                  children: <Widget>[
                    Container(
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/Bg.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 9, 13, 72)
                            .withOpacity(0.6),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 80),
                      child: Container(
                        width: double.infinity,
                        child: const Text(
                          'Create An Account',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: 'Nunito',
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 25),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              // Overlay layer
              Padding(
                padding: const EdgeInsets.only(top: 170),
                child: Container(
                  width: double.infinity,
                  // height: double.infinity,
                  constraints:
                      BoxConstraints(maxHeight: 600), // Set a maximum height
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
                                  controller: _email,
                                  decoration: InputDecoration(
                                    hintText: 'Enter you email',
                                    focusColor: Colors.blue,
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        width: 2,
                                        color: ColorCustom.blueButton,
                                      ),
                                    ),
                                  ),
                                  onChanged: (text) {
                                    setState(() {
                                      _error = false;
                                    });
                                  }),
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
                                  controller: _password,
                                  focusNode: _passwordFocusNode,
                                  obscureText: _isObscure,
                                  decoration: InputDecoration(
                                    hintText: 'Enter your password',
                                    focusColor: Colors.blue,
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        width: 2,
                                        color: ColorCustom.blueButton,
                                      ),
                                    ),
                                    // suffixIcon: IconButton(
                                    //   icon: Icon(
                                    //     _isObscure
                                    //         ? Icons.visibility
                                    //         : Icons.visibility_off,
                                    //     color: const Color.fromARGB(
                                    //         255, 200, 200, 200),
                                    //   ),
                                    //   onPressed: _togglePasswordVisibility,
                                    // ),
                                  ),
                                  onChanged: (text) {
                                    setState(() {
                                      _error = false;
                                    });
                                  }),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Re-Password",
                                style: TextStyle(
                                  color: ColorCustom.myGrey,
                                ),
                              ),
                              TextField(
                                  controller: _repassword,
                                  obscureText: _isObscure,
                                  focusNode: _repasswordFocusNode,
                                  decoration: InputDecoration(
                                    hintText: 'Enter re-password',
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
                                        color:
                                            Color.fromARGB(255, 103, 103, 103),
                                      ),
                                    ),
                                    errorText: _error ? validateText() : null,
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
                                      _error = false;
                                    });
                                  }),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 40.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorCustom.blueButton,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            onPressed: () {
                              signUp();
                            },
                            child: Container(
                              alignment: Alignment.center,
                              width: 250,
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
                          padding: const EdgeInsets.only(top: 15.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Have an account?',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: ColorCustom.myGrey,
                                  // fontFamily: 'Numito',
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => LogIn()),
                                  );
                                },
                                child: Text(
                                  'Log In',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w500,
                                    // fontFamily: 'Numito',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
