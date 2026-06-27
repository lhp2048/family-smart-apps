// 将构建时刻写入 lib/core/constants/build_stamp.dart（格式 yy.Mdd.hhmm，见 REQ.txt）。
// 用法（在包根目录）：dart run tool/generate_build_stamp.dart
import 'dart:io';

void main() {
  final now = DateTime.now().toLocal();
  final yy = now.year % 100;
  final mdd = '${now.month}${now.day.toString().padLeft(2, '0')}';
  final hhmm =
      '${now.hour.toString().padLeft(2, '0')}'
      '${now.minute.toString().padLeft(2, '0')}';
  final stamp = '$yy.$mdd.$hhmm';

  final out = File('lib/core/constants/build_stamp.dart');
  out.writeAsStringSync(
    '// GENERATED — do not edit by hand.\n'
    '// Regenerate: dart run tool/generate_build_stamp.dart\n'
    '\n'
    "const String kAppBuildStamp = '$stamp';\n",
  );

  stdout.writeln('build_stamp: $stamp -> ${out.path}');
}
