// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feature_entry_entity_io.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetFeatureEntryEntityCollection on Isar {
  IsarCollection<FeatureEntryEntity> get featureEntryEntitys =>
      this.collection();
}

const FeatureEntryEntitySchema = CollectionSchema(
  name: r'FeatureEntryEntity',
  id: 6906952659081653049,
  properties: {
    r'enabled': PropertySchema(
      id: 0,
      name: r'enabled',
      type: IsarType.bool,
    ),
    r'entryKey': PropertySchema(
      id: 1,
      name: r'entryKey',
      type: IsarType.string,
    ),
    r'icon': PropertySchema(
      id: 2,
      name: r'icon',
      type: IsarType.string,
    ),
    r'sort': PropertySchema(
      id: 3,
      name: r'sort',
      type: IsarType.long,
    ),
    r'title': PropertySchema(
      id: 4,
      name: r'title',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 5,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _featureEntryEntityEstimateSize,
  serialize: _featureEntryEntitySerialize,
  deserialize: _featureEntryEntityDeserialize,
  deserializeProp: _featureEntryEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'entryKey': IndexSchema(
      id: 7468454376934395055,
      name: r'entryKey',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'entryKey',
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
  getId: _featureEntryEntityGetId,
  getLinks: _featureEntryEntityGetLinks,
  attach: _featureEntryEntityAttach,
  version: '3.1.0+1',
);

int _featureEntryEntityEstimateSize(
  FeatureEntryEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.entryKey.length * 3;
  bytesCount += 3 + object.icon.length * 3;
  bytesCount += 3 + object.title.length * 3;
  return bytesCount;
}

void _featureEntryEntitySerialize(
  FeatureEntryEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.enabled);
  writer.writeString(offsets[1], object.entryKey);
  writer.writeString(offsets[2], object.icon);
  writer.writeLong(offsets[3], object.sort);
  writer.writeString(offsets[4], object.title);
  writer.writeDateTime(offsets[5], object.updatedAt);
}

FeatureEntryEntity _featureEntryEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = FeatureEntryEntity();
  object.enabled = reader.readBool(offsets[0]);
  object.entryKey = reader.readString(offsets[1]);
  object.icon = reader.readString(offsets[2]);
  object.id = id;
  object.sort = reader.readLong(offsets[3]);
  object.title = reader.readString(offsets[4]);
  object.updatedAt = reader.readDateTime(offsets[5]);
  return object;
}

P _featureEntryEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _featureEntryEntityGetId(FeatureEntryEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _featureEntryEntityGetLinks(
    FeatureEntryEntity object) {
  return [];
}

void _featureEntryEntityAttach(
    IsarCollection<dynamic> col, Id id, FeatureEntryEntity object) {
  object.id = id;
}

extension FeatureEntryEntityByIndex on IsarCollection<FeatureEntryEntity> {
  Future<FeatureEntryEntity?> getByEntryKey(String entryKey) {
    return getByIndex(r'entryKey', [entryKey]);
  }

  FeatureEntryEntity? getByEntryKeySync(String entryKey) {
    return getByIndexSync(r'entryKey', [entryKey]);
  }

  Future<bool> deleteByEntryKey(String entryKey) {
    return deleteByIndex(r'entryKey', [entryKey]);
  }

  bool deleteByEntryKeySync(String entryKey) {
    return deleteByIndexSync(r'entryKey', [entryKey]);
  }

  Future<List<FeatureEntryEntity?>> getAllByEntryKey(
      List<String> entryKeyValues) {
    final values = entryKeyValues.map((e) => [e]).toList();
    return getAllByIndex(r'entryKey', values);
  }

  List<FeatureEntryEntity?> getAllByEntryKeySync(List<String> entryKeyValues) {
    final values = entryKeyValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'entryKey', values);
  }

  Future<int> deleteAllByEntryKey(List<String> entryKeyValues) {
    final values = entryKeyValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'entryKey', values);
  }

  int deleteAllByEntryKeySync(List<String> entryKeyValues) {
    final values = entryKeyValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'entryKey', values);
  }

  Future<Id> putByEntryKey(FeatureEntryEntity object) {
    return putByIndex(r'entryKey', object);
  }

  Id putByEntryKeySync(FeatureEntryEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'entryKey', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByEntryKey(List<FeatureEntryEntity> objects) {
    return putAllByIndex(r'entryKey', objects);
  }

  List<Id> putAllByEntryKeySync(List<FeatureEntryEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'entryKey', objects, saveLinks: saveLinks);
  }
}

extension FeatureEntryEntityQueryWhereSort
    on QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QWhere> {
  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterWhere> anySort() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'sort'),
      );
    });
  }
}

extension FeatureEntryEntityQueryWhere
    on QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QWhereClause> {
  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterWhereClause>
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

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterWhereClause>
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

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterWhereClause>
      entryKeyEqualTo(String entryKey) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'entryKey',
        value: [entryKey],
      ));
    });
  }

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterWhereClause>
      entryKeyNotEqualTo(String entryKey) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'entryKey',
              lower: [],
              upper: [entryKey],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'entryKey',
              lower: [entryKey],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'entryKey',
              lower: [entryKey],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'entryKey',
              lower: [],
              upper: [entryKey],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterWhereClause>
      sortEqualTo(int sort) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'sort',
        value: [sort],
      ));
    });
  }

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterWhereClause>
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

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterWhereClause>
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

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterWhereClause>
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

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterWhereClause>
      sortBetween(
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

extension FeatureEntryEntityQueryFilter
    on QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QFilterCondition> {
  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterFilterCondition>
      enabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'enabled',
        value: value,
      ));
    });
  }

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterFilterCondition>
      entryKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'entryKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterFilterCondition>
      entryKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'entryKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterFilterCondition>
      entryKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'entryKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterFilterCondition>
      entryKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'entryKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterFilterCondition>
      entryKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'entryKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterFilterCondition>
      entryKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'entryKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterFilterCondition>
      entryKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'entryKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterFilterCondition>
      entryKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'entryKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterFilterCondition>
      entryKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'entryKey',
        value: '',
      ));
    });
  }

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterFilterCondition>
      entryKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'entryKey',
        value: '',
      ));
    });
  }

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterFilterCondition>
      iconEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'icon',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterFilterCondition>
      iconGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'icon',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterFilterCondition>
      iconLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'icon',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterFilterCondition>
      iconBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'icon',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterFilterCondition>
      iconStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'icon',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterFilterCondition>
      iconEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'icon',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterFilterCondition>
      iconContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'icon',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterFilterCondition>
      iconMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'icon',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterFilterCondition>
      iconIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'icon',
        value: '',
      ));
    });
  }

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterFilterCondition>
      iconIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'icon',
        value: '',
      ));
    });
  }

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterFilterCondition>
      sortEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sort',
        value: value,
      ));
    });
  }

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterFilterCondition>
      titleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterFilterCondition>
      titleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterFilterCondition>
      titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterFilterCondition>
      titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterFilterCondition>
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

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterFilterCondition>
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

extension FeatureEntryEntityQueryObject
    on QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QFilterCondition> {}

extension FeatureEntryEntityQueryLinks
    on QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QFilterCondition> {}

extension FeatureEntryEntityQuerySortBy
    on QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QSortBy> {
  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterSortBy>
      sortByEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enabled', Sort.asc);
    });
  }

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterSortBy>
      sortByEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enabled', Sort.desc);
    });
  }

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterSortBy>
      sortByEntryKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entryKey', Sort.asc);
    });
  }

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterSortBy>
      sortByEntryKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entryKey', Sort.desc);
    });
  }

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterSortBy>
      sortByIcon() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'icon', Sort.asc);
    });
  }

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterSortBy>
      sortByIconDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'icon', Sort.desc);
    });
  }

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterSortBy>
      sortBySort() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sort', Sort.asc);
    });
  }

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterSortBy>
      sortBySortDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sort', Sort.desc);
    });
  }

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterSortBy>
      sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterSortBy>
      sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension FeatureEntryEntityQuerySortThenBy
    on QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QSortThenBy> {
  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterSortBy>
      thenByEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enabled', Sort.asc);
    });
  }

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterSortBy>
      thenByEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enabled', Sort.desc);
    });
  }

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterSortBy>
      thenByEntryKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entryKey', Sort.asc);
    });
  }

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterSortBy>
      thenByEntryKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entryKey', Sort.desc);
    });
  }

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterSortBy>
      thenByIcon() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'icon', Sort.asc);
    });
  }

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterSortBy>
      thenByIconDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'icon', Sort.desc);
    });
  }

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterSortBy>
      thenBySort() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sort', Sort.asc);
    });
  }

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterSortBy>
      thenBySortDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sort', Sort.desc);
    });
  }

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterSortBy>
      thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterSortBy>
      thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension FeatureEntryEntityQueryWhereDistinct
    on QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QDistinct> {
  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QDistinct>
      distinctByEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'enabled');
    });
  }

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QDistinct>
      distinctByEntryKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'entryKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QDistinct>
      distinctByIcon({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'icon', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QDistinct>
      distinctBySort() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sort');
    });
  }

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QDistinct>
      distinctByTitle({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension FeatureEntryEntityQueryProperty
    on QueryBuilder<FeatureEntryEntity, FeatureEntryEntity, QQueryProperty> {
  QueryBuilder<FeatureEntryEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<FeatureEntryEntity, bool, QQueryOperations> enabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'enabled');
    });
  }

  QueryBuilder<FeatureEntryEntity, String, QQueryOperations>
      entryKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'entryKey');
    });
  }

  QueryBuilder<FeatureEntryEntity, String, QQueryOperations> iconProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'icon');
    });
  }

  QueryBuilder<FeatureEntryEntity, int, QQueryOperations> sortProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sort');
    });
  }

  QueryBuilder<FeatureEntryEntity, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<FeatureEntryEntity, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
