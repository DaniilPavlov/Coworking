import 'package:flutter/material.dart';
import 'package:coworking/resources/option.dart';

class CheckBoxPicker extends FormField<Set<Option>> {
  final List<Option> options;

  CheckBoxPicker({Key key, this.options, validator, void Function(Set<Option>) onSaved})
      : super(
          key: key,
          validator: validator,
          initialValue: Set<Option>(),
          onSaved: onSaved,
          builder: (state) => Column(children: <Widget>[
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8.0,
              children: List.generate(options.length, (i) {
                Option option = options[i];
                bool selected = state.value.contains(option);

                return ChoiceChip(
                  label: Text(option.text),
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : Colors.black,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      state.value.add(option);
                    } else {
                      state.value.remove(option);
                    }
                    state.didChange(state.value);
                  },
                  selected: selected,
                  selectedColor: option.colour,
                  backgroundColor: option.colour.withOpacity(0.2),
                );
              }),
            ),
            state.hasError
                ? Text(
                    state.errorText,
                    style: TextStyle(
                      color: Theme.of(state.context).errorColor,
                      fontSize:
                          Theme.of(state.context).textTheme.caption.fontSize,
                    ),
                  )
                : Container(),
          ]),
        );
}
