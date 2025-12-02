class PetModel {
  final int id;
  final String name;
  final String? species;
  final String? portraitUrl;
  final String? notes;

  PetModel({required this.id, required this.name, this.species, this.portraitUrl, this.notes});

  factory PetModel.fromMap(Map<String, dynamic> map) {
    return PetModel(
      id: map['id'] as int,
      name: map['name'] as String,
      species: map['species'] as String?,
      portraitUrl: map['portrait_url'] as String?,
      notes: map['notes'] as String?,
    );
  }
}

