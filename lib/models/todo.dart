import 'package:cloud_firestore/cloud_firestore.dart';

class Todo {
  String id;
  String title;

  String description;
  bool isCompleted;

  Todo(
      {required this.id,
      required this.title,
      required this.description,
      required this.isCompleted});

  factory Todo.fromDocument(DocumentSnapshot doc) {
    return Todo(
      id: doc.id,
      title: doc['title'] ?? '',
      description: doc['description'] ?? '',
      isCompleted: doc['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
    };
  }
}
