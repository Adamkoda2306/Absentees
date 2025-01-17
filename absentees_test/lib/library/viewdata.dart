import 'package:flutter/material.dart';
import 'bargraph.dart';

class ViewData extends StatelessWidget {
  final String dataDate;
  final double dataValue;
  final Color dataColor;
  final Color textColors;
  const ViewData(
      {super.key,
      required this.dataDate,
      required this.dataValue,
      required this.dataColor,
      required this.textColors});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Container(
        padding: const EdgeInsets.fromLTRB(0, 5.0, 0, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              height: ((dataValue / largestValue) * size.width) / 1.5,
              width: 28,
              color: dataColor,
              child: Center(
                child: Text(
                  dataValue.toStringAsFixed(1),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    fontSize: 9,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
            ),
            Text(
              "_____",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
            Text(
              dataDate,
              style: TextStyle(
                fontSize: 9,
                color: textColors,
              ),
            )
          ],
        ));
  }
}
