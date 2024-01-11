import 'package:flutter/material.dart';

class Ticket {
  final int sponsored;
  final int eventid;
  final String event_title;
  final String organizer;
  final int ticketid;
  final int price;
  final String event_type;
  final String event_link;
  final String date;
  final String start_time;
  final String end_time;
  final String vip;
  final String location;
  final String description;
  final double lat;
  final double lng;

  const Ticket({
    required this.sponsored,
    required this.eventid,
    required this.event_title,
    required this.organizer,
    required this.ticketid,
    required this.price,
    required this.event_type,
    required this.event_link,
    required this.date,
    required this.start_time,
    required this.end_time,
    required this.vip,
    required this.location,
    required this.description,
    required this.lat,
    required this.lng,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      sponsored: json['sponsored'],
      eventid: json['Eid'],
      event_title: json['event_title'],
      organizer: json['organizer'],
      ticketid: json['Tid'],
      price: json['price'],
      event_type: json['type'],
      event_link: json['event_link'],
      date: json['date'],
      start_time: json['start_time'],
      end_time: json['end_time'],
      vip: json['vip'],
      location: json['location'],
      description: json['description'],
      lat: double.parse(json['lat'].toString()),
      lng: double.parse(json['long'].toString()),
    );
  }
}