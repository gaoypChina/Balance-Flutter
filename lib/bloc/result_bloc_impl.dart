
import 'package:balance_app/floor/measurement_database.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:balance_app/bloc/events/result_events.dart';
import 'package:balance_app/bloc/states/result_states.dart';
import 'package:balance_app/repository/result_repository.dart';

/// Class representing the Bloc for Result screen
///
/// This class is the core of the bloc pattern, it converts form
/// [ResultEvents] to [ResultState]s
class ResultBloc extends Bloc<ResultEvents, ResultState> {
  final ResultRepository _repository;

  ResultBloc._(MeasurementDatabase db): _repository = ResultRepository((db));

  /// Factory method for create an instance of [ResultBloc] given a
  /// [MeasurementDatabase] and a measurement id.
  factory ResultBloc.create(MeasurementDatabase db, int resultId) =>
    ResultBloc._(db)..add(FetchResult(resultId));

  @override
  ResultState get initialState => ResultLoading();

  @override
  Stream<ResultState> mapEventToState(ResultEvents event) async* {
    if (event is FetchResult) {
      // fetch the data from the repository
      try {
        yield ResultSuccess(await _repository.getResult(event.measurementId));
      } catch(e) {
        yield ResultError(e);
      }
    }
    else if (event is ExportResult) {
      // Export the measurement
      try {
        await _repository.exportMeasurement(event.measurementId);
        yield ResultExportSuccess();
      } catch(e) {
        yield ResultError(e);
      }
    }
  }
}