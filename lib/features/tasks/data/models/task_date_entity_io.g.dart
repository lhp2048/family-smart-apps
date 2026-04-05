// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_date_entity_io.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTaskDateEntityCollection on Isar {
  IsarCollection<TaskDateEntity> get taskDateEntitys => this.collection();
}

const TaskDateEntitySchema = CollectionSchema(
  name: r'TaskDateEntity',
  id: 7119123691188122581,
  properties: {
    r'bizDate': PropertySchema(
      id: 0,
      name: r'bizDate',
      type: IsarType.string,
    ),
    r'hasReward': PropertySchema(
      id: 1,
      name: r'hasReward',
      type: IsarType.bool,
    ),
    r'updatedAt': PropertySchema(
      id: 2,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'weekday': PropertySchema(
      id: 3,
      name: r'weekday',
      type: IsarType.string,
    )
  },
  estimateSize: _taskDateEntityEstimateSize,
  serialize: _taskDateEntitySerialize,
  deserialize: _taskDateEntityDeserialize,
  deserializeProp: _taskDateEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'bizDate': IndexSchema(
      id: 6295166300634180650,
      name: r'bizDate',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'bizDate',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _taskDateEntityGetId,
  getLinks: _taskDateEntityGetLinks,
  attach: _taskDateEntityAttach,
  version: '3.1.0+1',
);

int _taskDateEntityEstimateSize(
  TaskDateEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.bizDate.length * 3;
  bytesCount += 3 + object.weekday.length * 3;
  return bytesCount;
}

void _taskDateEntitySerialize(
  TaskDateEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.bizDate);
  writer.writeBool(offsets[1], object.hasReward);
  writer.writeDateTime(offsets[2], object.updatedAt);
  writer.writeString(offsets[3], object.weekday);
}

TaskDateEntity _taskDateEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TaskDateEntity();
  object.bizDate = reader.readString(offsets[0]);
  object.hasReward = reader.readBool(offsets[1]);
  object.id = id;
  object.updatedAt = reader.readDateTime(offsets[2]);
  object.weekday = reader.readString(offsets[3]);
  return object;
}

P _taskDateEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _taskDateEntityGetId(TaskDateEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _taskDateEntityGetLinks(TaskDateEntity object) {
  return [];
}

void _taskDateEntityAttach(
    IsarCollection<dynamic> col, Id id, TaskDateEntity object) {
  object.id = id;
}

extension TaskDateEntityByIndex on IsarCollection<TaskDateEntity> {
  Future<TaskDateEntity?> getByBizDate(String bizDate) {
    return getByIndex(r'bizDate', [bizDate]);
  }

  TaskDateEntity? getByBizDateSync(String bizDate) {
    return getByIndexSync(r'bizDate', [bizDate]);
  }

  Future<bool> deleteByBizDate(String bizDate) {
    return deleteByIndex(r'bizDate', [bizDate]);
  }

  bool deleteByBizDateSync(String bizDate) {
    return deleteByIndexSync(r'bizDate', [bizDate]);
  }

  Future<List<TaskDateEntity?>> getAllByBizDate(List<String> bizDateValues) {
    final values = bizDateValues.map((e) => [e]).toList();
    return getAllByIndex(r'bizDate', values);
  }

  List<TaskDateEntity?> getAllByBizDateSync(List<String> bizDateValues) {
    final values = bizDateValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'bizDate', values);
  }

  Future<int> deleteAllByBizDate(List<String> bizDateValues) {
    final values = bizDateValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'bizDate', values);
  }

  int deleteAllByBizDateSync(List<String> bizDateValues) {
    final values = bizDateValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'bizDate', values);
  }

  Future<Id> putByBizDate(TaskDateEntity object) {
    return putByIndex(r'bizDate', object);
  }

  Id putByBizDateSync(TaskDateEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'bizDate', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByBizDate(List<TaskDateEntity> objects) {
    return putAllByIndex(r'bizDate', objects);
  }

  List<Id> putAllByBizDateSync(List<TaskDateEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'bizDate', objects, saveLinks: saveLinks);
  }
}

extension TaskDateEntityQueryWhereSort
    on QueryBuilder<TaskDateEntity, TaskDateEntity, QWhere> {
  QueryBuilder<TaskDateEntity, TaskDateEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension TaskDateEntityQueryWhere
    on QueryBuilder<TaskDateEntity, TaskDateEntity, QWhereClause> {
  QueryBuilder<TaskDateEntity, TaskDateEntity, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<TaskDateEntity, TaskDateEntity, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<TaskDateEntity, TaskDateEntity, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<TaskDateEntity, TaskDateEntity, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<TaskDateEntity, TaskDateEntity, QAfterWhereClause> idBetween(
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

  QueryBuilder<TaskDateEntity, TaskDateEntity, QAfterWhereClause>
      bizDateEqualTo(String bizDate) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'bizDate',
        value: [bizDate],
      ));
    });
  }

  QueryBuilder<TaskDateEntity, TaskDateEntity, QAfterWhereClause>
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
}

extension TaskDateEntityQueryFilter
    on QueryBuilder<TaskDateEntity, TaskDateEntity, QFilterCondition> {
  QueryBuilder<TaskDateEntity, TaskDateEntity, QAfterFilterCondition>
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

  QueryBuilder<TaskDateEntity, TaskDateEntity, QAfterFilterCondition>
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

  QueryBuilder<TaskDateEntity, TaskDateEntity, QAfterFilterCondition>
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

  QueryBuilder<TaskDateEntity, TaskDateEntity, QAfterFilterCondition>
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

  QueryBuilder<TaskDateEntity, TaskDateEntity, QAfterFilterCondition>
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

  QueryBuilder<TaskDateEntity, TaskDateEntity, QAfterFilterCondition>
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

  QueryBuilder<TaskDateEntity, TaskDateEntity, QAfterFilterCondition>
      bizDateContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'bizDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskDateEntity, TaskDateEntity, QAfterFilterCondition>
      bizDateMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'bizDate',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskDateEntity, TaskDateEntity, QAfterFilterCondition>
      bizDateIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bizDate',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskDateEntity, TaskDateEntity, QAfterFilterCondition>
      bizDateIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'bizDate',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskDateEntity, TaskDateEntity, QAfterFilterCondition>
      hasRewardEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hasReward',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskDateEntity, TaskDateEntity, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskDateEntity, TaskDateEntity, QAfterFilterCondition>
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

  QueryBuilder<TaskDateEntity, TaskDateEntity, QAfterFilterCondition>
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

  QueryBuilder<TaskDateEntity, TaskDateEntity, QAfterFilterCondition> idBetween(
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

  QueryBuilder<TaskDateEntity, TaskDateEntity, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskDateEntity, TaskDateEntity, QAfterFilterCondition>
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

  QueryBuilder<TaskDateEntity, TaskDateEntity, QAfterFilterCondition>
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

  QueryBuilder<TaskDateEntity, TaskDateEntity, QAfterFilterCondition>
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

  QueryBuilder<TaskDateEntity, TaskDateEntity, QAfterFilterCondition>
      weekdayEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'weekday',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskDateEntity, TaskDateEntity, QAfterFilterCondition>
      weekdayGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'weekday',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskDateEntity, TaskDateEntity, QAfterFilterCondition>
      weekdayLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'weekday',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskDateEntity, TaskDateEntity, QAfterFilterCondition>
      weekdayBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'weekday',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskDateEntity, TaskDateEntity, QAfterFilterCondition>
      weekdayStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'weekday',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskDateEntity, TaskDateEntity, QAfterFilterCondition>
      weekdayEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'weekday',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskDateEntity, TaskDateEntity, QAfterFilterCondition>
      weekdayContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'weekday',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskDateEntity, TaskDateEntity, QAfterFilterCondition>
      weekdayMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'weekday',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskDateEntity, TaskDateEntity, QAfterFilterCondition>
      weekdayIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'weekday',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskDateEntity, TaskDateEntity, QAfterFilterCondition>
      weekdayIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'weekday',
        value: '',
      ));
    });
  }
}

extension TaskDateEntityQueryObject
    on QueryBuilder<TaskDateEntity, TaskDateEntity, QFilterCondition> {}

extension TaskDateEntityQueryLinks
    on QueryBuilder<TaskDateEntity, TaskDateEntity, QFilterCondition> {}

extension TaskDateEntityQuerySortBy
    on QueryBuilder<TaskDateEntity, TaskDateEntity, QSortBy> {
  QueryBuilder<TaskDateEntity, TaskDateEntity, QAfterSortBy> sortByBizDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bizDate', Sort.asc);
    });
  }

  QueryBuilder<TaskDateEntity, TaskDateEntity, QAfterSortBy>
      sortByBizDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bizDate', Sort.desc);
    });
  }

  QueryBuilder<TaskDateEntity, TaskDateEntity, QAfterSortBy> sortByHasReward() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasReward', Sort.asc);
    });
  }

  QueryBuilder<TaskDateEntity, TaskDateEntity, QAfterSortBy>
      sortByHasRewardDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasReward', Sort.desc);
    });
  }

  QueryBuilder<TaskDateEntity, TaskDateEntity, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<TaskDateEntity, TaskDateEntity, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<TaskDateEntity, TaskDateEntity, QAfterSortBy> sortByWeekday() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weekday', Sort.asc);
    });
  }

  QueryBuilder<TaskDateEntity, TaskDateEntity, QAfterSortBy>
      sortByWeekdayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weekday', Sort.desc);
    });
  }
}

extension TaskDateEntityQuerySortThenBy
    on QueryBuilder<TaskDateEntity, TaskDateEntity, QSortThenBy> {
  QueryBuilder<TaskDateEntity, TaskDateEntity, QAfterSortBy> thenByBizDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bizDate', Sort.asc);
    });
  }

  QueryBuilder<TaskDateEntity, TaskDateEntity, QAfterSortBy>
      thenByBizDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bizDate', Sort.desc);
    });
  }

  QueryBuilder<TaskDateEntity, TaskDateEntity, QAfterSortBy> thenByHasReward() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasReward', Sort.asc);
    });
  }

  QueryBuilder<TaskDateEntity, TaskDateEntity, QAfterSortBy>
      thenByHasRewardDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasReward', Sort.desc);
    });
  }

  QueryBuilder<TaskDateEntity, TaskDateEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<TaskDateEntity, TaskDateEntity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<TaskDateEntity, TaskDateEntity, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<TaskDateEntity, TaskDateEntity, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<TaskDateEntity, TaskDateEntity, QAfterSortBy> thenByWeekday() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weekday', Sort.asc);
    });
  }

  QueryBuilder<TaskDateEntity, TaskDateEntity, QAfterSortBy>
      thenByWeekdayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weekday', Sort.desc);
    });
  }
}

extension TaskDateEntityQueryWhereDistinct
    on QueryBuilder<TaskDateEntity, TaskDateEntity, QDistinct> {
  QueryBuilder<TaskDateEntity, TaskDateEntity, QDistinct> distinctByBizDate(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bizDate', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TaskDateEntity, TaskDateEntity, QDistinct>
      distinctByHasReward() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hasReward');
    });
  }

  QueryBuilder<TaskDateEntity, TaskDateEntity, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<TaskDateEntity, TaskDateEntity, QDistinct> distinctByWeekday(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'weekday', caseSensitive: caseSensitive);
    });
  }
}

extension TaskDateEntityQueryProperty
    on QueryBuilder<TaskDateEntity, TaskDateEntity, QQueryProperty> {
  QueryBuilder<TaskDateEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<TaskDateEntity, String, QQueryOperations> bizDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bizDate');
    });
  }

  QueryBuilder<TaskDateEntity, bool, QQueryOperations> hasRewardProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hasReward');
    });
  }

  QueryBuilder<TaskDateEntity, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<TaskDateEntity, String, QQueryOperations> weekdayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'weekday');
    });
  }
}
