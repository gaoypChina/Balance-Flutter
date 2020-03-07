import 'package:balance_app/floor/measurement_database.dart';
import 'package:balance_app/model/measurement.dart';
import 'package:balance_app/widgets/measure_countdown.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Home();
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        MeasureCountdown(),
        SizedBox(height: 30),
        RaisedButton(
          onPressed: () async {
            int a = await Provider.of<MeasurementDatabase>(context, listen: false).measurementDao
              .insertMeasurement(Measurement.create(eyesOpen: true));
            print(a);
          },
          child: Text("Boh"),
        ),
      ]);
  }
}
