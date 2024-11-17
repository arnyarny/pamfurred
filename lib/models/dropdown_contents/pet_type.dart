import 'package:animated_custom_dropdown/custom_dropdown.dart';

class PetType with CustomDropdownListFilter {
  final String name;
  const PetType(this.name);

  @override
  String toString() {
    return name;
  }

  @override
  bool filter(String query) {
    return name.toLowerCase().contains(query.toLowerCase());
  }
}

const List<PetType> petTypeList = [
  PetType('Dog'),
  PetType('Cat'),
  PetType('Bunny')
];
