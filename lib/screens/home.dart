import 'dart:async';

import 'package:auto_size_text_pk/auto_size_text_pk.dart';
import 'package:durotto/services/google_services.dart';
import 'package:durotto/services/notification_api.dart';
import 'package:durotto/state_management/user_bloc.dart';
import 'package:flutter_focus_watcher/flutter_focus_watcher.dart';
import 'package:geocode/geocode.dart';
import 'package:google_maps_webservice/places.dart' as WebServices;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {

  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool loadOnce = false;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final userAddress = new TextEditingController();
  final destination = new TextEditingController();

  late LocationData currentLocation;
  Coordinates destinationLocation = Coordinates();
  late StreamSubscription<LocationData> locationSubscription;

  GoogleApiServices _googleApiServices = GoogleApiServices();

  getLocation(userBloc) async {
    if (loadOnce == false) {
      var location = new Location();
      currentLocation = await location.getLocation();

      _googleApiServices.getNameFromLatLng(currentLocation.latitude.toString(), currentLocation.longitude.toString()).then((value) {
          loadOnce = true;
          userBloc.start = value;
      });
    }
  }

  getDestinationCoordinates(placeID, userBloc) async {
    try {
      _googleApiServices.getLatLngFromPlaceID(placeID.toString()).then((value) {

        Coordinates coordinates = Coordinates(latitude: value[0], longitude: value[1]);

        setState(() {
          destinationLocation = coordinates;

          var distance = _googleApiServices.getDistance(
              currentLocation.latitude.toString(),
              currentLocation.longitude.toString(),
              destinationLocation.latitude.toString(),
              destinationLocation.longitude.toString()
          );

          distance.then((value) {
            userBloc.distance = value.toDouble();

            NotificationApi.showNotification(
              title: "Distance to " + destination.text + " is",
              body: value.toString() + " km",
            );

            storeRecord(value, userBloc);
          });
        });
      });
    } catch (e) {
      print(e);
    }
  }

  storeRecord(distance, userBloc) {
    var record = {
      "start": userAddress.text,
      "createdAt": Timestamp.now(),
      "end": destination.text,
      "distance": distance,
      "start_latLng": [currentLocation.latitude, currentLocation.longitude],
      "end_latLng": [destinationLocation.latitude, destinationLocation.longitude],
    };

    CollectionReference users = FirebaseFirestore.instance.collection('users').doc(userBloc.user['email']).collection("records");
    users.add(record);
  }

  @override
  Widget build(BuildContext context) {
    UserBloc _userBloc = Provider.of<UserBloc>(context);
    getLocation(_userBloc);
    var displayName = _userBloc.user['name']!=null?_userBloc.user["name"]:"";
    setState(() {
      userAddress.text = _userBloc.start;
    });

    return SingleChildScrollView(
      child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                child: Image.asset(
                  "assets/images/home.gif",
                  width: 200,
                  height: 200,
                ),
              ),
              Container(
                child: AutoSizeText(
                  "Welcome, " + displayName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    color: Colors.green[800]
                  ),
                  maxLines: 1,
                  maxFontSize: 18,
                  minFontSize: 12,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: EdgeInsets.all(0),
                margin: EdgeInsets.only(top: 20, left: 10, right: 10),
                child: TextFormField(
                  readOnly: true,
                  controller: userAddress,
                  keyboardType: TextInputType.text,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontSize: 16
                  ),
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(color: Colors.transparent)
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(color: Colors.transparent)
                    ),
                    hintText: 'User Current Location',
                    prefixIcon: IconButton(
                      padding: EdgeInsets.all(0),
                      constraints: BoxConstraints(minHeight: 0, maxHeight: 0, minWidth: 0, maxWidth: 0),
                      onPressed: () {

                      },
                      icon: FaIcon(
                        FontAwesomeIcons.locationArrow,
                        size: 20,
                      ),
                    ),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                    hintStyle: TextStyle(
                      fontSize: 16,
                    ),
                    filled: true,
                    fillColor: Colors.grey[300],
                  ),
                  enableSuggestions: false,
                  autocorrect: false,
                ),
              ),

              Container(
                padding: EdgeInsets.all(0),
                margin: EdgeInsets.only(top: 20, left: 10, right: 10),
                child: TextFormField(
                  onTap: () async {
                    FocusScope.of(context).unfocus();

                    //for leaking purpose in git :v
                    var a = "AIzaSyBWi73AXGHHu";
                    var b = "_MhHGbaOjLI6I";
                    var c = "3EfXuJRha";

                    WebServices.Prediction? p = await PlacesAutocomplete.show(
                      context: context,
                      apiKey: a+c+b,
                      language: "en",
                      offset: 0,
                      radius: 1000,
                      hint: "",
                      types: [],
                      strictbounds: false,
                      components: [
                        WebServices.Component(WebServices.Component.country, "bd")
                      ],

                    );

                    if (p != null) {
                      print(p.placeId);
                      destination.text = p.description!;
                      _userBloc.destination = destination.text;
                      getDestinationCoordinates(p.placeId, _userBloc);
                    }
                  },
                  controller: destination,
                  keyboardType: TextInputType.text,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontSize: 16
                  ),
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(color: Colors.transparent)
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(color: Colors.transparent)
                    ),
                    hintText: 'Destination',
                    prefixIcon: IconButton(
                      padding: EdgeInsets.all(0),
                      constraints: BoxConstraints(minHeight: 0, maxHeight: 0, minWidth: 0, maxWidth: 0),
                      onPressed: () {},
                      icon: FaIcon(
                        FontAwesomeIcons.locationArrow,
                        size: 20,
                      ),
                    ),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                    hintStyle: TextStyle(
                      fontSize: 16,
                    ),
                    filled: true,
                    fillColor: Colors.grey[300],
                  ),
                  enableSuggestions: false,
                  autocorrect: false,
                ),
              ),

              _userBloc.distance>0?
              Container(
                margin: EdgeInsets.all(20),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  gradient: new LinearGradient(
                      colors: [
                        Colors.green,
                        Colors.blueGrey,
                      ],
                      begin: const FractionalOffset(0.0, 0.5),
                      end: const FractionalOffset(1.0, 1.0),
                      stops: [0.0, 1.0],
                      tileMode: TileMode.clamp
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                            flex: 1,
                            child: FaIcon(
                              FontAwesomeIcons.mapPin,
                              color: Colors.white,
                            )
                        ),
                        Expanded(
                            flex: 8,
                            child: Text(
                              userAddress.text,
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800
                              ),
                            ),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 5.0),
                          child: FaIcon(
                            FontAwesomeIcons.ellipsisV,
                            color: Colors.white,
                            size: 15,
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                            flex: 1,
                            child: FaIcon(
                              FontAwesomeIcons.mapPin,
                              color: Colors.white,
                            )
                        ),
                        Expanded(
                          flex: 8,
                          child: Text(
                            _userBloc.destination,
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w800
                            ),
                          ),
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        "Distance: " + _userBloc.distance.toString() + " km",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w800
                        ),
                      ),
                    ),
                  ],
                ),
              ):Container(),

            ],
          ),
      ),
    );
  }
}
