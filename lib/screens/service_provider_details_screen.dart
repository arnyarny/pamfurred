import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ServiceProviderDetailsScreen extends StatefulWidget {
  final String sp_id;

  const ServiceProviderDetailsScreen({super.key, required this.sp_id});

  @override
  ServiceProviderDetailsScreenState createState() =>
      ServiceProviderDetailsScreenState();
}

class ServiceProviderDetailsScreenState
    extends State<ServiceProviderDetailsScreen> {
  late Future<Map<String, dynamic>> _serviceProviderFuture;

  @override
  void initState() {
    super.initState();
    _serviceProviderFuture = _fetchServiceProviderDetails(widget.sp_id);
  }

  Future<Map<String, dynamic>> _fetchServiceProviderDetails(String spId) async {
    final response = await Supabase.instance.client
        .from('service_provider')
        .select()
        .eq('sp_id', spId)
        .single();
    // Check if the response has an error based on status code
    if (response.status != 200) {
      throw Exception(
          'Failed to load service provider details: ${response.error?.message ?? "Unknown error"}');
    }

    // Ensure response data is not null before casting
    if (response.data == null) {
      throw Exception('No service provider found with the given ID.');
    }

    return response.data as Map<String, dynamic>;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Provider Details'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _serviceProviderFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: SelectableText('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('No service provider details found.'));
          }

          // Accessing fields based on your data structure
          final serviceProvider = snapshot.data!;
          final name = serviceProvider['name'] ?? 'Unknown';
          final imageUrl =
              serviceProvider['image'] ?? 'https://tinyurl.com/3tnt6yyy';
          final rating = serviceProvider['rating']?.toString() ?? 'N/A';
          final address = serviceProvider['address'] ?? 'No address provided';
          final phone = serviceProvider['phone'] ?? 'No phone number';
          final hours = serviceProvider['hours'] ?? 'No hours provided';
          final petsCatered =
              serviceProvider['pets_catered'] ?? 'No pets catered';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    imageUrl,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(child: Icon(Icons.error, size: 50));
                    },
                  ),
                ),
                const SizedBox(height: 16.0),
                Text(
                  name,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                Text('Rating: $rating'),
                const SizedBox(height: 8.0),
                Text('Address: $address'),
                const SizedBox(height: 8.0),
                Text('Phone: $phone'),
                const SizedBox(height: 8.0),
                Text('Operating Hours: $hours'),
                const SizedBox(height: 8.0),
                Text('Pets Catered: $petsCatered'),
              ],
            ),
          );
        },
      ),
    );
  }
}
