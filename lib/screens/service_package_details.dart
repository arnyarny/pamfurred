import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/providers/service_details_provider.dart';
import 'package:pamfurred/providers/service_package_details_provider.dart';

class ServicePackageDetails extends ConsumerWidget {
  const ServicePackageDetails({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicePackageId = ref.watch(selectedServicePackageIdProvider);
    final details = ref.watch(servicePackageDetailsProvider(servicePackageId));

    return Scaffold(
      appBar: AppBar(title: const Text('Details')),
      body: details.when(
        data: (item) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                CachedNetworkImage(
                    imageUrl: item.imageUrl,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover),
                const SizedBox(height: 16),
                Text('Provider: ${item.spName}',
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text('Type: ${item.type}',
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text('Price: \$${item.price}',
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text('Rating: ${item.averageRating}',
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text('Location: (${item.latitude}, ${item.longitude})',
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text('Sentiment: ${item.sentimentLabel}',
                    style: const TextStyle(fontSize: 18)),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
