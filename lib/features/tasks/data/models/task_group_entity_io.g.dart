// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_group_entity_io.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTaskGroupEntityCollection on Isar {
  IsarCollection<TaskGroupEntity> get taskGroupEntitys => this.collection();
}

const TaskGroupEntitySchema = CollectionSchema(
  name: r'TaskGroupEntity',
  id: 8230248635486604661,
  properties: {
    r'bizDate': PropertySchema(
      id: 0,
      name: r'bizDate',
      type: IsarType.string,
    ),
    r'bizDateGroupKey': PropertySchema(
      id: 1,
      name: r'bizDateGroupKey',
      type: IsarType.string,
    ),
    r'groupCode': PropertySchema(
      id: 2,
      name: r'groupCode',
      type: IsarType.string,
    ),
    r'progress': PropertySchema(
      id: 3,
      name: r'progress',
      type: IsarType.double,
    ),
    r'sort': PropertySchema(
      id: 4,
      name: r'sort',
      type: IsarType.long,
    ),
    r'title': PropertySchema(
      id: 5,
      name: r'title',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 6,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _taskGroupEntityEstimateSize,
  serialize: _taskGroupEntitySerialize,
  deserialize: _taskGroupEntityDeserialize,
  deserializeProp: _taskGroupEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'bizDateGroupKey': IndexSchema(
      id: -3331184590442079762,
      name: r'bizDateGroupKey',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'bizDateGroupKey',
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
  getId: _taskGroupEntityGetId,
  getLinks: _taskGroupEntityGetLinks,
  attach: _taskGroupEntityAttach,
  version: '3.1.0+1',
);

int _taskGroupEntityEstimateSize(
  TaskGroupEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.bizDate.length * 3;
  bytesCount += 3 + object.bizDateGroupKey.length * 3;
  bytesCount += 3 + object.groupCode.length * 3;
  bytesCount += 3 + object.title.length * 3;
  return bytesCount;
}

void _taskGroupEntitySerialize(
  TaskGroupEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.bizDate);
  writer.writeString(offsets[1], object.bizDateGroupKey);
  writer.writeString(offsets[2], object.groupCode);
  writer.writeDouble(offsets[3], object.progress);
  writer.writeLong(offsets[4], object.sort);
  writer.writeString(offsets[5], object.title);
  writer.writeDateTime(offsets[6], object.updatedAt);
}

TaskGroupEntity _taskGroupEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TaskGroupEntity();
  object.bizDate = reader.readString(offsets[0]);
  object.bizDateGroupKey = reader.readString(offsets[1]);
  object.groupCode = reader.readString(offsets[2]);
  object.id = id;
  object.progress = reader.readDouble(offsets[3]);
  object.sort = reader.readLong(offsets[4]);
  object.title = reader.readString(offsets[5]);
  object.updatedAt = reader.readDateTime(offsets[6]);
  return object;
}

P _taskGroupEntityDeserializeProp<P>(
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
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _taskGroupEntityGetId(TaskGroupEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _taskGroupEntityGetLinks(TaskGroupEntity object) {
  return [];
}

void _taskGroupEntityAttach(
    IsarCollection<dynamic> col, Id id, TaskGroupEntity object) {
  object.id = id;
}

extension TaskGroupEntityByIndex on IsarCollection<TaskGroupEntity> {
  Future<TaskGroupEntity?> getByBizDateGroupKey(String bizDateGroupKey) {
    return getByIndex(r'bizDateGroupKey', [bizDateGroupKey]);
  }

  TaskGroupEntity? getByBizDateGroupKeySync(String bizDateGroupKey) {
    return getByIndexSync(r'bizDateGroupKey', [bizDateGroupKey]);
  }

  Future<bool> deleteByBizDateGroupKey(String bizDateGroupKey) {
    return deleteByIndex(r'bizDateGroupKey', [bizDateGroupKey]);
  }

  bool deleteByBizDateGroupKeySync(String bizDateGroupKey) {
    return deleteByIndexSync(r'bizDateGroupKey', [bizDateGroupKey]);
  }

  Future<List<TaskGroupEntity?>> getAllByBizDateGroupKey(
      List<String> bizDateGroupKeyValues) {
    final values = bizDateGroupKeyValues.map((e) => [e]).toList();
    return getAllByIndex(r'bizDateGroupKey', values);
  }

  List<TaskGroupEntity?> getAllByBizDateGroupKeySync(
      List<String> bizDateGroupKeyValues) {
    final values = bizDateGroupKeyValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'bizDateGroupKey', values);
  }

  Future<int> deleteAllByBizDateGroupKey(List<String> bizDateGroupKeyValues) {
    final values = bizDateGroupKeyValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'bizDateGroupKey', values);
  }

  int deleteAllByBizDateGroupKeySync(List<String> bizDateGroupKeyValues) {
    final values = bizDateGroupKeyValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'bizDateGroupKey', values);
  }

  Future<Id> putByBizDateGroupKey(TaskGroupEntity object) {
    return putByIndex(r'bizDateGroupKey', object);
  }

  Id putByBizDateGroupKeySync(TaskGroupEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'bizDateGroupKey', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByBizDateGroupKey(List<TaskGroupEntity> objects) {
    return putAllByIndex(r'bizDateGroupKey', objects);
  }

  List<Id> putAllByBizDateGroupKeySync(List<TaskGroupEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'bizDateGroupKey', objects, saveLinks: saveLinks);
  }
}

extension TaskGroupEntityQueryWhereSort
    on QueryBuilder<TaskGroupEntity, TaskGroupEntity, QWhere> {
  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterWhere> anySort() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'sort'),
      );
    });
  }
}

extension TaskGroupEntityQueryWhere
    on QueryBuilder<TaskGroupEntity, TaskGroupEntity, QWhereClause> {
  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterWhereClause>
      idNotEqualTo(Id id) {
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

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterWhereClause> idBetween(
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

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterWhereClause>
      bizDateGroupKeyEqualTo(String bizDateGroupKey) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'bizDateGroupKey',
        value: [bizDateGroupKey],
      ));
    });
  }

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterWhereClause>
      bizDateGroupKeyNotEqualTo(String bizDateGroupKey) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bizDateGroupKey',
              lower: [],
              upper: [bizDateGroupKey],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bizDateGroupKey',
              lower: [bizDateGroupKey],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bizDateGroupKey',
              lower: [bizDateGroupKey],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bizDateGroupKey',
              lower: [],
              upper: [bizDateGroupKey],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterWhereClause>
      bizDateEqualTo(String bizDate) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'bizDate',
        value: [bizDate],
      ));
    });
  }

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterWhereClause>
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

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterWhereClause> sortEqualTo(
      int sort) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'sort',
        value: [sort],
      ));
    });
  }

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterWhereClause>
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

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterWhereClause>
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

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterWhereClause>
      sortLessThan(
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

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterWhereClause> sortBetween(
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

extension TaskGroupEntityQueryFilter
    on QueryBuilder<TaskGroupEntity, TaskGroupEntity, QFilterCondition> {
  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterFilterCondition>
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

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterFilterCondition>
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

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterFilterCondition>
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

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterFilterCondition>
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

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterFilterCondition>
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

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterFilterCondition>
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

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterFilterCondition>
      bizDateContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'bizDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterFilterCondition>
      bizDateMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'bizDate',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterFilterCondition>
      bizDateIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bizDate',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterFilterCondition>
      bizDateIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'bizDate',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterFilterCondition>
      bizDateGroupKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bizDateGroupKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterFilterCondition>
      bizDateGroupKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bizDateGroupKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterFilterCondition>
      bizDateGroupKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bizDateGroupKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterFilterCondition>
      bizDateGroupKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bizDateGroupKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterFilterCondition>
      bizDateGroupKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'bizDateGroupKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterFilterCondition>
      bizDateGroupKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'bizDateGroupKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterFilterCondition>
      bizDateGroupKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'bizDateGroupKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterFilterCondition>
      bizDateGroupKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'bizDateGroupKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterFilterCondition>
      bizDateGroupKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bizDateGroupKey',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterFilterCondition>
      bizDateGroupKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'bizDateGroupKey',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterFilterCondition>
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

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterFilterCondition>
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

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterFilterCondition>
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

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterFilterCondition>
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

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterFilterCondition>
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

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterFilterCondition>
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

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterFilterCondition>
      groupCodeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'groupCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterFilterCondition>
      groupCodeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'groupCode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterFilterCondition>
      groupCodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'groupCode',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterFilterCondition>
      groupCodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'groupCode',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterFilterCondition>
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

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterFilterCondition>
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

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterFilterCondition>
      idBetween(
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

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterFilterCondition>
      progressEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'progress',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterFilterCondition>
      progressGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'progress',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterFilterCondition>
      progressLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'progress',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterFilterCondition>
      progressBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'progress',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterFilterCondition>
      sortEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sort',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterFilterCondition>
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

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterFilterCondition>
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

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterFilterCondition>
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

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterFilterCondition>
      titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterFilterCondition>
      titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterFilterCondition>
      titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterFilterCondition>
      titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterFilterCondition>
      titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterFilterCondition>
      titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterFilterCondition>
      titleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterFilterCondition>
      titleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterFilterCondition>
      titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterFilterCondition>
      titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterFilterCondition>
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

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterFilterCondition>
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

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterFilterCondition>
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

extension TaskGroupEntityQueryObject
    on QueryBuilder<TaskGroupEntity, TaskGroupEntity, QFilterCondition> {}

extension TaskGroupEntityQueryLinks
    on QueryBuilder<TaskGroupEntity, TaskGroupEntity, QFilterCondition> {}

extension TaskGroupEntityQuerySortBy
    on QueryBuilder<TaskGroupEntity, TaskGroupEntity, QSortBy> {
  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterSortBy> sortByBizDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bizDate', Sort.asc);
    });
  }

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterSortBy>
      sortByBizDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bizDate', Sort.desc);
    });
  }

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterSortBy>
      sortByBizDateGroupKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bizDateGroupKey', Sort.asc);
    });
  }

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterSortBy>
      sortByBizDateGroupKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bizDateGroupKey', Sort.desc);
    });
  }

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterSortBy>
      sortByGroupCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupCode', Sort.asc);
    });
  }

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterSortBy>
      sortByGroupCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupCode', Sort.desc);
    });
  }

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterSortBy>
      sortByProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progress', Sort.asc);
    });
  }

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterSortBy>
      sortByProgressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progress', Sort.desc);
    });
  }

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterSortBy> sortBySort() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sort', Sort.asc);
    });
  }

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterSortBy>
      sortBySortDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sort', Sort.desc);
    });
  }

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterSortBy>
      sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension TaskGroupEntityQuerySortThenBy
    on QueryBuilder<TaskGroupEntity, TaskGroupEntity, QSortThenBy> {
  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterSortBy> thenByBizDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bizDate', Sort.asc);
    });
  }

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterSortBy>
      thenByBizDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bizDate', Sort.desc);
    });
  }

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterSortBy>
      thenByBizDateGroupKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bizDateGroupKey', Sort.asc);
    });
  }

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterSortBy>
      thenByBizDateGroupKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bizDateGroupKey', Sort.desc);
    });
  }

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterSortBy>
      thenByGroupCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupCode', Sort.asc);
    });
  }

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterSortBy>
      thenByGroupCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupCode', Sort.desc);
    });
  }

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterSortBy>
      thenByProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progress', Sort.asc);
    });
  }

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterSortBy>
      thenByProgressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progress', Sort.desc);
    });
  }

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterSortBy> thenBySort() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sort', Sort.asc);
    });
  }

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterSortBy>
      thenBySortDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sort', Sort.desc);
    });
  }

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterSortBy>
      thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension TaskGroupEntityQueryWhereDistinct
    on QueryBuilder<TaskGroupEntity, TaskGroupEntity, QDistinct> {
  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QDistinct> distinctByBizDate(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bizDate', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QDistinct>
      distinctByBizDateGroupKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bizDateGroupKey',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QDistinct> distinctByGroupCode(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'groupCode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QDistinct>
      distinctByProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'progress');
    });
  }

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QDistinct> distinctBySort() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sort');
    });
  }

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TaskGroupEntity, TaskGroupEntity, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension TaskGroupEntityQueryProperty
    on QueryBuilder<TaskGroupEntity, TaskGroupEntity, QQueryProperty> {
  QueryBuilder<TaskGroupEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<TaskGroupEntity, String, QQueryOperations> bizDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bizDate');
    });
  }

  QueryBuilder<TaskGroupEntity, String, QQueryOperations>
      bizDateGroupKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bizDateGroupKey');
    });
  }

  QueryBuilder<TaskGroupEntity, String, QQueryOperations> groupCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'groupCode');
    });
  }

  QueryBuilder<TaskGroupEntity, double, QQueryOperations> progressProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'progress');
    });
  }

  QueryBuilder<TaskGroupEntity, int, QQueryOperations> sortProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sort');
    });
  }

  QueryBuilder<TaskGroupEntity, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<TaskGroupEntity, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
