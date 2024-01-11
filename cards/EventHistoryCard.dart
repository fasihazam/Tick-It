import 'package:firstapp/models/EventHistoryCardModel.dart';
import 'package:intl/intl.dart';
import '../models/Event.dart';
import '../screens/EventView.dart';
import '../screens/LoginScreen.dart';
import '../screens/QRScanner.dart';
import 'package:flutter/material.dart';

class EventHistoryCard extends StatelessWidget {
  const EventHistoryCard({
    super.key,
    this.width = 140,
    this.aspectRetion = 1.02,
    required this.eventHistoryCardData,
    required this.press,
  });
  final double width, aspectRetion;
  final EventHistoryCardModel eventHistoryCardData;
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
            height: 100,
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
                          eventHistoryCardData.event_title,
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
                          "Start: " + DateFormat('dd-MM-yyyy')
                              .format(DateTime.parse(eventHistoryCardData.start_date)),
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
                          "By: " + eventHistoryCardData.organizer,
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
                          "End: " + DateFormat('dd-MM-yyyy')
                              .format(DateTime.parse(eventHistoryCardData.end_date)),
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
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
