import 'dart:ffi';

import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';
import 'package:firstapp/Screens/MainMenu.dart';
import 'package:firstapp/models/User.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../database/sqlite.dart';

class Profile extends StatefulWidget {
  final bool loginCheck;
  const Profile({super.key, required this.loginCheck});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  List<Map<String, dynamic>> userData = [];

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  void getUserData() async {
    var users = await DatabaseHelper.instance.users();
    setState(() {
      userData = users;
    });
  }

  Widget getProfileScreen() {
    return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              child: Padding(
                padding: EdgeInsets.only(top: 50, bottom: 50),
                child: Text(
                  userData[0]['name'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                    color: Colors.blue[800],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(40),
                        topLeft: Radius.circular(40)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        child: Text(
                          "Email",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      Container(
                        height: 10,
                      ),
                      Container(
                        child: Text(
                          userData[0]['email'],
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 10, bottom: 10, right: 30, left: 30),
                        child: Divider(thickness: 1.5),
                      ),
                      Container(
                        child: Text(
                          "Contact Number",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      Container(
                        height: 10,
                      ),
                      Container(
                        child: Text(
                          userData[0]['phone'],
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 10, bottom: 10, right: 30, left: 30),
                        child: Divider(thickness: 1.5),
                      ),
                      Container(
                        child: Text(
                          "Account Level",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      Container(
                        height: 10,
                      ),
                      Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            if (userData[0]['role'] == 1 ||
                                userData[0]['role'] == 4) ...[
                              Container(
                                child: Text(
                                  "Ticket Buyer",
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                              )
                            ] else if (userData[0]['role'] == 2 ||
                                userData[0]['role'] == 5) ...[
                              Container(
                                child: Text(
                                  "Event Creator",
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                              )
                            ] else if (userData[0]['role'] == 3) ...[
                              Container(
                                child: Text(
                                  "Event Sponsor",
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                              )
                            ]
                          ],
                        ),
                      ),
                    ],
                  )),
            )
          ],
        ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //drawer: NavBar(),
      appBar: AppBar(
        title: Text("Tick-It"),
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.blue[900],
          statusBarBrightness: Brightness.dark,
        ),
      ),
      body: Container(
        child: widget.loginCheck == true
            ? new Container(child: getProfileScreen())
            : new Container(
                width: double.maxFinite,
                color: Colors.grey[300],
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                        child: Icon(
                      Icons.person,
                      color: Colors.grey[600],
                      size: 40,
                    )),
                    Container(
                      child: Text(
                        'Sign in to view your profile',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey[600],
                        ),
                      ),
                    )
                  ],
                ),
              ),
      ),
    );
  }
}


