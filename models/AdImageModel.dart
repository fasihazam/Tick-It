import 'package:flutter/material.dart';

class AdImage {
  final String path;
  final int id;

  const AdImage({
    required this.path,
    required this.id,
  });

  factory AdImage.fromJson(Map<String, dynamic> json) {
    return AdImage(
      path: json['path'],
      id: json['id'],
    );
  }
}