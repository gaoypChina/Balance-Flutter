
import 'package:flutter/material.dart';
import 'package:circular_check_box/circular_check_box.dart';
import 'package:balance_app/res/colors.dart';

/// Widget that contains and manage a group of [CheckboxElement]s
/// 
/// This Widget instantiates a list of [CheckboxElement]s
/// based on the given [labels].
/// Every time an item is selected [onChanged] callback will be called
/// passing a list of length equal to [labels] where each item is either 
/// true or false if it's selected.
/// Passing a list of boolean as [selected] parameter to preselect some 
/// element when creating the group.
class CheckboxGroup extends StatefulWidget {
  /// List of [String]s labels
  final List<String> labels;
  /// List of selected items.
  final List<bool> selected;
  /// Callback called when an item is selected
  final ValueChanged<List<bool>> onChanged;

  CheckboxGroup({
    Key key,
    this.labels,
    this.selected,
    this.onChanged,
  }): super(key: key);

  @override
  State<StatefulWidget> createState() => _CheckboxGroupState();
}

class _CheckboxGroupState extends State<CheckboxGroup> {
  List<bool> _selectedItems;

  @override
  void initState() {
    super.initState();
    _selectedItems = widget.selected ?? List.filled(widget.labels.length, false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.labels.map((e) {
        final idx = widget.labels.indexOf(e);
        return CheckboxElement(
          label: e,
          isSelected: _selectedItems[idx],
          onItemSelected: (value) => setState(() {
            _selectedItems[idx] = value;
            widget.onChanged(_selectedItems);
          }),
        );
      }).toList()
    );
  }
}

/// A single checkbox element
class CheckboxElement extends StatelessWidget {
  final String label;
  final bool isSelected;
  final ValueChanged<bool> onItemSelected;

  CheckboxElement({
    Key key,
    this.label,
    this.isSelected: false,
    this.onItemSelected,
  }): assert(label != null),
    super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Material(
        borderRadius: BorderRadius.circular(9),
        color: isSelected? Color(0xFFF3F3FF): Colors.white,
        elevation: isSelected? 8: 4,
        child: InkWell(
          onTap: () {
            onItemSelected(!isSelected);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Row(
              children: <Widget>[
                CircularCheckBox(
                  activeColor: BColors.colorPrimary,
                  inactiveColor: Color(0xFFBFBFBF),
                  checkColor: Color(0xFFF3F3FF),
                  value: isSelected,
                  onChanged: (value) {
                    onItemSelected(value);
                  },
                ),
                Text(
                  label,
                  style: Theme.of(context).textTheme.subtitle2.copyWith(
                    color: isSelected? BColors.colorPrimary: Color(0xFFBFBFBF),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CheckboxGroupFormField extends FormField<List<bool>> {
  CheckboxGroupFormField({
    Key key,
    List<String> items,
    this.onChanged,
    List<bool> value,
    bool autovalidate: false,
    FormFieldValidator validator,
    FormFieldSetter onSaved,
  }): super(
    key: key,
    initialValue: value,
    validator: validator,
    onSaved: onSaved,
    autovalidate: autovalidate,
    builder: (state) {
      return CheckboxGroup(
        labels: items,
        selected: state.value,
        onChanged: onChanged == null? null: state.didChange,
      );
  });

  final ValueChanged<List<bool>> onChanged;

  @override
  FormFieldState<List<bool>> createState() => _CheckboxGroupFormFieldState();
}

class _CheckboxGroupFormFieldState extends FormFieldState<List<bool>> {
  @override
  CheckboxGroupFormField get widget => super.widget as CheckboxGroupFormField;

  @override
  void didChange(value) {
    super.didChange(value);
    assert(widget.onChanged != null);
    widget.onChanged(value);
  }
}

class PlainCheckboxFormField extends FormField<bool> {
  PlainCheckboxFormField({
    Key key,
    Text child,
    bool value,
    this.onChanged,
    FormFieldValidator<bool> validator,
    FormFieldSetter<bool> onSaved,
    bool autovalidate: false,
  }): super(
    key: key,
    initialValue: value,
    validator: validator,
    autovalidate: autovalidate,
    onSaved: onSaved,
    builder: (state) {
      return GestureDetector(
        onTap: () {
          if (onChanged != null)
            state.didChange(!state.value);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Flexible(
              child: child,
          ),
            CircularCheckBox(
              value: state.value,
              onChanged: onChanged == null? null: state.didChange,
              activeColor: Colors.white,
              inactiveColor: Colors.white,
              checkColor: Color(0xFFC95E4B),
            ),
          ],
        )
      );
    }
  );
  
  final ValueChanged<bool> onChanged;
  
  @override
  FormFieldState<bool> createState() => _PlainCheckboxFormFieldState();
}

class _PlainCheckboxFormFieldState extends FormFieldState<bool> {
  @override
  PlainCheckboxFormField get widget => super.widget as PlainCheckboxFormField;

  @override
  void didChange(value) {
    super.didChange(value);
    assert(widget.onChanged != null);
    widget.onChanged(value);
  }
}