class Registration {
  int? id;
  int userId; // FK para Usuario.id
  int eventId;  // FK para Evento.id
  bool isConfirmed;

  Registration({this.id, required this.userId, required this.eventId, required this.isConfirmed});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'eventId': eventId,
      'isConfirmed': isConfirmed ? 1 : 0
    };
  }

 factory Registration.fromMap(Map<String, dynamic> map) {
    return Registration(
      id: map['id'] as int?,
      userId: map['userId'] as int,
      eventId: map['eventId'] as int,
      isConfirmed: (map['isConfirmed'] ?? 0) == 1,
    );
  }

  Registration copyWith({
    int? id,
    int? userId, 
    int? eventId, 
    bool? isConfirmed
  }) {   
    return Registration(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      eventId: eventId ?? this.eventId,
      isConfirmed: isConfirmed ?? this.isConfirmed
    );
  }
}
