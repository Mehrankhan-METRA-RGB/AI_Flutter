
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'home.dart';

List<CameraDescription>? cameras;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    // rethrow;
    if (kDebugMode) {
      print("Error: $e.code\nError Message: $e.message");
    }
  }
  runApp( MyApp());

}


// Future<Null> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   try {
//     cameras = await availableCameras();
//   } on CameraException catch (e) {
//     print('Error: $e.code\nError Message: $e.message');
//   }
//   runApp(new MyApp());
// }

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.amber,
      title: 'Currency Detector',
      theme: ThemeData(
        // primaryColor: Colors.d,
        brightness: Brightness.dark,
        // buttonColor: Colors.amber
      ),
      home: HomePage(cameras!),
    );
  }
}
