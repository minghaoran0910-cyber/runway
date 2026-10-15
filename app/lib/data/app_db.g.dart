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
  static const VerificationMeta _importBatchIdMeta = const VerificationMeta(
    'importBatchId',
  );
  @override
  late final GeneratedColumn<int> importBatchId = GeneratedColumn<int>(
    'import_batch_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    amountFen,
    occurredAt,
    category,
    note,
    source,
    importBatchId,
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
    if (data.containsKey('import_batch_id')) {
      context.handle(
        _importBatchIdMeta,
        importBatchId.isAcceptableOrUnknown(
          data['import_batch_id']!,
          _importBatchIdMeta,
        ),
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
      importBatchId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}import_batch_id'],
      ),
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
  final int? importBatchId;
  const Transaction({
    required this.id,
    required this.amountFen,
    required this.occurredAt,
    required this.category,
    required this.note,
    required this.source,
    this.importBatchId,
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
    if (!nullToAbsent || importBatchId != null) {
      map['import_batch_id'] = Variable<int>(importBatchId);
    }
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
      importBatchId: importBatchId == null && nullToAbsent
          ? const Value.absent()
          : Value(importBatchId),
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
      importBatchId: serializer.fromJson<int?>(json['importBatchId']),
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
      'importBatchId': serializer.toJson<int?>(importBatchId),
    };
  }

  Transaction copyWith({
    int? id,
    int? amountFen,
    DateTime? occurredAt,
    String? category,
    String? note,
    String? source,
    Value<int?> importBatchId = const Value.absent(),
  }) => Transaction(
    id: id ?? this.id,
    amountFen: amountFen ?? this.amountFen,
    occurredAt: occurredAt ?? this.occurredAt,
    category: category ?? this.category,
    note: note ?? this.note,
    source: source ?? this.source,
    importBatchId: importBatchId.present
        ? importBatchId.value
        : this.importBatchId,
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
      importBatchId: data.importBatchId.present
          ? data.importBatchId.value
          : this.importBatchId,
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
          ..write('source: $source, ')
          ..write('importBatchId: $importBatchId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    amountFen,
    occurredAt,
    category,
    note,
    source,
    importBatchId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transaction &&
          other.id == this.id &&
          other.amountFen == this.amountFen &&
          other.occurredAt == this.occurredAt &&
          other.category == this.category &&
          other.note == this.note &&
          other.source == this.source &&
          other.importBatchId == this.importBatchId);
}

class TransactionsCompanion extends UpdateCompanion<Transaction> {
  final Value<int> id;
  final Value<int> amountFen;
  final Value<DateTime> occurredAt;
  final Value<String> category;
  final Value<String> note;
  final Value<String> source;
  final Value<int?> importBatchId;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.amountFen = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.category = const Value.absent(),
    this.note = const Value.absent(),
    this.source = const Value.absent(),
    this.importBatchId = const Value.absent(),
  });
  TransactionsCompanion.insert({
    this.id = const Value.absent(),
    required int amountFen,
    required DateTime occurredAt,
    required String category,
    this.note = const Value.absent(),
    this.source = const Value.absent(),
    this.importBatchId = const Value.absent(),
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
    Expression<int>? importBatchId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (amountFen != null) 'amount_fen': amountFen,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (category != null) 'category': category,
      if (note != null) 'note': note,
      if (source != null) 'source': source,
      if (importBatchId != null) 'import_batch_id': importBatchId,
    });
  }

  TransactionsCompanion copyWith({
    Value<int>? id,
    Value<int>? amountFen,
    Value<DateTime>? occurredAt,
    Value<String>? category,
    Value<String>? note,
    Value<String>? source,
    Value<int?>? importBatchId,
  }) {
    return TransactionsCompanion(
      id: id ?? this.id,
      amountFen: amountFen ?? this.amountFen,
      occurredAt: occurredAt ?? this.occurredAt,
      category: category ?? this.category,
      note: note ?? this.note,
      source: source ?? this.source,
      importBatchId: importBatchId ?? this.importBatchId,
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
    if (importBatchId.present) {
      map['import_batch_id'] = Variable<int>(importBatchId.value);
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
          ..write('source: $source, ')
          ..write('importBatchId: $importBatchId')
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
  static const VerificationMeta _deadlineMeta = const VerificationMeta(
    'deadline',
  );
  @override
  late final GeneratedColumn<String> deadline = GeneratedColumn<String>(
    'deadline',
    aliasedName,
    true,
    type: DriftSqlType.string,
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
    deadline,
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
    if (data.containsKey('deadline')) {
      context.handle(
        _deadlineMeta,
        deadline.isAcceptableOrUnknown(data['deadline']!, _deadlineMeta),
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
      deadline: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deadline'],
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
  final String? deadline;
  final DateTime createdAt;
  const Goal({
    required this.id,
    required this.name,
    required this.targetFen,
    required this.priceName,
    required this.priceFen,
    this.tier,
    this.doneAt,
    this.deadline,
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
    if (!nullToAbsent || deadline != null) {
      map['deadline'] = Variable<String>(deadline);
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
      deadline: deadline == null && nullToAbsent
          ? const Value.absent()
          : Value(deadline),
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
      deadline: serializer.fromJson<String?>(json['deadline']),
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
      'deadline': serializer.toJson<String?>(deadline),
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
    Value<String?> deadline = const Value.absent(),
    DateTime? createdAt,
  }) => Goal(
    id: id ?? this.id,
    name: name ?? this.name,
    targetFen: targetFen ?? this.targetFen,
    priceName: priceName ?? this.priceName,
    priceFen: priceFen ?? this.priceFen,
    tier: tier.present ? tier.value : this.tier,
    doneAt: doneAt.present ? doneAt.value : this.doneAt,
    deadline: deadline.present ? deadline.value : this.deadline,
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
      deadline: data.deadline.present ? data.deadline.value : this.deadline,
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
          ..write('deadline: $deadline, ')
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
    deadline,
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
          other.deadline == this.deadline &&
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
  final Value<String?> deadline;
  final Value<DateTime> createdAt;
  const GoalsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.targetFen = const Value.absent(),
    this.priceName = const Value.absent(),
    this.priceFen = const Value.absent(),
    this.tier = const Value.absent(),
    this.doneAt = const Value.absent(),
    this.deadline = const Value.absent(),
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
    this.deadline = const Value.absent(),
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
    Expression<String>? deadline,
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
      if (deadline != null) 'deadline': deadline,
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
    Value<String?>? deadline,
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
      deadline: deadline ?? this.deadline,
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
    if (deadline.present) {
      map['deadline'] = Variable<String>(deadline.value);
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
          ..write('deadline: $deadline, ')
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

class $PendingRecordsTable extends PendingRecords
    with TableInfo<$PendingRecordsTable, PendingRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingRecordsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _merchantMeta = const VerificationMeta(
    'merchant',
  );
  @override
  late final GeneratedColumn<String> merchant = GeneratedColumn<String>(
    'merchant',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 64,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourcePkgMeta = const VerificationMeta(
    'sourcePkg',
  );
  @override
  late final GeneratedColumn<String> sourcePkg = GeneratedColumn<String>(
    'source_pkg',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _notifyKeyMeta = const VerificationMeta(
    'notifyKey',
  );
  @override
  late final GeneratedColumn<String> notifyKey = GeneratedColumn<String>(
    'notify_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
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
    amountFen,
    occurredAt,
    category,
    merchant,
    sourcePkg,
    notifyKey,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<PendingRecord> instance, {
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
    if (data.containsKey('merchant')) {
      context.handle(
        _merchantMeta,
        merchant.isAcceptableOrUnknown(data['merchant']!, _merchantMeta),
      );
    } else if (isInserting) {
      context.missing(_merchantMeta);
    }
    if (data.containsKey('source_pkg')) {
      context.handle(
        _sourcePkgMeta,
        sourcePkg.isAcceptableOrUnknown(data['source_pkg']!, _sourcePkgMeta),
      );
    }
    if (data.containsKey('notify_key')) {
      context.handle(
        _notifyKeyMeta,
        notifyKey.isAcceptableOrUnknown(data['notify_key']!, _notifyKeyMeta),
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
  PendingRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingRecord(
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
      merchant: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}merchant'],
      )!,
      sourcePkg: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_pkg'],
      )!,
      notifyKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notify_key'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PendingRecordsTable createAlias(String alias) {
    return $PendingRecordsTable(attachedDatabase, alias);
  }
}

class PendingRecord extends DataClass implements Insertable<PendingRecord> {
  final int id;
  final int amountFen;
  final DateTime occurredAt;
  final String category;
  final String merchant;
  final String sourcePkg;
  final String notifyKey;
  final DateTime createdAt;
  const PendingRecord({
    required this.id,
    required this.amountFen,
    required this.occurredAt,
    required this.category,
    required this.merchant,
    required this.sourcePkg,
    required this.notifyKey,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['amount_fen'] = Variable<int>(amountFen);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    map['category'] = Variable<String>(category);
    map['merchant'] = Variable<String>(merchant);
    map['source_pkg'] = Variable<String>(sourcePkg);
    map['notify_key'] = Variable<String>(notifyKey);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PendingRecordsCompanion toCompanion(bool nullToAbsent) {
    return PendingRecordsCompanion(
      id: Value(id),
      amountFen: Value(amountFen),
      occurredAt: Value(occurredAt),
      category: Value(category),
      merchant: Value(merchant),
      sourcePkg: Value(sourcePkg),
      notifyKey: Value(notifyKey),
      createdAt: Value(createdAt),
    );
  }

  factory PendingRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingRecord(
      id: serializer.fromJson<int>(json['id']),
      amountFen: serializer.fromJson<int>(json['amountFen']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
      category: serializer.fromJson<String>(json['category']),
      merchant: serializer.fromJson<String>(json['merchant']),
      sourcePkg: serializer.fromJson<String>(json['sourcePkg']),
      notifyKey: serializer.fromJson<String>(json['notifyKey']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
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
      'merchant': serializer.toJson<String>(merchant),
      'sourcePkg': serializer.toJson<String>(sourcePkg),
      'notifyKey': serializer.toJson<String>(notifyKey),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PendingRecord copyWith({
    int? id,
    int? amountFen,
    DateTime? occurredAt,
    String? category,
    String? merchant,
    String? sourcePkg,
    String? notifyKey,
    DateTime? createdAt,
  }) => PendingRecord(
    id: id ?? this.id,
    amountFen: amountFen ?? this.amountFen,
    occurredAt: occurredAt ?? this.occurredAt,
    category: category ?? this.category,
    merchant: merchant ?? this.merchant,
    sourcePkg: sourcePkg ?? this.sourcePkg,
    notifyKey: notifyKey ?? this.notifyKey,
    createdAt: createdAt ?? this.createdAt,
  );
  PendingRecord copyWithCompanion(PendingRecordsCompanion data) {
    return PendingRecord(
      id: data.id.present ? data.id.value : this.id,
      amountFen: data.amountFen.present ? data.amountFen.value : this.amountFen,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      category: data.category.present ? data.category.value : this.category,
      merchant: data.merchant.present ? data.merchant.value : this.merchant,
      sourcePkg: data.sourcePkg.present ? data.sourcePkg.value : this.sourcePkg,
      notifyKey: data.notifyKey.present ? data.notifyKey.value : this.notifyKey,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingRecord(')
          ..write('id: $id, ')
          ..write('amountFen: $amountFen, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('category: $category, ')
          ..write('merchant: $merchant, ')
          ..write('sourcePkg: $sourcePkg, ')
          ..write('notifyKey: $notifyKey, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    amountFen,
    occurredAt,
    category,
    merchant,
    sourcePkg,
    notifyKey,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingRecord &&
          other.id == this.id &&
          other.amountFen == this.amountFen &&
          other.occurredAt == this.occurredAt &&
          other.category == this.category &&
          other.merchant == this.merchant &&
          other.sourcePkg == this.sourcePkg &&
          other.notifyKey == this.notifyKey &&
          other.createdAt == this.createdAt);
}

class PendingRecordsCompanion extends UpdateCompanion<PendingRecord> {
  final Value<int> id;
  final Value<int> amountFen;
  final Value<DateTime> occurredAt;
  final Value<String> category;
  final Value<String> merchant;
  final Value<String> sourcePkg;
  final Value<String> notifyKey;
  final Value<DateTime> createdAt;
  const PendingRecordsCompanion({
    this.id = const Value.absent(),
    this.amountFen = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.category = const Value.absent(),
    this.merchant = const Value.absent(),
    this.sourcePkg = const Value.absent(),
    this.notifyKey = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PendingRecordsCompanion.insert({
    this.id = const Value.absent(),
    required int amountFen,
    required DateTime occurredAt,
    required String category,
    required String merchant,
    this.sourcePkg = const Value.absent(),
    this.notifyKey = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : amountFen = Value(amountFen),
       occurredAt = Value(occurredAt),
       category = Value(category),
       merchant = Value(merchant);
  static Insertable<PendingRecord> custom({
    Expression<int>? id,
    Expression<int>? amountFen,
    Expression<DateTime>? occurredAt,
    Expression<String>? category,
    Expression<String>? merchant,
    Expression<String>? sourcePkg,
    Expression<String>? notifyKey,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (amountFen != null) 'amount_fen': amountFen,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (category != null) 'category': category,
      if (merchant != null) 'merchant': merchant,
      if (sourcePkg != null) 'source_pkg': sourcePkg,
      if (notifyKey != null) 'notify_key': notifyKey,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PendingRecordsCompanion copyWith({
    Value<int>? id,
    Value<int>? amountFen,
    Value<DateTime>? occurredAt,
    Value<String>? category,
    Value<String>? merchant,
    Value<String>? sourcePkg,
    Value<String>? notifyKey,
    Value<DateTime>? createdAt,
  }) {
    return PendingRecordsCompanion(
      id: id ?? this.id,
      amountFen: amountFen ?? this.amountFen,
      occurredAt: occurredAt ?? this.occurredAt,
      category: category ?? this.category,
      merchant: merchant ?? this.merchant,
      sourcePkg: sourcePkg ?? this.sourcePkg,
      notifyKey: notifyKey ?? this.notifyKey,
      createdAt: createdAt ?? this.createdAt,
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
    if (merchant.present) {
      map['merchant'] = Variable<String>(merchant.value);
    }
    if (sourcePkg.present) {
      map['source_pkg'] = Variable<String>(sourcePkg.value);
    }
    if (notifyKey.present) {
      map['notify_key'] = Variable<String>(notifyKey.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingRecordsCompanion(')
          ..write('id: $id, ')
          ..write('amountFen: $amountFen, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('category: $category, ')
          ..write('merchant: $merchant, ')
          ..write('sourcePkg: $sourcePkg, ')
          ..write('notifyKey: $notifyKey, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ImportBatchesTable extends ImportBatches
    with TableInfo<$ImportBatchesTable, ImportBatch> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImportBatchesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('bill'),
  );
  static const VerificationMeta _fileNameMeta = const VerificationMeta(
    'fileName',
  );
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
    'file_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _rowCountMeta = const VerificationMeta(
    'rowCount',
  );
  @override
  late final GeneratedColumn<int> rowCount = GeneratedColumn<int>(
    'row_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _okCountMeta = const VerificationMeta(
    'okCount',
  );
  @override
  late final GeneratedColumn<int> okCount = GeneratedColumn<int>(
    'ok_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _failCountMeta = const VerificationMeta(
    'failCount',
  );
  @override
  late final GeneratedColumn<int> failCount = GeneratedColumn<int>(
    'fail_count',
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
    source,
    fileName,
    rowCount,
    okCount,
    failCount,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'import_batches';
  @override
  VerificationContext validateIntegrity(
    Insertable<ImportBatch> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('file_name')) {
      context.handle(
        _fileNameMeta,
        fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta),
      );
    }
    if (data.containsKey('row_count')) {
      context.handle(
        _rowCountMeta,
        rowCount.isAcceptableOrUnknown(data['row_count']!, _rowCountMeta),
      );
    }
    if (data.containsKey('ok_count')) {
      context.handle(
        _okCountMeta,
        okCount.isAcceptableOrUnknown(data['ok_count']!, _okCountMeta),
      );
    }
    if (data.containsKey('fail_count')) {
      context.handle(
        _failCountMeta,
        failCount.isAcceptableOrUnknown(data['fail_count']!, _failCountMeta),
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
  ImportBatch map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImportBatch(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      fileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_name'],
      )!,
      rowCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}row_count'],
      )!,
      okCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ok_count'],
      )!,
      failCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fail_count'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ImportBatchesTable createAlias(String alias) {
    return $ImportBatchesTable(attachedDatabase, alias);
  }
}

class ImportBatch extends DataClass implements Insertable<ImportBatch> {
  final int id;
  final String source;
  final String fileName;
  final int rowCount;
  final int okCount;
  final int failCount;
  final DateTime createdAt;
  const ImportBatch({
    required this.id,
    required this.source,
    required this.fileName,
    required this.rowCount,
    required this.okCount,
    required this.failCount,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['source'] = Variable<String>(source);
    map['file_name'] = Variable<String>(fileName);
    map['row_count'] = Variable<int>(rowCount);
    map['ok_count'] = Variable<int>(okCount);
    map['fail_count'] = Variable<int>(failCount);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ImportBatchesCompanion toCompanion(bool nullToAbsent) {
    return ImportBatchesCompanion(
      id: Value(id),
      source: Value(source),
      fileName: Value(fileName),
      rowCount: Value(rowCount),
      okCount: Value(okCount),
      failCount: Value(failCount),
      createdAt: Value(createdAt),
    );
  }

  factory ImportBatch.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImportBatch(
      id: serializer.fromJson<int>(json['id']),
      source: serializer.fromJson<String>(json['source']),
      fileName: serializer.fromJson<String>(json['fileName']),
      rowCount: serializer.fromJson<int>(json['rowCount']),
      okCount: serializer.fromJson<int>(json['okCount']),
      failCount: serializer.fromJson<int>(json['failCount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'source': serializer.toJson<String>(source),
      'fileName': serializer.toJson<String>(fileName),
      'rowCount': serializer.toJson<int>(rowCount),
      'okCount': serializer.toJson<int>(okCount),
      'failCount': serializer.toJson<int>(failCount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ImportBatch copyWith({
    int? id,
    String? source,
    String? fileName,
    int? rowCount,
    int? okCount,
    int? failCount,
    DateTime? createdAt,
  }) => ImportBatch(
    id: id ?? this.id,
    source: source ?? this.source,
    fileName: fileName ?? this.fileName,
    rowCount: rowCount ?? this.rowCount,
    okCount: okCount ?? this.okCount,
    failCount: failCount ?? this.failCount,
    createdAt: createdAt ?? this.createdAt,
  );
  ImportBatch copyWithCompanion(ImportBatchesCompanion data) {
    return ImportBatch(
      id: data.id.present ? data.id.value : this.id,
      source: data.source.present ? data.source.value : this.source,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      rowCount: data.rowCount.present ? data.rowCount.value : this.rowCount,
      okCount: data.okCount.present ? data.okCount.value : this.okCount,
      failCount: data.failCount.present ? data.failCount.value : this.failCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImportBatch(')
          ..write('id: $id, ')
          ..write('source: $source, ')
          ..write('fileName: $fileName, ')
          ..write('rowCount: $rowCount, ')
          ..write('okCount: $okCount, ')
          ..write('failCount: $failCount, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    source,
    fileName,
    rowCount,
    okCount,
    failCount,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImportBatch &&
          other.id == this.id &&
          other.source == this.source &&
          other.fileName == this.fileName &&
          other.rowCount == this.rowCount &&
          other.okCount == this.okCount &&
          other.failCount == this.failCount &&
          other.createdAt == this.createdAt);
}

class ImportBatchesCompanion extends UpdateCompanion<ImportBatch> {
  final Value<int> id;
  final Value<String> source;
  final Value<String> fileName;
  final Value<int> rowCount;
  final Value<int> okCount;
  final Value<int> failCount;
  final Value<DateTime> createdAt;
  const ImportBatchesCompanion({
    this.id = const Value.absent(),
    this.source = const Value.absent(),
    this.fileName = const Value.absent(),
    this.rowCount = const Value.absent(),
    this.okCount = const Value.absent(),
    this.failCount = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ImportBatchesCompanion.insert({
    this.id = const Value.absent(),
    this.source = const Value.absent(),
    this.fileName = const Value.absent(),
    this.rowCount = const Value.absent(),
    this.okCount = const Value.absent(),
    this.failCount = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  static Insertable<ImportBatch> custom({
    Expression<int>? id,
    Expression<String>? source,
    Expression<String>? fileName,
    Expression<int>? rowCount,
    Expression<int>? okCount,
    Expression<int>? failCount,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (source != null) 'source': source,
      if (fileName != null) 'file_name': fileName,
      if (rowCount != null) 'row_count': rowCount,
      if (okCount != null) 'ok_count': okCount,
      if (failCount != null) 'fail_count': failCount,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ImportBatchesCompanion copyWith({
    Value<int>? id,
    Value<String>? source,
    Value<String>? fileName,
    Value<int>? rowCount,
    Value<int>? okCount,
    Value<int>? failCount,
    Value<DateTime>? createdAt,
  }) {
    return ImportBatchesCompanion(
      id: id ?? this.id,
      source: source ?? this.source,
      fileName: fileName ?? this.fileName,
      rowCount: rowCount ?? this.rowCount,
      okCount: okCount ?? this.okCount,
      failCount: failCount ?? this.failCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (rowCount.present) {
      map['row_count'] = Variable<int>(rowCount.value);
    }
    if (okCount.present) {
      map['ok_count'] = Variable<int>(okCount.value);
    }
    if (failCount.present) {
      map['fail_count'] = Variable<int>(failCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImportBatchesCompanion(')
          ..write('id: $id, ')
          ..write('source: $source, ')
          ..write('fileName: $fileName, ')
          ..write('rowCount: $rowCount, ')
          ..write('okCount: $okCount, ')
          ..write('failCount: $failCount, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $BudgetsTable extends Budgets with TableInfo<$BudgetsTable, Budget> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BudgetsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _monthKeyMeta = const VerificationMeta(
    'monthKey',
  );
  @override
  late final GeneratedColumn<String> monthKey = GeneratedColumn<String>(
    'month_key',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 4,
      maxTextLength: 16,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _budgetFenMeta = const VerificationMeta(
    'budgetFen',
  );
  @override
  late final GeneratedColumn<int> budgetFen = GeneratedColumn<int>(
    'budget_fen',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _basisFenMeta = const VerificationMeta(
    'basisFen',
  );
  @override
  late final GeneratedColumn<int> basisFen = GeneratedColumn<int>(
    'basis_fen',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _tightenPctMeta = const VerificationMeta(
    'tightenPct',
  );
  @override
  late final GeneratedColumn<int> tightenPct = GeneratedColumn<int>(
    'tighten_pct',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(5),
  );
  static const VerificationMeta _basisMeta = const VerificationMeta('basis');
  @override
  late final GeneratedColumn<String> basis = GeneratedColumn<String>(
    'basis',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('median'),
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
    monthKey,
    budgetFen,
    basisFen,
    tightenPct,
    basis,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'budgets';
  @override
  VerificationContext validateIntegrity(
    Insertable<Budget> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('month_key')) {
      context.handle(
        _monthKeyMeta,
        monthKey.isAcceptableOrUnknown(data['month_key']!, _monthKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_monthKeyMeta);
    }
    if (data.containsKey('budget_fen')) {
      context.handle(
        _budgetFenMeta,
        budgetFen.isAcceptableOrUnknown(data['budget_fen']!, _budgetFenMeta),
      );
    } else if (isInserting) {
      context.missing(_budgetFenMeta);
    }
    if (data.containsKey('basis_fen')) {
      context.handle(
        _basisFenMeta,
        basisFen.isAcceptableOrUnknown(data['basis_fen']!, _basisFenMeta),
      );
    }
    if (data.containsKey('tighten_pct')) {
      context.handle(
        _tightenPctMeta,
        tightenPct.isAcceptableOrUnknown(data['tighten_pct']!, _tightenPctMeta),
      );
    }
    if (data.containsKey('basis')) {
      context.handle(
        _basisMeta,
        basis.isAcceptableOrUnknown(data['basis']!, _basisMeta),
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
  Budget map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Budget(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      monthKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}month_key'],
      )!,
      budgetFen: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}budget_fen'],
      )!,
      basisFen: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}basis_fen'],
      )!,
      tightenPct: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tighten_pct'],
      )!,
      basis: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}basis'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $BudgetsTable createAlias(String alias) {
    return $BudgetsTable(attachedDatabase, alias);
  }
}

class Budget extends DataClass implements Insertable<Budget> {
  final int id;
  final String monthKey;
  final int budgetFen;
  final int basisFen;
  final int tightenPct;
  final String basis;
  final DateTime createdAt;
  const Budget({
    required this.id,
    required this.monthKey,
    required this.budgetFen,
    required this.basisFen,
    required this.tightenPct,
    required this.basis,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['month_key'] = Variable<String>(monthKey);
    map['budget_fen'] = Variable<int>(budgetFen);
    map['basis_fen'] = Variable<int>(basisFen);
    map['tighten_pct'] = Variable<int>(tightenPct);
    map['basis'] = Variable<String>(basis);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BudgetsCompanion toCompanion(bool nullToAbsent) {
    return BudgetsCompanion(
      id: Value(id),
      monthKey: Value(monthKey),
      budgetFen: Value(budgetFen),
      basisFen: Value(basisFen),
      tightenPct: Value(tightenPct),
      basis: Value(basis),
      createdAt: Value(createdAt),
    );
  }

  factory Budget.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Budget(
      id: serializer.fromJson<int>(json['id']),
      monthKey: serializer.fromJson<String>(json['monthKey']),
      budgetFen: serializer.fromJson<int>(json['budgetFen']),
      basisFen: serializer.fromJson<int>(json['basisFen']),
      tightenPct: serializer.fromJson<int>(json['tightenPct']),
      basis: serializer.fromJson<String>(json['basis']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'monthKey': serializer.toJson<String>(monthKey),
      'budgetFen': serializer.toJson<int>(budgetFen),
      'basisFen': serializer.toJson<int>(basisFen),
      'tightenPct': serializer.toJson<int>(tightenPct),
      'basis': serializer.toJson<String>(basis),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Budget copyWith({
    int? id,
    String? monthKey,
    int? budgetFen,
    int? basisFen,
    int? tightenPct,
    String? basis,
    DateTime? createdAt,
  }) => Budget(
    id: id ?? this.id,
    monthKey: monthKey ?? this.monthKey,
    budgetFen: budgetFen ?? this.budgetFen,
    basisFen: basisFen ?? this.basisFen,
    tightenPct: tightenPct ?? this.tightenPct,
    basis: basis ?? this.basis,
    createdAt: createdAt ?? this.createdAt,
  );
  Budget copyWithCompanion(BudgetsCompanion data) {
    return Budget(
      id: data.id.present ? data.id.value : this.id,
      monthKey: data.monthKey.present ? data.monthKey.value : this.monthKey,
      budgetFen: data.budgetFen.present ? data.budgetFen.value : this.budgetFen,
      basisFen: data.basisFen.present ? data.basisFen.value : this.basisFen,
      tightenPct: data.tightenPct.present
          ? data.tightenPct.value
          : this.tightenPct,
      basis: data.basis.present ? data.basis.value : this.basis,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Budget(')
          ..write('id: $id, ')
          ..write('monthKey: $monthKey, ')
          ..write('budgetFen: $budgetFen, ')
          ..write('basisFen: $basisFen, ')
          ..write('tightenPct: $tightenPct, ')
          ..write('basis: $basis, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    monthKey,
    budgetFen,
    basisFen,
    tightenPct,
    basis,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Budget &&
          other.id == this.id &&
          other.monthKey == this.monthKey &&
          other.budgetFen == this.budgetFen &&
          other.basisFen == this.basisFen &&
          other.tightenPct == this.tightenPct &&
          other.basis == this.basis &&
          other.createdAt == this.createdAt);
}

class BudgetsCompanion extends UpdateCompanion<Budget> {
  final Value<int> id;
  final Value<String> monthKey;
  final Value<int> budgetFen;
  final Value<int> basisFen;
  final Value<int> tightenPct;
  final Value<String> basis;
  final Value<DateTime> createdAt;
  const BudgetsCompanion({
    this.id = const Value.absent(),
    this.monthKey = const Value.absent(),
    this.budgetFen = const Value.absent(),
    this.basisFen = const Value.absent(),
    this.tightenPct = const Value.absent(),
    this.basis = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  BudgetsCompanion.insert({
    this.id = const Value.absent(),
    required String monthKey,
    required int budgetFen,
    this.basisFen = const Value.absent(),
    this.tightenPct = const Value.absent(),
    this.basis = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : monthKey = Value(monthKey),
       budgetFen = Value(budgetFen);
  static Insertable<Budget> custom({
    Expression<int>? id,
    Expression<String>? monthKey,
    Expression<int>? budgetFen,
    Expression<int>? basisFen,
    Expression<int>? tightenPct,
    Expression<String>? basis,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (monthKey != null) 'month_key': monthKey,
      if (budgetFen != null) 'budget_fen': budgetFen,
      if (basisFen != null) 'basis_fen': basisFen,
      if (tightenPct != null) 'tighten_pct': tightenPct,
      if (basis != null) 'basis': basis,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  BudgetsCompanion copyWith({
    Value<int>? id,
    Value<String>? monthKey,
    Value<int>? budgetFen,
    Value<int>? basisFen,
    Value<int>? tightenPct,
    Value<String>? basis,
    Value<DateTime>? createdAt,
  }) {
    return BudgetsCompanion(
      id: id ?? this.id,
      monthKey: monthKey ?? this.monthKey,
      budgetFen: budgetFen ?? this.budgetFen,
      basisFen: basisFen ?? this.basisFen,
      tightenPct: tightenPct ?? this.tightenPct,
      basis: basis ?? this.basis,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (monthKey.present) {
      map['month_key'] = Variable<String>(monthKey.value);
    }
    if (budgetFen.present) {
      map['budget_fen'] = Variable<int>(budgetFen.value);
    }
    if (basisFen.present) {
      map['basis_fen'] = Variable<int>(basisFen.value);
    }
    if (tightenPct.present) {
      map['tighten_pct'] = Variable<int>(tightenPct.value);
    }
    if (basis.present) {
      map['basis'] = Variable<String>(basis.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BudgetsCompanion(')
          ..write('id: $id, ')
          ..write('monthKey: $monthKey, ')
          ..write('budgetFen: $budgetFen, ')
          ..write('basisFen: $basisFen, ')
          ..write('tightenPct: $tightenPct, ')
          ..write('basis: $basis, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $DailyClosesTable extends DailyCloses
    with TableInfo<$DailyClosesTable, DailyClose> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyClosesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _dateKeyMeta = const VerificationMeta(
    'dateKey',
  );
  @override
  late final GeneratedColumn<String> dateKey = GeneratedColumn<String>(
    'date_key',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 8,
      maxTextLength: 16,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _estimateFenMeta = const VerificationMeta(
    'estimateFen',
  );
  @override
  late final GeneratedColumn<int> estimateFen = GeneratedColumn<int>(
    'estimate_fen',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('done'),
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
    dateKey,
    estimateFen,
    status,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_closes';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyClose> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date_key')) {
      context.handle(
        _dateKeyMeta,
        dateKey.isAcceptableOrUnknown(data['date_key']!, _dateKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_dateKeyMeta);
    }
    if (data.containsKey('estimate_fen')) {
      context.handle(
        _estimateFenMeta,
        estimateFen.isAcceptableOrUnknown(
          data['estimate_fen']!,
          _estimateFenMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
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
  DailyClose map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyClose(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      dateKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date_key'],
      )!,
      estimateFen: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}estimate_fen'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $DailyClosesTable createAlias(String alias) {
    return $DailyClosesTable(attachedDatabase, alias);
  }
}

class DailyClose extends DataClass implements Insertable<DailyClose> {
  final int id;
  final String dateKey;
  final int estimateFen;
  final String status;
  final DateTime createdAt;
  const DailyClose({
    required this.id,
    required this.dateKey,
    required this.estimateFen,
    required this.status,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date_key'] = Variable<String>(dateKey);
    map['estimate_fen'] = Variable<int>(estimateFen);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  DailyClosesCompanion toCompanion(bool nullToAbsent) {
    return DailyClosesCompanion(
      id: Value(id),
      dateKey: Value(dateKey),
      estimateFen: Value(estimateFen),
      status: Value(status),
      createdAt: Value(createdAt),
    );
  }

  factory DailyClose.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyClose(
      id: serializer.fromJson<int>(json['id']),
      dateKey: serializer.fromJson<String>(json['dateKey']),
      estimateFen: serializer.fromJson<int>(json['estimateFen']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'dateKey': serializer.toJson<String>(dateKey),
      'estimateFen': serializer.toJson<int>(estimateFen),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DailyClose copyWith({
    int? id,
    String? dateKey,
    int? estimateFen,
    String? status,
    DateTime? createdAt,
  }) => DailyClose(
    id: id ?? this.id,
    dateKey: dateKey ?? this.dateKey,
    estimateFen: estimateFen ?? this.estimateFen,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
  );
  DailyClose copyWithCompanion(DailyClosesCompanion data) {
    return DailyClose(
      id: data.id.present ? data.id.value : this.id,
      dateKey: data.dateKey.present ? data.dateKey.value : this.dateKey,
      estimateFen: data.estimateFen.present
          ? data.estimateFen.value
          : this.estimateFen,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyClose(')
          ..write('id: $id, ')
          ..write('dateKey: $dateKey, ')
          ..write('estimateFen: $estimateFen, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, dateKey, estimateFen, status, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyClose &&
          other.id == this.id &&
          other.dateKey == this.dateKey &&
          other.estimateFen == this.estimateFen &&
          other.status == this.status &&
          other.createdAt == this.createdAt);
}

class DailyClosesCompanion extends UpdateCompanion<DailyClose> {
  final Value<int> id;
  final Value<String> dateKey;
  final Value<int> estimateFen;
  final Value<String> status;
  final Value<DateTime> createdAt;
  const DailyClosesCompanion({
    this.id = const Value.absent(),
    this.dateKey = const Value.absent(),
    this.estimateFen = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  DailyClosesCompanion.insert({
    this.id = const Value.absent(),
    required String dateKey,
    this.estimateFen = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : dateKey = Value(dateKey);
  static Insertable<DailyClose> custom({
    Expression<int>? id,
    Expression<String>? dateKey,
    Expression<int>? estimateFen,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dateKey != null) 'date_key': dateKey,
      if (estimateFen != null) 'estimate_fen': estimateFen,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  DailyClosesCompanion copyWith({
    Value<int>? id,
    Value<String>? dateKey,
    Value<int>? estimateFen,
    Value<String>? status,
    Value<DateTime>? createdAt,
  }) {
    return DailyClosesCompanion(
      id: id ?? this.id,
      dateKey: dateKey ?? this.dateKey,
      estimateFen: estimateFen ?? this.estimateFen,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (dateKey.present) {
      map['date_key'] = Variable<String>(dateKey.value);
    }
    if (estimateFen.present) {
      map['estimate_fen'] = Variable<int>(estimateFen.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyClosesCompanion(')
          ..write('id: $id, ')
          ..write('dateKey: $dateKey, ')
          ..write('estimateFen: $estimateFen, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ClosePrefsTable extends ClosePrefs
    with TableInfo<$ClosePrefsTable, ClosePref> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClosePrefsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
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
  List<GeneratedColumn> get $columns => [id, enabled, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'close_prefs';
  @override
  VerificationContext validateIntegrity(
    Insertable<ClosePref> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
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
  ClosePref map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ClosePref(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ClosePrefsTable createAlias(String alias) {
    return $ClosePrefsTable(attachedDatabase, alias);
  }
}

class ClosePref extends DataClass implements Insertable<ClosePref> {
  final int id;
  final bool enabled;
  final DateTime updatedAt;
  const ClosePref({
    required this.id,
    required this.enabled,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['enabled'] = Variable<bool>(enabled);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ClosePrefsCompanion toCompanion(bool nullToAbsent) {
    return ClosePrefsCompanion(
      id: Value(id),
      enabled: Value(enabled),
      updatedAt: Value(updatedAt),
    );
  }

  factory ClosePref.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ClosePref(
      id: serializer.fromJson<int>(json['id']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'enabled': serializer.toJson<bool>(enabled),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ClosePref copyWith({int? id, bool? enabled, DateTime? updatedAt}) =>
      ClosePref(
        id: id ?? this.id,
        enabled: enabled ?? this.enabled,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  ClosePref copyWithCompanion(ClosePrefsCompanion data) {
    return ClosePref(
      id: data.id.present ? data.id.value : this.id,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ClosePref(')
          ..write('id: $id, ')
          ..write('enabled: $enabled, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, enabled, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClosePref &&
          other.id == this.id &&
          other.enabled == this.enabled &&
          other.updatedAt == this.updatedAt);
}

class ClosePrefsCompanion extends UpdateCompanion<ClosePref> {
  final Value<int> id;
  final Value<bool> enabled;
  final Value<DateTime> updatedAt;
  const ClosePrefsCompanion({
    this.id = const Value.absent(),
    this.enabled = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ClosePrefsCompanion.insert({
    this.id = const Value.absent(),
    this.enabled = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  static Insertable<ClosePref> custom({
    Expression<int>? id,
    Expression<bool>? enabled,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (enabled != null) 'enabled': enabled,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ClosePrefsCompanion copyWith({
    Value<int>? id,
    Value<bool>? enabled,
    Value<DateTime>? updatedAt,
  }) {
    return ClosePrefsCompanion(
      id: id ?? this.id,
      enabled: enabled ?? this.enabled,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClosePrefsCompanion(')
          ..write('id: $id, ')
          ..write('enabled: $enabled, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $CooloffsTable extends Cooloffs with TableInfo<$CooloffsTable, Cooloff> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CooloffsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _txIdMeta = const VerificationMeta('txId');
  @override
  late final GeneratedColumn<int> txId = GeneratedColumn<int>(
    'tx_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
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
  static const VerificationMeta _proposedAtMeta = const VerificationMeta(
    'proposedAt',
  );
  @override
  late final GeneratedColumn<DateTime> proposedAt = GeneratedColumn<DateTime>(
    'proposed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _decidedAtMeta = const VerificationMeta(
    'decidedAt',
  );
  @override
  late final GeneratedColumn<DateTime> decidedAt = GeneratedColumn<DateTime>(
    'decided_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    txId,
    amountFen,
    proposedAt,
    status,
    decidedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cooloffs';
  @override
  VerificationContext validateIntegrity(
    Insertable<Cooloff> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('tx_id')) {
      context.handle(
        _txIdMeta,
        txId.isAcceptableOrUnknown(data['tx_id']!, _txIdMeta),
      );
    } else if (isInserting) {
      context.missing(_txIdMeta);
    }
    if (data.containsKey('amount_fen')) {
      context.handle(
        _amountFenMeta,
        amountFen.isAcceptableOrUnknown(data['amount_fen']!, _amountFenMeta),
      );
    } else if (isInserting) {
      context.missing(_amountFenMeta);
    }
    if (data.containsKey('proposed_at')) {
      context.handle(
        _proposedAtMeta,
        proposedAt.isAcceptableOrUnknown(data['proposed_at']!, _proposedAtMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('decided_at')) {
      context.handle(
        _decidedAtMeta,
        decidedAt.isAcceptableOrUnknown(data['decided_at']!, _decidedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Cooloff map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Cooloff(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      txId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tx_id'],
      )!,
      amountFen: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_fen'],
      )!,
      proposedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}proposed_at'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      decidedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}decided_at'],
      ),
    );
  }

  @override
  $CooloffsTable createAlias(String alias) {
    return $CooloffsTable(attachedDatabase, alias);
  }
}

class Cooloff extends DataClass implements Insertable<Cooloff> {
  final int id;
  final int txId;
  final int amountFen;
  final DateTime proposedAt;
  final String status;
  final DateTime? decidedAt;
  const Cooloff({
    required this.id,
    required this.txId,
    required this.amountFen,
    required this.proposedAt,
    required this.status,
    this.decidedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['tx_id'] = Variable<int>(txId);
    map['amount_fen'] = Variable<int>(amountFen);
    map['proposed_at'] = Variable<DateTime>(proposedAt);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || decidedAt != null) {
      map['decided_at'] = Variable<DateTime>(decidedAt);
    }
    return map;
  }

  CooloffsCompanion toCompanion(bool nullToAbsent) {
    return CooloffsCompanion(
      id: Value(id),
      txId: Value(txId),
      amountFen: Value(amountFen),
      proposedAt: Value(proposedAt),
      status: Value(status),
      decidedAt: decidedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(decidedAt),
    );
  }

  factory Cooloff.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Cooloff(
      id: serializer.fromJson<int>(json['id']),
      txId: serializer.fromJson<int>(json['txId']),
      amountFen: serializer.fromJson<int>(json['amountFen']),
      proposedAt: serializer.fromJson<DateTime>(json['proposedAt']),
      status: serializer.fromJson<String>(json['status']),
      decidedAt: serializer.fromJson<DateTime?>(json['decidedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'txId': serializer.toJson<int>(txId),
      'amountFen': serializer.toJson<int>(amountFen),
      'proposedAt': serializer.toJson<DateTime>(proposedAt),
      'status': serializer.toJson<String>(status),
      'decidedAt': serializer.toJson<DateTime?>(decidedAt),
    };
  }

  Cooloff copyWith({
    int? id,
    int? txId,
    int? amountFen,
    DateTime? proposedAt,
    String? status,
    Value<DateTime?> decidedAt = const Value.absent(),
  }) => Cooloff(
    id: id ?? this.id,
    txId: txId ?? this.txId,
    amountFen: amountFen ?? this.amountFen,
    proposedAt: proposedAt ?? this.proposedAt,
    status: status ?? this.status,
    decidedAt: decidedAt.present ? decidedAt.value : this.decidedAt,
  );
  Cooloff copyWithCompanion(CooloffsCompanion data) {
    return Cooloff(
      id: data.id.present ? data.id.value : this.id,
      txId: data.txId.present ? data.txId.value : this.txId,
      amountFen: data.amountFen.present ? data.amountFen.value : this.amountFen,
      proposedAt: data.proposedAt.present
          ? data.proposedAt.value
          : this.proposedAt,
      status: data.status.present ? data.status.value : this.status,
      decidedAt: data.decidedAt.present ? data.decidedAt.value : this.decidedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Cooloff(')
          ..write('id: $id, ')
          ..write('txId: $txId, ')
          ..write('amountFen: $amountFen, ')
          ..write('proposedAt: $proposedAt, ')
          ..write('status: $status, ')
          ..write('decidedAt: $decidedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, txId, amountFen, proposedAt, status, decidedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Cooloff &&
          other.id == this.id &&
          other.txId == this.txId &&
          other.amountFen == this.amountFen &&
          other.proposedAt == this.proposedAt &&
          other.status == this.status &&
          other.decidedAt == this.decidedAt);
}

class CooloffsCompanion extends UpdateCompanion<Cooloff> {
  final Value<int> id;
  final Value<int> txId;
  final Value<int> amountFen;
  final Value<DateTime> proposedAt;
  final Value<String> status;
  final Value<DateTime?> decidedAt;
  const CooloffsCompanion({
    this.id = const Value.absent(),
    this.txId = const Value.absent(),
    this.amountFen = const Value.absent(),
    this.proposedAt = const Value.absent(),
    this.status = const Value.absent(),
    this.decidedAt = const Value.absent(),
  });
  CooloffsCompanion.insert({
    this.id = const Value.absent(),
    required int txId,
    required int amountFen,
    this.proposedAt = const Value.absent(),
    this.status = const Value.absent(),
    this.decidedAt = const Value.absent(),
  }) : txId = Value(txId),
       amountFen = Value(amountFen);
  static Insertable<Cooloff> custom({
    Expression<int>? id,
    Expression<int>? txId,
    Expression<int>? amountFen,
    Expression<DateTime>? proposedAt,
    Expression<String>? status,
    Expression<DateTime>? decidedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (txId != null) 'tx_id': txId,
      if (amountFen != null) 'amount_fen': amountFen,
      if (proposedAt != null) 'proposed_at': proposedAt,
      if (status != null) 'status': status,
      if (decidedAt != null) 'decided_at': decidedAt,
    });
  }

  CooloffsCompanion copyWith({
    Value<int>? id,
    Value<int>? txId,
    Value<int>? amountFen,
    Value<DateTime>? proposedAt,
    Value<String>? status,
    Value<DateTime?>? decidedAt,
  }) {
    return CooloffsCompanion(
      id: id ?? this.id,
      txId: txId ?? this.txId,
      amountFen: amountFen ?? this.amountFen,
      proposedAt: proposedAt ?? this.proposedAt,
      status: status ?? this.status,
      decidedAt: decidedAt ?? this.decidedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (txId.present) {
      map['tx_id'] = Variable<int>(txId.value);
    }
    if (amountFen.present) {
      map['amount_fen'] = Variable<int>(amountFen.value);
    }
    if (proposedAt.present) {
      map['proposed_at'] = Variable<DateTime>(proposedAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (decidedAt.present) {
      map['decided_at'] = Variable<DateTime>(decidedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CooloffsCompanion(')
          ..write('id: $id, ')
          ..write('txId: $txId, ')
          ..write('amountFen: $amountFen, ')
          ..write('proposedAt: $proposedAt, ')
          ..write('status: $status, ')
          ..write('decidedAt: $decidedAt')
          ..write(')'))
        .toString();
  }
}

class $CooloffPrefsTable extends CooloffPrefs
    with TableInfo<$CooloffPrefsTable, CooloffPref> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CooloffPrefsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _customFenMeta = const VerificationMeta(
    'customFen',
  );
  @override
  late final GeneratedColumn<int> customFen = GeneratedColumn<int>(
    'custom_fen',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
  List<GeneratedColumn> get $columns => [id, enabled, customFen, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cooloff_prefs';
  @override
  VerificationContext validateIntegrity(
    Insertable<CooloffPref> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    if (data.containsKey('custom_fen')) {
      context.handle(
        _customFenMeta,
        customFen.isAcceptableOrUnknown(data['custom_fen']!, _customFenMeta),
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
  CooloffPref map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CooloffPref(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
      customFen: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}custom_fen'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CooloffPrefsTable createAlias(String alias) {
    return $CooloffPrefsTable(attachedDatabase, alias);
  }
}

class CooloffPref extends DataClass implements Insertable<CooloffPref> {
  final int id;
  final bool enabled;
  final int customFen;
  final DateTime updatedAt;
  const CooloffPref({
    required this.id,
    required this.enabled,
    required this.customFen,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['enabled'] = Variable<bool>(enabled);
    map['custom_fen'] = Variable<int>(customFen);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CooloffPrefsCompanion toCompanion(bool nullToAbsent) {
    return CooloffPrefsCompanion(
      id: Value(id),
      enabled: Value(enabled),
      customFen: Value(customFen),
      updatedAt: Value(updatedAt),
    );
  }

  factory CooloffPref.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CooloffPref(
      id: serializer.fromJson<int>(json['id']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      customFen: serializer.fromJson<int>(json['customFen']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'enabled': serializer.toJson<bool>(enabled),
      'customFen': serializer.toJson<int>(customFen),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CooloffPref copyWith({
    int? id,
    bool? enabled,
    int? customFen,
    DateTime? updatedAt,
  }) => CooloffPref(
    id: id ?? this.id,
    enabled: enabled ?? this.enabled,
    customFen: customFen ?? this.customFen,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CooloffPref copyWithCompanion(CooloffPrefsCompanion data) {
    return CooloffPref(
      id: data.id.present ? data.id.value : this.id,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      customFen: data.customFen.present ? data.customFen.value : this.customFen,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CooloffPref(')
          ..write('id: $id, ')
          ..write('enabled: $enabled, ')
          ..write('customFen: $customFen, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, enabled, customFen, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CooloffPref &&
          other.id == this.id &&
          other.enabled == this.enabled &&
          other.customFen == this.customFen &&
          other.updatedAt == this.updatedAt);
}

class CooloffPrefsCompanion extends UpdateCompanion<CooloffPref> {
  final Value<int> id;
  final Value<bool> enabled;
  final Value<int> customFen;
  final Value<DateTime> updatedAt;
  const CooloffPrefsCompanion({
    this.id = const Value.absent(),
    this.enabled = const Value.absent(),
    this.customFen = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  CooloffPrefsCompanion.insert({
    this.id = const Value.absent(),
    this.enabled = const Value.absent(),
    this.customFen = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  static Insertable<CooloffPref> custom({
    Expression<int>? id,
    Expression<bool>? enabled,
    Expression<int>? customFen,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (enabled != null) 'enabled': enabled,
      if (customFen != null) 'custom_fen': customFen,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  CooloffPrefsCompanion copyWith({
    Value<int>? id,
    Value<bool>? enabled,
    Value<int>? customFen,
    Value<DateTime>? updatedAt,
  }) {
    return CooloffPrefsCompanion(
      id: id ?? this.id,
      enabled: enabled ?? this.enabled,
      customFen: customFen ?? this.customFen,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (customFen.present) {
      map['custom_fen'] = Variable<int>(customFen.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CooloffPrefsCompanion(')
          ..write('id: $id, ')
          ..write('enabled: $enabled, ')
          ..write('customFen: $customFen, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $ExperimentsTable extends Experiments
    with TableInfo<$ExperimentsTable, Experiment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExperimentsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _templateIdMeta = const VerificationMeta(
    'templateId',
  );
  @override
  late final GeneratedColumn<String> templateId = GeneratedColumn<String>(
    'template_id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 32,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _dailySaveFenMeta = const VerificationMeta(
    'dailySaveFen',
  );
  @override
  late final GeneratedColumn<int> dailySaveFen = GeneratedColumn<int>(
    'daily_save_fen',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _checkInsMeta = const VerificationMeta(
    'checkIns',
  );
  @override
  late final GeneratedColumn<String> checkIns = GeneratedColumn<String>(
    'check_ins',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
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
    templateId,
    name,
    dailySaveFen,
    startDate,
    checkIns,
    status,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'experiments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Experiment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('template_id')) {
      context.handle(
        _templateIdMeta,
        templateId.isAcceptableOrUnknown(data['template_id']!, _templateIdMeta),
      );
    } else if (isInserting) {
      context.missing(_templateIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('daily_save_fen')) {
      context.handle(
        _dailySaveFenMeta,
        dailySaveFen.isAcceptableOrUnknown(
          data['daily_save_fen']!,
          _dailySaveFenMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dailySaveFenMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('check_ins')) {
      context.handle(
        _checkInsMeta,
        checkIns.isAcceptableOrUnknown(data['check_ins']!, _checkInsMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
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
  Experiment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Experiment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      templateId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}template_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      dailySaveFen: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}daily_save_fen'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      )!,
      checkIns: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}check_ins'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ExperimentsTable createAlias(String alias) {
    return $ExperimentsTable(attachedDatabase, alias);
  }
}

class Experiment extends DataClass implements Insertable<Experiment> {
  final int id;
  final String templateId;
  final String name;
  final int dailySaveFen;
  final DateTime startDate;
  final String checkIns;
  final String status;
  final DateTime createdAt;
  const Experiment({
    required this.id,
    required this.templateId,
    required this.name,
    required this.dailySaveFen,
    required this.startDate,
    required this.checkIns,
    required this.status,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['template_id'] = Variable<String>(templateId);
    map['name'] = Variable<String>(name);
    map['daily_save_fen'] = Variable<int>(dailySaveFen);
    map['start_date'] = Variable<DateTime>(startDate);
    map['check_ins'] = Variable<String>(checkIns);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ExperimentsCompanion toCompanion(bool nullToAbsent) {
    return ExperimentsCompanion(
      id: Value(id),
      templateId: Value(templateId),
      name: Value(name),
      dailySaveFen: Value(dailySaveFen),
      startDate: Value(startDate),
      checkIns: Value(checkIns),
      status: Value(status),
      createdAt: Value(createdAt),
    );
  }

  factory Experiment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Experiment(
      id: serializer.fromJson<int>(json['id']),
      templateId: serializer.fromJson<String>(json['templateId']),
      name: serializer.fromJson<String>(json['name']),
      dailySaveFen: serializer.fromJson<int>(json['dailySaveFen']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      checkIns: serializer.fromJson<String>(json['checkIns']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'templateId': serializer.toJson<String>(templateId),
      'name': serializer.toJson<String>(name),
      'dailySaveFen': serializer.toJson<int>(dailySaveFen),
      'startDate': serializer.toJson<DateTime>(startDate),
      'checkIns': serializer.toJson<String>(checkIns),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Experiment copyWith({
    int? id,
    String? templateId,
    String? name,
    int? dailySaveFen,
    DateTime? startDate,
    String? checkIns,
    String? status,
    DateTime? createdAt,
  }) => Experiment(
    id: id ?? this.id,
    templateId: templateId ?? this.templateId,
    name: name ?? this.name,
    dailySaveFen: dailySaveFen ?? this.dailySaveFen,
    startDate: startDate ?? this.startDate,
    checkIns: checkIns ?? this.checkIns,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
  );
  Experiment copyWithCompanion(ExperimentsCompanion data) {
    return Experiment(
      id: data.id.present ? data.id.value : this.id,
      templateId: data.templateId.present
          ? data.templateId.value
          : this.templateId,
      name: data.name.present ? data.name.value : this.name,
      dailySaveFen: data.dailySaveFen.present
          ? data.dailySaveFen.value
          : this.dailySaveFen,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      checkIns: data.checkIns.present ? data.checkIns.value : this.checkIns,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Experiment(')
          ..write('id: $id, ')
          ..write('templateId: $templateId, ')
          ..write('name: $name, ')
          ..write('dailySaveFen: $dailySaveFen, ')
          ..write('startDate: $startDate, ')
          ..write('checkIns: $checkIns, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    templateId,
    name,
    dailySaveFen,
    startDate,
    checkIns,
    status,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Experiment &&
          other.id == this.id &&
          other.templateId == this.templateId &&
          other.name == this.name &&
          other.dailySaveFen == this.dailySaveFen &&
          other.startDate == this.startDate &&
          other.checkIns == this.checkIns &&
          other.status == this.status &&
          other.createdAt == this.createdAt);
}

class ExperimentsCompanion extends UpdateCompanion<Experiment> {
  final Value<int> id;
  final Value<String> templateId;
  final Value<String> name;
  final Value<int> dailySaveFen;
  final Value<DateTime> startDate;
  final Value<String> checkIns;
  final Value<String> status;
  final Value<DateTime> createdAt;
  const ExperimentsCompanion({
    this.id = const Value.absent(),
    this.templateId = const Value.absent(),
    this.name = const Value.absent(),
    this.dailySaveFen = const Value.absent(),
    this.startDate = const Value.absent(),
    this.checkIns = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ExperimentsCompanion.insert({
    this.id = const Value.absent(),
    required String templateId,
    required String name,
    required int dailySaveFen,
    required DateTime startDate,
    this.checkIns = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : templateId = Value(templateId),
       name = Value(name),
       dailySaveFen = Value(dailySaveFen),
       startDate = Value(startDate);
  static Insertable<Experiment> custom({
    Expression<int>? id,
    Expression<String>? templateId,
    Expression<String>? name,
    Expression<int>? dailySaveFen,
    Expression<DateTime>? startDate,
    Expression<String>? checkIns,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (templateId != null) 'template_id': templateId,
      if (name != null) 'name': name,
      if (dailySaveFen != null) 'daily_save_fen': dailySaveFen,
      if (startDate != null) 'start_date': startDate,
      if (checkIns != null) 'check_ins': checkIns,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ExperimentsCompanion copyWith({
    Value<int>? id,
    Value<String>? templateId,
    Value<String>? name,
    Value<int>? dailySaveFen,
    Value<DateTime>? startDate,
    Value<String>? checkIns,
    Value<String>? status,
    Value<DateTime>? createdAt,
  }) {
    return ExperimentsCompanion(
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
      name: name ?? this.name,
      dailySaveFen: dailySaveFen ?? this.dailySaveFen,
      startDate: startDate ?? this.startDate,
      checkIns: checkIns ?? this.checkIns,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (templateId.present) {
      map['template_id'] = Variable<String>(templateId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (dailySaveFen.present) {
      map['daily_save_fen'] = Variable<int>(dailySaveFen.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (checkIns.present) {
      map['check_ins'] = Variable<String>(checkIns.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExperimentsCompanion(')
          ..write('id: $id, ')
          ..write('templateId: $templateId, ')
          ..write('name: $name, ')
          ..write('dailySaveFen: $dailySaveFen, ')
          ..write('startDate: $startDate, ')
          ..write('checkIns: $checkIns, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ExperimentPrefsTable extends ExperimentPrefs
    with TableInfo<$ExperimentPrefsTable, ExperimentPref> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExperimentPrefsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
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
  List<GeneratedColumn> get $columns => [id, enabled, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'experiment_prefs';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExperimentPref> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
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
  ExperimentPref map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExperimentPref(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ExperimentPrefsTable createAlias(String alias) {
    return $ExperimentPrefsTable(attachedDatabase, alias);
  }
}

class ExperimentPref extends DataClass implements Insertable<ExperimentPref> {
  final int id;
  final bool enabled;
  final DateTime updatedAt;
  const ExperimentPref({
    required this.id,
    required this.enabled,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['enabled'] = Variable<bool>(enabled);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ExperimentPrefsCompanion toCompanion(bool nullToAbsent) {
    return ExperimentPrefsCompanion(
      id: Value(id),
      enabled: Value(enabled),
      updatedAt: Value(updatedAt),
    );
  }

  factory ExperimentPref.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExperimentPref(
      id: serializer.fromJson<int>(json['id']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'enabled': serializer.toJson<bool>(enabled),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ExperimentPref copyWith({int? id, bool? enabled, DateTime? updatedAt}) =>
      ExperimentPref(
        id: id ?? this.id,
        enabled: enabled ?? this.enabled,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  ExperimentPref copyWithCompanion(ExperimentPrefsCompanion data) {
    return ExperimentPref(
      id: data.id.present ? data.id.value : this.id,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExperimentPref(')
          ..write('id: $id, ')
          ..write('enabled: $enabled, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, enabled, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExperimentPref &&
          other.id == this.id &&
          other.enabled == this.enabled &&
          other.updatedAt == this.updatedAt);
}

class ExperimentPrefsCompanion extends UpdateCompanion<ExperimentPref> {
  final Value<int> id;
  final Value<bool> enabled;
  final Value<DateTime> updatedAt;
  const ExperimentPrefsCompanion({
    this.id = const Value.absent(),
    this.enabled = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ExperimentPrefsCompanion.insert({
    this.id = const Value.absent(),
    this.enabled = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  static Insertable<ExperimentPref> custom({
    Expression<int>? id,
    Expression<bool>? enabled,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (enabled != null) 'enabled': enabled,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ExperimentPrefsCompanion copyWith({
    Value<int>? id,
    Value<bool>? enabled,
    Value<DateTime>? updatedAt,
  }) {
    return ExperimentPrefsCompanion(
      id: id ?? this.id,
      enabled: enabled ?? this.enabled,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExperimentPrefsCompanion(')
          ..write('id: $id, ')
          ..write('enabled: $enabled, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $RoleOverridesTable extends RoleOverrides
    with TableInfo<$RoleOverridesTable, RoleOverride> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoleOverridesTable(this.attachedDatabase, [this._alias]);
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
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 8,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  List<GeneratedColumn> get $columns => [id, category, role, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'role_overrides';
  @override
  VerificationContext validateIntegrity(
    Insertable<RoleOverride> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
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
  RoleOverride map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoleOverride(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $RoleOverridesTable createAlias(String alias) {
    return $RoleOverridesTable(attachedDatabase, alias);
  }
}

class RoleOverride extends DataClass implements Insertable<RoleOverride> {
  final int id;
  final String category;
  final String role;
  final DateTime updatedAt;
  const RoleOverride({
    required this.id,
    required this.category,
    required this.role,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['category'] = Variable<String>(category);
    map['role'] = Variable<String>(role);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  RoleOverridesCompanion toCompanion(bool nullToAbsent) {
    return RoleOverridesCompanion(
      id: Value(id),
      category: Value(category),
      role: Value(role),
      updatedAt: Value(updatedAt),
    );
  }

  factory RoleOverride.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoleOverride(
      id: serializer.fromJson<int>(json['id']),
      category: serializer.fromJson<String>(json['category']),
      role: serializer.fromJson<String>(json['role']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'category': serializer.toJson<String>(category),
      'role': serializer.toJson<String>(role),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  RoleOverride copyWith({
    int? id,
    String? category,
    String? role,
    DateTime? updatedAt,
  }) => RoleOverride(
    id: id ?? this.id,
    category: category ?? this.category,
    role: role ?? this.role,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  RoleOverride copyWithCompanion(RoleOverridesCompanion data) {
    return RoleOverride(
      id: data.id.present ? data.id.value : this.id,
      category: data.category.present ? data.category.value : this.category,
      role: data.role.present ? data.role.value : this.role,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoleOverride(')
          ..write('id: $id, ')
          ..write('category: $category, ')
          ..write('role: $role, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, category, role, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoleOverride &&
          other.id == this.id &&
          other.category == this.category &&
          other.role == this.role &&
          other.updatedAt == this.updatedAt);
}

class RoleOverridesCompanion extends UpdateCompanion<RoleOverride> {
  final Value<int> id;
  final Value<String> category;
  final Value<String> role;
  final Value<DateTime> updatedAt;
  const RoleOverridesCompanion({
    this.id = const Value.absent(),
    this.category = const Value.absent(),
    this.role = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  RoleOverridesCompanion.insert({
    this.id = const Value.absent(),
    required String category,
    required String role,
    this.updatedAt = const Value.absent(),
  }) : category = Value(category),
       role = Value(role);
  static Insertable<RoleOverride> custom({
    Expression<int>? id,
    Expression<String>? category,
    Expression<String>? role,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (category != null) 'category': category,
      if (role != null) 'role': role,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  RoleOverridesCompanion copyWith({
    Value<int>? id,
    Value<String>? category,
    Value<String>? role,
    Value<DateTime>? updatedAt,
  }) {
    return RoleOverridesCompanion(
      id: id ?? this.id,
      category: category ?? this.category,
      role: role ?? this.role,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoleOverridesCompanion(')
          ..write('id: $id, ')
          ..write('category: $category, ')
          ..write('role: $role, ')
          ..write('updatedAt: $updatedAt')
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
  late final $PendingRecordsTable pendingRecords = $PendingRecordsTable(this);
  late final $ImportBatchesTable importBatches = $ImportBatchesTable(this);
  late final $BudgetsTable budgets = $BudgetsTable(this);
  late final $DailyClosesTable dailyCloses = $DailyClosesTable(this);
  late final $ClosePrefsTable closePrefs = $ClosePrefsTable(this);
  late final $CooloffsTable cooloffs = $CooloffsTable(this);
  late final $CooloffPrefsTable cooloffPrefs = $CooloffPrefsTable(this);
  late final $ExperimentsTable experiments = $ExperimentsTable(this);
  late final $ExperimentPrefsTable experimentPrefs = $ExperimentPrefsTable(
    this,
  );
  late final $RoleOverridesTable roleOverrides = $RoleOverridesTable(this);
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
    pendingRecords,
    importBatches,
    budgets,
    dailyCloses,
    closePrefs,
    cooloffs,
    cooloffPrefs,
    experiments,
    experimentPrefs,
    roleOverrides,
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
      Value<int?> importBatchId,
    });
typedef $$TransactionsTableUpdateCompanionBuilder =
    TransactionsCompanion Function({
      Value<int> id,
      Value<int> amountFen,
      Value<DateTime> occurredAt,
      Value<String> category,
      Value<String> note,
      Value<String> source,
      Value<int?> importBatchId,
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

  ColumnFilters<int> get importBatchId => $composableBuilder(
    column: $table.importBatchId,
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

  ColumnOrderings<int> get importBatchId => $composableBuilder(
    column: $table.importBatchId,
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

  GeneratedColumn<int> get importBatchId => $composableBuilder(
    column: $table.importBatchId,
    builder: (column) => column,
  );
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
                Value<int?> importBatchId = const Value.absent(),
              }) => TransactionsCompanion(
                id: id,
                amountFen: amountFen,
                occurredAt: occurredAt,
                category: category,
                note: note,
                source: source,
                importBatchId: importBatchId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int amountFen,
                required DateTime occurredAt,
                required String category,
                Value<String> note = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int?> importBatchId = const Value.absent(),
              }) => TransactionsCompanion.insert(
                id: id,
                amountFen: amountFen,
                occurredAt: occurredAt,
                category: category,
                note: note,
                source: source,
                importBatchId: importBatchId,
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
      Value<String?> deadline,
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
      Value<String?> deadline,
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

  ColumnFilters<String> get deadline => $composableBuilder(
    column: $table.deadline,
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

  ColumnOrderings<String> get deadline => $composableBuilder(
    column: $table.deadline,
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

  GeneratedColumn<String> get deadline =>
      $composableBuilder(column: $table.deadline, builder: (column) => column);

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
                Value<String?> deadline = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => GoalsCompanion(
                id: id,
                name: name,
                targetFen: targetFen,
                priceName: priceName,
                priceFen: priceFen,
                tier: tier,
                doneAt: doneAt,
                deadline: deadline,
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
                Value<String?> deadline = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => GoalsCompanion.insert(
                id: id,
                name: name,
                targetFen: targetFen,
                priceName: priceName,
                priceFen: priceFen,
                tier: tier,
                doneAt: doneAt,
                deadline: deadline,
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
typedef $$PendingRecordsTableCreateCompanionBuilder =
    PendingRecordsCompanion Function({
      Value<int> id,
      required int amountFen,
      required DateTime occurredAt,
      required String category,
      required String merchant,
      Value<String> sourcePkg,
      Value<String> notifyKey,
      Value<DateTime> createdAt,
    });
typedef $$PendingRecordsTableUpdateCompanionBuilder =
    PendingRecordsCompanion Function({
      Value<int> id,
      Value<int> amountFen,
      Value<DateTime> occurredAt,
      Value<String> category,
      Value<String> merchant,
      Value<String> sourcePkg,
      Value<String> notifyKey,
      Value<DateTime> createdAt,
    });

class $$PendingRecordsTableFilterComposer
    extends Composer<_$AppDb, $PendingRecordsTable> {
  $$PendingRecordsTableFilterComposer({
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

  ColumnFilters<String> get merchant => $composableBuilder(
    column: $table.merchant,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourcePkg => $composableBuilder(
    column: $table.sourcePkg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notifyKey => $composableBuilder(
    column: $table.notifyKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PendingRecordsTableOrderingComposer
    extends Composer<_$AppDb, $PendingRecordsTable> {
  $$PendingRecordsTableOrderingComposer({
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

  ColumnOrderings<String> get merchant => $composableBuilder(
    column: $table.merchant,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourcePkg => $composableBuilder(
    column: $table.sourcePkg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notifyKey => $composableBuilder(
    column: $table.notifyKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PendingRecordsTableAnnotationComposer
    extends Composer<_$AppDb, $PendingRecordsTable> {
  $$PendingRecordsTableAnnotationComposer({
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

  GeneratedColumn<String> get merchant =>
      $composableBuilder(column: $table.merchant, builder: (column) => column);

  GeneratedColumn<String> get sourcePkg =>
      $composableBuilder(column: $table.sourcePkg, builder: (column) => column);

  GeneratedColumn<String> get notifyKey =>
      $composableBuilder(column: $table.notifyKey, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PendingRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $PendingRecordsTable,
          PendingRecord,
          $$PendingRecordsTableFilterComposer,
          $$PendingRecordsTableOrderingComposer,
          $$PendingRecordsTableAnnotationComposer,
          $$PendingRecordsTableCreateCompanionBuilder,
          $$PendingRecordsTableUpdateCompanionBuilder,
          (
            PendingRecord,
            BaseReferences<_$AppDb, $PendingRecordsTable, PendingRecord>,
          ),
          PendingRecord,
          PrefetchHooks Function()
        > {
  $$PendingRecordsTableTableManager(_$AppDb db, $PendingRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PendingRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PendingRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> amountFen = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> merchant = const Value.absent(),
                Value<String> sourcePkg = const Value.absent(),
                Value<String> notifyKey = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PendingRecordsCompanion(
                id: id,
                amountFen: amountFen,
                occurredAt: occurredAt,
                category: category,
                merchant: merchant,
                sourcePkg: sourcePkg,
                notifyKey: notifyKey,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int amountFen,
                required DateTime occurredAt,
                required String category,
                required String merchant,
                Value<String> sourcePkg = const Value.absent(),
                Value<String> notifyKey = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PendingRecordsCompanion.insert(
                id: id,
                amountFen: amountFen,
                occurredAt: occurredAt,
                category: category,
                merchant: merchant,
                sourcePkg: sourcePkg,
                notifyKey: notifyKey,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PendingRecordsTable, PendingRecord>(table),
                  BaseReferences<_$AppDb, $PendingRecordsTable, PendingRecord>(
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

typedef $$PendingRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $PendingRecordsTable,
      PendingRecord,
      $$PendingRecordsTableFilterComposer,
      $$PendingRecordsTableOrderingComposer,
      $$PendingRecordsTableAnnotationComposer,
      $$PendingRecordsTableCreateCompanionBuilder,
      $$PendingRecordsTableUpdateCompanionBuilder,
      (
        PendingRecord,
        BaseReferences<_$AppDb, $PendingRecordsTable, PendingRecord>,
      ),
      PendingRecord,
      PrefetchHooks Function()
    >;
typedef $$ImportBatchesTableCreateCompanionBuilder =
    ImportBatchesCompanion Function({
      Value<int> id,
      Value<String> source,
      Value<String> fileName,
      Value<int> rowCount,
      Value<int> okCount,
      Value<int> failCount,
      Value<DateTime> createdAt,
    });
typedef $$ImportBatchesTableUpdateCompanionBuilder =
    ImportBatchesCompanion Function({
      Value<int> id,
      Value<String> source,
      Value<String> fileName,
      Value<int> rowCount,
      Value<int> okCount,
      Value<int> failCount,
      Value<DateTime> createdAt,
    });

class $$ImportBatchesTableFilterComposer
    extends Composer<_$AppDb, $ImportBatchesTable> {
  $$ImportBatchesTableFilterComposer({
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

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rowCount => $composableBuilder(
    column: $table.rowCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get okCount => $composableBuilder(
    column: $table.okCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get failCount => $composableBuilder(
    column: $table.failCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ImportBatchesTableOrderingComposer
    extends Composer<_$AppDb, $ImportBatchesTable> {
  $$ImportBatchesTableOrderingComposer({
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

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rowCount => $composableBuilder(
    column: $table.rowCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get okCount => $composableBuilder(
    column: $table.okCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get failCount => $composableBuilder(
    column: $table.failCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ImportBatchesTableAnnotationComposer
    extends Composer<_$AppDb, $ImportBatchesTable> {
  $$ImportBatchesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<int> get rowCount =>
      $composableBuilder(column: $table.rowCount, builder: (column) => column);

  GeneratedColumn<int> get okCount =>
      $composableBuilder(column: $table.okCount, builder: (column) => column);

  GeneratedColumn<int> get failCount =>
      $composableBuilder(column: $table.failCount, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ImportBatchesTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $ImportBatchesTable,
          ImportBatch,
          $$ImportBatchesTableFilterComposer,
          $$ImportBatchesTableOrderingComposer,
          $$ImportBatchesTableAnnotationComposer,
          $$ImportBatchesTableCreateCompanionBuilder,
          $$ImportBatchesTableUpdateCompanionBuilder,
          (
            ImportBatch,
            BaseReferences<_$AppDb, $ImportBatchesTable, ImportBatch>,
          ),
          ImportBatch,
          PrefetchHooks Function()
        > {
  $$ImportBatchesTableTableManager(_$AppDb db, $ImportBatchesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImportBatchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImportBatchesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ImportBatchesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String> fileName = const Value.absent(),
                Value<int> rowCount = const Value.absent(),
                Value<int> okCount = const Value.absent(),
                Value<int> failCount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ImportBatchesCompanion(
                id: id,
                source: source,
                fileName: fileName,
                rowCount: rowCount,
                okCount: okCount,
                failCount: failCount,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String> fileName = const Value.absent(),
                Value<int> rowCount = const Value.absent(),
                Value<int> okCount = const Value.absent(),
                Value<int> failCount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ImportBatchesCompanion.insert(
                id: id,
                source: source,
                fileName: fileName,
                rowCount: rowCount,
                okCount: okCount,
                failCount: failCount,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ImportBatchesTable, ImportBatch>(table),
                  BaseReferences<_$AppDb, $ImportBatchesTable, ImportBatch>(
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

typedef $$ImportBatchesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $ImportBatchesTable,
      ImportBatch,
      $$ImportBatchesTableFilterComposer,
      $$ImportBatchesTableOrderingComposer,
      $$ImportBatchesTableAnnotationComposer,
      $$ImportBatchesTableCreateCompanionBuilder,
      $$ImportBatchesTableUpdateCompanionBuilder,
      (ImportBatch, BaseReferences<_$AppDb, $ImportBatchesTable, ImportBatch>),
      ImportBatch,
      PrefetchHooks Function()
    >;
typedef $$BudgetsTableCreateCompanionBuilder =
    BudgetsCompanion Function({
      Value<int> id,
      required String monthKey,
      required int budgetFen,
      Value<int> basisFen,
      Value<int> tightenPct,
      Value<String> basis,
      Value<DateTime> createdAt,
    });
typedef $$BudgetsTableUpdateCompanionBuilder =
    BudgetsCompanion Function({
      Value<int> id,
      Value<String> monthKey,
      Value<int> budgetFen,
      Value<int> basisFen,
      Value<int> tightenPct,
      Value<String> basis,
      Value<DateTime> createdAt,
    });

class $$BudgetsTableFilterComposer extends Composer<_$AppDb, $BudgetsTable> {
  $$BudgetsTableFilterComposer({
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

  ColumnFilters<String> get monthKey => $composableBuilder(
    column: $table.monthKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get budgetFen => $composableBuilder(
    column: $table.budgetFen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get basisFen => $composableBuilder(
    column: $table.basisFen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tightenPct => $composableBuilder(
    column: $table.tightenPct,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get basis => $composableBuilder(
    column: $table.basis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BudgetsTableOrderingComposer extends Composer<_$AppDb, $BudgetsTable> {
  $$BudgetsTableOrderingComposer({
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

  ColumnOrderings<String> get monthKey => $composableBuilder(
    column: $table.monthKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get budgetFen => $composableBuilder(
    column: $table.budgetFen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get basisFen => $composableBuilder(
    column: $table.basisFen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tightenPct => $composableBuilder(
    column: $table.tightenPct,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get basis => $composableBuilder(
    column: $table.basis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BudgetsTableAnnotationComposer
    extends Composer<_$AppDb, $BudgetsTable> {
  $$BudgetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get monthKey =>
      $composableBuilder(column: $table.monthKey, builder: (column) => column);

  GeneratedColumn<int> get budgetFen =>
      $composableBuilder(column: $table.budgetFen, builder: (column) => column);

  GeneratedColumn<int> get basisFen =>
      $composableBuilder(column: $table.basisFen, builder: (column) => column);

  GeneratedColumn<int> get tightenPct => $composableBuilder(
    column: $table.tightenPct,
    builder: (column) => column,
  );

  GeneratedColumn<String> get basis =>
      $composableBuilder(column: $table.basis, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$BudgetsTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $BudgetsTable,
          Budget,
          $$BudgetsTableFilterComposer,
          $$BudgetsTableOrderingComposer,
          $$BudgetsTableAnnotationComposer,
          $$BudgetsTableCreateCompanionBuilder,
          $$BudgetsTableUpdateCompanionBuilder,
          (Budget, BaseReferences<_$AppDb, $BudgetsTable, Budget>),
          Budget,
          PrefetchHooks Function()
        > {
  $$BudgetsTableTableManager(_$AppDb db, $BudgetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BudgetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BudgetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BudgetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> monthKey = const Value.absent(),
                Value<int> budgetFen = const Value.absent(),
                Value<int> basisFen = const Value.absent(),
                Value<int> tightenPct = const Value.absent(),
                Value<String> basis = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => BudgetsCompanion(
                id: id,
                monthKey: monthKey,
                budgetFen: budgetFen,
                basisFen: basisFen,
                tightenPct: tightenPct,
                basis: basis,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String monthKey,
                required int budgetFen,
                Value<int> basisFen = const Value.absent(),
                Value<int> tightenPct = const Value.absent(),
                Value<String> basis = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => BudgetsCompanion.insert(
                id: id,
                monthKey: monthKey,
                budgetFen: budgetFen,
                basisFen: basisFen,
                tightenPct: tightenPct,
                basis: basis,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BudgetsTable, Budget>(table),
                  BaseReferences<_$AppDb, $BudgetsTable, Budget>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BudgetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $BudgetsTable,
      Budget,
      $$BudgetsTableFilterComposer,
      $$BudgetsTableOrderingComposer,
      $$BudgetsTableAnnotationComposer,
      $$BudgetsTableCreateCompanionBuilder,
      $$BudgetsTableUpdateCompanionBuilder,
      (Budget, BaseReferences<_$AppDb, $BudgetsTable, Budget>),
      Budget,
      PrefetchHooks Function()
    >;
typedef $$DailyClosesTableCreateCompanionBuilder =
    DailyClosesCompanion Function({
      Value<int> id,
      required String dateKey,
      Value<int> estimateFen,
      Value<String> status,
      Value<DateTime> createdAt,
    });
typedef $$DailyClosesTableUpdateCompanionBuilder =
    DailyClosesCompanion Function({
      Value<int> id,
      Value<String> dateKey,
      Value<int> estimateFen,
      Value<String> status,
      Value<DateTime> createdAt,
    });

class $$DailyClosesTableFilterComposer
    extends Composer<_$AppDb, $DailyClosesTable> {
  $$DailyClosesTableFilterComposer({
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

  ColumnFilters<String> get dateKey => $composableBuilder(
    column: $table.dateKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get estimateFen => $composableBuilder(
    column: $table.estimateFen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DailyClosesTableOrderingComposer
    extends Composer<_$AppDb, $DailyClosesTable> {
  $$DailyClosesTableOrderingComposer({
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

  ColumnOrderings<String> get dateKey => $composableBuilder(
    column: $table.dateKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get estimateFen => $composableBuilder(
    column: $table.estimateFen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DailyClosesTableAnnotationComposer
    extends Composer<_$AppDb, $DailyClosesTable> {
  $$DailyClosesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get dateKey =>
      $composableBuilder(column: $table.dateKey, builder: (column) => column);

  GeneratedColumn<int> get estimateFen => $composableBuilder(
    column: $table.estimateFen,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$DailyClosesTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $DailyClosesTable,
          DailyClose,
          $$DailyClosesTableFilterComposer,
          $$DailyClosesTableOrderingComposer,
          $$DailyClosesTableAnnotationComposer,
          $$DailyClosesTableCreateCompanionBuilder,
          $$DailyClosesTableUpdateCompanionBuilder,
          (DailyClose, BaseReferences<_$AppDb, $DailyClosesTable, DailyClose>),
          DailyClose,
          PrefetchHooks Function()
        > {
  $$DailyClosesTableTableManager(_$AppDb db, $DailyClosesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyClosesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyClosesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyClosesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> dateKey = const Value.absent(),
                Value<int> estimateFen = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => DailyClosesCompanion(
                id: id,
                dateKey: dateKey,
                estimateFen: estimateFen,
                status: status,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String dateKey,
                Value<int> estimateFen = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => DailyClosesCompanion.insert(
                id: id,
                dateKey: dateKey,
                estimateFen: estimateFen,
                status: status,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DailyClosesTable, DailyClose>(table),
                  BaseReferences<_$AppDb, $DailyClosesTable, DailyClose>(
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

typedef $$DailyClosesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $DailyClosesTable,
      DailyClose,
      $$DailyClosesTableFilterComposer,
      $$DailyClosesTableOrderingComposer,
      $$DailyClosesTableAnnotationComposer,
      $$DailyClosesTableCreateCompanionBuilder,
      $$DailyClosesTableUpdateCompanionBuilder,
      (DailyClose, BaseReferences<_$AppDb, $DailyClosesTable, DailyClose>),
      DailyClose,
      PrefetchHooks Function()
    >;
typedef $$ClosePrefsTableCreateCompanionBuilder =
    ClosePrefsCompanion Function({
      Value<int> id,
      Value<bool> enabled,
      Value<DateTime> updatedAt,
    });
typedef $$ClosePrefsTableUpdateCompanionBuilder =
    ClosePrefsCompanion Function({
      Value<int> id,
      Value<bool> enabled,
      Value<DateTime> updatedAt,
    });

class $$ClosePrefsTableFilterComposer
    extends Composer<_$AppDb, $ClosePrefsTable> {
  $$ClosePrefsTableFilterComposer({
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

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ClosePrefsTableOrderingComposer
    extends Composer<_$AppDb, $ClosePrefsTable> {
  $$ClosePrefsTableOrderingComposer({
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

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ClosePrefsTableAnnotationComposer
    extends Composer<_$AppDb, $ClosePrefsTable> {
  $$ClosePrefsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ClosePrefsTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $ClosePrefsTable,
          ClosePref,
          $$ClosePrefsTableFilterComposer,
          $$ClosePrefsTableOrderingComposer,
          $$ClosePrefsTableAnnotationComposer,
          $$ClosePrefsTableCreateCompanionBuilder,
          $$ClosePrefsTableUpdateCompanionBuilder,
          (ClosePref, BaseReferences<_$AppDb, $ClosePrefsTable, ClosePref>),
          ClosePref,
          PrefetchHooks Function()
        > {
  $$ClosePrefsTableTableManager(_$AppDb db, $ClosePrefsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClosePrefsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClosePrefsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClosePrefsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ClosePrefsCompanion(
                id: id,
                enabled: enabled,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ClosePrefsCompanion.insert(
                id: id,
                enabled: enabled,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ClosePrefsTable, ClosePref>(table),
                  BaseReferences<_$AppDb, $ClosePrefsTable, ClosePref>(
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

typedef $$ClosePrefsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $ClosePrefsTable,
      ClosePref,
      $$ClosePrefsTableFilterComposer,
      $$ClosePrefsTableOrderingComposer,
      $$ClosePrefsTableAnnotationComposer,
      $$ClosePrefsTableCreateCompanionBuilder,
      $$ClosePrefsTableUpdateCompanionBuilder,
      (ClosePref, BaseReferences<_$AppDb, $ClosePrefsTable, ClosePref>),
      ClosePref,
      PrefetchHooks Function()
    >;
typedef $$CooloffsTableCreateCompanionBuilder =
    CooloffsCompanion Function({
      Value<int> id,
      required int txId,
      required int amountFen,
      Value<DateTime> proposedAt,
      Value<String> status,
      Value<DateTime?> decidedAt,
    });
typedef $$CooloffsTableUpdateCompanionBuilder =
    CooloffsCompanion Function({
      Value<int> id,
      Value<int> txId,
      Value<int> amountFen,
      Value<DateTime> proposedAt,
      Value<String> status,
      Value<DateTime?> decidedAt,
    });

class $$CooloffsTableFilterComposer extends Composer<_$AppDb, $CooloffsTable> {
  $$CooloffsTableFilterComposer({
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

  ColumnFilters<int> get txId => $composableBuilder(
    column: $table.txId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountFen => $composableBuilder(
    column: $table.amountFen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get proposedAt => $composableBuilder(
    column: $table.proposedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get decidedAt => $composableBuilder(
    column: $table.decidedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CooloffsTableOrderingComposer
    extends Composer<_$AppDb, $CooloffsTable> {
  $$CooloffsTableOrderingComposer({
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

  ColumnOrderings<int> get txId => $composableBuilder(
    column: $table.txId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountFen => $composableBuilder(
    column: $table.amountFen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get proposedAt => $composableBuilder(
    column: $table.proposedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get decidedAt => $composableBuilder(
    column: $table.decidedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CooloffsTableAnnotationComposer
    extends Composer<_$AppDb, $CooloffsTable> {
  $$CooloffsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get txId =>
      $composableBuilder(column: $table.txId, builder: (column) => column);

  GeneratedColumn<int> get amountFen =>
      $composableBuilder(column: $table.amountFen, builder: (column) => column);

  GeneratedColumn<DateTime> get proposedAt => $composableBuilder(
    column: $table.proposedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get decidedAt =>
      $composableBuilder(column: $table.decidedAt, builder: (column) => column);
}

class $$CooloffsTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $CooloffsTable,
          Cooloff,
          $$CooloffsTableFilterComposer,
          $$CooloffsTableOrderingComposer,
          $$CooloffsTableAnnotationComposer,
          $$CooloffsTableCreateCompanionBuilder,
          $$CooloffsTableUpdateCompanionBuilder,
          (Cooloff, BaseReferences<_$AppDb, $CooloffsTable, Cooloff>),
          Cooloff,
          PrefetchHooks Function()
        > {
  $$CooloffsTableTableManager(_$AppDb db, $CooloffsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CooloffsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CooloffsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CooloffsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> txId = const Value.absent(),
                Value<int> amountFen = const Value.absent(),
                Value<DateTime> proposedAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> decidedAt = const Value.absent(),
              }) => CooloffsCompanion(
                id: id,
                txId: txId,
                amountFen: amountFen,
                proposedAt: proposedAt,
                status: status,
                decidedAt: decidedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int txId,
                required int amountFen,
                Value<DateTime> proposedAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> decidedAt = const Value.absent(),
              }) => CooloffsCompanion.insert(
                id: id,
                txId: txId,
                amountFen: amountFen,
                proposedAt: proposedAt,
                status: status,
                decidedAt: decidedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CooloffsTable, Cooloff>(table),
                  BaseReferences<_$AppDb, $CooloffsTable, Cooloff>(
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

typedef $$CooloffsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $CooloffsTable,
      Cooloff,
      $$CooloffsTableFilterComposer,
      $$CooloffsTableOrderingComposer,
      $$CooloffsTableAnnotationComposer,
      $$CooloffsTableCreateCompanionBuilder,
      $$CooloffsTableUpdateCompanionBuilder,
      (Cooloff, BaseReferences<_$AppDb, $CooloffsTable, Cooloff>),
      Cooloff,
      PrefetchHooks Function()
    >;
typedef $$CooloffPrefsTableCreateCompanionBuilder =
    CooloffPrefsCompanion Function({
      Value<int> id,
      Value<bool> enabled,
      Value<int> customFen,
      Value<DateTime> updatedAt,
    });
typedef $$CooloffPrefsTableUpdateCompanionBuilder =
    CooloffPrefsCompanion Function({
      Value<int> id,
      Value<bool> enabled,
      Value<int> customFen,
      Value<DateTime> updatedAt,
    });

class $$CooloffPrefsTableFilterComposer
    extends Composer<_$AppDb, $CooloffPrefsTable> {
  $$CooloffPrefsTableFilterComposer({
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

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get customFen => $composableBuilder(
    column: $table.customFen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CooloffPrefsTableOrderingComposer
    extends Composer<_$AppDb, $CooloffPrefsTable> {
  $$CooloffPrefsTableOrderingComposer({
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

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get customFen => $composableBuilder(
    column: $table.customFen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CooloffPrefsTableAnnotationComposer
    extends Composer<_$AppDb, $CooloffPrefsTable> {
  $$CooloffPrefsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<int> get customFen =>
      $composableBuilder(column: $table.customFen, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CooloffPrefsTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $CooloffPrefsTable,
          CooloffPref,
          $$CooloffPrefsTableFilterComposer,
          $$CooloffPrefsTableOrderingComposer,
          $$CooloffPrefsTableAnnotationComposer,
          $$CooloffPrefsTableCreateCompanionBuilder,
          $$CooloffPrefsTableUpdateCompanionBuilder,
          (
            CooloffPref,
            BaseReferences<_$AppDb, $CooloffPrefsTable, CooloffPref>,
          ),
          CooloffPref,
          PrefetchHooks Function()
        > {
  $$CooloffPrefsTableTableManager(_$AppDb db, $CooloffPrefsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CooloffPrefsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CooloffPrefsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CooloffPrefsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<int> customFen = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => CooloffPrefsCompanion(
                id: id,
                enabled: enabled,
                customFen: customFen,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<int> customFen = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => CooloffPrefsCompanion.insert(
                id: id,
                enabled: enabled,
                customFen: customFen,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CooloffPrefsTable, CooloffPref>(table),
                  BaseReferences<_$AppDb, $CooloffPrefsTable, CooloffPref>(
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

typedef $$CooloffPrefsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $CooloffPrefsTable,
      CooloffPref,
      $$CooloffPrefsTableFilterComposer,
      $$CooloffPrefsTableOrderingComposer,
      $$CooloffPrefsTableAnnotationComposer,
      $$CooloffPrefsTableCreateCompanionBuilder,
      $$CooloffPrefsTableUpdateCompanionBuilder,
      (CooloffPref, BaseReferences<_$AppDb, $CooloffPrefsTable, CooloffPref>),
      CooloffPref,
      PrefetchHooks Function()
    >;
typedef $$ExperimentsTableCreateCompanionBuilder =
    ExperimentsCompanion Function({
      Value<int> id,
      required String templateId,
      required String name,
      required int dailySaveFen,
      required DateTime startDate,
      Value<String> checkIns,
      Value<String> status,
      Value<DateTime> createdAt,
    });
typedef $$ExperimentsTableUpdateCompanionBuilder =
    ExperimentsCompanion Function({
      Value<int> id,
      Value<String> templateId,
      Value<String> name,
      Value<int> dailySaveFen,
      Value<DateTime> startDate,
      Value<String> checkIns,
      Value<String> status,
      Value<DateTime> createdAt,
    });

class $$ExperimentsTableFilterComposer
    extends Composer<_$AppDb, $ExperimentsTable> {
  $$ExperimentsTableFilterComposer({
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

  ColumnFilters<String> get templateId => $composableBuilder(
    column: $table.templateId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dailySaveFen => $composableBuilder(
    column: $table.dailySaveFen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get checkIns => $composableBuilder(
    column: $table.checkIns,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExperimentsTableOrderingComposer
    extends Composer<_$AppDb, $ExperimentsTable> {
  $$ExperimentsTableOrderingComposer({
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

  ColumnOrderings<String> get templateId => $composableBuilder(
    column: $table.templateId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dailySaveFen => $composableBuilder(
    column: $table.dailySaveFen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get checkIns => $composableBuilder(
    column: $table.checkIns,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExperimentsTableAnnotationComposer
    extends Composer<_$AppDb, $ExperimentsTable> {
  $$ExperimentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get templateId => $composableBuilder(
    column: $table.templateId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get dailySaveFen => $composableBuilder(
    column: $table.dailySaveFen,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<String> get checkIns =>
      $composableBuilder(column: $table.checkIns, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ExperimentsTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $ExperimentsTable,
          Experiment,
          $$ExperimentsTableFilterComposer,
          $$ExperimentsTableOrderingComposer,
          $$ExperimentsTableAnnotationComposer,
          $$ExperimentsTableCreateCompanionBuilder,
          $$ExperimentsTableUpdateCompanionBuilder,
          (Experiment, BaseReferences<_$AppDb, $ExperimentsTable, Experiment>),
          Experiment,
          PrefetchHooks Function()
        > {
  $$ExperimentsTableTableManager(_$AppDb db, $ExperimentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExperimentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExperimentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExperimentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> templateId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> dailySaveFen = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<String> checkIns = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ExperimentsCompanion(
                id: id,
                templateId: templateId,
                name: name,
                dailySaveFen: dailySaveFen,
                startDate: startDate,
                checkIns: checkIns,
                status: status,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String templateId,
                required String name,
                required int dailySaveFen,
                required DateTime startDate,
                Value<String> checkIns = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ExperimentsCompanion.insert(
                id: id,
                templateId: templateId,
                name: name,
                dailySaveFen: dailySaveFen,
                startDate: startDate,
                checkIns: checkIns,
                status: status,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ExperimentsTable, Experiment>(table),
                  BaseReferences<_$AppDb, $ExperimentsTable, Experiment>(
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

typedef $$ExperimentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $ExperimentsTable,
      Experiment,
      $$ExperimentsTableFilterComposer,
      $$ExperimentsTableOrderingComposer,
      $$ExperimentsTableAnnotationComposer,
      $$ExperimentsTableCreateCompanionBuilder,
      $$ExperimentsTableUpdateCompanionBuilder,
      (Experiment, BaseReferences<_$AppDb, $ExperimentsTable, Experiment>),
      Experiment,
      PrefetchHooks Function()
    >;
typedef $$ExperimentPrefsTableCreateCompanionBuilder =
    ExperimentPrefsCompanion Function({
      Value<int> id,
      Value<bool> enabled,
      Value<DateTime> updatedAt,
    });
typedef $$ExperimentPrefsTableUpdateCompanionBuilder =
    ExperimentPrefsCompanion Function({
      Value<int> id,
      Value<bool> enabled,
      Value<DateTime> updatedAt,
    });

class $$ExperimentPrefsTableFilterComposer
    extends Composer<_$AppDb, $ExperimentPrefsTable> {
  $$ExperimentPrefsTableFilterComposer({
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

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExperimentPrefsTableOrderingComposer
    extends Composer<_$AppDb, $ExperimentPrefsTable> {
  $$ExperimentPrefsTableOrderingComposer({
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

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExperimentPrefsTableAnnotationComposer
    extends Composer<_$AppDb, $ExperimentPrefsTable> {
  $$ExperimentPrefsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ExperimentPrefsTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $ExperimentPrefsTable,
          ExperimentPref,
          $$ExperimentPrefsTableFilterComposer,
          $$ExperimentPrefsTableOrderingComposer,
          $$ExperimentPrefsTableAnnotationComposer,
          $$ExperimentPrefsTableCreateCompanionBuilder,
          $$ExperimentPrefsTableUpdateCompanionBuilder,
          (
            ExperimentPref,
            BaseReferences<_$AppDb, $ExperimentPrefsTable, ExperimentPref>,
          ),
          ExperimentPref,
          PrefetchHooks Function()
        > {
  $$ExperimentPrefsTableTableManager(_$AppDb db, $ExperimentPrefsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExperimentPrefsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExperimentPrefsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExperimentPrefsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ExperimentPrefsCompanion(
                id: id,
                enabled: enabled,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ExperimentPrefsCompanion.insert(
                id: id,
                enabled: enabled,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ExperimentPrefsTable, ExperimentPref>(table),
                  BaseReferences<
                    _$AppDb,
                    $ExperimentPrefsTable,
                    ExperimentPref
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExperimentPrefsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $ExperimentPrefsTable,
      ExperimentPref,
      $$ExperimentPrefsTableFilterComposer,
      $$ExperimentPrefsTableOrderingComposer,
      $$ExperimentPrefsTableAnnotationComposer,
      $$ExperimentPrefsTableCreateCompanionBuilder,
      $$ExperimentPrefsTableUpdateCompanionBuilder,
      (
        ExperimentPref,
        BaseReferences<_$AppDb, $ExperimentPrefsTable, ExperimentPref>,
      ),
      ExperimentPref,
      PrefetchHooks Function()
    >;
typedef $$RoleOverridesTableCreateCompanionBuilder =
    RoleOverridesCompanion Function({
      Value<int> id,
      required String category,
      required String role,
      Value<DateTime> updatedAt,
    });
typedef $$RoleOverridesTableUpdateCompanionBuilder =
    RoleOverridesCompanion Function({
      Value<int> id,
      Value<String> category,
      Value<String> role,
      Value<DateTime> updatedAt,
    });

class $$RoleOverridesTableFilterComposer
    extends Composer<_$AppDb, $RoleOverridesTable> {
  $$RoleOverridesTableFilterComposer({
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

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RoleOverridesTableOrderingComposer
    extends Composer<_$AppDb, $RoleOverridesTable> {
  $$RoleOverridesTableOrderingComposer({
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

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RoleOverridesTableAnnotationComposer
    extends Composer<_$AppDb, $RoleOverridesTable> {
  $$RoleOverridesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$RoleOverridesTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $RoleOverridesTable,
          RoleOverride,
          $$RoleOverridesTableFilterComposer,
          $$RoleOverridesTableOrderingComposer,
          $$RoleOverridesTableAnnotationComposer,
          $$RoleOverridesTableCreateCompanionBuilder,
          $$RoleOverridesTableUpdateCompanionBuilder,
          (
            RoleOverride,
            BaseReferences<_$AppDb, $RoleOverridesTable, RoleOverride>,
          ),
          RoleOverride,
          PrefetchHooks Function()
        > {
  $$RoleOverridesTableTableManager(_$AppDb db, $RoleOverridesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoleOverridesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoleOverridesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoleOverridesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => RoleOverridesCompanion(
                id: id,
                category: category,
                role: role,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String category,
                required String role,
                Value<DateTime> updatedAt = const Value.absent(),
              }) => RoleOverridesCompanion.insert(
                id: id,
                category: category,
                role: role,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RoleOverridesTable, RoleOverride>(table),
                  BaseReferences<_$AppDb, $RoleOverridesTable, RoleOverride>(
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

typedef $$RoleOverridesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $RoleOverridesTable,
      RoleOverride,
      $$RoleOverridesTableFilterComposer,
      $$RoleOverridesTableOrderingComposer,
      $$RoleOverridesTableAnnotationComposer,
      $$RoleOverridesTableCreateCompanionBuilder,
      $$RoleOverridesTableUpdateCompanionBuilder,
      (
        RoleOverride,
        BaseReferences<_$AppDb, $RoleOverridesTable, RoleOverride>,
      ),
      RoleOverride,
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
  $$PendingRecordsTableTableManager get pendingRecords =>
      $$PendingRecordsTableTableManager(_db, _db.pendingRecords);
  $$ImportBatchesTableTableManager get importBatches =>
      $$ImportBatchesTableTableManager(_db, _db.importBatches);
  $$BudgetsTableTableManager get budgets =>
      $$BudgetsTableTableManager(_db, _db.budgets);
  $$DailyClosesTableTableManager get dailyCloses =>
      $$DailyClosesTableTableManager(_db, _db.dailyCloses);
  $$ClosePrefsTableTableManager get closePrefs =>
      $$ClosePrefsTableTableManager(_db, _db.closePrefs);
  $$CooloffsTableTableManager get cooloffs =>
      $$CooloffsTableTableManager(_db, _db.cooloffs);
  $$CooloffPrefsTableTableManager get cooloffPrefs =>
      $$CooloffPrefsTableTableManager(_db, _db.cooloffPrefs);
  $$ExperimentsTableTableManager get experiments =>
      $$ExperimentsTableTableManager(_db, _db.experiments);
  $$ExperimentPrefsTableTableManager get experimentPrefs =>
      $$ExperimentPrefsTableTableManager(_db, _db.experimentPrefs);
  $$RoleOverridesTableTableManager get roleOverrides =>
      $$RoleOverridesTableTableManager(_db, _db.roleOverrides);
}
