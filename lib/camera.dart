import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';
import 'dart:math' as math;

import 'createmodel.dart';
import 'models.dart';

typedef void Callback(List<dynamic> list, int h, int w);

class Camera extends StatefulWidget {
  final List<CameraDescription>? cameras;
  final Callback? setRecognitions;
  final String? model;

  Camera(this.cameras, this.model, this.setRecognitions);

  @override
  _CameraState createState() =>  _CameraState();
}

class _CameraState extends State<Camera> {
  CameraController? controller;
  bool isDetecting = false;

  @override
  void initState() {
    super.initState();

    if (widget.cameras == null || widget.cameras!.isEmpty) {
      print('No camera is found');
    }
    else {
      controller =  CameraController(
        widget.cameras![0],
        ResolutionPreset.medium,
      );
      controller!.initialize().then((_) {
        if (!mounted) {return;}setState(() {});

        controller!.startImageStream((CameraImage img) {
          if (!isDetecting) {
            isDetecting = true;

            int startTime = new DateTime.now().millisecondsSinceEpoch;
// print(img.planes.map((plane) {return plane.bytes;}).toList());
            if (widget.model == mobilenet) {
              Tflite.runModelOnFrame(
                bytesList: img.planes.map((plane) {return plane.bytes;}).toList(),
                imageHeight: img.height,
                imageWidth: img.width,
                numResults: 2,
              ).then((recognitions) {
                int endTime = new DateTime.now().millisecondsSinceEpoch;
                print("Detection took ${(endTime - startTime)/60} sec");

                widget.setRecognitions!(recognitions!, img.height, img.width);

                isDetecting = false;
              });
            }
            else if (widget.model == posenet) {
              Tflite.runPoseNetOnFrame(
                bytesList: img.planes.map((plane) {
                  return plane.bytes;
                }).toList(),
                imageHeight: img.height,
                imageWidth: img.width,
                numResults: 2,
              ).then((recognitions) {
                int endTime = new DateTime.now().millisecondsSinceEpoch;
                print("Detection took ${endTime - startTime}");

                widget.setRecognitions!(recognitions!, img.height, img.width);

                isDetecting = false;
              });
            }
            else {
              Tflite.detectObjectOnFrame(
                bytesList: img.planes.map((plane) {
                  return plane.bytes;
                }).toList(),
                model: widget.model == yolo ? "YOLO" : "SSDMobileNet",
                imageHeight: img.height,
                imageWidth: img.width,
                imageMean: widget.model == yolo ? 0 : 127.5,
                imageStd: widget.model == yolo ? 255.0 : 127.5,
                numResultsPerClass: 1,
                threshold: widget.model == yolo ? 0.2 : 0.4,
              ).then((recognitions) {
                int endTime = new DateTime.now().millisecondsSinceEpoch;
                print("Detection took ${endTime - startTime}");

                widget.setRecognitions!(recognitions!, img.height, img.width);

                isDetecting = false;
              });

           }
          }
        });
      });
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {return Container();}
    var tmp = MediaQuery.of(context).size;
    var screenH = math.max(tmp.height, tmp.width);
    // print('screenH:$screenH');
    var screenW = math.min(tmp.height, tmp.width);
    // print('screenw:$screenW');
    tmp = controller!.value.previewSize!;
    var previewH = math.max(tmp.height, tmp.width);
    // print('PreviewH:$previewH');
    var previewW = math.min(tmp.height, tmp.width);
    // print('PreviewW:$previewW');
    var screenRatio = screenH / screenW;
    // print('screenRatio:$screenRatio');
    var previewRatio = previewH / previewW;
    // print('previewRatio:$previewRatio');
    // print('maxheight:${ screenRatio > previewRatio ? screenH : screenW / previewW * previewH}');
    // print('maxwidth:${  screenRatio > previewRatio ? screenW:screenH / previewH * previewW  }');

    return OverflowBox(
      maxHeight:
          screenRatio > previewRatio ? screenH : screenW / previewW * previewH,
      maxWidth:
          screenRatio > previewRatio ? screenH / previewH * previewW : screenW,
      child: CameraPreview(controller!),
    );
  }
}
