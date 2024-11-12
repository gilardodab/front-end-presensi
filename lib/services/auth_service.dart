import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl =
      "http://karyawanku.online/api/yf"; // Ganti dengan URL backend Anda

  // Fungsi untuk login
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse("$baseUrl/login");
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['status'] == 'success') {
      // Simpan token di shared_preferences jika login berhasil
      if (data.containsKey('token')) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
      }
      return data; // Berhasil login
    } else {
      // Gagal login, kembalikan respons dari API dengan pesan error
      return {
        'status': 'error',
        'message': data['message'] ?? 'Login failed',
      };
    }
  }

  // Fungsi untuk logout dan menghapus token dari shared_preferences
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token'); // Hapus token
  }

  // Fungsi untuk mendapatkan data karyawan berdasarkan token
  Future<Map<String, dynamic>> getEmployeeData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    // Periksa apakah token ada
    if (token == null) {
      throw Exception('No token found. Please login.');
    }

    final url = Uri.parse("$baseUrl/karyawan/data"); // Pastikan URL sudah benar
    final response = await http.get(
      url,
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Pastikan data memiliki struktur yang diharapkan
      if (data['status'] == 'success' && data.containsKey('data')) {
        return data['data']; // Mengembalikan hanya bagian data
      } else {
        throw Exception('Employee data not found');
      }
    } else if (response.statusCode == 401) {
      // Jika token tidak valid atau tidak terautentikasi
      throw Exception('Unauthorized. Please login again.');
    } else {
      throw Exception('Failed to load employee data');
    }
  }

  Future<List<Map<String, dynamic>>> getWeeklyPresenceData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('No token found. Please login.');
    }

    final url = Uri.parse("$baseUrl/presensi/seminggu");
    final response = await http.get(
      url,
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (responseData['status'] == 'success') {
        return List<Map<String, dynamic>>.from(responseData['data']);
      } else {
        throw Exception(responseData['message'] ?? 'Failed to load data');
      }
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized. Please login again.');
    } else {
      throw Exception('Failed to load presence data');
    }
  }

  Future<String> sendPresenceData(
      File image, double latitude, double longitude) async {
    // Mendapatkan instance SharedPreferences untuk akses token
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    // Validasi token
    if (token == null) {
      throw Exception('No token found. Please login.');
    }

    // URL endpoint untuk mengirim presensi dengan selfie
    final url = Uri.parse("$baseUrl/presensi/selfie");

    // Membaca file gambar dan mengonversinya menjadi string Base64
    List<int> imageBytes = await image.readAsBytes();
    String base64Image = base64Encode(imageBytes);

    // Membuat request POST dengan mengirim gambar sebagai string Base64
    var response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'picture':
            base64Image, // Mengirim gambar dalam format Base64 sebagai string
      }),
    );

    // Memeriksa status response
    if (response.statusCode == 201) {
      return 'success';
    } else {
      // Mengembalikan pesan error jika ada
      return response.body.isNotEmpty
          ? response.body
          : 'Failed to record presence';
    }
  }

  Future<Map<String, dynamic>> updatePassword(String newPassword) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    // Check if token exists
    if (token == null) {
      return {
        'status': 'error',
        'message': 'No token found. Please login.',
      };
    }

    final url = Uri.parse(
        "$baseUrl/karyawan/update-password-user"); // Ensure URL matches your backend
    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        'employees_password': newPassword,
        'employees_password_confirmation':
            newPassword, // Assuming confirmation is required
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['status'] == 'success') {
      return {
        'status': 'success',
        'message': data['message'] ?? 'Password updated successfully',
      };
    } else {
      return {
        'status': 'error',
        'message': data['message'] ?? 'Failed to update password',
      };
    }
  }

  //update profile employees_code and employees_name
  Future<Map<String, dynamic>> updateProfile(String phone, String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    // Check if token exists
    if (token == null) {
      return {
        'status': 'error',
        'message': 'No token found. Please login.',
      };
    }
    try {
      final url = Uri.parse(
          "$baseUrl/karyawan/update-profile-user"); // Ensure URL matches your backend
      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          'employees_code': phone,
          'employees_name': name,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        return {
          'status': 'success',
          'message': data['message'] ?? 'Profile Berhasil Di Ubah',
        };
      } else {
        return {
          'status': 'error',
          'message': data['message'] ?? 'Failed to update profile',
        };
      }
    } on SocketException {
      // Catch network-related errors
      return {
        'status': 'error',
        'message': 'Gagal Tidak Ada Koneksi Internet',
      };
    } catch (e) {
      // Catch other errors
      return {
        'status': 'error',
        'message': 'An unexpected error occurred',
      };
    }
  }

  //load data cuti employee
  Future<List<Map<String, dynamic>>> loadCutiData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('No token found. Please login.');
    }

    final url = Uri.parse("$baseUrl/cuti/data-cuti");
    final response = await http.get(
      url,
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (responseData['status'] == 'success') {
        return List<Map<String, dynamic>>.from(responseData['data']);
      } else {
        throw Exception(responseData['message'] ?? 'Gagal Memuat data Cuti');
      }
    } else {
      throw Exception('Gagal Memuat data Cuti');
    }
  }

  // Method untuk menambah data cuti
    Future<Map<String, dynamic>> addCuti({
      
    required String cutyStart,
    required String cutyEnd,
    required String dateWork,
    required int cutyTotal,
    String? cutyDescription,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    // Check if token exists
    if (token == null) {
      return {
        'status': 'error',
        'message': 'No token found. Please login.',
      };
    }
    try {
      final url = Uri.parse(
          "$baseUrl/cuti/tambah-data-cuti"); // Ensure URL matches your backend
      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: json.encode({
          "cuty_start": cutyStart,
          "cuty_end": cutyEnd,
          "date_work": dateWork,
          "cuty_total": cutyTotal,
          "cuty_description": cutyDescription,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        return {
          'status': 'success',
          'message': data['message'] ?? 'Data Cuti Berhasil Ditambahkan',
          'data': data['data'] ?? {},
        };
      } else {
        return {
          'status': 'error',
          'message': data['message'] ?? 'Gagal Menambah Data Cuti',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Gagal Menambah Data Cuti: $e',
      };
    }
  }

    Future<Map<String, dynamic>> editCuti({
    required int cutyId,
    required String cutyStart,
    required String cutyEnd,
    required String dateWork,
    required int cutyTotal,
    String? cutyDescription,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    // Check if token exists
    if (token == null) {
      return {
        'status': 'error',
        'message': 'No token found. Please login.',
      };
    }

    try {
      final url = Uri.parse("$baseUrl/cuti/edit-data-cuti/$cutyId");
      final response = await http.put(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: json.encode({
          "cuty_start": cutyStart,
          "cuty_end": cutyEnd,
          "date_work": dateWork,
          "cuty_total": cutyTotal,
          "cuty_description": cutyDescription,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        return {
          'status': 'success',
          'message': data['message'] ?? 'Data Cuti Berhasil Diupdate',
          'data': data['data'] ?? {}, // Use empty map if data is null
        };
      } else {
        return {
          'status': 'error',
          'message': data['message'] ?? 'Gagal Mengupdate Data Cuti',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Gagal Mengupdate Data Cuti: $e',
      };
    }
  }

  Future<Map<String, dynamic>> deleteCuti(int cutyId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    // Check if token exists
    if (token == null) {
      return {
        'status': 'error',
        'message': 'No token found. Please login.',
      };
    }

    try {
      final url = Uri.parse("$baseUrl/cuti/hapus-data-cuti/$cutyId");
      final response = await http.delete(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        return {
          'status': 'success',
          'message': data['message'] ?? 'Data cuti berhasil dihapus',
        };
      } else {
        return {
          'status': 'error',
          'message': data['message'] ?? 'Gagal menghapus data cuti',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Gagal menghapus data cuti: $e',
      };
    }
  }

}
