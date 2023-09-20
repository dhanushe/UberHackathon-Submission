import 'package:carpool/gmaps.dart';
import 'package:carpool/requests.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:carpool/database.dart';

class ThreeBest extends StatefulWidget {
  final List<dynamic> dates;
  final List<dynamic> locations;
  final String id;
  // locations should actually be everything!
  const ThreeBest(
      {Key? key,
      required this.dates,
      required this.locations,
      required this.id})
      : super(key: key);

  @override
  State<ThreeBest> createState() => _ThreeBestState();
}

// get the trip's data
// if you click into, it should zoom into the actual map
class _ThreeBestState extends State<ThreeBest> {
  // List<dynamic> dates = [];
  // Iterable<String> bestOpts = [];

  // create init state method

  @override
  // ignore: must_call_super
  void initState() {
    // ignore: avoid_print
    // print(getData());
    orderAddresses(widget.locations, widget.id);

    // now we got to calculate the overlap in dates (what's the high tie)
  }

  // awesome thing now is to do future builder
  // then we can use this
  Future<Iterable<String>> loadDates() async {
    DatabaseMethods dm = new DatabaseMethods();
    return bestOptions(await dm.fetchStringArray(widget.id, 'dates'));
  }

  // once we changed dates, we can use it for everything
  // we have to count the same dates

  // best options will all be tested the same time on gmaps
  Iterable<String> bestOptions(List<dynamic> dates) {
    // we'd use dates here
    Map<String, int> keepCount = {};
    for (String date in dates) {
      // check if already in the map
      if (keepCount.containsKey(date)) {
        keepCount[date] = keepCount[date]! + 1;
      } else {
        keepCount[date] = 0;
      }
    }

    // now get me whatever are the top numbers
    var sortedByValueMap = Map.fromEntries(keepCount.entries.toList()
      ..sort((e1, e2) => e1.value.compareTo(e2.value)));

    // get last 3 dates
    return sortedByValueMap.keys.toList().reversed.take(3);
  }

  // we kind of have to do 2 futures here which is weird but
  Future<List<String>> getTimes() async {
    // make the request
    DatabaseMethods database = DatabaseMethods();
    List<dynamic> adds =
        await database.fetchStringArray(widget.id, 'orderedLocations');
    List<String> times = [];
    Iterable<String> dates = await loadDates();

    // loop through value
    for (String date in dates) {
      dynamic waited = await getRouteMatrix(adds, date);
      String duration = waited['routes'][0]['duration'];

      // convert seconds to minutes
      times.add((int.parse(duration.split("s")[0]) / 60).toInt().toString());

      // times.add();
    }

    // times.split("s")
    return times;
  }

  // fetch the ordered location
  // fetchStringArray(widget.id, )

  @override
  Widget build(BuildContext context) {
    // Future<List<String>> dates = getData();
    // idea is to take our collection, loop through members, and collect all dates

    // will wait until loaded and add to future builder
    Future<Iterable<String>> bestOpts = loadDates();
    // these are our addresses
    Future<List<String>> times = getTimes();

    return Scaffold(
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height, // Set a fixed height
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // back button just makes it easy for us with the simulator
              backButton(context, Colors.black12),
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: Text(
                  "Choose Your Favorite",
                  style: TextStyle(
                      fontSize: 40,
                      color: Colors.black,
                      fontFamily: 'InclusiveSans'),
                ),
              ),
              SizedBox(height: 20),
              Container(
                child: FutureBuilder(
                    future: Future.wait([bestOpts, times]),
                    builder: (context, snapshot) {
                      // here I want to create a quick array
                      if (snapshot.data == null) {
                        return const Center(
                            child: CircularProgressIndicator(
                          color: Colors.blue,
                        ));
                      }

                      List<int> arr = [];
                      for (int i = 0; i < snapshot.data![0].length; i += 1) {
                        arr.add(i);
                      }

                      return CarouselSlider(
                        options: CarouselOptions(
                          viewportFraction: 0.8,
                          height: MediaQuery.of(context).size.height * 0.3,
                          enableInfiniteScroll: false,
                        ),
                        // every time always going to be 3 options
                        items: arr.map((i) {
                          return Builder(builder: (BuildContext context) {
                            // the length of array is 0
                            print("Length of array: " +
                                snapshot.data!.length.toString());
                            return ThreeCards(
                                context,
                                snapshot.data![0].elementAt(i),
                                snapshot.data![1].elementAt(i),
                                widget.id);
                          });
                        }).toList(),
                      );
                    }),
                // yay, we should be able to load the data now!
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// date + time
// we will get time with an awesome request
Widget ThreeCards(BuildContext context, String date, String time, String id) {
  DatabaseMethods dm = DatabaseMethods();
  // instead of grey background google maps api should be present
  return Stack(alignment: Alignment.center, children: [
    Container(
        // height: MediaQuery.of(context).size.height * 0.6,
        // margin: EdgeInsets.all(40),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
          BoxShadow(
              color: Colors.grey.shade200, blurRadius: 10, spreadRadius: 10)
        ])),
    Container(
        // margin: EdgeInsets.all(40),
        child: Column(children: [
      /*Container(
          height: MediaQuery.of(context).size.height * 0.6 * 0.4,
          decoration: BoxDecoration(
            // just an example that we'll replace later
            image: DecorationImage(
                image: AssetImage('assets/gmaps.png'), fit: BoxFit.cover),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          )),*/
      Container(
        padding: EdgeInsets.all(20),
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${time} minute ride",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 30,
                    fontFamily: 'InclusiveSans',
                    fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            iconText(
                date, Icon(Icons.date_range, color: Colors.blue, size: 30)),
            SizedBox(height: 10),
            iconText("${time} minutes",
                Icon(Icons.timelapse, color: Colors.orange, size: 30)),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                // change decided date here and then navigator.push
                dm.changeDate(id, date);

                // after changed date, awesome!
                Navigator.pop(context);
              },
              child: Text("This is my favorite",
                  style: TextStyle(
                      color: Colors.blue,
                      fontFamily: 'inclusiveSans',
                      fontSize: 20)),
            )
            /*SizedBox(height: 10),
            iconText("Traffic Level: High",
                Icon(Icons.traffic, color: Colors.pink, size: 30))*/
          ],
        ),
      )
    ]))
  ]);
}

Row iconText(String txt, Icon icon) {
  return Row(
    children: [
      Stack(alignment: Alignment.center, children: [
        // create a small rounded box and a icon
        Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 10,
                    spreadRadius: 10)
              ]),
        ),
        // here's where the icon should go!
        icon
      ]),
      SizedBox(width: 15),
      Text(txt,
          style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 20,
              fontFamily: 'InclusiveSans'))
    ],
    // add Text here
  );
}
