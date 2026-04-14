import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

class PdfGenerator {
  static Future<File> generatePdfFromImage(File imageFile) async {
    final pdf = pw.Document();
    
    final image = pw.MemoryImage(
      imageFile.readAsBytesSync(),
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Image(image, fit: pw.BoxFit.contain),
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/document_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }
}
// nit: clean up
// nit: clean up
// nit: clean up
// nit: clean up
