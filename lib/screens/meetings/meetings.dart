import 'package:flutter/material.dart';
import 'package:coworking/models/account.dart';
import 'package:coworking/models/meeting.dart';
import 'package:coworking/screens/meetings/new_meeting_form.dart';
import 'package:coworking/screens/meetings/meeting_tile.dart';
import 'package:coworking/screens/meetings/join_meeting.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:coworking/widgets/meetings_background.dart';

class UserMeetingsPage extends StatelessWidget {
  const UserMeetingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text('Ваши встречи'),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            semanticLabel: "Back",
          ),
          onPressed: () => Navigator.pop(context, false),
        ),
        actions: <Widget>[
          PopupMenuButton(
            tooltip: "Help",
            icon: const Icon(
              Icons.help,
              color: Colors.black,
            ),
            itemBuilder: (BuildContext context) => <PopupMenuEntry>[
              const PopupMenuItem(
                child: Text(
                  "\nЗдесь будут отображаться все ваши встречи.\n"
                  "\nПо нажатию на кнопку внизу вы можете либо создать встречу, "
                  "либо присоединиться к действующей.\n",
                  textAlign: TextAlign.justify,
                ),
              ),
            ],
          )
        ],
      ),
      body: const MeetingLayout(),
    );
  }
}

class MeetingLayout extends StatefulWidget {
  const MeetingLayout({Key? key}) : super(key: key);

  @override
  _MeetingLayoutState createState() => _MeetingLayoutState();
}

class _MeetingLayoutState extends State<MeetingLayout> {
  Widget _getFAB() {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: const IconThemeData(size: 22),
      backgroundColor: Colors.orange,
      visible: true,
      curve: Curves.bounceIn,
      children: [
        // FAB 1
        SpeedDialChild(
            child: const Icon(Icons.assignment_return),
            backgroundColor: Colors.orange,
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const JoinMeeting()));
            },
            label: 'Присоединиться ко встрече',
            labelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.white,
                fontSize: 16.0),
            labelBackgroundColor: Colors.orange),
        // FAB 2
        SpeedDialChild(
            child: const Icon(Icons.assignment_ind),
            backgroundColor: Colors.orange,
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const NewMeetingForm(
                            meeting: null,
                          )));
            },
            label: 'Создать встречу',
            labelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.white,
                fontSize: 16.0),
            labelBackgroundColor: Colors.orange)
      ],
    );
  }

  var meetingFormKey = GlobalKey<NewMeetingFormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: _getFAB(),
        body: CustomPaint(
            painter: BackgroundMeetings(),
            child: StreamBuilder<List<Meeting>>(
              stream: Account.getMeetingsForUser(context),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return MeetingListItem(snapshot.data![index]);
                    },
                  );
                } else {
                  return const Center(
                    child: Text("Пока здесь пусто :( \n",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20)),
                  );
                }
              },
            )));
  }
}
