import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerBox extends FormField<File> {
  const ImagePickerBox({super.key, super.validator})
      : super(
          builder: ImagePickerBoxState.new,
        );
}

class ImagePickerBoxState extends StatelessWidget {
  ImagePickerBoxState(this.state, {super.key});
  final FormFieldState<File> state;
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          padding: const EdgeInsets.all(4),
          child: OutlinedButton(
            clipBehavior: Clip.antiAlias,
            onPressed: () async {
              try {
                final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
                state.didChange(File(pickedFile!.path));
              } catch (e) {
                debugPrint(e.toString());
              }
            },
            child: state.value == null
                ? const Icon(
                    Icons.add_photo_alternate,
                    semanticLabel: 'Add image',
                  )
                : Image.file(
                    state.value!,
                    width: 100,
                    height: 100,
                    semanticLabel: 'Uploaded image',
                    fit: BoxFit.cover,
                  ),
          ),
        ),
        if (state.hasError) Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  state.errorText!,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
                  ),
                ),
              ) else Container(),
      ],
    );
  }
}
