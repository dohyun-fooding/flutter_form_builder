import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class FormBuilderField<T> extends FormField<T> {
  /// Used to reference the field within the form, or to reference form data
  /// after the form is submitted.
  final String name;

  /// Called just before field value is saved. Used to massage data just before
  /// committing the value.
  ///
  /// This sample shows how to convert age in a [FormBuilderTextField] to number
  /// so that the final value is numeric instead of a String
  ///
  /// ```dart
  ///   FormBuilderTextField(
  ///     name: 'age',
  ///     decoration: InputDecoration(labelText: 'Age'),
  ///     valueTransformer: (text) => num.tryParse(text),
  ///     validator: FormBuilderValidators.numeric(context),
  ///     initialValue: '18',
  ///     keyboardType: TextInputType.number,
  ///  ),
  /// ```
  final ValueTransformer valueTransformer;

  /// Called when the field value is changed.
  final ValueChanged<T> onChanged;

  /// Whether the field value can be changed. Defaults to false
  final bool readOnly;

  /// The border, labels, icons, and styles used to decorate the field.
  final InputDecoration decoration;

  /// Called when the field value is reset.
  final VoidCallback onReset;

  /// {@macro flutter.widgets.Focus.focusNode}
  final FocusNode focusNode;

  //TODO: implement bool autofocus, ValueChanged<bool> onValidated

  FormBuilderField({
    Key key,
    //From Super
    FormFieldSetter<T> onSaved,
    T initialValue,
    bool autovalidate = false,
    bool enabled = true,
    FormFieldValidator validator,
    @required FormFieldBuilder<T> builder,
    @required this.name,
    this.valueTransformer,
    this.onChanged,
    this.readOnly = false,
    this.decoration = const InputDecoration(),
    this.onReset,
    this.focusNode,
  }) : super(
          key: key,
          onSaved: onSaved,
          initialValue: initialValue,
          autovalidate: autovalidate,
          enabled: enabled,
          builder: builder,
          validator: validator,
        );

  @override
  FormBuilderFieldState<T> createState() => FormBuilderFieldState();
}

class FormBuilderFieldState<T> extends FormFieldState<T> {
  @override
  FormBuilderField<T> get widget => super.widget;

  FormBuilderState get formState => _formBuilderState;

  bool get readOnly => _readOnly;

  bool get pristine => !_dirty;

  bool get dirty => !_dirty;

  // Only autovalidate if dirty
  bool get autovalidate => dirty && widget.autovalidate;

  T get initialValue => _initialValue;

  FormBuilderState _formBuilderState;

  bool _readOnly = false;

  bool _dirty = false;

  T _initialValue;

  FocusNode _focusNode;

  FocusNode get _effectiveFocusNode =>
      widget.focusNode ??
      (_focusNode ??= FocusNode(debugLabel: '${widget.name}'));

  @override
  void initState() {
    super.initState();
    _formBuilderState = FormBuilder.of(context);
    _readOnly = _formBuilderState?.readOnly == true || widget.readOnly;
    _formBuilderState?.registerField(widget.name, this);
    _initialValue = widget.initialValue ??
        ((_formBuilderState?.initialValue?.containsKey(widget.name) ??
                false)
            ? _formBuilderState.initialValue[widget.name]
            : null);
    setValue(_initialValue);
  }

  @override
  void save() {
    super.save();
    _formBuilderState?.setInternalFieldValue(
        widget.name, widget.valueTransformer?.call(value) ?? value);
  }

  @override
  void didChange(T val) {
    setState(() {
      _dirty = true;
    });
    super.didChange(val);
    widget.onChanged?.call(value);
  }

  @override
  void reset() {
    super.reset();
    setValue(initialValue);
    widget.onReset?.call();
  }

  @override
  bool validate() {
    return super.validate() && widget.decoration?.errorText == null;
  }

  void requestFocus() {
    FocusScope.of(context).requestFocus(_effectiveFocusNode);
  }

  @override
  void dispose() {
    _formBuilderState?.unregisterField(widget.name);
    // The attachment will automatically be detached in dispose().
    _focusNode?.dispose();
    super.dispose();
  }

  void patchValue(T value){
    didChange(value);
  }
}