import '../../dcli.dart';
import 'shell_mixin.dart';
import 'windows_mixin.dart';

/// Windows Power Shell
class PowerShell with WindowsMixin, ShellMixin {
  /// Name of the shell
  static const String shellName = 'powershell.exe';

  @override
  final int pid;
  PowerShell.withPid(this.pid);

  @override
  bool addToPATH(String path) {
    /// These need to be run as admin
    /// not working correctly at this point.
    /// Looks like powershell ignores the file association.
    'cmd /c assoc .dart=dcli'.run;
    r'''cmd /c ftype dcli=`"C:\Users\User\dcli`" `"%1`" `"%2`" `"%3`" `"%4`" `"%5`" `"%6`" `"%7`" `"%8`" `"%9`"'''
        .run;
    return true;
  }

  @override
  void installTabCompletion({bool quiet = false}) {
    // not supported.
  }

  @override
  bool get isPrivilegedUser {
    final currentPrincipal =
        'New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())'
            .firstLine;
    Settings().verbose('currentPrinciple: $currentPrincipal');
    final isPrivileged =
        '$currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)'
            .firstLine;
    Settings().verbose('isPrivileged: $isPrivileged');

    return isPrivileged.toLowerCase() == 'true';
  }

  @override
  bool get isPrivilegedProcess => isPrivilegedUser;

  @override
  bool get isCompletionInstalled => false;

  @override
  bool get isCompletionSupported => false;

  @override
  String get name => shellName;

  @override
  bool operator ==(covariant PowerShell other) {
    return name == other.name;
  }

  @override
  int get hashCode => name.hashCode;

  @override
  bool get hasStartScript => false;

  @override
  String get startScriptName => throw UnimplementedError;

  @override
  String get pathToStartScript => throw UnimplementedError;
}
