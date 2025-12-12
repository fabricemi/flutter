class Commentaire {
  final String contenu;
  int? lieu_id;

  Commentaire(this.contenu, this.lieu_id);

  Map<String, Object?> toMap() {
    return {"lieu_id": lieu_id, "texte": contenu};
  }
}

class Note {
  final int note;
  int? lieu_id;

  Note(this.note, this.lieu_id);

  Map<String, Object?> toMap() {
    return {"lieu_id": lieu_id, "note": note};
  }
}
