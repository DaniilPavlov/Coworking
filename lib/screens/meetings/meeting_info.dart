import 'package:flutter/material.dart';
import 'package:coworking/models/account.dart';
import 'package:coworking/models/meeting.dart';
import 'package:coworking/screens/meetings/new_meeting_form.dart';
import 'package:coworking/widgets/toast.dart';
import 'package:coworking/utils/time_left.dart';
import 'package:coworking/services/database_meeting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:coworking/widgets/meetings_background.dart';
import 'package:coworking/widgets/shadow_container.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MeetingInfo extends StatefulWidget {
  final Meeting meeting;

  MeetingInfo({this.meeting});

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
                        NewMeetingForm(meeting: widget.meeting))).then((value) {
              if (value != null) {
                setState(() {
                  widget.meeting.place = value.place;
                  widget.meeting.description = value.description;
                  widget.meeting.dateCompleted = value.dateCompleted;
                });
              } else {
                print('Do nothing');
              }
            });
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
            showDialog(
                context: context,
                builder: (context2) => AlertDialog(
                        title: Text(
                          "Встреча будет удалена. Продолжить?",
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
            buildToast('Вы не автор!');
          break;
      }
    }

    Widget notifyFAB() {
      return SpeedDial(
        icon: Icons.notifications,
        backgroundColor: Colors.orange,
        visible: true,
        curve: Curves.bounceIn,
        children: [
          // FAB 1
          SpeedDialChild(
              child: Icon(Icons.timer),
              backgroundColor: Colors.orange,
              onTap: () async {
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
              onTap: () async {
                DateTime updateDate = widget.meeting.dateCompleted.toDate();
                updateDate = DateTime(
                    updateDate.year,
                    updateDate.month,
                    updateDate.day,
                    updateDate.hour,
                    updateDate.minute,
                    updateDate.second,
                    updateDate.millisecond,
                    updateDate.microsecond + 1);
                widget.meeting.dateCompleted = Timestamp.fromDate(updateDate);

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
          title: Text("О встрече"),
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
        body: CustomPaint(
            painter: BackgroundMeetings(),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 20.0, right: 20, bottom: 80, top: 20),
                child: ShadowContainer(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        "Место проведения:",
                        textScaleFactor: 2,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        widget.meeting.place,
                        textScaleFactor: 2,
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                      Divider(
                        thickness: 2,
                        color: Colors.orange,
                      ),
                      Text(
                        "Описание:",
                        textScaleFactor: 2,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Expanded(
                          child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Text(
                                widget.meeting.description,
                                textScaleFactor: 1.5,
                              ))),
                      Divider(
                        thickness: 2,
                        color: Colors.orange,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      FutureBuilder(
                        future: widget.meeting.author.userName,
                        builder: (_, snapshot) => Text(
                          (snapshot.hasData)
                              ? "Организатор:  " + snapshot.data
                              : "Организатор:  " + "Anonymous",
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "До встречи осталось:",
                        style: TextStyle(color: Colors.black.withOpacity(0.4)),
                      ),
                      Text(
                        TimeLeft()
                            .timeLeft(widget.meeting.dateCompleted.toDate()),
                        style: TextStyle(color: Colors.black.withOpacity(0.4)),
                      ),
                    ],
                  ),
                ),
              ),
            )));
  }
}
