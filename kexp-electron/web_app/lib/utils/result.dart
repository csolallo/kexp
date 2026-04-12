sealed class Result<T> {
    const Result();

    factory Result.ok(T result) => Ok(result);

    factory Result.err(Exception error) => Err(error);
}

class Ok<T> extends Result<T> {
  final T _t;

  const Ok(T value) : _t = value;

  T get value => _t;   
}

class Err<T> extends Result<T> {
  final Exception _error;

  const Err(Exception error) : _error = error;

  Exception get error => _error;
}
