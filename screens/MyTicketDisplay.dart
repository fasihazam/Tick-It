import 'dart:async';
import 'dart:convert';
import 'package:flutter/rendering.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:map_picker/map_picker.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../database/sqlite.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/AdImageModel.dart';
import '../models/Day.dart';
import '../models/Event.dart';
import '../models/ImageModel.dart';
import '../models/MyTicketCardModel.dart';
import '../models/TicketModel.dart';
import 'MainMenu.dart';
import '../helper/ticket_images.dart';
import 'LoginScreen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../helper/constant.dart' as API;
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart';

class MyTicketDisplay extends StatefulWidget {
  MyTicketDisplay({super.key, required this.ticketID, required this.dayID});
  final int ticketID;
  final int dayID;

  @override
  State<MyTicketDisplay> createState() => _MyTicketDisplayState();
}

class _MyTicketDisplayState extends State<MyTicketDisplay> {
  List<Map<String, dynamic>> userData = [];
  late Ticket ticketDayData;
  late bool check;
  late String QRcode;

  @override
  void initState() {
    super.initState();
    check = false;
    getUserData();
  }

  void getUserData() async {
    var users = await DatabaseHelper.instance.users();
    setState(() {
      userData = users;
      getTicketDayData();
    });
  }

  Future<void> getTicketDayData() async {
    try {
      Response event_response = await post(
          Uri.parse('http://' + API.IP + '/api/gettickitdetails'),
          headers: {
            'Authorization': "Bearer " + userData[0]['token'],
          },
          body: {
            'id': widget.ticketID.toString(),
          });

      /*EasyLoading.showToast('Test: ' + event_response.body,
          toastPosition: EasyLoadingToastPosition.bottom);*/

      if (event_response.statusCode == 200) {
        final jsonEvent = json.decode(event_response.body);
        final eventData = Ticket.fromJson(jsonEvent[0]);
        setState(() {
          ticketDayData = eventData;
          check = true;
          QRcode = userData[0]['id'].toString() +
              ',' +
              ticketDayData.ticketid.toString() +
              ',' +
              ticketDayData.eventid.toString() +
              ',' +
              widget.dayID.toString();
        });
        /*EasyLoading.showToast('Test: ' + ticketDayData.sponsored.toString(),
        toastPosition: EasyLoadingToastPosition.bottom);*/
      }
    } catch (e) {
      EasyLoading.showToast('Error: ' + e.toString(),
          toastPosition: EasyLoadingToastPosition.bottom);
    }
  }

  @override
  Widget build(BuildContext context) {
    return check == false
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
        : Scaffold(
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
                    maxHeight: MediaQuery.of(context).size.height * 1.18),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(top: 10),
                      alignment: Alignment.center,
                      child: Text(
                        ticketDayData.event_title,
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
                        "By " + ticketDayData.organizer,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                        child: ticketDayData.sponsored == 1
                            ? SponsorAd(
                                dayId: widget.dayID,
                                usertoken: userData[0]['token'])
                            : null),
                    Container(
                        child: int.parse(ticketDayData.event_type) == 1
                            ? Container(
                                alignment: Alignment.center,
                                child: QrImage(
                                  data: QRcode,
                                  version: QrVersions.auto,
                                  size: 180,
                                ),
                              )
                            : Container(
                                padding: EdgeInsets.only(top: 20, bottom: 20),
                                child: RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    text: ticketDayData.event_link,
                                    style: new TextStyle(
                                        fontSize: 25, color: Colors.blue),
                                    recognizer: new TapGestureRecognizer()
                                      ..onTap = () {
                                        launch(ticketDayData.event_link);
                                      },
                                  ),
                                ),
                              )),
                    Expanded(
                      child: Container(
                        child: SingleChildScrollView(
                          child: TicketDayDisplay(ticketDayData),
                          physics: ScrollPhysics(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}

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

TicketDayDisplay(Ticket ticket) {
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
                "${ticket.price}",
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
                child: int.parse(ticket.event_type) == 1
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
                DateFormat('dd-MM-yyyy').format(DateTime.parse(ticket.date)),
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
                getTime(ticket.start_time),
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
                getTime(ticket.end_time),
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
                ticket.vip,
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
          child: int.parse(ticket.event_type) == 1
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
                              ticket.location,
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
          ticket.description,
          style: TextStyle(
            fontSize: 20,
          ),
        ),
      ),
      Container(
          padding: EdgeInsets.only(top: 5),
          child: int.parse(ticket.event_type) == 1
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
                            loc: ticket.location,
                            lat: ticket.lat,
                            lng: ticket.lng,
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

class SponsorAd extends StatefulWidget {
  SponsorAd({super.key, required this.dayId, required this.usertoken});
  int dayId;
  String usertoken;
  @override
  State<SponsorAd> createState() => _SponsorAdState();
}

class _SponsorAdState extends State<SponsorAd> {
  List<String> imageUrls = [];
  List<int> imageID = [];
  late List<AdImage> eventImageData = [];
  bool isSliderPlaying = true;

  final ScrollController _scrollController = ScrollController();
  final CarouselController _carouselController = CarouselController();
  bool isSliderVisible = true;
  bool isSliderAutoPlay = true;
  @override
  void initState() {
    super.initState();
    setState(() {
      fetchImages();
    });
  }

  Future<void> fetchImages() async {
    try {
      // Make an API request to fetch images
      Response response = await post(
        Uri.parse('http://' + API.IP + '/api/getsponsors'),
        headers: {
          'Authorization': 'Bearer ' + widget.usertoken,
        },
        body: {
          'id': widget.dayId.toString(),
        },
      );
      if (response.statusCode == 200) {
        final jsonImage = json.decode(response.body) as List<dynamic>;
        final imageData =
            jsonImage.map((json) => AdImage.fromJson(json)).toList();
        setState(() {
          eventImageData = imageData;

          for (var i = 0; i < eventImageData.length; i++) {
            imageUrls.add(eventImageData[i].path);
            imageID.add(eventImageData[i].id);
          }
        });
      } else {
        // Handle error if the API call fails
        EasyLoading.showToast('Could not load sponsor',
            toastPosition: EasyLoadingToastPosition.bottom);
      }
    } catch (e) {
      EasyLoading.showToast('Error: ' + e.toString(),
          toastPosition: EasyLoadingToastPosition.bottom);
    }
  }

  void _onVisibilityChanged(VisibilityInfo visibilityInfo) {
    setState(() {
      isSliderVisible = visibilityInfo.visibleFraction > 0.5;
      if (isSliderVisible) {
        isSliderPlaying = true;
      } else {
        isSliderPlaying = false;
      }
    });
  }

  Future<void> viewsAPI(int index) async {
    try {
      // Make an API request to fetch images
      Response response = await post(
        Uri.parse('http://' + API.IP + '/api/adcount'),
        headers: {
          'Authorization': 'Bearer ' + widget.usertoken,
        },
        body: {
          'id': imageID[index].toString(),
        },
      );
      if (response.statusCode == 200) {
      } else {
        EasyLoading.showToast('Error: ' + response.body,
            toastPosition: EasyLoadingToastPosition.bottom);
      }
    } catch (e) {
      EasyLoading.showToast('Error: ' + e.toString(),
          toastPosition: EasyLoadingToastPosition.bottom);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragStart: (_) {
        setState(() {
          isSliderPlaying = true;
        });
      },
      onVerticalDragEnd: (_) {
        setState(() {
          isSliderPlaying = false;
        });
      },
      child: VisibilityDetector(
        key: Key('sliderVisibilityKey'),
        onVisibilityChanged: _onVisibilityChanged,
        child: Container(
          child: CarouselSlider(
            carouselController: _carouselController,
            options: CarouselOptions(
              autoPlay: isSliderPlaying && isSliderVisible,
              aspectRatio: 16 / 9,
              enlargeCenterPage: true,
              onPageChanged: (index, reason) async {
                setState(() {
                  viewsAPI(index);
                });
              },
            ),
            items: imageUrls.map((i) {
              return Builder(builder: (BuildContext context) {
                return Container(
                  margin: EdgeInsets.all(5),
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    child: Image.network(
                      "http://" + API.IP + i,
                      fit: BoxFit.cover,
                      width: 1000,
                    ),
                  ),
                );
              });
            }).toList(),
          ),
        ),
      ),
    );
  }
}
