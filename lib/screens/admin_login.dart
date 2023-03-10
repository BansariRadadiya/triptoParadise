import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:home_page/dashboard_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:home_page/config/global.dart' as globals;
import '../config/user.dart';
import '../widget/loading_dialog.dart';

class AdminLogin extends StatefulWidget {
  const AdminLogin({Key? key}) : super(key: key);

  @override
  State<AdminLogin> createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  bool state = true;
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void signIn() async {
    try {
      if (_emailController.text.toString().trim() == "admin@gmail.com" &&
          _passController.text.toString().trim() == "admin@123") {
        globals.isAdmin = true;
        print('===============================${globals.isAdmin}');
      } else {
        globals.isAdmin = false;
        print('===============================${globals.isAdmin}');
      }

      LoadingDialog.showLoadingDialog();
      UserCredential userCred = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passController.text,
      );
      if (userCred.user != null) {
        final data = await FirebaseFirestore.instance
            .collection("users")
            .doc(userCred.user!.uid)
            .get();
        if (data.data() != null && data.exists) {
          final res = data.data();
          UserProfile.userName = res!['userName'];
          UserProfile.id = res['id'];
          //UserProfile.name = res['name'];
          UserProfile.profile = res['profile'];
          UserProfile.email=res['email'];
          SharedPreferences _pref = await SharedPreferences.getInstance();
          // _pref.setString("name", res['name']);
          _pref.setString("id", res['id']);
          _pref.setString("userName", res['userName']);
          _pref.setString("profile", res['profile']);
          _pref.setString("email", res['email']);
          LoadingDialog.hideLoading();
          LoadingDialog.showSuccessToast("Login Successfully");
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => DashboardScreen()));
        }
      }
    } on FirebaseAuthException catch (e) {
      print(e);
      if (e.code == 'user-not-found') {
        print('Account Already Exists.');
        LoadingDialog.hideLoading();
        LoadingDialog.showErrorToast("User Not Found");
        // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        //   backgroundColor: Colors.red[500],
        //   content: Text('User Not Found'),
        //));
      } else if (e.code == 'wrong-password') {
        print('Account Already Exists.');
        LoadingDialog.hideLoading();
        LoadingDialog.showErrorToast("Wrong Password");
        // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        //   backgroundColor: Colors.red[500],
        //   content: Text('Wrong Password'),
        // ));
      }
    }
  }

  // Future signIn() async {
  //   showDialog(
  //       context: context,
  //       barrierDismissible: true,
  //       builder: (context) => Center(
  //         child: CircularProgressIndicator(),
  //       ));
  //   try {
  //     await FirebaseAuth.instance.signInWithEmailAndPassword(
  //         email: _emailController.text.trim(),
  //         password: _passController.text.trim());
  //   } on FirebaseAuthException catch (e) {
  //     print(e);
  //     if (e.code == 'user-not-found') {
  //       print('Account Already Exists.');
  //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //         backgroundColor: Colors.red[500],
  //         content: Text('User Not Found'),
  //       ));
  //     } else if (e.code == 'wrong-password') {
  //       print('Account Already Exists.');
  //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //         backgroundColor: Colors.red[500],
  //         content: Text('Wrong Password'),
  //       ));
  //     }
  //     // Utils.showSnackBar(e.message);
  //   }
  //   Navigator.of(context).push(MaterialPageRoute(builder:(context)=>DashboardScreen()));
  //   //navigatorKey.currentState!.popUntil((route) => route.isFirst);
  // }
  bool _obscureText = true;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            // SizedBox(
            //   height: double.infinity,
            //   width: double.infinity,
            //   child: Image.asset(
            //     "assets/background_all.png",
            //     fit: BoxFit.fill,
            //   ),
            // ),
            SingleChildScrollView(
              child: Form(
                key: _key,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        left: 20,
                        top: 20,
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Icon(Icons.arrow_back_ios,
                            color: Color(0xE80A0A0A)),
                      ),
                    ),
                    Center(
                      child: Container(
                        height: 300,
                        width: 300,
                        child: Lottie.asset("assets/roatating_planet.json",
                            fit: BoxFit.fill),
                      ),
                    ),
                    Center(
                      child: Text(
                        "Admin Login",
                        style: TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 30,
                        left: 10,
                        right: 10,
                      ),
                      child: TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Enter Email';
                          } else if (!value.contains(".com") &&
                              !value.contains("@gmail")) {
                            return 'Please enter valid email';
                          }
                          return null;
                        },
                        controller: _emailController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.email_outlined),
                          fillColor: Color.fromRGBO(0, 0, 0, 490),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(40),
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 15),
                          hintText: "Email",
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 10,
                        left: 10,
                        right: 10,
                      ),
                      child: TextFormField(
                        obscureText: _obscureText,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter password';
                          }
                          return null;
                        },
                        controller: _passController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.key),
                          fillColor: Color.fromRGBO(0, 0, 0, 490),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(40),
                            ),
                          ),
                          contentPadding:
                          const EdgeInsets.symmetric(horizontal: 15),
                          hintText: "Password",
                          suffixIcon:  GestureDetector(
                            onTap: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                            child:  Icon(_obscureText
                                ? Icons.visibility_off
                                : Icons.visibility),
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        if (_key.currentState!.validate()) {
                          if (_emailController.text.toString().trim() ==
                              "admin@gmail.com" &&
                              _passController.text.toString().trim() ==
                                  "admin@123") {
                            signIn();
                          } else {
                            LoadingDialog.hideLoading();
                            LoadingDialog.showErrorToast(
                                "Please check Email-Password");
                            Navigator.of(context).push(MaterialPageRoute(builder: (context)=>AdminLogin()));
                          }
                        }
                      },
                      child: Container(
                        height: 50,
                        margin: const EdgeInsets.only(
                          left: 10,
                          right: 10,
                          top: 20,
                        ),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(40),
                          border: Border.all(width: 1.2),
                          color: Color(0x881CD7DB),
                        ),
                        child: const Text(
                          "Sign in",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
