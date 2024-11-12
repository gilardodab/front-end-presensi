import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:presensi/presentation/provider/cuti_provider.dart';

class CutiPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cuti')),
      body: Consumer<CutiProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(child: Text(provider.errorMessage!));
          }

          return ListView.builder(
            itemCount: provider.cutiData.length,
            itemBuilder: (context, index) {
              final cuti = provider.cutiData[index];
              return ListTile(
                title: Text("Mulai: ${cuti.start} - Akhir: ${cuti.end}"),
                subtitle: Text("Status: ${cuti.status == 1 ? "Disetujui" : "Menunggu"}"),
              );
            },
          );
        },
      ),
    );
  }
}
