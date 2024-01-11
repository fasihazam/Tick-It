import 'package:firstapp/models/EventCardModel.dart';
import 'package:intl/intl.dart';

import '../models/Event.dart';
import '../screens/EventView.dart';
import '../screens/LoginScreen.dart';
import '../screens/QRScanner.dart';
import 'package:flutter/material.dart';

class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.eventCardData,
    required this.press,
  });
  final EventCardModel eventCardData;
  final GestureTapCallback press;

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: GestureDetector(
        onTap: press,
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
                          eventCardData.event_title,
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
                          DateFormat('dd-MM-yyyy')
                              .format(DateTime.parse(eventCardData.start_date)),
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
                          "By: " + eventCardData.organizer,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                          margin: EdgeInsets.only(right: 10),
                          child: eventCardData.event_type == 1
                              ? Text(
                                  "Physical",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : Container(
                                  child: eventCardData.event_type == 2
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
                                builder: (context) => EventView(
                                      eventID: eventCardData.id,
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
                          text: 'Scanner',
                          press: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => BarcodeScannerWithController(ECeventID: eventCardData.id,)));
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
