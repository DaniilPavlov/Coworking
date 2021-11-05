// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';

// class ReviewWidget extends StatefulWidget {
//   bool isFood;
//   bool isFree;
//   bool isRazors;
//   bool isWiFi;
//   String review;
//   String rate;

//   ReviewWidget({
//     Key key,
//     @required this.isFood,
//     @required this.isFree,
//     @required this.isRazors,
//     @required this.isWiFi,
//     @required this.review,
//     @required this.rate,
//   }) : super(key: key);

//   State<ReviewWidget> createState() => ReviewWidgetState();
// }

// Key RateKey = new UniqueKey();
// Key ReviewKey = new UniqueKey();
// Key isFoodKey = new UniqueKey();
// Key isFreeKey = new UniqueKey();
// Key isRazorsKey = new UniqueKey();
// Key isWiFiKey = new UniqueKey();
// Key iconButton = new UniqueKey();

// class ReviewWidgetState extends State<ReviewWidget> {
//   GlobalKey<FormState> formKey = GlobalKey();

//   TextEditingController reviewController;
//   TextEditingController rateController =
//       TextEditingController(text: "Your initial value");
//   var save = Icons.crop_square_sharp;

//   @override
//   void initState() {
//     super.initState();
//     rateController.text = widget.rate;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Review Widget',
//       home: Scaffold(
//           appBar: AppBar(actions: <Widget>[
//             IconButton(
//               key: iconButton,
//               icon: Icon(save),
//               onPressed: () async {
//                 if (formKey.currentState.validate()) {
//                   setState(() {
//                     save = Icons.check;
//                   });
//                 }
//               },
//             )
//           ]),
//           body: Form(
//               key: formKey,
//               child: SingleChildScrollView(
//                 child: Column(children: <Widget>[
//                   TextFormField(
//                     key: ReviewKey,
//                     initialValue: widget.review,
//                     controller: reviewController,
//                     validator: (text) =>
//                         text.isEmpty ? "Отзыв обязателен" : null,
//                     maxLines: 3,
//                     decoration: InputDecoration(
//                       hintText: "Отзыв",
//                       contentPadding: EdgeInsets.all(10.0),
//                     ),
//                   ),
//                   Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Column(children: <Widget>[
//                         Text(
//                           "Раздел оценки места",
//                           style: Theme.of(context).textTheme.subtitle1,
//                           textAlign: TextAlign.left,
//                         ),
//                         GridView.count(
//                           childAspectRatio: 5,
//                           crossAxisCount: 2,
//                           shrinkWrap: true,
//                           children: <Widget>[
//                             Container(
//                               alignment: Alignment.centerLeft,
//                               child: Text("Можно приобрести еду"),
//                             ),
//                             Container(
//                               alignment: Alignment.center,
//                               child: Checkbox(
//                                 key: isFoodKey,
//                                 value: widget.isFood,
//                                 onChanged: (value) {
//                                   setState(() {
//                                     widget.isFood = value;
//                                   });
//                                 },
//                                 tristate: false,
//                               ),
//                             ),
//                             Container(
//                               alignment: Alignment.centerLeft,
//                               child: Text("Можно находиться бесплатно"),
//                             ),
//                             Container(
//                               alignment: Alignment.center,
//                               child: Checkbox(
//                                 key: isFreeKey,
//                                 value: widget.isFree,
//                                 onChanged: (value) {
//                                   setState(() {
//                                     widget.isFree = value;
//                                   });
//                                 },
//                                 tristate: false,
//                               ),
//                             ),
//                             Container(
//                               alignment: Alignment.centerLeft,
//                               child: Text("Есть розетки"),
//                             ),
//                             Container(
//                               alignment: Alignment.center,
//                               child: Checkbox(
//                                 key: isRazorsKey,
//                                 value: widget.isRazors,
//                                 onChanged: (value) {
//                                   setState(() {
//                                     widget.isRazors = value;
//                                   });
//                                 },
//                                 tristate: false,
//                               ),
//                             ),
//                             Container(
//                               alignment: Alignment.centerLeft,
//                               child: Text("Есть WiFi"),
//                             ),
//                             Container(
//                               alignment: Alignment.center,
//                               child: Checkbox(
//                                 key: isWiFiKey,
//                                 value: widget.isWiFi,
//                                 onChanged: (value) {
//                                   setState(() {
//                                     widget.isWiFi = value;
//                                   });
//                                 },
//                                 tristate: false,
//                               ),
//                             ),
//                             Container(
//                               alignment: Alignment.centerLeft,
//                               child: Text(
//                                   "Ваша личная оценка места (введите число от 0 до 10)"),
//                             ),
//                             Container(
//                               alignment: Alignment.center,
//                               child: TextFormField(
//                                 textAlign: TextAlign.center,
//                                 controller: rateController,
//                                 validator: (input) {
//                                   final RegExp shutterSpeedRegEx = RegExp(
//                                       "[0-9]([0-9]*)((\\.[0-9][0-9]*)|\$)");
//                                   if (input.length == 0)
//                                     return "Вы не ввели оценку";
//                                   else if (!shutterSpeedRegEx.hasMatch(input))
//                                     return "Введите число";
//                                   else if (double.parse(rateController.text) >
//                                           10 ||
//                                       double.parse(rateController.text) < 0)
//                                     return "От 0 до 10";
//                                   else
//                                     return null;
//                                 },
//                               ),
//                             ),
//                           ],
//                         ),
//                       ])),
//                 ]),
//               ))),
//     );
//   }
// }

// void main() {
//   testWidgets('Test review', (WidgetTester tester) async {
//     await tester.pumpWidget(ReviewWidget(
//       isFood: true,
//       isFree: false,
//       isRazors: false,
//       isWiFi: true,
//       rate: "7.6",
//       review: "Место класс!",
//     ));
//     final reviewFinder = find.text('Место класс!');
//     expect(reviewFinder, findsOneWidget);
//     await tester.enterText(reviewFinder, 'Передумал, отсутствуют розетки!');
//     expect(find.text('Место класс!'), findsNothing);
//     expect(find.text('Передумал, отсутствуют розетки!'), findsOneWidget);
//   });

//   testWidgets('Test rate', (WidgetTester tester) async {
//     await tester.pumpWidget(ReviewWidget(
//       isFood: true,
//       isFree: false,
//       isRazors: false,
//       isWiFi: true,
//       rate: "7.6",
//       review: "Место класс!",
//     ));
//     final rateFinder = find.text('7.6');
//     expect(rateFinder, findsOneWidget);
//     await tester.enterText(rateFinder, '10.0');
//     expect(find.text('7.6!'), findsNothing);
//     expect(find.text('10.0'), findsOneWidget);
//   });

//   testWidgets('Test checkBox', (WidgetTester tester) async {
//     await tester.pumpWidget(ReviewWidget(
//       isFood: true,
//       isFree: false,
//       isRazors: false,
//       isWiFi: true,
//       rate: "7.6",
//       review: "Место класс!",
//     ));
//     await tester.tap(find.byKey(isFreeKey));
//     await tester.pump();
//     Checkbox widgetFree = tester.widget(find.byKey(isFreeKey));
//     expect(widgetFree.value, equals(true));
//   });

//   testWidgets('Form validate true', (WidgetTester tester) async {
//     await tester.pumpWidget(ReviewWidget(
//       isFood: true,
//       isFree: false,
//       isRazors: false,
//       isWiFi: true,
//       rate: "7.6",
//       review: "Место класс!",
//     ));
//     var currentIcon = find.byIcon(Icons.crop_square_sharp);
//     expect(currentIcon, findsOneWidget);
//     await tester.tap(find.byKey(iconButton));
//     await tester.pump();
//     expect(find.byIcon(Icons.check), findsOneWidget);
//   });

//   testWidgets('Form validate false', (WidgetTester tester) async {
//     await tester.pumpWidget(ReviewWidget(
//       isFood: true,
//       isFree: false,
//       isRazors: false,
//       isWiFi: true,
//       rate: "hahahhahah",
//       review: "Место класс!",
//     ));
//     var currentIcon = find.byIcon(Icons.crop_square_sharp);
//     expect(currentIcon, findsOneWidget);
//     await tester.tap(find.byKey(iconButton));
//     await tester.pump();
//     expect(find.byIcon(Icons.check), findsNothing);
//     final rateFinder = find.text('hahahhahah');
//     expect(rateFinder, findsOneWidget);
//     await tester.enterText(rateFinder, '10.0');
//     expect(find.text('10.0'), findsOneWidget);
//     await tester.tap(find.byKey(iconButton));
//     await tester.pump();
//     expect(find.byIcon(Icons.check), findsOneWidget);
//   });
// }
