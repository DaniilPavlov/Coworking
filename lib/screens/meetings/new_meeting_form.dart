import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coworking/services/database_meeting.dart';
import 'package:coworking/widgets/shadow_container.dart';
import 'package:flutter/material.dart';
import 'package:coworking/models/account.dart';
import 'package:coworking/models/meeting.dart';
import 'package:intl/intl.dart';
import 'package:numberpicker/numberpicker.dart';

///ПЕРЕДЕЛЫВАЮ ПОД ИЗМЕНЕНИЕ
class NewMeetingForm extends StatefulWidget {
  final Meeting meeting;

  NewMeetingForm({Key key, this.meeting}) : super(key: key);

  State<NewMeetingForm> createState() => NewMeetingFormState();
}

class NewMeetingFormState extends State<NewMeetingForm>
    with AutomaticKeepAliveClientMixin<NewMeetingForm> {
  final addMeetingKey = GlobalKey<ScaffoldState>();

  TextEditingController _meetingPlaceController = TextEditingController();
  TextEditingController _meetingDescriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  bool isOld = false;
  Meeting meeting;
  List<String> members = List();
  List<String> tokens = List();

  @override
  bool get wantKeepAlive => true;

  initState() {
    if (widget.meeting != null) {
      isOld = true;
      meeting = widget.meeting.copy();
      _meetingDescriptionController.text = meeting.description;
      _meetingPlaceController.text = meeting.place;
    }
    super.initState();
  }

  Future<void> _selectDate() async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2222));

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = DateTime(picked.year, picked.month, picked.day,
            _selectedDate.hour, 0, 0, 0, 0);
      });
    }
  }

  Future _selectTime() async {
    await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return new NumberPickerDialog.integer(
          minValue: 0,
          maxValue: 23,
          initialIntegerValue: 0,
          infiniteLoop: true,
        );
      },
    ).then((num value) {
      if (value != null) {
        setState(() {
          _selectedDate = DateTime(_selectedDate.year, _selectedDate.month,
              _selectedDate.day, value, 0, 0, 0, 0);
        });
      }
    });
  }

  void _editMeeting(BuildContext context, Meeting meeting) async {
    String _returnString;
    if (_selectedDate.isAfter(DateTime.now().add(Duration(days: 1)))) {
      _returnString = await DatabaseMeeting().editMeeting(meeting);
      if (_returnString == "success") {
        setState(() {
          widget.meeting.place = meeting.place;
          widget.meeting.description = meeting.description;
          widget.meeting.dateCompleted = meeting.dateCompleted;
        });
        Navigator.pop(context);
      }
    } else {
      addMeetingKey.currentState.showSnackBar(
        SnackBar(
          content: Text("До начала всего 24 часа, это слишком мало!"),
        ),
      );
    }
  }

  void _addMeeting(BuildContext context, Meeting meeting) async {
    String _returnString;

    if (_selectedDate.isAfter(DateTime.now().add(Duration(days: 1)))) {
      _returnString = await DatabaseMeeting().addMeeting(meeting);

      if (_returnString == "success") {
        Navigator.pop(context);
      }
    } else {
      addMeetingKey.currentState.showSnackBar(
        SnackBar(
          content: Text("До начала всего 24 часа, это слишком мало!"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: addMeetingKey,
      body: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: <Widget>[BackButton()],
            ),
          ),
          SizedBox(
            height: 40,
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ShadowContainer(
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: _meetingPlaceController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.place),
                      hintText: "Место встречи",
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  TextFormField(
                    controller: _meetingDescriptionController,
                    validator: (text) =>
                        text.isEmpty ? "Описание обязательно" : null,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Описание",
                      contentPadding: EdgeInsets.all(8.0),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(DateFormat.yMMMMd("en_US").format(_selectedDate)),
                  Text(DateFormat("H:00").format(_selectedDate)),
                  Row(
                    children: [
                      Expanded(
                        child: FlatButton(
                          child: Text("Изменить дату"),
                          onPressed: () => _selectDate(),
                        ),
                      ),
                      Expanded(
                        child: FlatButton(
                          child: Text("Изменить время"),
                          onPressed: () => _selectTime(),
                        ),
                      ),
                    ],
                  ),
                  RaisedButton(
                    color: Colors.orange,
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                      child: Text(
                        "Назначить",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                        ),
                      ),
                    ),
                    onPressed: () {
                      Meeting meeting = Meeting(null, "", "",
                          Account.currentAccount, members, tokens, null, false);
                      if (_meetingPlaceController.text == "") {
                        addMeetingKey.currentState.showSnackBar(SnackBar(
                          content: Text("Требуется добавить место встречи"),
                        ));
                      } else if (_meetingDescriptionController.text == "") {
                        addMeetingKey.currentState.showSnackBar(SnackBar(
                          content: Text("Требуется добавить описание встречи"),
                        ));
                      } else {
                        meeting.place = _meetingPlaceController.text;
                        meeting.description =
                            _meetingDescriptionController.text;
                        meeting.dateCompleted =
                            Timestamp.fromDate(_selectedDate);
                        if (isOld) {
                          meeting.id = widget.meeting.id;
                          _editMeeting(context, meeting);
                        } else
                          _addMeeting(context, meeting);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
