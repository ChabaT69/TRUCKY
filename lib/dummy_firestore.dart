library dummy_firestore;

class Timestamp {
  final DateTime _date;
  Timestamp(this._date);
  factory Timestamp.fromDate(DateTime date) => Timestamp(date);
  DateTime toDate() => _date;
}

class DocumentSnapshot {
  final String id;
  final Map<String, dynamic> _data;
  DocumentSnapshot(this.id, this._data);
  Map<String, dynamic> data() => _data;
}

class FirebaseFirestore {
  FirebaseFirestore._();
  static final FirebaseFirestore instance = FirebaseFirestore._();

  CollectionReference collection(String path) => CollectionReference(path);
}

class CollectionReference {
  final String path;
  CollectionReference(this.path);
  Future<void> add(Map<String, dynamic> data) async {}
}
