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
import '../models/EventCardModel.dart';
import '../models/User.dart';
import '../screens/LoginScreen.dart';
import 'package:flutter/material.dart';
import '../screens/TicketView.dart';
import '../helper/constant.dart' as API;

class TicketCard extends StatefulWidget {
  const TicketCard(
      {super.key, required this.ticketCardData, required this.press});
  final EventCardModel ticketCardData;
  final GestureTapCallback press;
  @override
  State<TicketCard> createState() => _TicketCardState();
}

class _TicketCardState extends State<TicketCard> {
  List<Map<String, dynamic>> userData = [];
  List<String> imagesList = [];

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
                              widget.ticketCardData.event_title,
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
                                  widget.ticketCardData.start_date)),
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
                              "By: " + widget.ticketCardData.organizer,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                              margin: EdgeInsets.only(right: 10),
                              child: widget.ticketCardData.event_type == 1
                                  ? Text(
                                      "Physical",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : Container(
                                      child:
                                          widget.ticketCardData.event_type == 2
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
                              text: 'View',
                              press: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => TicketView(
                                          eventID: widget.ticketCardData.id,
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
                              text: 'Sponsor',
                              press: () {
                                setState(() {
                                  getUserData();
                                });
                                showDialog<String>(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext context) =>
                                        AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(8.0)),
                                          ),
                                          title: userData.length == 0
                                              ? Text(
                                                  "Please Sign In",
                                                  textAlign: TextAlign.center,
                                                )
                                              : userData[0]['role'] == 1
                                                  ? Text(
                                                      "Add an image of your ID card front and back, \n Also add an image of your business card",
                                                      textAlign:
                                                          TextAlign.center,
                                                    )
                                                  : userData[0]['role'] == 2 ||
                                                          userData[0]['role'] ==
                                                              4
                                                      ? Text(
                                                          "Add an image of your business card",
                                                          textAlign:
                                                              TextAlign.center,
                                                        )
                                                      : userData[0]['role'] ==
                                                                  0 ||
                                                              userData[0][
                                                                      'role'] ==
                                                                  3
                                                          ? Container(
                                                              child: Column(
                                                                children: [
                                                                  Container(
                                                                      child:
                                                                          Text(
                                                                    "Visit our website to sponsor",
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                  )),
                                                                  RichText(
                                                                    text:
                                                                        TextSpan(
                                                                      text:
                                                                          "Tick-It",
                                                                      style: new TextStyle(
                                                                          fontSize:
                                                                              20,
                                                                          color:
                                                                              Colors.blue),
                                                                      recognizer:
                                                                          new TapGestureRecognizer()
                                                                            ..onTap =
                                                                                () {
                                                                              launch("http://" + API.IP + "/");
                                                                            },
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            )
                                                          : userData[0][
                                                                      'role'] ==
                                                                  5
                                                              ? Text(
                                                                  "Please give us some time to approve your request",
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                )
                                                              : null,
                                          actions: [
                                            userData.length == 0
                                                ? Container(
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
                                                : userData[0]['role'] == 1 ||
                                                        userData[0]['role'] ==
                                                            2 ||
                                                        userData[0]['role'] == 4
                                                    ? Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceAround,
                                                        children: [
                                                          Container(
                                                            alignment: Alignment
                                                                .bottomCenter,
                                                            child:
                                                                RoundedButton(
                                                              text: 'Upgrade',
                                                              press: () async {
                                                                imagesList
                                                                    .clear();
                                                                await _showPickImageDialog();
                                                                Navigator.pop(
                                                                    context);
                                                                submitRequst();
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
                                                            alignment: Alignment
                                                                .bottomCenter,
                                                            child:
                                                                RoundedButton(
                                                              text: 'Close',
                                                              press: () {
                                                                Navigator.pop(
                                                                    context);
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
                                                    : Container(
                                                        alignment: Alignment
                                                            .bottomCenter,
                                                        child: RoundedButton(
                                                          text: 'Close',
                                                          press: () {
                                                            Navigator.pop(
                                                                context);
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

  Future<void> _showPickImageDialog() async {
    final picker = ImagePicker();
    final List<XFile> pickedFile = await picker.pickMultiImage(
      imageQuality: 50,
    );
    if (pickedFile != null) {
      setState(() {
        for (var i = 0; i < pickedFile.length; i++) {
          imagesList
              .add(base64Encode(File(pickedFile[i].path).readAsBytesSync()));
        }
      });
    }
    //Navigator.pop(context);
  }

  submitRequst() {
    showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
              title: Text(
                "Submit Request",
                textAlign: TextAlign.center,
              ),
              actions: [
                Container(
                  alignment: Alignment.bottomCenter,
                  child: RoundedButton(
                    text: 'Submit',
                    press: () {
                      Navigator.pop(context);
                      upgradeAPI();
                      setState(() {
                        getUserData();
                      });
                    },
                    width: 100,
                    height: 40,
                    background_color: Colors.blue,
                    foreground_color: Colors.white,
                  ),
                ),
              ],
            ));
  }

  upgradeAPI() async {
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
                  'Submitting Request',
                  style: TextStyle(fontSize: 20),
                ),
              )
            ],
          );
        });
    try {
      Response response = await post(
        Uri.parse('http://' + API.IP + '/api/updatetoes'),
        headers: {
          'Authorization': "Bearer " + userData[0]['token'],
        },
        body: {
          'documents[]': imagesList.toString(),
          'type': "brand",
          'r_type': "es",
        },
      );
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        EasyLoading.showToast('Upgrade Requested',
            toastPosition: EasyLoadingToastPosition.bottom);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
      ));
    }
    Navigator.pop(context);
  }
}
