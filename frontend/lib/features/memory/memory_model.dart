class MemoryModel {
  final int id;
  final int petId;
  final String title;
  final String? content;
  final String? mediaUrl;
  MemoryModel({required this.id, required this.petId, required this.title, this.content, this.mediaUrl});
  factory MemoryModel.fromMap(Map<String, dynamic> map) {
    return MemoryModel(
      id: map['id'] as int,
      petId: map['pet_id'] as int,
      title: map['title'] as String,
      content: map['content'] as String?,
      mediaUrl: map['media_url'] as String?,
    );
  }
}

