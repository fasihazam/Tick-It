import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../database/sqlite.dart';
import '../models/MyHistoryTicketCardModel.dart';
import '../screens/LoginScreen.dart';
import '../screens/MyTicketDisplay.dart';
import 'package:flutter/material.dart';
import '../screens/TicketView.dart';

class TicketHistoryCard extends StatefulWidget {
  const TicketHistoryCard(
      {super.key, required this.ticketHistoryCardData, required this.press});
  final MyHistoryTicketCardModel ticketHistoryCardData;
  final GestureTapCallback press;
  
  @override
  State<TicketHistoryCard> createState() => _TicketHistoryCardState();
}

class _TicketHistoryCardState extends State<TicketHistoryCard> {
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

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: GestureDetector(
        onTap: widget.press,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: SizedBox(
            width: double.infinity,
            height: 100,
            child: Card(
              shadowColor: Colors.blue,
              elevation: 9,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9.0),
              ),
              child: Container(
                  padding: EdgeInsets.all(7),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            margin: new EdgeInsets.symmetric(
                                horizontal: 20, vertical: 1),
                            child: Text(
                              widget.ticketHistoryCardData.event_title,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(right: 10),
                            child: Text(
                              DateFormat('dd-MM-yyyy').format(DateTime.parse(
                                  widget.ticketHistoryCardData.date)),
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            margin: new EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              widget.ticketHistoryCardData.organizer,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                          margin: EdgeInsets.only(right: 10),
                          child: Text( "Price: Rs." +
                          widget.ticketHistoryCardData.price.toString(),
                          style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                          )
                              ),
                        ],
                      ),
                      
                    ],
                  )
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
