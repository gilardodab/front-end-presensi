import 'package:flutter/material.dart';
import 'package:presensi/data/models/cuti_model.dart';
import 'package:presensi/domain/usecases/get_cuti.dart';

class CutiProvider extends ChangeNotifier {
  final GetCuti getCuti;
  List<CutiModel> cutiData = [];
  bool isLoading = false;
  String? errorMessage;

  CutiProvider(this.getCuti);

  Future<void> fetchCutiData() async {
    isLoading = true;
    errorMessage = null; // Reset error message setiap kali fetch data
    notifyListeners();

    try {
      // Mengambil data cuti
      cutiData = await getCuti.execute();
    } catch (error) {
      // Tangani error dan simpan pesan errornya
      errorMessage = 'Gagal memuat data cuti. Silakan coba lagi.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
