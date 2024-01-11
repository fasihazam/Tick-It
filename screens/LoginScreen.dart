import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import '../models/User.dart';
import 'MainMenu.dart';
import 'SignupScreen.dart';
import 'package:http/http.dart' as http;
import '../database/sqlite.dart';
import 'package:audioplayers/audioplayers.dart';
import '../helper/constant.dart' as API;

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Body(),
    );
  }
}

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final email = TextEditingController();
  final password = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _passwordVisible = true;

  void login(String e, p) async {
    FocusScope.of(context).unfocus();
    try {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  child: CircularProgressIndicator(
                    color: Colors.black,
                  ),
                ),
                Container(
                  child: SizedBox(height: 10),
                ),
                Container(
                  child: Text(
                    'Signing In',
                    style: TextStyle(fontSize: 20),
                  ),
                )
              ],
            );
          });
      Response response = await post(Uri.parse('http://' + API.IP + '/api/Login'),
          body: {'email': e, 'password': p});

      if (_formKey.currentState!.validate() && response.statusCode == 201) {
        var jsonResponse = jsonDecode(response.body);
        var jsonUser = jsonResponse['user'];

        var userData = User(
          id: jsonUser['id'],
          role: jsonUser['role'],
          name: jsonUser['name'],
          email: jsonUser['email'],
          address: jsonUser['address'],
          phone: jsonUser['phoneNo'],
          token: jsonResponse['token'],
        );

        await DatabaseHelper.instance.insertUser(userData);

        Navigator.of(context).pop();
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MainMenu(
                      loginCheck: true,
                    )));
      } else if (response.statusCode == 202) {
        Navigator.of(context).pop();
        EasyLoading.showToast('Varify email to login',
            toastPosition: EasyLoadingToastPosition.bottom);
      } else if (_formKey.currentState!.validate()) {
        Navigator.of(context).pop();
        var data = jsonDecode(response.body.toString());
        /*ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(response.body)));*/

        EasyLoading.showToast('Email or Password Incorrect',
            toastPosition: EasyLoadingToastPosition.bottom);
      } else {
        Navigator.of(context).pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
      ));
    }
  }

  @override
  void initState() {
    _passwordVisible = false;
    getUserData();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return new WillPopScope(
      onWillPop: () async => exit(0),
      child: Form(
        key: _formKey,
        child: Container(
          alignment: Alignment.center,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 10, 80),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: RoundedButton(
                      text: 'SKIP',
                      press: () async {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => MainMenu(
                              loginCheck: false,
                            ),
                          ),
                        );
                      },
                      width: 110,
                      height: 40,
                      background_color: Colors.grey.shade100,
                      foreground_color: Colors.black,
                    ),
                  ),
                ),
                Image.asset(
                  'assets/images/logo.png',
                  width: size.width * 0.5,
                ),
                Container(
                  padding:
                      EdgeInsets.only(left: 40, right: 40, top: 7, bottom: 7),
                  child: TextFormField(
                    controller: email,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.email),
                      isDense: true,
                      labelText: 'Email',
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40),
                          borderSide: BorderSide(color: Colors.blue)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40),
                          borderSide: BorderSide(color: Colors.blue)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40),
                          borderSide: BorderSide(color: Colors.blue)),
                      errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40),
                          borderSide: BorderSide(color: Colors.red)),
                    ),
                    style: TextStyle(
                      fontSize: 18,
                    ),
                    validator: (email) {
                      final bool emailValid = RegExp(
                              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                          .hasMatch(email!);
                      if (email == null || email.isEmpty) {
                        return 'Please enter an email';
                      } else if (!emailValid) {
                        return 'Please enter correct email';
                      }
                      return null;
                    },
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.only(left: 40, right: 40, top: 15, bottom: 7),
                  child: TextFormField(
                    controller: password,
                    obscureText: !_passwordVisible,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.password),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Theme.of(context).primaryColorDark,
                        ),
                        onPressed: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
                      isDense: true,
                      labelText: 'Password',
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40),
                          borderSide: BorderSide(color: Colors.blue)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40),
                          borderSide: BorderSide(color: Colors.blue)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40),
                          borderSide: BorderSide(color: Colors.blue)),
                      errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40),
                          borderSide: BorderSide(color: Colors.red)),
                    ),
                    style: TextStyle(
                      fontSize: 18,
                    ),
                    validator: (password) {
                      if (password == null || password.isEmpty) {
                        return 'Please enter correct password';
                      } else if (password.length < 8) {
                      } else if (password.length < 8) {
                        return 'Atleast 8 characters required';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                RoundedButton(
                  press: () {
                    login(email.text.toString(), password.text.toString());
                  },
                  text: "LOGIN",
                  width: size.width * 0.3,
                  height: size.width * 0.11,
                  background_color: Colors.blue,
                  foreground_color: Colors.white,
                ),
                SizedBox(
                  width: 5,
                  height: 2,
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => SignUpScreen()));
                  },
                  child: Text(
                    "Register",
                    style: TextStyle(color: Colors.blue, fontSize: 20),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> userData = [];

  void getUserData() async {
    var users = await DatabaseHelper.instance.users();
    setState(() {
      userData = users;
    });
  }
}

class RoundedButton extends StatelessWidget {
  final double width;
  final double height;
  final String text;
  final Color background_color;
  final Color foreground_color;
  final Function press;
  const RoundedButton({
    super.key,
    required this.text,
    required this.press,
    required this.width,
    required this.height,
    required this.background_color,
    required this.foreground_color,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: TextButton(
          onPressed: () {
            press();
          },
          child: Text(
            text,
            style: TextStyle(
              fontSize: 17,
            ),
          ),
          style: TextButton.styleFrom(
              foregroundColor: foreground_color,
              backgroundColor: background_color,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 2),
        ),
      ),
    );
  }
}
