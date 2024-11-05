import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Todo {
  String id;
  String title;

  Todo({required this.id, required this.title});

  // Konstruktor untuk membuat objek Todo dari dokumen Firestore
  Todo.fromDocument({required Map<String, dynamic> doc, required this.id})
      : title = doc['title'];

  // Method untuk mengubah objek Todo menjadi Map agar bisa disimpan di Firestore
  Map<String, dynamic> toMap() {
    return {'title': title};
  }
}

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({Key? key}) : super(key: key);

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  // Referensi ke koleksi 'todos' di Firestore
  final CollectionReference<Object?> todos =
      FirebaseFirestore.instance.collection('todos');

  // Variabel untuk menyimpan judul task baru
  String newTask = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do List'),
      ),
      body: StreamBuilder<QuerySnapshot<Object?>>(
        stream: todos.snapshots(), // Mendengarkan perubahan data di Firestore
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Mengubah dokumen Firestore menjadi objek Todo
          final List<Todo> todoList = snapshot.data!.docs
              .map<Todo>((doc) => Todo.fromDocument(
                  doc: doc.data() as Map<String, dynamic>, id: doc.id))
              .toList();

          return ListView.builder(
            itemCount: todoList.length,
            itemBuilder: (BuildContext context, int index) {
              var todo = todoList[index];
              return ListTile(
                title: Text(todo.title),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    // Menghapus task dari Firestore
                    todos.doc(todo.id).delete();
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => addTodoDialog(context: context),
        child: const Icon(Icons.add),
      ),
    );
  }

  // Fungsi untuk menampilkan dialog penambahan task baru
  void addTodoDialog({required BuildContext context}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Task'),
          content: TextField(
            onChanged: (String value) {
              newTask = value;
            },
            decoration: const InputDecoration(hintText: "Enter task title"),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                if (newTask.isNotEmpty) {
                  // Membuat objek Todo baru dan menyimpannya ke Firestore
                  var newTodo = Todo(id: '', title: newTask);
                  todos.add(newTodo.toMap());
                  newTask = ''; // Mengosongkan input field
                  Navigator.pop(context);
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }
}
