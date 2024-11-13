// fetch_locations.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<Map<String, String>>> fetchLocations(String query) async {
  final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&limit=5');

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = json.decode(response.body) as List;
    return data
        .map((item) => {
              'displayName': item['display_name'] as String,
              'latitude': item['lat'] as String,
              'longitude': item['lon'] as String,
              'address': item['address']['road']?.toString() ?? '',
              'city': item['address']['city']?.toString() ?? '',
              'country': item['address']['country']?.toString() ?? '',
            })
        .toList();
  } else {
    throw Exception('Failed to load locations');
  }
}
