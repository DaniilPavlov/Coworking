import 'package:flutter/material.dart';
import 'package:coworking/models/option.dart';

class RadioButtonPicker extends FormField<Option> {
  final List<Option>? options;

  RadioButtonPicker(
      {Key? key, this.options, String? Function(Option?)? validator})
      : super(
          key: key,
          validator: validator,
          builder: (state) => Column(children: <Widget>[
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8.0,
              children: List.generate(options!.length, (i) {
                Option option = options[i];
                bool selected = state.value == option;
                return ChoiceChip(
                  label: Text(option.text),
                  labelStyle: const TextStyle(
                    // color: selected ? Colors.white : Colors.black,
                     color: Colors.white,
                  ),
                  onSelected: (selected) => state.didChange(option),
                  selected: selected,
                  selectedColor: option.colour,
                  backgroundColor: option.colour.withOpacity(0.2),
                );
              }),
            ),
            state.hasError
                ? Text(
                    state.errorText!,
                    style: TextStyle(
                      color: Theme.of(state.context).errorColor,
                      fontSize:
                          Theme.of(state.context).textTheme.caption?.fontSize,
                    ),
                  )
                : Container(),
          ]),
        );
}
