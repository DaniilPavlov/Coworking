// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:coworking/widgets/image_picker_box.dart';
// import 'package:coworking/widgets/radio_button_picker.dart';
// import 'package:coworking/models/category.dart';
// import 'dart:io';

// class PinWidget extends StatefulWidget {
//   String name;
//   File image;
//   Category category;

//   PinWidget({
//     Key key,
//     @required this.name,
//     @required this.image,
//     @required this.category,
//   }) : super(key: key);

//   State<PinWidget> createState() => PinWidgetState();
// }

// GlobalKey<FormFieldState> imagePickerKey = GlobalKey();
// GlobalKey<FormFieldState> categoryPickerKey = GlobalKey();
// GlobalKey<FormFieldState> textKey = GlobalKey();
// Key iconButton = new UniqueKey();

// class PinWidgetState extends State<PinWidget> {
//   GlobalKey<FormState> formKey = GlobalKey<FormState>();

//   TextEditingController nameController =
//       TextEditingController(text: "Your initial value");
//   var save = Icons.crop_square_sharp;

//   @override
//   void initState() {
//     super.initState();
//     nameController.text = widget.name;
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
//                 if (nameController.text != "" &&
//                     nameController.text != null &&
//                     widget.image != null &&
//                     widget.category != null) {
//                   setState(() {
//                     save = Icons.check;
//                   });
//                 }
//               },
//             )
//           ]),
//           body: Form(
//             key: formKey,
//             child: Column(children: <Widget>[
//               ImagePickerBox(
//                 key: imagePickerKey,
//                 validator: (image) =>
//                     image == null ? "Необходима фотография места" : null,
//               ),
//               RadioButtonPicker(
//                 key: categoryPickerKey,
//                 validator: (option) =>
//                     option == null ? "Необходима категория места" : null,
//                 options: Category.all(),
//               ),
//               TextFormField(
//                 key: textKey,
//                 controller: nameController,
//                 validator: (text) =>
//                     text.isEmpty ? "Необходимо название места" : null,
//                 decoration: InputDecoration(
//                   hintText: "Название места",
//                   contentPadding: EdgeInsets.all(8.0),
//                 ),
//               ),
//             ]),
//           )),
//     );
//   }
// }

// void main() {
//   testWidgets('Test name', (WidgetTester tester) async {
//     await tester.pumpWidget(PinWidget(
//       name: "Дворец",
//       image: File("xxxx"),
//       category: Category("Парк", Colors.green),
//     ));
//     final reviewFinder = find.text('Дворец');
//     expect(reviewFinder, findsOneWidget);
//     await tester.enterText(reviewFinder, 'Хижина');
//     expect(find.text('Дворец'), findsNothing);
//     expect(find.text('Хижина'), findsOneWidget);
//   });

//   testWidgets('Test category', (WidgetTester tester) async {
//     await tester.pumpWidget(PinWidget(
//       name: "Место",
//       image: File("xxxx"),
//       category: Category("Парк", Colors.green),
//     ));
//     var categoryFinder = find.widgetWithText(RadioButtonPicker, "Парк");
//     expect(categoryFinder, findsOneWidget);
//     await tester.tap(categoryFinder);
//     expect(categoryFinder.description.contains("Парк"), true);
//     categoryFinder = find.widgetWithText(RadioButtonPicker, "Коворкинг");
//     expect(categoryFinder, findsOneWidget);
//     await tester.tap(categoryFinder);
//     await tester.pump();
//     expect(categoryFinder.description.contains("Коворкинг"), true);
//   });

//   testWidgets('Test photo', (WidgetTester tester) async {
//     await tester.pumpWidget(PinWidget(
//       name: "Место",
//       image: File("xxxx"),
//       category: Category("Парк", Colors.green),
//     ));
//     var imageFinder = find.byKey(imagePickerKey);
//     expect(imageFinder, findsOneWidget);
//   });

//   testWidgets('Form validate true', (WidgetTester tester) async {
//     await tester.pumpWidget(PinWidget(
//       name: "Место",
//       image: File("xxxx"),
//       category: Category("Парк", Colors.green),
//     ));
//     var currentIcon = find.byIcon(Icons.crop_square_sharp);
//     expect(currentIcon, findsOneWidget);
//     await tester.tap(find.byKey(iconButton));
//     await tester.pump();
//     expect(find.byIcon(Icons.check), findsOneWidget);
//   });

//   testWidgets('Form validate false', (WidgetTester tester) async {
//     await tester.pumpWidget(PinWidget(
//       name: "",
//       image: File("xxxx"),
//       category: Category("Парк", Colors.green),
//     ));
//     var currentIcon = find.byIcon(Icons.crop_square_sharp);
//     expect(currentIcon, findsOneWidget);
//     await tester.tap(find.byKey(iconButton));
//     await tester.pump();
//     expect(find.byIcon(Icons.check), findsNothing);

//     final reviewFinder = find.byKey(textKey);
//     expect(reviewFinder, findsOneWidget);

//     await tester.enterText(reviewFinder, 'Хижина');
//     expect(find.text('Хижина'), findsOneWidget);

//     await tester.tap(find.byKey(iconButton));
//     await tester.pump();
//     expect(find.byIcon(Icons.check), findsOneWidget);
//   });
// }

// // expect(categoryFinder, findsNWidgets(2));
