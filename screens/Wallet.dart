import 'dart:convert';
import 'package:firstapp/screens/LoginScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as met;
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../Cards/TransactionCard.dart';
import 'package:http/http.dart';
import '../database/sqlite.dart';
import '../models/TransactionModel.dart';
import 'MainMenu.dart';
import '../helper/constant.dart' as API;

class Wallet extends StatefulWidget {
  const Wallet({super.key, required this.loginCheck, required this.userToken});
  final bool loginCheck;
  final String userToken;
  @override
  State<Wallet> createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  final depositAmount = TextEditingController();
  final bankName = TextEditingController();
  final accountNumber = TextEditingController();
  late double userbalance = 0;
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic>? paymentIntent;
  List<Transaction> transactions = [];
  late bool loader;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //drawer: NavBar(),
      appBar: AppBar(
        title: Text("Tick-It"),
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.blue[900],
          statusBarBrightness: Brightness.dark,
        ),
      ),
      body: Container(
        child: widget.loginCheck == true
            ? new Container(
                child: loader == false
                    ? Container(
                        width: MediaQuery.of(context).size.width,
                        child: Column(
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
                                'Loading Wallet',
                                style: TextStyle(fontSize: 20),
                              ),
                            )
                          ],
                        ))
                    : getWalletScreen())
            : Container(
                width: double.maxFinite,
                color: Colors.grey[300],
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                        child: Icon(
                      Icons.wallet,
                      color: Colors.grey[600],
                      size: 40,
                    )),
                    Container(
                      child: Text(
                        'Sign in to view your wallet',
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
    );
  }

  @override
  void initState() {
    super.initState();
    loader = false;
    if (widget.loginCheck == true) {
      balanceAPI();
      transactionAPI();
    }
  }

  Future<void> balanceAPI() async {
    try {
      Response response = await post(
        Uri.parse('http://' + API.IP + '/api/getbalance'),
        headers: {
          'Authorization': "Bearer " + widget.userToken,
        },
      );
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);

        setState(() {
          userbalance = double.parse(jsonResponse['balance'].toString());
        });
      }
    } catch (e) {
      EasyLoading.showToast('Error: ' + e.toString(),
          toastPosition: EasyLoadingToastPosition.bottom);
    }
  }

  Future<void> depositAPI() async {
    try {
      Response response =
          await post(Uri.parse('http://' + API.IP + '/api/deposite'), headers: {
        'Authorization': "Bearer " + widget.userToken,
      }, body: {
        'amount': "1000",
      });

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        EasyLoading.showToast('Transaction succssful',
            toastPosition: EasyLoadingToastPosition.bottom);
        balanceAPI();
        transactionAPI();
      } else {
        EasyLoading.showToast('Transaction failed',
            toastPosition: EasyLoadingToastPosition.bottom);
      }
    } catch (e) {
      EasyLoading.showToast('Error: ' + e.toString(),
          toastPosition: EasyLoadingToastPosition.bottom);
    }
  }

  Future<void> withdrawAPI() async {
    try {
      Response response =
          await post(Uri.parse('http://' + API.IP + '/api/withdraw'), headers: {
        'Authorization': "Bearer " + widget.userToken,
      }, body: {
        'bank': bankName.text,
        'ano': accountNumber.text,
        'amount': depositAmount.text,
      });

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        EasyLoading.showToast('Withdraw requested',
            toastPosition: EasyLoadingToastPosition.bottom);
      } else {
        EasyLoading.showToast('Request failed',
            toastPosition: EasyLoadingToastPosition.bottom);
      }
    } catch (e) {
      EasyLoading.showToast('Error: ' + e.toString(),
          toastPosition: EasyLoadingToastPosition.bottom);
    }
  }

  void makePayment() async {
    try {
      paymentIntent = await createPaymentIntent();

      var gpay = const PaymentSheetGooglePay(
        merchantCountryCode: "PK",
        currencyCode: "PKR",
        testEnv: true,
      );
      await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: paymentIntent!["client_secret"],
        style: ThemeMode.light,
        merchantDisplayName: "Tick-It",
        googlePay: gpay,
      ));

      displayPaymentSheet();
    } catch (e) {
      print(e.toString());
    }
  }

  void displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      depositAPI();
    } catch (e) {
      EasyLoading.showToast('Payment Falied',
          toastPosition: EasyLoadingToastPosition.bottom);
    }
  }

  createPaymentIntent() async {
    try {
      Map<String, dynamic> body = {
        "amount": "100000",
        "currency": "PKR",
      };

      Response response = await post(
          Uri.parse("https://api.stripe.com/v1/payment_intents"),
          body: body,
          headers: {
            "Authorization":
                "Bearer sk_test_51N4fYDGg4kRxFZtJbLO4mFkQ10dO7Ev1NqPQTEICZobCTFXLUe65yOGIKkUrlrxv4apwrtYe53xEP0APm3iBQfOt00CWI3xowk",
            "Content-Type": "application/x-www-form-urlencoded",
          });
      return json.decode(response.body);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  getWalletScreen() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.blue[200],
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(10),
              child: met.Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.0))),
                elevation: 10,
                shadowColor: Colors.black,
                color: Colors.white,
                child: SizedBox(
                  width: double.maxFinite,
                  height: 130,

                  child: Column(
                    children: [
                      Padding(padding: EdgeInsets.all(10)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                              margin: EdgeInsets.fromLTRB(15, 0, 0, 0),
                              child: Text(
                                'Rs.' + userbalance.toStringAsFixed(2),
                                style: TextStyle(
                                    fontSize: 32, fontWeight: FontWeight.bold),
                              )),
                          Container(
                              margin: EdgeInsets.only(right: 10),
                              child: RoundedButton(
                                  text: 'Withdraw Cash',
                                  press: () {
                                    showDialog<String>(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (BuildContext context) =>
                                          AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(8.0)),
                                        ),
                                        title: Text(
                                          "Enter account details",
                                          textAlign: TextAlign.center,
                                        ),
                                        actions: [
                                          Container(
                                            height: 250,
                                            child: Form(
                                              key: _formKey,
                                              child: Scaffold(
                                                resizeToAvoidBottomInset: false,
                                                body: SingleChildScrollView(
                                                  physics: ScrollPhysics(),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Container(
                                                        padding:
                                                            EdgeInsets.only(
                                                                bottom: 10),
                                                        child: TextFormField(
                                                          controller: bankName,
                                                          decoration:
                                                              InputDecoration(
                                                            isDense: true,
                                                            labelText: 'Bank',
                                                            enabledBorder: OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                borderSide: BorderSide(
                                                                    color: Colors
                                                                        .blue)),
                                                            focusedBorder:
                                                                OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              borderSide:
                                                                  BorderSide(
                                                                      color: Colors
                                                                          .blue),
                                                            ),
                                                            border: OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                borderSide: BorderSide(
                                                                    color: Colors
                                                                        .blue)),
                                                            errorBorder: OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                borderSide: BorderSide(
                                                                    color: Colors
                                                                        .red)),
                                                          ),
                                                          style: TextStyle(
                                                            fontSize: 20,
                                                          ),
                                                          validator:
                                                              (bankName) {
                                                            if (bankName ==
                                                                    null ||
                                                                bankName
                                                                    .isEmpty) {
                                                              return 'Please enter a bank';
                                                            }
                                                            return null;
                                                          },
                                                        ),
                                                      ),
                                                      Container(
                                                        padding:
                                                            EdgeInsets.only(
                                                                bottom: 10),
                                                        child: TextFormField(
                                                          controller:
                                                              accountNumber,
                                                          decoration:
                                                              InputDecoration(
                                                            isDense: true,
                                                            labelText:
                                                                'Account Number',
                                                            enabledBorder: OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                borderSide: BorderSide(
                                                                    color: Colors
                                                                        .blue)),
                                                            focusedBorder:
                                                                OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              borderSide:
                                                                  BorderSide(
                                                                      color: Colors
                                                                          .blue),
                                                            ),
                                                            border: OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                borderSide: BorderSide(
                                                                    color: Colors
                                                                        .blue)),
                                                            errorBorder: OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                borderSide: BorderSide(
                                                                    color: Colors
                                                                        .red)),
                                                          ),
                                                          style: TextStyle(
                                                            fontSize: 20,
                                                          ),
                                                          validator:
                                                              (accountNumber) {
                                                            if (accountNumber ==
                                                                    null ||
                                                                accountNumber
                                                                    .isEmpty) {
                                                              return 'Please enter an account number';
                                                            }
                                                            return null;
                                                          },
                                                        ),
                                                      ),
                                                      Container(
                                                        padding:
                                                            EdgeInsets.only(
                                                                bottom: 10),
                                                        child: TextFormField(
                                                          controller:
                                                              depositAmount,
                                                          decoration:
                                                              InputDecoration(
                                                            prefixText: "Rs.",
                                                            isDense: true,
                                                            labelText: 'Amount',
                                                            enabledBorder: OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                borderSide: BorderSide(
                                                                    color: Colors
                                                                        .blue)),
                                                            focusedBorder:
                                                                OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              borderSide:
                                                                  BorderSide(
                                                                      color: Colors
                                                                          .blue),
                                                            ),
                                                            border: OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                borderSide: BorderSide(
                                                                    color: Colors
                                                                        .blue)),
                                                            errorBorder: OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                borderSide: BorderSide(
                                                                    color: Colors
                                                                        .red)),
                                                          ),
                                                          style: TextStyle(
                                                            fontSize: 20,
                                                          ),
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
                                                          validator:
                                                              (depositAmount) {
                                                            final bool
                                                                depositAmountValid =
                                                                RegExp(r'^(?:[1-9]\d*|0)?(?:\.\d+)?$')
                                                                    .hasMatch(
                                                                        depositAmount!);
                                                            if (depositAmount ==
                                                                    null ||
                                                                depositAmount
                                                                    .isEmpty) {
                                                              return 'Please enter an amount';
                                                            } else if (!depositAmountValid) {
                                                              return 'Please enter a number';
                                                            }
                                                            return null;
                                                          },
                                                        ),
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceAround,
                                                        children: [
                                                          Container(
                                                            alignment: Alignment
                                                                .bottomCenter,
                                                            child:
                                                                RoundedButton(
                                                              text: 'Submit',
                                                              press: () {
                                                                FocusScope.of(
                                                                        context)
                                                                    .unfocus();
                                                                if (_formKey
                                                                    .currentState!
                                                                    .validate()) {
                                                                  if (userbalance >=
                                                                      double.parse(depositAmount
                                                                          .text
                                                                          .toString())) {
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                    withdrawAPI();
                                                                    balanceAPI();
                                                                    transactionAPI();
                                                                  } else {
                                                                    EasyLoading.showToast(
                                                                        'Not enought balance',
                                                                        toastPosition:
                                                                            EasyLoadingToastPosition.bottom);
                                                                  }
                                                                }
                                                              },
                                                              width: 100,
                                                              height: 40,
                                                              background_color:
                                                                  Colors.blue,
                                                              foreground_color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                          Container(
                                                            alignment: Alignment
                                                                .bottomCenter,
                                                            child:
                                                                RoundedButton(
                                                              text: 'Close',
                                                              press: () {
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              width: 100,
                                                              height: 40,
                                                              background_color:
                                                                  Colors.blue,
                                                              foreground_color:
                                                                  Colors.white,
                                                            ),
                                                          )
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  width: 150,
                                  height: 40,
                                  background_color:
                                      const Color.fromARGB(255, 220, 232, 241),
                                  foreground_color: Colors.black)),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                              margin: EdgeInsets.only(left: 15),
                              child: Text(
                                'Available Balance',
                                style: TextStyle(fontSize: 18),
                              )),
                          Container(
                            margin: EdgeInsets.fromLTRB(0, 10, 10, 0),
                            child: RoundedButton(
                                text: 'Add Rs.1000',
                                press: () {
                                  makePayment();
                                  transactionAPI();
                                },
                                width: 150,
                                height: 40,
                                background_color:
                                    const Color.fromARGB(255, 126, 193, 249),
                                foreground_color: Colors.black),
                          ),
                        ],
                      ),
                    ],
                  ), //Column
                ), //Padding
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Expanded(
                child: met.Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12.0))),
                  elevation: 10,
                  shadowColor: Colors.black,
                  color: Colors.white,
                  child: SizedBox(
                      width: double.maxFinite,
                      height: MediaQuery.of(context).size.height * 0.65,
                      child: transactions.length == 0
                          ? Container(
                            padding: EdgeInsets.only(top: 30),
                              width: double.maxFinite,
                              child: Text('No transactions found',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.grey[600],
                                  )),
                            )
                          : SingleChildScrollView(
                              child: Column(
                                children: [
                                  ...List.generate(
                                    transactions.length,
                                    (index) => TransactionCard(
                                      transactionData: transactions[index],
                                    ),
                                  ),
                                ],
                              ),
                            )),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> transactionAPI() async {
    try {
      Response response = await get(
        Uri.parse('http://' + API.IP + '/api/getauserstransaction'),
        headers: {
          'Authorization': "Bearer " + widget.userToken,
        },
      );
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as List<dynamic>;
        final transactionData =
            jsonData.map((json) => Transaction.fromJson(json)).toList();
        setState(() {
          transactions = transactionData;
          loader = true;
        });
      } else {
        EasyLoading.showToast('Request failed',
            toastPosition: EasyLoadingToastPosition.bottom);
      }
    } catch (e) {
      EasyLoading.showToast('Error: ' + e.toString(),
          toastPosition: EasyLoadingToastPosition.bottom);
    }
  }
}
