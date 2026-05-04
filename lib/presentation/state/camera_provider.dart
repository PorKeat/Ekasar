import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final camerasProvider = StateProvider<List<CameraDescription>>((ref) => []);

final cameraControllerProvider = StateNotifierProvider.autoDispose<CameraControllerNotifier, AsyncValue<CameraController?>>((ref) {
  return CameraControllerNotifier(ref);
});

class CameraControllerNotifier extends StateNotifier<AsyncValue<CameraController?>> {
  final Ref _ref;
  CameraController? _controller;

  CameraControllerNotifier(this._ref) : super(const AsyncValue.loading()) {
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = _ref.read(camerasProvider);
      if (cameras.isEmpty) {
        state = const AsyncValue.data(null);
        return;
      }

      _controller = CameraController(
        cameras[0],
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();
      
      if (mounted) {
        state = AsyncValue.data(_controller);
      }
    } catch (e, st) {
      if (mounted) {
        state = AsyncValue.error(e, st);
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
