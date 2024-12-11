import 'package:flutter/material.dart';

class DetectableObjectsPage extends StatelessWidget {
  final List<String> labels;

  const DetectableObjectsPage({Key? key, required this.labels}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Objetos Detectables')),
      body: ListView.builder(
        itemCount: labels.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(labels[index]),
            leading: Icon(Icons.check_circle),
          );
        },
      ),
    );
  }
}
