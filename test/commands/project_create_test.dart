@Timeout(Duration(seconds: 600))

import 'dart:io';

import 'package:dshell/dshell.dart' hide equals;
import 'package:dshell/src/script/entry_point.dart';
import 'package:test/test.dart';

import 'package:path/path.dart' as p;

import '../util/test_file_system.dart';

void main() {
  TestFileSystem();

  var scriptPath = truepath(TestFileSystem().testScriptPath, 'create_test');

  if (!exists(scriptPath)) {
    createDir(scriptPath, recursive: true);
  }
  var script = truepath(scriptPath, 'hello_world.dart');

  group('Create Project', () {
    test('Create hello world', () {
      TestFileSystem().withinZone((fs) {
        var paths = TestFileSystem();
        EntryPoint().process(['create', '--foreground', script]);

        checkProjectStructure(paths, script);
      });
    });

    test('Clean hello world', () {
      TestFileSystem().withinZone((fs) {
        var paths = TestFileSystem();
        EntryPoint().process(['clean', script]);

        checkProjectStructure(paths, script);
      });
    });

    test('Run hello world', () {
      TestFileSystem().withinZone((fs) {
        EntryPoint().process([script]);
      });
    });

    test('With Lib', () {});
  });
}

void checkProjectStructure(TestFileSystem paths, String scriptName) {
  expect(exists(paths.runtimePath(scriptName)), equals(true));

  var pubspecPath = p.join(paths.runtimePath(scriptName), 'pubspec.yaml');
  expect(exists(pubspecPath), equals(true));

  var libPath = p.join(paths.runtimePath(scriptName), 'lib');
  expect(exists(libPath), equals(true));

  // There should be three files/directories in the project.
  // script link
  // lib or lib link
  // pubspec.lock
  // pubspec.yaml
  // .packages

  var files = <String>[];
  find('*.*', recursive: false, root: paths.runtimePath(scriptName), types: [
    FileSystemEntityType.file,
  ]).forEach((line) => files.add(p.basename(line)));
  expect(
      files,
      unorderedEquals((<String>[
        'hello_world.dart',
        'pubspec.yaml',
        'pubspec.lock',
        '.packages',
        '.build.complete'
      ])));

  var directories = <String>[];

  find('*',
          recursive: false,
          root: paths.runtimePath(scriptName),
          types: [FileSystemEntityType.directory])
      .forEach((line) => directories.add(p.basename(line)));
  expect(directories, unorderedEquals(<String>['lib', '.dart_tool']));
}
