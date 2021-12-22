import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerBox extends FormField<File> {
  ImagePickerBox({Key? key, String? Function(File?)? validator})
      : super(
          key: key,
          builder: (state) => ImagePickerBoxState(state),
          validator: validator,
        );
}

class ImagePickerBoxState extends StatelessWidget {
  final FormFieldState<File> state;

  ImagePickerBoxState(this.state, {Key? key}) : super(key: key);
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 100.0,
          height: 100.0,
          padding: const EdgeInsets.all(4.0),
          child: OutlinedButton(
            clipBehavior: Clip.antiAlias,
            onPressed: () async {
              try {
                var pickedFile =
                    await _picker.pickImage(source: ImageSource.gallery);
                state.didChange(File(pickedFile!.path));
              } catch (e) {
                print(e);
              }
            },
            child: state.value == null
                ? const Icon(
                    Icons.add_photo_alternate,
                    semanticLabel: "Add image",
                  )
                : Image.file(
                    state.value!,
                    width: 100.0,
                    height: 100.0,
                    semanticLabel: "Uploaded image",
                    fit: BoxFit.cover,
                  ),
          ),
        ),
        state.hasError
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  state.errorText!,
                  style: TextStyle(
                    color: Theme.of(context).errorColor,
                    fontSize: Theme.of(context).textTheme.caption!.fontSize,
                  ),
                ),
              )
            : Container(),
      ],
    );
  }
}
