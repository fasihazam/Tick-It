import 'dart:async';
import 'dart:convert';

import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:map_picker/map_picker.dart';
import '../database/sqlite.dart';
import '../helper/DIsplayFunctions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/Day.dart';
import '../models/Event.dart';
import '../models/ImageModel.dart';
import 'MainMenu.dart';
import '../helper/ticket_images.dart';
import 'LoginScreen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../helper/constant.dart' as API;

class TicketView extends StatefulWidget {
  TicketView({super.key, required this.eventID});
  final int eventID;

  @override
  State<TicketView> createState() => _TicketViewState();
}

class _TicketViewState extends State<TicketView> {
  List<Map<String, dynamic>> userData = [];
  late Event allEventData;
  late List<Day> eventDayData = [];
  late List<ImageModel> eventImageData = [];
  late int tab_count = 1;
  bool isChecked = false;
  late List<int> buyDayID = [];
  late double totalPrice = 0;
  var showTotalPrice = TextEditingController();

  @override
  void initState() {
    super.initState();
    getallEventData();
    getUserData();
    showTotalPrice.text = "0";
  }

  void getUserData() async {
    var users = await DatabaseHelper.instance.users();
    setState(() {
      userData = users;
    });
  }

  Future<void> getallEventData() async {
    try {
      Response event_response = await post(
          Uri.parse('http://' + API.IP + '/api/geteventdetails'),
          body: {
            'id': widget.eventID.toString(),
          });
      if (event_response.statusCode == 200) {
        final jsonEvent = json.decode(event_response.body);
        final eventData = Event.fromJson(jsonEvent);
        setState(() {
          allEventData = eventData;
        });
      }

      Response day_response =
          await post(Uri.parse('http://' + API.IP + '/api/geteventdays'), body: {
        'id': widget.eventID.toString(),
      });
      if (day_response.statusCode == 200) {
        final jsonDay = json.decode(day_response.body) as List<dynamic>;
        final dayData = jsonDay.map((json) => Day.fromJson(json)).toList();
        setState(() {
          eventDayData = dayData;
          tab_count = eventDayData.length;
        });
      }
      /*EasyLoading.showToast('Test: ' + eventDayData[0].type,
            toastPosition: EasyLoadingToastPosition.bottom);*/
      Response image_response = await post(
          Uri.parse('http://' + API.IP + '/api/geteventimages'),
          body: {
            'id': widget.eventID.toString(),
          });
      if (image_response.statusCode == 200) {
        final jsonImage = json.decode(image_response.body) as List<dynamic>;
        final imageData =
            jsonImage.map((json) => ImageModel.fromJson(json)).toList();
        setState(() {
          eventImageData = imageData;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
      ));
    }
  }

  Future<void> buyAPI() async {
    try {
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
                  'Buying tickets',
                  style: TextStyle(fontSize: 20),
                ),
              )
            ],
          );
        },
      );

      Response response =
          await post(Uri.parse('http://' + API.IP + '/api/buyticket'), headers: {
        'Authorization': "Bearer " + userData[0]['token'],
      }, body: {
        'dayid[]': buyDayID.toString(),
      });
      EasyLoading.showToast('Test: ' + response.body,
            toastPosition: EasyLoadingToastPosition.bottom);
      Navigator.of(context).pop();

      if (response.statusCode == 200) {
        EasyLoading.showToast('Purchase Successful',
            toastPosition: EasyLoadingToastPosition.bottom);
      } else if (response.statusCode == 422) {
        EasyLoading.showToast('Insufficent balance',
            toastPosition: EasyLoadingToastPosition.bottom);
      } else if (response.statusCode == 409) {
        EasyLoading.showToast('Sorry tickets not available',
            toastPosition: EasyLoadingToastPosition.bottom);
      } else if (response.statusCode == 408) {
        EasyLoading.showToast('Tickets already bought',
            toastPosition: EasyLoadingToastPosition.bottom);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return eventDayData.length == 0
        ? Column(
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
                  'Loading Event',
                  style: TextStyle(fontSize: 20),
                ),
              )
            ],
          )
        : DefaultTabController(
            length: 2,
            child: Scaffold(
              drawer: NavBar(),
              appBar: AppBar(
                title: Text("Tick-It"),
                centerTitle: true,
                systemOverlayStyle: SystemUiOverlayStyle(
                  statusBarColor: Colors.blue[900],
                  statusBarBrightness: Brightness.dark,
                ),
              ),
              bottomNavigationBar: Container(
                child: ButtonBar(
                  children: [
                    SizedBox(
                      width: double.maxFinite,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () {
                          userData.length == 0 
                          ? EasyLoading.showToast('Log in to buy ticket',
            toastPosition: EasyLoadingToastPosition.bottom)
                          : buyPopUp();
                        },
                        child: Text(
                          'Buy',
                        ),
                        style: ElevatedButton.styleFrom(
                          textStyle: TextStyle(fontSize: 25),
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              body: SingleChildScrollView(
                physics: ScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 1.15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(top: 10),
                        alignment: Alignment.center,
                        child: Text(
                          allEventData.event_title,
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 10),
                        alignment: Alignment.center,
                        child: Text(
                          "By " + allEventData.organizer,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                          child: TicketImages(
                        imageData: eventImageData,
                      )),
                      Expanded(
                        child: ContainedTabBarView(
                          tabBarProperties: TabBarProperties(
                            labelColor: Colors.black,
                            labelStyle: TextStyle(fontSize: 20),
                            indicatorWeight: 5,
                          ),
                          tabs: tabMaker(),
                          views: viewMaker(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }

  buyPopUp() {
    buyDayID.clear();
    isChecked = false;
    totalPrice = 0;
    showTotalPrice.text = "0";

    showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        title: Text(
          allEventData.event_title,
          textAlign: TextAlign.center,
        ),
        actions: <Widget>[
          Container(
            height: 150,
            width: double.maxFinite,
            child: Scrollbar(
              showTrackOnHover: true,
              isAlwaysShown: true,
              child: SingleChildScrollView(
                physics: ScrollPhysics(),
                child: Column(
                  children: [
                    Column(
                      children: [
                        ...List.generate(
                            eventDayData.length, (index) => DaysPreview(index))
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
          Container(
            child: Column(
              children: [
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Total:  Rs.",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IntrinsicWidth(
                          child: TextField(
                        controller: showTotalPrice,
                        readOnly: true,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                        ),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ))
                    ],
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Container(
                  alignment: Alignment.bottomCenter,
                  child: RoundedButton(
                    text: 'BUY NOW',
                    press: () {
                      if (buyDayID.length == 0) {
                        EasyLoading.showToast('Select a day to buy',
                            toastPosition: EasyLoadingToastPosition.bottom);
                      } else {
                        Navigator.of(context).pop();
                        buyAPI();
                      }
                    },
                    width: 130,
                    height: 40,
                    background_color: Colors.blue,
                    foreground_color: Colors.white,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  tabMaker() {
    List<Tab> tabs = [];
    for (var i = 0; i < tab_count; i++) {
      tabs.add(Tab(
        text: 'Day ' + (i + 1).toString(),
      ));
    }
    ;
    return tabs;
  }

  viewMaker() {
    List<Widget> view = [];
    for (var i = 0; i < tab_count; i++) {
      view.add(
        Container(
          child: SingleChildScrollView(
            child: DayDisplay(eventDayData, i),
            physics: ScrollPhysics(),
          ),
        ),
      );
    }
    ;
    return view;
  }

  DaysPreview(int index) {
    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.blue;
      }
      return Colors.blue;
    }

    DateTime eventDate = DateTime.parse(eventDayData[index].date);
    DateTime currentDate = DateTime.now();
    bool check = eventDate.isAfter(currentDate.subtract(Duration(days: 1)));
    int day = index + 1;
    return Container(
      child: check == true
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  child: Row(
                    children: [
                      StatefulBuilder(
                        builder: (BuildContext context, setState) {
                          return Checkbox(
                            checkColor: Colors.white,
                            fillColor:
                                MaterialStateProperty.resolveWith(getColor),
                            value: isChecked,
                            onChanged: (bool? value) {
                              setState(() {
                                isChecked = value!;
                              });
                              if (value == true) {
                                buyDayID.add(eventDayData[index].dayID);
                                totalPrice = totalPrice +
                                    eventDayData[index].sponsoredPrice;
                                setState(() {
                                  showTotalPrice.text = totalPrice.toString();
                                });
                              } else {
                                buyDayID.remove(eventDayData[index].dayID);
                                totalPrice = totalPrice -
                                    eventDayData[index].sponsoredPrice;
                                setState(() {
                                  showTotalPrice.text = totalPrice.toString();
                                });
                              }
                            },
                          );
                        },
                      ),
                      Text('Day ' + "$day"),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(right: 15),
                  child: Text(
                      "Rs." + eventDayData[index].sponsoredPrice.toString()),
                )
              ],
            )
          : null,
    );
  }
}
