import 'package:flutter/material.dart';
import 'package:presensi/services/auth_service.dart';

class CutiPage extends StatefulWidget {
  const CutiPage({super.key});

  @override
  _CutiPageState createState() => _CutiPageState();
}

class _CutiPageState extends State<CutiPage> {
  final AuthService authService = AuthService();
  List<Map<String, dynamic>> cutiData = []; // List to store leave data
  late Future<void> _loadDataCutiFuture;

  @override
  void initState() {
    super.initState();
    _loadDataCutiFuture = _cutiData();
  }

  Future<void> _cutiData() async {
    try {
      final data = await authService.loadCutiData();
      setState(() {
        cutiData = data; // Save fetched data to cutiData list
      });
    } catch (e) {
      print('Failed to load cuti data: $e');
    }
  }
Future<void> _addCuti(Map<String, dynamic> cutiRequest) async {
  try {
    final response = await authService.addCuti(
      cutyStart: cutiRequest['cuty_start'],
      cutyEnd: cutiRequest['cuty_end'],
      dateWork: cutiRequest['date_work'],
      cutyTotal: cutiRequest['cuty_total'],
      cutyDescription: cutiRequest['cuty_description'],
    );

    if (response['status'] == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'])),
      );
      
      // Tambahkan data baru ke dalam daftar cutiData
      setState(() {
        cutiData.insert(0, response['data']);
      });
      
    } else {
      throw Exception(response['message']);
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}
Future<void> _deleteCuti(int cutyId) async {
  final response = await authService.deleteCuti(cutyId);
  if (response['status'] == 'success') {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(response['message'])),
    );
    setState(() {
      cutiData.removeWhere((cuti) => cuti['cuty_id'] == cutyId);
    });
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${response['message']}')),
    );
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cuti'),
        centerTitle: true,
      ),
      body: FutureBuilder<void>(
        future: _loadDataCutiFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sisa Cuti Anda: ${cutiData.length} hari/Tahun',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _showAddCutiModal(); // Open modal to add leave request
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Tambah Cuti'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Data Permohonan Cuti',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...cutiData.map((data) => _buildPermohonanCutiCard(data)).toList(),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  // Function to build a card for each leave request
  Widget _buildPermohonanCutiCard(Map<String, dynamic> data) {
    final dateStart = data["cuty_start"] ?? '-';
    final dateEnd = data["cuty_end"] ?? '-';
    final description = data["cuty_description"] ?? 'No description';
    final status = data["cuty_status"] == "1" ? "Disetujui" : "Menunggu"; // Example status

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Mulai: $dateStart",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Berakhir: $dateEnd",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  Text(
                    "Status: $status",
                    style: const TextStyle(fontSize: 14, color: Colors.blueAccent),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.green),
              onPressed: () {
                _showEditCutiModal(data); // Memanggil modal edit dengan data cuti
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                bool confirm = await _showDeleteConfirmationDialog();
                if (confirm) {
                  await _deleteCuti(data['cuty_id']);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // Function to display the modal for adding a new leave request
void _showAddCutiModal() {
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  TextEditingController returnDateController = TextEditingController();
  TextEditingController daysController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      controller.text = "${picked.toLocal()}".split(' ')[0]; // Format tanggal menjadi YYYY-MM-DD
    }
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 16.0,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Tambah Permohonan Cuti',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
              ),
              ),
              const SizedBox(height: 20),
              // Field input tanggal mulai cuti
              const Text('Mulai Cuti'),
              TextField(
                controller: startDateController,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: 'Pilih Tanggal Mulai',
                ),
                onTap: () => _selectDate(context, startDateController),
              ),
              const SizedBox(height: 20),
              // Field input tanggal akhir cuti
              const Text('Berakhir Cuti'),
              TextField(
                controller: endDateController,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: 'Pilih Tanggal Akhir',
                ),
                onTap: () => _selectDate(context, endDateController),
              ),
              const SizedBox(height: 20),
              // Field input tanggal masuk kerja
              const Text('Tanggal Masuk Kerja'),
              TextField(
                controller: returnDateController,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: 'Pilih Tanggal Masuk Kerja',
                ),
                onTap: () => _selectDate(context, returnDateController),
              ),
              const SizedBox(height: 20),
              // Field input jumlah cuti
              const Text('Jumlah Cuti'),
              TextField(
                controller: daysController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Jumlah Hari Cuti',
                ),
              ),
              const SizedBox(height: 20),
              // Field input keterangan
              const Text('Keterangan'),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Masukkan Keterangan Cuti',
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                onPressed: () {
                  if (startDateController.text.isEmpty ||
                      endDateController.text.isEmpty ||
                      returnDateController.text.isEmpty ||
                      daysController.text.isEmpty ||
                      int.tryParse(daysController.text) == null ||
                      int.parse(daysController.text) <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: 
                      Text('Lengkapi semua kolom dengan benar'),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                    Navigator.pop(context);
                    return;
                  }

                  final cutiRequest = {
                    "cuty_start": startDateController.text,
                    "cuty_end": endDateController.text,
                    "date_work": returnDateController.text,
                    "cuty_total": int.parse(daysController.text),
                    "cuty_description": descriptionController.text,
                  };
                  _addCuti(cutiRequest);
                  Navigator.pop(context);
                },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Simpan'),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
void _showEditCutiModal(Map<String, dynamic> cutiData) {
  TextEditingController startDateController = TextEditingController(text: cutiData['cuty_start']);
  TextEditingController endDateController = TextEditingController(text: cutiData['cuty_end']);
  TextEditingController returnDateController = TextEditingController(text: cutiData['date_work']);
  TextEditingController daysController = TextEditingController(text: cutiData['cuty_total'].toString());
  TextEditingController descriptionController = TextEditingController(text: cutiData['cuty_description'] ?? '');

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      controller.text = "${picked.toLocal()}".split(' ')[0];
    }
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 16.0,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Edit Permohonan Cuti',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Mulai Cuti'),
              TextField(
                controller: startDateController,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: 'Pilih Tanggal Mulai',
                ),
                onTap: () => _selectDate(context, startDateController),
              ),
              const SizedBox(height: 20),
              const Text('Berakhir Cuti'),
              TextField(
                controller: endDateController,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: 'Pilih Tanggal Akhir',
                ),
                onTap: () => _selectDate(context, endDateController),
              ),
              const SizedBox(height: 20),
              const Text('Tanggal Masuk Kerja'),
              TextField(
                controller: returnDateController,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: 'Pilih Tanggal Masuk Kerja',
                ),
                onTap: () => _selectDate(context, returnDateController),
              ),
              const SizedBox(height: 20),
              const Text('Jumlah Cuti'),
              TextField(
                controller: daysController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Jumlah Hari Cuti',
                ),
              ),
              const SizedBox(height: 20),
              const Text('Keterangan'),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Masukkan Keterangan Cuti',
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final cutyId = cutiData['cuty_id']; // Mendapatkan ID cuti
                    final response = await authService.editCuti(
                      cutyId: cutyId,
                      cutyStart: startDateController.text,
                      cutyEnd: endDateController.text,
                      dateWork: returnDateController.text,
                      cutyTotal: int.parse(daysController.text),
                      cutyDescription: descriptionController.text,
                    );
                    if (response['status'] == 'success') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(response['message'])),
                      );
                      await _cutiData(); // Refresh data setelah edit
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${response['message']}')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Simpan Perubahan'),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<bool> _showDeleteConfirmationDialog() async {
  return await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Apakah Anda yakin ingin menghapus data cuti ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      );
    },
  ) ?? false;
}

}
