# Ekasar - PDF Scanner Pro

Ekasar is a premium, modern, and high-performance document scanning application built with Flutter. It leverages on-device Machine Learning (Google ML Kit Document Scanner API) to automatically detect document boundaries, capture scans, and process them into high-quality PDFs.

## 🚀 Features
- **Smart Edge Detection**: Automatically identifies document boundaries using Google's ML Kit for perfectly cropped scans.
- **Premium UI/UX**: A cinematic dark-themed interface with smooth micro-animations, dynamic text colors, and an elegant "wave" background.
- **Document Filters**: 
  - *Original*: Raw capture.
  - *Magic*: Boosts contrast and brightness for color documents.
  - *B & W*: High-contrast filter to crush shadows and make text pop.
  - *Grayscale*: Clean grayscale conversion.
  - *Lighten*: Brightens dark or shadowed documents.
- **Gallery Upload**: Import existing photos and edit/crop them directly within the app.
- **PDF Generation**: Instantly generate lightweight, high-quality PDF files.
- **Easy Sharing**: Share your PDFs instantly via native share sheets.

## 🛠 Tech Stack
- **Framework**: Flutter (Dart)
- **Scanning Engine**: Google ML Kit Vision Document Scanner
- **PDF Generation**: `pdf` package
- **Image Processing**: `image` and `image_cropper` packages

## 📱 Getting Started
1. Clone the repository.
2. Run `flutter pub get` to install dependencies.
3. Connect your Android or iOS device.
4. Run `flutter run` to build and install the app.

## 📝 License
This project is proprietary and confidential.
