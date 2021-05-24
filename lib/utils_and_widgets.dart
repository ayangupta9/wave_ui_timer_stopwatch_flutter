import 'package:flutter/material.dart';
import 'package:timer_project/colorPalette2.dart';

class CommonContainerProps {
  static BoxDecoration decoration = BoxDecoration(
    boxShadow: [
      BoxShadow(
        color: Colors.black54,
        blurRadius: 12.0,
        spreadRadius: -2.5,
      )
    ],
    borderRadius: BorderRadius.circular(
      30.0,
    ),
    color: Colors.white,
  );

  static EdgeInsets padding = EdgeInsets.only(top: 20.0, bottom: 20.0);

  static InputBorder buttonBorder = UnderlineInputBorder(
    borderSide: BorderSide(color: Colors.white, width: 1.0),
    borderRadius: BorderRadius.circular(10.0),
  );

  static Widget circleColors(int x, int y) {
    return CircleAvatar(
      radius: 20.0,
      backgroundColor: ColorsP.colorPalette[x][y],
    );
  }

  static Widget colonSizedBoxWidget(Color fontColor) {
    return SizedBox(
      width: 1.0,
      child: Text(
        ":",
        style: TextStyle(
          fontSize: 30.0,
          color: fontColor,
        ),
      ),
    );
  }

  static timeUnitWidget(String text, Color fontColor) {
    return Container(
      width: 125.0,
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(letterSpacing: 10.0, fontSize: 65.0, color: fontColor),
      ),
    );
  }
}
