import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:camera/camera.dart';
import 'package:mime/mime.dart';
import 'package:async/async.dart';
import 'package:path_provider/path_provider.dart';

class GnerateLiveCaptions extends StatefulWidget {
  // const GnerateLiveCaptions({Key? key}) : super(key: key);

  @override
  State<GnerateLiveCaptions> createState() => _GnerateLiveCaptionsState();
}

class _GnerateLiveCaptionsState extends State<GnerateLiveCaptions> {
  String resultText = 'Fetching Response...';
  List<CameraDescription> cameras;
  CameraController controller;
  bool takephoto = false;

  @override
  void initState() {
    super.initState();
    takephoto = true;
    detectCameras().then((_) {
      initializeController();
    });
  }

  Future<void> detectCameras() async {
    cameras = await availableCameras();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void initializeController() {
    controller = CameraController(cameras[0], ResolutionPreset.medium);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
      if (takephoto) {
        const interval = const Duration(seconds: 5);
        new Timer.periodic(interval, (Timer t) => capturePicture());
      }
    });
  }

  capturePicture() async {
    String timesteps = DateTime.now().millisecondsSinceEpoch.toString();
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirpath = '${extDir.path}/Pictures/flutter_test';
    await Directory(dirpath).create(recursive: true);
    final String filepath = '$dirpath/{$timesteps}.png';
    if (takephoto) {
      controller.takePicture(filepath).then((_) {
        if (takephoto) {
          File imgfile = File(filepath);
          fetchResponse(imgfile);
        } else {
          return;
        }
      });
    }
  }

  Future<Map<String, dynamic>> fetchResponse(File image) async {
    final mimeTypeData =
        lookupMimeType(image.path, headerBytes: [0xFF, 0xD8]).split('/');

    final imageUploadRequest = http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://max-image-caption-generator-podo-sayed-dev.apps.sandbox.x8i5.p1.openshiftapps.com/model/predict'));
    final file = await http.MultipartFile.fromPath('image', image.path,
        contentType: MediaType(mimeTypeData[0], mimeTypeData[1]));
    imageUploadRequest.fields['ext'] = mimeTypeData[1];
    imageUploadRequest.files.add(file);

    try {
      final streamedResponse = await imageUploadRequest.send();
      final response = await http.Response.fromStream(streamedResponse);
      final Map<String, dynamic> responseData = json.decode(response.body);
      parseResponse(responseData);
      return responseData;
    } catch (e) {
      print(e);
      return null;
    }
  }

  void parseResponse(var response) {
    String r = '';
    var predictions = response['predictions'];
    for (var prediction in predictions) {
      var caption = prediction['caption'];
      var probability = prediction['probability'];
      r = r + '$caption\n\n';
    }
    setState(() {
      resultText = r;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.004, 1],
            colors: [
              Color(0x11232526),
              Color(0xFF232526),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(top: 35),
              child: IconButton(
                color: Colors.white,
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () {
                  setState(() {
                    takephoto = false;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
            (controller.value.isInitialized)
                ? Center(child: buildCameraPreview())
                : Container()
          ],
        ),
      ),
    );
  }

  Widget buildCameraPreview() {
    var size = MediaQuery.of(context).size.width / 1.2;
    return Column(
      children: <Widget>[
        Container(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 60,
              ),
              Container(
                width: size,
                height: size,
                child: CameraPreview(controller),
              ),
              SizedBox(
                height: 40,
              ),
              Text(
                'prediction is: \n',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 25,
                ),
              ),
              Text(
                resultText,
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              )
            ],
          ),
        )
      ],
    );
  }
}
