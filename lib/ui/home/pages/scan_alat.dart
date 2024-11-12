import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';


class ScanAlatPage extends StatefulWidget {
  const ScanAlatPage({Key? key}) : super(key: key);

  @override
  _ScanAlatPageState createState() => _ScanAlatPageState();
}

class _ScanAlatPageState extends State<ScanAlatPage> {
  String? scanResult;
  DateTime scanDateTime = DateTime.now();

  // Fungsi untuk melakukan pemindaian QR code
  Future<void> _scanQRCode() async {
    try {
      var result = await BarcodeScanner.scan();
      setState(() {
        scanResult = result.rawContent;
        scanDateTime = DateTime.now();
      });
    } catch (e) {
      setState(() {
        scanResult = 'Scan dibatalkan';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Alat'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tab Bar (Scan dan Riwayat)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTabItem('Scan', true),
                _buildTabItem('Riwayat', false),
              ],
            ),
            const SizedBox(height: 16.0),

            // Kartu Informasi Pemindaian
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ikon dan Tanggal/Waktu Pemindaian
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.qr_code, color: Colors.orange, size: 40),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            DateFormat('dd MMM yyyy').format(scanDateTime),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          ),
                          Text(
                            DateFormat('hh:mm:ss a').format(scanDateTime),
                            style: const TextStyle(
                              fontSize: 14.0,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),

                  // Lokasi (Contoh data lokasi, bisa diganti dengan lokasi aktual)
                  const Text(
                    'Lokasi Anda: Daerah Istimewa Yogyakarta',
                    style: TextStyle(fontSize: 14.0, color: Colors.black54),
                  ),
                  const SizedBox(height: 4.0),
                  const Text(
                    'Lokasi Anda: -7.8151698, 110.44489',
                    style: TextStyle(fontSize: 14.0, color: Colors.black54),
                  ),
                  const SizedBox(height: 16.0),

                  // Hasil Scan Barcode
                  const Text(
                    'Barcode:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
                  ),
                  const SizedBox(height: 8.0),
                  Container(
                    color: Colors.black12,
                    width: double.infinity,
                    height: 200,
                    child: scanResult != null
                        ? Center(child: Text(scanResult!, style: const TextStyle(fontSize: 16.0)))
                        : const Center(child: Text('Belum ada hasil scan')),
                  ),
                  const SizedBox(height: 8.0),

                  // Informasi Customer (placeholder)
                  const Text(
                    'Customers:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),

            // Menampilkan QR Code dengan QrImage

            // Tombol untuk Memulai Pemindaian QR Code
            SizedBox(
              width: double.infinity, // Make the button full-width
              child: ElevatedButton.icon(
                onPressed: _scanQRCode,
                icon: const Icon(Icons.qr_code_scanner),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
                label: const Text('Pemindaian QR Code'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi untuk membangun item tab bar
  Widget _buildTabItem(String title, bool isActive) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.purple : Colors.black54,
          ),
        ),
        if (isActive)
          Container(
            margin: const EdgeInsets.only(top: 4.0),
            height: 3.0,
            width: 40.0,
            color: Colors.purple,
          ),
      ],
    );
  }
}