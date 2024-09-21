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
  bool play = false;
  String? thumbnailUrl;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    final response = await Dio().get('${widget.proxyUrl}${widget.videoId}');
    if (!mounted) return;
    setState(() {
      thumbnailUrl = response.data['pictures']['sizes'][3]['link_with_play_button'];
    });

    final url = response.data['play']['hls']['link'];
    final videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(url));

    await videoPlayerController.initialize();

    if (!mounted) return;
    setState(() {
      _chewieController = ChewieController(
        videoPlayerController: videoPlayerController,
        autoPlay: false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (thumbnailUrl == null) {
      return const Center(child: CircularProgressIndicator());
    } else if (!play) {
      return InkWell(
        onTap: () {
          setState(() {
            play = true;
            _chewieController!.play();
          });
        },
        child: Image.network(thumbnailUrl!, fit: BoxFit.cover),
      );
    } else {
      return AspectRatio(
        aspectRatio: _chewieController!.videoPlayerController.value.aspectRatio,
        child: Chewie(controller: _chewieController!),
      );
    }
  }
}
