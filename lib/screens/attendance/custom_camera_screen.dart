import 'dart:io';
import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:internusa_group/utils/theme.dart';
import 'package:image/image.dart' as img;

class CustomCameraScreen extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String position;

  const CustomCameraScreen({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.position,
  });

  @override
  State<CustomCameraScreen> createState() => _CustomCameraScreenState();
}

class _CustomCameraScreenState extends State<CustomCameraScreen> {
  CameraController? _controller;
  final List<Face> _faces = [];
  String? _address;

  bool _isProcessing = false;
  late InputImageRotation _rotation;

  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.fast,
    ),
  );

  /* ================= INIT ================= */

  @override
  void initState() {
    super.initState();
    _initCamera();
    _loadAddress();
  }

  /* ================= CAMERA ================= */

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      final camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
      );

      _controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();

      _rotation = InputImageRotationValue.fromRawValue(
            camera.sensorOrientation,
          ) ??
          InputImageRotation.rotation0deg;

      _controller!.startImageStream(_processFrame);

      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Camera init error: $e');
      _showError('Gagal membuka kamera');
    }
  }

  void _processFrame(CameraImage image) async {
    if (_isProcessing || !mounted) return;

    _isProcessing = true;

    try {
      final faces = await _detectFaces(image);
      setState(() {
        _faces
          ..clear()
          ..addAll(faces);
      });
    } catch (e) {
      debugPrint('Frame error: $e');
    } finally {
      _isProcessing = false;
    }
  }

  /* ================= FACE DETECTION ================= */

  Future<List<Face>> _detectFaces(CameraImage image) async {
    final WriteBuffer buffer = WriteBuffer();
    for (final plane in image.planes) {
      buffer.putUint8List(plane.bytes);
    }

    final inputImage = InputImage.fromBytes(
      bytes: buffer.done().buffer.asUint8List(),
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: _rotation,
        format: InputImageFormat.nv21,
        bytesPerRow: image.planes.first.bytesPerRow,
      ),
    );

    return _faceDetector.processImage(inputImage);
  }

  /* ================= LOCATION ================= */

  Future<void> _loadAddress() async {
    try {
      final placemarks = await placemarkFromCoordinates(
        widget.latitude,
        widget.longitude,
      );

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        setState(() {
          _address =
              '${p.street}, ${p.locality}, ${p.administrativeArea}, ${p.country}';
        });
      }
    } catch (e) {
      debugPrint('Location error: $e');
    }
  }

  /* ================= CAPTURE ================= */

  Future<void> _capture() async {
    // debugPrint('=== CAPTURE START ===');

    if (_faces.isEmpty) {
      // debugPrint('No face detected');
      _showError('Wajah tidak terdeteksi');
      return;
    }

    try {
      final xFile = await _controller!.takePicture();
      // debugPrint('[1] Picture taken: ${xFile.path}');

      final file = File(xFile.path);
      if (!file.existsSync()) {
        // debugPrint('File not exists after capture');
        _showError('File foto tidak ditemukan');
        return;
      }

      // debugPrint('[2] File size: ${file.lengthSync()}');

      final bytes = await file.readAsBytes();
      // debugPrint('[3] Bytes length: ${bytes.length}');

      final originalImage = img.decodeImage(bytes);
      if (originalImage == null) {
        // debugPrint('Image decode failed');
        _showError('Gagal decode gambar');
        return;
      }

      // debugPrint(
      //     '[4] Image decoded: ${originalImage.width}x${originalImage.height}');

      final flippedImage = img.flipHorizontal(originalImage);
      // debugPrint('[5] Image flipped');

      file.writeAsBytesSync(
        img.encodeJpg(flippedImage, quality: 95),
        flush: true,
      );

      // debugPrint('[6] Image saved after flip');

      Navigator.pop(context, file);
      // debugPrint('=== CAPTURE SUCCESS ===');
    } catch (e, s) {
      // debugPrint('CAPTURE ERROR: $e');
      debugPrintStack(stackTrace: s);
      _showError('Gagal mengambil foto');
    }
  }

  /* ================= UI ================= */

  Widget _faceOverlay() {
    if (_faces.isEmpty) {
      return _instruction();
    }

    final preview = _controller!.value.previewSize!;
    final screen = MediaQuery.of(context).size;

    final scaleX = screen.width / preview.height;
    final scaleY = screen.height / preview.width;

    return Stack(
      children: _faces.map((face) {
        final r = face.boundingBox;

        return Positioned(
          left: screen.width - (r.right * scaleX),
          top: r.top * scaleY,
          width: r.width * scaleX,
          height: r.height * scaleY,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.cameraFace,
                width: 3.w,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _instruction() {
    return Center(
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: AppColors.textPrimary,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Text(
          'Posisikan wajah di tengah layar',
          style: TextStyle(
            color: AppColors.background,
            fontSize: 16.sp,
          ),
        ),
      ),
    );
  }

  /* ================= HELPERS ================= */

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    _faceDetector.close();
    super.dispose();
  }

  /* ================= BUILD ================= */

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.textPrimary,
      body: Stack(
        children: [
          CameraPreview(_controller!),
          _faceOverlay(),
          _bottomPanel(),
        ],
      ),
    );
  }

  Widget _bottomPanel() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: EdgeInsets.only(bottom: 24.r),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: AppColors.textPrimary.withOpacity(0.6),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.position,
              style: TextStyle(
                color: AppColors.background,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_address != null) ...[
              SizedBox(height: 8.h),
              Text(
                _address!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.surface,
                  fontSize: 14.sp,
                ),
              ),
            ],
            SizedBox(height: 16.h),
            ElevatedButton.icon(
              onPressed: _capture,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Ambil Foto'),
            ),
          ],
        ),
      ),
    );
  }
}
