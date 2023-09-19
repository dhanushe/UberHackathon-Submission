import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:custom_map_markers/custom_map_markers.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:carpool_early/requests.dart';

// with the google maps api, draw all markers
// will replace markers with the faces involved
// let the user travel in the page!
// whenever reaches the friend's house send a message

List<String> images = [
  "assets/akshay.jpeg",
  "assets/emma.jpeg",
  "assets/johnny.jpeg",
  "assets/srk.webp",
  "assets/taylor.webp"
];

List<String> names = ["Akshay", "Emma", "Johnny", "Sharukh", "Taylor"];

// my guess is we need to add + in between
List<String> addresses = [
  "Santa Clara, CA",
  "Seattle, WA",
  "Santa+Cruz, CA",
  "Woodinville, WA",
  "Bothell, WA"
];

// we could create a new polyline here
// but we already get one in the json file which we'll use!

// first location is wherever you are
List<LatLng> locations = [
  LatLng(37.33, -122.0),
  LatLng(38, -122.0),
  LatLng(37.1, -122),
  LatLng(37.3, -122.0),
  LatLng(37.5, -122.0)
];

void launchURL(String url) async {
  if (await canLaunchUrlString(url)) {
    await launchUrlString(url);
  } else {
    throw 'Could not launch $url';
  }
}

String generateNames(List<String> names) {
  String nameString = "";
  for (int i = 0; i < names.length; i += 1) {
    nameString += names[i];
    if (i + 1 != names.length) {
      nameString += ", ";
    }
  }
  return nameString;
}

// use with direction button
String generateUrl(List<String> adds) {
  String mapsUrl = "https://www.google.com/maps/dir/?api=1";
  // List<String> waypoints = adds.sublist(1, adds.length - 1);
  bool waypoints = false;

  // split origin into space
  for (int i = 0; i < adds.length; i += 1) {
    if (i == 0) {
      mapsUrl += "&origin=";
    } else if (i + 1 == adds.length) {
      mapsUrl += "&destination=";
      waypoints = false;
    } else if (i == 1) {
      mapsUrl += "&waypoints=";
      waypoints = true;
    }

    // split origin into spaces

    List<String> words = adds[i].split(" ");
    for (int j = 0; j < words.length; j += 1) {
      // check if a comma is in a word
      if (words[j].contains(",")) {
        mapsUrl += words[j].substring(0, words[j].length - 1) + "%2C";
      } else {
        mapsUrl += words[j];
      }

      if (j + 1 != words.length) {
        mapsUrl += "+";
      }
    }

    // notice also for every new waypoint
    // we'd have a |
    // last waypoint is 2nd last one
    if ((waypoints == true) && (i + 1 != adds.length - 1)) {
      // means we would add a |
      mapsUrl += "%7C";
    }
  }

  // take mapsUrl and replace | and ,

  print(mapsUrl);
  return mapsUrl;
}

class Gmaps extends StatefulWidget {
  const Gmaps({super.key});

  // static const LatLng sourceLocation = LatLng(37.33, -122.0);

  @override
  State<Gmaps> createState() => _GmapsState();
}

class _GmapsState extends State<Gmaps> {
  // final Completer<GoogleMapController> _controller = Completer();
  // late GoogleMapController mapController;
  // Set<Marker> markers = new Set();
  // List<BitmapDescriptor> custom = [];
  // LocationData? currentLocation;

  // void init state
  @override
  void initState() {
    super.initState();
    // below code updates list
    // so our application updates this when reached the page
    addresses = [
      "Santa Clara, CA",
      "Seattle, WA",
      "Santa Cruz, CA",
      "Woodinville, WA",
      "Bothell, WA"
    ];
    locations = [
      LatLng(37.33, -122.0),
      LatLng(38, -122.0),
      LatLng(37.1, -122),
      LatLng(37.3, -122.0),
      LatLng(37.5, -122.0)
    ];
    // getCurrentLocation();
    getBestWaypoints(addresses);
    print('running');
  }

  // to get location in future
  // when we place google maps inside our code
  // and have the icon move in-app

  /*void getCurrentLocation() async {
    Location location = new Location();
    // GoogleMapController googleMapController = await _controller.future;

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    currentLocation = await location.getLocation();

    location.onLocationChanged.listen((newLoc) {
      currentLocation = newLoc;
      /*googleMapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
              zoom: 11, target: LatLng(newLoc.latitude!, newLoc.longitude!))));*/
      setState(() {});
    });
  }*/

  // constant updates
  List<MarkerData> getMarkers() {
    // update every time we call this
    List<MarkerData> _customMarkers = [];
    // awesome now getting current location works!
    //getCurrentLocation();

    for (int i = 0; i < addresses.length; i++) {
      // the first event organizer is the driver
      LatLng loc = locations[i];
      // if i is 0, then we grab it from current location
      /*if (i == 0) {
        loc =
            new LatLng(currentLocation!.latitude!, currentLocation!.longitude!);
      }*/

      // code to be executed after 2 seconds
      _customMarkers.add(MarkerData(
          marker: Marker(
            markerId: MarkerId(addresses[i]),
            position: loc,
          ),
          child: _customMarker(images[i])));
    }

    return _customMarkers;
  }

  // Hooray, google maps is working, let's now add some markers
  @override
  Widget build(BuildContext context) {
    // getLocations();
    // print(addresses);
    // print(locations);
    return Scaffold(
      // top right corner with padding
      // Your Ride
      body: // currentLocation == null
          // ? const Center(child: Text("loading")) :
          Stack(
        children: [
          CustomGoogleMapMarkerBuilder(
            // screenshotDelay: const Duration(seconds: 4),
            customMarkers: getMarkers(),
            builder: (BuildContext context, Set<Marker>? markers) {
              // null for brief sec
              if (markers == null) {
                return const Center(child: CircularProgressIndicator());
              }
              return GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(locations[0].latitude, locations[0].longitude),
                  zoom: 9,
                ),
                markers: markers,
                // onMapCreated: (GoogleMapController mapController) {
                // _controller.complete(mapController);
                // },
              );
            },
          ),
          backButton(context),
          // create another rounded rectangle all the way at the bottom
          driveBar(),
        ],
      ),
    );
  }

  // this is our custom marker!
  _customMarker(String image) {
    // create a circle avatar
    return Align(
      child: CircleAvatar(
        radius: 30,
        backgroundColor: Colors.white,
        child: CircleAvatar(
          radius: 25,
          backgroundImage: AssetImage(image),
        ),
      ),
    );
  }

  GestureDetector backButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      // should reformat this to an icon
      child: Stack(alignment: Alignment.center, children: [
        // create a small rounded box and a icon
        Container(
          margin: EdgeInsets.all(10),
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        // here's where the icon should go!
        Icon(Icons.arrow_left, color: Colors.blue, size: 40)
      ]),
    );
  }

  Column driveBar() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // this is how we center with stack
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.35,
              // padding: EdgeInsets.all(20),
              // margin: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
              ),
            ),
            // alignment: Alignment.center,
            Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text('The Walnut Creek Trip',
                              style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.black,
                                  fontFamily: 'InclusiveSans')),
                        ),
                        SizedBox(width: 20),
                        GestureDetector(
                          onTap: () {
                            launchURL(generateUrl(addresses));
                          },
                          child: Column(
                            children: [
                              Stack(alignment: Alignment.center, children: [
                                // create a small rounded box and a icon
                                Container(
                                  height: 50,
                                  width: 50,
                                  margin: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                // here's where the icon should go!
                                Icon(Icons.directions,
                                    color: Colors.white, size: 30)
                              ]),
                              Text('Start Trip',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontFamily: 'InclusiveSans',
                                      fontSize: 20))
                            ],
                          ),
                        ),
                      ],
                    ),

                    // here we add the circle icons
                    circlesOverlap(Colors.white),
                    Text(generateNames(names),
                        style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'InclusiveSans',
                            fontSize: 20))
                  ],
                )),
          ],
        )
      ],
    );
  }
}

// defined globally so we can use in gmaps
// right now using the same images
Container circlesOverlap(Color color) {
  return Container(
      padding: EdgeInsets.all(10),
      child: Row(children: [
        for (int i = 0; i < 5; i++)
          Align(
              widthFactor: 0.5,
              child: CircleAvatar(
                radius: 30,
                backgroundColor: color,
                child: CircleAvatar(
                  radius: 25,
                  backgroundImage: AssetImage(images[i]),
                ),
              ))
      ]));
}
