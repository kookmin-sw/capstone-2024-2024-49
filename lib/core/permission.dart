import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<void> requestPermission() async {
    final PermissionStatus status = await Permission.camera.request();
    if (status.isGranted) {
      print('Permission granted');
    } else {
      print('Permission denied');
    }
  }
}
