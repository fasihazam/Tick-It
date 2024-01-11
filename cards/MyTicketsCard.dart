import 'dart:convert';
import 'dart:io';

import 'package:firstapp/screens/MainMenu.dart';
import 'package:firstapp/tabs/MyTickets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../database/sqlite.dart';
import '../models/MyTicketCardModel.dart';
import '../screens/LoginScreen.dart';
import '../screens/MyTicketDisplay.dart';
import 'package:flutter/material.dart';
import '../screens/TicketView.dart';
import '../helper/constant.dart' as API;

class MyTicketCard extends StatefulWidget {
  const MyTicketCard(
      {super.key, required this.MyticketCardData, required this.press});
  final MyTicketCardModel MyticketCardData;
  final GestureTapCallback press;
  @override
  State<MyTicketCard> createState() => _MyTicketCardState();
}

class _MyTicketCardState extends State<MyTicketCard> {
  List<Map<String, dynamic>> userData = [];
  bool logincheck = true;

  @override
  void initState() {
    super.initState();
    if (userData.length == 0) {
      logincheck = false;
    }
    getUserData();
  }

  void getUserData() async {
    var users = await DatabaseHelper.instance.users();
    setState(() {
      userData = users;
    });
  }

  Future<void> refundAPI() async {
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
                  'Request refund',
                  style: TextStyle(fontSize: 20),
                ),
              )
            ],
          );
        });
    try {
      Response response =
          await post(Uri.parse('http://' + API.IP + '/api/Refund'), headers: {
        'Authorization': "Bearer " + userData[0]['token'],
      }, body: {
        'tid': widget.MyticketCardData.ticketid.toString(),
      });
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        EasyLoading.showToast('Refund successful',
            toastPosition: EasyLoadingToastPosition.bottom);
      } else {
        EasyLoading.showToast('Can not refund under 24H',
            toastPosition: EasyLoadingToastPosition.bottom);
      }
    } catch (e) {
      EasyLoading.showToast('Error: ' + e.toString(),
          toastPosition: EasyLoadingToastPosition.bottom);
    }
    Navigator.pop(context);
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
            height: 180,
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
                              widget.MyticketCardData.event_title,
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
                              DateFormat('dd-MM-yyyy').format(
                                  DateTime.parse(widget.MyticketCardData.date)),
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
                              "VIP: " + widget.MyticketCardData.vip,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                              margin: EdgeInsets.only(right: 10),
                              child: int.parse(
                                          widget.MyticketCardData.event_type) ==
                                      1
                                  ? Text(
                                      "Physical",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : Container(
                                      child: int.parse(widget.MyticketCardData
                                                  .event_type) ==
                                              2
                                          ? Text(
                                              "Online",
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )
                                          : Text(
                                              "Hybrid",
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                    )),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.only(left: 30),
                            alignment: Alignment.bottomLeft,
                            child: RoundedButton(
                              text: 'Ticket',
                              press: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => MyTicketDisplay(
                                          ticketID:
                                              widget.MyticketCardData.ticketid,
                                          dayID: widget.MyticketCardData.dayid,
                                        )));
                              },
                              width: 100,
                              height: 35,
                              background_color: Colors.blue,
                              foreground_color: Colors.white,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(right: 30),
                            alignment: Alignment.center,
                            child: RoundedButton(
                              text: 'Refund',
                              press: () {
                                showDialog<String>(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext context) =>
                                        AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(8.0)),
                                          ),
                                          title: Text(
                                            "Are you sure you want to refund this ticket?",
                                            textAlign: TextAlign.center,
                                          ),
                                          actions: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                Container(
                                                  alignment:
                                                      Alignment.bottomCenter,
                                                  child: RoundedButton(
                                                    text: 'Confirm',
                                                    press: () async {
                                                      Navigator.pop(context);
                                                      refundAPI();
                                                    },
                                                    width: 100,
                                                    height: 40,
                                                    background_color:
                                                        Colors.blue,
                                                    foreground_color:
                                                        Colors.white,
                                                  ),
                                                ),
                                                Container(
                                                  alignment:
                                                      Alignment.bottomCenter,
                                                  child: RoundedButton(
                                                    text: 'Close',
                                                    press: () {
                                                      Navigator.pop(context);
                                                    },
                                                    width: 100,
                                                    height: 40,
                                                    background_color:
                                                        Colors.blue,
                                                    foreground_color:
                                                        Colors.white,
                                                  ),
                                                )
                                              ],
                                            )
                                          ],
                                        ));
                              },
                              width: 100,
                              height: 35,
                              background_color: Colors.blue,
                              foreground_color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  )),
            ),
          ),
        ),
      ),
    );
  }
}
