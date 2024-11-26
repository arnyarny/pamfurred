import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:philippines_rpcmb/philippines_rpcmb.dart';

class TestPhilippineDropdown extends StatefulWidget {
  const TestPhilippineDropdown({super.key});

  @override
  State<TestPhilippineDropdown> createState() => _TestPhilippineDropdownState();
}

class _TestPhilippineDropdownState extends State<TestPhilippineDropdown> {
  Region? region;
  Province? province;
  Municipality? municipality;
  String? barangay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Philippines RPCMB'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          child: Column(
            children: [
              CustomDropdown<String>.search(
                decoration: CustomDropdownDecoration(
                  closedFillColor: Colors.grey.shade200,
                  expandedFillColor: Colors.white,
                  closedSuffixIcon: const Icon(Icons.arrow_drop_down),
                  expandedSuffixIcon: const Icon(Icons.arrow_drop_up),
                  closedBorder: Border.all(
                      color: Colors.grey.withOpacity(0.1), width: 0.8),
                  closedBorderRadius: BorderRadius.circular(8),
                  closedErrorBorder: Border.all(color: Colors.red),
                  closedErrorBorderRadius: BorderRadius.circular(8),
                  expandedBorder: Border.all(color: Colors.blue, width: 0.15),
                  expandedBorderRadius: BorderRadius.circular(8),
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                  noResultFoundStyle:
                      const TextStyle(color: Colors.red, fontSize: 14),
                  errorStyle: const TextStyle(color: Colors.red, fontSize: 14),
                  listItemStyle:
                      const TextStyle(color: Colors.black, fontSize: 14),
                  overlayScrollbarDecoration: const ScrollbarThemeData(
                    thumbColor: WidgetStatePropertyAll(Colors.grey),
                  ),
                ),
                hintText: 'Select Region',
                // Transform the list of regions to a list of their names
                items: philippineRegions
                    .map((region) => region.regionName)
                    .toList(),
                onChanged: (String? regionName) {
                  setState(() {
                    region = philippineRegions.firstWhere(
                      (r) => r.regionName == regionName,
                    );
                    province = null;
                    municipality = null;
                    barangay = null;
                  });
                },
              ),
              CustomDropdown<String>.search(
                decoration: CustomDropdownDecoration(
                  closedFillColor: Colors.grey.shade200,
                  expandedFillColor: Colors.white,
                  closedSuffixIcon: const Icon(Icons.arrow_drop_down),
                  expandedSuffixIcon: const Icon(Icons.arrow_drop_up),
                  closedBorder: Border.all(
                      color: Colors.grey.withOpacity(0.1), width: 0.8),
                  closedBorderRadius: BorderRadius.circular(8),
                  closedErrorBorder: Border.all(color: Colors.red),
                  closedErrorBorderRadius: BorderRadius.circular(8),
                  expandedBorder: Border.all(color: Colors.blue, width: 0.15),
                  expandedBorderRadius: BorderRadius.circular(8),
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                  noResultFoundStyle:
                      const TextStyle(color: Colors.red, fontSize: 14),
                  errorStyle: const TextStyle(color: Colors.red, fontSize: 14),
                  listItemStyle:
                      const TextStyle(color: Colors.black, fontSize: 14),
                  overlayScrollbarDecoration: const ScrollbarThemeData(
                    thumbColor: WidgetStatePropertyAll(Colors.grey),
                  ),
                ),
                hintText: 'Select Province',
                // Map provinces to their names
                items: region?.provinces.map((p) => p.name).toList() ?? [],
                onChanged: (String? name) {
                  setState(() {
                    province = region?.provinces.firstWhere(
                      (p) => p.name == name,
                    );
                    municipality = null;
                    barangay = null;
                  });
                },
              ),
              CustomDropdown<String>.search(
                decoration: CustomDropdownDecoration(
                  closedFillColor: Colors.grey.shade200,
                  expandedFillColor: Colors.white,
                  closedSuffixIcon: const Icon(Icons.arrow_drop_down),
                  expandedSuffixIcon: const Icon(Icons.arrow_drop_up),
                  closedBorder: Border.all(
                      color: Colors.grey.withOpacity(0.1), width: 0.8),
                  closedBorderRadius: BorderRadius.circular(8),
                  closedErrorBorder: Border.all(color: Colors.red),
                  closedErrorBorderRadius: BorderRadius.circular(8),
                  expandedBorder: Border.all(color: Colors.blue, width: 0.15),
                  expandedBorderRadius: BorderRadius.circular(8),
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                  noResultFoundStyle:
                      const TextStyle(color: Colors.red, fontSize: 14),
                  errorStyle: const TextStyle(color: Colors.red, fontSize: 14),
                  listItemStyle:
                      const TextStyle(color: Colors.black, fontSize: 14),
                  overlayScrollbarDecoration: const ScrollbarThemeData(
                    thumbColor: WidgetStatePropertyAll(Colors.grey),
                  ),
                ),
                hintText: 'Select Municipality',
                // Map municipalities to their names
                items:
                    province?.municipalities.map((m) => m.name).toList() ?? [],
                onChanged: (String? name) {
                  setState(() {
                    municipality = province?.municipalities.firstWhere(
                      (m) => m.name == name,
                    );
                    barangay = null;
                  });
                },
              ),
              CustomDropdown<String>.search(
                decoration: CustomDropdownDecoration(
                  closedFillColor: Colors.grey.shade200,
                  expandedFillColor: Colors.white,
                  closedSuffixIcon: const Icon(Icons.arrow_drop_down),
                  expandedSuffixIcon: const Icon(Icons.arrow_drop_up),
                  closedBorder: Border.all(
                      color: Colors.grey.withOpacity(0.1), width: 0.8),
                  closedBorderRadius: BorderRadius.circular(8),
                  closedErrorBorder: Border.all(color: Colors.red),
                  closedErrorBorderRadius: BorderRadius.circular(8),
                  expandedBorder: Border.all(color: Colors.blue, width: 0.15),
                  expandedBorderRadius: BorderRadius.circular(8),
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                  noResultFoundStyle:
                      const TextStyle(color: Colors.red, fontSize: 14),
                  errorStyle: const TextStyle(color: Colors.red, fontSize: 14),
                  listItemStyle:
                      const TextStyle(color: Colors.black, fontSize: 14),
                  overlayScrollbarDecoration: const ScrollbarThemeData(
                    thumbColor: WidgetStatePropertyAll(Colors.grey),
                  ),
                ),
                hintText: 'Select Barangay',
                items: municipality?.barangays ?? [],
                onChanged: (String? value) {
                  setState(() {
                    barangay = value;
                  });
                },
              ),
              const SizedBox(height: 32),
              Text(region?.regionName ?? ''),
              Text(province?.name ?? ''),
              Text(municipality?.name ?? ''),
              Text(barangay ?? ''),
            ],
          ),
        ),
      ),
    );
  }
}
