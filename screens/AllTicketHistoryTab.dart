import 'dart:convert';

import 'package:firstapp/Screens/MainMenu.dart';
import 'package:firstapp/models/EventCardModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart';
import '../database/sqlite.dart';
import '../models/MyHistoryTicketCardModel.dart';
import 'MyTicketDisplay.dart';
import '../cards/MyTicketsCard.dart';
import '../cards/MyTicketsHistoryCard.dart';
import '../cards/TicketCard.dart';
import 'TicketView.dart';
import '../helper/constant.dart' as API;

class AllTicketsHistory extends StatefulWidget {
  AllTicketsHistory({super.key, required this.loginCheck});
  bool loginCheck;
  @override
  State<AllTicketsHistory> createState() => _AllTicketsHistoryState();
}

class _AllTicketsHistoryState extends State<AllTicketsHistory> {
  List<Map<String, dynamic>> userData = [];
  List<MyHistoryTicketCardModel> myTicketCard = [];
  List<MyHistoryTicketCardModel> foundTicket = [];
  late bool loader;

  @override
  void initState() {
    super.initState();
    loader = false;
    if (widget.loginCheck == true) {
      getUserData();
    }
  }

  void getUserData() async {
    var users = await DatabaseHelper.instance.users();
    setState(() {
      userData = users;
      getMyTicketData();
    });
  }

  Future<void> getMyTicketData() async {
    try {
      Response response = await post(
        Uri.parse('http://' + API.IP + '/api/getmyticketshistory'),
        headers: {
          'Authorization': "Bearer " + userData[0]['token'],
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as List<dynamic>;
        final myticketCardData = jsonData
            .map((json) => MyHistoryTicketCardModel.fromJson(json))
            .toList();
        setState(() {
          myTicketCard = myticketCardData;
          foundTicket = myTicketCard;
          loader = true;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
      ));
    }
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
        body: widget.loginCheck == false
            ? new Container(
                width: double.maxFinite,
                color: Colors.grey[300],
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                        child: Icon(
                      Icons.history,
                      color: Colors.grey[600],
                      size: 40,
                    )),
                    Container(
                      child: Text(
                        'Sign in to view your ticket history',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey[600],
                        ),
                      ),
                    )
                  ],
                ),
              )
            : Container(
                child: SingleChildScrollView(
                    child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    child: SafeArea(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(
                                      left: 18, right: 18, top: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                Container(
                                  child: loader == false
                                      ? Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.8,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                child:
                                                    CircularProgressIndicator(
                                                  color: Colors.black,
                                                ),
                                              ),
                                              Container(
                                                child: SizedBox(height: 10),
                                              ),
                                              Container(
                                                child: Text(
                                                  'Loading Tickets',
                                                  style:
                                                      TextStyle(fontSize: 20),
                                                ),
                                              )
                                            ],
                                          ),
                                        )
                                      : foundTicket.length == 0
                                          ? Container(
                                              padding: EdgeInsets.all(100),
                                              child: Text('No Ticket Found',
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    color: Colors.grey[600],
                                                  )),
                                            )
                                          : Column(
                                              children: [
                                                ...List.generate(
                                                  foundTicket.length,
                                                  (index) => TicketHistoryCard(
                                                      ticketHistoryCardData:
                                                          foundTicket[index],
                                                      press: () {}),
                                                ),
                                              ],
                                            ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ))));
  }
}
