import 'dart:convert';

import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart';
import '../Screens/EventFormScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../helper/DIsplayFunctions.dart';
import '../models/Day.dart';
import '../models/Event.dart';
import '../models/ImageModel.dart';
import 'MainMenu.dart';
import '../helper/ticket_images.dart';
import '../helper/constant.dart' as API;

class EventView extends StatefulWidget {
  const EventView({super.key, required this.eventID});
  final int eventID;

  @override
  State<EventView> createState() => _EventViewState();
}

class _EventViewState extends State<EventView> {
  late Event myEventData;
  late List<Day> eventDayData = [];
  late List<ImageModel> eventImageData = [];
  late int tab_count = 1;

  @override
  void initState() {
    super.initState();
    getMyEventData();
  }

  Future<void> getMyEventData() async {
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
          myEventData = eventData;
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
              body: SingleChildScrollView(
                physics: ScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height*1.15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(top: 10),
                        alignment: Alignment.center,
                        child: Text(
                          myEventData.event_title,
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
                          "By " + myEventData.organizer,
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
            child: EventDayDisplay(eventDayData, i),
            physics: ScrollPhysics(),
          ),
        ),
      );
    };
    return view;
  }
}
