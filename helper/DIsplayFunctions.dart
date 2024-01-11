import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:map_picker/map_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/Day.dart';
import '../models/Event.dart';
import '../helper/ticket_images.dart';
import 'package:url_launcher/url_launcher.dart';

Position? _currentPosition;

String getTime(timeString) {
  List<String> parts = timeString.split(':');

  int hours = int.parse(parts[0]);
  int minutes = int.parse(parts[1]);
  int seconds = int.parse(parts[2]);

  String period = hours >= 12 ? 'PM' : 'AM';
  hours = hours % 12;
  hours = hours != 0 ? hours : 12;

  String time = '$hours:$minutes $period';

  return time;
}

EventDayDisplay(List<Day> day, int index) {
  int total = day[index].sold + day[index].left;
  return Column(
    children: [
      Container(
        padding: EdgeInsets.only(top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.only(left: 20),
              alignment: Alignment.center,
              child: Text(
                "Total Tickets: ",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(right: 20),
              alignment: Alignment.center,
              child: Text(
                total.toString(),
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
      ),
      Divider(
        thickness: 1,
      ),
      Container(
        padding: EdgeInsets.only(top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.only(left: 20),
              alignment: Alignment.center,
              child: Text(
                "Tickets Sold: ",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(right: 20),
              alignment: Alignment.center,
              child: Text(
                day[index].sold.toString(),
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
      ),
      Divider(
        thickness: 1,
      ),
      Container(
        padding: EdgeInsets.only(top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.only(left: 20),
              alignment: Alignment.center,
              child: Text(
                "Price: ",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(right: 20),
              alignment: Alignment.center,
              child: Text(
                "${day[index].pricePerTicket}",
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
      ),
      Divider(
        thickness: 1,
      ),
      Container(
        padding: EdgeInsets.only(top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.only(left: 20),
              alignment: Alignment.center,
              child: Text(
                "Type: ",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
                child: int.parse(day[index].type) == 1
                    ? Container(
                        padding: EdgeInsets.only(right: 20),
                        alignment: Alignment.center,
                        child: Text(
                          "Physical",
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      )
                    : Container(
                        padding: EdgeInsets.only(right: 20),
                        alignment: Alignment.center,
                        child: Text(
                          "Online",
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      )),
          ],
        ),
      ),
      Divider(
        thickness: 1,
      ),
      Container(
        padding: EdgeInsets.only(top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.only(left: 20),
              alignment: Alignment.center,
              child: Text(
                "Date: ",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(right: 20),
              alignment: Alignment.center,
              child: Text(
                DateFormat('dd-MM-yyyy')
                    .format(DateTime.parse(day[index].date)),
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
      ),
      Divider(
        thickness: 1,
      ),
      Container(
        padding: EdgeInsets.only(top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.only(left: 20),
              alignment: Alignment.center,
              child: Text(
                "Start Time: ",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(right: 20),
              alignment: Alignment.center,
              child: Text(
                getTime(day[index].start_time),
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
      ),
      Divider(
        thickness: 1,
      ),
      Container(
        padding: EdgeInsets.only(top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.only(left: 20),
              alignment: Alignment.center,
              child: Text(
                "End Time: ",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(right: 20),
              alignment: Alignment.center,
              child: Text(
                getTime(day[index].end_time),
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
      ),
      Divider(
        thickness: 1,
      ),
      Container(
        padding: EdgeInsets.only(top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.only(left: 20),
              alignment: Alignment.center,
              child: Text(
                "VIP: ",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(right: 20),
              alignment: Alignment.center,
              child: Text(
                day[index].vip,
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
      ),
      Divider(
        thickness: 1,
      ),
      Container(
          child: int.parse(day[index].type) == 1
              ? Container(
                  padding: EdgeInsets.only(top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.only(left: 20),
                        alignment: Alignment.center,
                        child: Text(
                          "Location: ",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(right: 20),
                        alignment: Alignment.center,
                        child: Text(
                          day[index].location,
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Container(
                  padding: EdgeInsets.only(top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.only(left: 20),
                        alignment: Alignment.center,
                        child: Text(
                          "Event Link: ",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(right: 20),
                        alignment: Alignment.center,
                        child: RichText(
                          text: TextSpan(
                            text: day[index].event_link,
                            style:
                                new TextStyle(fontSize: 20, color: Colors.blue),
                            recognizer: new TapGestureRecognizer()
                              ..onTap = () {
                                launch(day[index].event_link);
                              },
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
      Divider(
        thickness: 1,
      ),
      Container(
        padding: EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 10),
        alignment: Alignment.topLeft,
        child: Text(
          "Description:",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      Container(
        padding: EdgeInsets.only(left: 20, right: 20),
        alignment: Alignment.topLeft,
        child: Text(
          day[index].description,
          style: TextStyle(
            fontSize: 20,
          ),
        ),
      ),
      Container(
          padding: EdgeInsets.only(top: 5),
          child: int.parse(day[index].type) == 1
              ? Column(
                  children: [
                    Divider(
                      thickness: 1,
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Container(
                        child: LimitedBox(
                          maxHeight: 250,
                          child: LocationShower(
                            loc: day[index].location,
                            lat: day[index].lat,
                            lng: day[index].long,
                          ),
                        ),
                      ),
                    )
                  ],
                )
              : null),
    ],
  );
}

DayDisplay(List<Day> day, int index) {
  int total = day[index].sold + day[index].left;
  return Column(
    children: [
      Container(
        padding: EdgeInsets.only(top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.only(left: 20),
              alignment: Alignment.center,
              child: Text(
                "Price: ",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(right: 20),
              alignment: Alignment.center,
              child: Text(
                "${day[index].sponsoredPrice}",
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
      ),
      Divider(
        thickness: 1,
      ),
      Container(
        padding: EdgeInsets.only(top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.only(left: 20),
              alignment: Alignment.center,
              child: Text(
                "Type: ",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
                child: int.parse(day[index].type) == 1
                    ? Container(
                        padding: EdgeInsets.only(right: 20),
                        alignment: Alignment.center,
                        child: Text(
                          "Physical",
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      )
                    : Container(
                        padding: EdgeInsets.only(right: 20),
                        alignment: Alignment.center,
                        child: Text(
                          "Online",
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      )),
          ],
        ),
      ),
      Divider(
        thickness: 1,
      ),
      Container(
        padding: EdgeInsets.only(top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.only(left: 20),
              alignment: Alignment.center,
              child: Text(
                "Date: ",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(right: 20),
              alignment: Alignment.center,
              child: Text(
                DateFormat('dd-MM-yyyy')
                    .format(DateTime.parse(day[index].date)),
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
      ),
      Divider(
        thickness: 1,
      ),
      Container(
        padding: EdgeInsets.only(top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.only(left: 20),
              alignment: Alignment.center,
              child: Text(
                "Start Time: ",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(right: 20),
              alignment: Alignment.center,
              child: Text(
                getTime(day[index].start_time),
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
      ),
      Divider(
        thickness: 1,
      ),
      Container(
        padding: EdgeInsets.only(top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.only(left: 20),
              alignment: Alignment.center,
              child: Text(
                "End Time: ",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(right: 20),
              alignment: Alignment.center,
              child: Text(
                getTime(day[index].end_time),
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
      ),
      Divider(
        thickness: 1,
      ),
      Container(
        padding: EdgeInsets.only(top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.only(left: 20),
              alignment: Alignment.center,
              child: Text(
                "VIP: ",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(right: 20),
              alignment: Alignment.center,
              child: Text(
                day[index].vip,
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
      ),
      Divider(
        thickness: 1,
      ),
      Container(
          child: int.parse(day[index].type) == 1
              ? Column(
                  children: [
                    Container(
                      padding: EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.only(left: 20),
                            alignment: Alignment.center,
                            child: Text(
                              "Location: ",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(right: 20),
                            alignment: Alignment.center,
                            child: Text(
                              day[index].location,
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      thickness: 1,
                    ),
                  ],
                )
              : null),
      Container(
        padding: EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 10),
        alignment: Alignment.topLeft,
        child: Text(
          "Description:",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      Container(
        padding: EdgeInsets.only(left: 20, right: 20),
        alignment: Alignment.topLeft,
        child: Text(
          day[index].description,
          style: TextStyle(
            fontSize: 20,
          ),
        ),
      ),
      Container(
          padding: EdgeInsets.only(top: 5),
          child: int.parse(day[index].type) == 1
              ? Column(
                  children: [
                    Divider(
                      thickness: 1,
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Container(
                        child: LimitedBox(
                          maxHeight: 250,
                          child: LocationShower(
                            loc: day[index].location,
                            lat: day[index].lat,
                            lng: day[index].long,
                          ),
                        ),
                      ),
                    )
                  ],
                )
              : null),
    ],
  );
}

class LocationShower extends StatefulWidget {
  final double lat;
  final double lng;
  final String loc;
  const LocationShower(
      {Key? key, required this.lat, required this.lng, required this.loc})
      : super(key: key);

  @override
  _LocationShowerState createState() => _LocationShowerState();
}

class _LocationShowerState extends State<LocationShower> {
  final _controller = Completer<GoogleMapController>();

  String? _currentAddress;

  CameraPosition cameraPosition = CameraPosition(
    target: LatLng(0.0, 0.0),
    zoom: 14.4746,
  );

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    permission = await Geolocator.checkPermission();
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        EasyLoading.showToast('Location permissions are denied',
            toastPosition: EasyLoadingToastPosition.bottom);
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      EasyLoading.showToast(
          'Location permissions are permanently denied, we cannot request permissions.',
          toastPosition: EasyLoadingToastPosition.bottom);
      return false;
    }
    return true;
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() => _currentPosition = position);
    }).catchError((e) {
      debugPrint(e);
    });
  }

  var textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _getCurrentPosition();
    var mapPickerController = MapPickerController();
    return Scaffold(
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          GestureDetector(
            onVerticalDragStart: (start) {},
            child: MapPicker(
              //add map picker controller
              mapPickerController: mapPickerController,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(width: 1.5, color: Colors.blue),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(15),
                  ),
                  child: GoogleMap(
                    gestureRecognizers: Set()
                      ..add(Factory<OneSequenceGestureRecognizer>(
                          () => new EagerGestureRecognizer()))
                      ..add(Factory<PanGestureRecognizer>(
                          () => PanGestureRecognizer()))
                      ..add(Factory<ScaleGestureRecognizer>(
                          () => ScaleGestureRecognizer()))
                      ..add(Factory<TapGestureRecognizer>(
                          () => TapGestureRecognizer()))
                      ..add(Factory<VerticalDragGestureRecognizer>(
                          () => VerticalDragGestureRecognizer())),
                    myLocationEnabled: true,
                    zoomControlsEnabled: false,
                    // hide location button
                    myLocationButtonEnabled: false,
                    mapType: MapType.normal,
                    markers: Set<Marker>.of([
                      Marker(
                        markerId: MarkerId('myMarker'),
                        position: LatLng(widget.lat, widget.lng),
                        infoWindow: InfoWindow(title: 'My Location'),
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueAzure),
                      ),
                    ]),
                    //  camera position
                    initialCameraPosition: CameraPosition(
                      target: LatLng(widget.lat, widget.lng),
                      zoom: 14,
                    ),
                    onMapCreated: (GoogleMapController controller) {
                      _controller.complete(controller);
                      textController.text = widget.loc;
                    },
                    onCameraMoveStarted: () {
                      // notify map is moving
                      mapPickerController.mapMoving!();
                    },
                    onCameraMove: (cameraPosition) {
                      this.cameraPosition = cameraPosition;
                    },
                    onCameraIdle: () async {
                      // notify map stopped moving
                      mapPickerController.mapFinishedMoving!();
                      //get address name from camera position
                      List<Placemark> placemarks =
                          await placemarkFromCoordinates(
                        cameraPosition.target.latitude,
                        cameraPosition.target.longitude,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).viewPadding.top + 20,
            width: MediaQuery.of(context).size.width - 50,
            height: 50,
            child: TextFormField(
              maxLines: 3,
              textAlign: TextAlign.center,
              readOnly: true,
              decoration: const InputDecoration(
                  contentPadding: EdgeInsets.zero, border: InputBorder.none),
              controller: textController,
            ),
          ),
        ],
      ),
    );
  }
}
