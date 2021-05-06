import 'package:coworking/models/meeting.dart';
import 'package:coworking/utils/time_left.dart';
import 'package:flutter/material.dart';
import 'package:coworking/screens/meetings/meeting_info.dart';

///этот класс отвечает за отображение *моих* митингов
class MeetingListItem extends StatefulWidget {
  const MeetingListItem(this.meeting);

  final Meeting meeting;

  @override
  _MeetingListItemState createState() => _MeetingListItemState();
}

class _MeetingListItemState extends State<MeetingListItem> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min,
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 10,
          ),
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(40)),
                color: Colors.orangeAccent,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black45,
                      offset: Offset(-5, 5),
                      blurRadius: 10,
                      spreadRadius: 1),
                ]),
            padding:
                const EdgeInsets.symmetric(vertical: 5.0, horizontal: 16.0),
            child: InkWell(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MeetingInfo(widget.meeting))),
              child: Center(
                  child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Место проведения:  " + widget.meeting.place,
                    style: DefaultTextStyle.of(context)
                        .style
                        .apply(fontSizeFactor: 1.2),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  FutureBuilder(
                    future: widget.meeting.author.userName,
                    builder: (_, snapshot) => Text(
                      (snapshot.hasData)
                          ? "Организатор:  " + snapshot.data
                          : "Организатор:  " + "Unknown",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "До встречи осталось:  ",
                    style: TextStyle(color: Colors.black.withOpacity(0.4)),
                  ),
                  Text(
                    TimeLeft().timeLeft(widget.meeting.dateCompleted.toDate()),
                    style: TextStyle(color: Colors.black.withOpacity(0.4)),
                  ),
                ],
              )),
            ),
          ),
          SizedBox(
            height: 20,
          ),
        ]);
  }
}
