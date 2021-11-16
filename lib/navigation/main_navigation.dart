import 'package:coworking/models/meeting.dart';
import 'package:coworking/models/pin.dart';
import 'package:coworking/screens/login/login_screen.dart';
import 'package:coworking/screens/map/map_screen.dart';
import 'package:coworking/screens/map/pin/pin_screen.dart';
import 'package:coworking/screens/meetings/meeting_info.dart';
import 'package:coworking/screens/meetings/meetings.dart';
import 'package:coworking/screens/meetings/new_meeting_form.dart';
import 'package:coworking/screens/menu/favourite_pins/favourite_pins_screen.dart';
import 'package:coworking/screens/menu/flagged_reviews.dart';
import 'package:coworking/screens/menu/user_reviews.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class MainNavigationRouteNames {
  static const auth = '/';
  static const mapScreen = '/map';
  static const pinDetails = '/map/pin';
  static const favouriteReviews = '/map/favourite_reviews';
  static const flaggedReviews = '/map/flagged_reviews';
  static const userReviews = '/map/user_reviews';
  // static const account = '/account';
  static const meetingsScreen = '/map/meetings';
  static const meetingDetails = '/map/meetings/details';
  static const meetingCreate = '/map/meetings/create';
}

class MainNavigation {
  String initialRoute(bool isAuth) => isAuth
      ? MainNavigationRouteNames.auth
      : MainNavigationRouteNames.mapScreen;
  final routes = <String, Widget Function(BuildContext)>{
    MainNavigationRouteNames.auth: (context) => const LoginScreen(),
    MainNavigationRouteNames.favouriteReviews: (context) =>
        const FavouritePinsScreen(),
    MainNavigationRouteNames.userReviews: (context) =>
        const UserReviewsScreen(),
    MainNavigationRouteNames.flaggedReviews: (context) =>
        const FlaggedReviewsScreen(),
    // MainNavigationRouteNames.account: (context) => AccountScreen(),
    MainNavigationRouteNames.meetingsScreen: (context) =>
        const UserMeetingsPage(),
    MainNavigationRouteNames.meetingCreate: (context) => const NewMeetingForm(),
  };

  Route<Object> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case MainNavigationRouteNames.mapScreen:
        final arguments = settings.arguments;
       
        if (arguments == null) {
          return MaterialPageRoute(builder: (context) => MapScreen());
        }
        final map = arguments as LatLng;
         print("LOCATION"+ map.toString());
        return MaterialPageRoute(
            builder: (context) => MapScreen(
                  currentMapPosition: map,
                ));
      case MainNavigationRouteNames.meetingCreate:
        final arguments = settings.arguments;
        if (arguments == null) {
          return MaterialPageRoute(
              builder: (context) => const NewMeetingForm());
        }
        final meeting = arguments as Meeting;
        return MaterialPageRoute(
            builder: (context) => NewMeetingForm(
                  meeting: meeting,
                ));
      case MainNavigationRouteNames.meetingDetails:
        final arguments = settings.arguments;
        final meeting = arguments is Meeting ? arguments : '' as Meeting;
        return MaterialPageRoute(
            builder: (context) => MeetingInfo(meeting: meeting));
      case MainNavigationRouteNames.pinDetails:
        final arguments = settings.arguments;
        final pin = arguments is Pin ? arguments : '' as Pin;
        return MaterialPageRoute(
          builder: (context) => PinScreen(pin),
        );
      default:
        const widget = Text('Navigation error');
        return MaterialPageRoute(builder: (context) => widget);
    }
  }
}
