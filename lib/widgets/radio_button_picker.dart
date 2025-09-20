import 'package:flutter/material.dart';
import 'package:coworking/domain/entities/option.dart';

class RadioButtonPicker extends FormField<Option> {
  RadioButtonPicker({super.key, this.options, super.validator})
      : super(
          builder: (state) => Column(
            children: <Widget>[
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
                    backgroundColor: option.colour.withValues(alpha: 0.2),
                  );
                }),
              ),
              state.hasError
                  ? Text(
                      state.errorText!,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: Theme.of(state.context).textTheme.bodyMedium?.fontSize,
                      ),
                    )
                  : Container(),
            ],
          ),
        );
  final List<Option>? options;
}
