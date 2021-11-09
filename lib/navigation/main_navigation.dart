import 'package:coworking/models/meeting.dart';
import 'package:coworking/models/pin.dart';
import 'package:coworking/screens/login/login_widget.dart';
import 'package:coworking/screens/map/map.dart';
import 'package:coworking/screens/map/pin/pin_widget.dart';
import 'package:coworking/screens/meetings/meeting_info.dart';
import 'package:coworking/screens/meetings/meetings.dart';
import 'package:coworking/screens/meetings/new_meeting_form.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class MainNavigationRouteNames {
  static const auth = 'auth';
  static const mapScreen = '/map';
  static const pinDetails = '/map/pin';
  static const meetingsScreen = '/meetings';
  static const meetingDetails = '/meetings/details';
  static const meetingCreate = '/meetings/create';
}

class MainNavigation {
  String initialRoute = MainNavigationRouteNames.auth;
  final routes = <String, Widget Function(BuildContext)>{
    MainNavigationRouteNames.auth: (context) => LoginScreen(),
    MainNavigationRouteNames.meetingsScreen: (context) =>
        const UserMeetingsPage(),
    MainNavigationRouteNames.meetingCreate: (context) => const NewMeetingForm(),
  };

  Route<Object> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case MainNavigationRouteNames.mapScreen:
        final arguments = settings.arguments;
        if (arguments == null) {
          return MaterialPageRoute(builder: (context) => MapPage());
        }
        final map = arguments as LatLng;
        return MaterialPageRoute(
            builder: (context) => MapPage(
                  currentMapPosition: map,
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
          builder: (context) => PinWidget(pin),
        );
      default:
        const widget = Text('Navigation error');
        return MaterialPageRoute(builder: (context) => widget);
    }
  }
}
