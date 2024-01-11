import 'dart:convert';

import 'package:firstapp/models/EventCardModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart';
import '../database/sqlite.dart';
import '../models/MyTicketCardModel.dart';
import '../models/User.dart';
import '../screens/MyTicketDisplay.dart';
import '../cards/MyTicketsCard.dart';
import '../cards/TicketCard.dart';
import '../screens/TicketView.dart';
import '../helper/constant.dart' as API;

class MyTickets extends StatefulWidget {
  const MyTickets({super.key});

  @override
  State<MyTickets> createState() => _MyTicketsState();
}

class _MyTicketsState extends State<MyTickets> {
  List<Map<String, dynamic>> userData = [];
  List<MyTicketCardModel> myTicketCard = [];
  List<MyTicketCardModel> foundTicket = [];
  late bool loader;

  @override
  void initState() {
    super.initState();
    getUserData();
    userRoleAPI();
    loader = false;
  }

  userRoleAPI() async {
    Response response = await get(
      Uri.parse('http://' + API.IP + '/api/getrole'),
      headers: {
        'Authorization': "Bearer " + userData[0]['token'],
      },
    );

    var userDataUpdate = User(
      id: userData[0]['id'],
      role: int.parse(response.body),
      name: userData[0]['name'],
      email: userData[0]['email'],
      address: userData[0]['address'],
      phone: userData[0]['phone'],
      token: userData[0]['token'],
    );

    await DatabaseHelper.instance.updateUser(userDataUpdate);
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
        Uri.parse('http://' + API.IP + '/api/getmytickets'),
        headers: {
          'Authorization': "Bearer " + userData[0]['token'],
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as List<dynamic>;
        final myticketCardData =
            jsonData.map((json) => MyTicketCardModel.fromJson(json)).toList();
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
    return Column(
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
                        margin: EdgeInsets.only(left: 18, right: 18, top: 20),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: TextField(
                          onChanged: (value) => runFilter(value),
                          decoration: InputDecoration(
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            hintText: "Search Tickets",
                            prefixIcon: Icon(Icons.search),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        child:  loader == false
                            ? Container(
                              height: MediaQuery.of(context).size.height * 0.5,
                              child: Column(
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
                                      'Loading Tickets',
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  )
                                ],
                              ),
                            )
                            : foundTicket.length == 0
                            ? Container(
                                padding: EdgeInsets.only(top: 20),
                                child: Text('No ticket found',
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.grey[600],
                                    )),
                              )
                            : Column(
                                children: [
                                  ...List.generate(
                                    foundTicket.length,
                                    (index) => MyTicketCard(
                                        MyticketCardData: foundTicket[index],
                                        press: () {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      MyTicketDisplay(
                                                        ticketID: foundTicket[index].ticketid,
                                          dayID: foundTicket[index].dayid,
                                                      )));
                                        }),
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
    );
  }

  void runFilter(String enteredKeyword) {
    List<MyTicketCardModel> results = [];
    if (enteredKeyword.isEmpty) {
      results = myTicketCard;
    } else {
      for (var i = 0; i < myTicketCard.length; i++) {
        results = myTicketCard
            .where((event) => event.event_title
                .toLowerCase()
                .contains(enteredKeyword.toLowerCase()))
            .toList();
      }
    }
    setState(() {
      foundTicket = results;
    });
  }
}