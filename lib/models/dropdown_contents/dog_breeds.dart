import 'package:animated_custom_dropdown/custom_dropdown.dart';

class DogBreed with CustomDropdownListFilter {
  final String name;
  const DogBreed(this.name);

  @override
  String toString() {
    return name;
  }

  @override
  bool filter(String query) {
    return name.toLowerCase().contains(query.toLowerCase());
  }
}

const List<DogBreed> dogBreedList = [
  DogBreed('Unknown'),
  DogBreed('Akita'),
  DogBreed('Alaskan Malamute'),
  DogBreed('Aspin'),
  DogBreed('Australian Shepherd'),
  DogBreed('Basset Hound'),
  DogBreed('Beagle'),
  DogBreed('Belgian Malinois'),
  DogBreed('Bernese Mountain Dog'),
  DogBreed('Bichon Frise'),
  DogBreed('Bloodhound'),
  DogBreed('Border Collie'),
  DogBreed('Boston Terrier'),
  DogBreed('Boxer'),
  DogBreed('Brittany Spaniel'),
  DogBreed('Bulldog'),
  DogBreed('Bull Terrier'),
  DogBreed('Cane Corso'),
  DogBreed('Cavalier King Charles Spaniel'),
  DogBreed('Chihuahua'),
  DogBreed('Chow Chow'),
  DogBreed('Cocker Spaniel'),
  DogBreed('Collie'),
  DogBreed('Dachshund'),
  DogBreed('Dalmatian'),
  DogBreed('Doberman Pinscher'),
  DogBreed('English Mastiff'),
  DogBreed('German Shepherd'),
  DogBreed('Golden Retriever'),
  DogBreed('Great Dane'),
  DogBreed('Greyhound'),
  DogBreed('Havanese'),
  DogBreed('Irish Setter'),
  DogBreed('Labrador Retriever'),
  DogBreed('Lhasa Apso'),
  DogBreed('Maltese'),
  DogBreed('Miniature Schnauzer'),
  DogBreed('Newfoundland'),
  DogBreed('Papillon'),
  DogBreed('Pekingese'),
  DogBreed('Pointer'),
  DogBreed('Pomeranian'),
  DogBreed('Poodle'),
  DogBreed('Rhodesian Ridgeback'),
  DogBreed('Rottweiler'),
  DogBreed('Saint Bernard'),
  DogBreed('Samoyed'),
  DogBreed('Scottish Terrier'),
  DogBreed('Shetland Sheepdog'),
  DogBreed('Shiba Inu'),
  DogBreed('Shih Tzu'),
  DogBreed('Siberian Husky'),
  DogBreed('Staffordshire Bull Terrier'),
  DogBreed('Vizsla'),
  DogBreed('Weimaraner'),
  DogBreed('West Highland White Terrier'),
  DogBreed('Whippet'),
  DogBreed('Yorkshire Terrier'),
];
