import 'package:coworking/utils/map_url.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapButton extends StatelessWidget {
  const GoogleMapButton({required this.location, super.key});
  final LatLng location;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: ElevatedButton(
        onPressed: () {
          MapUrl.openMap(location.latitude, location.longitude);
        },
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(Colors.blueAccent),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
        child: const Text(
          'Показать на Гугл Картах',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
