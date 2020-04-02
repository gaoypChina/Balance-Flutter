
/// Base State of the result page
abstract class ResultState {
  const ResultState();
}

/// State for when the data is loading
class ResultLoading extends ResultState {}

/// State for when the data is retrieved successfully
class ResultSuccess extends ResultState {
  const ResultSuccess();
}

/// State for when there is an error
class ResultError extends ResultState {
  final Error error;
  const ResultError(this.error);
}