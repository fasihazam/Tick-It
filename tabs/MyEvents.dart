import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../database/sqlite.dart';
import '../models/Event.dart';
import '../models/EventCardModel.dart';
import '../models/User.dart';
import '../cards/EventCard.dart';
import '../screens/EventView.dart';
import '../screens/TicketView.dart';
import 'package:http/http.dart';
import '../helper/constant.dart' as API;

class MyEvents extends StatefulWidget {
  const MyEvents({super.key});

  @override
  State<MyEvents> createState() => _MyEventsState();
}

class _MyEventsState extends State<MyEvents> {
  List<Map<String, dynamic>> userData = [];
  List<EventCardModel> myEventsCard = [];
  List<EventCardModel> foundEvents = [];
  late bool loader;

  @override
  void initState() {
    super.initState();
    getUserData();
    loader = false;
  }

  void getUserData() async {
    var users = await DatabaseHelper.instance.users();
    setState(() {
      userData = users;
      getMyEventData();
    });
  }

  Future<void> getMyEventData() async {
    try {
      Response response = await get(
        Uri.parse('http://' + API.IP + '/api/getusersevents'),
        headers: {
          'Authorization': "Bearer " + userData[0]['token'],
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as List<dynamic>;
        final eventCardData =
            jsonData.map((json) => EventCardModel.fromJson(json)).toList();
        setState(() {
          myEventsCard = eventCardData;
          foundEvents = myEventsCard;
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
                                height:
                                    MediaQuery.of(context).size.height * 0.5,
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
                                        (index) => EventCard(
                                          eventCardData: foundEvents[index],
                                          press: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) => EventView(
                                                  eventID:
                                                      foundEvents[index].id,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
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
      results = myEventsCard;
    } else {
      for (var i = 0; i < myEventsCard.length; i++) {
        results = myEventsCard
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
