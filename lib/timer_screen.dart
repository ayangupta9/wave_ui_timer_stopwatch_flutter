import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timer_project/colorPalette2.dart';
import 'package:timer_project/slidingPanelWidget.dart';
import 'package:timer_project/utils_and_widgets.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';
import 'package:just_audio/just_audio.dart';

class TimerScreen extends StatefulWidget {
  final int colorScheme;
  final Function(int) callBackTimerScreen;
  final Function(bool) tabBarVisible;
  final SharedPreferences sharedPreferences;
  TimerScreen(
      {this.colorScheme,
      this.callBackTimerScreen,
      this.tabBarVisible,
      this.sharedPreferences});

  @override
  _TimerScreenState createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen>
    with TickerProviderStateMixin {
  Stream<String> stream() async* {
    yield* Stream.periodic(Duration(seconds: 1), (a) {
      if (_time == Duration(minutes: 0, seconds: 0)) {
        cancelStream();
        player.play();
        setState(() {
          _time = Duration(seconds: 1);
          _fullTime = _time;
          _animationController.reverse().then((value) {
            _animationController.reset();
          });
          _isActive = false;
          _resetAvailable = false;
        });

        Fluttertoast.showToast(msg: "Timer end");
        return "00:00";
      }
      _time = _time - Duration(seconds: 1);
      return formatDate(_time);
    });
  }

  void resetStream() {
    cancelStream();
    setState(() {
      _minuteController.text =
          (minute < 10) ? '0' + minute.toString() : minute.toString();
      _secondController.text =
          (second < 10) ? '0' + second.toString() : second.toString();
      _time = Duration(seconds: 1);
      _fullTime = _time;
      _resetAvailable = false;
      _isActive = false;
      _animationController = AnimationController(
          vsync: this, reverseDuration: Duration(seconds: 1));
      _animationController.reverse().then((value) {
        _animationController.reset();
      });
    });
  }

  String formatDate(Duration t) {
    String formattedMin = (t.inMinutes < 10)
        ? '0' + t.inMinutes.toString()
        : t.inMinutes.toString();
    int numSeconds = t.inSeconds - (t.inMinutes * 60);
    String formattedsSec =
        (numSeconds < 10) ? '0' + numSeconds.toString() : numSeconds.toString();
    String formattedTime = formattedMin + ':' + formattedsSec;
    return formattedTime;
  }

  void listenToStream() {
    _streamSubscription = stream().listen((data) {
      setState(() {
        _minuteController.text = data.substring(0, 2);
        _secondController.text = data.substring(3);
      });
    });
  }

  void cancelStream() {
    _streamSubscription.pause();
  }

  void resumeStream() {
    _streamSubscription.resume();
  }

  TextEditingController _minuteController = new TextEditingController();
  TextEditingController _secondController = new TextEditingController();
  StreamSubscription _streamSubscription;
  AnimationController _animationController;
  final player = AudioPlayer();
  var duration;
  int minute = 0;
  int second = 0;
  Duration _time = Duration(seconds: 0);
  Duration _fullTime = Duration(seconds: 0);
  bool _isActive = false;
  bool _resetAvailable = false;
  double _height;

  static int _colorSchemeValue;
  static Color _fontColor;
  final focus = FocusNode();

  void initialiseAudio() async {
    duration = await player.setAsset('assets/sounds/alarmclocksound.mp3');
  }

  callBack(colorSchemeTimer) {
    setState(() {
      _colorSchemeValue = colorSchemeTimer;
      widget.sharedPreferences.setInt('colorSchemeTimer', colorSchemeTimer);
    });
  }

  callBackSliding(value) {
    widget.tabBarVisible(value);
  }

  @override
  void initState() {
    setState(() {
      _colorSchemeValue = widget.colorScheme;
      _fontColor = ColorsP.colorPalette[_colorSchemeValue][6];
    });
    _animationController = AnimationController(
        vsync: this,
        duration: _fullTime,
        reverseDuration: Duration(seconds: 1));
    initialiseAudio();
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => widget.callBackTimerScreen(_colorSchemeValue));

    if (_streamSubscription != null) {
      _streamSubscription.cancel();
    }
    _minuteController.dispose();
    _secondController.dispose();
    _animationController.dispose();
    if (player != null) {
      player.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              Container(
                alignment: Alignment.center,
                color: ColorsP.colorPalette[_colorSchemeValue][5],
                height: MediaQuery.of(context).size.height,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [_buildCustomAnimatedContainer()],
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
                          Container(
                            alignment: Alignment.center,
                            width: 150.0,
                            child: Center(
                              child: TextFormField(
                                textAlign: TextAlign.center,
                                textAlignVertical: TextAlignVertical.center,
                                readOnly: _resetAvailable,
                                enableInteractiveSelection: false,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(2)
                                ],
                                cursorColor: Colors.white,
                                decoration: InputDecoration(
                                  hintText: "00",
                                  hintStyle: TextStyle(
                                      letterSpacing: 20.0,
                                      fontSize: 75.0,
                                      color: _fontColor.withOpacity(0.5)),
                                  focusColor: Colors.white,
                                  border: _resetAvailable == true
                                      ? InputBorder.none
                                      : CommonContainerProps.buttonBorder,
                                  focusedBorder: _resetAvailable == true
                                      ? InputBorder.none
                                      : CommonContainerProps.buttonBorder,
                                  enabledBorder: _resetAvailable == true
                                      ? InputBorder.none
                                      : CommonContainerProps.buttonBorder,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.only(
                                      left: 11, bottom: 11, top: 11, right: 11),
                                ),
                                keyboardType: TextInputType.phone,
                                style: TextStyle(
                                    letterSpacing: 20.0,
                                    fontSize: 75.0,
                                    color: _fontColor),
                                controller: _minuteController,
                                onChanged: (value) {
                                  if (value.length >= 2) {
                                    FocusScope.of(context).requestFocus(focus);
                                  }
                                },
                              ),
                            ),
                          ),
                          Container(
                            child: SizedBox(
                              child: Text(
                                ":",
                                style: TextStyle(
                                  fontSize: 40.0,
                                  color: _fontColor,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            alignment: Alignment.center,
                            width: 150.0,
                            child: TextFormField(
                              textAlign: TextAlign.center,
                              textAlignVertical: TextAlignVertical.center,
                              focusNode: focus,
                              readOnly: _resetAvailable,
                              enableInteractiveSelection: false,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(2)
                              ],
                              cursorColor: Colors.white,
                              decoration: InputDecoration(
                                hintText: "00",
                                hintStyle: TextStyle(
                                    letterSpacing: 20.0,
                                    fontSize: 75.0,
                                    color: _fontColor.withOpacity(0.5)),
                                focusColor: Colors.white,
                                border: _resetAvailable == true
                                    ? InputBorder.none
                                    : CommonContainerProps.buttonBorder,
                                focusedBorder: _resetAvailable == true
                                    ? InputBorder.none
                                    : CommonContainerProps.buttonBorder,
                                enabledBorder: _resetAvailable == true
                                    ? InputBorder.none
                                    : CommonContainerProps.buttonBorder,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                contentPadding: EdgeInsets.only(
                                    left: 11, bottom: 11, top: 11, right: 11),
                              ),
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.phone,
                              style: TextStyle(
                                letterSpacing: 20.0,
                                fontSize: 75.0,
                                color: _fontColor,
                              ),
                              controller: _secondController,
                              onChanged: (value) {
                                if (value.length >= 2) {
                                  FocusScope.of(context).unfocus();
                                }
                              },
                            ),
                          ),
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
                                  padding: const EdgeInsets.all(8.0),
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
                                        if (_secondController.text.isEmpty) {
                                          Fluttertoast.showToast(
                                              msg: "Enter valid duration");
                                          return;
                                        }
                                        setState(() {
                                          if (_isActive == false &&
                                              _time.inSeconds ==
                                                  _fullTime.inSeconds) {
                                            _isActive = true;
                                            _resetAvailable = true;
                                            minute = int.parse(
                                                _minuteController.text.isEmpty
                                                    ? "00"
                                                    : _minuteController.text);
                                            second = int.parse(
                                                _secondController.text);
                                            _time = Duration(
                                                minutes: minute,
                                                seconds: second);
                                            _fullTime = Duration(
                                                minutes: minute,
                                                seconds: second);
                                            _animationController =
                                                AnimationController(
                                                    reverseDuration:
                                                        Duration(seconds: 1),
                                                    vsync: this,
                                                    duration: _fullTime +
                                                        Duration(seconds: 1));
                                            listenToStream();
                                          } else if (_isActive == false &&
                                              _time.inSeconds <
                                                  _fullTime.inSeconds) {
                                            _isActive = true;
                                            _resetAvailable = true;
                                            resumeStream();
                                          }
                                          _animationController.forward();
                                          FocusScope.of(context).unfocus();
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
                                                  _time.inSeconds ==
                                                      _fullTime.inSeconds
                                              ? "START TIMER"
                                              : "RESUME TIMER",
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
                                          "PAUSE TIMER",
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
                                          "RESET TIMER",
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
        return Container(
          alignment: Alignment.bottomCenter,
          height: _height * (1.0 - _animationController.value),
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
