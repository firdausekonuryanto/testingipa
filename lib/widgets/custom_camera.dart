import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomCamera extends StatefulWidget {
  final Function(File) onImageCaptured;
  final Function(String) onError;
  final VoidCallback onCancel;
  final double maxFileSizeMB;

  const CustomCamera({
    super.key,
    required this.onImageCaptured,
    required this.onError,
    required this.onCancel,
    this.maxFileSizeMB = 5.0,
  });

  @override
  State<CustomCamera> createState() => _CustomCameraState();
}

class _CustomCameraState extends State<CustomCamera> {
  CameraController? _controller;
  bool _isLoading = true;
  bool _isCapturing = false;
  bool _permissionGranted = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkCameraPermission();
  }

  Future<void> _checkCameraPermission() async {
    try {
      final status = await Permission.camera.status;

      if (status.isPermanentlyDenied) {
        _handleError(
            'Izin kamera ditolak permanen. Harus diaktifkan di pengaturan');
        return;
      }

      if (status.isDenied) {
        final result = await Permission.camera.request();
        if (!result.isGranted) {
          _handleError('Izin kamera diperlukan untuk mengambil foto');
          return;
        }
      }

      setState(() => _permissionGranted = true);
      _initializeCamera();
    } catch (e) {
      _handleError('Gagal memeriksa izin kamera: $e');
    }
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        throw Exception('Tidak ada kamera yang tersedia');
      }

      final camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _controller!.initialize();

      if (!mounted) return;

      setState(() => _isLoading = false);
    } catch (e) {
      _handleError('Gagal menginisialisasi kamera: $e');
    }
  }

  void _handleError(String message) {
    // debugPrint(message);
    setState(() {
      _errorMessage = message;
      _isLoading = false;
    });
    widget.onError(message);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (_isLoading || _isCapturing || _controller == null) return;

    setState(() => _isCapturing = true);

    try {
      final XFile image = await _controller!.takePicture();
      final File imageFile = File(image.path);

      final fileSize = await imageFile.length();
      final maxSizeBytes = widget.maxFileSizeMB * 1024 * 1024;

      if (fileSize > maxSizeBytes) {
        widget.onError('Ukuran gambar melebihi ${widget.maxFileSizeMB}MB');
        return;
      }

      widget.onImageCaptured(imageFile);
    } catch (e) {
      _handleError('Gagal mengambil gambar: $e');
    } finally {
      if (mounted) {
        setState(() => _isCapturing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_permissionGranted || _errorMessage != null) {
      return _buildErrorState();
    }

    if (_isLoading) {
      return _buildLoadingState();
    }

    return _buildCameraPreview();
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 16.h),
          Text(
            _errorMessage ?? 'Izin kamera diperlukan',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () {
              if (_errorMessage?.contains('pengaturan') ?? false) {
                openAppSettings();
              } else {
                widget.onCancel();
              }
            },
            child: Text(_errorMessage?.contains('pengaturan') ?? false
                ? 'Buka Pengaturan'
                : 'Kembali'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          SizedBox(height: 16.h),
          const Text('Menyiapkan kamera...'),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    return Stack(
      children: [
        Positioned.fill(
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..scale(-1.0, 1.0, 1.0), // mirror effect
            child: CameraPreview(_controller!),
          ),
        ),
        Positioned(
          bottom: 24,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(Icons.close, color: Colors.white, size: 36.sp),
                onPressed: widget.onCancel,
              ),
              IconButton(
                icon: Icon(Icons.camera, color: Colors.white, size: 48.sp),
                onPressed: _takePicture,
              ),
              SizedBox(width: 48.w),
            ],
          ),
        ),
        if (_isCapturing)
          const Positioned.fill(
            child: ColoredBox(
              color: Colors.black54,
              child: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}
