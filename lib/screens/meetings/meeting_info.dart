import 'package:flutter/material.dart';
import 'package:coworking/models/account.dart';
import 'package:coworking/models/meeting.dart';
import 'package:coworking/screens/meetings/new_meeting_form.dart';
import 'package:coworking/widgets/toast.dart';
import 'package:coworking/utils/time_left.dart';
import 'package:coworking/services/database_meeting.dart';
import 'package:flutter/services.dart';
import 'package:coworking/screens/meetings/meetings.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

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
          } else
            buildToast('Вы не автор!');
          break;
        case 'Скопировать ключ':
          Clipboard.setData(ClipboardData(text: widget.meeting.id));
          buildToast('Вы скопировали ключ!' + widget.meeting.id);
          break;
        case 'Покинуть':
          if (widget.meeting.author.id == Account.currentAccount.id) {
            showDialog(
                context: context,
                builder: (context2) => AlertDialog(
                        title: Text(
                          "Если вы покинете встречу, она будет удалена. Продолжить?",
                          style: TextStyle(color: Colors.orange),
                        ),
                        actions: <Widget>[
                          FlatButton(
                              child: Text(
                                "Да",
                                style: TextStyle(color: Colors.white),
                              ),
                              color: Colors.orange,
                              onPressed: () {
                                DatabaseMeeting.deleteMeeting(widget.meeting);
                                Navigator.pop(context2, true);
                                Navigator.pop(context, true);
                                buildToast('Встреча была удалена');
                              }),
                          SizedBox(
                            width: 100,
                          ),
                          FlatButton(
                            child: Text("Нет",
                                style: TextStyle(color: Colors.white)),
                            color: Colors.orange,
                            onPressed: () {
                              Navigator.pop(context2, false);
                            },
                          ),
                        ]));
          } else
            showDialog(
                context: context,
                builder: (context1) => AlertDialog(
                        title: Text(
                          "Вы действительно хотите покинуть встречу?",
                          style: TextStyle(color: Colors.orange),
                        ),
                        actions: <Widget>[
                          FlatButton(
                              child: Text(
                                "Да",
                                style: TextStyle(color: Colors.white),
                              ),
                              color: Colors.orange,
                              onPressed: () {
                                DatabaseMeeting.leaveMeeting(widget.meeting.id);
                                Navigator.pop(context1, true);
                                Navigator.pop(context, true);
                                buildToast('Вы покинули встречу');
                              }),
                          SizedBox(
                            width: 100,
                          ),
                          FlatButton(
                            child: Text("Нет",
                                style: TextStyle(color: Colors.white)),
                            color: Colors.orange,
                            onPressed: () {
                              Navigator.pop(context, false);
                            },
                          ),
                        ]));
          break;
        case 'Удалить':
          if (widget.meeting.author.id == Account.currentAccount.id) {
            DatabaseMeeting.deleteMeeting(widget.meeting);
            Navigator.pop(context, true);
            buildToast('Встреча была удалена');
          } else
            buildToast('Вы не автор!');
          break;
      }
    }

    Widget notifyFAB() {
      return SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        animatedIconTheme: IconThemeData(size: 22),
        backgroundColor: Colors.orange,
        visible: true,
        curve: Curves.bounceIn,
        children: [
          // FAB 1
          SpeedDialChild(
              child: Icon(Icons.timer),
              backgroundColor: Colors.orange,
              onTap: () async{
                await DatabaseMeeting().timeNotify(widget.meeting);
              },
              label: 'Напомнить о встрече',
              labelStyle: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  fontSize: 16.0),
              labelBackgroundColor: Colors.orange),
          // FAB 2
          SpeedDialChild(
              child: Icon(Icons.fiber_new_outlined),
              backgroundColor: Colors.orange,
              onTap: () async{
                await DatabaseMeeting().changeInfoNotify(widget.meeting);
              },
              label: 'Информация о встрече изменилась',
              labelStyle: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  fontSize: 16.0),
              labelBackgroundColor: Colors.orange)
        ],
      );
    }

    return Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            PopupMenuButton<String>(
              onSelected: handleClick,
              itemBuilder: (BuildContext context) {
                return {'Изменить', 'Скопировать ключ', 'Покинуть', 'Удалить'}
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
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: notifyFAB(),
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
                  (snapshot.hasData) ? snapshot.data : "Anonymous",
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
