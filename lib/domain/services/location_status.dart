import 'dart:async';
import 'package:coworking/widgets/toast.dart';
import 'package:geolocator/geolocator.dart';

class LocationStatus {
  static bool locationEnabled = false;
  static bool isStarted = false;
  static bool isMapControllerConnected = false;

  static bool locationStatusChanged = false;

  static Position currentPosition = Position(
    longitude: 30.359357,
    latitude: 59.933895,
    accuracy: 0,
    altitude: 0,
    heading: 0,
    speed: 0,
    speedAccuracy: 0,
    timestamp: DateTime.now(),
    altitudeAccuracy: 0,
    headingAccuracy: 0,
  );

  static Future<Position> checkLocationPermission() async {
    isStarted = true;
    LocationPermission permission;
    locationEnabled = await Geolocator.isLocationServiceEnabled();
    if (!locationEnabled) {
      await buildToast('Пожалуйста, включите GPS для вашего удобства');
      return currentPosition;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        await buildToast('Доступ к геолокациюю запрещен');
        return currentPosition;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      await buildToast('Доступ к геолокации запрещен навсегда. Вы всегда можете изменить это в настройках приложения');
      return currentPosition;
    }

    // из-за всплывающего окна с предложением включить геолокацию сюда
    // проходим с false location
    // добавил try catch, работает супер!
    if (locationEnabled) {
      try {
        currentPosition = await Geolocator.getCurrentPosition(
          locationSettings: LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        );
      } catch (e) {
        locationEnabled = false;
        await buildToast('Пожалуйста, включите GPS для вашего удобства');
      }
    }

    return currentPosition;
  }
}
