import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coworking/domain/entities/account.dart';
import 'package:coworking/domain/services/database_meeting.dart';
import 'package:coworking/widgets/shadow_container.dart';
import 'package:coworking/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:coworking/domain/entities/meeting.dart';
import 'package:intl/intl.dart';
import 'package:coworking/widgets/meetings_background.dart';

class NewMeetingForm extends StatefulWidget {
  final Meeting? meeting;

  const NewMeetingForm({Key? key, this.meeting}) : super(key: key);

  @override
  State<NewMeetingForm> createState() => NewMeetingFormState();
}

class NewMeetingFormState extends State<NewMeetingForm>
    with AutomaticKeepAliveClientMixin<NewMeetingForm> {
  final addMeetingKey = GlobalKey<ScaffoldState>();

  final TextEditingController _meetingPlaceController = TextEditingController();
  final TextEditingController _meetingDescriptionController =
      TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  bool isOld = false;
  late Meeting meeting;
  List<String> members = [];
  List<String> tokens = [];

  @override
  bool get wantKeepAlive => true;

  @override
  initState() {
    if (widget.meeting != null) {
      isOld = true;
      meeting = widget.meeting!.copy();
      _meetingDescriptionController.text = meeting.description;
      _meetingPlaceController.text = meeting.place;
      _selectedDate = widget.meeting!.dateCompleted!.toDate();
      _selectedTime =
          TimeOfDay(hour: _selectedDate.hour, minute: _selectedDate.minute);
    }
    super.initState();
  }

  Future _selectDate() async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2222));

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = DateTime(picked.year, picked.month, picked.day,
            _selectedTime.hour, _selectedTime.minute, 0, 0, 0);
      });
    }
  }

  Future _selectTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: _selectedTime,
        builder: (BuildContext context, Widget? child) => MediaQuery(
              data:
                  MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
              child: child!,
            ));

    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
        _selectedDate = DateTime(
            _selectedDate.year,
            _selectedDate.month,
            _selectedDate.day,
            _selectedTime.hour,
            _selectedTime.minute,
            0,
            0,
            0);
      });
    }
  }

  void _editMeeting(BuildContext context, Meeting meeting) async {
    String _returnString;
    if (_selectedDate.isAfter(DateTime.now().add(const Duration(hours: 2)))) {
      _returnString = await DatabaseMeeting().editMeeting(meeting);
      if (_returnString == "success") {
        setState(() {
          widget.meeting!.place = meeting.place;
          widget.meeting!.description = meeting.description;
          widget.meeting!.dateCompleted = meeting.dateCompleted;
        });
        Navigator.of(context).pop(widget.meeting);
      }
    } else {
      buildToast("До начала всего 2 часа, это слишком мало!");
    }
  }

  void _addMeeting(BuildContext context, Meeting meeting) async {
    String _returnString;

    ///возможно изменить время для начала
    if (_selectedDate.isAfter(DateTime.now().add(const Duration(hours: 2)))) {
      _returnString = await DatabaseMeeting().addMeeting(meeting);

      if (_returnString == "success") {
        Navigator.pop(context);
      }
    } else {
      buildToast("До начала всего 2 часа, это слишком мало!");
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      key: addMeetingKey,
      body: CustomPaint(
          painter: BackgroundMeetings(),
          child: ListView(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: const <Widget>[BackButton()],
                ),
              ),
              const SizedBox(
                height: 60,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20, top: 60),
                child: ShadowContainer(
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        controller: _meetingPlaceController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.place),
                          hintText: "Место встречи",
                        ),
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      TextFormField(
                        controller: _meetingDescriptionController,
                        validator: (text) =>
                            text!.isEmpty ? "Описание обязательно" : null,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: "Описание",
                          contentPadding: EdgeInsets.all(8.0),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(DateFormat.yMMMMd("en_US").format(_selectedDate)),
                      Text("${_selectedTime.hour} : ${_selectedTime.minute}"),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              child: const Text("Изменить дату"),
                              onPressed: () => _selectDate(),
                            ),
                          ),
                          Expanded(
                            child: TextButton(
                              child: const Text("Изменить время"),
                              onPressed: () => _selectTime(),
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.red)),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 50, vertical: 10),
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
                          Meeting? meeting = Meeting(
                              null,
                              "",
                              "",
                              Account.currentAccount!,
                              members,
                              tokens,
                              null,
                              false);
                          if (_meetingPlaceController.text == "") {
                            buildToast("Требуется добавить место встречи");
                          } else if (_meetingDescriptionController.text == "") {
                            buildToast("Требуется добавить описание встречи");
                          } else {
                            meeting.place = _meetingPlaceController.text;
                            meeting.description =
                                _meetingDescriptionController.text;
                            meeting.dateCompleted =
                                Timestamp.fromDate(_selectedDate);
                            if (isOld) {
                              meeting.id = widget.meeting!.id;
                              _editMeeting(context, meeting);
                            } else {
                              _addMeeting(context, meeting);
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )),
    );
  }
}
