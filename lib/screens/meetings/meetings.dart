import 'package:flutter/material.dart';
import 'package:coworking/models/account.dart';
import 'package:coworking/models/meeting.dart';
import 'package:coworking/screens/meetings/new_meeting_form.dart';
import 'package:coworking/screens/meetings/meeting_tile.dart';
import 'package:coworking/screens/meetings/join_meeting.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class UserMeetingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text('Ваши встречи'),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            semanticLabel: "Back",
          ),
          onPressed: () => Navigator.pop(context, false),
        ),
        actions: <Widget>[
          PopupMenuButton(
            tooltip: "Help",
            icon: Icon(
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
      body: MeetingLayout(),
    );
  }
}

class MeetingLayout extends StatefulWidget {
  @override
  _MeetingLayoutState createState() => _MeetingLayoutState();
}

class _MeetingLayoutState extends State<MeetingLayout> {
  Widget _getFAB() {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: IconThemeData(size: 22),
      backgroundColor: Colors.orange,
      visible: true,
      curve: Curves.bounceIn,
      children: [
        // FAB 1
        SpeedDialChild(
            child: Icon(Icons.assignment_turned_in),
            backgroundColor: Colors.orange,
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => JoinMeeting()));
            },
            label: 'Присоединиться ко встрече',
            labelStyle: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.white,
                fontSize: 16.0),
            labelBackgroundColor: Colors.orange),
        // FAB 2
        SpeedDialChild(
            child: Icon(Icons.assignment_turned_in),
            backgroundColor: Colors.orange,
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => NewMeetingForm()));
            },
            label: 'Создать встречу',
            labelStyle: TextStyle(
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
        body: StreamBuilder<List<Meeting>>(
          stream: Account.getMeetingsForUser(context),
          builder: (context, snapshot) {
            Widget progressIndicator = Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            );

            ///При рестарте и заходе в данное место может произойти ошибка
            return CustomScrollView(
                physics: BouncingScrollPhysics(),
                slivers: <Widget>[
                  (snapshot.hasData ||
                          snapshot.connectionState != ConnectionState.waiting)
                      ? SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, i) => MeetingListItem(snapshot.data[i]),
                            childCount: snapshot.data.length,
                          ),
                        )
                      : SliverFillRemaining(
                          child: progressIndicator,
                          hasScrollBody: false,
                        ),
                  SliverFillRemaining(hasScrollBody: false),
                  SliverToBoxAdapter(
                    child: Padding(padding: EdgeInsets.all(1.0)),
                  )
                ]);
          },
        ));
  }
}
