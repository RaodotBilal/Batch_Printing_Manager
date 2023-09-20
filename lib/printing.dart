import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:file_picker/file_picker.dart';

class PrintPDFScreen extends StatefulWidget {
  // ignore: use_key_in_widget_constructors
  const PrintPDFScreen({Key? key});

  @override
  _PrintPDFScreenState createState() => _PrintPDFScreenState();
}

class _PrintPDFScreenState extends State<PrintPDFScreen> {
  List<PlatformFile> selectedFiles = [];
  List<PlatformFile> _draggedFiles = [];

  Future<void> _selectFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf',],
      allowMultiple: true,
    );
    if (result != null) {
      setState(() {
        selectedFiles
            .addAll(result.files); // add new files to the existing list
      });
    }
  }
  void _deleteAllFiles() {
  setState(() {
    selectedFiles.clear();
  });
}


  void _removeFile(PlatformFile file) {
    if (_draggedFiles.contains(file)) {
      setState(() {
        _draggedFiles.remove(file);
      });
    } else {
      setState(() {
        selectedFiles.remove(file);
      });
    }
  }

  Future<void> _printPDF() async {
    if (selectedFiles.isEmpty) {
      print('No files selected');
      return;
    }
    final pdf = pw.Document();

    for (var i = 0; i < selectedFiles.length; i++) {
      final file = selectedFiles[i];

      try {
        final fileBytes = await File(file.path!).readAsBytes();

        if (file.extension == 'pdf') {
          // Process PDF file
          // You can add PDF files to the PDF document as-is
         await Printing.layoutPdf(
      onLayout: (_) => fileBytes,
    );
        } else if (file.extension == 'jpg' ||
            file.extension == 'jpeg' ||
            file.extension == 'png') {
          // Process image file
          await Printing.layoutPdf(
      onLayout: (_) => fileBytes,
    );
        } else if (file.extension == 'txt') {
          // Process text file (e.g., add text content)
          await Printing.layoutPdf(
      onLayout: (_) => fileBytes,
    );
        } else {
          print('Unsupported file format: ${file.extension}');
          continue;
        }
      } catch (e) {
        print('Error adding ${file.name} to PDF: $e');
      }
    }

    final pdfData = await pdf.save();
    if (pdfData.isEmpty) {
      print('PDF data is null or empty');
      return;
    }

    try {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) => pdfData.buffer.asUint8List(),
        name: 'My PDF Document',
      );
      print('PDF printed successfully');
    } catch (e) {
      print('Error printing PDF: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      title: const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text('Print Documents >>'),
      ),
      actions: [
        IconButton(
          onPressed: _printPDF,
          padding: const EdgeInsets.fromLTRB(0, 0, 10.0, 0),
          icon: const Icon(Icons.print),
        ),
        IconButton(
          onPressed: _deleteAllFiles,
          padding: const EdgeInsets.fromLTRB(0, 0, 10.0, 0),
          icon: const Icon(Icons.delete),
        ),
      ],
    ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30.0, 0, 30.0, 0),
          child: Center(
            child: DragTarget<List<PlatformFile>>(
              onWillAccept: (data) => true,
              onAccept: (data) {
                setState(() {
                  selectedFiles.addAll(data);
                });
              },
              builder: (context, candidateData, rejectedData) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (selectedFiles.isNotEmpty)
                      Column(
                        children: [
                          const Text(
                            'Selected files:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          for (var file in selectedFiles)
                            Draggable<List<PlatformFile>>(
                              data: [file],
                              feedback: Material(
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  color: Colors.grey[300],
                                  child: Text(file.name),
                                ),
                              ),
                              childWhenDragging: const SizedBox(),
                              onDragStarted: () {
                                setState(() {
                                  _draggedFiles = [file];
                                });
                              },
                              onDragEnd: (_) {
                                setState(() {
                                  _draggedFiles = [];
                                });
                              },
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(file.name),
                                  ),
                                  IconButton(
                                    onPressed: () => _removeFile(file),
                                    icon: const Icon(Icons.delete),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      )
                    else
                      const SizedBox(),
                  ],
                );
              },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _selectFiles,
        tooltip: 'Add Files to Print',
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
