import 'dart:io';

import 'package:final_project/database/User.dart';
import 'package:final_project/pages/LogIn.dart';
import 'package:final_project/pages/change_password.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:final_project/colors.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:image_picker/image_picker.dart';

class Profile extends StatefulWidget {
  Profile({Key? key}) : super(key: key);
  @override
  _ProfileWidgetState createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<Profile> {
  final user = FirebaseAuth.instance.currentUser;

  bool _isObscure = true;
  final TextEditingController _nameController = TextEditingController();

  String? userName;
  File? file;
  ImagePicker imagePicker = ImagePicker();
  var url;

  @override
  void initState() {
    super.initState();
    _nameController;
    fetchUserName();
    fetchImageUrl();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isObscure = !_isObscure;
    });
  }

  Future<void> fetchImageUrl() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final ref = FirebaseStorage.instance.ref().child("${user.email}.jpg");
        String downloadUrl = await ref.getDownloadURL();
        setState(() {
          url = downloadUrl;
        });
        print('Image fetched successfully: $downloadUrl');
      } on FirebaseException catch (e) {
        print("Error fetching image: ${e.message}");
      }
    }
  }

  void fetchUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DatabaseReference ref = FirebaseDatabase.instance.ref("users");
      final snapshot = await ref.get();
      if (snapshot.exists) {
        final data = snapshot.value;

        if (data is Map<dynamic, dynamic>) {
          for (var entry in data.entries) {
            if (entry.value != null && entry.value is Map<dynamic, dynamic>) {
              var userModel = UserModel.fromMap(entry.value);
              if (userModel.email == user.email) {
                setState(() {
                  userName = userModel.name;
                });
                break;
              }
            }
          }
        } else if (data is List<dynamic>) {
          for (var item in data) {
            if (item != null && item is Map<dynamic, dynamic>) {
              var userModel = UserModel.fromMap(item);
              if (userModel.email == user.email) {
                setState(() {
                  userName = userModel.name;
                });
                break;
              }
            }
          }
        } else {
          print('Unexpected data type: ${data.runtimeType}');
        }
      } else {
        print('No data available.');
      }
    } else {
      print('User is not logged in.');
    }
  }

  Future<void> getImage() async {
    try {
      var img = await imagePicker.pickImage(source: ImageSource.gallery);
      setState(() {
        file = File(img!.path);
      });
      uploadFile();
    } catch (e) {
      print(e);
    }
  }

  Future<void> uploadFile() async {
    if (file == null) return;

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('User is not logged in.');
        return;
      }
      var imagefile =
          FirebaseStorage.instance.ref().child("/${user.email}.jpg");
      UploadTask task = imagefile.putFile(file!);
      TaskSnapshot snapshot = await task;
      url = await snapshot.ref.getDownloadURL();
      setState(() {
        url = url;
      });
      Fluttertoast.showToast(
        msg: "Upload Avatar Successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      print('Upload successful. URL: $url');
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: <Widget>[
            // Background layer
            Container(
              width: double.infinity,
              height: 400,
              child: Stack(
                children: <Widget>[
                  Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/bg4.avif'),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color:
                          const Color.fromARGB(255, 9, 13, 72).withOpacity(0.1),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 75),
                    child: Column(
                      children: <Widget>[
                        GestureDetector(
                          onTap: getImage,
                          child: Center(
                            child: Container(
                              width: 120, // Chiều rộng cố định
                              height: 120, // Chiều cao cố định
                              decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(40)),
                              ),
                              child: ClipRRect(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(40)),
                                child: url == null
                                    ? Image.asset(
                                        'assets/images/avt.png',
                                        fit: BoxFit.cover,
                                      )
                                    : Image.network(
                                        url!,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            _showEditName(context, userName!);
                          },
                          child: Text(
                            "$userName",
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 20,
                              color: ColorCustom.myGrey,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Overlay layer
            Padding(
              padding: const EdgeInsets.only(top: 290),
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
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ChangePassword()),
                          );
                        },
                        child: Row(
                          children: [
                            // Outer square with blue background and border radius

                            Container(
                              width: 50, // Adjust the width as needed
                              height: 50, // Adjust the height as needed
                              decoration: BoxDecoration(
                                color: Colors.blue, // Blue background
                                borderRadius:
                                    BorderRadius.circular(20), // Border radius
                              ),
                              child: Center(
                                child: // Inner square with white background
                                    Container(
                                  width: 28, // Adjust the width as needed
                                  height: 28, // Adjust the height as needed
                                  decoration: BoxDecoration(
                                    color: Colors.white, // White background
                                    borderRadius: BorderRadius.circular(
                                        0), // Border radius
                                  ),
                                ),
                              ),
                            ),

                            // Text
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 20), // Adjust the padding as needed
                              child: Container(
                                width: 150,
                                child: Text(
                                  maxLines: 2,
                                  'Change Your Password',
                                  style: TextStyle(
                                    fontSize:
                                        18, // Adjust the font size as needed
                                    fontFamily: 'Nunito',
                                    color: Colors
                                        .black, // Adjust the text color as needed
                                  ),
                                ),
                              ),
                            ),
                            Spacer(),
                            // Arrow Icon
                            Padding(
                              padding: EdgeInsets.all(0),
                              // padding: const EdgeInsets.only(left: 50.0),
                              child: Container(
                                width: 50, // Adjust the width as needed
                                height: 50, // Adjust the height as needed
                                decoration: BoxDecoration(
                                  color:
                                      ColorCustom.squareGrey, // Blue background
                                  borderRadius: BorderRadius.circular(
                                      20), // Border radius
                                ),
                                child: Center(
                                  child: // Inner square with white background
                                      Container(
                                    width: 28, // Adjust the width as needed
                                    height: 28, // Adjust the height as needed
                                    decoration: BoxDecoration(
                                      color: Colors.white, // White background
                                      borderRadius: BorderRadius.circular(
                                          0), // Border radius
                                    ),
                                    child: Icon(
                                      Icons.key, // Arrow icon
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => LogIn()),
                            (Route<dynamic> route) =>
                                false, // This never allows any route to be kept.
                          );
                        },
                        child: Row(
                          children: [
                            // Outer square with blue background and border radius

                            Container(
                              width: 50, // Adjust the width as needed
                              height: 50, // Adjust the height as needed
                              decoration: BoxDecoration(
                                color: ColorCustom.squarePur, // Blue background
                                borderRadius:
                                    BorderRadius.circular(20), // Border radius
                              ),
                              child: Center(
                                child: // Inner square with white background
                                    Container(
                                  width: 28, // Adjust the width as needed
                                  height: 28, // Adjust the height as needed
                                  decoration: BoxDecoration(
                                    color: Colors.white, // White background
                                    borderRadius: BorderRadius.circular(
                                        0), // Border radius
                                  ),
                                ),
                              ),
                            ),

                            // Text
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 20), // Adjust the padding as needed
                              child: Text(
                                'Sign Out',
                                style: TextStyle(
                                  fontSize:
                                      18, // Adjust the font size as needed
                                  fontFamily: 'Nunito',
                                  color: Colors
                                      .black, // Adjust the text color as needed
                                ),
                              ),
                            ),
                            // Arrow Icon
                            Spacer(),
                            Padding(
                              padding: const EdgeInsets.only(left: 0.0),
                              child: Container(
                                width: 50, // Adjust the width as needed
                                height: 50, // Adjust the height as needed
                                decoration: BoxDecoration(
                                  color:
                                      ColorCustom.squareGrey, // Blue background
                                  borderRadius: BorderRadius.circular(
                                      20), // Border radius
                                ),
                                child: Center(
                                  child: // Inner square with white background
                                      Container(
                                    width: 28, // Adjust the width as needed
                                    height: 28, // Adjust the height as needed
                                    decoration: BoxDecoration(
                                      color: Colors.white, // White background
                                      borderRadius: BorderRadius.circular(
                                          0), // Border radius
                                    ),
                                    child: Icon(
                                      Icons.logout, // Arrow icon
                                      color: Colors.black,
                                    ),
                                  ),
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
    );
  }

  void _showEditName(BuildContext context, String userName) {
    TextEditingController _nameCategoryController =
        TextEditingController(text: userName);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Name'),
          content: Container(
            height: 150,
            child: Column(
              children: [
                SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Name',
                      style: TextStyle(fontSize: 20, fontFamily: 'Nunito'),
                    ),
                  ],
                ),
                TextField(
                  controller: _nameCategoryController,
                  decoration: InputDecoration(hintText: 'Enter new name'),
                ),
                SizedBox(
                  height: 15,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                foregroundColor: Colors.black,
                backgroundColor: const Color.fromARGB(255, 205, 205, 205),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                foregroundColor: Colors.white,
                backgroundColor: Colors.green,
              ),
              onPressed: () async {
                ///logic here
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  DatabaseReference dref =
                      FirebaseDatabase.instance.ref("users");
                  final snapshot = await dref.get();
                  if (snapshot.exists) {
                    final data = snapshot.value as Map<dynamic, dynamic>;

                    for (var key in data.keys) {
                      var item = data[key];
                      if (item != null && item is Map<dynamic, dynamic>) {
                        if (item['email'] == user.email) {
                          String newName = _nameCategoryController.text;

                          await dref.child(key).update({'name': newName});
                          setState(() {
                            userName = newName;
                            print(userName);
                            fetchUserName();
                          });
                          break;
                        }
                      }
                    }
                  } else {
                    print('No data available.');
                  }
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
