import 'package:animated_custom_dropdown/custom_dropdown.dart';

class Sex with CustomDropdownListFilter {
  final String name;
  const Sex(this.name);

  @override
  String toString() {
    return name;
  }

  @override
  bool filter(String query) {
    return name.toLowerCase().contains(query.toLowerCase());
  }
}

const List<Sex> sexList = [
  Sex('Male'),
  Sex('Female')
];
