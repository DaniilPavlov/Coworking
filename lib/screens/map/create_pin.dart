import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:coworking/models/account.dart';
import 'package:coworking/models/category.dart';
import 'package:coworking/services/database_map.dart';
import 'package:coworking/models/pin.dart';
import 'package:coworking/models/review.dart';
import 'package:coworking/screens/map/map.dart';
import 'package:coworking/screens/map/new_review_form.dart';
import 'package:coworking/widgets/image_picker_box.dart';
import 'package:coworking/widgets/radio_button_picker.dart';

class CreatePin extends StatefulWidget {
  final double drawerHeight;

  CreatePin(this.drawerHeight, {Key key}) : super(key: key);

  @override
  State<CreatePin> createState() => CreatePinState();
}

class CreatePinState extends State<CreatePin>
    with SingleTickerProviderStateMixin {
  TabController tabController;

  GlobalKey<_PinFormState> pinFormKey;
  GlobalKey<NewReviewFormState> reviewFormKey;

  PinForm pinForm;
  NewReviewForm reviewForm;

  bool validate() {
    if (!pinFormKey.currentState.isValid) {
      tabController.animateTo(0);
      return false;
    }

    if (reviewFormKey.currentState == null ||
        !reviewFormKey.currentState.isValid) {
      tabController.animateTo(1);
      tabController.addListener(() => reviewFormKey.currentState.isValid);
      return false;
    }

    return true;
  }

  Future<Pin> createPin() async {
    Review review = reviewFormKey.currentState.getReview();
    return pinFormKey.currentState.createPin(review);
  }

  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);

    pinFormKey = GlobalKey<_PinFormState>();
    reviewFormKey = GlobalKey<NewReviewFormState>();

    pinForm = PinForm(key: pinFormKey);
    reviewForm = NewReviewForm(key: reviewFormKey);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.drawerHeight,
      child: TabBarView(controller: tabController, children: [
        pinForm,
        reviewForm,
      ]),
    );
  }
}

class PinForm extends StatefulWidget {
  PinForm({Key key}) : super(key: key);

  @override
  _PinFormState createState() => _PinFormState();
}

class _PinFormState extends State<PinForm>
    with AutomaticKeepAliveClientMixin<PinForm> {
  GlobalKey<FormState> formKey;
  GlobalKey<FormFieldState> imagePickerKey;
  GlobalKey<FormFieldState> categoryPickerKey;
  TextEditingController nameController;

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
        TextFormField(
          controller: nameController,
          validator: (text) =>
              text.isEmpty ? "Необходимо название места" : null,
          decoration: InputDecoration(
            hintText: "Название места",
            contentPadding: EdgeInsets.all(8.0),
          ),
        ),
      ]),
    );
  }

  bool get isValid => formKey.currentState.validate();

  Future<Pin> createPin(Review review) async {
    File image = imagePickerKey.currentState.value;
    String name = nameController.text;

    Category category = categoryPickerKey.currentState.value;

    CameraPosition position =
        context.findAncestorStateOfType<MapPageState>().currentMapPosition;
    return DatabaseMap.newPin(
      position.target,
      name,
      review,
      Account.currentAccount,
      image,
      category,
      context,
    );
  }
}
