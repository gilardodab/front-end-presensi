import 'package:flutter/material.dart';

class CutiForm extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Tanggal Mulai'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Masukkan tanggal mulai';
                }
                return null;
              },
            ),
            // Add other fields as needed
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState?.validate() == true) {
                  // Add logic for adding cuti
                }
              },
              child: Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
