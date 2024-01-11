import 'dart:convert';

import 'package:firstapp/screens/LoginScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../helper/qr_overlay.dart';
import '../database/sqlite.dart';
import '../helper/constant.dart' as API;

class BarcodeScannerWithController extends StatefulWidget {
  late int ECeventID;
  BarcodeScannerWithController({Key? key, required this.ECeventID})
      : super(key: key);

  @override
  _BarcodeScannerWithControllerState createState() =>
      _BarcodeScannerWithControllerState();
}

class _BarcodeScannerWithControllerState
    extends State<BarcodeScannerWithController>
    with SingleTickerProviderStateMixin {
  BarcodeCapture? barcode;
  late String qrcode;
  List<Map<String, dynamic>> userData = [];

  final MobileScannerController controller = MobileScannerController(
      //torchEnabled: true,
      // formats: [BarcodeFormat.qrCode]
      // facing: CameraFacing.front,
      // detectionSpeed: DetectionSpeed.normal
      // detectionTimeoutMs: 1000,
      // returnImage: false,
      );

  bool isStarted = true;

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  void getUserData() async {
    var users = await DatabaseHelper.instance.users();
    setState(() {
      userData = users;
    });
  }

  void _startOrStop() {
    try {
      if (isStarted) {
        controller.stop();
      } else {
        controller.start();
      }
      setState(() {
        isStarted = !isStarted;
      });
    } on Exception catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Something went wrong! $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tick-It"),
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.blue[900],
          statusBarBrightness: Brightness.dark,
        ),
      ),
      backgroundColor: Colors.black,
      body: Builder(
        builder: (context) {
          return Stack(
            children: [
              MobileScanner(
                controller: controller,
                fit: BoxFit.cover,
                scanWindow: Rect.fromCenter(
                    center: Offset(MediaQuery.of(context).size.width / 2,
                        MediaQuery.of(context).size.height / 2),
                    width: 150,
                    height: 250),
                onDetect: (barcode) {
                  setState(() {
                    this.barcode = barcode;
                    controller.stop();
                    qrcode = barcode.barcodes.first.rawValue.toString();
                    final split = qrcode.split(',');
                    final Map<int, String> values = {
                      for (int i = 0; i < split.length; i++) i: split[i]
                    };

                    int TBeventid = int.parse(values[2].toString());

                    if (widget.ECeventID == TBeventid) {
                      setState(() {
                        qrcodeAPI();
                      });
                    } else {
                      showDialog<String>(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(8.0)),
                          ),
                          icon: Icon(
                            Icons.highlight_off,
                            color: Colors.red,
                            size: 50,
                          ),
                          title: Text(
                            "Not your event",
                            textAlign: TextAlign.center,
                          ),
                          actions: [
                            Container(
                              alignment: Alignment.bottomCenter,
                              child: RoundedButton(
                                text: 'Ok',
                                press: () {
                                  controller.start();
                                  Navigator.of(context).pop();
                                },
                                width: 100,
                                height: 40,
                                background_color: Colors.blue,
                                foreground_color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  });
                },
              ),
              QRScannerOverlay(overlayColour: Colors.black.withOpacity(0.5)),
            ],
          );
        },
      ),
    );
  }

  qrcodeAPI() async {
    try {
      Response response =
          await post(Uri.parse('http://' + API.IP + '/api/scan'), headers: {
        'Authorization': "Bearer " + userData[0]['token'],
      }, body: {
        'ids': qrcode,
      });

      if (response.statusCode == 200) {
        /*EasyLoading.showToast('Successfully',
            toastPosition: EasyLoadingToastPosition.bottom);*/
        showDialog<String>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
            icon: Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 50,
            ),
            title: Text(
              "Verified",
              textAlign: TextAlign.center,
            ),
            actions: [
              Container(
                alignment: Alignment.bottomCenter,
                child: RoundedButton(
                  text: 'Ok',
                  press: () {
                    controller.start();
                    Navigator.of(context).pop();
                  },
                  width: 100,
                  height: 40,
                  background_color: Colors.blue,
                  foreground_color: Colors.white,
                ),
              ),
            ],
          ),
        );
      } else if (response.statusCode == 201) {
        /*EasyLoading.showToast('Event not started yet',
            toastPosition: EasyLoadingToastPosition.bottom);*/
        showDialog<String>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
            icon: Icon(
              Icons.schedule,
              color: Colors.amber,
              size: 50,
            ),
            title: Text(
              "Event not started",
              textAlign: TextAlign.center,
            ),
            actions: [
              Container(
                alignment: Alignment.bottomCenter,
                child: RoundedButton(
                  text: 'Ok',
                  press: () {
                    controller.start();
                    Navigator.of(context).pop();
                  },
                  width: 100,
                  height: 40,
                  background_color: Colors.blue,
                  foreground_color: Colors.white,
                ),
              ),
            ],
          ),
        );
      } else if (response.statusCode == 400) {
        /*EasyLoading.showToast('Ticket alraeady scanned',
            toastPosition: EasyLoadingToastPosition.bottom);*/
        showDialog<String>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
            icon: Icon(
              Icons.highlight_off,
              color: Colors.red,
              size: 50,
            ),
            title: Text(
              "Already used",
              textAlign: TextAlign.center,
            ),
            actions: [
              Container(
                alignment: Alignment.bottomCenter,
                child: RoundedButton(
                  text: 'Ok',
                  press: () {
                    controller.start();
                    Navigator.of(context).pop();
                  },
                  width: 100,
                  height: 40,
                  background_color: Colors.blue,
                  foreground_color: Colors.white,
                ),
              ),
            ],
          ),
        );
      } else if (response.statusCode == 404) {
        /*EasyLoading.showToast('Event has already ended',
            toastPosition: EasyLoadingToastPosition.bottom);*/
        showDialog<String>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
            icon: Icon(
              Icons.event_busy_outlined,
              color: Colors.orange,
              size: 50,
            ),
            title: Text(
              "Event has ended",
              textAlign: TextAlign.center,
            ),
            actions: [
              Container(
                alignment: Alignment.bottomCenter,
                child: RoundedButton(
                  text: 'Ok',
                  press: () {
                    controller.start();
                    Navigator.of(context).pop();
                  },
                  width: 100,
                  height: 40,
                  background_color: Colors.blue,
                  foreground_color: Colors.white,
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
      ));
    }
  }
}
