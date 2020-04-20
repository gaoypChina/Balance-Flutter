
import 'dart:async';
import 'package:quiver/async.dart';
import 'package:balance_app/floor/measurement_database.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:balance_app/repository/measure_countdown_repository.dart';
import 'package:balance_app/bloc/events/countdown_events.dart';
import 'package:balance_app/bloc/states/countdown_state.dart';
import 'package:balance_app/sensors/sensor_monitor.dart';

class CountdownBloc extends Bloc<CountdownEvents, CountdownState> {
  CountdownTimer _countdownTimer;
  bool _isCountdownCancelled;
  SensorMonitor _sensorMonitor;
  StreamSubscription<Duration> _monitorSub;
  MeasureCountdownRepository _repository;
  bool _eyesOpen;

  /// Setter for the [_eyesOpen] parameter
  void set eyesOpen(bool value) => _eyesOpen = value;

  /// Private constructor of [CountdownBloc]
  CountdownBloc._(MeasurementDatabase db):
    _repository = MeasureCountdownRepository(db),
    _isCountdownCancelled = false,
    _sensorMonitor = SensorMonitor(Duration(milliseconds: 8000));

  /// Factory method for creating an instance of [CountdownBloc]
  factory CountdownBloc.create(MeasurementDatabase db) => CountdownBloc._(db);

  @override
  CountdownState get initialState => CountdownIdleState();

  @override
  Stream<CountdownState> mapEventToState(CountdownEvents event) async* {
    switch (event) {
      // Start the pre measuring countdown
      case CountdownEvents.startPreMeasure:
        print("CountdownBloc.mapEventToState: startPreMeasure");
        _isCountdownCancelled = false;
        _countdownTimer = CountdownTimer(
          Duration(milliseconds: 6000),
          Duration(milliseconds: 1000)
        )..listen((event) { /*No-Op*/ },
            onDone: () {
              if (!_isCountdownCancelled)
                add(CountdownEvents.startMeasure);
            }
          );
        yield CountdownPreMeasureState();
        break;
      // Start the measuring
      case CountdownEvents.startMeasure:
        print("CountdownBloc.mapEventToState: startMeasure");
        _monitorSub = _sensorMonitor.sensorStream.listen((event) { /*No-op*/ },
          onDone: () {
            _monitorSub = null;
            add(CountdownEvents.measureComplete);
          }
        );
        yield CountdownMeasureState();
        break;
      // Stop the pre measuring countdown
      case CountdownEvents.stopPreMeasure:
        print("CountdownBloc.mapEventToState: stopPreMeasure");
        _isCountdownCancelled = true;
        _countdownTimer.cancel();
        _countdownTimer = null;
        yield CountdownIdleState();
        break;
      // Stop the measuring
      case CountdownEvents.stopMeasure:
        print("CountdownBloc.mapEventToState: stopMeasure");
        _monitorSub.cancel();
        _monitorSub = null;
        yield CountdownIdleState();
        break;
      // Save the new test into the database
      case CountdownEvents.measureComplete:
        // TODO: 18/04/20 return the entire Measurement and do some error handling
        try {
         final newId = await _repository.createNewMeasurement(_sensorMonitor.result, _eyesOpen);
         print("CountdownBloc.mapEventToState: Measurement $newId created with ${_sensorMonitor.result.length} raw data");
         yield CountdownCompleteState.success(newId);
        } catch(e) {
          print("$e");
          yield CountdownCompleteState.error(e);
        } finally {
        }
        break;
    }
  }

  @override
  Future<void> close() {
    print("Close bloc");
    // Stop the countdown timer
    _isCountdownCancelled = true;
    _countdownTimer?.cancel();
    _countdownTimer = null;
    // Stop the sensor monitor
    _monitorSub?.cancel();
    _monitorSub = null;
    return super.close();
  }
}