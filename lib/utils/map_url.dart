import 'package:url_launcher/url_launcher.dart';

class MapUrl {
  static Future<void> openMap(double latitude, double longitude) async {
    final String googleUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunchUrl(Uri(path: googleUrl))) {
      await launchUrl(Uri(path: googleUrl));
    } else {
      throw Exception('Could not open the map.');
    }
  }
}
