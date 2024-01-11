import 'package:flutter/material.dart';

class MyHistoryTicketCardModel {
  final int dayid;
  final int ticketid;
  final String event_title;
  final String event_type;
  final String date;
  final String vip;
  final String end_time;
  final String organizer;
  final int price;

  const MyHistoryTicketCardModel({
    required this.dayid,
    required this.ticketid,
    required this.event_title,
    required this.event_type,
    required this.date,
    required this.vip,
    required this.end_time,
    required this.organizer,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'did': dayid,
      'Tid': ticketid,
      'event_title': event_title,
      'type': event_type,
      'date': date,
      'vip': vip,
      'end_time': end_time,
      'organizer': organizer,
      'price': price,
    };
  }

  factory MyHistoryTicketCardModel.fromJson(Map<String, dynamic> json) {
    return MyHistoryTicketCardModel(
      dayid: json['did'],
      ticketid: json['Tid'],
      event_title: json['event_title'],
      event_type: json['type'],
      date: json['date'],
      vip: json['vip'],
      end_time: json['end_time'],
      organizer: json['organizer'],
      price: json['price'],
    );
  }
}