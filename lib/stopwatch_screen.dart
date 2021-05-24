import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timer_project/colorPalette2.dart';
import 'package:timer_project/slidingPanelWidget.dart';
import 'package:timer_project/utils_and_widgets.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';
import 'package:just_audio/just_audio.dart';

class StopwatchScreen extends StatefulWidget {
  final int colorScheme;
  final SharedPreferences sharedPreferences;
  final Function(int) callBackStopwathScreen;
  final Function(bool) tabBarVisible;
  StopwatchScreen(
      {this.colorScheme,
      this.callBackStopwathScreen,
      this.tabBarVisible,
      this.sharedPreferences});

  @override
  _StopwatchScreenState createState() => _StopwatchScreenState();
}

class _StopwatchScreenState extends State<StopwatchScreen>
    with TickerProviderStateMixin {
  StreamSubscription _streamSubscription;
  AnimationController _animationController;
  final player = AudioPlayer();
  var duration;
  static Color _fontColor;
  static bool isReverseAnimation = false;
  double _height;
  Duration _time = Duration(seconds: 0, milliseconds: 0);
  bool _isActive = false;
  bool _resetAvailable = false;
  static int _colorSchemeValue = 2;
  String minute = "00";
  String second = "00";
  String milliseconds = "00";

  callBack(colorSchemeStopwatch) {
    setState(() {
      _colorSchemeValue = colorSchemeStopwatch;
      widget.sharedPreferences
          .setInt('colorSchemeStopwatch', colorSchemeStopwatch);
    });
  }

  callBackSliding(value) {
    widget.tabBarVisible(value);
  }

  Stream<List<String>> stream() async* {
    yield* Stream.periodic(Duration(milliseconds: 100), (a) {
      _time = _time + Duration(milliseconds: 100);
      return returnTimeFormatted(_time);
    });
  }

  List<String> returnTimeFormatted(Duration t) {
    String formattedMin = (t.inMinutes < 10)
        ? '0' + t.inMinutes.toString()
        : t.inMinutes.toString();

    int numSeconds = t.inSeconds - t.inMinutes * 60;

    String formattedSec =
        (numSeconds < 10) ? '0' + numSeconds.toString() : numSeconds.toString();

    int numMilliSeconds = (t.inMilliseconds ~/ 100 < 100)
        ? t.inMilliseconds ~/ 100
        : (t.inMilliseconds ~/ 100) % 100;
    String formattedMilliSeconds = (numMilliSeconds < 10)
        ? '0' + numMilliSeconds.toString()
        : numMilliSeconds.toString();

    return [formattedMin, formattedSec, formattedMilliSeconds];
  }

  void listenToStream() {
    _streamSubscription = stream().listen((data) {
      setState(() {
        minute = data[0];
        second = data[1];
        milliseconds = data[2];
      });

      if (minute == "01" && second == "30") {
        player.play();
        resetStream();
        Fluttertoast.showToast(msg: "1 hour complete");
      }
    });
  }

  void cancelStream() {
    if (_streamSubscription != null) {
      _streamSubscription.pause();
    }
  }

  void resumeStream() {
    if (_streamSubscription != null) {
      _streamSubscription.resume();
    }
  }

  void resetStream() {
    cancelStream();
    setState(() {
      minute = "00";
      second = "00";
      milliseconds = "00";
      _time = Duration(seconds: 0);
      _resetAvailable = false;
      _isActive = false;
      _animationController = AnimationController(
          vsync: this, reverseDuration: Duration(seconds: 1));
      _animationController.reverse().then((value) {
        _animationController.reset();
      });
    });
  }

  @override
  void initState() {
    setState(() {
      _colorSchemeValue = widget.colorScheme;
      _fontColor = ColorsP.colorPalette[_colorSchemeValue][6];
    });
    _animationController = AnimationController(
        vsync: this,
        duration: _time + Duration(seconds: 1),
        reverseDuration: Duration(seconds: 1));
    initialiseAudio();
    super.initState();
  }

  void initialiseAudio() async {
    duration = await player.setAsset('assets/sounds/alarmclocksound.mp3');
  }

  @override
  void dispose() {
    _animationController.dispose();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => widget.callBackStopwathScreen(_colorSchemeValue));
    if (_streamSubscription != null) {
      _streamSubscription.cancel();
    }
    if (player != null) {
      player.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100.0),
        child: SafeArea(
          child: AppBar(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            flexibleSpace: Center(
              child: Text(
                "1 HOUR STOP WATCH",
                style: TextStyle(
                  fontSize: 13.0,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                  letterSpacing: 5.0,
                ),
              ),
            ),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                color: ColorsP.colorPalette[_colorSchemeValue][5],
                height: MediaQuery.of(context).size.height,
                child: Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [_buildCustomAnimatedContainer()],
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Container(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          CommonContainerProps.timeUnitWidget(
                              minute, _fontColor),
                          CommonContainerProps.colonSizedBoxWidget(_fontColor),
                          CommonContainerProps.timeUnitWidget(
                              second, _fontColor),
                          CommonContainerProps.colonSizedBoxWidget(_fontColor),
                          CommonContainerProps.timeUnitWidget(
                              milliseconds, _fontColor),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 50.0,
                    ),
                    Container(
                      width: 250.0,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          _isActive == true
                              ? Container()
                              : Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Container(
                                    padding: EdgeInsets.zero,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30.0),
                                      border: Border.all(
                                        color: _fontColor,
                                        width: 0.5,
                                      ),
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          if (_isActive == false &&
                                              _time.inMilliseconds == 0) {
                                            _isActive = true;
                                            _resetAvailable = true;
                                            isReverseAnimation = false;
                                            minute = "00";
                                            second = "00";
                                            milliseconds = "00";
                                            _time = Duration(
                                                minutes: int.parse(minute),
                                                seconds: int.parse(second),
                                                milliseconds:
                                                    int.parse(milliseconds));

                                            _animationController = null;
                                            _animationController =
                                                AnimationController(
                                                    reverseDuration: _time +
                                                        Duration(minutes: 1),
                                                    vsync: this,
                                                    duration:
                                                        Duration(minutes: 1));

                                            listenToStream();
                                          } else if (_isActive == false &&
                                              _time.inMilliseconds > 0) {
                                            _isActive = true;
                                            _resetAvailable = true;
                                            resumeStream();
                                          }
                                          if (isReverseAnimation == false) {
                                            _animationController.forward();
                                          } else {
                                            _animationController.reverse();
                                          }
                                        });
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(
                                            top: 15.0, bottom: 15.0),
                                        alignment: Alignment.center,
                                        padding: EdgeInsets.fromLTRB(
                                            20.0, 0.0, 20.0, 0.0),
                                        child: Text(
                                          _isActive == false &&
                                                  _time.inMilliseconds == 0
                                              ? "START STOPWATCH"
                                              : "RESUME STOPWATCH",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                          _isActive == true
                              ? Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    padding: EdgeInsets.fromLTRB(
                                        20.0, 0.0, 20.0, 0.0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30.0),
                                      border: Border.all(
                                        color: _fontColor,
                                        width: 0.5,
                                      ),
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        if (_isActive == true) {
                                          setState(() {
                                            if (_animationController
                                                .isAnimating) {
                                              _animationController.stop();
                                            }
                                            _isActive = false;
                                          });
                                          cancelStream();
                                        }
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(
                                            top: 15.0, bottom: 15.0),
                                        alignment: Alignment.center,
                                        padding: EdgeInsets.fromLTRB(
                                            20.0, 0.0, 20.0, 0.0),
                                        child: Text(
                                          "PAUSE STOPWATCH",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : Container(),
                          _resetAvailable == true
                              ? Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    padding: EdgeInsets.fromLTRB(
                                        20.0, 0.0, 20.0, 0.0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30.0),
                                      border: Border.all(
                                        color: _fontColor,
                                        width: 0.5,
                                      ),
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        if (_resetAvailable == true) {
                                          setState(() {
                                            _resetAvailable = false;
                                            _isActive = false;
                                            resetStream();
                                          });
                                        }
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(
                                            top: 15.0, bottom: 15.0),
                                        alignment: Alignment.center,
                                        padding: EdgeInsets.fromLTRB(
                                            20.0, 0.0, 20.0, 0.0),
                                        child: Text(
                                          "RESET STOPWATCH",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : Container(),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              SlidingPanelWidget(callBack, callBackSliding),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomAnimatedContainer() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        if (_animationController.value == 1.0 && _isActive == true) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              isReverseAnimation = true;
            });
          });
          _animationController.reverse();
        } else if (_animationController.value == 0.0 && _isActive == true) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              isReverseAnimation = false;
            });
          });
          _animationController.forward();
        }

        return Container(
          alignment: Alignment.bottomCenter,
          height: (_height - 20.0) * _animationController.value,
          child: WaveWidget(
            config: CustomConfig(
              gradients: [
                [
                  ColorsP.colorPalette[_colorSchemeValue][0],
                  ColorsP.colorPalette[_colorSchemeValue][1],
                ],
                [
                  ColorsP.colorPalette[_colorSchemeValue][2],
                  ColorsP.colorPalette[_colorSchemeValue][0],
                ],
                [
                  ColorsP.colorPalette[_colorSchemeValue][3],
                  ColorsP.colorPalette[_colorSchemeValue][2],
                ],
                [
                  ColorsP.colorPalette[_colorSchemeValue][4],
                  ColorsP.colorPalette[_colorSchemeValue][3],
                  ColorsP.colorPalette[_colorSchemeValue][1],
                  ColorsP.colorPalette[_colorSchemeValue][0],
                ]
              ],
              durations: [5000, 10000, 7000, 6000],
              heightPercentages: [0.0, 0.01, 0.02, 0.03],
              blur: MaskFilter.blur(BlurStyle.solid, 10),
              gradientBegin: Alignment.bottomLeft,
              gradientEnd: Alignment.topRight,
            ),
            waveAmplitude: 10.0,
            size: Size(
              double.infinity,
              double.infinity,
            ),
          ),
        );
      },
    );
  }
}
