import 'package:flutter/material.dart';
import 'package:presensi/services/auth_service.dart'; // Pastikan AuthService memiliki fungsi getEmployeeData
import '../../../core/core.dart';
import '../widgets/menu_button.dart';
import 'attendance_page.dart';
import 'callplan_page.dart';
import 'cuti_page.dart';
import 'history_page.dart';
import 'kunjungan_page.dart';
import 'notes_page.dart';
import 'notification_page.dart';
import 'permit_page.dart';
import 'scan_alat.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String employeeName = 'Loading...';
  String? shiftTimeIn;
  String? shiftTimeOut;

  final AuthService authService = AuthService();
  List<Map<String, dynamic>> attendanceData = [];

  @override
  void initState() {
    super.initState();
    _loadEmployeeData();
    _loadWeeklyPresenceData();
  }

  Future<void> _loadEmployeeData() async {
    try {
      final response = await authService.getEmployeeData();
      print('API Response: $response'); // Debugging

      setState(() {
        employeeName = response['employees_name'] ?? 'Guest';
        shiftTimeIn = response['shift']?['time_in'];
        shiftTimeOut = response['shift']?['time_out'];
      });
    } catch (e) {
      print('Failed to load employee data: $e');
      setState(() {
        employeeName = 'Guest';
        shiftTimeIn = null;
        shiftTimeOut = null;
      });
    }
  }

  Future<void> _loadWeeklyPresenceData() async {
    try {
      final data = await authService.getWeeklyPresenceData();
      setState(() {
        attendanceData = data;
      });
    } catch (e) {
      print('Failed to load weekly presence data: $e');
    }
  }

  Future<void> _refreshData() async {
    await _loadEmployeeData();
    await _loadWeeklyPresenceData();
  }

  @override
  Widget build(BuildContext context) {
    double baseFontSize = MediaQuery.of(context).textScaleFactor * 12.0;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(10.0),
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 154, 59, 218),
            ),
            child: ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(50.0),
                      child: Image.network(
                        'https://i.pinimg.com/originals/1b/14/53/1b14536a5f7e70664550df4ccaa5b231.jpg',
                        width: 48.0,
                        height: 48.0,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Text(
                        'Halo, $employeeName',
                        style: const TextStyle(
                          fontSize: 17.0,
                          color: AppColors.white,
                        ),
                        maxLines: 2,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        context.push(const NotificationPage());
                      },
                      icon: Assets.icons.notificationRounded.svg(),
                    ),
                  ],
                ),
                const SizedBox(height: 24.0),
                Container(
                  padding: const EdgeInsets.all(14.0),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 221, 221, 221),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Column(
                    children: [
                      Center (
                        child: Text(
                          'Jika Hari Ini Gagal, Cobalah Hari Selanjutnya',
                          style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: baseFontSize - 2 ,
                          color: const Color.fromARGB(255, 160, 86, 244),
                        ),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Text(
                        DateTime.now().toFormattedDate(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 0, 0, 0),
                          fontSize: baseFontSize - 2,
                        ),
                      ),
                      const SizedBox(height: 18.0),
                      const Divider(),
                      const SizedBox(height: 6.0),
                      Text(
                        '${shiftTimeIn ?? '08:00:00'} - ${shiftTimeOut ?? '16:00:00'}',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: baseFontSize,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50.0),
                GridView(
                  padding: const EdgeInsets.symmetric(horizontal: 10.10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    MenuButton(
                      label: 'Presensi',
                      iconPath: Assets.icons.menu.pulang.path,
                      onPressed: () {
                        context.push(const AttendancePage());
                      },
                    ),
                    MenuButton(
                      label: 'Kunjungan',
                      iconPath: Assets.icons.menu.kunjungan.path,
                      onPressed: () {
                        context.push(const KunjunganPage());
                      },
                    ),
                    MenuButton(
                      label: 'Cuti',
                      iconPath: Assets.icons.menu.cuti.path,
                      onPressed: () {
                        context.push(const CutiPage());
                      },
                    ),
                    MenuButton(
                      label: 'Callplan',
                      iconPath: Assets.icons.menu.callplan.path,
                      onPressed: () {
                        context.push(const CallplanPage());
                      },
                    ),
                    MenuButton(
                      label: 'Scan Alat',
                      iconPath: Assets.icons.menu.scanAlat.path,
                      onPressed: () {
                        context.push(const ScanAlatPage());
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 50.0),
                Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 160, 86, 244),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "1 Minggu Terakhir",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          
                          columnSpacing: 20.0,
                          //create center alignment
                          
                          columns: [
                            DataColumn(
                              label: Center( // Center-align the column header
                                child: Text(
                                  "Tanggal",
                                  style: TextStyle(color: Colors.white, fontSize: baseFontSize),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            DataColumn(
                                label: Center( // Center-align the column header
                                  child: Text(
                                    "Masuk",
                                    style: TextStyle(color: Colors.white, fontSize: baseFontSize),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                            ),
                            DataColumn(
                              label: Center( // Center-align the column header
                                child: Text(
                                  "Pulang",
                                  style: TextStyle(color: Colors.white, fontSize: baseFontSize),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                          rows: attendanceData.isNotEmpty
                              ? attendanceData.map((data) {
                                  return DataRow(
                                  cells: [
                            DataCell(
                              Center( // Center-align the cell content
                                child: Text(
                                  data["presence_date"] ?? '-',
                                  style: TextStyle(color: Colors.white, fontSize: baseFontSize),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            DataCell(
                              Center( // Center-align the cell content
                                child: Text(
                                  data["time_in"] ?? 'Belum Presensi',
                                  style: TextStyle(color: Colors.white, fontSize: baseFontSize),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            DataCell(
                              Center( // Center-align the cell content
                                child: Text(
                                  data["time_out"] ?? 'Belum Presensi',
                                  style: TextStyle(color: Colors.white, fontSize: baseFontSize),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        );
                          }).toList()
                        : [
                            DataRow(cells: [
                              DataCell(
                                Center(
                                  child: Text(
                                    '-',
                                    style: TextStyle(color: Colors.white, fontSize: baseFontSize),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              DataCell(
                                Center(
                                  child: Text(
                                    'Tidak Ada Data',
                                    style: TextStyle(color: Colors.white, fontSize: baseFontSize),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              DataCell(
                                Center(
                                  child: Text(
                                    '-',
                                    style: TextStyle(color: Colors.white, fontSize: baseFontSize),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ]),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
