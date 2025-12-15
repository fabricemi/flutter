class Commentaire {
  int? id;
  String contenu;
  int note;
  int? lieu_id;

  Commentaire({
    this.id,
    required this.contenu,
    this.lieu_id,
    this.note = 1, // valeur par défaut
  });

  Map<String, Object?> toMap() {
    return {"id": id, "lieu_id": lieu_id, "texte": contenu, "note": note};
  }

  @override
  String toString() {
    return 'Commentaire{id: $id, contenu: $contenu, note: $note, lieu_id: $lieu_id}';
  }
}

/* class Note {
  final int note;
  int? lieu_id;

  Note(this.note, this.lieu_id);

  Map<String, Object?> toMap() {
    return {"lieu_id": lieu_id, "note": note};
  }
} */
