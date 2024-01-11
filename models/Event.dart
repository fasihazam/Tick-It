import 'package:flutter/material.dart';

class Event {
  final int id;
  final int user_id;
  final String event_title;
  final int event_type;
  final String organizer;
  final String start_date;
  final String end_date;
  final String created_at;
  final String updated_at;

  const Event({
    required this.id,
    required this.user_id,
    required this.event_title,
    required this.event_type,
    required this.organizer,
    required this.start_date,
    required this.end_date,
    required this.created_at,
    required this.updated_at,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      user_id: json['user_id'],
      event_title: json['event_title'],
      event_type: json['event_type'],
      organizer: json['organizer'],
      start_date: json['start_date'],
      end_date: json['end_date'],
      created_at: json['created_at'],
      updated_at: json['updated_at'],
    );
  }
}