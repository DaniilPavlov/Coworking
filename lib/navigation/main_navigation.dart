import 'package:coworking/models/meeting.dart';
import 'package:coworking/screens/login/login_widget.dart';
import 'package:coworking/screens/map/map.dart';
import 'package:coworking/screens/meetings/meeting_info.dart';
import 'package:coworking/screens/meetings/meetings.dart';
import 'package:coworking/screens/meetings/new_meeting_form.dart';
import 'package:flutter/material.dart';

abstract class MainNavigationRouteNames {
  static const auth = 'auth';
  static const mapScreen = '/map';
  static const pinDetails = '/map/pin';
  static const meetingsScreen = '/meetings';
  static const meetingDetails = '/meetings/details';
  static const meetingCreate = '/meetings/create';
}

// утащим роуты для удобного использования в отдельный файл
class MainNavigation {
  String initialRoute = MainNavigationRouteNames.auth;
  final routes = <String, Widget Function(BuildContext)>{
    MainNavigationRouteNames.auth: (context) =>  LoginScreen(),
    MainNavigationRouteNames.mapScreen: (context) => MapPage(),
    MainNavigationRouteNames.meetingsScreen: (context) =>
        const UserMeetingsPage(),
    MainNavigationRouteNames.meetingCreate: (context) => const NewMeetingForm(),
  };

  Route<Object> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case MainNavigationRouteNames.meetingDetails:
        final arguments = settings.arguments;
        final meeting = arguments is Meeting ? arguments : '' as Meeting;
        //может пересобираться несколько раз и модель будет теряться
        //поэтому модель меняем на криэйт
        return MaterialPageRoute(
            builder: (context) => MeetingInfo(meeting: meeting));
      // case MainNavigationRouteNames.pinDetails:
      // final arguments = settings.arguments;
      //   final pin = arguments is Meeting ? arguments : '' as Meeting;
      //   return MaterialPageRoute(
      //     builder: (context) => const PinInfo(pin, imgURL),
      //   );
      default:
        const widget = Text('Navigation error');
        return MaterialPageRoute(builder: (context) => widget);
    }
  }
}
