import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';

class CachedNetworkImage extends StatefulWidget {
  final String url;
  final double width;
  final double height;
  final BoxFit fit;

  const CachedNetworkImage({
    Key? key,
    required this.url,
    this.width = 100,
    this.height = 100,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  @override
  _CachedNetworkImageState createState() => _CachedNetworkImageState();
}

class _CachedNetworkImageState extends State<CachedNetworkImage> {
  File? _localFile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final filename = widget.url.split('/').last;
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$filename');

    if (await file.exists()) {
      // الصورة موجودة محلياً
      setState(() {
        _localFile = file;
        _loading = false;
      });
    } else {
      // تحميل الصورة من الإنترنت
      try {
        final response = await Dio().get<List<int>>(
          widget.url,
          options: Options(responseType: ResponseType.bytes),
        );
        final bytes = response.data!;
        await file.writeAsBytes(bytes);
        setState(() {
          _localFile = file;
          _loading = false;
        });
      } catch (e) {
        print('خطأ في تحميل الصورة: $e');
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const CircularProgressIndicator();
    if (_localFile != null) return Image.file(_localFile!, width: widget.width, height: widget.height, fit: widget.fit);
    return const Icon(Icons.broken_image, size: 50, color: Colors.red);
  }
}
