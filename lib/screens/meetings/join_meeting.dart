import 'package:coworking/domain/services/database_meeting.dart';
import 'package:coworking/widgets/meetings_background.dart';
import 'package:coworking/widgets/shadow_container.dart';
import 'package:flutter/material.dart';

class JoinMeeting extends StatefulWidget {
  const JoinMeeting({super.key});

  @override
  JoinMeetingState createState() => JoinMeetingState();
}

class JoinMeetingState extends State<JoinMeeting> {
  Future<void> _joinMeeting(BuildContext context, String meetingId) async {
    final String returnString = await DatabaseMeeting().joinMeeting(meetingId);
    if (returnString == 'success' && context.mounted) {
      Navigator.pop(context);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(returnString),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  final TextEditingController _meetingIdController = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: CustomPaint(
        painter: BackgroundMeetings(),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: const <Widget>[BackButton()],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: ShadowContainer(
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: _meetingIdController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.group),
                        hintText: 'id встречи',
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all<Color>(Colors.orange),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                        child: Text(
                          'Присоединиться',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      onPressed: () {
                        _joinMeeting(context, _meetingIdController.text);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
