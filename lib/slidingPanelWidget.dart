import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:timer_project/colorPalette2.dart';
import 'package:timer_project/utils_and_widgets.dart';

class SlidingPanelWidget extends StatefulWidget {
  final Function(int) callback;
  final Function(bool) tabBarVisible;
  SlidingPanelWidget(this.callback, this.tabBarVisible);

  @override
  _SlidingPanelWidgetState createState() => _SlidingPanelWidgetState();
}

class _SlidingPanelWidgetState extends State<SlidingPanelWidget> {
  int i = 5;

  @override
  Widget build(BuildContext context) {
    return SlidingUpPanel(
      backdropTapClosesPanel: true,
      backdropEnabled: true,
      backdropColor: Colors.black,
      backdropOpacity: 0.75,
      collapsed: Container(
        alignment: Alignment.center,
        child: Center(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(5.0),
                margin: EdgeInsets.only(right: 10.0),
                child: Image.network(
                  "https://cdn0.iconfinder.com/data/icons/arrows-android-l-lollipop-icon-pack/24/collapse2-512.png",
                ),
              ),
            ],
          ),
        ),
      ),
      boxShadow: [
        BoxShadow(
          color: ColorsP.colorPalette[i][4],
          blurRadius: 10.0,
          spreadRadius: 0.0,
        ),
      ],
      onPanelSlide: (value) {
        if (value > 0.0) {
          widget.tabBarVisible(false);
        } else {
          widget.tabBarVisible(true);
        }
      },
      parallaxEnabled: true,
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
      minHeight: 25.0,
      maxHeight: 450.0,
      panel: PageView(
        controller: PageController(viewportFraction: 0.9),
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(top: 40.0, bottom: 20.0),
                alignment: Alignment.center,
                child: Text("Choose a theme"),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    i = 0;
                  });
                  widget.callback(0);
                },
                child: Container(
                  padding: CommonContainerProps.padding,
                  margin: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 20.0),
                  decoration: CommonContainerProps.decoration,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        for (int j = 0; j < 5; j++)
                          CommonContainerProps.circleColors(0, j)
                      ],
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    i = 1;
                  });
                  widget.callback(1);
                },
                child: Container(
                  padding: CommonContainerProps.padding,
                  margin: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
                  decoration: CommonContainerProps.decoration,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        for (int j = 0; j < 5; j++)
                          CommonContainerProps.circleColors(1, j)
                      ],
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    i = 2;
                  });
                  widget.callback(2);
                },
                child: Container(
                  padding: CommonContainerProps.padding,
                  margin: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 40.0),
                  decoration: CommonContainerProps.decoration,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        for (int j = 0; j < 5; j++)
                          CommonContainerProps.circleColors(2, j)
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(top: 40.0, bottom: 20.0),
                alignment: Alignment.center,
                child: Text("Choose a theme"),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    i = 3;
                  });
                  widget.callback(3);
                },
                child: Container(
                  padding: CommonContainerProps.padding,
                  margin: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 20.0),
                  decoration: CommonContainerProps.decoration,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        for (int j = 0; j < 5; j++)
                          CommonContainerProps.circleColors(3, j)
                      ],
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    i = 4;
                  });
                  widget.callback(4);
                },
                child: Container(
                  padding: CommonContainerProps.padding,
                  decoration: CommonContainerProps.decoration,
                  margin: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        for (int j = 0; j < 5; j++)
                          CommonContainerProps.circleColors(4, j)
                      ],
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    i = 5;
                  });
                  widget.callback(5);
                },
                child: Container(
                  padding: CommonContainerProps.padding,
                  margin: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 40.0),
                  decoration: CommonContainerProps.decoration,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        for (int j = 0; j < 5; j++)
                          CommonContainerProps.circleColors(5, j)
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
