import 'package:coworking/domain/entities/category.dart';
import 'package:coworking/domain/entities/pin.dart';
import 'package:coworking/domain/services/database_pin.dart';
import 'package:coworking/screens/map/pin/review/review_form.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PinScreenModel extends ChangeNotifier {
  Pin pin;
  PinScreenModel({required this.pin}) {
    _asyncInit();
  }

  var visitedText = "";
  var visitedColor = Colors.orange;
  GlobalKey<ReviewFormState> reviewFormKey = GlobalKey<ReviewFormState>();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  GlobalKey<FormFieldState> imagePickerKey = GlobalKey<FormFieldState>();
  GlobalKey<FormFieldState> categoryPickerKey = GlobalKey<FormFieldState>();
  TextEditingController nameController = TextEditingController();
  List<double> threeMonthStats = [0, 0, 0, 0, 0];

//TODO расширить
  Future _asyncInit() async {
    nameController.text = pin.name;
  }

  Future<bool> savePin() async {
    try {
      var newImage = imagePickerKey.currentState!.value;
      var timeKey = DateTime.now();

      final Reference postImageRef =
          FirebaseStorage.instance.ref().child("Pin Images");
      final UploadTask uploadTask =
          postImageRef.child(timeKey.toString() + ".jpg").putFile(newImage);
      String stringUrl = await (await uploadTask).ref.getDownloadURL();

      Category category = categoryPickerKey.currentState!.value;
      if (formKey.currentState!.validate() &&
          nameController.text != "" &&
          category.text != "" &&
          stringUrl.isNotEmpty) {
        await FirebaseStorage.instance.refFromURL(pin.imageUrl).delete();
        pin.imageUrl = stringUrl;
        pin.name = nameController.text;
        pin.category.text = category.text;
        await DatabasePin().editPin(pin);
        notifyListeners();
        return false;
      }
    } catch (e) {
      notifyListeners();
      return true;
    }
    notifyListeners();
    return true;
  }

  void setFavourite() {
    visitedText = "Добавить в избранное";
    visitedColor = Colors.grey;
    DatabasePin.addFavourite(pin.id);
    notifyListeners();
  }

  void setUnfavourite() {
    visitedText = "В избранном";
    visitedColor = Colors.yellow;
    DatabasePin.removeFavourite(pin.id);
    notifyListeners();
  }
}
