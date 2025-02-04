import 'package:flutter/material.dart';
import 'package:flutter_geocoder/geocoder.dart' as gc;
import 'package:flutter_map/plugin_api.dart';
import 'package:geocode/geocode.dart';

import 'package:latlong2/latlong.dart';


class MapScreen extends StatefulWidget {
  MapScreen({Key? key, this.select= true, this.lat=50, this.long=50, this.latCenter= 34.4394, this.longCenter=9.490272}) : super(key: key);

  bool select;
  double lat;
  double long;
  double latCenter;
  double longCenter;

  @override
  _MapScreenState createState() => _MapScreenState();
}

//try using MAPBOX

class _MapScreenState extends State<MapScreen> {

  late LatLng center = LatLng(widget.latCenter, widget.longCenter);
  late LatLng point = LatLng(widget.lat, widget.long);
  Address location = Address(city: "",region: "",countryName: "");
  String locationString = "";
  GeoCode geoCode = GeoCode();
  var coordinates = Coordinates();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
              interactiveFlags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
              onTap: (p,latlng) async {
                if(widget.select){
                  try{

                    //location = await geoCode.reverseGeocoding(latitude: latlng.latitude, longitude: latlng.longitude);
                    final coordinates = new gc.Coordinates(latlng.latitude, latlng.longitude);
                    var c = await gc.Geocoder.local.findAddressesFromCoordinates(coordinates);
                    //print(c.first.adminArea);
                   // print(c.first.subAdminArea);

                    print("ok");
                   // locationString = "${location.countryName ?? ""} ${location.city ?? ""} ${location.region ?? ""}";
                    locationString = "${c.first.adminArea ?? ""} ${c.first.subAdminArea ?? ""}";
                    setState(() {
                      point = latlng;
                    });
                  }
                  catch(Exception){
                    print(Exception);
                    showDialog(context: context, builder: (context){return AlertDialog(title: Text("Une erreur s'est produite. Réessayez encore."),alignment: Alignment.bottomCenter,);});
                  }
                }

              },
              center: center,
              zoom: 6.5
          ),
          layers: [

            TileLayerOptions(
              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: ['a','b','c'],
            ),
            MarkerLayerOptions(
                markers: [
                  Marker(
                      width: 100,
                      height: 100,
                      point: point,
                      builder: (ctx)=> Icon(Icons.location_on,color: Colors.red,)
                  ),
                ]
            )
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 30,horizontal: 30),
          child: SizedBox.expand(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                widget.select ? Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      locationString != "" ? locationString: "Choisissez la localisation",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ): SizedBox(),
                widget.select ? Card(
                    child: TextButton.icon(
                      onPressed: (){
                        Navigator.pop(context,[locationString,point]);
                      },
                      icon: Icon(Icons.location_on),
                      label: Text("Confirmer"),
                    )
                ) : SizedBox(),
              ],
            ),
          ),
        )
      ],
    );
  }
}


/*
tuple: ^2.0.0
transparent_image: ^2.0.0
async: ^2.8.2
flutter_image: ^4.1.0
  vector_math: ^2.1.1
  proj4dart: ^2.0.0
  meta: ^1.7.0
  collection: ^1.15.0
*/