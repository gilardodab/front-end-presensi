import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:presensi/services/auth_service.dart';
import '../../../core/core.dart';
import 'attendance_success_page.dart';
import 'location_page.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  List<CameraDescription>? _availableCameras;
  CameraController? _controller;
  final AuthService _authService = AuthService();
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _initializeCamera() async {
    _availableCameras = await availableCameras();
    _initCamera(_availableCameras!.first);
  }

  void _initCamera(CameraDescription description) async {
    _controller = CameraController(description, ResolutionPreset.max);
    await _controller!.initialize();
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _takePicture() async {
    try {
      final image = await _controller!.takePicture();
      setState(() {
        _imageFile = File(image.path);
      });
      await _getLocationAndSendData();
    } catch (e) {
      print('Failed to take picture: $e');
    }
  }

  Future<void> _getLocationAndSendData() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    if (_imageFile != null) {
      try {
        // Check if the widget is still mounted before showing the dialog
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return const AlertDialog(
                content: Row(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(width: 20),
                    Text("Mengirim data, mohon tunggu..."),
                  ],
                ),
              );
            },
          );
        }

        // Mengirim data ke server
        final message = await _authService.sendPresenceData(
          _imageFile!,
          position.latitude,
          position.longitude,
        );

        // Check if the widget is still mounted before closing the dialog
        if (mounted) {
          Navigator.pop(context);
        }

        // Tampilkan pop-up berdasarkan hasil jika widget masih mounted
        if (message == 'success') {
          if (mounted) {
            _showMessageDialog('Success', 'Presence recorded successfully');
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AttendanceSuccessPage()));
              }
            });
          }
        } else {
          if (mounted) {
            _showMessageDialog('Error', message);
          }
        }
      } catch (e) {
        // Close the loading dialog if an error occurs and the widget is still mounted
        if (mounted) {
          Navigator.pop(context);
          _showMessageDialog('Error', 'Failed to send data: $e');
        }
      }
    }
  }

  void _showMessageDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _handleLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        return false;
      }
    }
    return true;
  }

  void _reverseCamera() {
    final lensDirection = _controller!.description.lensDirection;
    CameraDescription newDescription;
    if (lensDirection == CameraLensDirection.front) {
      newDescription = _availableCameras!.firstWhere((description) => description.lensDirection == CameraLensDirection.back);
    } else {
      newDescription = _availableCameras!.firstWhere((description) => description.lensDirection == CameraLensDirection.front);
    }
    _initCamera(newDescription);
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      body: Stack(
        children: [
          AspectRatio(
            aspectRatio: context.deviceWidth / context.deviceHeight,
            child: CameraPreview(_controller!),
          ),
          Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.47),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Absensi Datang',
                            style: TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Kantor',
                            style: TextStyle(
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          context.push(const LocationPage());
                        },
                        child: Assets.images.seeLocation.image(height: 30.0),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 80.0),
                Row(
                  children: [
                    IconButton(
                      onPressed: _reverseCamera,
                      icon: Assets.icons.reverse.svg(width: 48.0),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: _takePicture,
                      icon: const Icon(
                        Icons.circle,
                        size: 70.0,
                      ),
                      color: AppColors.red,
                    ),
                    const Spacer(),
                    const SizedBox(width: 48.0),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
