import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'LoginScreen.dart';
import 'package:http/http.dart';
import 'dart:convert';
import '../helper/constant.dart' as API;

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Signup(),
    );
  }
}

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _formKey = GlobalKey<FormState>();
  final username = TextEditingController();
  final email = TextEditingController();
  final contact = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  bool _passwordVisible = true;
  bool _confirmPasswordVisible = true;

  @override
  void initState() {
    _passwordVisible = false;
    _confirmPasswordVisible = false;
  }

  void register(String un, em, co, pa, cp) async {
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
                    'Registering',
                    style: TextStyle(fontSize: 20),
                  ),
                )
              ],
            );
          });

      if (_formKey.currentState!.validate()) {
        Response response =
            await post(Uri.parse('http://' + API.IP + '/api/register'), body: {
          'name': un,
          'email': em,
          'phoneNo': co,
          'password': pa,
          'mode': 'mob',
          'password_confirmation': cp,
        });
        if (response.statusCode == 200) {
          Navigator.of(context).pop();
          EasyLoading.showToast('Account Registered',
              toastPosition: EasyLoadingToastPosition.bottom);
          showDialog<String>(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
              title: Text(
                'Registred',
                textAlign: TextAlign.center,
              ),
              actions: <Widget>[
                Container(
                  child: Column(
                    children: [
                      Text(
                        'A link has been sent on your email. Varify your email to login',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Container(
                        alignment: Alignment.bottomCenter,
                        child: RoundedButton(
                          text: 'Confirm',
                          press: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginScreen()));
                          },
                          width: 100,
                          height: 40,
                          background_color: Colors.blue,
                          foreground_color: Colors.white,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        } else if (response.statusCode == 201) {
          Navigator.of(context).pop();
          EasyLoading.showToast('Email and Phone Already Exists',
              toastPosition: EasyLoadingToastPosition.bottom);
        } else if (response.statusCode == 202) {
          Navigator.of(context).pop();
          EasyLoading.showToast('Email Already Exists',
              toastPosition: EasyLoadingToastPosition.bottom);
        } else if (response.statusCode == 203) {
          Navigator.of(context).pop();
          EasyLoading.showToast('Phone Number Already Exists',
              toastPosition: EasyLoadingToastPosition.bottom);
        }
      } else {
        Navigator.of(context).pop();
        EasyLoading.showToast('Enter Correct Information',
            toastPosition: EasyLoadingToastPosition.bottom);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Form(
      key: _formKey,
      child: Container(
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset(
                "assets/images/logo.png",
                width: size.width * 0.4,
              ),
              Container(
                padding: EdgeInsets.only(left: 40, right: 40, bottom: 7),
                child: TextFormField(
                  controller: username,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.person),
                    isDense: true,
                    labelText: 'Username',
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
                  validator: (username) {
                    if (username == null || username.isEmpty) {
                      return 'Please enter a username';
                    }
                    return null;
                  },
                ),
              ),
              Container(
                padding:
                    EdgeInsets.only(left: 40, right: 40, top: 5, bottom: 7),
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
                    EdgeInsets.only(left: 40, right: 40, top: 5, bottom: 7),
                child: TextFormField(
                  controller: contact,
                  decoration: InputDecoration(
                    hintText: "xxxx-xxxxxxx",
                    prefixIcon: Icon(Icons.phone),
                    isDense: true,
                    labelText: 'Phone Number',
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
                  validator: (contact) {
                    final bool contactValid =
                        RegExp(r"^\d{4}(\s|-)\d{7}$").hasMatch(contact!);
                    if (contact == null || contact.isEmpty) {
                      return 'Please enter a phone number';
                    } else if (!contactValid) {
                      return 'Please enter a correct number';
                    }
                    return null;
                  },
                ),
              ),
              Container(
                padding:
                    EdgeInsets.only(left: 40, right: 40, top: 5, bottom: 7),
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
                      return 'Please enter atleast 8 characters';
                    }
                    return null;
                  },
                ),
              ),
              Container(
                padding:
                    EdgeInsets.only(left: 40, right: 40, top: 5, bottom: 7),
                child: TextFormField(
                  controller: confirmPassword,
                  obscureText: !_confirmPasswordVisible,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.password),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _confirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Theme.of(context).primaryColorDark,
                      ),
                      onPressed: () {
                        setState(() {
                          _confirmPasswordVisible = !_confirmPasswordVisible;
                        });
                      },
                    ),
                    isDense: true,
                    labelText: 'Confirm Password',
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
                  validator: (confirmPassword) {
                    if (confirmPassword == null || confirmPassword.isEmpty) {
                      return 'Please enter a password';
                    } else if (confirmPassword.length < 8) {
                      return 'Please enter atleast 8 characters';
                    } else if (confirmPassword != password.text) {
                      return 'Please enter same password';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(
                height: 50,
                width: 100,
                child: RoundedButton(
                  text: "Register",
                  press: () {
                    register(
                        username.text.toString(),
                        email.text.toString(),
                        contact.text.toString(),
                        password.text.toString(),
                        confirmPassword.text.toString());
                  },
                  width: size.width * 0.3,
                  height: size.width * 0.11,
                  background_color: Colors.blue,
                  foreground_color: Colors.white,
                ),
              ),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => LoginScreen()));
                  },
                  child: Text(
                    "Login",
                    style: TextStyle(color: Colors.blue, fontSize: 20),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
