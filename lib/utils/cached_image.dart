import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CachedImage extends StatelessWidget {
  final String? url;
  final double width;
  final double height;
  final BoxFit fit;

  const CachedImage({Key? key, this.url, this.width = 50, this.height = 50, this.fit = BoxFit.cover}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return Image.asset('assets/placeholder.png', width: width, height: height, fit: fit);
    }
    return CachedNetworkImage(
      imageUrl: url!,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => Image.asset('assets/placeholder.png', width: width, height: height, fit: fit),
      errorWidget: (context, url, error) => Image.asset('assets/placeholder.png', width: width, height: height, fit: fit),
    );
  }
}
