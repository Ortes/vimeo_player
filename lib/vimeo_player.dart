library vimeo_player;

import 'package:chewie/chewie.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VimeoPlayer extends StatefulWidget {
  const VimeoPlayer({super.key, required this.proxyUrl, required this.videoId});

  final String proxyUrl;
  final String videoId;

  @override
  State<VimeoPlayer> createState() => _VimeoPlayerState();
}

class _VimeoPlayerState extends State<VimeoPlayer> {
  ChewieController? _chewieController;

  // VideoPlayerController? _videoPlayerController;

  @override
  void initState() {
    super.initState();
    try {
      init();
    } catch (e) {
      print(e);
    }
  }

  Future<void> init() async {
    final response = await Dio().get('${widget.proxyUrl}${widget.videoId}');
    final defaultCdn = response.data['request']['files']['hls']['default_cdn'];
    final url = response.data['request']['files']['hls']['cdns'][defaultCdn]['avc_url'];
    final videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(url));

    await videoPlayerController.initialize();

    setState(() {
      _chewieController = ChewieController(
        videoPlayerController: videoPlayerController,
        autoPlay: false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_chewieController == null) {
      init();
      return const IntrinsicHeight(child: Center(child: CircularProgressIndicator()));
    } else {
      return AspectRatio(
        aspectRatio: _chewieController!.videoPlayerController.value.aspectRatio,
        child: Chewie(controller: _chewieController!),
      );
    }
  }
}
