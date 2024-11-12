import 'package:flutter/material.dart';
import 'package:presensi/services/auth_service.dart'; // Make sure this path is correct

class EditProfilePage extends StatefulWidget {
  EditProfilePage({Key? key}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController positionController = TextEditingController();
  final TextEditingController workTimeController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController employeeCodeController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  late Future<void> _loadEmployeeDataFuture;

  final AuthService authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadEmployeeDataFuture = _loadEmployeeData();
  }

  Future<void> _loadEmployeeData() async {
    try {
      final data = await authService.getEmployeeData();
      setState(() {
        phoneController.text = data['employees_code'] ?? '';
        nameController.text = data['employees_name'] ?? '';
        // positionController.text = data['position']['position_name'] ?? '';
        // workTimeController.text = data['shift']['shift_name'] ?? '';
        // locationController.text = data['building']['name'] ?? '';
        employeeCodeController.text = data['employees_email'] ?? '';
      });
    } catch (e) {
      print("Error loading employee data: $e");
    }
  }

  Future<void> _updatePassword() async {
    final newPassword = newPasswordController.text;

    if (newPassword.isEmpty) {
      _showMessage('Masukan Password Baru', isSuccess: false);
      return;
    }

    final result = await authService.updatePassword(newPassword);

    _showMessage(result['message'], isSuccess: result['status'] == 'success');
  }

  Future<void> _updateProfile() async {
    final phone = phoneController.text;
    final name = nameController.text;

    if (phone.isEmpty ) {
      _showMessage('Masukan Nomor Telepon', isSuccess: false);
      return;
    }

    if (name.isEmpty) {
      _showMessage('Masukan Nama', isSuccess: false);
      return;
    }

    final result = await authService.updateProfile(phone, name);

    _showMessage(result['message'], isSuccess: result['status'] == 'success');
  }

  void _showMessage(String message, {bool isSuccess = false}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isSuccess ? 'Success' : 'Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: FutureBuilder<void>(
        future: _loadEmployeeDataFuture,
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
                  const Text(
                    'Profile',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                  ),
                  const SizedBox(height: 16.0),
                  _buildProfileField("No. HP", phoneController),
                  _buildProfileField("Nama", nameController),
                  const SizedBox(height: 16.0),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // Save Profile function here if needed
                        _updateProfile();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 60.0, vertical: 14.0),
                      ),
                      child: const Text("Save"),
                    ),
                  ),
                  const SizedBox(height: 32.0),
                  const Text(
                    'Update Password',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                  ),
                  const SizedBox(height: 16.0),
                  _buildPasswordField("Email", employeeCodeController, isReadOnly: true),
                  _buildPasswordField("New Password", newPasswordController),
                  const SizedBox(height: 16.0),
                  Center(
                    child: ElevatedButton(
                      onPressed: _updatePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 60.0, vertical: 14.0),
                      ),
                      child: const Text("Save"),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildProfileField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14.0, color: Colors.black54),
          ),
          const SizedBox(height: 8.0),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller, {bool isReadOnly = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14.0, color: Colors.black54),
          ),
          const SizedBox(height: 8.0),
          TextField(
            controller: controller,
            obscureText: label == "New Password" && !_isPasswordVisible,
            readOnly: isReadOnly,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              suffixIcon: label == "New Password"
                  ? IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
