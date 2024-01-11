import 'dart:convert';
import 'package:firstapp/Screens/MainMenu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../database/sqlite.dart';
import '../models/Event.dart';
import '../models/EventHistoryCardModel.dart';
import '../cards/EventHistoryCard.dart';
import 'EventView.dart';
import 'TicketView.dart';
import 'package:http/http.dart';
import '../helper/constant.dart' as API;

class MyEventsHistory extends StatefulWidget {
  MyEventsHistory({super.key, required this.loginCheck});
  bool loginCheck;
  @override
  State<MyEventsHistory> createState() => _MyEventsHistoryState();
}

class _MyEventsHistoryState extends State<MyEventsHistory> {
  List<Map<String, dynamic>> userData = [];
  List<EventHistoryCardModel> myEventsHistoryCard = [];
  List<EventHistoryCardModel> foundEvents = [];
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
      getMyEventData();
    });
  }

  Future<void> getMyEventData() async {
    try {
      Response response = await get(
        Uri.parse('http://' + API.IP + '/api/getausereventshistory'),
        headers: {
          'Authorization': "Bearer " + userData[0]['token'],
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as List<dynamic>;
        final eventHistoryCardData = jsonData
            .map((json) => EventHistoryCardModel.fromJson(json))
            .toList();
        setState(() {
          myEventsHistoryCard = eventHistoryCardData;
          foundEvents = myEventsHistoryCard;
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
                        'Sign in to view your event history',
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
                                                  'Loading Events',
                                                  style:
                                                      TextStyle(fontSize: 20),
                                                ),
                                              )
                                            ],
                                          ),
                                        )
                                      : foundEvents.length == 0
                                          ? Container(
                                              padding: EdgeInsets.all(100),
                                              child: Text('No Event Found',
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    color: Colors.grey[600],
                                                  )),
                                            )
                                          : Column(
                                              children: [
                                                ...List.generate(
                                                  myEventsHistoryCard.length,
                                                  (index) => EventHistoryCard(
                                                    eventHistoryCardData:
                                                        myEventsHistoryCard[
                                                            index],
                                                    press: () {
                                                      Navigator.of(context)
                                                          .push(
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              EventView(
                                                            eventID:
                                                                myEventsHistoryCard[
                                                                        index]
                                                                    .id,
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
              ))));
  }
}
