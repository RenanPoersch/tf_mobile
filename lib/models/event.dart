class Event {
  int? id;
  String name;
  String description;
  DateTime date;
  int eventType;
  String image;

  Event({
    this.id, 
    required this.name, 
    required this.description, 
    required this.date, 
    required this.eventType, 
    required this.image
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description, 
      'date': date.toIso8601String(),
      'eventType': eventType,
      'image': image
    };
  }

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event (
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String,
      date: DateTime.parse(map['date'] as String),
      eventType: map['eventType'] as int,
      image: map['image'] as String? ?? '',
    );
  }

  Event copyWith({
    int? id,
    String? name,
    String? description,
    DateTime? date,
    int? eventType,
    String? image,
  }) {
    return Event (
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      date: date ?? this.date,
      eventType: eventType ?? this.eventType,
      image: image ?? this.image
    );
  }
}
