import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/components/globals.dart';
import 'package:pamfurred/providers/search_results_provider.dart';
import 'package:pamfurred/providers/serviceprovider_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final FocusNode _focusNode = FocusNode(); // FocusNode for TextField
  List<String> filteredSuggestions = [];

  late TextEditingController _searchController;

  // Fetch service names based on the selected category
  Future<List<String>> fetchServiceNamesByCategory(String category) async {
    final response = await Supabase.instance.client
        .from('distinct_services') // Query the service_names view
        .select('service_name')
        .eq('category_name', category);
    return List<String>.from(
        response.map((service) => service['service_name'] as String));
  }

  // Fetch package names based on the selected category
  Future<List<String>> fetchPackageNamesByCategory(String category) async {
    final response = await Supabase.instance.client
        .from('distinct_package_names') // Query the distinct_package_names view
        .select('package_name')
        .eq('category_name', category);

    return List<String>.from(
        response.map((pkg) => pkg['package_name'] as String)); // Corrected here
  }

  // Fetch both services and packages and filter based on the query
  void _filterSuggestions(String query, String category) async {
    try {
      final category = ref.watch(selectedHomeScreenSpCategoryProvider);
      final serviceNames = await fetchServiceNamesByCategory(category);
      final packageNames = await fetchPackageNamesByCategory(category);

      // Filter and limit the suggestions to 10 items
      setState(() {
        filteredSuggestions = [
          ...serviceNames.where(
              (service) => service.toLowerCase().contains(query.toLowerCase())),
          ...packageNames.where(
              (package) => package.toLowerCase().contains(query.toLowerCase())),
        ].take(10).toList(); // Limit the combined results to 10
      });
    } catch (error) {
      print('Error fetching services and packages: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    // Request focus on the text field as soon as the screen is loaded
    _focusNode.requestFocus();

    _searchController = TextEditingController(
        text: ref.read(searchedServicePackageProvider) ?? '');
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose(); // Dispose the FocusNode when the widget is destroyed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedCategory = ref.watch(
        selectedHomeScreenSpCategoryProvider); // Watch category from Riverpod

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 60,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Center(
              child: Row(
                children: [
                  Container(
                    width: 270,
                    child: TextField(
                      controller: _searchController,
                      focusNode: _focusNode, // Attach FocusNode to TextField
                      onChanged: (query) => _filterSuggestions(
                          query, selectedCategory), // Filter suggestions
                      decoration: InputDecoration(
                        hintText: 'Search service or package...',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(secondaryBorderRadius),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        suffixIcon: GestureDetector(
                          onTap: () {
                            _searchController.text = '';
                            ref
                                .read(searchedServicePackageProvider.notifier)
                                .state = '';
                          },
                          child: Icon(
                            CupertinoIcons.clear_circled_solid,
                            color: Colors.black,
                            size: 25,
                          ),
                        ),
                        contentPadding: EdgeInsets.all(10),
                      ),
                    ),
                  ),
                  const SizedBox(width: secondarySizedBox),
                  TextButton(
                      onPressed: () {
                        print(_searchController.text);

                        // Update the selected service/package name in Riverpod
                        ref
                            .read(searchedServicePackageProvider.notifier)
                            .state = _searchController.text;
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Search',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(primaryColor),
                        shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(secondaryBorderRadius))),
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Suggestions List
            Expanded(
              child: ListView.builder(
                itemCount: filteredSuggestions.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(filteredSuggestions[index]),
                    onTap: () {
                      // Handle suggestion tap, e.g., navigate to details or show results
                      print('Tapped on ${filteredSuggestions[index]}');
                      _searchController.text = filteredSuggestions[index];

                      // Update the selected service/package name in Riverpod
                      ref.read(searchedServicePackageProvider.notifier).state =
                          filteredSuggestions[index];
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
