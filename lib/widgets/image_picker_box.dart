import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerBox extends FormField<File> {
  ImagePickerBox({Key key, validator})
      : super(
          key: key,
          builder: (state) => ImagePickerBoxState(state),
          validator: validator,
        );
}

class ImagePickerBoxState extends StatelessWidget {
  final FormFieldState<File> state;
  ImagePickerBoxState(this.state);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 100.0,
          height: 100.0,
          padding: EdgeInsets.all(4.0),
          child: OutlineButton(
            clipBehavior: Clip.antiAlias,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.0),
            ),
            onPressed: () {
              ImagePicker.pickImage(
                source: ImageSource.gallery,
              ).then((value) {
                state.didChange(value);
              });
            },
            child: state.value == null
                ? Icon(
                    Icons.add_photo_alternate,
                    semanticLabel: "Add image",
                  )
                : Image.file(
                    state.value,
                    width: 100.0,
                    height: 100.0,
                    semanticLabel: "Uploaded image",
                    fit: BoxFit.cover,
                  ),
          ),
        ),
        state.hasError
            ? Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  state.errorText,
                  style: TextStyle(
                    color: Theme.of(context).errorColor,
                    fontSize: Theme.of(context).textTheme.caption.fontSize,
                  ),
                ),
              )
            : Container(),
      ],
    );
  }
}
