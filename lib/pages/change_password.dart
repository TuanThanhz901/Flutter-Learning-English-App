import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:final_project/colors.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class ChangePassword extends StatefulWidget {
  ChangePassword({Key? key}) : super(key: key);
  @override
  _ChangePasswordWidgetState createState() => _ChangePasswordWidgetState();
}

class _ChangePasswordWidgetState extends State<ChangePassword> {
  TextEditingController _oldPassword = TextEditingController();
  TextEditingController _password = TextEditingController();
  TextEditingController _repassword = TextEditingController();
  bool _errorNewPassword = false;
  bool _erroOldPassword = false;
  bool _isObscure = true;
  bool _isObscure1 = true;
  final user = FirebaseAuth.instance.currentUser;

  final FocusNode _oldPasswordFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _repasswordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _oldPasswordFocusNode.addListener(() {
      if (_oldPasswordFocusNode.hasFocus) {
        setState(() {
          _erroOldPassword = false;
        });
      }
    });
    _passwordFocusNode.addListener(() {
      if (_passwordFocusNode.hasFocus) {
        setState(() {
          _errorNewPassword = false;
        });
      }
    });
    _repasswordFocusNode.addListener(() {
      if (_repasswordFocusNode.hasFocus) {
        setState(() {
          _errorNewPassword = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _oldPassword.dispose();
    _password.dispose();
    _repassword.dispose();
    _oldPasswordFocusNode.dispose();
    _passwordFocusNode.dispose();
    _repasswordFocusNode.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isObscure = !_isObscure;
    });
  }

  void _togglePasswordVisibility1() {
    setState(() {
      _isObscure1 = !_isObscure1;
    });
  }

  bool confirmPassword() {
    if (_password.text.isEmpty || _repassword.text.isEmpty) {
      return false;
    } else if (_password.text.trim() != _repassword.text.trim()) {
      return false;
    }
    return true;
  }

  Future<bool> confirmOldPassword() async {
    User? user = FirebaseAuth.instance.currentUser;
    String email = user?.email ?? ""; // Lấy email của người dùng hiện tại

    // Tạo AuthCredential với email và mật khẩu cũ
    AuthCredential credential =
        EmailAuthProvider.credential(email: email, password: _oldPassword.text);

    try {
      // Xác thực lại với credential
      await user!.reauthenticateWithCredential(credential);

      return true; // Xác thực thành công
    } on FirebaseAuthException catch (e) {
      print("Error re-authenticating: ${e.message}");
      setState(() {
        _erroOldPassword = false;
      });
      return false; // Xác thực thất bại
    }
  }

  Future<void> changePassword() async {
    bool isOldPasswordConfirmed = await confirmOldPassword();
    if (!isOldPasswordConfirmed) {
      setState(() {
        _erroOldPassword = true;
      });
    } else if (!confirmPassword()) {
      setState(() {
        _errorNewPassword = true;
      });
    } else {
      user!.updatePassword(_password.text);
      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        text: "Change Password Successful!",
        confirmBtnText: 'Oke',
        confirmBtnColor: ColorCustom.blueButton,
      );
      _oldPassword.clear();
      _password.clear();
      _repassword.clear();
    }
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
              // Overlay layer
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 5, 0, 0),
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back_ios),
                    style: ButtonStyle(
                        iconSize: MaterialStateProperty.all<double>(35),
                        iconColor: MaterialStateProperty.all<Color>(
                            ColorCustom.myGrey)),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 190),
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
                        const SizedBox(
                          height: 25,
                        ),
                        const Text(
                          "Change Password",
                          style: TextStyle(
                            color: ColorCustom.myGrey,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Old password",
                                style: TextStyle(
                                  color: ColorCustom.myGrey,
                                ),
                              ),
                              TextField(
                                  focusNode: _oldPasswordFocusNode,
                                  controller: _oldPassword,
                                  obscureText: _isObscure1,
                                  decoration: InputDecoration(
                                    hintText: 'Old Password',
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
                                    errorText: _erroOldPassword
                                        ? 'Password Is Incorrect!'
                                        : null,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _isObscure1
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: const Color.fromARGB(
                                            255, 200, 200, 200),
                                      ),
                                      onPressed: _togglePasswordVisibility1,
                                    ),
                                  ),
                                  onChanged: (text) {
                                    setState(() {
                                      _erroOldPassword = false;
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
                                "New password",
                                style: TextStyle(
                                  color: ColorCustom.myGrey,
                                ),
                              ),
                              TextField(
                                  controller: _password,
                                  focusNode: _passwordFocusNode,
                                  obscureText: _isObscure,
                                  decoration: InputDecoration(
                                    hintText: 'Enter new password',
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
                                      _errorNewPassword = false;
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
                                "Re-New Password",
                                style: TextStyle(
                                  color: ColorCustom.myGrey,
                                ),
                              ),
                              TextField(
                                  controller: _repassword,
                                  obscureText: _isObscure,
                                  focusNode: _repasswordFocusNode,
                                  decoration: InputDecoration(
                                    hintText: 'Enter re-new password',
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
                                    errorText: _errorNewPassword
                                        ? 'Password Not Match!'
                                        : null,
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
                                      _errorNewPassword = false;
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
                              changePassword();
                            },
                            child: Container(
                              alignment: Alignment.center,
                              width: 250,
                              height: 55,
                              child: const Text(
                                'CHANGE PASSWORD',
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
