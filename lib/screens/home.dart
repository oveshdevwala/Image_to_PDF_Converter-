import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_to_pdf_converter/constrains/colors.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfHomeScreen extends StatefulWidget {
  const PdfHomeScreen({super.key});

  @override
  State<PdfHomeScreen> createState() => PdfHomeScreenState();
}

class PdfHomeScreenState extends State<PdfHomeScreen> {
  final picker = ImagePicker();
  final pdf = pw.Document();
  final List<File> _image = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: UIColors.shade50Bg,
        appBar: homeAppBar(context),
        floatingActionButton: photosSelectButtons(),
        body: _image.isEmpty
            ? noImageFound()
            : SingleChildScrollView(
                child: Column(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _image.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 1),
                          child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: const BoxDecoration(
                                  border: Border(
                                      top: BorderSide(
                                          color: UIColors.black, width: 2))),
                              child: Image.file(_image[index])),
                        );
                      },
                    ),
                    const SizedBox(height: 50)
                  ],
                ),
              ));
  }
  Padding noImageFound() {
    return Padding(
      padding: const EdgeInsets.all(25),
      child: DottedBorder(
          radius: const Radius.circular(20),
          dashPattern: const [10, 10],
          borderType: BorderType.RRect,
          child: SizedBox(
              height: 400,
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.picture_as_pdf,
                    size: 100,
                    color: UIColors.shade500,
                  ),
                  Text(
                    'No Image Found',
                    style: TextStyle(
                        fontSize: 18,
                        color: UIColors.shade500,
                        fontWeight: FontWeight.bold),
                  )
                ],
              ))),
    );
  }

  myFlushBar({var title, var msg}) {
    Flushbar(
      title: title,
      duration: const Duration(seconds: 5),
      message: msg.toString(),
      icon: Icon(
        Icons.save,
        color: UIColors.shade500,
      ),
    ).show(context);
  }

  Row photosSelectButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
            backgroundColor: UIColors.shade200,
            foregroundColor: UIColors.black,
            onPressed: () => getImage(ImageSource.camera),
            child: const Icon(
              Icons.camera_alt,
              size: 30,
            )),
        const SizedBox(width: 30),
        FloatingActionButton(
            backgroundColor: UIColors.shade200,
            foregroundColor: UIColors.black,
            onPressed: () => getImage(ImageSource.gallery),
            child: const Icon(
              Icons.photo_library,
              size: 30,
            )),
      ],
    );
  }

  AppBar homeAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: UIColors.shade100Bg,
      title: const Center(child: Text('Image To PDF')),
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(
          onTap: () {
            _image.clear();
            setState(() {});
          },
          child: CircleAvatar(
              backgroundColor: UIColors.shade200,
              child: const Icon(
                Icons.add,
                size: 30,
              )),
        ),
      ),
      actions: [
        TextButton(
            style: TextButton.styleFrom(
                foregroundColor: UIColors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                backgroundColor: UIColors.shade200),
            child: const Text('Save',
                style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () async {
              await createPdf();
              await savePdf();
              _image.clear();
              setState(() {});
            }),
        const SizedBox(width: 10)
      ],
    );
  }

  Future getImage(ImageSource source) async {
    final pickerFile = await picker.pickImage(source: source);
    setState(() {
      if (pickerFile != null) {
        _image.add(File(pickerFile.path));
      } else {
        myFlushBar(msg: 'Image Not Selected', title: 'Error');
      }
    });
  }

  Future<void> createPdf() async {
    for (var img in _image) {
      final image = pw.MemoryImage(img.readAsBytesSync());
      pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(child: pw.Image(image));
        },
      ));
    }
  }

  Future<void> savePdf() async {
    try {
      final downloadDir = await getApplicationDocumentsDirectory();
      final filepath =
          File('${downloadDir.path}/${DateTime.now().microsecondsSinceEpoch}');
      await filepath.writeAsBytes(await pdf.save());
      myFlushBar(title: 'Success', msg: '$filepath');
    } catch (e) {
      myFlushBar(title: 'Error', msg: e.toString());
    }
  }
}
