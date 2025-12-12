class Commentaire {
  final String contenu;
  int note = 1;
  int? lieu_id;

  Commentaire(this.contenu, this.lieu_id, this.note);

  Map<String, Object?> toMap() {
    return {"lieu_id": lieu_id, "texte": contenu, "note": note};
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
