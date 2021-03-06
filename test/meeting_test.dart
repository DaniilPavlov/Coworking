// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:coworking/widgets/shadow_container.dart';
// import 'package:intl/intl.dart';

// class MeetingWidget extends StatefulWidget {
//   String name;
//   String description;
//   String hour;
//   String minute;

//   MeetingWidget({
//     Key key,
//     @required this.name,
//     @required this.description,
//     @required this.hour,
//     @required this.minute,
//   }) : super(key: key);

//   State<MeetingWidget> createState() => MeetingWidgetState();
// }

// GlobalKey<FormFieldState> timeKey = GlobalKey();
// GlobalKey<FormFieldState> textKey = GlobalKey();

// class MeetingWidgetState extends State<MeetingWidget> {
//   var addMeetingKey = GlobalKey<ScaffoldState>();

//   TextEditingController _meetingPlaceController =
//       TextEditingController(text: "Your initial value");
//   TextEditingController _meetingDescriptionController =
//       TextEditingController(text: "Your initial value");
//   DateTime _selectedDate = DateTime.now();
//   TimeOfDay _selectedTime = TimeOfDay.now();
//   var save = "Invalid";

//   @override
//   void initState() {
//     super.initState();
//     _meetingPlaceController.text = widget.name;
//     _meetingDescriptionController.text = widget.description;
//   }

//   Future _selectDate() async {
//     final DateTime picked = await showDatePicker(
//         context: context,
//         initialDate: DateTime.now(),
//         firstDate: DateTime.now(),
//         lastDate: DateTime(2222));

//     if (picked != null && picked != _selectedDate) {
//       setState(() {
//         _selectedDate = DateTime(picked.year, picked.month, picked.day,
//             _selectedTime.hour, _selectedTime.minute, 0, 0, 0);
//         print(_selectedDate.minute);
//       });
//     }
//   }

//   Future _selectTime() async {
//     TimeOfDay pickedTime = await showTimePicker(
//         context: context,
//         initialTime: _selectedTime,
//         builder: (BuildContext context, Widget child) {
//           return MediaQuery(
//             data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
//             child: child,
//           );
//         });

//     if (pickedTime != null && pickedTime != _selectedTime) {
//       setState(() {
//         _selectedTime = pickedTime;
//         _selectedDate = DateTime(
//             _selectedDate.year,
//             _selectedDate.month,
//             _selectedDate.day,
//             _selectedTime.hour,
//             _selectedTime.minute,
//             0,
//             0,
//             0);
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Review Widget',
//       home: Scaffold(
//           key: addMeetingKey,
//           body: ListView(
//             children: <Widget>[
//               Padding(
//                 padding: const EdgeInsets.all(20.0),
//                 child: Row(
//                   children: <Widget>[BackButton()],
//                 ),
//               ),
//               SizedBox(
//                 height: 60,
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(left: 20.0, right: 20, top: 60),
//                 child: ShadowContainer(
//                   child: Column(
//                     children: <Widget>[
//                       TextFormField(
//                         key: textKey,
//                         controller: _meetingPlaceController,
//                         decoration: InputDecoration(
//                           prefixIcon: Icon(Icons.place),
//                           hintText: "?????????? ??????????????",
//                         ),
//                       ),
//                       SizedBox(
//                         height: 20.0,
//                       ),
//                       TextFormField(
//                         controller: _meetingDescriptionController,
//                         validator: (text) =>
//                             text.isEmpty ? "???????????????? ??????????????????????" : null,
//                         maxLines: 3,
//                         decoration: InputDecoration(
//                           hintText: "????????????????",
//                           contentPadding: EdgeInsets.all(8.0),
//                         ),
//                       ),
//                       SizedBox(
//                         height: 20,
//                       ),
//                       Text(DateFormat.yMMMMd("en_US").format(_selectedDate)),
//                       Text("${widget.hour} : ${widget.minute}"),
//                       Row(
//                         children: [
//                           Expanded(
//                             child: FlatButton(
//                               child: Text("???????????????? ????????"),
//                               onPressed: () => _selectDate(),
//                             ),
//                           ),
//                           Expanded(
//                             child: FlatButton(
//                               child: Text("???????????????? ??????????"),
//                               onPressed: () => _selectTime(),
//                             ),
//                           ),
//                         ],
//                       ),
//                       RaisedButton(
//                         color: Colors.orange,
//                         child: Padding(
//                           padding: EdgeInsets.symmetric(
//                               horizontal: 50, vertical: 10),
//                           child: Text(
//                             save,
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                               fontSize: 20.0,
//                             ),
//                           ),
//                         ),
//                         onPressed: () async {
//                           if (_meetingPlaceController.text == "") {
//                             addMeetingKey.currentState.showSnackBar(SnackBar(
//                               content: Text("?????????????????? ???????????????? ?????????? ??????????????"),
//                             ));
//                           } else if (_meetingDescriptionController.text == "") {
//                             addMeetingKey.currentState.showSnackBar(SnackBar(
//                               content:
//                                   Text("?????????????????? ???????????????? ???????????????? ??????????????"),
//                             ));
//                           }
//                           if (_meetingPlaceController.text != "" &&
//                               _meetingPlaceController.text != null &&
//                               widget.description != null) {
//                             setState(() {
//                               save = "Valid";
//                             });
//                           }
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           )),
//     );
//   }
// }

// void main() {
//   testWidgets('Test name', (WidgetTester tester) async {
//     await tester.pumpWidget(MeetingWidget(
//       name: "???????????????????????? ????????????????",
//       description: "???????????????? ?????????? ?? ????????????",
//       hour: "20",
//       minute: "21",
//     ));
//     final reviewFinder = find.text("???????????????????????? ????????????????");
//     expect(reviewFinder, findsOneWidget);
//     await tester.enterText(reviewFinder, '????????????');
//     expect(find.text("???????????????????????? ????????????????"), findsNothing);
//     expect(find.text('????????????'), findsOneWidget);
//   });

//   testWidgets('Test description', (WidgetTester tester) async {
//     await tester.pumpWidget(MeetingWidget(
//       name: "???????????????????????? ????????????????",
//       description: "???????????????? ?????????? ?? ????????????",
//       hour: "20",
//       minute: "21",
//     ));
//     final reviewFinder = find.text("???????????????? ?????????? ?? ????????????");
//     expect(reviewFinder, findsOneWidget);
//     await tester.enterText(reviewFinder, '??????????????, ?????? ?????????????? ??????!');
//     expect(find.text("???????????????? ?????????? ?? ????????????"), findsNothing);
//     expect(find.text('??????????????, ?????? ?????????????? ??????!'), findsOneWidget);
//   });

//   testWidgets('Test time', (WidgetTester tester) async {
//     await tester.pumpWidget(MeetingWidget(
//       name: "???????????????????????? ????????????????",
//       description: "???????????????? ?????????? ?? ????????????",
//       hour: "20",
//       minute: "21",
//     ));
//     var timeFinder = find.text("20 : 21");
//     expect(timeFinder, findsOneWidget);
//   });

//   testWidgets('Form validate true', (WidgetTester tester) async {
//     await tester.pumpWidget(MeetingWidget(
//       name: "???????????????????????? ????????????????",
//       description: "???????????????? ?????????? ?? ????????????",
//       hour: "20",
//       minute: "21",
//     ));
//     var currentButton = find.text("Invalid");
//     expect(currentButton, findsOneWidget);
//     final placeFinder = find.text("???????????????????????? ????????????????");
//     expect(placeFinder, findsOneWidget);
//     await tester.tap(currentButton);
//     await tester.pump();
//     expect(find.text("Valid"), findsOneWidget);
//   });

//   testWidgets('Form validate false', (WidgetTester tester) async {
//     await tester.pumpWidget(MeetingWidget(
//       name: "",
//       description: "???????????????? ?????????? ?? ????????????",
//       hour: "20",
//       minute: "21",
//     ));
//     var currentButton = find.text("Invalid");
//     expect(currentButton, findsOneWidget);
//     await tester.tap(currentButton);
//     await tester.pump();
//     expect(find.text("Valid"), findsNothing);
//     var placeFinder = find.byKey(textKey);
//     await tester.enterText(placeFinder, "???????????????????????? ????????????????");
//     expect(find.text("???????????????????????? ????????????????"), findsOneWidget);
//     await tester.tap(currentButton);
//     await tester.pump();
//     expect(find.text("Valid"), findsOneWidget);
//   });
// }
