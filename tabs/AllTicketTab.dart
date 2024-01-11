import 'dart:convert';

import 'package:firstapp/models/EventCardModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart';
import '../database/sqlite.dart';
import '../models/User.dart';
import '../cards/TicketCard.dart';
import '../screens/TicketView.dart';
import '../helper/constant.dart' as API;

class AllTickets extends StatefulWidget {
  const AllTickets({super.key});

  @override
  State<AllTickets> createState() => _AllTicketsState();
}

class _AllTicketsState extends State<AllTickets> {
  List<Map<String, dynamic>> userData = [];
  List<EventCardModel> allTicketCard = [];
  List<EventCardModel> foundEvents = [];
  late bool loader;

  void getUserData() async {
    var users = await DatabaseHelper.instance.users();
    setState(() {
      userData = users;
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      getUserData();
      loader = false;
      getallTicketData();
    });
    
  }

  Future<void> getallTicketData() async {
    try {
      Response response = await get(
        Uri.parse('http://' + API.IP + '/api/getevent'),
      );
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as List<dynamic>;
        final eventCardData =
            jsonData.map((json) => EventCardModel.fromJson(json)).toList();
        setState(() {
          allTicketCard = eventCardData;
          foundEvents = allTicketCard;
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
                            hintText: "Search Event",
                            prefixIcon: Icon(Icons.search),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        child: loader == false
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
                                      'Loading Events',
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  )
                                ],
                              ),
                            )
                            : foundEvents.length == 0
                                ? Container(
                                    padding: EdgeInsets.only(top: 20),
                                    child: Text('No event found',
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.grey[600],
                                        )),
                                  )
                                : Column(
                                    children: [
                                      ...List.generate(
                                        foundEvents.length,
                                        (index) => TicketCard(
                                            ticketCardData: foundEvents[index],
                                            press: () {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          TicketView(
                                                            eventID:
                                                                foundEvents[
                                                                        index]
                                                                    .id,
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
    List<EventCardModel> results = [];
    if (enteredKeyword.isEmpty) {
      results = allTicketCard;
    } else {
      for (var i = 0; i < allTicketCard.length; i++) {
        results = allTicketCard
            .where((event) => event.event_title
                .toLowerCase()
                .contains(enteredKeyword.toLowerCase()))
            .toList();
      }
    }
    setState(() {
      foundEvents = results;
    });
  }
}
