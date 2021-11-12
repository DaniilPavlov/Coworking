import 'dart:io';

import 'package:coworking/models/account.dart';
import 'package:coworking/models/category.dart';
import 'package:coworking/models/pin.dart';
import 'package:coworking/models/review.dart';
import 'package:coworking/screens/map/map_screen.dart';
import 'package:coworking/services/database_pin.dart';
import 'package:coworking/widgets/image_picker_box.dart';
import 'package:coworking/widgets/radio_button_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PinForm extends StatefulWidget {
  const PinForm({Key? key}) : super(key: key);

  @override
  PinFormState createState() => PinFormState();
}

class PinFormState extends State<PinForm>
    with AutomaticKeepAliveClientMixin<PinForm> {
  late GlobalKey<FormState> formKey;
  late GlobalKey<FormFieldState> imagePickerKey;
  late GlobalKey<FormFieldState> categoryPickerKey;
  late TextEditingController nameController;

  @override
  void initState() {
    formKey = GlobalKey<FormState>();
    imagePickerKey = GlobalKey<FormFieldState>();
    categoryPickerKey = GlobalKey<FormFieldState>();

    nameController = TextEditingController();

    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Form(
      key: formKey,
      child: Column(children: <Widget>[
        ImagePickerBox(
          key: imagePickerKey,
          validator: (image) =>
              image == null ? "Необходима фотография места" : null,
        ),
        RadioButtonPicker(
          key: categoryPickerKey,
          validator: (option) =>
              option == null ? "Необходима категория места" : null,
          options: Category.all(),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 40.0, left: 20.0, right: 20.0),
          child: TextFormField(
            controller: nameController,
            validator: (text) =>
                text!.isEmpty ? "Необходимо название места" : null,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: "Название места",
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.all(8.0),
            ),
          ),
        ),
      ]),
    );
  }

  bool get isValid => formKey.currentState!.validate();

  Future<Pin> createPin(Review review) async {
    File image = imagePickerKey.currentState!.value;
    String name = nameController.text;

    Category category = categoryPickerKey.currentState!.value;

    CameraPosition position =
        context.findAncestorStateOfType<MapScreenState>()!.currentMapPosition;
    return DatabasePin.newPin(
      position.target,
      name,
      review,
      Account.currentAccount!,
      image,
      category,
      context,
    );
  }
}
