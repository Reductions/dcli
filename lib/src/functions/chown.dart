import 'dart:io';
import 'package:posix/posix.dart' as posix;

import '../../dcli.dart';
import '../util/dcli_exception.dart';
import '../util/stack_trace_impl.dart';

import 'dcli_function.dart';

/// Provides similar functionality to the posix chmod command.
///
/// Changes the user or group ownership of [path].
///
/// On Windows this command has no effect.
///
/// [path] is the path to the file or directory that we are changing the
/// ownership of. If [path] does not exists then a [ChOwnException] is thrown.
/// [path] may be absolute (preferred) or relative.
///
/// [user] is the posix user that will own the file/directory. If no [user] is specified
/// then the loggedin user is used.
///
/// [group] is the posix group that will own the file/directory. If no [group] is specified
/// then [user] is used as the group name.
///
/// If [recursive] is true (the default) then the change is applied to all subdirectories.
/// If you pass [recursive] and [path] is a file then [recursive] will be ignored.
///
void chown(String path, {String user, String group, bool recursive = true}) =>
    _ChOwn()._chown(path, user: user, group: group, recursive: recursive);

/// Implementatio for [chmod] function.
class _ChOwn extends DCliFunction {
// this.user, this.group, this.other, this.path

  void _chown(String path, {String user, String group, bool recursive = true}) {
    if (Platform.isWindows) return;

    user ??= Shell.current.loggedInUser;

    group ??= user;
    if (!exists(path)) {
      throw ChOwnException(
          'The file/directory at ${truepath(path)} does not exists');
    }

    final passwd = posix.getpwnam(user);
    final pgroup = posix.getgrnam(group);
    if (isDirectory(path) && recursive) {
      find('*', includeHidden: true, workingDirectory: path)
          .forEach((file) => posix.chown(path, passwd.uid, pgroup.gid));
    } else {
      posix.chown(path, passwd.uid, pgroup.gid);
    }
  }
}

/// Thrown if the [chown] function encounters an error.
class ChOwnException extends DCliFunctionException {
  /// Thrown if the [chown] function encounters an error.
  ChOwnException(String reason, [StackTraceImpl stacktrace])
      : super(reason, stacktrace);

  @override
  DCliException copyWith(StackTraceImpl stackTrace) {
    return ChOwnException(message, stackTrace);
  }
}
