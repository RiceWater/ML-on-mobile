import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_tflite/flutter_tflite.dart';

class ScanController extends GetxController{

  @override
  void onInit(){
    super.onInit();
    initCamera();
    initTflite();
  }

  @override
  void dispose(){
    super.dispose();
    cameraController.dispose();
  }
  late CameraController cameraController;
  late List<CameraDescription> cameras;

  // late CameraImage cameraImage;

  var cameraCount = 0;
  var isCameraInitialized = false.obs;

  var x, y, w, h = 0.0;
  var label = "";

  initCamera() async {
    if (await Permission.camera.request().isGranted){
      cameras = await availableCameras();
      cameraController = CameraController(cameras[0], ResolutionPreset.max);
      await cameraController.initialize().then((value) {
        cameraController.startImageStream((image) {
          cameraCount++;
          if (cameraCount % 10 == 0){
            cameraCount = 0;
            objectDetector(image);
          }
          update();
        });
      });
      isCameraInitialized(true);
      update();
    }
    else{
      print("Permission denied.");
    }
  }

  objectDetector(CameraImage image) async {
    var detector = await Tflite.runModelOnFrame(
        bytesList: image.planes.map((e){
          return e.bytes;
        }).toList(),
      asynch: true,
      imageHeight: image.height,
      imageWidth: image.width,
      imageMean: 127.5,
      imageStd: 127.5,
      numResults: 1,
      rotation: 90,
      threshold: 0.4,
    );

    if (detector != null){
      var ourDetectedObject = detector.first;
      print('==============');
      print(ourDetectedObject);
      print('==============');
      if (ourDetectedObject['confidence'] > 0.45){
        label = ourDetectedObject['label'].toString();
        print(label);
      }
      update();
    }
  }

  initTflite() async {
    await Tflite.loadModel(
      model: "assets/model.tflite",
      labels: "assets/labels.txt",
      isAsset: true,
      numThreads: 1,
      useGpuDelegate: false,
    );
  }
}