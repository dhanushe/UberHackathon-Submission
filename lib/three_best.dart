import 'package:flutter/material.dart';

class ThreeBest extends StatefulWidget {
  const ThreeBest({super.key});

  @override
  State<ThreeBest> createState() => _ThreeBestState();
}

// if you click into, it should zoom into the actual map
class _ThreeBestState extends State<ThreeBest> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height, // Set a fixed height
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                  child: CarouselSlider(
                options: CarouselOptions(
                  viewportFraction: 0.8,
                  height: MediaQuery.of(context).size.height * 0.6,
                  enableInfiniteScroll: false,
                ),
                items: [1, 2, 3].map((i) {
                  return Builder(builder: (BuildContext context) {
                    return ThreeCards(context);
                  });
                }).toList(),
              )),
            ],
          ),
        ),
      ),
    );
  }
}

Widget ThreeCards(BuildContext context) {
  // instead of grey background google maps api should be present
  return Stack(children: [
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
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
          height: MediaQuery.of(context).size.height * 0.6 * 0.4,
          decoration: BoxDecoration(
            // just an example that we'll replace later
            image: DecorationImage(
                image: AssetImage('assets/gmaps.png'), fit: BoxFit.cover),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          )),
      Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("20 minute ride",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 30,
                    fontFamily: 'InclusiveSans',
                    fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            iconText("Sat Sept 16",
                Icon(Icons.date_range, color: Colors.blue, size: 30)),
            SizedBox(height: 10),
            iconText("3 - 5 pm",
                Icon(Icons.timelapse, color: Colors.orange, size: 30)),
            SizedBox(height: 10),
            iconText("Traffic Level: High",
                Icon(Icons.traffic, color: Colors.pink, size: 30))
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