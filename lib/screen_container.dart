import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timer_project/stopwatch_screen.dart';
import 'package:timer_project/timer_screen.dart';

class ScreensContainer extends StatefulWidget {
  @override
  _ScreensContainerState createState() => _ScreensContainerState();
}

class _ScreensContainerState extends State<ScreensContainer>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  SharedPreferences sharedPreferences;
  bool readyToShow = false;
  static int colorSchemeValueTimerScreen;
  static int colorSchemeValueStopwatchScreen;

  static bool tabBarVisible = true;

  TabController _tabController;

  callBackTimerScreen(colorScheme) {
    setState(() {
      colorSchemeValueTimerScreen = colorScheme;
    });
  }

  callBackStopwatchScreen(colorScheme) {
    setState(() {
      colorSchemeValueStopwatchScreen = colorScheme;
    });
  }

  callBackTabBarVisibility(isVisible) {
    setState(() {
      tabBarVisible = isVisible;
    });
  }

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    initialiseSharedPreferences();
    super.initState();
  }

  void initialiseSharedPreferences() async {
    sharedPreferences = await SharedPreferences.getInstance().then((value) {
      setState(() {
        colorSchemeValueTimerScreen = value.getInt('colorSchemeTimer') ?? 5;
        colorSchemeValueStopwatchScreen =
            value.getInt('colorSchemeStopwatch') ?? 2;
        readyToShow = true;
      });
      return value;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return readyToShow == false
        ? Container(
            color: Colors.black87,
            alignment: Alignment.center,
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          )
        : Scaffold(
            backgroundColor: Colors.black87,
            key: _scaffoldKey,
            extendBodyBehindAppBar: true,
            body: Stack(
              children: <Widget>[
                TabBarView(
                  controller: _tabController,
                  children: <Widget>[
                    TimerScreen(
                      colorScheme: colorSchemeValueTimerScreen,
                      callBackTimerScreen: callBackTimerScreen,
                      tabBarVisible: callBackTabBarVisibility,
                      sharedPreferences: sharedPreferences,
                    ),
                    StopwatchScreen(
                      colorScheme: colorSchemeValueStopwatchScreen,
                      callBackStopwathScreen: callBackStopwatchScreen,
                      tabBarVisible: callBackTabBarVisibility,
                      sharedPreferences: sharedPreferences,
                    ),
                  ],
                ),
                Visibility(
                  visible: tabBarVisible,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment(0.0, 0.85),
                      child: TabBar(
                        indicatorPadding:
                            EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                        labelColor: Colors.black,
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        unselectedLabelColor: Colors.white,
                        unselectedLabelStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            50.0,
                          ),
                          color: Colors.white,
                        ),
                        controller: _tabController,
                        tabs: [
                          Tab(
                            text: "TIMER",
                          ),
                          Tab(
                            text: "STOP WATCH",
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
