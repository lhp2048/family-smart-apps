// 验证指定业务日的作业接口数据是否与 App 解析逻辑一致（成员码、完成状态等）。
//
// 用法（站点根 = 设置里填的地址，不含 /api/v1）：
//   dart run tool/verify_homework_biz_date.dart http://192.168.2.11:18024
//   dart run tool/verify_homework_biz_date.dart http://192.168.2.11:18024 2026-04-03
//
// 或用环境变量：
//   set FAMILY_API_ORIGIN=http://192.168.2.11:18024
//   set FAMILY_API_ACCESS_TOKEN=与 App 设置中访问API KEY 相同（必填）
//   dart run tool/verify_homework_biz_date.dart 2026-04-03
//
// 退出码：0 正常；1 请求/解析失败；2 发现成员码与 status 键不一致等告警（仍打印完整报告）。

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:family_smart_center/core/utils/api_base_url.dart';
import 'package:family_smart_center/features/dashboard/data/family_api_client.dart';
import 'package:family_smart_center/features/tasks/data/homework_items_bundle.dart';
import 'package:family_smart_center/features/tasks/data/models/task_item_entity.dart';
import 'package:family_smart_center/features/tasks/data/task_api_mappers.dart';
import 'package:family_smart_center/features/tasks/data/task_member_status.dart';

/// 与 [homeworkItemsBundleForDateAsyncProvider] 一致。
List<TaskItemEntity> _dedupeFlatHomeworkItems(List<TaskItemEntity> items) {
  final seen = <String>{};
  final out = <TaskItemEntity>[];
  for (final e in items) {
    late final String key;
    if (e.taskCode.isNotEmpty) {
      key = '${e.bizDate}|${e.taskCode}';
    } else if (e.bizDateGroupTaskKey.isNotEmpty) {
      key = e.bizDateGroupTaskKey;
    } else {
      out.add(e);
      continue;
    }
    if (seen.add(key)) out.add(e);
  }
  return out;
}

Future<HomeworkItemsBundle> _fetchHomeworkBundle(
  FamilyApiClient client,
  String bizDate,
) async {
  final groupMaps = await client.fetchTaskGroups(bizDate);
  var groups = groupMaps.map(taskGroupFromApiMap).toList();
  groups.sort((a, b) => a.sort.compareTo(b.sort));
  if (groups.isEmpty) {
    final flat = await client.fetchTaskItems(bizDate);
    return homeworkItemsBundleFromApiRawList(flat, bizDate);
  }
  final parts = <HomeworkItemsBundle>[];
  for (final g in groups) {
    final raw = await client.fetchTaskItems(bizDate, groupCode: g.groupCode);
    parts.add(homeworkItemsBundleFromApiRawList(raw, bizDate));
  }
  return HomeworkItemsBundle.mergeGroupFetches(parts, _dedupeFlatHomeworkItems);
}

Future<void> main(List<String> args) async {
  final envOrigin = Platform.environment['FAMILY_API_ORIGIN']?.trim();
  String bizDate = '2026-04-03';
  late final String resolvedOrigin;

  if (envOrigin != null && envOrigin.isNotEmpty) {
    resolvedOrigin = envOrigin;
    if (args.isNotEmpty) {
      final a0 = args.first.trim();
      if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(a0)) {
        bizDate = a0;
      }
    }
  } else {
    if (args.isEmpty) {
      stderr.writeln(
        '缺少站点根。示例：\n'
        '  dart run tool/verify_homework_biz_date.dart http://192.168.2.11:18024\n'
        '  dart run tool/verify_homework_biz_date.dart http://host:port 2026-04-03\n'
        '或设置环境变量 FAMILY_API_ORIGIN 后只传业务日。',
      );
      exit(64);
    }
    final a0 = args[0].trim();
    if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(a0)) {
      stderr.writeln('请先传入站点根 URL，或使用 FAMILY_API_ORIGIN。');
      exit(64);
    }
    resolvedOrigin = a0;
    if (args.length >= 2 &&
        RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(args[1].trim())) {
      bizDate = args[1].trim();
    }
  }

  final v1Base =
      familyOriginToApiV1Base(normalizeFamilyApiOrigin(resolvedOrigin));
  final envKey = Platform.environment['FAMILY_API_ACCESS_TOKEN']?.trim();
  if (envKey == null || envKey.isEmpty) {
    stderr.writeln(
      '请设置环境变量 FAMILY_API_ACCESS_TOKEN（与 App 设置中访问API KEY 一致）。',
    );
    exit(64);
  }
  final dio = FamilyApiClient.createDio(
    baseUrl: v1Base,
    accessToken: envKey,
  );
  final client = FamilyApiClient(dio);

  stderr.writeln('GET 基址: $v1Base');
  stderr.writeln('业务日: $bizDate\n');

  try {
    final membersRaw = await client.fetchMembers();
    final childCodes = <String>[];
    for (final m in membersRaw) {
      if ((m['role']?.toString() ?? '') != 'child') continue;
      final e = memberFromApiMap(m);
      if (e.memberCode.isNotEmpty) {
        childCodes.add(e.memberCode);
      }
    }
    childCodes.sort();

    stdout.writeln('=== 孩子 memberCode（来自 GET members, role=child）===');
    if (childCodes.isEmpty) {
      stdout.writeln('(无) — 作业页将显示「暂无孩子成员」');
    } else {
      for (final c in childCodes) {
        stdout.writeln('  - $c');
      }
    }
    stdout.writeln();

    final bundle = await _fetchHomeworkBundle(client, bizDate);
    final totalRows = bundle.flattenedMembersSorted().length;
    stdout.writeln(
      '=== 作业项（与 App 一致；按 groupCode 分块时组内按 taskName 排序；共 $totalRows 行）===',
    );
    if (!bundle.hasAnyItems) {
      stdout.writeln('(无数据) 请确认 task-dates / task-groups / task-items 有该日数据。');
    }

    var hasWarn = false;
    var globalIndex = 0;
    bundle.forEachMemberSection((section, items) {
      stdout.writeln(
        '\n>>> 分组: ${section == '*' ? "扁平(全员共用)" : section}（${items.length} 条）',
      );
      for (var i = 0; i < items.length; i++) {
        globalIndex++;
        final it = items[i];
        Map<String, dynamic> st = {};
        try {
          st = Map<String, dynamic>.from(
            jsonDecode(it.statusByMemberJson) as Map<dynamic, dynamic>,
          );
        } catch (_) {}

        final statusKeys = st.keys.toList()..sort();
        stdout.writeln('\n--- #$globalIndex ${it.name} ---');
        stdout.writeln('taskCode: ${it.taskCode}  groupCode: ${it.groupCode}');
        stdout.writeln(
            'statusByMemberJson 键: ${statusKeys.isEmpty ? "(空)" : statusKeys.join(", ")}');

        if (childCodes.isNotEmpty && statusKeys.isNotEmpty) {
          final noKey = <String>[];
          for (final c in childCodes) {
            if (!st.containsKey(c) &&
                !st.keys.any(
                    (k) => k.toString().toLowerCase() == c.toLowerCase())) {
              noKey.add(c);
            }
          }
          if (noKey.isNotEmpty && section != '*') {
            final relevant = noKey.where((c) => c != section).toList();
            if (relevant.isNotEmpty) {
              stdout.writeln(
                '⚠ 以下孩子 memberCode 在 status 中无对应键: ${relevant.join(", ")}',
              );
              hasWarn = true;
            }
          } else if (noKey.isNotEmpty && section == '*') {
            stdout.writeln(
              '⚠ 以下孩子 memberCode 在 status 中无对应键（将显示为未完成）: ${noKey.join(", ")}',
            );
            hasWarn = true;
          }
          for (final c in childCodes) {
            final done = memberTaskDoneForCode(st, c);
            stdout.writeln('  $c -> ${done ? "完成" : "未完成"}');
          }
        }
      }
    });

    stdout.writeln('\n=== 原始 JSON 样例（第一条，便于对照后台）===');
    if (bundle.hasAnyItems) {
      final rawList = await client.fetchTaskItems(bizDate);
      if (rawList.isNotEmpty) {
        stdout.writeln(
            const JsonEncoder.withIndent('  ').convert(rawList.first));
      } else {
        final groups = await client.fetchTaskGroups(bizDate);
        if (groups.isNotEmpty) {
          final gc = taskGroupFromApiMap(groups.first).groupCode;
          final perG = await client.fetchTaskItems(bizDate, groupCode: gc);
          if (perG.isNotEmpty) {
            stdout.writeln(const JsonEncoder.withIndent('  ').convert(perG.first));
          }
        }
      }
    }

    exit(hasWarn ? 2 : 0);
  } on FamilyApiException catch (e) {
    stderr.writeln('接口错误: $e');
    exit(1);
  } on DioException catch (e) {
    stderr.writeln('网络错误: ${e.message}');
    exit(1);
  } finally {
    dio.close();
  }
}
