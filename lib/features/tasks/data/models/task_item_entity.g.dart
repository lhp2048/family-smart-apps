// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_item_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTaskItemEntityCollection on Isar {
  IsarCollection<TaskItemEntity> get taskItemEntitys => this.collection();
}

const TaskItemEntitySchema = CollectionSchema(
  name: r'TaskItemEntity',
  id: 313837663814851483,
  properties: {
    r'bizDate': PropertySchema(
      id: 0,
      name: r'bizDate',
      type: IsarType.string,
    ),
    r'bizDateGroupTaskKey': PropertySchema(
      id: 1,
      name: r'bizDateGroupTaskKey',
      type: IsarType.string,
    ),
    r'completedAtByMemberJson': PropertySchema(
      id: 2,
      name: r'completedAtByMemberJson',
      type: IsarType.string,
    ),
    r'groupCode': PropertySchema(
      id: 3,
      name: r'groupCode',
      type: IsarType.string,
    ),
    r'name': PropertySchema(
      id: 4,
      name: r'name',
      type: IsarType.string,
    ),
    r'score': PropertySchema(
      id: 5,
      name: r'score',
      type: IsarType.long,
    ),
    r'sort': PropertySchema(
      id: 6,
      name: r'sort',
      type: IsarType.long,
    ),
    r'statusByMemberJson': PropertySchema(
      id: 7,
      name: r'statusByMemberJson',
      type: IsarType.string,
    ),
    r'taskCode': PropertySchema(
      id: 8,
      name: r'taskCode',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 9,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _taskItemEntityEstimateSize,
  serialize: _taskItemEntitySerialize,
  deserialize: _taskItemEntityDeserialize,
  deserializeProp: _taskItemEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'bizDateGroupTaskKey': IndexSchema(
      id: 3600090450667287622,
      name: r'bizDateGroupTaskKey',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'bizDateGroupTaskKey',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'bizDate': IndexSchema(
      id: 6295166300634180650,
      name: r'bizDate',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'bizDate',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'groupCode': IndexSchema(
      id: 5617245274874830724,
      name: r'groupCode',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'groupCode',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'sort': IndexSchema(
      id: 5566940169709045701,
      name: r'sort',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'sort',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _taskItemEntityGetId,
  getLinks: _taskItemEntityGetLinks,
  attach: _taskItemEntityAttach,
  version: '3.1.0+1',
);

int _taskItemEntityEstimateSize(
  TaskItemEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.bizDate.length * 3;
  bytesCount += 3 + object.bizDateGroupTaskKey.length * 3;
  bytesCount += 3 + object.completedAtByMemberJson.length * 3;
  bytesCount += 3 + object.groupCode.length * 3;
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.statusByMemberJson.length * 3;
  bytesCount += 3 + object.taskCode.length * 3;
  return bytesCount;
}

void _taskItemEntitySerialize(
  TaskItemEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.bizDate);
  writer.writeString(offsets[1], object.bizDateGroupTaskKey);
  writer.writeString(offsets[2], object.completedAtByMemberJson);
  writer.writeString(offsets[3], object.groupCode);
  writer.writeString(offsets[4], object.name);
  writer.writeLong(offsets[5], object.score);
  writer.writeLong(offsets[6], object.sort);
  writer.writeString(offsets[7], object.statusByMemberJson);
  writer.writeString(offsets[8], object.taskCode);
  writer.writeDateTime(offsets[9], object.updatedAt);
}

TaskItemEntity _taskItemEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TaskItemEntity();
  object.bizDate = reader.readString(offsets[0]);
  object.bizDateGroupTaskKey = reader.readString(offsets[1]);
  object.completedAtByMemberJson = reader.readString(offsets[2]);
  object.groupCode = reader.readString(offsets[3]);
  object.id = id;
  object.name = reader.readString(offsets[4]);
  object.score = reader.readLong(offsets[5]);
  object.sort = reader.readLong(offsets[6]);
  object.statusByMemberJson = reader.readString(offsets[7]);
  object.taskCode = reader.readString(offsets[8]);
  object.updatedAt = reader.readDateTime(offsets[9]);
  return object;
}

P _taskItemEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _taskItemEntityGetId(TaskItemEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _taskItemEntityGetLinks(TaskItemEntity object) {
  return [];
}

void _taskItemEntityAttach(
    IsarCollection<dynamic> col, Id id, TaskItemEntity object) {
  object.id = id;
}

extension TaskItemEntityByIndex on IsarCollection<TaskItemEntity> {
  Future<TaskItemEntity?> getByBizDateGroupTaskKey(String bizDateGroupTaskKey) {
    return getByIndex(r'bizDateGroupTaskKey', [bizDateGroupTaskKey]);
  }

  TaskItemEntity? getByBizDateGroupTaskKeySync(String bizDateGroupTaskKey) {
    return getByIndexSync(r'bizDateGroupTaskKey', [bizDateGroupTaskKey]);
  }

  Future<bool> deleteByBizDateGroupTaskKey(String bizDateGroupTaskKey) {
    return deleteByIndex(r'bizDateGroupTaskKey', [bizDateGroupTaskKey]);
  }

  bool deleteByBizDateGroupTaskKeySync(String bizDateGroupTaskKey) {
    return deleteByIndexSync(r'bizDateGroupTaskKey', [bizDateGroupTaskKey]);
  }

  Future<List<TaskItemEntity?>> getAllByBizDateGroupTaskKey(
      List<String> bizDateGroupTaskKeyValues) {
    final values = bizDateGroupTaskKeyValues.map((e) => [e]).toList();
    return getAllByIndex(r'bizDateGroupTaskKey', values);
  }

  List<TaskItemEntity?> getAllByBizDateGroupTaskKeySync(
      List<String> bizDateGroupTaskKeyValues) {
    final values = bizDateGroupTaskKeyValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'bizDateGroupTaskKey', values);
  }

  Future<int> deleteAllByBizDateGroupTaskKey(
      List<String> bizDateGroupTaskKeyValues) {
    final values = bizDateGroupTaskKeyValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'bizDateGroupTaskKey', values);
  }

  int deleteAllByBizDateGroupTaskKeySync(
      List<String> bizDateGroupTaskKeyValues) {
    final values = bizDateGroupTaskKeyValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'bizDateGroupTaskKey', values);
  }

  Future<Id> putByBizDateGroupTaskKey(TaskItemEntity object) {
    return putByIndex(r'bizDateGroupTaskKey', object);
  }

  Id putByBizDateGroupTaskKeySync(TaskItemEntity object,
      {bool saveLinks = true}) {
    return putByIndexSync(r'bizDateGroupTaskKey', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByBizDateGroupTaskKey(List<TaskItemEntity> objects) {
    return putAllByIndex(r'bizDateGroupTaskKey', objects);
  }

  List<Id> putAllByBizDateGroupTaskKeySync(List<TaskItemEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'bizDateGroupTaskKey', objects,
        saveLinks: saveLinks);
  }
}

extension TaskItemEntityQueryWhereSort
    on QueryBuilder<TaskItemEntity, TaskItemEntity, QWhere> {
  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterWhere> anySort() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'sort'),
      );
    });
  }
}

extension TaskItemEntityQueryWhere
    on QueryBuilder<TaskItemEntity, TaskItemEntity, QWhereClause> {
  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterWhereClause>
      bizDateGroupTaskKeyEqualTo(String bizDateGroupTaskKey) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'bizDateGroupTaskKey',
        value: [bizDateGroupTaskKey],
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterWhereClause>
      bizDateGroupTaskKeyNotEqualTo(String bizDateGroupTaskKey) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bizDateGroupTaskKey',
              lower: [],
              upper: [bizDateGroupTaskKey],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bizDateGroupTaskKey',
              lower: [bizDateGroupTaskKey],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bizDateGroupTaskKey',
              lower: [bizDateGroupTaskKey],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bizDateGroupTaskKey',
              lower: [],
              upper: [bizDateGroupTaskKey],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterWhereClause>
      bizDateEqualTo(String bizDate) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'bizDate',
        value: [bizDate],
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterWhereClause>
      bizDateNotEqualTo(String bizDate) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bizDate',
              lower: [],
              upper: [bizDate],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bizDate',
              lower: [bizDate],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bizDate',
              lower: [bizDate],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bizDate',
              lower: [],
              upper: [bizDate],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterWhereClause>
      groupCodeEqualTo(String groupCode) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'groupCode',
        value: [groupCode],
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterWhereClause>
      groupCodeNotEqualTo(String groupCode) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'groupCode',
              lower: [],
              upper: [groupCode],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'groupCode',
              lower: [groupCode],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'groupCode',
              lower: [groupCode],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'groupCode',
              lower: [],
              upper: [groupCode],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterWhereClause> sortEqualTo(
      int sort) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'sort',
        value: [sort],
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterWhereClause>
      sortNotEqualTo(int sort) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sort',
              lower: [],
              upper: [sort],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sort',
              lower: [sort],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sort',
              lower: [sort],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sort',
              lower: [],
              upper: [sort],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterWhereClause>
      sortGreaterThan(
    int sort, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'sort',
        lower: [sort],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterWhereClause> sortLessThan(
    int sort, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'sort',
        lower: [],
        upper: [sort],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterWhereClause> sortBetween(
    int lowerSort,
    int upperSort, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'sort',
        lower: [lowerSort],
        includeLower: includeLower,
        upper: [upperSort],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension TaskItemEntityQueryFilter
    on QueryBuilder<TaskItemEntity, TaskItemEntity, QFilterCondition> {
  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      bizDateEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bizDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      bizDateGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bizDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      bizDateLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bizDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      bizDateBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bizDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      bizDateStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'bizDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      bizDateEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'bizDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      bizDateContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'bizDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      bizDateMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'bizDate',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      bizDateIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bizDate',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      bizDateIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'bizDate',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      bizDateGroupTaskKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bizDateGroupTaskKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      bizDateGroupTaskKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bizDateGroupTaskKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      bizDateGroupTaskKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bizDateGroupTaskKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      bizDateGroupTaskKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bizDateGroupTaskKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      bizDateGroupTaskKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'bizDateGroupTaskKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      bizDateGroupTaskKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'bizDateGroupTaskKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      bizDateGroupTaskKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'bizDateGroupTaskKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      bizDateGroupTaskKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'bizDateGroupTaskKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      bizDateGroupTaskKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bizDateGroupTaskKey',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      bizDateGroupTaskKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'bizDateGroupTaskKey',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      completedAtByMemberJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'completedAtByMemberJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      completedAtByMemberJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'completedAtByMemberJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      completedAtByMemberJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'completedAtByMemberJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      completedAtByMemberJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'completedAtByMemberJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      completedAtByMemberJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'completedAtByMemberJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      completedAtByMemberJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'completedAtByMemberJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      completedAtByMemberJsonContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'completedAtByMemberJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      completedAtByMemberJsonMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'completedAtByMemberJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      completedAtByMemberJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'completedAtByMemberJson',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      completedAtByMemberJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'completedAtByMemberJson',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      groupCodeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'groupCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      groupCodeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'groupCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      groupCodeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'groupCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      groupCodeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'groupCode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      groupCodeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'groupCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      groupCodeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'groupCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      groupCodeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'groupCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      groupCodeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'groupCode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      groupCodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'groupCode',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      groupCodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'groupCode',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      scoreEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'score',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      scoreGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'score',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      scoreLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'score',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      scoreBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'score',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      sortEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sort',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      sortGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sort',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      sortLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sort',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      sortBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sort',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      statusByMemberJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'statusByMemberJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      statusByMemberJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'statusByMemberJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      statusByMemberJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'statusByMemberJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      statusByMemberJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'statusByMemberJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      statusByMemberJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'statusByMemberJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      statusByMemberJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'statusByMemberJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      statusByMemberJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'statusByMemberJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      statusByMemberJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'statusByMemberJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      statusByMemberJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'statusByMemberJson',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      statusByMemberJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'statusByMemberJson',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      taskCodeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'taskCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      taskCodeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'taskCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      taskCodeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'taskCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      taskCodeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'taskCode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      taskCodeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'taskCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      taskCodeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'taskCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      taskCodeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'taskCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      taskCodeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'taskCode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      taskCodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'taskCode',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      taskCodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'taskCode',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      updatedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      updatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterFilterCondition>
      updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension TaskItemEntityQueryObject
    on QueryBuilder<TaskItemEntity, TaskItemEntity, QFilterCondition> {}

extension TaskItemEntityQueryLinks
    on QueryBuilder<TaskItemEntity, TaskItemEntity, QFilterCondition> {}

extension TaskItemEntityQuerySortBy
    on QueryBuilder<TaskItemEntity, TaskItemEntity, QSortBy> {
  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterSortBy> sortByBizDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bizDate', Sort.asc);
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterSortBy>
      sortByBizDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bizDate', Sort.desc);
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterSortBy>
      sortByBizDateGroupTaskKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bizDateGroupTaskKey', Sort.asc);
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterSortBy>
      sortByBizDateGroupTaskKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bizDateGroupTaskKey', Sort.desc);
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterSortBy>
      sortByCompletedAtByMemberJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAtByMemberJson', Sort.asc);
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterSortBy>
      sortByCompletedAtByMemberJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAtByMemberJson', Sort.desc);
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterSortBy> sortByGroupCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupCode', Sort.asc);
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterSortBy>
      sortByGroupCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupCode', Sort.desc);
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterSortBy> sortByScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'score', Sort.asc);
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterSortBy> sortByScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'score', Sort.desc);
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterSortBy> sortBySort() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sort', Sort.asc);
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterSortBy> sortBySortDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sort', Sort.desc);
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterSortBy>
      sortByStatusByMemberJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'statusByMemberJson', Sort.asc);
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterSortBy>
      sortByStatusByMemberJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'statusByMemberJson', Sort.desc);
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterSortBy> sortByTaskCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskCode', Sort.asc);
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterSortBy>
      sortByTaskCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskCode', Sort.desc);
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension TaskItemEntityQuerySortThenBy
    on QueryBuilder<TaskItemEntity, TaskItemEntity, QSortThenBy> {
  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterSortBy> thenByBizDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bizDate', Sort.asc);
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterSortBy>
      thenByBizDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bizDate', Sort.desc);
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterSortBy>
      thenByBizDateGroupTaskKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bizDateGroupTaskKey', Sort.asc);
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterSortBy>
      thenByBizDateGroupTaskKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bizDateGroupTaskKey', Sort.desc);
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterSortBy>
      thenByCompletedAtByMemberJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAtByMemberJson', Sort.asc);
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterSortBy>
      thenByCompletedAtByMemberJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAtByMemberJson', Sort.desc);
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterSortBy> thenByGroupCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupCode', Sort.asc);
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterSortBy>
      thenByGroupCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupCode', Sort.desc);
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterSortBy> thenByScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'score', Sort.asc);
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterSortBy> thenByScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'score', Sort.desc);
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterSortBy> thenBySort() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sort', Sort.asc);
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterSortBy> thenBySortDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sort', Sort.desc);
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterSortBy>
      thenByStatusByMemberJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'statusByMemberJson', Sort.asc);
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterSortBy>
      thenByStatusByMemberJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'statusByMemberJson', Sort.desc);
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterSortBy> thenByTaskCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskCode', Sort.asc);
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterSortBy>
      thenByTaskCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskCode', Sort.desc);
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension TaskItemEntityQueryWhereDistinct
    on QueryBuilder<TaskItemEntity, TaskItemEntity, QDistinct> {
  QueryBuilder<TaskItemEntity, TaskItemEntity, QDistinct> distinctByBizDate(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bizDate', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QDistinct>
      distinctByBizDateGroupTaskKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bizDateGroupTaskKey',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QDistinct>
      distinctByCompletedAtByMemberJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'completedAtByMemberJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QDistinct> distinctByGroupCode(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'groupCode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QDistinct> distinctByScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'score');
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QDistinct> distinctBySort() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sort');
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QDistinct>
      distinctByStatusByMemberJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'statusByMemberJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QDistinct> distinctByTaskCode(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'taskCode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TaskItemEntity, TaskItemEntity, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension TaskItemEntityQueryProperty
    on QueryBuilder<TaskItemEntity, TaskItemEntity, QQueryProperty> {
  QueryBuilder<TaskItemEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<TaskItemEntity, String, QQueryOperations> bizDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bizDate');
    });
  }

  QueryBuilder<TaskItemEntity, String, QQueryOperations>
      bizDateGroupTaskKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bizDateGroupTaskKey');
    });
  }

  QueryBuilder<TaskItemEntity, String, QQueryOperations>
      completedAtByMemberJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'completedAtByMemberJson');
    });
  }

  QueryBuilder<TaskItemEntity, String, QQueryOperations> groupCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'groupCode');
    });
  }

  QueryBuilder<TaskItemEntity, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<TaskItemEntity, int, QQueryOperations> scoreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'score');
    });
  }

  QueryBuilder<TaskItemEntity, int, QQueryOperations> sortProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sort');
    });
  }

  QueryBuilder<TaskItemEntity, String, QQueryOperations>
      statusByMemberJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'statusByMemberJson');
    });
  }

  QueryBuilder<TaskItemEntity, String, QQueryOperations> taskCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'taskCode');
    });
  }

  QueryBuilder<TaskItemEntity, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
