import 'package:flutter/material.dart';
import 'package:coworking/models/account.dart';
import 'package:coworking/models/meeting.dart';
import 'package:coworking/screens/meetings/new_meeting_form.dart';
import 'package:coworking/widgets/toast.dart';
import 'package:coworking/utils/timeLeft.dart';

class MeetingInfo extends StatefulWidget {
  final Meeting meeting;

  MeetingInfo(this.meeting);

  @override
  _MeetingInfoState createState() => _MeetingInfoState();
}

class _MeetingInfoState extends State<MeetingInfo> {
  final meetingFormKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    void handleClick(String value) {
      switch (value) {
        case 'Изменить':
          if (widget.meeting.author.id == Account.currentAccount.id) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        NewMeetingForm(meeting: widget.meeting)));
            buildToast('Вы автор!');
          } else
            buildToast('Вы не автор!');
          break;
        case 'Поделиться':
          if (widget.meeting.author.id == Account.currentAccount.id) {
            buildToast('Вы автор!');
          } else
            buildToast('Вы не автор!');
          break;
        case 'Удалить':
          // DatabaseService().deleteCheckList(checkList);
          // Navigator.pop(context, true);
          // buildToast('Список был удален');
          if (widget.meeting.author.id == Account.currentAccount.id) {
            buildToast('Вы автор!');
          } else
            buildToast('Вы не автор!');
          break;
      }
    }

    return Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            PopupMenuButton<String>(
              onSelected: handleClick,
              itemBuilder: (BuildContext context) {
                return {'Изменить', 'Поделиться', 'Удалить'}
                    .map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                widget.meeting.description,
                textScaleFactor: 1.1,
              ),
              FutureBuilder(
                future: widget.meeting.author.userName,
                builder: (_, snapshot) => Text(
                  (snapshot.hasData) ? snapshot.data : "Unknown",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                TimeLeft().timeLeft(widget.meeting.dateCompleted.toDate()),
                style: TextStyle(color: Colors.black.withOpacity(0.4)),
              ),
            ],
          ),
        ));
  }
}
