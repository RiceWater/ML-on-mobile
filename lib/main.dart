import 'dart:io';
import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;


  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  File ? retrievedImage;
  String statusAPI = "API Status: Offline";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MaterialButton(
              onPressed: () {
                uploadImage();
              },
              color: Colors.blue,
              child: const Text("Pick and Classify Image from Gallery using ML",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ),
            MaterialButton(
              onPressed: () {
                fetchData();
                setState(() {
                  statusAPI = statusAPI;
                });
              },
              color: Colors.red,
              child: const Text("Check API Status",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ),
            const SizedBox(height: 20,),
            retrievedImage != null ? Image.file(retrievedImage!) : Text(
                statusAPI)
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future _pickImageFromGallery() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;
    setState(() {
      retrievedImage = File(image.path);
    });
  }

  Future _pickImageFromCamera() async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image == null) return;
    setState(() {
      retrievedImage = File(image.path);
    });
  }


  Future fetchData() async {
    final url = Uri.parse('https://ideal-modest-gazelle.ngrok-free.app/');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Successful response, handle data here
        print('Response data: ${response.body}');
        statusAPI = "API Status: Online!";
      } else {
        // Handle errors, e.g., server errors or no internet
        print('Error: ${response.statusCode}');
        statusAPI =  "API Offline...\n${response.statusCode.toString()}";
      }
    } catch (e) {
      // Handle exceptions, e.g., network errors
      print('Exception: $e');
      statusAPI =  "Error fetching data: $e";
    }
  }


  Future uploadImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://ideal-modest-gazelle.ngrok-free.app/upload'),
      );
      if (image == null) return;

      request.files.add(
        await http.MultipartFile.fromPath(
          'file', // API expects a field named 'file'
          image.path,
        ),
      );
      var response = await http.Client().send(request);
      if (response.statusCode == 200) {
        // Successful response, handle data here
        var convertedResponse = await http.Response.fromStream(response);

        print(
            'Response data: ${convertedResponse.body}');
      } else {
        // Handle errors, e.g., server errors or no internet
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error uploading image: $error');
    }
  }
}
