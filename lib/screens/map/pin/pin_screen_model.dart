import 'dart:io';

import 'package:coworking/domain/entities/category.dart';
import 'package:coworking/domain/entities/pin.dart';
import 'package:coworking/domain/entities/review.dart';
import 'package:coworking/domain/services/database_pin.dart';
import 'package:coworking/screens/map/pin/review/review_form.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PinScreenModel extends ChangeNotifier {
  PinScreenModel({required this.pin}) {
    _asyncInit();
  }
  Pin pin;

  String visitedText = '';
  MaterialColor visitedColor = Colors.orange;
  String newPhotoPath = '';
  GlobalKey<ReviewFormState> reviewFormKey = GlobalKey<ReviewFormState>();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  GlobalKey<FormFieldState> categoryPickerKey = GlobalKey<FormFieldState>();
  TextEditingController nameController = TextEditingController();
  List<double> threeMonthStats = [0, 0, 0, 0, 0];

// TODO(feature): add loading of photos and categories
  Future _asyncInit() async {
    nameController.text = pin.name;
  }

  Future<void> createReview(BuildContext context) async {
    if (reviewFormKey.currentState!.isValid) {
      final Review review = reviewFormKey.currentState!.getReview();
      pin..addReview(review)
      ..rating = await DatabasePin.updateRateOfPin(pin.id);
      notifyListeners();
      if (context.mounted) {
        Navigator.pop(context);
      }
    }
  }

  // TODO(fix): fix uploading of images into database when error happens
  Future<bool> savePin() async {
    try {
      final newImage = File(newPhotoPath);
      final timeKey = DateTime.now();
      final Reference postImageRef = FirebaseStorage.instance.ref().child('Pin Images');
      final UploadTask uploadTask = postImageRef.child('$timeKey.jpg').putFile(newImage);
      final String stringUrl = await (await uploadTask).ref.getDownloadURL();
      final Category category = categoryPickerKey.currentState!.value;
      if (formKey.currentState!.validate() &&
          nameController.text != '' &&
          category.text != '' &&
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

  Future<void> setNewPhoto() async {
    final ImagePicker picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      newPhotoPath = pickedFile!.path;
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void setFavourite() {
    visitedText = 'Добавить в избранное';
    visitedColor = Colors.grey;
    DatabasePin.addFavourite(pin.id);
    notifyListeners();
  }

  void setUnfavourite() {
    visitedText = 'В избранном';
    visitedColor = Colors.yellow;
    DatabasePin.removeFavourite(pin.id);
    notifyListeners();
  }
}
