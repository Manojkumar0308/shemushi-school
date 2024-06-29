import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../utils/appcolors.dart';
import '../../utils/common_methods.dart';

class ImageFullScreen extends StatefulWidget {
  final String imageUrl;

  const ImageFullScreen({super.key, required this.imageUrl});

  @override
  State<ImageFullScreen> createState() => _ImageFullScreenState();
}

class _ImageFullScreenState extends State<ImageFullScreen> {
  double? progress;
  bool isDownloadStart = false;
  bool isDownloadFinish = false;
  double isdownloadProgress = 0;
  String getFileExtension(String fileName) {
    return ".${fileName.split('.').last}";
  }

  Future<void> downloadImage(String url) async {
    final Dio dio = Dio();
    try {
      const dir = '/storage/emulated/0/Download';
      DateTime now = DateTime.now();
      String dateString =
          now.toLocal().toString().split(' ')[0]; // Remove HH:mm:ss part
      String cleanedDateString = dateString.replaceAll(
          RegExp(r'[ -]'), ''); // Remove whitespace and hyphens

      final filePath = widget.imageUrl.contains('pdf')
          ? '$dir/PDF_$cleanedDateString${getFileExtension(widget.imageUrl)}'
          : '$dir/IMG_$cleanedDateString${getFileExtension(widget.imageUrl)}';
      print(filePath);
      final response = await dio.download(
        url,
        filePath,
        onReceiveProgress: (receivedBytes, totalBytes) {
          // Calculate download progress
          setState(() {
            progress = receivedBytes / totalBytes;
          });

          print(progress);
        },
      );
      if (response.statusCode == 200) {
        print('Downloaded successfully');
      } else {
        print('Download failed');
      }
    } catch (e) {
      print('Exception is $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download), // Add the download icon here
            onPressed: () {
              if (widget.imageUrl.isNotEmpty) {
                downloadBuilder();
                downloadImage(widget.imageUrl);
              }
            },
          ),
        ],
        // Add any other customization you want for the app bar
      ),
      body: Center(
        child: GestureDetector(
          onTap: () {
            Navigator.pop(context); // Close the full-screen image when tapped
          },
          child: widget.imageUrl.contains('pdf')
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.picture_as_pdf,
                          color: Colors.red,
                          size: 35,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text('PDF FILE'),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    const Text(
                      'Please download the file to open it',
                      style: TextStyle(fontSize: 12, color: Colors.blueGrey),
                    ),
                  ],
                )
              : Image.network(
                  widget.imageUrl,
                  fit: BoxFit.contain, // Adjust to your preference
                ),
        ),
      ),
    );
  }

  void downloadBuilder() async {
    isDownloadStart = true;
    isDownloadFinish = false;
    isdownloadProgress = 0;
    if (isDownloadStart) {
      // Show the download dialog with a loader
      showDialog(
        context: context,
        barrierDismissible: false, // Prevent dismissing while downloading
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.black,
            title: const Text(
              'Downloading...',
              style: TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                CircularProgressIndicator(
                  color: Appcolor.themeColor,
                ),
                SizedBox(height: 16),
                Text(
                  'Loading...',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          );
        },
      );
      while (isdownloadProgress < 100) {
        isdownloadProgress += 10;
        setState(() {});

        if (isdownloadProgress == 100) {
          setState(() {
            isDownloadFinish = true;
            isDownloadStart = false;
            CommonMethods().showSnackBar(context, 'Downloaded successfully');
          });

          // Close the dialog
          Navigator.pop(context);
          break;
        }

        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
  }
}
