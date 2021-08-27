import 'dart:convert';

import 'package:http/http.dart' as http;

var a = "AIzaSyBWi73AXGHHu";
var b = "_MhHGbaOjLI6I";
var c = "3EfXuJRha";
String apiKey = a+c+b;

class GoogleApiServices{

  Future<double> getDistance(String userLat, String userLng, String placeLat, String placeLng) async{
    String url = "https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=$userLat,$userLng&destinations=$placeLat,$placeLng&key=$apiKey";
    http.Response response = await http.get(Uri.parse(url));
    Map values = jsonDecode(response.body);

    return (values["rows"][0]["elements"][0]["distance"]["value"])/1000;
  }

  Future<List> getLatLngFromPlaceID(placeID) async {
    String url = "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeID&key=$apiKey";
    http.Response response = await http.get(Uri.parse(url));
    Map values = jsonDecode(response.body);

    var lat = values['result']['geometry']['location']['lat'];
    var lng = values['result']['geometry']['location']['lng'];

    return [lat, lng];
  }

  Future<String> getNameFromLatLng(lat, lng) async {
    String url = "https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$apiKey";
    http.Response response = await http.get(Uri.parse(url));
    Map values = jsonDecode(response.body);
    var address = values["results"][0]["formatted_address"];

    return address;
  }

}