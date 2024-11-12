import 'package:presensi/core/network/api_client.dart';
import 'package:presensi/data/models/cuti_model.dart';

class CutiRepository {
  final ApiClient apiClient;

  CutiRepository(this.apiClient);

  Future<List<CutiModel>> getCutiData() async {
    try {
      final response = await apiClient.get('/cuti/data-cuti');
      return (response['data'] as List)
          .map((cuti) => CutiModel.fromJson(cuti))
          .toList();
    } catch (error) {
      print("Error fetching cuti data: $error");
      rethrow; // Rethrow the error to be handled by the caller
    }
  }

  Future<String> addCuti(CutiModel cuti) async {
    try {
      final response = await apiClient.post('/cuti/tambah-data-cuti', cuti.toJson());
      return response['message'] ?? 'Data cuti berhasil ditambahkan';
    } catch (error) {
      print("Error adding cuti data: $error");
      rethrow; // Rethrow the error to be handled by the caller
    }
  }

  Future<String> editCuti(CutiModel cuti) async {
    try {
      final response = await apiClient.put('/cuti/edit-data-cuti/${cuti.id}', cuti.toJson());
      return response['message'] ?? 'Data cuti berhasil diupdate';
    } catch (error) {
      print("Error editing cuti data: $error");
      rethrow; // Rethrow the error to be handled by the caller
    }
  }

  Future<String> deleteCuti(int id) async {
    try {
      final response = await apiClient.delete('/cuti/hapus-data-cuti/$id');
      return response['message'] ?? 'Data cuti berhasil dihapus';
    } catch (error) {
      print("Error deleting cuti data: $error");
      rethrow; // Rethrow the error to be handled by the caller
    }
  }
}
