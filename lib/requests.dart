import 'package:carpool/database.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// in firebase store the list of addresses (first user, other users, destination)
// reordered by waypoint index
// for every trip it'll be same

// order addresses again when a new user is added
// locations should be the entire list
void orderAddresses(List<dynamic> locations, String id) async {
  DatabaseMethods database = DatabaseMethods();
  // origin, destination
  // or origin, waypoint, destination
  if (locations.length <= 3) {
    database.addOrderedLocations(locations, id);
  }
  // otherwise compute best waypoints and then create list
  else {
    List<String> orderedLocations = [];

    print("Locations: " + locations.toString());
    dynamic waypoints = await getBestWaypoints(locations);
    // will help us get locations!
    print("Waypoints: " + waypoints.toString());

    // just needed that 0 in the middle
    List<dynamic> idxes =
        waypoints["routes"][0]["optimizedIntermediateWaypointIndex"];

    // waypoints are in middle
    List<dynamic> waypointAdds = locations.sublist(1, locations.length - 1);
    orderedLocations.add(locations[0]);

    for (dynamic id in idxes) {
      orderedLocations.add(waypointAdds[id]);
    }

    orderedLocations.add(locations.last);

    // now we can just say
    database.addOrderedLocations(orderedLocations, id);
  }
}

// create a map for string and dynamic
List<Map<String, String>> genWaypoints(List<dynamic> adds) {
  List<Map<String, String>> waypoints = [];

  for (int i = 0; i < adds.length; i++) {
    if ((i != 0) && (i + 1 != adds.length)) {
      Map<String, String> map = {"address": adds[i]};
      waypoints.add(map);
    }
  }

  print(waypoints);
  return waypoints;
}

// another request
// uses ordering of waypoints and makes decision

// we actually don't have to specify departure time
Future<dynamic> getRouteMatrix(List<dynamic> adds, String depart) async {
  final String apiUrl =
      'https://routes.googleapis.com/directions/v2:computeRoutes';
  final String apiKey = 'AIzaSyBoPYbDnCI7pndyPWh04s_FHnxUk8sBO5s';

  String correctDateFormat = "";
  List<String> times = depart.split("/");

  correctDateFormat = times[2] + "-" + times[0] + "-" + times[1];
  print('date format: ' + correctDateFormat.toString());

  //get month/day/year
  // year-month-day

  final Map<String, dynamic> requestBody = {
    "origin": {"address": adds[0]},
    "destination": {"address": adds.last},
    "intermediates": genWaypoints(
        adds) /*[
      {"address": "Barossa+Valley,SA"},
      {"address": "Clare,SA"},
      {"address": "Connawarra,SA"},
      {"address": "McLaren+Vale,SA"}
    ]*/
    ,
    "routingPreference": "TRAFFIC_AWARE",
    // here we would have to change departure time
    "departureTime": "${correctDateFormat}T12:00:0.045123456Z",
    "computeAlternativeRoutes": false,
    "routeModifiers": {
      "avoidTolls": false,
      "avoidHighways": false,
      "avoidFerries": false
    },
    "languageCode": "en-US",
    "units": "IMPERIAL"
  };

  final Map<String, String> headers = {
    'Content-Type': 'application/json',
    'X-Goog-Api-Key': apiKey,
    'X-Goog-FieldMask':
        'routes.duration,routes.distanceMeters,routes.polyline.encodedPolyline',
  };

  final response = await http.post(
    Uri.parse(apiUrl),
    headers: headers,
    body: jsonEncode(requestBody),
  );

  if (response.statusCode == 200) {
    // Request was successful, handle the response data here
    print('route body:' + response.body.toString());
    final jsonResponse = jsonDecode(response.body);
    print('decoded: ' + jsonResponse.toString());
    return jsonResponse;

    print('Response: ${response.body}');
  } else {
    // Request failed
    print('Request failed with status code: ${response.statusCode}');
    print('Response body: ${response.body}');
  }
}

// ideas is that adds is ordered so origin, waypoints, then destination
// since it's future maybe await
Future<dynamic> getBestWaypoints(List<dynamic> adds) async {
  print("Address: " + adds.toString());
  final String apiUrl =
      'https://routes.googleapis.com/directions/v2:computeRoutes';
  final String apiKey = 'AIzaSyBoPYbDnCI7pndyPWh04s_FHnxUk8sBO5s';

  // Construct the request body
  final Map<String, dynamic> requestBody = {
    "origin": {"address": adds[0]},
    "destination": {"address": adds.last},
    // we might need pluses
    "intermediates": genWaypoints(adds),
    /*[
      {"address": "Barossa+Valley,SA"},
      {"address": "Clare,SA"},
      {"address": "Connawarra,SA"},
      {"address": "McLaren+Vale,SA"}
    ],*/
    "travelMode": "DRIVE",
    "optimizeWaypointOrder": true // Note that it's a boolean, not a string
  };

  // Set the headers
  final Map<String, String> headers = {
    'Content-Type': 'application/json',
    'X-Goog-Api-Key': apiKey,
    'X-Goog-FieldMask': 'routes.optimizedIntermediateWaypointIndex'
  };

  // Make the POST request
  final response = await http.post(
    Uri.parse(apiUrl),
    headers: headers,
    body: jsonEncode(requestBody),
  );

  // List<int> idxes = [0, 1, 2, 3];
  print(response.body);
  if (response.statusCode == 200) {
    // Request was successful, handle the response data here
    final jsonResponse = jsonDecode(response.body);
    // want something dynamic
    return jsonResponse;

    // will be used and passed to the function where we can actually get order
    //List<int> idxes = jsonResponse['routes']['optimizedIntermediateWaypointIndex'];
    print('Response: ${response.body}');
  } else {
    // Request failed
    print('Request failed with status code: ${response.statusCode}');
    print('Response body: ${response.body}');
  }
}

// will convert address to longitude, latitude coordinate
Future<List<double>> geocodeAddress(String address) async {
  final apiKey =
      'AIzaSyBoPYbDnCI7pndyPWh04s_FHnxUk8sBO5s'; // Replace with your Google Maps API Key
  final encodedAddress = Uri.encodeComponent(address); // Encode the address

  final apiUrl = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?address=$encodedAddress&key=$apiKey');
  double latitude = 0.0;
  double longitude = 0.0;

  try {
    final response = await http.get(apiUrl);

    if (response.statusCode == 200) {
      // Parse and handle the response data (e.g., JSON parsing)
      final responseData = jsonDecode(response.body);
      final results = responseData['results'] as List<dynamic>;
      if (results.isNotEmpty) {
        final location = results[0]['geometry']['location'];
        latitude = location['lat'];
        longitude = location['lng'];

        print('Latitude: $latitude, Longitude: $longitude');
      } else {
        // Handle case where there are no results
        print('No results found.');
      }
      // Process the responseData here (extract latitude and longitude)
    } else {
      // Handle API error (e.g., non-200 status code)
      print('Error: ${response.statusCode}');
    }
  } catch (e) {
    // Handle network or other errors
    print('Error: $e');
  }

  return [latitude, longitude];
}
