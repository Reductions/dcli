import '../util/dcli_exception.dart';
import '../util/stack_trace_impl.dart';

/// Base class for the classes that implement
/// the public DCli functions.
class DCliFunction {}

/// Base class for all dcli function exceptions.
class DCliFunctionException extends DCliException {
  /// Base class for all dcli function exceptions.
  DCliFunctionException(String message, [StackTraceImpl stackTrace])
      : super(message, stackTrace);

  @override
  DCliException copyWith(StackTraceImpl stackTrace) {
    return DCliFunctionException(message, stackTrace);
  }
}
