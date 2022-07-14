library smart_player;

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_player/progress_bar.dart';
import 'package:video_player/video_player.dart';
import 'full_screen_player_page.dart';

class SmartPlayer extends StatefulWidget {
  final String url;
  final bool? showAds;
  final int? startedAt;

  const SmartPlayer(
      {Key? key, required this.url, this.showAds, this.startedAt = 0})
      : super(key: key);

  @override
  SmartPlayerState createState() => SmartPlayerState();
}

class SmartPlayerState extends State<SmartPlayer> {
  VideoPlayerController? _controller;
  VideoPlayerController? _adsController;
  static const _examplePlaybackRates = [
    0.25,
    0.5,
    1.0,
    1.5,
    2.0,
    3.0,
    5.0,
    10.0,
  ];
  bool isSkipped = false;
  bool showControls = true;
  bool isLocked = false;
  int totalLength = 0;

  @override
  void initState() {
    super.initState();
    _adsController = VideoPlayerController.network(
        "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4");
    _adsController?.initialize().then((_) => setState(() {}));
    _adsController?.play();
    _controller = VideoPlayerController.network(widget.url);
    _controller?.initialize().then((_) => setState(() {
          String twoDigits(int n) => n.toString().padLeft(2, "0");
          int twoDigitMinutes = int.parse(
              twoDigits(_controller!.value.duration.inMinutes.remainder(60)));
          int twoDigitSeconds = int.parse(
              twoDigits(_controller!.value.duration.inSeconds.remainder(60)));
          var min = (twoDigitMinutes) * 60;
          totalLength = twoDigitSeconds + min;
          if (widget.startedAt != 0) {
            _controller?.seekTo(Duration(seconds: widget.startedAt ?? 0));
          }
          if (widget.showAds == false) {
            _controller?.play();
          }
        }));
  }

  @override
  Future<void> dispose() async {
    // timer();
    _controller?.dispose();
    _adsController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: InkWell(
        onTap: () {
          if (!isLocked) {
            showControls = showControls == true ? false : true;
            setState(() {});
          }
        },
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 300,
                  width: MediaQuery.of(context).size.width,
                  child: VideoPlayer(
                      isSkipped == false && widget.showAds == true
                          ? _adsController!
                          : _controller!),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 6, right: 8.0),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: isLocked == false
                        ? PopupMenuButton<double>(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onSelected: (speed) {
                        _controller?.setPlaybackSpeed(speed);
                      },
                      itemBuilder: (context) {
                        return [
                          for (final speed in _examplePlaybackRates)
                            PopupMenuItem(
                              value: speed,
                              child: Text(
                                '${speed}x',
                              ),
                            )
                        ];
                      },
                      child: const Icon(
                        Icons.more_vert,
                        color: Colors.white,
                        size: 25.0,
                      ),
                    )
                        : InkWell(
                      onTap: () {
                        isLocked = false;
                        showControls = true;
                        setState((){});
                      },
                      child: const Icon(
                        Icons.lock,
                        color: Colors.white,
                        size: 25.0,
                      ),
                    ),
                  ),
                )
              ],
            ),
            isSkipped == false && widget.showAds == true
                ? InkWell(
              onTap: () {
                setState(() {
                  isSkipped = true;
                });
                _adsController?.dispose();
                _controller?.play();
              },
              child: Container(
                alignment: Alignment.bottomRight,
                padding: const EdgeInsets.only(right: 10, bottom: 20),
                child: const Text("Skip ads",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white)),
              ),
            )
                : showControls == true
                ? _controlsOverlay(_controller!)
                : Container(),
            isSkipped == false && widget.showAds == true
                ? Container()
                : isLocked == false ? ProgressBarPage(controller: _controller!) : Container(),
          ],
        ),
      ),
    );
  }

  _controlsOverlay(VideoPlayerController controller) {
    return Container(
      color: Colors.black26,
      height: 80,
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 50),
          reverseDuration: const Duration(milliseconds: 200),
          child: FittedBox(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MaterialButton(
                  onPressed: () {
                    // print(">>>>>>>>>>>>>>>");
                    // SimplePip().enterPipMode(
                    //   aspectRatio: [16, 9],
                    // );
                    // setState((){});
                    // SimplePip().enterPipMode();

                    showControls = false;
                    isLocked = true;
                    setState(() {});
                  },
                  minWidth: 20,
                  child: const Icon(
                    Icons.lock,
                    color: Colors.white,
                    size: 20.0,
                  ),
                ),
                MaterialButton(
                  onPressed: () async {
                    var position = await controller.position;
                    controller.seekTo(Duration(seconds: position!.inSeconds - 5));
                    setState(() {});
                  },
                  minWidth: 20,
                  child: const Icon(
                    Icons.replay_5,
                    color: Colors.white,
                    size: 20.0,
                  ),
                ),
                controller.value.isPlaying
                    ? MaterialButton(
                        minWidth: 20,
                        onPressed: () {
                          controller.value.isPlaying
                              ? controller.pause()
                              : controller.play();
                          setState(() {});
                        },
                        child: const Icon(
                          Icons.pause,
                          color: Colors.white,
                          size: 30.0,
                        ),
                      )
                    : MaterialButton(
                        minWidth: 20,
                        onPressed: () {
                          controller.value.isPlaying
                              ? controller.pause()
                              : controller.play();
                          setState(() {});
                        },
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 30.0,
                        ),
                      ),
                const SizedBox(
                  width: 10,
                ),
                MaterialButton(
                  onPressed: () async {
                    var position = await controller.position;
                    controller.seekTo(Duration(seconds: position!.inSeconds + 5));
                    setState(() {});
                  },
                  minWidth: 20,
                  child: const Icon(
                    Icons.forward_5,
                    color: Colors.white,
                    size: 20.0,
                  ),
                ),
                MaterialButton(
                  onPressed: () {
                    // var sec = await timer();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => FullScreenPlayerPage(
                                  // duration: sec,
                                  controller: _controller!,
                                ))).then((value) => {
                          _controller = value,
                          SystemChrome.setPreferredOrientations([
                            DeviceOrientation.portraitDown,
                            DeviceOrientation.portraitUp
                          ]),
                        });
                  },
                  minWidth: 20,
                  child: const Icon(
                    Icons.fullscreen,
                    color: Colors.white,
                    size: 20.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // timer() async {
  //   Duration? duration = await _controller?.position;
  //   String twoDigits(int n) => n.toString().padLeft(2, "0");
  //   int twoDigitMinutes =
  //       int.parse(twoDigits(duration!.inMinutes.remainder(60)));
  //   int twoDigitSeconds =
  //       int.parse(twoDigits(duration.inSeconds.remainder(60)));
  //   var min = (twoDigitMinutes) * 60;
  //   // var sec = twoDigitSeconds + min;
  // }

  String formatDuration(Duration position) {
    final ms = position.inMilliseconds;
    int seconds = ms ~/ 1000;
    final int hours = seconds ~/ 3600;
    seconds = seconds % 3600;
    var minutes = seconds ~/ 60;
    seconds = seconds % 60;
    final hoursString = hours >= 10
        ? '$hours'
        : hours == 0
        ? '00'
        : '0$hours';
    final minutesString = minutes >= 10
        ? '$minutes'
        : minutes == 0
        ? '00'
        : '0$minutes';
    final secondsString = seconds >= 10
        ? '$seconds'
        : seconds == 0
        ? '00'
        : '0$seconds';
    final formattedTime =
        '${hoursString == '00' ? '' : '$hoursString:'}$minutesString:$secondsString';
    return formattedTime;
  }


  getRandomTimer() {
    int ads = 3;
    List<int> time = [];
    Random random = Random();
    for (int i = 0; i < ads; i++) {
      int randomNumber = random.nextInt(100);
      time.add(randomNumber);
    }
  }
}