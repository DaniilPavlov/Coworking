import 'package:coworking/utils/map_url.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapButton extends StatelessWidget {
  final LatLng location;
  const GoogleMapButton({Key? key, required this.location}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        child: const Text(
          'Показать на Гугл Картах',
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () {
          MapUrl.openMap(location.latitude, location.longitude);
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.blueAccent),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
            ),
          ),
        ),
      ),
    );
  }
}
