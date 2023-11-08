import 'package:baaba_devs/controller/scan_controller.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CameraView extends StatelessWidget {
  const CameraView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<ScanController>(
          init: ScanController(),
          builder: (controller) {
            return controller.isCameraInitialized.value
                ? Stack(children: [
                    CameraPreview(controller.cameraController),
                    Positioned(
                      top: 200,
                      right: 50,
                      child: Container(
                        width: 300,
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.green, width: 4.0),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                                color: Colors.white,
                                child: Text("${controller.label}")),
                          ],
                        ),
                      ),
                    )
                  ])
                : const Center(child: Text("Loading Preview..."));
          }),
    );
  }
}
