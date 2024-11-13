import 'package:animated_custom_dropdown/custom_dropdown.dart';

class CatBreed with CustomDropdownListFilter {
  final String name;
  const CatBreed(this.name);

  @override
  String toString() {
    return name;
  }

  @override
  bool filter(String query) {
    return name.toLowerCase().contains(query.toLowerCase());
  }
}

const List<CatBreed> catBreedList = [
  CatBreed('Abyssinian'),
  CatBreed('American Bobtail'),
  CatBreed('American Curl'),
  CatBreed('American Shorthair'),
  CatBreed('American Wirehair'),
  CatBreed('Balinese'),
  CatBreed('Bengal'),
  CatBreed('Birman'),
  CatBreed('Bombay'),
  CatBreed('British Shorthair'),
  CatBreed('Burmese'),
  CatBreed('Burmilla'),
  CatBreed('Chartreux'),
  CatBreed('Cornish Rex'),
  CatBreed('Cymric'),
  CatBreed('Devon Rex'),
  CatBreed('Egyptian Mau'),
  CatBreed('Exotic Shorthair'),
  CatBreed('Himalayan'),
  CatBreed('Japanese Bobtail'),
  CatBreed('Javanese'),
  CatBreed('Korat'),
  CatBreed('LaPerm'),
  CatBreed('Maine Coon'),
  CatBreed('Manx'),
  CatBreed('Munchkin'),
  CatBreed('Norwegian Forest Cat'),
  CatBreed('Ocicat'),
  CatBreed('Oriental Shorthair'),
  CatBreed('Persian'),
  CatBreed('Pixie-bob'),
  CatBreed('Ragdoll'),
  CatBreed('Russian Blue'),
  CatBreed('Scottish Fold'),
  CatBreed('Selkirk Rex'),
  CatBreed('Siamese'),
  CatBreed('Siberian'),
  CatBreed('Singapura'),
  CatBreed('Snowshoe'),
  CatBreed('Somali'),
  CatBreed('Sphynx'),
  CatBreed('Tonkinese'),
  CatBreed('Turkish Angora'),
  CatBreed('Turkish Van'),
];
