import 'package:animated_custom_dropdown/custom_dropdown.dart';

class BunnyBreed with CustomDropdownListFilter {
  final String name;
  const BunnyBreed(this.name);

  @override
  String toString() {
    return name;
  }

  @override
  bool filter(String query) {
    return name.toLowerCase().contains(query.toLowerCase());
  }
}

const List<BunnyBreed> bunnyBreedList = [
  BunnyBreed('American'),
  BunnyBreed('Angora'),
  BunnyBreed('Belgian Hare'),
  BunnyBreed('Californian'),
  BunnyBreed('Checkered Giant'),
  BunnyBreed('Dutch'),
  BunnyBreed('Dwarf Hotot'),
  BunnyBreed('English Lop'),
  BunnyBreed('English Spot'),
  BunnyBreed('Flemish Giant'),
  BunnyBreed('French Lop'),
  BunnyBreed('Harlequin'),
  BunnyBreed('Holland Lop'),
  BunnyBreed('Jersey Wooly'),
  BunnyBreed('Lionhead'),
  BunnyBreed('Mini Lop'),
  BunnyBreed('Mini Rex'),
  BunnyBreed('Netherland Dwarf'),
  BunnyBreed('New Zealand'),
  BunnyBreed('Polish'),
  BunnyBreed('Rex'),
  BunnyBreed('Satin'),
  BunnyBreed('Silver'),
  BunnyBreed('Silver Fox'),
  BunnyBreed('Silver Marten'),
  BunnyBreed('Tan'),
];
