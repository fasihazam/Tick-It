import 'dart:io';

import 'package:flutter/material.dart';
import '../models/Event.dart';
import '../models/ImageModel.dart';
import '../helper/constant.dart' as API;

class TicketImages extends StatefulWidget {
  const TicketImages({
    super.key, required this.imageData,
  });

  final List<ImageModel> imageData;

  @override
  State<TicketImages> createState() => _TicketImagesState();
}

class _TicketImagesState extends State<TicketImages> {
  int selectedImage = 0;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          
          width: double.infinity,
          height: 300,
          child: Card(
            shadowColor: Colors.black,
            elevation: 9,
            margin: EdgeInsets.all(15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 300,
              child: Card(
                margin: EdgeInsets.all(10),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.network("http://" + API.IP + widget.imageData[selectedImage].path, 
                      fit: BoxFit.scaleDown),
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          width: double.maxFinite,
          child:  Card(
            margin: EdgeInsets.only(right: 15, left: 15, bottom: 10),
            shadowColor: Colors.black,
            elevation: 9,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: Colors.white,
            child: Container(
              
              margin: new EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ...List.generate(widget.imageData.length,
                      (index) => smallImagesPreview(index))
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  GestureDetector smallImagesPreview(int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedImage = index;
        });
      },
      child: Container(
        height: 60,
        width: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(
              color:
                  selectedImage == index ? Colors.blue : Colors.transparent),
        ),
        child: Image.network("http://" + API.IP + widget.imageData[index].path),
      ),
    );
  }
}
