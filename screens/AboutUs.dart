import 'dart:ffi';

import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';
import 'package:firstapp/Screens/MainMenu.dart';
import 'package:firstapp/models/User.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../database/sqlite.dart';

class AboutUs extends StatelessWidget {
  const AboutUs({super.key});

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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              child: Padding(
                padding: EdgeInsets.only(top: 50, bottom: 50),
                child: Text(
                  "TICK-IT",
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
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        height: 20,
                      ),
                      Container(
                        child: Text(
                          "Creators",
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
                          "Abdullah Amjad",
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ),
                      Container(
                        height: 5,
                      ),
                      Container(
                        child: Text(
                          "Haris Bin Khalid",
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ),
                      Container(
                        height: 5,
                      ),
                      Container(
                        child: Text(
                          "Ibrahim Ahmed",
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
                          "About Us",
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
                        padding: EdgeInsets.only(right: 20,  left: 20),
                        child: Text(
                          "We are a group of three students creating an application for our Final Year Project.",
                          style: TextStyle(
                            fontSize: 20,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Container(
                        height: 5,
                      ),
                      Container(
                        padding: EdgeInsets.only(right: 20,  left: 20),
                        child: Text(
                          "Our motivation was to provide a simple, easy and free access to anyone for creating and managing events.",
                          style: TextStyle(
                            fontSize: 20,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Container(
                        height: 5,
                      ),
                      Container(
                        padding: EdgeInsets.only(right: 20,  left: 20),
                        child: Text(
                          "So we provided a solution that allows the user to buy tickets, create events and also sponsor events within one system.",
                          style: TextStyle(
                            fontSize: 20,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 10, bottom: 10, right: 30, left: 30),
                        child: Divider(thickness: 1.5),
                      ),
                      Container(
                        child: Text(
                          "Contact Us",
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
                          "tick_it@gmail.com",
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ],
                  )),
            )
          ],
        ),
      ),
    );
  }
}
