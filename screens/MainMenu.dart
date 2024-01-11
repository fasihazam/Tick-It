import 'dart:convert';
import 'dart:io';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firstapp/screens/AboutUs.dart';
import 'package:firstapp/screens/AllTicketHistoryTab.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import '../database/sqlite.dart';
import '../models/User.dart';
import '../cards/EventCard.dart';
import '../tabs/MyEvents.dart';
import 'MyEventsHistory.dart';
import '../tabs/MyTickets.dart';
import 'QRScanner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'LoginScreen.dart';
import '../cards/TicketCard.dart';
import '../cards/EventCard.dart';
import 'EventFormScreen.dart';
import '../tabs/AllTicketTab.dart';
import 'ProfileScreen.dart';
import 'Wallet.dart';
import '../helper/constant.dart' as API;

late bool logincheck;

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
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

  Future<void> logoutAPI() async {
    try {
      Response response = await post(
        Uri.parse('http://' + API.IP + '/api/signout'),
        headers: {
          'Authorization': "Bearer " + userData[0]['token'],
        },
        body: {
          'email': userData[0]['email'],
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Color.fromARGB(255, 227, 246, 255),
      child: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Profile'),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => Profile(
                          loginCheck: logincheck,
                        ),
                      ),
                    );
                  },
                ),
                Divider(
                  thickness: 1.5,
                ),
                ListTile(
                  leading: Icon(Icons.history),
                  title: Text('Ticket History'),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => AllTicketsHistory(
                              loginCheck: logincheck,
                            )));
                  },
                ),
                Divider(
                  thickness: 1,
                ),
                ListTile(
                  leading: Icon(Icons.history),
                  title: Text('Event History'),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => MyEventsHistory(
                              loginCheck: logincheck,
                            )));
                  },
                ),
                Divider(
                  thickness: 1.5,
                ),
                ListTile(
                  leading: Icon(Icons.wallet),
                  title: Text('Wallet'),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => Wallet(
                              loginCheck: logincheck,
                              userToken: logincheck == true
                                  ? userData[0]['token']
                                  : "0",
                            )));
                  },
                ),
                Divider(
                  thickness: 1.5,
                ),
                ListTile(
                  leading: Icon(Icons.groups),
                  title: Text('About Us'),
                  onTap: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => AboutUs()));
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 5, bottom: 10),
              child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        child: Text('version: 1.0.0'),
                      ),
                      ButtonBar(
                        children: [
                          SizedBox(
                            width: double.maxFinite,
                            height: 60,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (logincheck == true) {
                                  await DatabaseHelper.instance.deleteAll();
                                  logoutAPI();
                                }

                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => LoginScreen()));
                              },
                              child: Text(
                                'Logout',
                              ),
                              style: ElevatedButton.styleFrom(
                                textStyle: TextStyle(fontSize: 25),
                                elevation: 6,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )),
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Color.fromARGB(255, 227, 246, 255),
      child: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  title: Text(
                    'Event A tickcet has been added to your tickets',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
                Divider(
                  thickness: 1,
                ),
                ListTile(
                  title: Text(
                    'Event A has started',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MainMenu extends StatefulWidget {
  static String routeName = "";
  final bool loginCheck;
  const MainMenu({super.key, required this.loginCheck});
  final String title = 'Tick-It';

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu>
    with SingleTickerProviderStateMixin {
  final _selectedColor = Colors.blue[300];
  final _unselectedColor = Color(0xff5f6368);
  final _maintabs = [
    Tab(child: Text('Tickets', style: TextStyle(fontSize: 20))),
    Tab(child: Text('Events', style: TextStyle(fontSize: 20))),
  ];

  List<Map<String, dynamic>> userData = [];

  void getUserData() async {
    var users = await DatabaseHelper.instance.users();
    setState(() {
      userData = users;
    });
  }

  @override
  void initState() {
    super.initState();
    getUserData();
    logincheck = widget.loginCheck;
  }

  userRoleAPI() async {
    Response response = await get(
      Uri.parse('http://' + API.IP + '/api/getrole'),
      headers: {
        'Authorization': "Bearer " + userData[0]['token'],
      },
    );

    var userDataUpdate = User(
      id: userData[0]['id'],
      role: int.parse(response.body),
      name: userData[0]['name'],
      email: userData[0]['email'],
      address: userData[0]['address'],
      phone: userData[0]['phone'],
      token: userData[0]['token'],
    );

    await DatabaseHelper.instance.updateUser(userDataUpdate);
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      onWillPop: () async => exit(0),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          drawer: NavBar(),
          //endDrawer: NotificationBar(),
          appBar: AppBar(
            /*actions: [
              Builder(
                builder: (BuildContext context) {
                  return IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () {
                      Scaffold.of(context).openEndDrawer();
                    },
                    tooltip:
                        MaterialLocalizations.of(context).openAppDrawerTooltip,
                  );
                },
              ),
            ],*/
            title: Text(widget.title),
            centerTitle: true,
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Colors.blue[900],
              statusBarBrightness: Brightness.dark,
            ),
          ),
          body: Container(
            child: Column(
              children: [
                Container(
                    child: Container(
                  height: kToolbarHeight,
                  decoration: BoxDecoration(
                    color: _selectedColor,
                  ),
                  child: TabBar(
                    onTap:(value) {
                      userRoleAPI();
                    },
                    indicator: BoxDecoration(
                      color: Colors.white,
                    ),
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.white,
                    tabs: _maintabs,
                  ),
                )),
                Expanded(
                  child: TabBarView(
                    children: [
                      TicketsTab(
                        loginCheck: widget.loginCheck,
                      ),
                      EventsTab(
                        loginCheck: widget.loginCheck,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TicketsTab extends StatefulWidget {
  final loginCheck;
  const TicketsTab({super.key, required this.loginCheck});
  @override
  State<TicketsTab> createState() => _TicketsTabState();
}

class _TicketsTabState extends State<TicketsTab>
    with SingleTickerProviderStateMixin {
  final _selectedColor = Colors.blue[200];
  final _unselectedColor = Color(0xff5f6368);
  final _tickettabs = [
    Tab(child: Text('Events', style: TextStyle(fontSize: 20))),
    Tab(child: Text('My Tickets', style: TextStyle(fontSize: 20))),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Container(
          child: Column(
            children: [
              Container(
                child: Container(
                  height: kToolbarHeight,
                  decoration: BoxDecoration(color: Colors.white, boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 10,
                    )
                  ]),
                  child: TabBar(
                    indicatorColor: Colors.blue[300],
                    indicatorWeight: 5,
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey[600],
                    tabs: _tickettabs,
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    Container(
                      child: SingleChildScrollView(
                        child: AllTickets(),
                      ),
                    ),
                    Container(
                      child: widget.loginCheck == true
                          ? new SingleChildScrollView(child: MyTickets())
                          : new Container(
                              color: Colors.grey[300],
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                      child: Icon(
                                    Icons.event_available_outlined,
                                    color: Colors.grey[600],
                                    size: 40,
                                  )),
                                  Container(
                                    child: Text(
                                      'Sign in to view your tickets',
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  )
                                ],
                              )),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EventsTab extends StatefulWidget {
  final loginCheck;
  const EventsTab({super.key, required this.loginCheck});

  @override
  State<EventsTab> createState() => _EventsTabState();
}

class _EventsTabState extends State<EventsTab>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> userData = [];
  late String frontImage;
  late String backImage;
  late bool checkforimage = false;

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

  final _selectedColor = Colors.blue[200];
  final _unselectedColor = Color(0xff5f6368);
  final _eventtabs = [
    Tab(child: Text('My Events', style: TextStyle(fontSize: 20))),
  ];

  openCamera() async {
    final picker = ImagePicker();
    final pickedFile1 = await picker.getImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );
    if (pickedFile1 != null) {
      setState(() {
        frontImage = base64Encode(File(pickedFile1.path).readAsBytesSync());
      });
    }
    final pickedFile2 = await picker.getImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );
    if (pickedFile2 != null) {
      setState(() {
        backImage = base64Encode(File(pickedFile2.path).readAsBytesSync());
        checkforimage = true;
      });
    }
  }

  upgradeAPI() async {
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
                  'Submitting Request',
                  style: TextStyle(fontSize: 20),
                ),
              )
            ],
          );
        });
    try {
      if (frontImage == null || backImage == null) {
        EasyLoading.showToast('Please add images',
            toastPosition: EasyLoadingToastPosition.bottom);
      } else {
        Response response = await post(
          Uri.parse('http://' + API.IP + '/api/updatetoec'),
          headers: {
            'Authorization': "Bearer " + userData[0]['token'],
          },
          body: {
            'front': frontImage,
            'back': backImage,
            'type': "cnic",
            'r_type': "ec",
          },
        );
        if (response.statusCode == 200) {
          var jsonResponse = jsonDecode(response.body);
          EasyLoading.showToast('Upgrade Requested',
              toastPosition: EasyLoadingToastPosition.bottom);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
      ));
    }
    Navigator.pop(context);
  }

  submitRequst() {
    showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        title: Text(
          "Submit Request",
          textAlign: TextAlign.center,
        ),
        actions: [
          Container(
            alignment: Alignment.bottomCenter,
            child: RoundedButton(
              text: 'Submit',
              press: () {
                if (frontImage == "" || backImage == "") {
                  EasyLoading.showToast('Image not taken',
                      toastPosition: EasyLoadingToastPosition.bottom);
                } else {
                  Navigator.pop(context);
                  upgradeAPI();
                  setState(() {               
                    getUserData();
                  });
                }
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

  Widget getwidget() {
    setState(() {
      getUserData();
    });
    if (userData[0]['role'] == 1) {
      return Container(
        color: Colors.grey[300],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              child: Icon(
                Icons.upgrade_outlined,
                color: Colors.grey[600],
                size: 40,
              ),
            ),
            Container(
              child: Text(
                'Upgrade your account to create your own events',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey[600],
                ),
              ),
            ),
            Container(
              child: RoundedButton(
                text: "Upgrade",
                press: () async {
                  showDialog<String>(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                            ),
                            title: Text(
                              "Take a picture of your ID card front and back",
                              textAlign: TextAlign.center,
                            ),
                            actions: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Container(
                                    alignment: Alignment.bottomCenter,
                                    child: RoundedButton(
                                      text: 'Upgrade',
                                      press: () {
                                        Navigator.pop(context);
                                        openCamera();
                                        submitRequst();
                                      },
                                      width: 100,
                                      height: 40,
                                      background_color: Colors.blue,
                                      foreground_color: Colors.white,
                                    ),
                                  ),
                                  Container(
                                    alignment: Alignment.bottomCenter,
                                    child: RoundedButton(
                                      text: 'Close',
                                      press: () {
                                        Navigator.pop(context);
                                      },
                                      width: 100,
                                      height: 40,
                                      background_color: Colors.blue,
                                      foreground_color: Colors.white,
                                    ),
                                  )
                                ],
                              )
                            ],
                          ));
                },
                width: 100,
                height: 40,
                background_color: Colors.blue,
                foreground_color: Colors.white,
              ),
            )
          ],
        ),
      );
    } else if (userData[0]['role'] == 0 ||
        userData[0]['role'] == 2 ||
        userData[0]['role'] == 3) {
      return Container(
        child: SingleChildScrollView(child: MyEvents()),
      );
    } else if (userData[0]['role'] == 4 || userData[0]['role'] == 5) {
      return Container(
        color: Colors.grey[300],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
                child: Icon(
              Icons.admin_panel_settings,
              color: Colors.grey[600],
              size: 40,
            )),
            Container(
              child: Text(
                'Please give us some time while we varifiy your ID',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey[600],
                ),
              ),
            )
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 1,
      child: Scaffold(
        body: Container(
          child: Column(
            children: [
              Container(
                  child: Container(
                height: kToolbarHeight,
                decoration: BoxDecoration(color: Colors.white, boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 0))
                ]),
                child: TabBar(
                  indicatorColor: Colors.blue[300],
                  indicatorWeight: 5,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.white,
                  tabs: _eventtabs,
                ),
              )),
              Expanded(
                child: TabBarView(
                  children: [
                    Container(
                      child: widget.loginCheck == true
                          ? new Container(child: getwidget())
                          : new Container(
                              color: Colors.grey[300],
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                      child: Icon(
                                    Icons.event_busy_outlined,
                                    color: Colors.grey[600],
                                    size: 40,
                                  )),
                                  Container(
                                    child: Text(
                                      'Sign in to view your events',
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: widget.loginCheck &&
                (userData[0]['role'] == 0 ||
                    userData[0]['role'] == 2 ||
                    userData[0]['role'] == 3)
            ? FloatingActionButton.extended(
                label: const Text('Create Event'),
                onPressed: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => EventForm()));
                },
                icon: const Icon(
                  Icons.add,
                ),
              )
            : null,
      ),
    );
  }
}
