// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_summary_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetHomeSummaryEntityCollection on Isar {
  IsarCollection<HomeSummaryEntity> get homeSummaryEntitys => this.collection();
}

const HomeSummaryEntitySchema = CollectionSchema(
  name: r'HomeSummaryEntity',
  id: -5694408554137805939,
  properties: {
    r'bizDate': PropertySchema(
      id: 0,
      name: r'bizDate',
      type: IsarType.string,
    ),
    r'memberScoresJson': PropertySchema(
      id: 1,
      name: r'memberScoresJson',
      type: IsarType.string,
    ),
    r'taskProgress': PropertySchema(
      id: 2,
      name: r'taskProgress',
      type: IsarType.double,
    ),
    r'updatedAt': PropertySchema(
      id: 3,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _homeSummaryEntityEstimateSize,
  serialize: _homeSummaryEntitySerialize,
  deserialize: _homeSummaryEntityDeserialize,
  deserializeProp: _homeSummaryEntityDeserializeProp,
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
  getId: _homeSummaryEntityGetId,
  getLinks: _homeSummaryEntityGetLinks,
  attach: _homeSummaryEntityAttach,
  version: '3.1.0+1',
);

int _homeSummaryEntityEstimateSize(
  HomeSummaryEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.bizDate.length * 3;
  bytesCount += 3 + object.memberScoresJson.length * 3;
  return bytesCount;
}

void _homeSummaryEntitySerialize(
  HomeSummaryEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.bizDate);
  writer.writeString(offsets[1], object.memberScoresJson);
  writer.writeDouble(offsets[2], object.taskProgress);
  writer.writeDateTime(offsets[3], object.updatedAt);
}

HomeSummaryEntity _homeSummaryEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = HomeSummaryEntity();
  object.bizDate = reader.readString(offsets[0]);
  object.id = id;
  object.memberScoresJson = reader.readString(offsets[1]);
  object.taskProgress = reader.readDouble(offsets[2]);
  object.updatedAt = reader.readDateTime(offsets[3]);
  return object;
}

P _homeSummaryEntityDeserializeProp<P>(
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
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _homeSummaryEntityGetId(HomeSummaryEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _homeSummaryEntityGetLinks(
    HomeSummaryEntity object) {
  return [];
}

void _homeSummaryEntityAttach(
    IsarCollection<dynamic> col, Id id, HomeSummaryEntity object) {
  object.id = id;
}

extension HomeSummaryEntityByIndex on IsarCollection<HomeSummaryEntity> {
  Future<HomeSummaryEntity?> getByBizDate(String bizDate) {
    return getByIndex(r'bizDate', [bizDate]);
  }

  HomeSummaryEntity? getByBizDateSync(String bizDate) {
    return getByIndexSync(r'bizDate', [bizDate]);
  }

  Future<bool> deleteByBizDate(String bizDate) {
    return deleteByIndex(r'bizDate', [bizDate]);
  }

  bool deleteByBizDateSync(String bizDate) {
    return deleteByIndexSync(r'bizDate', [bizDate]);
  }

  Future<List<HomeSummaryEntity?>> getAllByBizDate(List<String> bizDateValues) {
    final values = bizDateValues.map((e) => [e]).toList();
    return getAllByIndex(r'bizDate', values);
  }

  List<HomeSummaryEntity?> getAllByBizDateSync(List<String> bizDateValues) {
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

  Future<Id> putByBizDate(HomeSummaryEntity object) {
    return putByIndex(r'bizDate', object);
  }

  Id putByBizDateSync(HomeSummaryEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'bizDate', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByBizDate(List<HomeSummaryEntity> objects) {
    return putAllByIndex(r'bizDate', objects);
  }

  List<Id> putAllByBizDateSync(List<HomeSummaryEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'bizDate', objects, saveLinks: saveLinks);
  }
}

extension HomeSummaryEntityQueryWhereSort
    on QueryBuilder<HomeSummaryEntity, HomeSummaryEntity, QWhere> {
  QueryBuilder<HomeSummaryEntity, HomeSummaryEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension HomeSummaryEntityQueryWhere
    on QueryBuilder<HomeSummaryEntity, HomeSummaryEntity, QWhereClause> {
  QueryBuilder<HomeSummaryEntity, HomeSummaryEntity, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<HomeSummaryEntity, HomeSummaryEntity, QAfterWhereClause>
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

  QueryBuilder<HomeSummaryEntity, HomeSummaryEntity, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<HomeSummaryEntity, HomeSummaryEntity, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<HomeSummaryEntity, HomeSummaryEntity, QAfterWhereClause>
      idBetween(
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

  QueryBuilder<HomeSummaryEntity, HomeSummaryEntity, QAfterWhereClause>
      bizDateEqualTo(String bizDate) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'bizDate',
        value: [bizDate],
      ));
    });
  }

  QueryBuilder<HomeSummaryEntity, HomeSummaryEntity, QAfterWhereClause>
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

extension HomeSummaryEntityQueryFilter
    on QueryBuilder<HomeSummaryEntity, HomeSummaryEntity, QFilterCondition> {
  QueryBuilder<HomeSummaryEntity, HomeSummaryEntity, QAfterFilterCondition>
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

  QueryBuilder<HomeSummaryEntity, HomeSummaryEntity, QAfterFilterCondition>
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

  QueryBuilder<HomeSummaryEntity, HomeSummaryEntity, QAfterFilterCondition>
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

  QueryBuilder<HomeSummaryEntity, HomeSummaryEntity, QAfterFilterCondition>
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

  QueryBuilder<HomeSummaryEntity, HomeSummaryEntity, QAfterFilterCondition>
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

  QueryBuilder<HomeSummaryEntity, HomeSummaryEntity, QAfterFilterCondition>
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

  QueryBuilder<HomeSummaryEntity, HomeSummaryEntity, QAfterFilterCondition>
      bizDateContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'bizDate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HomeSummaryEntity, HomeSummaryEntity, QAfterFilterCondition>
      bizDateMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'bizDate',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HomeSummaryEntity, HomeSummaryEntity, QAfterFilterCondition>
      bizDateIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bizDate',
        value: '',
      ));
    });
  }

  QueryBuilder<HomeSummaryEntity, HomeSummaryEntity, QAfterFilterCondition>
      bizDateIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'bizDate',
        value: '',
      ));
    });
  }

  QueryBuilder<HomeSummaryEntity, HomeSummaryEntity, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<HomeSummaryEntity, HomeSummaryEntity, QAfterFilterCondition>
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

  QueryBuilder<HomeSummaryEntity, HomeSummaryEntity, QAfterFilterCondition>
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

  QueryBuilder<HomeSummaryEntity, HomeSummaryEntity, QAfterFilterCondition>
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

  QueryBuilder<HomeSummaryEntity, HomeSummaryEntity, QAfterFilterCondition>
      memberScoresJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'memberScoresJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HomeSummaryEntity, HomeSummaryEntity, QAfterFilterCondition>
      memberScoresJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'memberScoresJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HomeSummaryEntity, HomeSummaryEntity, QAfterFilterCondition>
      memberScoresJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'memberScoresJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HomeSummaryEntity, HomeSummaryEntity, QAfterFilterCondition>
      memberScoresJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'memberScoresJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HomeSummaryEntity, HomeSummaryEntity, QAfterFilterCondition>
      memberScoresJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'memberScoresJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HomeSummaryEntity, HomeSummaryEntity, QAfterFilterCondition>
      memberScoresJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'memberScoresJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HomeSummaryEntity, HomeSummaryEntity, QAfterFilterCondition>
      memberScoresJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'memberScoresJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HomeSummaryEntity, HomeSummaryEntity, QAfterFilterCondition>
      memberScoresJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'memberScoresJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HomeSummaryEntity, HomeSummaryEntity, QAfterFilterCondition>
      memberScoresJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'memberScoresJson',
        value: '',
      ));
    });
  }

  QueryBuilder<HomeSummaryEntity, HomeSummaryEntity, QAfterFilterCondition>
      memberScoresJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'memberScoresJson',
        value: '',
      ));
    });
  }

  QueryBuilder<HomeSummaryEntity, HomeSummaryEntity, QAfterFilterCondition>
      taskProgressEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'taskProgress',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<HomeSummaryEntity, HomeSummaryEntity, QAfterFilterCondition>
      taskProgressGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'taskProgress',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<HomeSummaryEntity, HomeSummaryEntity, QAfterFilterCondition>
      taskProgressLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'taskProgress',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<HomeSummaryEntity, HomeSummaryEntity, QAfterFilterCondition>
      taskProgressBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'taskProgress',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<HomeSummaryEntity, HomeSummaryEntity, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<HomeSummaryEntity, HomeSummaryEntity, QAfterFilterCondition>
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

  QueryBuilder<HomeSummaryEntity, HomeSummaryEntity, QAfterFilterCondition>
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

  QueryBuilder<HomeSummaryEntity, HomeSummaryEntity, QAfterFilterCondition>
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

extension HomeSummaryEntityQueryObject
    on QueryBuilder<HomeSummaryEntity, HomeSummaryEntity, QFilterCondition> {}

extension HomeSummaryEntityQueryLinks
    on QueryBuilder<HomeSummaryEntity, HomeSummaryEntity, QFilterCondition> {}

extension HomeSummaryEntityQuerySortBy
    on QueryBuilder<HomeSummaryEntity, HomeSummaryEntity, QSortBy> {
  QueryBuilder<HomeSummaryEntity, HomeSummaryEntity, QAfterSortBy>
      sortByBizDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bizDate', Sort.asc);
    });
  }

  QueryBuilder<HomeSummaryEntity, HomeSummaryEntity, QAfterSortBy>
      sortByBizDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bizDate', Sort.desc);
    });
  }

  QueryBuilder<HomeSummaryEntity, HomeSummaryEntity, QAfterSortBy>
      sortByMemberScoresJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'memberScoresJson', Sort.asc);
    });
  }

  QueryBuilder<HomeSummaryEntity, HomeSummaryEntity, QAfterSortBy>
      sortByMemberScoresJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'memberScoresJson', Sort.desc);
    });
  }

  QueryBuilder<HomeSummaryEntity, HomeSummaryEntity, QAfterSortBy>
      sortByTaskProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskProgress', Sort.asc);
    });
  }

  QueryBuilder<HomeSummaryEntity, HomeSummaryEntity, QAfterSortBy>
      sortByTaskProgressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskProgress', Sort.desc);
    });
  }

  QueryBuilder<HomeSummaryEntity, HomeSummaryEntity, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<HomeSummaryEntity, HomeSummaryEntity, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension HomeSummaryEntityQuerySortThenBy
    on QueryBuilder<HomeSummaryEntity, HomeSummaryEntity, QSortThenBy> {
  QueryBuilder<HomeSummaryEntity, HomeSummaryEntity, QAfterSortBy>
      thenByBizDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bizDate', Sort.asc);
    });
  }

  QueryBuilder<HomeSummaryEntity, HomeSummaryEntity, QAfterSortBy>
      thenByBizDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bizDate', Sort.desc);
    });
  }

  QueryBuilder<HomeSummaryEntity, HomeSummaryEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<HomeSummaryEntity, HomeSummaryEntity, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<HomeSummaryEntity, HomeSummaryEntity, QAfterSortBy>
      thenByMemberScoresJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'memberScoresJson', Sort.asc);
    });
  }

  QueryBuilder<HomeSummaryEntity, HomeSummaryEntity, QAfterSortBy>
      thenByMemberScoresJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'memberScoresJson', Sort.desc);
    });
  }

  QueryBuilder<HomeSummaryEntity, HomeSummaryEntity, QAfterSortBy>
      thenByTaskProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskProgress', Sort.asc);
    });
  }

  QueryBuilder<HomeSummaryEntity, HomeSummaryEntity, QAfterSortBy>
      thenByTaskProgressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskProgress', Sort.desc);
    });
  }

  QueryBuilder<HomeSummaryEntity, HomeSummaryEntity, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<HomeSummaryEntity, HomeSummaryEntity, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension HomeSummaryEntityQueryWhereDistinct
    on QueryBuilder<HomeSummaryEntity, HomeSummaryEntity, QDistinct> {
  QueryBuilder<HomeSummaryEntity, HomeSummaryEntity, QDistinct>
      distinctByBizDate({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bizDate', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<HomeSummaryEntity, HomeSummaryEntity, QDistinct>
      distinctByMemberScoresJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'memberScoresJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<HomeSummaryEntity, HomeSummaryEntity, QDistinct>
      distinctByTaskProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'taskProgress');
    });
  }

  QueryBuilder<HomeSummaryEntity, HomeSummaryEntity, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension HomeSummaryEntityQueryProperty
    on QueryBuilder<HomeSummaryEntity, HomeSummaryEntity, QQueryProperty> {
  QueryBuilder<HomeSummaryEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<HomeSummaryEntity, String, QQueryOperations> bizDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bizDate');
    });
  }

  QueryBuilder<HomeSummaryEntity, String, QQueryOperations>
      memberScoresJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'memberScoresJson');
    });
  }

  QueryBuilder<HomeSummaryEntity, double, QQueryOperations>
      taskProgressProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'taskProgress');
    });
  }

  QueryBuilder<HomeSummaryEntity, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
