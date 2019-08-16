import 'package:flutter/material.dart';

class InfoTiles extends StatefulWidget {
  final List<dynamic> labels;

  Key key;

  InfoTiles(this.labels, {@required this.key});

  @override
  State<StatefulWidget> createState() =>_InfoTilesState();
}

class _InfoTilesState extends State<InfoTiles> {

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: widget.labels.map((label) =>
          Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 8, 8),
            child: Container(
              color: Colors.black.withAlpha(10),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(label.toString(), style: Theme.of(context).textTheme.subtitle.apply(color: Colors.black45, fontSizeFactor: 0.8),),
                ),
              ),
            ),
          )).toList(),
      ),
    );
  }
}