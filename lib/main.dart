import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis/vision/v1.dart' as google;
import 'package:url_launcher/url_launcher.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_animated_button/flutter_animated_button.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  File? image;
  bool isLoading = false;
  final credit = '*888*';
  final internet = '*230*';
  final antsoMLay = '*313*';
  String? prefixe;
  String? offreSelected;

  final String apiKey = "AIzaSyBStuzSA7bW5n2wddHiCSNBG-TPWh-sd64";

  Future pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(
        source: source,
        imageQuality: 1,
      );
      if (image == null) return;

      final imageTemporary = File(image.path);
      await recognizeText(imageTemporary);
      setState(() => this.image = imageTemporary);
    } on Exception catch (e) {
      print('tsy mety sary : $e');
    }
  }

  Future recognizeText(File imageFile) async {
    try {
      setState(() {
        isLoading = true;
      });
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final client = http.Client();

      final url = Uri.parse(
          'https://vision.googleapis.com/v1/images:annotate?key=$apiKey');

      final response = await client.post(url,
          body: json.encode({
            'requests': [
              {
                'image': {'content': base64Image},
                'features': [
                  {'type': 'TEXT_DETECTION'}
                ]
              }
            ]
          }),
          headers: {'Content-Type': 'application/json'});

      final extractedData =
          json.decode(response.body)['responses'][0]['fullTextAnnotation'];

      List<String> lines = extractedData['text'].split("\n");
      print('debut');
      RegExp regex = RegExp(
          r'^\d{5} \d{5} \d{5}$'); // Expression régulière pour 15 chiffres séparés par bloc de 5 chiffres par une espace

      for (String line in lines) {
        if (regex.hasMatch(line)) {
          line.replaceAll(' ',
              ''); // Supprimer les espaces pour obtenir le code à 15 chiffres
          String urll = 'tel:$prefixe$line%23';
          if (await canLaunch(urll)) {
            await launch(urll);
          } else {
            print('Impossible de lancer $urll');
          }
        }
      }

      setState(() {
        isLoading = false;
        offreSelected = null;
      });

      client.close();
    } on Exception catch (e) {
      setState(() {
        isLoading = false;
        offreSelected = null;
      });
      print('Error during OCR: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        backgroundColor: Colors.blueGrey.shade50,
        appBar: AppBar(
          title: Row(
            children: [
              Image.asset(
                'assets/images/xp.png',
                height: 80,
                width: 80,
              ),
              const Text('Airtel XPerience',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                  )),
            ],
          ),
        ),
        body: SizedBox(
          width: double.infinity,
          child: !isLoading
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    AnimatedTextKit(
                      isRepeatingAnimation: false,
                      animatedTexts: [
                        TypewriterAnimatedText(
                          textStyle: const TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            // color: Colors.deepPurpleAccent,
                            letterSpacing: 1.5,
                          ),
                          'Scannez votre carte airtel en un seul clic!',
                          speed: const Duration(milliseconds: 70),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        SizedBox(
                          height: 50,
                          width: 190,
                          child: ElevatedButton.icon(
                            onPressed: () => setState(() {
                              prefixe = credit;
                              offreSelected = 'Crédit';
                            }),
                            icon: const Icon(Icons.credit_card),
                            label: const Text(
                              'Crédit',
                              style: TextStyle(
                                fontSize: 25,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              primary: offreSelected != 'Crédit'
                                  ? Colors.deepPurpleAccent
                                  : Colors.blue,
                              onPrimary: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              elevation: 5,
                              shadowColor: Colors.grey,
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.all(10),
                          height: 50,
                          width: 190,
                          child: ElevatedButton.icon(
                            onPressed: () => setState(() {
                              prefixe = internet;
                              offreSelected = 'Internet';
                            }),
                            icon: const Icon(Icons.wifi),
                            label: const Text(
                              'Internet',
                              style: TextStyle(
                                fontSize: 25,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              primary: offreSelected != 'Internet'
                                  ? Colors.deepPurpleAccent
                                  : Colors.blue,
                              onPrimary: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              elevation: 5,
                              shadowColor: Colors.grey,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 50,
                          width: 190,
                          child: ElevatedButton.icon(
                            onPressed: () => setState(() {
                              prefixe = antsoMLay;
                              offreSelected = "Antso M'lay";
                            }),
                            icon: const Icon(Icons.call),
                            label: const Text(
                              "Antso M'lay",
                              style: TextStyle(
                                fontSize: 25,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              primary: offreSelected != "Antso M'lay"
                                  ? Colors.deepPurpleAccent
                                  : Colors.blue,
                              onPrimary: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              elevation: 5,
                              shadowColor: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    offreSelected != null
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Center(
                                child: ElevatedButton.icon(
                                  onPressed: () =>
                                      pickImage(ImageSource.camera),
                                  icon: const Icon(
                                    Icons.camera_alt,
                                  ),
                                  label: const Text('Prendre une photo'),
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.blue,
                                    onPrimary: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    elevation: 5,
                                    shadowColor: Colors.grey,
                                  ),
                                ),
                              ),
                              Center(
                                child: ElevatedButton.icon(
                                  onPressed: () =>
                                      pickImage(ImageSource.gallery),
                                  icon: const Icon(Icons.photo_library),
                                  label: const Text('Importer une photo'),
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.blue,
                                    onPrimary: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    elevation: 5,
                                    shadowColor: Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Container(),
                  ],
                )
              : const Center(
                  child: CircularProgressIndicator(),
                ),
        ),
      ),
    );
  }
}
