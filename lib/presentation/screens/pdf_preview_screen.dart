import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf_scanner_pro/core/theme/app_colors.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:pdf_scanner_pro/presentation/widgets/custom_snackbar.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf_scanner_pro/data/repositories/document_repository.dart';
