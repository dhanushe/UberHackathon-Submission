import 'package:carpool/AppColors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share_plus/share_plus.dart';

class CarpoolCard extends StatelessWidget {
  // pass in carpool card code
  CarpoolCard({
    super.key,
    required this.address,
    required this.totalPeopleCount,
    required this.undecidedDate,
    required this.code,
  });

  String address;
  int totalPeopleCount = 5;
  String undecidedDate;
  String code;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        // borderRadius: BorderRadius.circular(16),
        borderRadius: BorderRadius.circular(30),
        // Shadow
        boxShadow: [
          BoxShadow(
            color: AppColors.containerShadowColor,
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.0),
          // Trip Title
          Row(
            children: [
              Text(
                // 'Tambark Creek Trip',
                '${address}',
                style: TextStyle(
                  color: AppColors.darkTextColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              // Disclose Icon
              const Spacer(),
              Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.deepPurpleColor,
              ),
            ],
          ),
          SizedBox(height: 8),

          Row(
            children: [
              // Font Awesome Icon
              FaIcon(
                FontAwesomeIcons.locationDot,
                color: AppColors.lightBlueColor,
                size: 16,
              ),
              SizedBox(width: 8),
              // Trip Location
              Text(
                // 'Tambark Creek Park',
                '${address}',
                style: TextStyle(
                  color: AppColors.lightBlueColor,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          Row(
            children: [
              // Font Awesome Icon
              FaIcon(
                FontAwesomeIcons.calendarAlt,
                color: AppColors.lightBlueColor,
                size: 16,
              ),

              SizedBox(width: 8),

              // Trip Date
              Text(
                (undecidedDate == '') ? 'Undecided' : undecidedDate,
                style: TextStyle(
                  color: AppColors.lightBlueColor,
                  fontSize: 16,
                ),
              ),
            ],
          ),

          // Trip Total People Count
          Row(
            children: [
              // Font Awesome Icon
              FaIcon(
                FontAwesomeIcons.userGroup,
                color: AppColors.lightBlueColor,
                size: 16,
              ),

              SizedBox(width: 8),

              // Trip Date
              Text(
                // '5',
                '${totalPeopleCount}',
                style: TextStyle(
                  color: AppColors.lightBlueColor,
                  fontSize: 16,
                ),
              ),
            ],
          ),

          GestureDetector(
            onTap: () {
              Share.share("Go join my trip with the code: ${code}");
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.slightlyDarkerBGColor,
                borderRadius: BorderRadius.circular(16),
              ),
              width: 105,
              child: Row(
                children: [
                  // Font Awesome Icon
                  FaIcon(
                    FontAwesomeIcons.share,
                    color: AppColors.darkTextColor,
                    size: 16,
                  ),

                  SizedBox(width: 8),

                  // Trip Date
                  Text(
                    'Share',
                    style: TextStyle(
                      color: AppColors.darkTextColor,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16.0),

          // Button to Generate Plan
          Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 16,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            decoration: BoxDecoration(
              color: AppColors.lightTextColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Container(
              child: Center(
                child: Text(
                  'Generate Plan',
                  style: TextStyle(
                    color: AppColors.darkTextColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
