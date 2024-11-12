import 'package:flutter/material.dart';
import 'package:presensi/data/models/cuti_model.dart';

class CutiCard extends StatelessWidget {
  final CutiModel cuti;

  const CutiCard({Key? key, required this.cuti}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text("Mulai: ${cuti.start} - Akhir: ${cuti.end}"),
        subtitle: Text("Status: ${cuti.status == 1 ? "Disetujui" : "Menunggu"}"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                // Handle edit
              },
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                // Handle delete
              },
            ),
          ],
        ),
      ),
    );
  }
}
