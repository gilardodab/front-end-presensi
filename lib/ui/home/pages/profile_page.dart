import 'package:flutter/material.dart';
import 'package:presensi/services/auth_service.dart';
import '../../../core/core.dart';
import '../../auth/login_page.dart';
import 'edit_profile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String employeeName = 'Loading...';
  String employeeEmail = 'Loading...';
  String employeeNoHP = 'Loading...';
  final AuthService authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadEmployeeData(); // Panggil fungsi untuk mengambil data saat halaman dimuat
  }

  // Fungsi untuk mengambil data karyawan
  Future<void> _loadEmployeeData() async {
    try {
      final response = await authService.getEmployeeData();
      setState(() {
        employeeName = response['employees_name'] ?? 'Guest';
        employeeEmail = response['employees_email'] ?? 'No Email';
        employeeNoHP = response['employees_code'] ?? 'No HP';
      });
    } catch (e) {
      print('Failed to load employee data: $e');
      setState(() {
        employeeName = 'Guest';
        employeeEmail = 'No Email';
        employeeNoHP = 'No HP';
      });
    }
  }

  // Fungsi untuk menangani logout dengan konfirmasi
  Future<void> _confirmLogout(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah Anda yakin ingin keluar dari akun ini?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog jika "Batal" diklik
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Tutup dialog sebelum logout
                await _handleLogout(context); // Panggil fungsi logout
              },
              child: const Text('Ya'),
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk menangani proses logout
  Future<void> _handleLogout(BuildContext context) async {
    try {
      await authService.logout(); // Memanggil fungsi logout di AuthService
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } catch (e) {
      print('Logout failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: Assets.images.bgHome.provider(),
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
          child: ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              const Text(
                'Profile',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SpaceHeight(25.0),
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100.0),
                        child: Image.network(
                          'https://i.pinimg.com/originals/1b/14/53/1b14536a5f7e70664550df4ccaa5b231.jpg',
                          width: 120.0,
                          height: 120.0,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {},
                      icon: Assets.icons.edit.svg(),
                    ),
                  ],
                ),
              ),
              const SpaceHeight(20.0),
              // Menampilkan employeeEmail yang dinamis
              Text(
                '$employeeEmail | $employeeNoHP',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color.fromARGB(255, 255, 255, 255),
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SpaceHeight(80.0),
              const Text(
                'Account',
                style: TextStyle(
                  color: AppColors.primary,
                ),
              ),
              const SpaceHeight(4.0),
              ListTile(
                onTap: () {
                  context.push(EditProfilePage());
                },
                title: const Text('Edit Profile'),
                trailing: const Icon(Icons.chevron_right),
              ),
              const Divider(
                color: AppColors.stroke,
                height: 2.0,
              ),
              // ListTile(
              //   onTap: () {},
              //   title: const Text('Jabatan'),
              //   trailing: const Icon(Icons.chevron_right),
              // ),
              // const Divider(
              //   color: AppColors.stroke,
              //   height: 2.0,
              // ),
              // ListTile(
              //   onTap: () {},
              //   title: const Text('Perangkat Terdaftar'),
              //   trailing: const Icon(Icons.chevron_right),
              // ),
              const Divider(
                color: AppColors.stroke,
                height: 2.0,
              ),
              ListTile(
                onTap: () =>
                    _confirmLogout(context), // Panggil dialog konfirmasi logout
                title: const Text('Logout'),
                trailing: const Icon(Icons.logout),
              ),
              const Divider(
                color: AppColors.stroke,
                height: 2.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
