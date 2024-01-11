import 'dart:convert';
import 'package:cool_datepicker/cool_datepicker.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:map_picker/map_picker.dart';
import '../database/sqlite.dart';
import 'MainMenu.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import '../helper/constant.dart' as API;

Position? _currentPosition;
CameraPosition? cameraPosition;
MapPickerController mapPickerController = MapPickerController();
List<double?> lat = [];
List<double?> lng = [];

//double? lat;
//double? lng;
class EventForm extends StatefulWidget {
  const EventForm({super.key});
  final String title = 'Tick-It';
  @override
  State<EventForm> createState() => _EventFormState();
}

class _EventFormState extends State<EventForm> {
  int? eventType = 1;
  int? numberOfDays = 0;
  DateTime? compareStartDate;
  DateTime? compareEndDate;
  DateTime? compareEventDate;
  DateTime? compareCurrentDate;
  TimeOfDay? compareStartTime;
  TimeOfDay? compareEndTime;
  TimeOfDay? compareCurrentTime;

  final _formKey = GlobalKey<FormState>();

  List<String> imagesList = [];
  final title = TextEditingController();
  final organizer = TextEditingController();
  final numberOfDayController = TextEditingController();
  final startDate = TextEditingController();
  final endDate = TextEditingController();

  final List<int?> hybridDayEventType = [];
  final List<TextEditingController> dateofDay = [];
  final List<TextEditingController> startTime = [];
  final List<TextEditingController> endTime = [];
  final List<TextEditingController> pricePerTicket = [];
  final List<TextEditingController> numberOfTickets = [];
  final List<TextEditingController> vipName = [];
  final List<TextEditingController> description = [];
  final List<TextEditingController> eventlink = [];
  final List<TextEditingController> location = [];

  int checkImage = 0;
  List<Map<String, dynamic>> userData = [];

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

  void submitForm() async {
    FocusScope.of(context).unfocus();
    try {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return Column(
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
                    'Creating Event',
                    style: TextStyle(fontSize: 20),
                  ),
                )
              ],
            );
          });

      List<String> loc = [];
      List<String> el = [];
      List<int> not = [];
      List<double> ppt = [];
      List<String> vn = [];
      List<String> des = [];
      List<double> lt = [];
      List<double> ln = [];
      List<String> dod = [];
      List<String> st = [];
      List<String> et = [];
      List<int> hdt = [];

      for (var i = 0; i < numberOfDays!; i++) {
        loc.add(location[i].text);
        el.add(eventlink[i].text);
        not.add(int.parse(numberOfTickets[i].text));
        ppt.add(double.parse(pricePerTicket[i].text));
        vn.add(vipName[i].text);
        des.add(description[i].text);
        lt.add(lat[i]!);
        ln.add(lng[i]!);
        dod.add(dateofDay[i].text);
        st.add(startTime[i].text);
        et.add(endTime[i].text);
        hdt.add(hybridDayEventType[i]!);
      }
      Response response = await post(
          Uri.parse('http://' + API.IP + '/api/create_event'),
          headers: {
            'Authorization': 'Bearer ' + userData[0]['token'],
          },
          body: {
            'title': title.text,
            'eventType': eventType.toString(),
            'organizer': organizer.text,
            'startDate': startDate.text,
            'endDate': endDate.text,
            'imagesList[]': imagesList.toString(),
            'numberOfDays': numberOfDays.toString(),
            'dataofDays[][location]': loc.toString(),
            'dataofDays[][eventlink]': el.toString(),
            'dataofDays[][numberOfTickets]': not.toString(),
            'dataofDays[][pricePerTicket]': ppt.toString(),
            'dataofDays[][vipName]': vn.toString(),
            'dataofDays[][description]': des.toString(),
            'dataofDays[][lat]': lt.toString(),
            'dataofDays[][lng]': ln.toString(),
            'dataofDays[][dateOfDay]': dod.toString(),
            'dataofDays[][startTime]': st.toString(),
            'dataofDays[][endTime]': et.toString(),
            'dataofDays[][type]': hdt.toString(),
          });

      /*EasyLoading.showToast('Test: ' + response.body,
            toastPosition: EasyLoadingToastPosition.bottom);*/

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        EasyLoading.showToast('Event successfully created',
            toastPosition: EasyLoadingToastPosition.bottom);

        Navigator.of(context).pop();
        Navigator.of(context).pop();
      } else {
        /*EasyLoading.showToast('Error: ' + response.statusCode.toString(),
            toastPosition: EasyLoadingToastPosition.bottom);*/
        Navigator.of(context).pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
      ));
    }
  }

  Future<void> _showPickImageDialog() async {
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Choose from Gallery'),
                onTap: () async {
                  final picker = ImagePicker();
                  final List<XFile> pickedFile = await picker.pickMultiImage(
                    imageQuality: 50,
                  );
                  if (pickedFile != null) {
                    setState(() {
                      for (var i = 0; i < pickedFile.length; i++) {
                        imagesList.add(base64Encode(
                            File(pickedFile[i].path).readAsBytesSync()));
                      }
                    });
                  }
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Take a Picture'),
                onTap: () async {
                  final picker = ImagePicker();
                  final pickedFile = await picker.getImage(
                    source: ImageSource.camera,
                    imageQuality: 50,
                  );
                  if (pickedFile != null) {
                    setState(() {
                      imagesList.add(base64Encode(
                          File(pickedFile.path).readAsBytesSync()));
                    });
                  }
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Container(
        child: Scaffold(
          drawer: NavBar(),
          appBar: AppBar(
            title: Text(widget.title),
            centerTitle: true,
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Colors.blue[900],
              statusBarBrightness: Brightness.dark,
            ),
          ),
          bottomNavigationBar: Container(
            child: ButtonBar(
              children: [
                SizedBox(
                  width: double.maxFinite,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();

                      if (imagesList.isEmpty) {
                        setState(() {
                          checkImage = 1;
                        });
                      } else {
                        setState(() {
                          checkImage = 2;
                        });
                      }
                      if (_formKey.currentState!.validate() &&
                          !imagesList.isEmpty) {
                        submitForm();
                        setState(() {});
                      } else {
                        EasyLoading.showToast("Form not filled or correct",
                            toastPosition: EasyLoadingToastPosition.bottom);
                      }
                    },
                    child: Text(
                      'Submit',
                    ),
                    style: ElevatedButton.styleFrom(
                      textStyle: TextStyle(fontSize: 25),
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          body: Container(
            child: ListView(
              children: [
                Container(
                    child: imagesList.isEmpty
                        ? null
                        : Container(
                            height: 130,
                            margin: const EdgeInsets.all(9.0),
                            child: Align(
                              alignment: Alignment.center,
                              child: GridView.count(
                                shrinkWrap: true,
                                crossAxisCount: 1,
                                scrollDirection: Axis.horizontal,
                                children: imagesList
                                    .map(
                                      (e) => Image.memory(base64Decode(e)),
                                    )
                                    .toList(),
                              ),
                            ))),
                ButtonBar(
                  children: [
                    SizedBox(
                      height: 50,
                      width: double.maxFinite,
                      child: OutlinedButton(
                        child: Text(
                          "Select an Image",
                          style: TextStyle(fontSize: 20),
                        ),
                        style: checkImage == 1
                            ? OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                side: const BorderSide(
                                    color: Color.fromARGB(255, 198, 40, 40)))
                            : OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                side: const BorderSide(color: Colors.blue)),
                        onPressed: () {
                          _showPickImageDialog();
                        },
                      ),
                    ),
                  ],
                ),
                Container(
                  child: (checkImage == 0 || checkImage == 2)
                      ? null
                      : Container(
                          margin: const EdgeInsets.only(left: 18, bottom: 5),
                          child: Text(
                            "Please select an image",
                            style:
                                TextStyle(color: Colors.red[800], fontSize: 12),
                          )),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      padding: EdgeInsets.all(7),
                      child: TextFormField(
                        controller: title,
                        decoration: InputDecoration(
                          isDense: true,
                          labelText: 'Title',
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.blue)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.blue)),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.blue)),
                          errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.red)),
                        ),
                        style: TextStyle(
                          fontSize: 20,
                        ),
                        validator: (title) {
                          if (title == null || title.isEmpty) {
                            return 'Please enter event title';
                          }
                          return null;
                        },
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(7),
                      child: TextFormField(
                        controller: organizer,
                        decoration: InputDecoration(
                          isDense: true,
                          labelText: 'Organizer',
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.blue)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.blue)),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.blue)),
                          errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.red)),
                        ),
                        style: TextStyle(
                          fontSize: 20,
                        ),
                        validator: (title) {
                          if (title == null || title.isEmpty) {
                            return 'Please enter organizer name';
                          }
                          return null;
                        },
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(7),
                      child: TextFormField(
                        controller: numberOfDayController,
                        decoration: InputDecoration(
                          isDense: true,
                          labelText: 'Number Of Event Days',
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.blue)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.blue)),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.blue)),
                          errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.red)),
                        ),
                        style: TextStyle(
                          fontSize: 20,
                        ),
                        keyboardType: TextInputType.number,
                        validator: (numberOfDayController) {
                          final bool numberOfDayControllerValid =
                              RegExp(r'^[0-9]+$')
                                  .hasMatch(numberOfDayController!);
                          if (numberOfDayController == null ||
                              numberOfDayController.isEmpty) {
                            return 'Please enter number of event days';
                          } else if (numberOfDays == 0) {
                            return 'Event days can not be zero';
                          } else if (numberOfDays! > 5) {
                            return 'Please enter less days';
                          } 
                          else if (!numberOfDayControllerValid) {
                            return 'Please enter a number';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            numberOfDays =
                                int.parse(numberOfDayController.text);

                            for (var i = 0; i < numberOfDays!; i++) {
                              hybridDayEventType.add(1);
                              dateofDay.add(TextEditingController());
                              startTime.add(TextEditingController());
                              endTime.add(TextEditingController());
                              pricePerTicket.add(TextEditingController());
                              numberOfTickets.add(TextEditingController());
                              vipName.add(TextEditingController());
                              description.add(TextEditingController());
                              eventlink.add(TextEditingController());
                              location.add(TextEditingController());
                              lat.add(0.0);
                              lng.add(0.0);
                            }
                          });
                        },
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(7),
                      child: TextFormField(
                        controller: startDate,
                        readOnly: true,
                        decoration: InputDecoration(
                          hintText: "DD-MM-YYYY",
                          isDense: true,
                          labelText: 'Event Start Date',
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.blue)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.blue)),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.blue)),
                          errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.red)),
                        ),
                        style: TextStyle(
                          fontSize: 20,
                        ),
                        validator: (startDate) {
                          final bool startDateValid =
                              RegExp(r"^\d{2}(\s|-)\d{2}(\s|-)\d{4}$")
                                  .hasMatch(startDate!);
                          if (startDate == null || startDate.isEmpty) {
                            return 'Please select starting date';
                          } else if (!startDateValid) {
                            return 'Please select a correct date';
                          } /*else if (compareStartDate!.isBefore(compareCurrentDate!)) {
                            return 'Please select a date today or after';
                          }*/
                          return null;
                        },
                        onTap: () async {
                          DateTime? pickedStartDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(
                                  2000), //DateTime.now() - not to allow to choose before today.
                              lastDate: DateTime(2101));

                          if (pickedStartDate != null) {
                            String formattedDate = DateFormat('dd-MM-yyyy')
                                .format(pickedStartDate);
                            setState(() {
                              startDate.text =
                                  formattedDate; //set output date to TextField value.
                              compareStartDate = pickedStartDate;
                              compareCurrentDate = DateTime.now();
                            });
                          }
                        },
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(7),
                      child: TextFormField(
                        controller: endDate,
                        readOnly: true,
                        decoration: InputDecoration(
                          hintText: "DD-MM-YYYY",
                          isDense: true,
                          labelText: 'Event End Date',
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.blue)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.blue)),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.blue)),
                          errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.red)),
                        ),
                        style: TextStyle(
                          fontSize: 20,
                        ),
                        validator: (endDate) {
                          final bool endDateValid =
                              RegExp(r"^\d{2}(\s|-)\d{2}(\s|-)\d{4}$")
                                  .hasMatch(endDate!);

                          if (endDate == null || endDate.isEmpty) {
                            return 'Please select ending date';
                          } else if (!endDateValid) {
                            return 'Please select a correct date';
                          } else if (compareEndDate!
                              .isBefore(compareStartDate!)) {
                            return 'Please select a date after start date';
                          }
                          return null;
                        },
                        onTap: () async {
                          DateTime? pickedEndDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(
                                  2000), //DateTime.now() - not to allow to choose before today.
                              lastDate: DateTime(2101));

                          if (pickedEndDate != null) {
                            String formattedDate =
                                DateFormat('dd-MM-yyyy').format(pickedEndDate);
                            setState(() {
                              endDate.text =
                                  formattedDate; //set output date to TextField value.
                              compareEndDate = pickedEndDate;
                            });
                          }
                        },
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(7),
                      child: DropdownButtonFormField(
                        value: eventType,
                        items: [
                          DropdownMenuItem(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: Colors.black.withOpacity(0.6),
                                ),
                                Text(" Physical Event"),
                              ],
                            ),
                            value: 1,
                          ),
                          DropdownMenuItem(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.wifi,
                                  color: Colors.black.withOpacity(0.6),
                                ),
                                Text(" Online Event"),
                              ],
                            ),
                            value: 2,
                          ),
                          DropdownMenuItem(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.present_to_all_outlined,
                                  color: Colors.black.withOpacity(0.6),
                                ),
                                Text(" Hybrid Event"),
                              ],
                            ),
                            value: 3,
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            eventType = value;
                          });
                        },
                        decoration: InputDecoration(
                          isDense: true,
                          labelText: 'Select Event Type',
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.blue)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.blue)),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.blue)),
                          errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.red)),
                        ),
                        borderRadius: BorderRadius.circular(10),
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black.withOpacity(0.6),
                        ),
                      ),
                    ),
                    if (numberOfDays == 0) ...[
                      Container(
                          margin: const EdgeInsets.only(top: 10),
                          child: Text(
                            "Event number of days to add form",
                            style:
                                TextStyle(color: Colors.red[800], fontSize: 15),
                          )),
                    ],
                    Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          if (eventType == 1) ...[
                            for (var i = 0; i < numberOfDays!; i++)
                              Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Text(
                                      'Day ' + (i + 1).toString(),
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.black.withOpacity(0.6),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(7),
                                      child: TextFormField(
                                        controller: pricePerTicket[i],
                                        decoration: InputDecoration(
                                          prefixText: "Rs.",
                                          isDense: true,
                                          labelText: 'Price per Ticket',
                                          enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                  color: Colors.blue)),
                                          focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                  color: Colors.blue)),
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                  color: Colors.blue)),
                                          errorBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                  color: Colors.red)),
                                        ),
                                        style: TextStyle(
                                          fontSize: 20,
                                        ),
                                        keyboardType: TextInputType.number,
                                        validator: (pricePerTicket) {
                                          final bool priceValid = RegExp(
                                                  r'^(?:[1-9]\d*|0)?(?:\.\d+)?$')
                                              .hasMatch(pricePerTicket!);
                                          if (pricePerTicket == null ||
                                              pricePerTicket.isEmpty) {
                                            return 'Please enter a price for the ticket';
                                          } else if (!priceValid) {
                                            return 'Please enter a number';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(7),
                                      child: TextFormField(
                                        controller: numberOfTickets[i],
                                        decoration: InputDecoration(
                                          isDense: true,
                                          labelText: 'Number of Tickets',
                                          enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                  color: Colors.blue)),
                                          focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                  color: Colors.blue)),
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                  color: Colors.blue)),
                                          errorBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                  color: Colors.red)),
                                        ),
                                        style: TextStyle(
                                          fontSize: 20,
                                        ),
                                        keyboardType: TextInputType.number,
                                        validator: (numberOfTickets) {
                                          final bool ticketValid =
                                              RegExp(r'^[0-9]+$')
                                                  .hasMatch(numberOfTickets!);
                                          if (numberOfTickets == null ||
                                              numberOfTickets.isEmpty) {
                                            return 'Please enter number of tickets';
                                          } else if (!ticketValid) {
                                            return 'Please enter a number';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(7),
                                      child: TextFormField(
                                        controller: dateofDay[i],
                                        readOnly: true,
                                        decoration: InputDecoration(
                                          hintText: "DD-MM-YYYY",
                                          isDense: true,
                                          labelText: 'Event Date',
                                          enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                  color: Colors.blue)),
                                          focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                  color: Colors.blue)),
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                  color: Colors.blue)),
                                          errorBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                  color: Colors.red)),
                                        ),
                                        style: TextStyle(
                                          fontSize: 20,
                                        ),
                                        validator: (dateofDay) {
                                          final bool dateofDayValid = RegExp(
                                                  r"^\d{2}(\s|-)\d{2}(\s|-)\d{4}$")
                                              .hasMatch(dateofDay!);

                                          if (dateofDay == null ||
                                              dateofDay.isEmpty) {
                                            return 'Please select ending date';
                                          } else if (!dateofDayValid) {
                                            return 'Please select a correct date';
                                          } else if (compareEventDate!.isBefore(
                                                  compareStartDate!) ||
                                              compareEventDate!
                                                  .isAfter(compareEndDate!)) {
                                            return 'Please select a date in rage of start and end date';
                                          }
                                          return null;
                                        },
                                        onTap: () async {
                                          DateTime? pickedEventDate =
                                              await showDatePicker(
                                                  context: context,
                                                  initialDate: DateTime.now(),
                                                  firstDate: DateTime(
                                                      2000), //DateTime.now() - not to allow to choose before today.
                                                  lastDate: DateTime(2101));

                                          if (pickedEventDate != null) {
                                            String formattedDate =
                                                DateFormat('dd-MM-yyyy')
                                                    .format(pickedEventDate);
                                            setState(() {
                                              dateofDay[i].text =
                                                  formattedDate; //set output date to TextField value.
                                              compareEventDate =
                                                  pickedEventDate;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(7),
                                      child: TextFormField(
                                        controller: startTime[i],
                                        readOnly: true,
                                        decoration: InputDecoration(
                                          hintText: "HH:MM:SS",
                                          isDense: true,
                                          labelText: 'Event Start Time',
                                          enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                  color: Colors.blue)),
                                          focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                  color: Colors.blue)),
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                  color: Colors.blue)),
                                          errorBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                  color: Colors.red)),
                                        ),
                                        style: TextStyle(
                                          fontSize: 20,
                                        ),
                                        validator: (startTime) {
                                          final bool startTimeValid = RegExp(
                                                  r"^\d{2}(\s|:)\d{2}(\s|:)\d{2}$")
                                              .hasMatch(startTime!);

                                          if (startTime == null ||
                                              startTime.isEmpty) {
                                            return 'Please select event start time';
                                          }
                                          return null;
                                        },
                                        onTap: () async {
                                          TimeOfDay? pickedStartTime =
                                              await showTimePicker(
                                            initialTime: TimeOfDay.now(),
                                            context: context,
                                          );
                                          if (pickedStartTime != null) {
                                            print(pickedStartTime.format(
                                                context)); //output 10:51 PM
                                            DateTime parsedTime =
                                                DateFormat.jm().parse(
                                                    pickedStartTime
                                                        .format(context)
                                                        .toString());
                                            String formattedTime =
                                                DateFormat('HH:mm:ss')
                                                    .format(parsedTime);

                                            setState(() {
                                              startTime[i].text =
                                                  formattedTime; //set the value of text field.
                                              compareStartTime =
                                                  pickedStartTime;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(7),
                                      child: TextFormField(
                                        controller: endTime[i],
                                        readOnly: true,
                                        decoration: InputDecoration(
                                          hintText: "HH:MM:SS",
                                          isDense: true,
                                          labelText: 'Event End Time',
                                          enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                  color: Colors.blue)),
                                          focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                  color: Colors.blue)),
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                  color: Colors.blue)),
                                          errorBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                  color: Colors.red)),
                                        ),
                                        style: TextStyle(
                                          fontSize: 20,
                                        ),
                                        validator: (endTime) {
                                          final bool endTimeValid = RegExp(
                                                  r"^\d{2}(\s|:)\d{2}(\s|:)\d{2}$")
                                              .hasMatch(endTime!);

                                          int startTimeInt =
                                              (compareStartTime!.hour * 60 +
                                                      compareStartTime!
                                                          .minute) *
                                                  60;
                                          int EndTimeInt =
                                              (compareEndTime!.hour * 60 +
                                                      compareEndTime!.minute) *
                                                  60;
                                          if (endTime == null ||
                                              endTime.isEmpty) {
                                            return 'Please select event start time';
                                          } else if (startTimeInt >=
                                              EndTimeInt) {
                                            return 'Please select a end time after start time';
                                          }
                                          return null;
                                        },
                                        onTap: () async {
                                          TimeOfDay? pickedEndTime =
                                              await showTimePicker(
                                            initialTime: TimeOfDay.now(),
                                            context: context,
                                          );
                                          if (pickedEndTime != null) {
                                            print(pickedEndTime.format(
                                                context)); //output 10:51 PM
                                            DateTime parsedTime =
                                                DateFormat.jm().parse(
                                                    pickedEndTime
                                                        .format(context)
                                                        .toString());
                                            String formattedTime =
                                                DateFormat('HH:mm:ss')
                                                    .format(parsedTime);

                                            setState(() {
                                              endTime[i].text =
                                                  formattedTime; //set the value of text field.
                                              compareEndTime = pickedEndTime;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(7),
                                      child: TextFormField(
                                        controller: vipName[i],
                                        decoration: InputDecoration(
                                          isDense: true,
                                          labelText: 'VIP Name',
                                          enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                  color: Colors.blue)),
                                          focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                  color: Colors.blue)),
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                  color: Colors.blue)),
                                          errorBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                  color: Colors.red)),
                                        ),
                                        style: TextStyle(
                                          fontSize: 20,
                                        ),
                                        validator: (vipName) {
                                          if (vipName == null ||
                                              vipName.isEmpty) {
                                            return 'Please enter event vip name';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(7),
                                      child: TextFormField(
                                        controller: description[i],
                                        decoration: InputDecoration(
                                          isDense: true,
                                          labelText: 'Description',
                                          enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                  color: Colors.blue)),
                                          focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                  color: Colors.blue)),
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                  color: Colors.blue)),
                                          errorBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                  color: Colors.red)),
                                        ),
                                        style: TextStyle(
                                          fontSize: 20,
                                        ),
                                        validator: (description) {
                                          if (description == null ||
                                              description.isEmpty) {
                                            return 'Please enter event description';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(7),
                                      child: TextFormField(
                                        controller: location[i],
                                        decoration: InputDecoration(
                                          isDense: true,
                                          labelText: 'Location',
                                          enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                  color: Colors.blue)),
                                          focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                  color: Colors.blue)),
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                  color: Colors.blue)),
                                          errorBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                  color: Colors.red)),
                                        ),
                                        style: TextStyle(
                                          fontSize: 20,
                                        ),
                                        validator: (Location) {
                                          if (Location == null ||
                                              Location.isEmpty) {
                                            return 'Please enter event location';
                                          } else {
                                            eventlink[i].text = "";
                                            hybridDayEventType[i] = 1;
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(7),
                                      child: Container(
                                        child: LimitedBox(
                                          maxHeight: 250,
                                          child: LocationPicker(
                                            index: i,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ]),
                          ] else if (eventType == 2) ...[
                            for (var i = 0; i < numberOfDays!; i++)
                              Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Text(
                                      'Day ' + (i + 1).toString(),
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.black.withOpacity(0.6),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(7),
                                      child: TextFormField(
                                        controller: pricePerTicket[i],
                                        decoration: InputDecoration(
                                          prefixText: "Rs.",
                                          isDense: true,
                                          labelText: 'Price per Ticket',
                                          enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                  color: Colors.blue)),
                                          focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                  color: Colors.blue)),
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                  color: Colors.blue)),
                                          errorBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                  color: Colors.red)),
                                        ),
                                        style: TextStyle(
                                          fontSize: 20,
                                        ),
                                        keyboardType: TextInputType.number,
                                        validator: (pricePerTicket) {
                                          final bool priceValid = RegExp(
                                                  r'^(?:[1-9]\d*|0)?(?:\.\d+)?$')
                                              .hasMatch(pricePerTicket!);
                                          if (pricePerTicket == null ||
                                              pricePerTicket.isEmpty) {
                                            return 'Please enter a price for the ticket';
                                          } else if (!priceValid) {
                                            return 'Please enter a number';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(7),
                                      child: TextFormField(
                                        controller: numberOfTickets[i],
                                        decoration: InputDecoration(
                                          isDense: true,
                                          labelText: 'Number of Tickets',
                                          enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                  color: Colors.blue)),
                                          focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                  color: Colors.blue)),
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                  color: Colors.blue)),
                                          errorBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                  color: Colors.red)),
                                        ),
                                        style: TextStyle(
                                          fontSize: 20,
                                        ),
                                        keyboardType: TextInputType.number,
                                        validator: (numberOfTickets) {
                                          final bool ticketValid =
                                              RegExp(r'^[0-9]+$')
                                                  .hasMatch(numberOfTickets!);
                                          if (numberOfTickets == null ||
                                              numberOfTickets.isEmpty) {
                                            return 'Please enter number of tickets';
                                          } else if (!ticketValid) {
                                            return 'Please enter a number';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(7),
                                      child: TextFormField(
                                        controller: dateofDay[i],
                                        readOnly: true,
                                        decoration: InputDecoration(
                                          hintText: "DD-MM-YYYY",
                                          isDense: true,
                                          labelText: 'Event Date',
                                          enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                  color: Colors.blue)),
                                          focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                  color: Colors.blue)),
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                  color: Colors.blue)),
                                          errorBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                  color: Colors.red)),
                                        ),
                                        style: TextStyle(
                                          fontSize: 20,
                                        ),
                                        validator: (dateofDay) {
                                          final bool dateofDayValid = RegExp(
                                                  r"^\d{2}(\s|-)\d{2}(\s|-)\d{4}$")
                                              .hasMatch(dateofDay!);

                                          if (dateofDay == null ||
                                              dateofDay.isEmpty) {
                                            return 'Please select ending date';
                                          } else if (!dateofDayValid) {
                                            return 'Please select a correct date';
                                          } else if (compareEventDate!.isBefore(
                                                  compareStartDate!) ||
                                              compareEventDate!
                                                  .isAfter(compareEndDate!)) {
                                            return 'Please select a date in rage of start and end date';
                                          }
                                          return null;
                                        },
                                        onTap: () async {
                                          DateTime? pickedEventDate =
                                              await showDatePicker(
                                                  context: context,
                                                  initialDate: DateTime.now(),
                                                  firstDate: DateTime(
                                                      2000), //DateTime.now() - not to allow to choose before today.
                                                  lastDate: DateTime(2101));

                                          if (pickedEventDate != null) {
                                            String formattedDate =
                                                DateFormat('dd-MM-yyyy')
                                                    .format(pickedEventDate);
                                            setState(() {
                                              dateofDay[i].text =
                                                  formattedDate; //set output date to TextField value.
                                              compareEventDate =
                                                  pickedEventDate;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(7),
                                      child: TextFormField(
                                        controller: startTime[i],
                                        readOnly: true,
                                        decoration: InputDecoration(
                                          hintText: "HH:MM:SS",
                                          isDense: true,
                                          labelText: 'Event Start Time',
                                          enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                  color: Colors.blue)),
                                          focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                  color: Colors.blue)),
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                  color: Colors.blue)),
                                          errorBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                  color: Colors.red)),
                                        ),
                                        style: TextStyle(
                                          fontSize: 20,
                                        ),
                                        validator: (startTime) {
                                          final bool startTimeValid = RegExp(
                                                  r"^\d{2}(\s|:)\d{2}(\s|:)\d{2}$")
                                              .hasMatch(startTime!);

                                          if (startTime == null ||
                                              startTime.isEmpty) {
                                            return 'Please select event start time';
                                          }
                                          return null;
                                        },
                                        onTap: () async {
                                          TimeOfDay? pickedStartTime =
                                              await showTimePicker(
                                            initialTime: TimeOfDay.now(),
                                            context: context,
                                          );
                                          if (pickedStartTime != null) {
                                            print(pickedStartTime.format(
                                                context)); //output 10:51 PM
                                            DateTime parsedTime =
                                                DateFormat.jm().parse(
                                                    pickedStartTime
                                                        .format(context)
                                                        .toString());
                                            String formattedTime =
                                                DateFormat('HH:mm:ss')
                                                    .format(parsedTime);

                                            setState(() {
                                              startTime[i].text =
                                                  formattedTime; //set the value of text field.
                                              compareStartTime =
                                                  pickedStartTime;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(7),
                                      child: TextFormField(
                                        controller: endTime[i],
                                        readOnly: true,
                                        decoration: InputDecoration(
                                          hintText: "HH:MM:SS",
                                          isDense: true,
                                          labelText: 'Event End Time',
                                          enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                  color: Colors.blue)),
                                          focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                  color: Colors.blue)),
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                  color: Colors.blue)),
                                          errorBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                  color: Colors.red)),
                                        ),
                                        style: TextStyle(
                                          fontSize: 20,
                                        ),
                                        validator: (endTime) {
                                          final bool endTimeValid = RegExp(
                                                  r"^\d{2}(\s|:)\d{2}(\s|:)\d{2}$")
                                              .hasMatch(endTime!);

                                          int startTimeInt =
                                              (compareStartTime!.hour * 60 +
                                                      compareStartTime!
                                                          .minute) *
                                                  60;
                                          int EndTimeInt =
                                              (compareEndTime!.hour * 60 +
                                                      compareEndTime!.minute) *
                                                  60;
                                          if (endTime == null ||
                                              endTime.isEmpty) {
                                            return 'Please select event start time';
                                          } else if (startTimeInt >=
                                              EndTimeInt) {
                                            return 'Please select a end time after start time';
                                          }
                                          return null;
                                        },
                                        onTap: () async {
                                          TimeOfDay? pickedEndTime =
                                              await showTimePicker(
                                            initialTime: TimeOfDay.now(),
                                            context: context,
                                          );
                                          if (pickedEndTime != null) {
                                            print(pickedEndTime.format(
                                                context)); //output 10:51 PM
                                            DateTime parsedTime =
                                                DateFormat.jm().parse(
                                                    pickedEndTime
                                                        .format(context)
                                                        .toString());
                                            String formattedTime =
                                                DateFormat('HH:mm:ss')
                                                    .format(parsedTime);

                                            setState(() {
                                              endTime[i].text =
                                                  formattedTime; //set the value of text field.
                                              compareEndTime = pickedEndTime;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(7),
                                      child: TextFormField(
                                        controller: vipName[i],
                                        decoration: InputDecoration(
                                          isDense: true,
                                          labelText: 'VIP Name',
                                          enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                  color: Colors.blue)),
                                          focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                  color: Colors.blue)),
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                  color: Colors.blue)),
                                          errorBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                  color: Colors.red)),
                                        ),
                                        style: TextStyle(
                                          fontSize: 20,
                                        ),
                                        validator: (vipName) {
                                          if (vipName == null ||
                                              vipName.isEmpty) {
                                            return 'Please enter event vip name';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(7),
                                      child: TextFormField(
                                        controller: description[i],
                                        decoration: InputDecoration(
                                          isDense: true,
                                          labelText: 'Description',
                                          enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                  color: Colors.blue)),
                                          focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                  color: Colors.blue)),
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                  color: Colors.blue)),
                                          errorBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                  color: Colors.red)),
                                        ),
                                        style: TextStyle(
                                          fontSize: 20,
                                        ),
                                        validator: (description) {
                                          if (description == null ||
                                              description.isEmpty) {
                                            return 'Please enter event description';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(7),
                                      child: TextFormField(
                                        controller: eventlink[i],
                                        decoration: InputDecoration(
                                          isDense: true,
                                          labelText: 'Event Link',
                                          enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                  color: Colors.blue)),
                                          focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                  color: Colors.blue)),
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                  color: Colors.blue)),
                                          errorBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                  color: Colors.red)),
                                        ),
                                        style: TextStyle(
                                          fontSize: 20,
                                        ),
                                        validator: (eventlink) {
                                          if (eventlink == null ||
                                              eventlink.isEmpty) {
                                            return 'Please enter event link';
                                          } else {
                                            location[i].text = "";
                                            lat[i] = 0.0;
                                            lng[i] = 0.0;
                                            hybridDayEventType[i] = 2;
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ])
                          ] else ...[
                            for (var i = 0; i < numberOfDays!; i++)
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                    'Day ' + (i + 1).toString(),
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.black.withOpacity(0.6),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(7),
                                    child: DropdownButtonFormField(
                                      value: hybridDayEventType[i],
                                      items: [
                                        DropdownMenuItem(
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.location_on,
                                                color: Colors.black
                                                    .withOpacity(0.6),
                                              ),
                                              Text(" Physical Event"),
                                            ],
                                          ),
                                          value: 1,
                                        ),
                                        DropdownMenuItem(
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.wifi,
                                                color: Colors.black
                                                    .withOpacity(0.6),
                                              ),
                                              Text(" Online Event"),
                                            ],
                                          ),
                                          value: 2,
                                        ),
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          hybridDayEventType[i] = value;
                                        });
                                      },
                                      decoration: InputDecoration(
                                        isDense: true,
                                        labelText: 'Select Day Event Type',
                                        enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide:
                                                BorderSide(color: Colors.blue)),
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide:
                                                BorderSide(color: Colors.blue)),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide:
                                                BorderSide(color: Colors.blue)),
                                        errorBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide:
                                                BorderSide(color: Colors.red)),
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.black.withOpacity(0.6),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(7),
                                    child: TextFormField(
                                      controller: pricePerTicket[i],
                                      decoration: InputDecoration(
                                        prefixText: "Rs.",
                                        isDense: true,
                                        labelText: 'Price per Ticket',
                                        enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide:
                                                BorderSide(color: Colors.blue)),
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide:
                                                BorderSide(color: Colors.blue)),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide:
                                                BorderSide(color: Colors.blue)),
                                        errorBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide:
                                                BorderSide(color: Colors.red)),
                                      ),
                                      style: TextStyle(
                                        fontSize: 20,
                                      ),
                                      keyboardType: TextInputType.number,
                                      validator: (pricePerTicket) {
                                        final bool priceValid = RegExp(
                                                r'^(?:[1-9]\d*|0)?(?:\.\d+)?$')
                                            .hasMatch(pricePerTicket!);
                                        if (pricePerTicket == null ||
                                            pricePerTicket.isEmpty) {
                                          return 'Please enter a price for the ticket';
                                        } else if (!priceValid) {
                                          return 'Please enter a number';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(7),
                                    child: TextFormField(
                                      controller: numberOfTickets[i],
                                      decoration: InputDecoration(
                                        isDense: true,
                                        labelText: 'Number of Tickets',
                                        enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide:
                                                BorderSide(color: Colors.blue)),
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide:
                                                BorderSide(color: Colors.blue)),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide:
                                                BorderSide(color: Colors.blue)),
                                        errorBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide:
                                                BorderSide(color: Colors.red)),
                                      ),
                                      style: TextStyle(
                                        fontSize: 20,
                                      ),
                                      keyboardType: TextInputType.number,
                                      validator: (numberOfTickets) {
                                        final bool ticketValid =
                                            RegExp(r'^[0-9]+$')
                                                .hasMatch(numberOfTickets!);
                                        if (numberOfTickets == null ||
                                            numberOfTickets.isEmpty) {
                                          return 'Please enter number of tickets';
                                        } else if (!ticketValid) {
                                          return 'Please enter a number';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(7),
                                    child: TextFormField(
                                      controller: dateofDay[i],
                                      readOnly: true,
                                      decoration: InputDecoration(
                                        hintText: "DD-MM-YYYY",
                                        isDense: true,
                                        labelText: 'Event Date',
                                        enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide:
                                                BorderSide(color: Colors.blue)),
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide:
                                                BorderSide(color: Colors.blue)),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide:
                                                BorderSide(color: Colors.blue)),
                                        errorBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide:
                                                BorderSide(color: Colors.red)),
                                      ),
                                      style: TextStyle(
                                        fontSize: 20,
                                      ),
                                      validator: (dateofDay) {
                                        final bool dateofDayValid = RegExp(
                                                r"^\d{2}(\s|-)\d{2}(\s|-)\d{4}$")
                                            .hasMatch(dateofDay!);

                                        if (dateofDay == null ||
                                            dateofDay.isEmpty) {
                                          return 'Please select ending date';
                                        } else if (!dateofDayValid) {
                                          return 'Please select a correct date';
                                        } else if (compareEventDate!
                                                .isBefore(compareStartDate!) ||
                                            compareEventDate!
                                                .isAfter(compareEndDate!)) {
                                          return 'Please select a date in rage of start and end date';
                                        }
                                        return null;
                                      },
                                      onTap: () async {
                                        DateTime? pickedEventDate =
                                            await showDatePicker(
                                                context: context,
                                                initialDate: DateTime.now(),
                                                firstDate: DateTime(
                                                    2000), //DateTime.now() - not to allow to choose before today.
                                                lastDate: DateTime(2101));

                                        if (pickedEventDate != null) {
                                          String formattedDate =
                                              DateFormat('dd-MM-yyyy')
                                                  .format(pickedEventDate);
                                          setState(() {
                                            dateofDay[i].text =
                                                formattedDate; //set output date to TextField value.
                                            compareEventDate = pickedEventDate;
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(7),
                                    child: TextFormField(
                                      controller: startTime[i],
                                      readOnly: true,
                                      decoration: InputDecoration(
                                        hintText: "HH:MM:SS",
                                        isDense: true,
                                        labelText: 'Event Start Time',
                                        enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide:
                                                BorderSide(color: Colors.blue)),
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide:
                                                BorderSide(color: Colors.blue)),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide:
                                                BorderSide(color: Colors.blue)),
                                        errorBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide:
                                                BorderSide(color: Colors.red)),
                                      ),
                                      style: TextStyle(
                                        fontSize: 20,
                                      ),
                                      validator: (startTime) {
                                        final bool startTimeValid = RegExp(
                                                r"^\d{2}(\s|:)\d{2}(\s|:)\d{2}$")
                                            .hasMatch(startTime!);

                                        if (startTime == null ||
                                            startTime.isEmpty) {
                                          return 'Please select event start time';
                                        }
                                        return null;
                                      },
                                      onTap: () async {
                                        TimeOfDay? pickedStartTime =
                                            await showTimePicker(
                                          initialTime: TimeOfDay.now(),
                                          context: context,
                                        );
                                        if (pickedStartTime != null) {
                                          print(pickedStartTime.format(
                                              context)); //output 10:51 PM
                                          DateTime parsedTime = DateFormat.jm()
                                              .parse(pickedStartTime
                                                  .format(context)
                                                  .toString());
                                          String formattedTime =
                                              DateFormat('HH:mm:ss')
                                                  .format(parsedTime);

                                          setState(() {
                                            startTime[i].text =
                                                formattedTime; //set the value of text field.
                                            compareStartTime = pickedStartTime;
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(7),
                                    child: TextFormField(
                                      controller: endTime[i],
                                      readOnly: true,
                                      decoration: InputDecoration(
                                        hintText: "HH:MM:SS",
                                        isDense: true,
                                        labelText: 'Event End Time',
                                        enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide:
                                                BorderSide(color: Colors.blue)),
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide:
                                                BorderSide(color: Colors.blue)),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide:
                                                BorderSide(color: Colors.blue)),
                                        errorBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide:
                                                BorderSide(color: Colors.red)),
                                      ),
                                      style: TextStyle(
                                        fontSize: 20,
                                      ),
                                      validator: (endTime) {
                                        final bool endTimeValid = RegExp(
                                                r"^\d{2}(\s|:)\d{2}(\s|:)\d{2}$")
                                            .hasMatch(endTime!);

                                        int startTimeInt =
                                            (compareStartTime!.hour * 60 +
                                                    compareStartTime!.minute) *
                                                60;
                                        int EndTimeInt =
                                            (compareEndTime!.hour * 60 +
                                                    compareEndTime!.minute) *
                                                60;
                                        if (endTime == null ||
                                            endTime.isEmpty) {
                                          return 'Please select event start time';
                                        } else if (startTimeInt >= EndTimeInt) {
                                          return 'Please select a end time after start time';
                                        }
                                        return null;
                                      },
                                      onTap: () async {
                                        TimeOfDay? pickedEndTime =
                                            await showTimePicker(
                                          initialTime: TimeOfDay.now(),
                                          context: context,
                                        );
                                        if (pickedEndTime != null) {
                                          print(pickedEndTime.format(
                                              context)); //output 10:51 PM
                                          DateTime parsedTime = DateFormat.jm()
                                              .parse(pickedEndTime
                                                  .format(context)
                                                  .toString());
                                          String formattedTime =
                                              DateFormat('HH:mm:ss')
                                                  .format(parsedTime);

                                          setState(() {
                                            endTime[i].text =
                                                formattedTime; //set the value of text field.
                                            compareEndTime = pickedEndTime;
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(7),
                                    child: TextFormField(
                                      controller: vipName[i],
                                      decoration: InputDecoration(
                                        isDense: true,
                                        labelText: 'VIP Name',
                                        enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide:
                                                BorderSide(color: Colors.blue)),
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide:
                                                BorderSide(color: Colors.blue)),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide:
                                                BorderSide(color: Colors.blue)),
                                        errorBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide:
                                                BorderSide(color: Colors.red)),
                                      ),
                                      style: TextStyle(
                                        fontSize: 20,
                                      ),
                                      validator: (vipName) {
                                        if (vipName == null ||
                                            vipName.isEmpty) {
                                          return 'Please enter event vip name';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(7),
                                    child: TextFormField(
                                      controller: description[i],
                                      decoration: InputDecoration(
                                        isDense: true,
                                        labelText: 'Description',
                                        enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide:
                                                BorderSide(color: Colors.blue)),
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide:
                                                BorderSide(color: Colors.blue)),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide:
                                                BorderSide(color: Colors.blue)),
                                        errorBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide:
                                                BorderSide(color: Colors.red)),
                                      ),
                                      style: TextStyle(
                                        fontSize: 20,
                                      ),
                                      validator: (description) {
                                        if (description == null ||
                                            description.isEmpty) {
                                          return 'Please enter event description';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  Container(
                                      child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      if (hybridDayEventType[i] == 1) ...[
                                        Container(
                                          padding: EdgeInsets.all(7),
                                          child: TextFormField(
                                            controller: location[i],
                                            decoration: InputDecoration(
                                              isDense: true,
                                              labelText: 'Location',
                                              enabledBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  borderSide: BorderSide(
                                                      color: Colors.blue)),
                                              focusedBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  borderSide: BorderSide(
                                                      color: Colors.blue)),
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  borderSide: BorderSide(
                                                      color: Colors.blue)),
                                              errorBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  borderSide: BorderSide(
                                                      color: Colors.red)),
                                            ),
                                            style: TextStyle(
                                              fontSize: 20,
                                            ),
                                            validator: (Location) {
                                              if (Location == null ||
                                                  Location.isEmpty) {
                                                return 'Please enter event location';
                                              } else {
                                                eventlink[i].text = "";
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(7),
                                          child: Container(
                                            child: LimitedBox(
                                              maxHeight: 250,
                                              child: LocationPicker(
                                                index: i,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ] else if (hybridDayEventType[i] ==
                                          2) ...[
                                        Container(
                                          padding: EdgeInsets.all(7),
                                          child: TextFormField(
                                            controller: eventlink[i],
                                            decoration: InputDecoration(
                                              isDense: true,
                                              labelText: 'Event Link',
                                              enabledBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  borderSide: BorderSide(
                                                      color: Colors.blue)),
                                              focusedBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  borderSide: BorderSide(
                                                      color: Colors.blue)),
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  borderSide: BorderSide(
                                                      color: Colors.blue)),
                                              errorBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  borderSide: BorderSide(
                                                      color: Colors.red)),
                                            ),
                                            style: TextStyle(
                                              fontSize: 20,
                                            ),
                                            validator: (eventlink) {
                                              if (eventlink == null ||
                                                  eventlink.isEmpty) {
                                                return 'Please enter event link';
                                              } else {
                                                location[i].text = "";
                                                lat[i] = 0.0;
                                                lng[i] = 0.0;
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                      ]
                                    ],
                                  )),
                                ],
                              ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LocationPicker extends StatefulWidget {
  final int index;
  const LocationPicker({Key? key, required this.index}) : super(key: key);

  @override
  _LocationPickerState createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
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
    return Scaffold(
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          GestureDetector(
            onVerticalDragStart: (start) {},
            child: MapPicker(
              // pass icon widget
              iconWidget: Icon(
                Icons.location_pin,
                size: 35,
                color: Color.fromARGB(255, 230, 15, 0),
              ),
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
                    //  camera position
                    initialCameraPosition: CameraPosition(
                      target: LatLng(_currentPosition!.latitude,
                          _currentPosition!.longitude),
                      zoom: 14,
                    ),
                    onMapCreated: (GoogleMapController controller) {
                      _controller.complete(controller);
                      lat[widget.index] = _currentPosition!.latitude;
                      lng[widget.index] = _currentPosition!.longitude;
                    },
                    onCameraMoveStarted: () {
                      // notify map is moving
                      mapPickerController.mapMoving!();
                      textController.text = "checking ...";
                      lat[widget.index] = cameraPosition.target.latitude;
                      lng[widget.index] = cameraPosition.target.longitude;
                    },
                    onCameraMove: (cameraPosition) {
                      this.cameraPosition = cameraPosition;
                      lat[widget.index] = cameraPosition.target.latitude;
                      lng[widget.index] = cameraPosition.target.longitude;
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

                      // update the ui with the address
                      textController.text =
                          '${placemarks.first.name}, ${placemarks.first.administrativeArea}, ${placemarks.first.country}';
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
