
import 'package:balance_app/manager/user_info_manager.dart';
import 'package:balance_app/res/colors.dart';
import 'package:custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:balance_app/widgets/custom_number_form_field.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:balance_app/bloc/intro_bloc.dart';

class GeneralInfoScreen extends StatefulWidget {
  @override
  _GeneralInfoScreenState createState() => _GeneralInfoScreenState();
}

class _GeneralInfoScreenState extends State<GeneralInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  int _genderIndex;

  @override
  Widget build(BuildContext context) {
    return BlocListener<IntroBloc, IntroState>(
      condition: (_, current) =>  current is NeedToValidateState && current.index == 2,
      listener: (context, state) {
        final isValid = _formKey.currentState.validate();
        if (isValid) {
          _formKey.currentState.save();
          context.bloc<IntroBloc>().add(ValidationSuccessEvent());
        }
        print("_GeneralInfoScreenState.build: General info are ${isValid? "valid": "invalid"}");
      },
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          reverse: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: IconTheme(
                  data: IconThemeData(
                    size: 200,
                  ),
                  child: Icon(Icons.group),
                ),
              ),
              SizedBox(height: 40),
              Text(
                "Tell us more about you",
                style: Theme.of(context).textTheme.headline4.copyWith(
                  fontSize: 36,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      CustomNumberFormField(
                        labelText: "Age",
                        validator: (value) {
                          if (value.isNotEmpty) {
                            try {
                              int age = int.parse(value);
                              if (age <= 0)
                                return "Invalid Age!";
                              else if (age > 130)
                                return "You're too old!";
                            } on FormatException catch(_) {
                              return "Invalid Age!";
                            }
                          }
                          return null;
                        },
                        onSaved: (newValue) {
                          if (newValue.isNotEmpty)
                            try {
                              UserInfoManager.update(age: int.parse(newValue));
                            } on FormatException catch(e) {
                              print("Some error occurred saving age data: ${e.message}");
                            }
                        },
                      ),
                      SizedBox(height: 8),
                      CustomDropdownFormField(
                        hint: "Gender",
                        value: _genderIndex,
                        onChanged: (newValue) {
                          setState(() => _genderIndex = newValue);
                        },
                        items: [
                          CustomDropdownItem(text: "unknow"),
                          CustomDropdownItem(text: "male"),
                          CustomDropdownItem(text: "female"),
                        ],
                        openColor: Color(0xFFF4F6F9),
                        enabledColor: Colors.white,
                        enableTextColor: Color(0xFFBFBFBF),
                        elementTextColor: Color(0xFF666666),
                        enabledIconColor: BColors.colorPrimary,
                        validator: (_) => null,
                        onSaved: (newValue) => UserInfoManager.update(gender: newValue ?? 0),
                      ),
                      SizedBox(height: 8),
                      CustomNumberFormField(
                        labelText: "Weight",
                        decimal: true,
                        validator: (value) {
                          if (value.isNotEmpty) {
                            try {
                              double weight = double.parse(value);
                              if (weight <= 0)
                                return "Invalid Age!";
                              else if (weight > 130)
                                return "You're too old!";
                            } on FormatException catch(_) {
                              return "Invalid Age!";
                            }
                          }
                          return null;
                        },
                        onSaved: (newValue) {
                          if (newValue.isNotEmpty)
                            try {
                              UserInfoManager.update(weight: double.parse(newValue));
                            } on FormatException catch(e) {
                              print("Some error occurred saving weight data: ${e.message}");
                            }
                        },
                      ),
                      SizedBox(height: 70),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}