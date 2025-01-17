import 'graphmodel.dart';
import 'viewdata.dart';
import 'package:flutter/material.dart';

double largestValue = 0;
double graphSize = 0;

// ignore: must_be_immutable
class BarGraph extends StatefulWidget {
  final List<GraphModel> graphData;
  late double largestValue;
  final Color backgroundColor;
  final Color textColor;
  final double graphHeight;
  final double graphWidth;

  BarGraph(
      {super.key,
      required this.graphData,
      required this.largestValue,
      required this.backgroundColor,
      required this.textColor,
      required this.graphHeight,
      required this.graphWidth});

  @override
  State<BarGraph> createState() => _BarGraphState();
}

class _BarGraphState extends State<BarGraph> {
  @override
  Widget build(BuildContext context) {
    largestValue = widget.largestValue;
    graphSize = widget.graphHeight;

    return Center(
        child: Container(
      width: 300.0,
      padding: const EdgeInsets.all(10),
      color: widget.backgroundColor,
      child: Container(
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 45.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(height: widget.graphHeight),
                Text(
                  "__",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
              ],
            ),
          ),
          // Y-axis line (vertical)
          Container(
            height: widget.graphHeight,
            width: 2, // Thickness of the Y-axis line
            color: Theme.of(context).colorScheme.inversePrimary, // Axis color
          ),
          // Graph container with bars
          Column(
            children: [
              // Graph Bars
              Container(
                height: widget.graphHeight + 42.0,
                width: widget.graphWidth, // Set the width using graphWidth
                color: widget.backgroundColor,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: widget.graphData.map((e) {
                    return Container(
                      height: widget.graphHeight,
                      width: widget.graphWidth /
                          widget.graphData
                              .length, // Adjust width based on the number of bars
                      color: widget.backgroundColor,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ViewData(
                            dataDate: e.dateData.toString(),
                            dataValue: e.valueData,
                            dataColor: e.colorData,
                            textColors: widget.textColor,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ]),
      ),
    ));
  }
}
