// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_db.dart';

// ignore_for_file: type=lint
class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, Transaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _amountFenMeta = const VerificationMeta(
    'amountFen',
  );
  @override
  late final GeneratedColumn<int> amountFen = GeneratedColumn<int>(
    'amount_fen',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 32,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('manual'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    amountFen,
    occurredAt,
    category,
    note,
    source,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Transaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('amount_fen')) {
      context.handle(
        _amountFenMeta,
        amountFen.isAcceptableOrUnknown(data['amount_fen']!, _amountFenMeta),
      );
    } else if (isInserting) {
      context.missing(_amountFenMeta);
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Transaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Transaction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      amountFen: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_fen'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }
}

class Transaction extends DataClass implements Insertable<Transaction> {
  final int id;
  final int amountFen;
  final DateTime occurredAt;
  final String category;
  final String note;
  final String source;
  const Transaction({
    required this.id,
    required this.amountFen,
    required this.occurredAt,
    required this.category,
    required this.note,
    required this.source,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['amount_fen'] = Variable<int>(amountFen);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    map['category'] = Variable<String>(category);
    map['note'] = Variable<String>(note);
    map['source'] = Variable<String>(source);
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      amountFen: Value(amountFen),
      occurredAt: Value(occurredAt),
      category: Value(category),
      note: Value(note),
      source: Value(source),
    );
  }

  factory Transaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Transaction(
      id: serializer.fromJson<int>(json['id']),
      amountFen: serializer.fromJson<int>(json['amountFen']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
      category: serializer.fromJson<String>(json['category']),
      note: serializer.fromJson<String>(json['note']),
      source: serializer.fromJson<String>(json['source']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'amountFen': serializer.toJson<int>(amountFen),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'category': serializer.toJson<String>(category),
      'note': serializer.toJson<String>(note),
      'source': serializer.toJson<String>(source),
    };
  }

  Transaction copyWith({
    int? id,
    int? amountFen,
    DateTime? occurredAt,
    String? category,
    String? note,
    String? source,
  }) => Transaction(
    id: id ?? this.id,
    amountFen: amountFen ?? this.amountFen,
    occurredAt: occurredAt ?? this.occurredAt,
    category: category ?? this.category,
    note: note ?? this.note,
    source: source ?? this.source,
  );
  Transaction copyWithCompanion(TransactionsCompanion data) {
    return Transaction(
      id: data.id.present ? data.id.value : this.id,
      amountFen: data.amountFen.present ? data.amountFen.value : this.amountFen,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      category: data.category.present ? data.category.value : this.category,
      note: data.note.present ? data.note.value : this.note,
      source: data.source.present ? data.source.value : this.source,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Transaction(')
          ..write('id: $id, ')
          ..write('amountFen: $amountFen, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('category: $category, ')
          ..write('note: $note, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, amountFen, occurredAt, category, note, source);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transaction &&
          other.id == this.id &&
          other.amountFen == this.amountFen &&
          other.occurredAt == this.occurredAt &&
          other.category == this.category &&
          other.note == this.note &&
          other.source == this.source);
}

class TransactionsCompanion extends UpdateCompanion<Transaction> {
  final Value<int> id;
  final Value<int> amountFen;
  final Value<DateTime> occurredAt;
  final Value<String> category;
  final Value<String> note;
  final Value<String> source;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.amountFen = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.category = const Value.absent(),
    this.note = const Value.absent(),
    this.source = const Value.absent(),
  });
  TransactionsCompanion.insert({
    this.id = const Value.absent(),
    required int amountFen,
    required DateTime occurredAt,
    required String category,
    this.note = const Value.absent(),
    this.source = const Value.absent(),
  }) : amountFen = Value(amountFen),
       occurredAt = Value(occurredAt),
       category = Value(category);
  static Insertable<Transaction> custom({
    Expression<int>? id,
    Expression<int>? amountFen,
    Expression<DateTime>? occurredAt,
    Expression<String>? category,
    Expression<String>? note,
    Expression<String>? source,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (amountFen != null) 'amount_fen': amountFen,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (category != null) 'category': category,
      if (note != null) 'note': note,
      if (source != null) 'source': source,
    });
  }

  TransactionsCompanion copyWith({
    Value<int>? id,
    Value<int>? amountFen,
    Value<DateTime>? occurredAt,
    Value<String>? category,
    Value<String>? note,
    Value<String>? source,
  }) {
    return TransactionsCompanion(
      id: id ?? this.id,
      amountFen: amountFen ?? this.amountFen,
      occurredAt: occurredAt ?? this.occurredAt,
      category: category ?? this.category,
      note: note ?? this.note,
      source: source ?? this.source,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (amountFen.present) {
      map['amount_fen'] = Variable<int>(amountFen.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('amountFen: $amountFen, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('category: $category, ')
          ..write('note: $note, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }
}

class $GoalsTable extends Goals with TableInfo<$GoalsTable, Goal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GoalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 32,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetFenMeta = const VerificationMeta(
    'targetFen',
  );
  @override
  late final GeneratedColumn<int> targetFen = GeneratedColumn<int>(
    'target_fen',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priceNameMeta = const VerificationMeta(
    'priceName',
  );
  @override
  late final GeneratedColumn<String> priceName = GeneratedColumn<String>(
    'price_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 16,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priceFenMeta = const VerificationMeta(
    'priceFen',
  );
  @override
  late final GeneratedColumn<int> priceFen = GeneratedColumn<int>(
    'price_fen',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tierMeta = const VerificationMeta('tier');
  @override
  late final GeneratedColumn<String> tier = GeneratedColumn<String>(
    'tier',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _doneAtMeta = const VerificationMeta('doneAt');
  @override
  late final GeneratedColumn<DateTime> doneAt = GeneratedColumn<DateTime>(
    'done_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    targetFen,
    priceName,
    priceFen,
    tier,
    doneAt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'goals';
  @override
  VerificationContext validateIntegrity(
    Insertable<Goal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('target_fen')) {
      context.handle(
        _targetFenMeta,
        targetFen.isAcceptableOrUnknown(data['target_fen']!, _targetFenMeta),
      );
    } else if (isInserting) {
      context.missing(_targetFenMeta);
    }
    if (data.containsKey('price_name')) {
      context.handle(
        _priceNameMeta,
        priceName.isAcceptableOrUnknown(data['price_name']!, _priceNameMeta),
      );
    } else if (isInserting) {
      context.missing(_priceNameMeta);
    }
    if (data.containsKey('price_fen')) {
      context.handle(
        _priceFenMeta,
        priceFen.isAcceptableOrUnknown(data['price_fen']!, _priceFenMeta),
      );
    } else if (isInserting) {
      context.missing(_priceFenMeta);
    }
    if (data.containsKey('tier')) {
      context.handle(
        _tierMeta,
        tier.isAcceptableOrUnknown(data['tier']!, _tierMeta),
      );
    }
    if (data.containsKey('done_at')) {
      context.handle(
        _doneAtMeta,
        doneAt.isAcceptableOrUnknown(data['done_at']!, _doneAtMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Goal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Goal(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      targetFen: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_fen'],
      )!,
      priceName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}price_name'],
      )!,
      priceFen: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}price_fen'],
      )!,
      tier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tier'],
      ),
      doneAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}done_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $GoalsTable createAlias(String alias) {
    return $GoalsTable(attachedDatabase, alias);
  }
}

class Goal extends DataClass implements Insertable<Goal> {
  final int id;
  final String name;
  final int targetFen;
  final String priceName;
  final int priceFen;
  final String? tier;
  final DateTime? doneAt;
  final DateTime createdAt;
  const Goal({
    required this.id,
    required this.name,
    required this.targetFen,
    required this.priceName,
    required this.priceFen,
    this.tier,
    this.doneAt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['target_fen'] = Variable<int>(targetFen);
    map['price_name'] = Variable<String>(priceName);
    map['price_fen'] = Variable<int>(priceFen);
    if (!nullToAbsent || tier != null) {
      map['tier'] = Variable<String>(tier);
    }
    if (!nullToAbsent || doneAt != null) {
      map['done_at'] = Variable<DateTime>(doneAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  GoalsCompanion toCompanion(bool nullToAbsent) {
    return GoalsCompanion(
      id: Value(id),
      name: Value(name),
      targetFen: Value(targetFen),
      priceName: Value(priceName),
      priceFen: Value(priceFen),
      tier: tier == null && nullToAbsent ? const Value.absent() : Value(tier),
      doneAt: doneAt == null && nullToAbsent
          ? const Value.absent()
          : Value(doneAt),
      createdAt: Value(createdAt),
    );
  }

  factory Goal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Goal(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      targetFen: serializer.fromJson<int>(json['targetFen']),
      priceName: serializer.fromJson<String>(json['priceName']),
      priceFen: serializer.fromJson<int>(json['priceFen']),
      tier: serializer.fromJson<String?>(json['tier']),
      doneAt: serializer.fromJson<DateTime?>(json['doneAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'targetFen': serializer.toJson<int>(targetFen),
      'priceName': serializer.toJson<String>(priceName),
      'priceFen': serializer.toJson<int>(priceFen),
      'tier': serializer.toJson<String?>(tier),
      'doneAt': serializer.toJson<DateTime?>(doneAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Goal copyWith({
    int? id,
    String? name,
    int? targetFen,
    String? priceName,
    int? priceFen,
    Value<String?> tier = const Value.absent(),
    Value<DateTime?> doneAt = const Value.absent(),
    DateTime? createdAt,
  }) => Goal(
    id: id ?? this.id,
    name: name ?? this.name,
    targetFen: targetFen ?? this.targetFen,
    priceName: priceName ?? this.priceName,
    priceFen: priceFen ?? this.priceFen,
    tier: tier.present ? tier.value : this.tier,
    doneAt: doneAt.present ? doneAt.value : this.doneAt,
    createdAt: createdAt ?? this.createdAt,
  );
  Goal copyWithCompanion(GoalsCompanion data) {
    return Goal(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      targetFen: data.targetFen.present ? data.targetFen.value : this.targetFen,
      priceName: data.priceName.present ? data.priceName.value : this.priceName,
      priceFen: data.priceFen.present ? data.priceFen.value : this.priceFen,
      tier: data.tier.present ? data.tier.value : this.tier,
      doneAt: data.doneAt.present ? data.doneAt.value : this.doneAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Goal(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('targetFen: $targetFen, ')
          ..write('priceName: $priceName, ')
          ..write('priceFen: $priceFen, ')
          ..write('tier: $tier, ')
          ..write('doneAt: $doneAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    targetFen,
    priceName,
    priceFen,
    tier,
    doneAt,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Goal &&
          other.id == this.id &&
          other.name == this.name &&
          other.targetFen == this.targetFen &&
          other.priceName == this.priceName &&
          other.priceFen == this.priceFen &&
          other.tier == this.tier &&
          other.doneAt == this.doneAt &&
          other.createdAt == this.createdAt);
}

class GoalsCompanion extends UpdateCompanion<Goal> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> targetFen;
  final Value<String> priceName;
  final Value<int> priceFen;
  final Value<String?> tier;
  final Value<DateTime?> doneAt;
  final Value<DateTime> createdAt;
  const GoalsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.targetFen = const Value.absent(),
    this.priceName = const Value.absent(),
    this.priceFen = const Value.absent(),
    this.tier = const Value.absent(),
    this.doneAt = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  GoalsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int targetFen,
    required String priceName,
    required int priceFen,
    this.tier = const Value.absent(),
    this.doneAt = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name),
       targetFen = Value(targetFen),
       priceName = Value(priceName),
       priceFen = Value(priceFen);
  static Insertable<Goal> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? targetFen,
    Expression<String>? priceName,
    Expression<int>? priceFen,
    Expression<String>? tier,
    Expression<DateTime>? doneAt,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (targetFen != null) 'target_fen': targetFen,
      if (priceName != null) 'price_name': priceName,
      if (priceFen != null) 'price_fen': priceFen,
      if (tier != null) 'tier': tier,
      if (doneAt != null) 'done_at': doneAt,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  GoalsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? targetFen,
    Value<String>? priceName,
    Value<int>? priceFen,
    Value<String?>? tier,
    Value<DateTime?>? doneAt,
    Value<DateTime>? createdAt,
  }) {
    return GoalsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      targetFen: targetFen ?? this.targetFen,
      priceName: priceName ?? this.priceName,
      priceFen: priceFen ?? this.priceFen,
      tier: tier ?? this.tier,
      doneAt: doneAt ?? this.doneAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (targetFen.present) {
      map['target_fen'] = Variable<int>(targetFen.value);
    }
    if (priceName.present) {
      map['price_name'] = Variable<String>(priceName.value);
    }
    if (priceFen.present) {
      map['price_fen'] = Variable<int>(priceFen.value);
    }
    if (tier.present) {
      map['tier'] = Variable<String>(tier.value);
    }
    if (doneAt.present) {
      map['done_at'] = Variable<DateTime>(doneAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GoalsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('targetFen: $targetFen, ')
          ..write('priceName: $priceName, ')
          ..write('priceFen: $priceFen, ')
          ..write('tier: $tier, ')
          ..write('doneAt: $doneAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $AchievementsTable extends Achievements
    with TableInfo<$AchievementsTable, Achievement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AchievementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _goalIdMeta = const VerificationMeta('goalId');
  @override
  late final GeneratedColumn<int> goalId = GeneratedColumn<int>(
    'goal_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _goalNameMeta = const VerificationMeta(
    'goalName',
  );
  @override
  late final GeneratedColumn<String> goalName = GeneratedColumn<String>(
    'goal_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 32,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetFenMeta = const VerificationMeta(
    'targetFen',
  );
  @override
  late final GeneratedColumn<int> targetFen = GeneratedColumn<int>(
    'target_fen',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _convertibleFenMeta = const VerificationMeta(
    'convertibleFen',
  );
  @override
  late final GeneratedColumn<int> convertibleFen = GeneratedColumn<int>(
    'convertible_fen',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tierMeta = const VerificationMeta('tier');
  @override
  late final GeneratedColumn<String> tier = GeneratedColumn<String>(
    'tier',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _unlockedAtMeta = const VerificationMeta(
    'unlockedAt',
  );
  @override
  late final GeneratedColumn<DateTime> unlockedAt = GeneratedColumn<DateTime>(
    'unlocked_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    goalId,
    goalName,
    targetFen,
    convertibleFen,
    tier,
    unlockedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'achievements';
  @override
  VerificationContext validateIntegrity(
    Insertable<Achievement> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('goal_id')) {
      context.handle(
        _goalIdMeta,
        goalId.isAcceptableOrUnknown(data['goal_id']!, _goalIdMeta),
      );
    } else if (isInserting) {
      context.missing(_goalIdMeta);
    }
    if (data.containsKey('goal_name')) {
      context.handle(
        _goalNameMeta,
        goalName.isAcceptableOrUnknown(data['goal_name']!, _goalNameMeta),
      );
    } else if (isInserting) {
      context.missing(_goalNameMeta);
    }
    if (data.containsKey('target_fen')) {
      context.handle(
        _targetFenMeta,
        targetFen.isAcceptableOrUnknown(data['target_fen']!, _targetFenMeta),
      );
    } else if (isInserting) {
      context.missing(_targetFenMeta);
    }
    if (data.containsKey('convertible_fen')) {
      context.handle(
        _convertibleFenMeta,
        convertibleFen.isAcceptableOrUnknown(
          data['convertible_fen']!,
          _convertibleFenMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_convertibleFenMeta);
    }
    if (data.containsKey('tier')) {
      context.handle(
        _tierMeta,
        tier.isAcceptableOrUnknown(data['tier']!, _tierMeta),
      );
    }
    if (data.containsKey('unlocked_at')) {
      context.handle(
        _unlockedAtMeta,
        unlockedAt.isAcceptableOrUnknown(data['unlocked_at']!, _unlockedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Achievement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Achievement(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      goalId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}goal_id'],
      )!,
      goalName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}goal_name'],
      )!,
      targetFen: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_fen'],
      )!,
      convertibleFen: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}convertible_fen'],
      )!,
      tier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tier'],
      )!,
      unlockedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}unlocked_at'],
      )!,
    );
  }

  @override
  $AchievementsTable createAlias(String alias) {
    return $AchievementsTable(attachedDatabase, alias);
  }
}

class Achievement extends DataClass implements Insertable<Achievement> {
  final int id;
  final int goalId;
  final String goalName;
  final int targetFen;
  final int convertibleFen;
  final String tier;
  final DateTime unlockedAt;
  const Achievement({
    required this.id,
    required this.goalId,
    required this.goalName,
    required this.targetFen,
    required this.convertibleFen,
    required this.tier,
    required this.unlockedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['goal_id'] = Variable<int>(goalId);
    map['goal_name'] = Variable<String>(goalName);
    map['target_fen'] = Variable<int>(targetFen);
    map['convertible_fen'] = Variable<int>(convertibleFen);
    map['tier'] = Variable<String>(tier);
    map['unlocked_at'] = Variable<DateTime>(unlockedAt);
    return map;
  }

  AchievementsCompanion toCompanion(bool nullToAbsent) {
    return AchievementsCompanion(
      id: Value(id),
      goalId: Value(goalId),
      goalName: Value(goalName),
      targetFen: Value(targetFen),
      convertibleFen: Value(convertibleFen),
      tier: Value(tier),
      unlockedAt: Value(unlockedAt),
    );
  }

  factory Achievement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Achievement(
      id: serializer.fromJson<int>(json['id']),
      goalId: serializer.fromJson<int>(json['goalId']),
      goalName: serializer.fromJson<String>(json['goalName']),
      targetFen: serializer.fromJson<int>(json['targetFen']),
      convertibleFen: serializer.fromJson<int>(json['convertibleFen']),
      tier: serializer.fromJson<String>(json['tier']),
      unlockedAt: serializer.fromJson<DateTime>(json['unlockedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'goalId': serializer.toJson<int>(goalId),
      'goalName': serializer.toJson<String>(goalName),
      'targetFen': serializer.toJson<int>(targetFen),
      'convertibleFen': serializer.toJson<int>(convertibleFen),
      'tier': serializer.toJson<String>(tier),
      'unlockedAt': serializer.toJson<DateTime>(unlockedAt),
    };
  }

  Achievement copyWith({
    int? id,
    int? goalId,
    String? goalName,
    int? targetFen,
    int? convertibleFen,
    String? tier,
    DateTime? unlockedAt,
  }) => Achievement(
    id: id ?? this.id,
    goalId: goalId ?? this.goalId,
    goalName: goalName ?? this.goalName,
    targetFen: targetFen ?? this.targetFen,
    convertibleFen: convertibleFen ?? this.convertibleFen,
    tier: tier ?? this.tier,
    unlockedAt: unlockedAt ?? this.unlockedAt,
  );
  Achievement copyWithCompanion(AchievementsCompanion data) {
    return Achievement(
      id: data.id.present ? data.id.value : this.id,
      goalId: data.goalId.present ? data.goalId.value : this.goalId,
      goalName: data.goalName.present ? data.goalName.value : this.goalName,
      targetFen: data.targetFen.present ? data.targetFen.value : this.targetFen,
      convertibleFen: data.convertibleFen.present
          ? data.convertibleFen.value
          : this.convertibleFen,
      tier: data.tier.present ? data.tier.value : this.tier,
      unlockedAt: data.unlockedAt.present
          ? data.unlockedAt.value
          : this.unlockedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Achievement(')
          ..write('id: $id, ')
          ..write('goalId: $goalId, ')
          ..write('goalName: $goalName, ')
          ..write('targetFen: $targetFen, ')
          ..write('convertibleFen: $convertibleFen, ')
          ..write('tier: $tier, ')
          ..write('unlockedAt: $unlockedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    goalId,
    goalName,
    targetFen,
    convertibleFen,
    tier,
    unlockedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Achievement &&
          other.id == this.id &&
          other.goalId == this.goalId &&
          other.goalName == this.goalName &&
          other.targetFen == this.targetFen &&
          other.convertibleFen == this.convertibleFen &&
          other.tier == this.tier &&
          other.unlockedAt == this.unlockedAt);
}

class AchievementsCompanion extends UpdateCompanion<Achievement> {
  final Value<int> id;
  final Value<int> goalId;
  final Value<String> goalName;
  final Value<int> targetFen;
  final Value<int> convertibleFen;
  final Value<String> tier;
  final Value<DateTime> unlockedAt;
  const AchievementsCompanion({
    this.id = const Value.absent(),
    this.goalId = const Value.absent(),
    this.goalName = const Value.absent(),
    this.targetFen = const Value.absent(),
    this.convertibleFen = const Value.absent(),
    this.tier = const Value.absent(),
    this.unlockedAt = const Value.absent(),
  });
  AchievementsCompanion.insert({
    this.id = const Value.absent(),
    required int goalId,
    required String goalName,
    required int targetFen,
    required int convertibleFen,
    this.tier = const Value.absent(),
    this.unlockedAt = const Value.absent(),
  }) : goalId = Value(goalId),
       goalName = Value(goalName),
       targetFen = Value(targetFen),
       convertibleFen = Value(convertibleFen);
  static Insertable<Achievement> custom({
    Expression<int>? id,
    Expression<int>? goalId,
    Expression<String>? goalName,
    Expression<int>? targetFen,
    Expression<int>? convertibleFen,
    Expression<String>? tier,
    Expression<DateTime>? unlockedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (goalId != null) 'goal_id': goalId,
      if (goalName != null) 'goal_name': goalName,
      if (targetFen != null) 'target_fen': targetFen,
      if (convertibleFen != null) 'convertible_fen': convertibleFen,
      if (tier != null) 'tier': tier,
      if (unlockedAt != null) 'unlocked_at': unlockedAt,
    });
  }

  AchievementsCompanion copyWith({
    Value<int>? id,
    Value<int>? goalId,
    Value<String>? goalName,
    Value<int>? targetFen,
    Value<int>? convertibleFen,
    Value<String>? tier,
    Value<DateTime>? unlockedAt,
  }) {
    return AchievementsCompanion(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      goalName: goalName ?? this.goalName,
      targetFen: targetFen ?? this.targetFen,
      convertibleFen: convertibleFen ?? this.convertibleFen,
      tier: tier ?? this.tier,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (goalId.present) {
      map['goal_id'] = Variable<int>(goalId.value);
    }
    if (goalName.present) {
      map['goal_name'] = Variable<String>(goalName.value);
    }
    if (targetFen.present) {
      map['target_fen'] = Variable<int>(targetFen.value);
    }
    if (convertibleFen.present) {
      map['convertible_fen'] = Variable<int>(convertibleFen.value);
    }
    if (tier.present) {
      map['tier'] = Variable<String>(tier.value);
    }
    if (unlockedAt.present) {
      map['unlocked_at'] = Variable<DateTime>(unlockedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AchievementsCompanion(')
          ..write('id: $id, ')
          ..write('goalId: $goalId, ')
          ..write('goalName: $goalName, ')
          ..write('targetFen: $targetFen, ')
          ..write('convertibleFen: $convertibleFen, ')
          ..write('tier: $tier, ')
          ..write('unlockedAt: $unlockedAt')
          ..write(')'))
        .toString();
  }
}

class $SafetyPadTable extends SafetyPad
    with TableInfo<$SafetyPadTable, SafetyPadData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SafetyPadTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _targetMonthsMeta = const VerificationMeta(
    'targetMonths',
  );
  @override
  late final GeneratedColumn<int> targetMonths = GeneratedColumn<int>(
    'target_months',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(6),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, targetMonths, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'safety_pad';
  @override
  VerificationContext validateIntegrity(
    Insertable<SafetyPadData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('target_months')) {
      context.handle(
        _targetMonthsMeta,
        targetMonths.isAcceptableOrUnknown(
          data['target_months']!,
          _targetMonthsMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SafetyPadData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SafetyPadData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      targetMonths: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_months'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SafetyPadTable createAlias(String alias) {
    return $SafetyPadTable(attachedDatabase, alias);
  }
}

class SafetyPadData extends DataClass implements Insertable<SafetyPadData> {
  final int id;
  final int targetMonths;
  final DateTime updatedAt;
  const SafetyPadData({
    required this.id,
    required this.targetMonths,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['target_months'] = Variable<int>(targetMonths);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SafetyPadCompanion toCompanion(bool nullToAbsent) {
    return SafetyPadCompanion(
      id: Value(id),
      targetMonths: Value(targetMonths),
      updatedAt: Value(updatedAt),
    );
  }

  factory SafetyPadData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SafetyPadData(
      id: serializer.fromJson<int>(json['id']),
      targetMonths: serializer.fromJson<int>(json['targetMonths']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'targetMonths': serializer.toJson<int>(targetMonths),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SafetyPadData copyWith({int? id, int? targetMonths, DateTime? updatedAt}) =>
      SafetyPadData(
        id: id ?? this.id,
        targetMonths: targetMonths ?? this.targetMonths,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  SafetyPadData copyWithCompanion(SafetyPadCompanion data) {
    return SafetyPadData(
      id: data.id.present ? data.id.value : this.id,
      targetMonths: data.targetMonths.present
          ? data.targetMonths.value
          : this.targetMonths,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SafetyPadData(')
          ..write('id: $id, ')
          ..write('targetMonths: $targetMonths, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, targetMonths, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SafetyPadData &&
          other.id == this.id &&
          other.targetMonths == this.targetMonths &&
          other.updatedAt == this.updatedAt);
}

class SafetyPadCompanion extends UpdateCompanion<SafetyPadData> {
  final Value<int> id;
  final Value<int> targetMonths;
  final Value<DateTime> updatedAt;
  const SafetyPadCompanion({
    this.id = const Value.absent(),
    this.targetMonths = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  SafetyPadCompanion.insert({
    this.id = const Value.absent(),
    this.targetMonths = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  static Insertable<SafetyPadData> custom({
    Expression<int>? id,
    Expression<int>? targetMonths,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (targetMonths != null) 'target_months': targetMonths,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  SafetyPadCompanion copyWith({
    Value<int>? id,
    Value<int>? targetMonths,
    Value<DateTime>? updatedAt,
  }) {
    return SafetyPadCompanion(
      id: id ?? this.id,
      targetMonths: targetMonths ?? this.targetMonths,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (targetMonths.present) {
      map['target_months'] = Variable<int>(targetMonths.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SafetyPadCompanion(')
          ..write('id: $id, ')
          ..write('targetMonths: $targetMonths, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $WeeklyReportsTable extends WeeklyReports
    with TableInfo<$WeeklyReportsTable, WeeklyReport> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WeeklyReportsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _weekStartMeta = const VerificationMeta(
    'weekStart',
  );
  @override
  late final GeneratedColumn<DateTime> weekStart = GeneratedColumn<DateTime>(
    'week_start',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _spendFenMeta = const VerificationMeta(
    'spendFen',
  );
  @override
  late final GeneratedColumn<int> spendFen = GeneratedColumn<int>(
    'spend_fen',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _incomeFenMeta = const VerificationMeta(
    'incomeFen',
  );
  @override
  late final GeneratedColumn<int> incomeFen = GeneratedColumn<int>(
    'income_fen',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _savedFenMeta = const VerificationMeta(
    'savedFen',
  );
  @override
  late final GeneratedColumn<int> savedFen = GeneratedColumn<int>(
    'saved_fen',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _topJsonMeta = const VerificationMeta(
    'topJson',
  );
  @override
  late final GeneratedColumn<String> topJson = GeneratedColumn<String>(
    'top_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _momDeltaFenMeta = const VerificationMeta(
    'momDeltaFen',
  );
  @override
  late final GeneratedColumn<int> momDeltaFen = GeneratedColumn<int>(
    'mom_delta_fen',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    weekStart,
    spendFen,
    incomeFen,
    savedFen,
    topJson,
    momDeltaFen,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'weekly_reports';
  @override
  VerificationContext validateIntegrity(
    Insertable<WeeklyReport> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('week_start')) {
      context.handle(
        _weekStartMeta,
        weekStart.isAcceptableOrUnknown(data['week_start']!, _weekStartMeta),
      );
    } else if (isInserting) {
      context.missing(_weekStartMeta);
    }
    if (data.containsKey('spend_fen')) {
      context.handle(
        _spendFenMeta,
        spendFen.isAcceptableOrUnknown(data['spend_fen']!, _spendFenMeta),
      );
    }
    if (data.containsKey('income_fen')) {
      context.handle(
        _incomeFenMeta,
        incomeFen.isAcceptableOrUnknown(data['income_fen']!, _incomeFenMeta),
      );
    }
    if (data.containsKey('saved_fen')) {
      context.handle(
        _savedFenMeta,
        savedFen.isAcceptableOrUnknown(data['saved_fen']!, _savedFenMeta),
      );
    }
    if (data.containsKey('top_json')) {
      context.handle(
        _topJsonMeta,
        topJson.isAcceptableOrUnknown(data['top_json']!, _topJsonMeta),
      );
    }
    if (data.containsKey('mom_delta_fen')) {
      context.handle(
        _momDeltaFenMeta,
        momDeltaFen.isAcceptableOrUnknown(
          data['mom_delta_fen']!,
          _momDeltaFenMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WeeklyReport map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WeeklyReport(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      weekStart: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}week_start'],
      )!,
      spendFen: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}spend_fen'],
      )!,
      incomeFen: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}income_fen'],
      )!,
      savedFen: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}saved_fen'],
      )!,
      topJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}top_json'],
      )!,
      momDeltaFen: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mom_delta_fen'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $WeeklyReportsTable createAlias(String alias) {
    return $WeeklyReportsTable(attachedDatabase, alias);
  }
}

class WeeklyReport extends DataClass implements Insertable<WeeklyReport> {
  final int id;
  final DateTime weekStart;
  final int spendFen;
  final int incomeFen;
  final int savedFen;
  final String topJson;
  final int momDeltaFen;
  final DateTime createdAt;
  const WeeklyReport({
    required this.id,
    required this.weekStart,
    required this.spendFen,
    required this.incomeFen,
    required this.savedFen,
    required this.topJson,
    required this.momDeltaFen,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['week_start'] = Variable<DateTime>(weekStart);
    map['spend_fen'] = Variable<int>(spendFen);
    map['income_fen'] = Variable<int>(incomeFen);
    map['saved_fen'] = Variable<int>(savedFen);
    map['top_json'] = Variable<String>(topJson);
    map['mom_delta_fen'] = Variable<int>(momDeltaFen);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  WeeklyReportsCompanion toCompanion(bool nullToAbsent) {
    return WeeklyReportsCompanion(
      id: Value(id),
      weekStart: Value(weekStart),
      spendFen: Value(spendFen),
      incomeFen: Value(incomeFen),
      savedFen: Value(savedFen),
      topJson: Value(topJson),
      momDeltaFen: Value(momDeltaFen),
      createdAt: Value(createdAt),
    );
  }

  factory WeeklyReport.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WeeklyReport(
      id: serializer.fromJson<int>(json['id']),
      weekStart: serializer.fromJson<DateTime>(json['weekStart']),
      spendFen: serializer.fromJson<int>(json['spendFen']),
      incomeFen: serializer.fromJson<int>(json['incomeFen']),
      savedFen: serializer.fromJson<int>(json['savedFen']),
      topJson: serializer.fromJson<String>(json['topJson']),
      momDeltaFen: serializer.fromJson<int>(json['momDeltaFen']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'weekStart': serializer.toJson<DateTime>(weekStart),
      'spendFen': serializer.toJson<int>(spendFen),
      'incomeFen': serializer.toJson<int>(incomeFen),
      'savedFen': serializer.toJson<int>(savedFen),
      'topJson': serializer.toJson<String>(topJson),
      'momDeltaFen': serializer.toJson<int>(momDeltaFen),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  WeeklyReport copyWith({
    int? id,
    DateTime? weekStart,
    int? spendFen,
    int? incomeFen,
    int? savedFen,
    String? topJson,
    int? momDeltaFen,
    DateTime? createdAt,
  }) => WeeklyReport(
    id: id ?? this.id,
    weekStart: weekStart ?? this.weekStart,
    spendFen: spendFen ?? this.spendFen,
    incomeFen: incomeFen ?? this.incomeFen,
    savedFen: savedFen ?? this.savedFen,
    topJson: topJson ?? this.topJson,
    momDeltaFen: momDeltaFen ?? this.momDeltaFen,
    createdAt: createdAt ?? this.createdAt,
  );
  WeeklyReport copyWithCompanion(WeeklyReportsCompanion data) {
    return WeeklyReport(
      id: data.id.present ? data.id.value : this.id,
      weekStart: data.weekStart.present ? data.weekStart.value : this.weekStart,
      spendFen: data.spendFen.present ? data.spendFen.value : this.spendFen,
      incomeFen: data.incomeFen.present ? data.incomeFen.value : this.incomeFen,
      savedFen: data.savedFen.present ? data.savedFen.value : this.savedFen,
      topJson: data.topJson.present ? data.topJson.value : this.topJson,
      momDeltaFen: data.momDeltaFen.present
          ? data.momDeltaFen.value
          : this.momDeltaFen,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WeeklyReport(')
          ..write('id: $id, ')
          ..write('weekStart: $weekStart, ')
          ..write('spendFen: $spendFen, ')
          ..write('incomeFen: $incomeFen, ')
          ..write('savedFen: $savedFen, ')
          ..write('topJson: $topJson, ')
          ..write('momDeltaFen: $momDeltaFen, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    weekStart,
    spendFen,
    incomeFen,
    savedFen,
    topJson,
    momDeltaFen,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WeeklyReport &&
          other.id == this.id &&
          other.weekStart == this.weekStart &&
          other.spendFen == this.spendFen &&
          other.incomeFen == this.incomeFen &&
          other.savedFen == this.savedFen &&
          other.topJson == this.topJson &&
          other.momDeltaFen == this.momDeltaFen &&
          other.createdAt == this.createdAt);
}

class WeeklyReportsCompanion extends UpdateCompanion<WeeklyReport> {
  final Value<int> id;
  final Value<DateTime> weekStart;
  final Value<int> spendFen;
  final Value<int> incomeFen;
  final Value<int> savedFen;
  final Value<String> topJson;
  final Value<int> momDeltaFen;
  final Value<DateTime> createdAt;
  const WeeklyReportsCompanion({
    this.id = const Value.absent(),
    this.weekStart = const Value.absent(),
    this.spendFen = const Value.absent(),
    this.incomeFen = const Value.absent(),
    this.savedFen = const Value.absent(),
    this.topJson = const Value.absent(),
    this.momDeltaFen = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  WeeklyReportsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime weekStart,
    this.spendFen = const Value.absent(),
    this.incomeFen = const Value.absent(),
    this.savedFen = const Value.absent(),
    this.topJson = const Value.absent(),
    this.momDeltaFen = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : weekStart = Value(weekStart);
  static Insertable<WeeklyReport> custom({
    Expression<int>? id,
    Expression<DateTime>? weekStart,
    Expression<int>? spendFen,
    Expression<int>? incomeFen,
    Expression<int>? savedFen,
    Expression<String>? topJson,
    Expression<int>? momDeltaFen,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (weekStart != null) 'week_start': weekStart,
      if (spendFen != null) 'spend_fen': spendFen,
      if (incomeFen != null) 'income_fen': incomeFen,
      if (savedFen != null) 'saved_fen': savedFen,
      if (topJson != null) 'top_json': topJson,
      if (momDeltaFen != null) 'mom_delta_fen': momDeltaFen,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  WeeklyReportsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? weekStart,
    Value<int>? spendFen,
    Value<int>? incomeFen,
    Value<int>? savedFen,
    Value<String>? topJson,
    Value<int>? momDeltaFen,
    Value<DateTime>? createdAt,
  }) {
    return WeeklyReportsCompanion(
      id: id ?? this.id,
      weekStart: weekStart ?? this.weekStart,
      spendFen: spendFen ?? this.spendFen,
      incomeFen: incomeFen ?? this.incomeFen,
      savedFen: savedFen ?? this.savedFen,
      topJson: topJson ?? this.topJson,
      momDeltaFen: momDeltaFen ?? this.momDeltaFen,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (weekStart.present) {
      map['week_start'] = Variable<DateTime>(weekStart.value);
    }
    if (spendFen.present) {
      map['spend_fen'] = Variable<int>(spendFen.value);
    }
    if (incomeFen.present) {
      map['income_fen'] = Variable<int>(incomeFen.value);
    }
    if (savedFen.present) {
      map['saved_fen'] = Variable<int>(savedFen.value);
    }
    if (topJson.present) {
      map['top_json'] = Variable<String>(topJson.value);
    }
    if (momDeltaFen.present) {
      map['mom_delta_fen'] = Variable<int>(momDeltaFen.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WeeklyReportsCompanion(')
          ..write('id: $id, ')
          ..write('weekStart: $weekStart, ')
          ..write('spendFen: $spendFen, ')
          ..write('incomeFen: $incomeFen, ')
          ..write('savedFen: $savedFen, ')
          ..write('topJson: $topJson, ')
          ..write('momDeltaFen: $momDeltaFen, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDb extends GeneratedDatabase {
  _$AppDb(QueryExecutor e) : super(e);
  $AppDbManager get managers => $AppDbManager(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $GoalsTable goals = $GoalsTable(this);
  late final $AchievementsTable achievements = $AchievementsTable(this);
  late final $SafetyPadTable safetyPad = $SafetyPadTable(this);
  late final $WeeklyReportsTable weeklyReports = $WeeklyReportsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    transactions,
    goals,
    achievements,
    safetyPad,
    weeklyReports,
  ];
}

typedef $$TransactionsTableCreateCompanionBuilder =
    TransactionsCompanion Function({
      Value<int> id,
      required int amountFen,
      required DateTime occurredAt,
      required String category,
      Value<String> note,
      Value<String> source,
    });
typedef $$TransactionsTableUpdateCompanionBuilder =
    TransactionsCompanion Function({
      Value<int> id,
      Value<int> amountFen,
      Value<DateTime> occurredAt,
      Value<String> category,
      Value<String> note,
      Value<String> source,
    });

class $$TransactionsTableFilterComposer
    extends Composer<_$AppDb, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountFen => $composableBuilder(
    column: $table.amountFen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$AppDb, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountFen => $composableBuilder(
    column: $table.amountFen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$AppDb, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get amountFen =>
      $composableBuilder(column: $table.amountFen, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);
}

class $$TransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $TransactionsTable,
          Transaction,
          $$TransactionsTableFilterComposer,
          $$TransactionsTableOrderingComposer,
          $$TransactionsTableAnnotationComposer,
          $$TransactionsTableCreateCompanionBuilder,
          $$TransactionsTableUpdateCompanionBuilder,
          (
            Transaction,
            BaseReferences<_$AppDb, $TransactionsTable, Transaction>,
          ),
          Transaction,
          PrefetchHooks Function()
        > {
  $$TransactionsTableTableManager(_$AppDb db, $TransactionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> amountFen = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<String> source = const Value.absent(),
              }) => TransactionsCompanion(
                id: id,
                amountFen: amountFen,
                occurredAt: occurredAt,
                category: category,
                note: note,
                source: source,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int amountFen,
                required DateTime occurredAt,
                required String category,
                Value<String> note = const Value.absent(),
                Value<String> source = const Value.absent(),
              }) => TransactionsCompanion.insert(
                id: id,
                amountFen: amountFen,
                occurredAt: occurredAt,
                category: category,
                note: note,
                source: source,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TransactionsTable, Transaction>(table),
                  BaseReferences<_$AppDb, $TransactionsTable, Transaction>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $TransactionsTable,
      Transaction,
      $$TransactionsTableFilterComposer,
      $$TransactionsTableOrderingComposer,
      $$TransactionsTableAnnotationComposer,
      $$TransactionsTableCreateCompanionBuilder,
      $$TransactionsTableUpdateCompanionBuilder,
      (Transaction, BaseReferences<_$AppDb, $TransactionsTable, Transaction>),
      Transaction,
      PrefetchHooks Function()
    >;
typedef $$GoalsTableCreateCompanionBuilder =
    GoalsCompanion Function({
      Value<int> id,
      required String name,
      required int targetFen,
      required String priceName,
      required int priceFen,
      Value<String?> tier,
      Value<DateTime?> doneAt,
      Value<DateTime> createdAt,
    });
typedef $$GoalsTableUpdateCompanionBuilder =
    GoalsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> targetFen,
      Value<String> priceName,
      Value<int> priceFen,
      Value<String?> tier,
      Value<DateTime?> doneAt,
      Value<DateTime> createdAt,
    });

class $$GoalsTableFilterComposer extends Composer<_$AppDb, $GoalsTable> {
  $$GoalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetFen => $composableBuilder(
    column: $table.targetFen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get priceName => $composableBuilder(
    column: $table.priceName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priceFen => $composableBuilder(
    column: $table.priceFen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tier => $composableBuilder(
    column: $table.tier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get doneAt => $composableBuilder(
    column: $table.doneAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GoalsTableOrderingComposer extends Composer<_$AppDb, $GoalsTable> {
  $$GoalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetFen => $composableBuilder(
    column: $table.targetFen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get priceName => $composableBuilder(
    column: $table.priceName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priceFen => $composableBuilder(
    column: $table.priceFen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tier => $composableBuilder(
    column: $table.tier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get doneAt => $composableBuilder(
    column: $table.doneAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GoalsTableAnnotationComposer extends Composer<_$AppDb, $GoalsTable> {
  $$GoalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get targetFen =>
      $composableBuilder(column: $table.targetFen, builder: (column) => column);

  GeneratedColumn<String> get priceName =>
      $composableBuilder(column: $table.priceName, builder: (column) => column);

  GeneratedColumn<int> get priceFen =>
      $composableBuilder(column: $table.priceFen, builder: (column) => column);

  GeneratedColumn<String> get tier =>
      $composableBuilder(column: $table.tier, builder: (column) => column);

  GeneratedColumn<DateTime> get doneAt =>
      $composableBuilder(column: $table.doneAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$GoalsTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $GoalsTable,
          Goal,
          $$GoalsTableFilterComposer,
          $$GoalsTableOrderingComposer,
          $$GoalsTableAnnotationComposer,
          $$GoalsTableCreateCompanionBuilder,
          $$GoalsTableUpdateCompanionBuilder,
          (Goal, BaseReferences<_$AppDb, $GoalsTable, Goal>),
          Goal,
          PrefetchHooks Function()
        > {
  $$GoalsTableTableManager(_$AppDb db, $GoalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GoalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GoalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GoalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> targetFen = const Value.absent(),
                Value<String> priceName = const Value.absent(),
                Value<int> priceFen = const Value.absent(),
                Value<String?> tier = const Value.absent(),
                Value<DateTime?> doneAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => GoalsCompanion(
                id: id,
                name: name,
                targetFen: targetFen,
                priceName: priceName,
                priceFen: priceFen,
                tier: tier,
                doneAt: doneAt,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required int targetFen,
                required String priceName,
                required int priceFen,
                Value<String?> tier = const Value.absent(),
                Value<DateTime?> doneAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => GoalsCompanion.insert(
                id: id,
                name: name,
                targetFen: targetFen,
                priceName: priceName,
                priceFen: priceFen,
                tier: tier,
                doneAt: doneAt,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$GoalsTable, Goal>(table),
                  BaseReferences<_$AppDb, $GoalsTable, Goal>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GoalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $GoalsTable,
      Goal,
      $$GoalsTableFilterComposer,
      $$GoalsTableOrderingComposer,
      $$GoalsTableAnnotationComposer,
      $$GoalsTableCreateCompanionBuilder,
      $$GoalsTableUpdateCompanionBuilder,
      (Goal, BaseReferences<_$AppDb, $GoalsTable, Goal>),
      Goal,
      PrefetchHooks Function()
    >;
typedef $$AchievementsTableCreateCompanionBuilder =
    AchievementsCompanion Function({
      Value<int> id,
      required int goalId,
      required String goalName,
      required int targetFen,
      required int convertibleFen,
      Value<String> tier,
      Value<DateTime> unlockedAt,
    });
typedef $$AchievementsTableUpdateCompanionBuilder =
    AchievementsCompanion Function({
      Value<int> id,
      Value<int> goalId,
      Value<String> goalName,
      Value<int> targetFen,
      Value<int> convertibleFen,
      Value<String> tier,
      Value<DateTime> unlockedAt,
    });

class $$AchievementsTableFilterComposer
    extends Composer<_$AppDb, $AchievementsTable> {
  $$AchievementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get goalId => $composableBuilder(
    column: $table.goalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get goalName => $composableBuilder(
    column: $table.goalName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetFen => $composableBuilder(
    column: $table.targetFen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get convertibleFen => $composableBuilder(
    column: $table.convertibleFen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tier => $composableBuilder(
    column: $table.tier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AchievementsTableOrderingComposer
    extends Composer<_$AppDb, $AchievementsTable> {
  $$AchievementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get goalId => $composableBuilder(
    column: $table.goalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get goalName => $composableBuilder(
    column: $table.goalName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetFen => $composableBuilder(
    column: $table.targetFen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get convertibleFen => $composableBuilder(
    column: $table.convertibleFen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tier => $composableBuilder(
    column: $table.tier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AchievementsTableAnnotationComposer
    extends Composer<_$AppDb, $AchievementsTable> {
  $$AchievementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get goalId =>
      $composableBuilder(column: $table.goalId, builder: (column) => column);

  GeneratedColumn<String> get goalName =>
      $composableBuilder(column: $table.goalName, builder: (column) => column);

  GeneratedColumn<int> get targetFen =>
      $composableBuilder(column: $table.targetFen, builder: (column) => column);

  GeneratedColumn<int> get convertibleFen => $composableBuilder(
    column: $table.convertibleFen,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tier =>
      $composableBuilder(column: $table.tier, builder: (column) => column);

  GeneratedColumn<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => column,
  );
}

class $$AchievementsTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $AchievementsTable,
          Achievement,
          $$AchievementsTableFilterComposer,
          $$AchievementsTableOrderingComposer,
          $$AchievementsTableAnnotationComposer,
          $$AchievementsTableCreateCompanionBuilder,
          $$AchievementsTableUpdateCompanionBuilder,
          (
            Achievement,
            BaseReferences<_$AppDb, $AchievementsTable, Achievement>,
          ),
          Achievement,
          PrefetchHooks Function()
        > {
  $$AchievementsTableTableManager(_$AppDb db, $AchievementsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AchievementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AchievementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AchievementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> goalId = const Value.absent(),
                Value<String> goalName = const Value.absent(),
                Value<int> targetFen = const Value.absent(),
                Value<int> convertibleFen = const Value.absent(),
                Value<String> tier = const Value.absent(),
                Value<DateTime> unlockedAt = const Value.absent(),
              }) => AchievementsCompanion(
                id: id,
                goalId: goalId,
                goalName: goalName,
                targetFen: targetFen,
                convertibleFen: convertibleFen,
                tier: tier,
                unlockedAt: unlockedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int goalId,
                required String goalName,
                required int targetFen,
                required int convertibleFen,
                Value<String> tier = const Value.absent(),
                Value<DateTime> unlockedAt = const Value.absent(),
              }) => AchievementsCompanion.insert(
                id: id,
                goalId: goalId,
                goalName: goalName,
                targetFen: targetFen,
                convertibleFen: convertibleFen,
                tier: tier,
                unlockedAt: unlockedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AchievementsTable, Achievement>(table),
                  BaseReferences<_$AppDb, $AchievementsTable, Achievement>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AchievementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $AchievementsTable,
      Achievement,
      $$AchievementsTableFilterComposer,
      $$AchievementsTableOrderingComposer,
      $$AchievementsTableAnnotationComposer,
      $$AchievementsTableCreateCompanionBuilder,
      $$AchievementsTableUpdateCompanionBuilder,
      (Achievement, BaseReferences<_$AppDb, $AchievementsTable, Achievement>),
      Achievement,
      PrefetchHooks Function()
    >;
typedef $$SafetyPadTableCreateCompanionBuilder =
    SafetyPadCompanion Function({
      Value<int> id,
      Value<int> targetMonths,
      Value<DateTime> updatedAt,
    });
typedef $$SafetyPadTableUpdateCompanionBuilder =
    SafetyPadCompanion Function({
      Value<int> id,
      Value<int> targetMonths,
      Value<DateTime> updatedAt,
    });

class $$SafetyPadTableFilterComposer
    extends Composer<_$AppDb, $SafetyPadTable> {
  $$SafetyPadTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetMonths => $composableBuilder(
    column: $table.targetMonths,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SafetyPadTableOrderingComposer
    extends Composer<_$AppDb, $SafetyPadTable> {
  $$SafetyPadTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetMonths => $composableBuilder(
    column: $table.targetMonths,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SafetyPadTableAnnotationComposer
    extends Composer<_$AppDb, $SafetyPadTable> {
  $$SafetyPadTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get targetMonths => $composableBuilder(
    column: $table.targetMonths,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SafetyPadTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $SafetyPadTable,
          SafetyPadData,
          $$SafetyPadTableFilterComposer,
          $$SafetyPadTableOrderingComposer,
          $$SafetyPadTableAnnotationComposer,
          $$SafetyPadTableCreateCompanionBuilder,
          $$SafetyPadTableUpdateCompanionBuilder,
          (
            SafetyPadData,
            BaseReferences<_$AppDb, $SafetyPadTable, SafetyPadData>,
          ),
          SafetyPadData,
          PrefetchHooks Function()
        > {
  $$SafetyPadTableTableManager(_$AppDb db, $SafetyPadTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SafetyPadTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SafetyPadTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SafetyPadTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> targetMonths = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => SafetyPadCompanion(
                id: id,
                targetMonths: targetMonths,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> targetMonths = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => SafetyPadCompanion.insert(
                id: id,
                targetMonths: targetMonths,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SafetyPadTable, SafetyPadData>(table),
                  BaseReferences<_$AppDb, $SafetyPadTable, SafetyPadData>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SafetyPadTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $SafetyPadTable,
      SafetyPadData,
      $$SafetyPadTableFilterComposer,
      $$SafetyPadTableOrderingComposer,
      $$SafetyPadTableAnnotationComposer,
      $$SafetyPadTableCreateCompanionBuilder,
      $$SafetyPadTableUpdateCompanionBuilder,
      (SafetyPadData, BaseReferences<_$AppDb, $SafetyPadTable, SafetyPadData>),
      SafetyPadData,
      PrefetchHooks Function()
    >;
typedef $$WeeklyReportsTableCreateCompanionBuilder =
    WeeklyReportsCompanion Function({
      Value<int> id,
      required DateTime weekStart,
      Value<int> spendFen,
      Value<int> incomeFen,
      Value<int> savedFen,
      Value<String> topJson,
      Value<int> momDeltaFen,
      Value<DateTime> createdAt,
    });
typedef $$WeeklyReportsTableUpdateCompanionBuilder =
    WeeklyReportsCompanion Function({
      Value<int> id,
      Value<DateTime> weekStart,
      Value<int> spendFen,
      Value<int> incomeFen,
      Value<int> savedFen,
      Value<String> topJson,
      Value<int> momDeltaFen,
      Value<DateTime> createdAt,
    });

class $$WeeklyReportsTableFilterComposer
    extends Composer<_$AppDb, $WeeklyReportsTable> {
  $$WeeklyReportsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get weekStart => $composableBuilder(
    column: $table.weekStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get spendFen => $composableBuilder(
    column: $table.spendFen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get incomeFen => $composableBuilder(
    column: $table.incomeFen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get savedFen => $composableBuilder(
    column: $table.savedFen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get topJson => $composableBuilder(
    column: $table.topJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get momDeltaFen => $composableBuilder(
    column: $table.momDeltaFen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WeeklyReportsTableOrderingComposer
    extends Composer<_$AppDb, $WeeklyReportsTable> {
  $$WeeklyReportsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get weekStart => $composableBuilder(
    column: $table.weekStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get spendFen => $composableBuilder(
    column: $table.spendFen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get incomeFen => $composableBuilder(
    column: $table.incomeFen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get savedFen => $composableBuilder(
    column: $table.savedFen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get topJson => $composableBuilder(
    column: $table.topJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get momDeltaFen => $composableBuilder(
    column: $table.momDeltaFen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WeeklyReportsTableAnnotationComposer
    extends Composer<_$AppDb, $WeeklyReportsTable> {
  $$WeeklyReportsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get weekStart =>
      $composableBuilder(column: $table.weekStart, builder: (column) => column);

  GeneratedColumn<int> get spendFen =>
      $composableBuilder(column: $table.spendFen, builder: (column) => column);

  GeneratedColumn<int> get incomeFen =>
      $composableBuilder(column: $table.incomeFen, builder: (column) => column);

  GeneratedColumn<int> get savedFen =>
      $composableBuilder(column: $table.savedFen, builder: (column) => column);

  GeneratedColumn<String> get topJson =>
      $composableBuilder(column: $table.topJson, builder: (column) => column);

  GeneratedColumn<int> get momDeltaFen => $composableBuilder(
    column: $table.momDeltaFen,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$WeeklyReportsTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $WeeklyReportsTable,
          WeeklyReport,
          $$WeeklyReportsTableFilterComposer,
          $$WeeklyReportsTableOrderingComposer,
          $$WeeklyReportsTableAnnotationComposer,
          $$WeeklyReportsTableCreateCompanionBuilder,
          $$WeeklyReportsTableUpdateCompanionBuilder,
          (
            WeeklyReport,
            BaseReferences<_$AppDb, $WeeklyReportsTable, WeeklyReport>,
          ),
          WeeklyReport,
          PrefetchHooks Function()
        > {
  $$WeeklyReportsTableTableManager(_$AppDb db, $WeeklyReportsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WeeklyReportsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WeeklyReportsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WeeklyReportsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> weekStart = const Value.absent(),
                Value<int> spendFen = const Value.absent(),
                Value<int> incomeFen = const Value.absent(),
                Value<int> savedFen = const Value.absent(),
                Value<String> topJson = const Value.absent(),
                Value<int> momDeltaFen = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => WeeklyReportsCompanion(
                id: id,
                weekStart: weekStart,
                spendFen: spendFen,
                incomeFen: incomeFen,
                savedFen: savedFen,
                topJson: topJson,
                momDeltaFen: momDeltaFen,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime weekStart,
                Value<int> spendFen = const Value.absent(),
                Value<int> incomeFen = const Value.absent(),
                Value<int> savedFen = const Value.absent(),
                Value<String> topJson = const Value.absent(),
                Value<int> momDeltaFen = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => WeeklyReportsCompanion.insert(
                id: id,
                weekStart: weekStart,
                spendFen: spendFen,
                incomeFen: incomeFen,
                savedFen: savedFen,
                topJson: topJson,
                momDeltaFen: momDeltaFen,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WeeklyReportsTable, WeeklyReport>(table),
                  BaseReferences<_$AppDb, $WeeklyReportsTable, WeeklyReport>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WeeklyReportsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $WeeklyReportsTable,
      WeeklyReport,
      $$WeeklyReportsTableFilterComposer,
      $$WeeklyReportsTableOrderingComposer,
      $$WeeklyReportsTableAnnotationComposer,
      $$WeeklyReportsTableCreateCompanionBuilder,
      $$WeeklyReportsTableUpdateCompanionBuilder,
      (
        WeeklyReport,
        BaseReferences<_$AppDb, $WeeklyReportsTable, WeeklyReport>,
      ),
      WeeklyReport,
      PrefetchHooks Function()
    >;

class $AppDbManager {
  final _$AppDb _db;
  $AppDbManager(this._db);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$GoalsTableTableManager get goals =>
      $$GoalsTableTableManager(_db, _db.goals);
  $$AchievementsTableTableManager get achievements =>
      $$AchievementsTableTableManager(_db, _db.achievements);
  $$SafetyPadTableTableManager get safetyPad =>
      $$SafetyPadTableTableManager(_db, _db.safetyPad);
  $$WeeklyReportsTableTableManager get weeklyReports =>
      $$WeeklyReportsTableTableManager(_db, _db.weeklyReports);
}
