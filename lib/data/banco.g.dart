// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'banco.dart';

// ignore_for_file: type=lint
class $DividasTable extends Dividas with TableInfo<$DividasTable, Divida> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DividasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nomeMeta = const VerificationMeta('nome');
  @override
  late final GeneratedColumn<String> nome = GeneratedColumn<String>(
    'nome',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _saldoCentavosMeta = const VerificationMeta(
    'saldoCentavos',
  );
  @override
  late final GeneratedColumn<int> saldoCentavos = GeneratedColumn<int>(
    'saldo_centavos',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _parcelaCentavosMeta = const VerificationMeta(
    'parcelaCentavos',
  );
  @override
  late final GeneratedColumn<int> parcelaCentavos = GeneratedColumn<int>(
    'parcela_centavos',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _diaVencimentoMeta = const VerificationMeta(
    'diaVencimento',
  );
  @override
  late final GeneratedColumn<int> diaVencimento = GeneratedColumn<int>(
    'dia_vencimento',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _parcelasRestantesMeta = const VerificationMeta(
    'parcelasRestantes',
  );
  @override
  late final GeneratedColumn<int> parcelasRestantes = GeneratedColumn<int>(
    'parcelas_restantes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _parcelasTotalMeta = const VerificationMeta(
    'parcelasTotal',
  );
  @override
  late final GeneratedColumn<int> parcelasTotal = GeneratedColumn<int>(
    'parcelas_total',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _quitadaEmMeta = const VerificationMeta(
    'quitadaEm',
  );
  @override
  late final GeneratedColumn<DateTime> quitadaEm = GeneratedColumn<DateTime>(
    'quitada_em',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _criadaEmMeta = const VerificationMeta(
    'criadaEm',
  );
  @override
  late final GeneratedColumn<DateTime> criadaEm = GeneratedColumn<DateTime>(
    'criada_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nome,
    saldoCentavos,
    parcelaCentavos,
    diaVencimento,
    parcelasRestantes,
    parcelasTotal,
    quitadaEm,
    criadaEm,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dividas';
  @override
  VerificationContext validateIntegrity(
    Insertable<Divida> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('nome')) {
      context.handle(
        _nomeMeta,
        nome.isAcceptableOrUnknown(data['nome']!, _nomeMeta),
      );
    } else if (isInserting) {
      context.missing(_nomeMeta);
    }
    if (data.containsKey('saldo_centavos')) {
      context.handle(
        _saldoCentavosMeta,
        saldoCentavos.isAcceptableOrUnknown(
          data['saldo_centavos']!,
          _saldoCentavosMeta,
        ),
      );
    }
    if (data.containsKey('parcela_centavos')) {
      context.handle(
        _parcelaCentavosMeta,
        parcelaCentavos.isAcceptableOrUnknown(
          data['parcela_centavos']!,
          _parcelaCentavosMeta,
        ),
      );
    }
    if (data.containsKey('dia_vencimento')) {
      context.handle(
        _diaVencimentoMeta,
        diaVencimento.isAcceptableOrUnknown(
          data['dia_vencimento']!,
          _diaVencimentoMeta,
        ),
      );
    }
    if (data.containsKey('parcelas_restantes')) {
      context.handle(
        _parcelasRestantesMeta,
        parcelasRestantes.isAcceptableOrUnknown(
          data['parcelas_restantes']!,
          _parcelasRestantesMeta,
        ),
      );
    }
    if (data.containsKey('parcelas_total')) {
      context.handle(
        _parcelasTotalMeta,
        parcelasTotal.isAcceptableOrUnknown(
          data['parcelas_total']!,
          _parcelasTotalMeta,
        ),
      );
    }
    if (data.containsKey('quitada_em')) {
      context.handle(
        _quitadaEmMeta,
        quitadaEm.isAcceptableOrUnknown(data['quitada_em']!, _quitadaEmMeta),
      );
    }
    if (data.containsKey('criada_em')) {
      context.handle(
        _criadaEmMeta,
        criadaEm.isAcceptableOrUnknown(data['criada_em']!, _criadaEmMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Divida map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Divida(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      nome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nome'],
      )!,
      saldoCentavos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}saldo_centavos'],
      )!,
      parcelaCentavos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}parcela_centavos'],
      )!,
      diaVencimento: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dia_vencimento'],
      )!,
      parcelasRestantes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}parcelas_restantes'],
      )!,
      parcelasTotal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}parcelas_total'],
      )!,
      quitadaEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}quitada_em'],
      ),
      criadaEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}criada_em'],
      )!,
    );
  }

  @override
  $DividasTable createAlias(String alias) {
    return $DividasTable(attachedDatabase, alias);
  }
}

class Divida extends DataClass implements Insertable<Divida> {
  final String id;
  final String nome;

  /// Guardado em **centavos**, como inteiro.
  ///
  /// double para dinheiro acumula erro de ponto flutuante: 0.1 + 0.2 dá
  /// 0.30000000000000004. Num app que soma parcela todo mês por 24 meses,
  /// isso vira centavo errado na tela — e o usuário confere na fatura.
  final int saldoCentavos;
  final int parcelaCentavos;
  final int diaVencimento;
  final int parcelasRestantes;
  final int parcelasTotal;
  final DateTime? quitadaEm;
  final DateTime criadaEm;
  const Divida({
    required this.id,
    required this.nome,
    required this.saldoCentavos,
    required this.parcelaCentavos,
    required this.diaVencimento,
    required this.parcelasRestantes,
    required this.parcelasTotal,
    this.quitadaEm,
    required this.criadaEm,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['nome'] = Variable<String>(nome);
    map['saldo_centavos'] = Variable<int>(saldoCentavos);
    map['parcela_centavos'] = Variable<int>(parcelaCentavos);
    map['dia_vencimento'] = Variable<int>(diaVencimento);
    map['parcelas_restantes'] = Variable<int>(parcelasRestantes);
    map['parcelas_total'] = Variable<int>(parcelasTotal);
    if (!nullToAbsent || quitadaEm != null) {
      map['quitada_em'] = Variable<DateTime>(quitadaEm);
    }
    map['criada_em'] = Variable<DateTime>(criadaEm);
    return map;
  }

  DividasCompanion toCompanion(bool nullToAbsent) {
    return DividasCompanion(
      id: Value(id),
      nome: Value(nome),
      saldoCentavos: Value(saldoCentavos),
      parcelaCentavos: Value(parcelaCentavos),
      diaVencimento: Value(diaVencimento),
      parcelasRestantes: Value(parcelasRestantes),
      parcelasTotal: Value(parcelasTotal),
      quitadaEm: quitadaEm == null && nullToAbsent
          ? const Value.absent()
          : Value(quitadaEm),
      criadaEm: Value(criadaEm),
    );
  }

  factory Divida.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Divida(
      id: serializer.fromJson<String>(json['id']),
      nome: serializer.fromJson<String>(json['nome']),
      saldoCentavos: serializer.fromJson<int>(json['saldoCentavos']),
      parcelaCentavos: serializer.fromJson<int>(json['parcelaCentavos']),
      diaVencimento: serializer.fromJson<int>(json['diaVencimento']),
      parcelasRestantes: serializer.fromJson<int>(json['parcelasRestantes']),
      parcelasTotal: serializer.fromJson<int>(json['parcelasTotal']),
      quitadaEm: serializer.fromJson<DateTime?>(json['quitadaEm']),
      criadaEm: serializer.fromJson<DateTime>(json['criadaEm']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'nome': serializer.toJson<String>(nome),
      'saldoCentavos': serializer.toJson<int>(saldoCentavos),
      'parcelaCentavos': serializer.toJson<int>(parcelaCentavos),
      'diaVencimento': serializer.toJson<int>(diaVencimento),
      'parcelasRestantes': serializer.toJson<int>(parcelasRestantes),
      'parcelasTotal': serializer.toJson<int>(parcelasTotal),
      'quitadaEm': serializer.toJson<DateTime?>(quitadaEm),
      'criadaEm': serializer.toJson<DateTime>(criadaEm),
    };
  }

  Divida copyWith({
    String? id,
    String? nome,
    int? saldoCentavos,
    int? parcelaCentavos,
    int? diaVencimento,
    int? parcelasRestantes,
    int? parcelasTotal,
    Value<DateTime?> quitadaEm = const Value.absent(),
    DateTime? criadaEm,
  }) => Divida(
    id: id ?? this.id,
    nome: nome ?? this.nome,
    saldoCentavos: saldoCentavos ?? this.saldoCentavos,
    parcelaCentavos: parcelaCentavos ?? this.parcelaCentavos,
    diaVencimento: diaVencimento ?? this.diaVencimento,
    parcelasRestantes: parcelasRestantes ?? this.parcelasRestantes,
    parcelasTotal: parcelasTotal ?? this.parcelasTotal,
    quitadaEm: quitadaEm.present ? quitadaEm.value : this.quitadaEm,
    criadaEm: criadaEm ?? this.criadaEm,
  );
  Divida copyWithCompanion(DividasCompanion data) {
    return Divida(
      id: data.id.present ? data.id.value : this.id,
      nome: data.nome.present ? data.nome.value : this.nome,
      saldoCentavos: data.saldoCentavos.present
          ? data.saldoCentavos.value
          : this.saldoCentavos,
      parcelaCentavos: data.parcelaCentavos.present
          ? data.parcelaCentavos.value
          : this.parcelaCentavos,
      diaVencimento: data.diaVencimento.present
          ? data.diaVencimento.value
          : this.diaVencimento,
      parcelasRestantes: data.parcelasRestantes.present
          ? data.parcelasRestantes.value
          : this.parcelasRestantes,
      parcelasTotal: data.parcelasTotal.present
          ? data.parcelasTotal.value
          : this.parcelasTotal,
      quitadaEm: data.quitadaEm.present ? data.quitadaEm.value : this.quitadaEm,
      criadaEm: data.criadaEm.present ? data.criadaEm.value : this.criadaEm,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Divida(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('saldoCentavos: $saldoCentavos, ')
          ..write('parcelaCentavos: $parcelaCentavos, ')
          ..write('diaVencimento: $diaVencimento, ')
          ..write('parcelasRestantes: $parcelasRestantes, ')
          ..write('parcelasTotal: $parcelasTotal, ')
          ..write('quitadaEm: $quitadaEm, ')
          ..write('criadaEm: $criadaEm')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    nome,
    saldoCentavos,
    parcelaCentavos,
    diaVencimento,
    parcelasRestantes,
    parcelasTotal,
    quitadaEm,
    criadaEm,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Divida &&
          other.id == this.id &&
          other.nome == this.nome &&
          other.saldoCentavos == this.saldoCentavos &&
          other.parcelaCentavos == this.parcelaCentavos &&
          other.diaVencimento == this.diaVencimento &&
          other.parcelasRestantes == this.parcelasRestantes &&
          other.parcelasTotal == this.parcelasTotal &&
          other.quitadaEm == this.quitadaEm &&
          other.criadaEm == this.criadaEm);
}

class DividasCompanion extends UpdateCompanion<Divida> {
  final Value<String> id;
  final Value<String> nome;
  final Value<int> saldoCentavos;
  final Value<int> parcelaCentavos;
  final Value<int> diaVencimento;
  final Value<int> parcelasRestantes;
  final Value<int> parcelasTotal;
  final Value<DateTime?> quitadaEm;
  final Value<DateTime> criadaEm;
  final Value<int> rowid;
  const DividasCompanion({
    this.id = const Value.absent(),
    this.nome = const Value.absent(),
    this.saldoCentavos = const Value.absent(),
    this.parcelaCentavos = const Value.absent(),
    this.diaVencimento = const Value.absent(),
    this.parcelasRestantes = const Value.absent(),
    this.parcelasTotal = const Value.absent(),
    this.quitadaEm = const Value.absent(),
    this.criadaEm = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DividasCompanion.insert({
    required String id,
    required String nome,
    this.saldoCentavos = const Value.absent(),
    this.parcelaCentavos = const Value.absent(),
    this.diaVencimento = const Value.absent(),
    this.parcelasRestantes = const Value.absent(),
    this.parcelasTotal = const Value.absent(),
    this.quitadaEm = const Value.absent(),
    this.criadaEm = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       nome = Value(nome);
  static Insertable<Divida> custom({
    Expression<String>? id,
    Expression<String>? nome,
    Expression<int>? saldoCentavos,
    Expression<int>? parcelaCentavos,
    Expression<int>? diaVencimento,
    Expression<int>? parcelasRestantes,
    Expression<int>? parcelasTotal,
    Expression<DateTime>? quitadaEm,
    Expression<DateTime>? criadaEm,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nome != null) 'nome': nome,
      if (saldoCentavos != null) 'saldo_centavos': saldoCentavos,
      if (parcelaCentavos != null) 'parcela_centavos': parcelaCentavos,
      if (diaVencimento != null) 'dia_vencimento': diaVencimento,
      if (parcelasRestantes != null) 'parcelas_restantes': parcelasRestantes,
      if (parcelasTotal != null) 'parcelas_total': parcelasTotal,
      if (quitadaEm != null) 'quitada_em': quitadaEm,
      if (criadaEm != null) 'criada_em': criadaEm,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DividasCompanion copyWith({
    Value<String>? id,
    Value<String>? nome,
    Value<int>? saldoCentavos,
    Value<int>? parcelaCentavos,
    Value<int>? diaVencimento,
    Value<int>? parcelasRestantes,
    Value<int>? parcelasTotal,
    Value<DateTime?>? quitadaEm,
    Value<DateTime>? criadaEm,
    Value<int>? rowid,
  }) {
    return DividasCompanion(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      saldoCentavos: saldoCentavos ?? this.saldoCentavos,
      parcelaCentavos: parcelaCentavos ?? this.parcelaCentavos,
      diaVencimento: diaVencimento ?? this.diaVencimento,
      parcelasRestantes: parcelasRestantes ?? this.parcelasRestantes,
      parcelasTotal: parcelasTotal ?? this.parcelasTotal,
      quitadaEm: quitadaEm ?? this.quitadaEm,
      criadaEm: criadaEm ?? this.criadaEm,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (nome.present) {
      map['nome'] = Variable<String>(nome.value);
    }
    if (saldoCentavos.present) {
      map['saldo_centavos'] = Variable<int>(saldoCentavos.value);
    }
    if (parcelaCentavos.present) {
      map['parcela_centavos'] = Variable<int>(parcelaCentavos.value);
    }
    if (diaVencimento.present) {
      map['dia_vencimento'] = Variable<int>(diaVencimento.value);
    }
    if (parcelasRestantes.present) {
      map['parcelas_restantes'] = Variable<int>(parcelasRestantes.value);
    }
    if (parcelasTotal.present) {
      map['parcelas_total'] = Variable<int>(parcelasTotal.value);
    }
    if (quitadaEm.present) {
      map['quitada_em'] = Variable<DateTime>(quitadaEm.value);
    }
    if (criadaEm.present) {
      map['criada_em'] = Variable<DateTime>(criadaEm.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DividasCompanion(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('saldoCentavos: $saldoCentavos, ')
          ..write('parcelaCentavos: $parcelaCentavos, ')
          ..write('diaVencimento: $diaVencimento, ')
          ..write('parcelasRestantes: $parcelasRestantes, ')
          ..write('parcelasTotal: $parcelasTotal, ')
          ..write('quitadaEm: $quitadaEm, ')
          ..write('criadaEm: $criadaEm, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PerfisTable extends Perfis with TableInfo<$PerfisTable, Perfi> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PerfisTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _rendaCentavosMeta = const VerificationMeta(
    'rendaCentavos',
  );
  @override
  late final GeneratedColumn<int> rendaCentavos = GeneratedColumn<int>(
    'renda_centavos',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _diaRendaMeta = const VerificationMeta(
    'diaRenda',
  );
  @override
  late final GeneratedColumn<int> diaRenda = GeneratedColumn<int>(
    'dia_renda',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gastoDiarioCentavosMeta =
      const VerificationMeta('gastoDiarioCentavos');
  @override
  late final GeneratedColumn<int> gastoDiarioCentavos = GeneratedColumn<int>(
    'gasto_diario_centavos',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contasFixasCentavosMeta =
      const VerificationMeta('contasFixasCentavos');
  @override
  late final GeneratedColumn<int> contasFixasCentavos = GeneratedColumn<int>(
    'contas_fixas_centavos',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _origemMeta = const VerificationMeta('origem');
  @override
  late final GeneratedColumn<String> origem = GeneratedColumn<String>(
    'origem',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('feeling'),
  );
  static const VerificationMeta _atualizadoEmMeta = const VerificationMeta(
    'atualizadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> atualizadoEm = GeneratedColumn<DateTime>(
    'atualizado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    rendaCentavos,
    diaRenda,
    gastoDiarioCentavos,
    contasFixasCentavos,
    origem,
    atualizadoEm,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'perfis';
  @override
  VerificationContext validateIntegrity(
    Insertable<Perfi> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('renda_centavos')) {
      context.handle(
        _rendaCentavosMeta,
        rendaCentavos.isAcceptableOrUnknown(
          data['renda_centavos']!,
          _rendaCentavosMeta,
        ),
      );
    }
    if (data.containsKey('dia_renda')) {
      context.handle(
        _diaRendaMeta,
        diaRenda.isAcceptableOrUnknown(data['dia_renda']!, _diaRendaMeta),
      );
    }
    if (data.containsKey('gasto_diario_centavos')) {
      context.handle(
        _gastoDiarioCentavosMeta,
        gastoDiarioCentavos.isAcceptableOrUnknown(
          data['gasto_diario_centavos']!,
          _gastoDiarioCentavosMeta,
        ),
      );
    }
    if (data.containsKey('contas_fixas_centavos')) {
      context.handle(
        _contasFixasCentavosMeta,
        contasFixasCentavos.isAcceptableOrUnknown(
          data['contas_fixas_centavos']!,
          _contasFixasCentavosMeta,
        ),
      );
    }
    if (data.containsKey('origem')) {
      context.handle(
        _origemMeta,
        origem.isAcceptableOrUnknown(data['origem']!, _origemMeta),
      );
    }
    if (data.containsKey('atualizado_em')) {
      context.handle(
        _atualizadoEmMeta,
        atualizadoEm.isAcceptableOrUnknown(
          data['atualizado_em']!,
          _atualizadoEmMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Perfi map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Perfi(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      rendaCentavos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}renda_centavos'],
      ),
      diaRenda: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dia_renda'],
      ),
      gastoDiarioCentavos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}gasto_diario_centavos'],
      ),
      contasFixasCentavos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}contas_fixas_centavos'],
      ),
      origem: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origem'],
      )!,
      atualizadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}atualizado_em'],
      )!,
    );
  }

  @override
  $PerfisTable createAlias(String alias) {
    return $PerfisTable(attachedDatabase, alias);
  }
}

class Perfi extends DataClass implements Insertable<Perfi> {
  final int id;
  final int? rendaCentavos;
  final int? diaRenda;
  final int? gastoDiarioCentavos;
  final int? contasFixasCentavos;

  /// 'feeling' (chute do onboarding) ou 'ofx' (extrato importado).
  final String origem;
  final DateTime atualizadoEm;
  const Perfi({
    required this.id,
    this.rendaCentavos,
    this.diaRenda,
    this.gastoDiarioCentavos,
    this.contasFixasCentavos,
    required this.origem,
    required this.atualizadoEm,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || rendaCentavos != null) {
      map['renda_centavos'] = Variable<int>(rendaCentavos);
    }
    if (!nullToAbsent || diaRenda != null) {
      map['dia_renda'] = Variable<int>(diaRenda);
    }
    if (!nullToAbsent || gastoDiarioCentavos != null) {
      map['gasto_diario_centavos'] = Variable<int>(gastoDiarioCentavos);
    }
    if (!nullToAbsent || contasFixasCentavos != null) {
      map['contas_fixas_centavos'] = Variable<int>(contasFixasCentavos);
    }
    map['origem'] = Variable<String>(origem);
    map['atualizado_em'] = Variable<DateTime>(atualizadoEm);
    return map;
  }

  PerfisCompanion toCompanion(bool nullToAbsent) {
    return PerfisCompanion(
      id: Value(id),
      rendaCentavos: rendaCentavos == null && nullToAbsent
          ? const Value.absent()
          : Value(rendaCentavos),
      diaRenda: diaRenda == null && nullToAbsent
          ? const Value.absent()
          : Value(diaRenda),
      gastoDiarioCentavos: gastoDiarioCentavos == null && nullToAbsent
          ? const Value.absent()
          : Value(gastoDiarioCentavos),
      contasFixasCentavos: contasFixasCentavos == null && nullToAbsent
          ? const Value.absent()
          : Value(contasFixasCentavos),
      origem: Value(origem),
      atualizadoEm: Value(atualizadoEm),
    );
  }

  factory Perfi.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Perfi(
      id: serializer.fromJson<int>(json['id']),
      rendaCentavos: serializer.fromJson<int?>(json['rendaCentavos']),
      diaRenda: serializer.fromJson<int?>(json['diaRenda']),
      gastoDiarioCentavos: serializer.fromJson<int?>(
        json['gastoDiarioCentavos'],
      ),
      contasFixasCentavos: serializer.fromJson<int?>(
        json['contasFixasCentavos'],
      ),
      origem: serializer.fromJson<String>(json['origem']),
      atualizadoEm: serializer.fromJson<DateTime>(json['atualizadoEm']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'rendaCentavos': serializer.toJson<int?>(rendaCentavos),
      'diaRenda': serializer.toJson<int?>(diaRenda),
      'gastoDiarioCentavos': serializer.toJson<int?>(gastoDiarioCentavos),
      'contasFixasCentavos': serializer.toJson<int?>(contasFixasCentavos),
      'origem': serializer.toJson<String>(origem),
      'atualizadoEm': serializer.toJson<DateTime>(atualizadoEm),
    };
  }

  Perfi copyWith({
    int? id,
    Value<int?> rendaCentavos = const Value.absent(),
    Value<int?> diaRenda = const Value.absent(),
    Value<int?> gastoDiarioCentavos = const Value.absent(),
    Value<int?> contasFixasCentavos = const Value.absent(),
    String? origem,
    DateTime? atualizadoEm,
  }) => Perfi(
    id: id ?? this.id,
    rendaCentavos: rendaCentavos.present
        ? rendaCentavos.value
        : this.rendaCentavos,
    diaRenda: diaRenda.present ? diaRenda.value : this.diaRenda,
    gastoDiarioCentavos: gastoDiarioCentavos.present
        ? gastoDiarioCentavos.value
        : this.gastoDiarioCentavos,
    contasFixasCentavos: contasFixasCentavos.present
        ? contasFixasCentavos.value
        : this.contasFixasCentavos,
    origem: origem ?? this.origem,
    atualizadoEm: atualizadoEm ?? this.atualizadoEm,
  );
  Perfi copyWithCompanion(PerfisCompanion data) {
    return Perfi(
      id: data.id.present ? data.id.value : this.id,
      rendaCentavos: data.rendaCentavos.present
          ? data.rendaCentavos.value
          : this.rendaCentavos,
      diaRenda: data.diaRenda.present ? data.diaRenda.value : this.diaRenda,
      gastoDiarioCentavos: data.gastoDiarioCentavos.present
          ? data.gastoDiarioCentavos.value
          : this.gastoDiarioCentavos,
      contasFixasCentavos: data.contasFixasCentavos.present
          ? data.contasFixasCentavos.value
          : this.contasFixasCentavos,
      origem: data.origem.present ? data.origem.value : this.origem,
      atualizadoEm: data.atualizadoEm.present
          ? data.atualizadoEm.value
          : this.atualizadoEm,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Perfi(')
          ..write('id: $id, ')
          ..write('rendaCentavos: $rendaCentavos, ')
          ..write('diaRenda: $diaRenda, ')
          ..write('gastoDiarioCentavos: $gastoDiarioCentavos, ')
          ..write('contasFixasCentavos: $contasFixasCentavos, ')
          ..write('origem: $origem, ')
          ..write('atualizadoEm: $atualizadoEm')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    rendaCentavos,
    diaRenda,
    gastoDiarioCentavos,
    contasFixasCentavos,
    origem,
    atualizadoEm,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Perfi &&
          other.id == this.id &&
          other.rendaCentavos == this.rendaCentavos &&
          other.diaRenda == this.diaRenda &&
          other.gastoDiarioCentavos == this.gastoDiarioCentavos &&
          other.contasFixasCentavos == this.contasFixasCentavos &&
          other.origem == this.origem &&
          other.atualizadoEm == this.atualizadoEm);
}

class PerfisCompanion extends UpdateCompanion<Perfi> {
  final Value<int> id;
  final Value<int?> rendaCentavos;
  final Value<int?> diaRenda;
  final Value<int?> gastoDiarioCentavos;
  final Value<int?> contasFixasCentavos;
  final Value<String> origem;
  final Value<DateTime> atualizadoEm;
  const PerfisCompanion({
    this.id = const Value.absent(),
    this.rendaCentavos = const Value.absent(),
    this.diaRenda = const Value.absent(),
    this.gastoDiarioCentavos = const Value.absent(),
    this.contasFixasCentavos = const Value.absent(),
    this.origem = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
  });
  PerfisCompanion.insert({
    this.id = const Value.absent(),
    this.rendaCentavos = const Value.absent(),
    this.diaRenda = const Value.absent(),
    this.gastoDiarioCentavos = const Value.absent(),
    this.contasFixasCentavos = const Value.absent(),
    this.origem = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
  });
  static Insertable<Perfi> custom({
    Expression<int>? id,
    Expression<int>? rendaCentavos,
    Expression<int>? diaRenda,
    Expression<int>? gastoDiarioCentavos,
    Expression<int>? contasFixasCentavos,
    Expression<String>? origem,
    Expression<DateTime>? atualizadoEm,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (rendaCentavos != null) 'renda_centavos': rendaCentavos,
      if (diaRenda != null) 'dia_renda': diaRenda,
      if (gastoDiarioCentavos != null)
        'gasto_diario_centavos': gastoDiarioCentavos,
      if (contasFixasCentavos != null)
        'contas_fixas_centavos': contasFixasCentavos,
      if (origem != null) 'origem': origem,
      if (atualizadoEm != null) 'atualizado_em': atualizadoEm,
    });
  }

  PerfisCompanion copyWith({
    Value<int>? id,
    Value<int?>? rendaCentavos,
    Value<int?>? diaRenda,
    Value<int?>? gastoDiarioCentavos,
    Value<int?>? contasFixasCentavos,
    Value<String>? origem,
    Value<DateTime>? atualizadoEm,
  }) {
    return PerfisCompanion(
      id: id ?? this.id,
      rendaCentavos: rendaCentavos ?? this.rendaCentavos,
      diaRenda: diaRenda ?? this.diaRenda,
      gastoDiarioCentavos: gastoDiarioCentavos ?? this.gastoDiarioCentavos,
      contasFixasCentavos: contasFixasCentavos ?? this.contasFixasCentavos,
      origem: origem ?? this.origem,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (rendaCentavos.present) {
      map['renda_centavos'] = Variable<int>(rendaCentavos.value);
    }
    if (diaRenda.present) {
      map['dia_renda'] = Variable<int>(diaRenda.value);
    }
    if (gastoDiarioCentavos.present) {
      map['gasto_diario_centavos'] = Variable<int>(gastoDiarioCentavos.value);
    }
    if (contasFixasCentavos.present) {
      map['contas_fixas_centavos'] = Variable<int>(contasFixasCentavos.value);
    }
    if (origem.present) {
      map['origem'] = Variable<String>(origem.value);
    }
    if (atualizadoEm.present) {
      map['atualizado_em'] = Variable<DateTime>(atualizadoEm.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PerfisCompanion(')
          ..write('id: $id, ')
          ..write('rendaCentavos: $rendaCentavos, ')
          ..write('diaRenda: $diaRenda, ')
          ..write('gastoDiarioCentavos: $gastoDiarioCentavos, ')
          ..write('contasFixasCentavos: $contasFixasCentavos, ')
          ..write('origem: $origem, ')
          ..write('atualizadoEm: $atualizadoEm')
          ..write(')'))
        .toString();
  }
}

class $LancamentosTable extends Lancamentos
    with TableInfo<$LancamentosTable, Lancamento> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LancamentosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descricaoMeta = const VerificationMeta(
    'descricao',
  );
  @override
  late final GeneratedColumn<String> descricao = GeneratedColumn<String>(
    'descricao',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valorCentavosMeta = const VerificationMeta(
    'valorCentavos',
  );
  @override
  late final GeneratedColumn<int> valorCentavos = GeneratedColumn<int>(
    'valor_centavos',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tipoMeta = const VerificationMeta('tipo');
  @override
  late final GeneratedColumn<String> tipo = GeneratedColumn<String>(
    'tipo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<DateTime> data = GeneratedColumn<DateTime>(
    'data',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoriaMeta = const VerificationMeta(
    'categoria',
  );
  @override
  late final GeneratedColumn<String> categoria = GeneratedColumn<String>(
    'categoria',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    descricao,
    valorCentavos,
    tipo,
    data,
    categoria,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lancamentos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Lancamento> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('descricao')) {
      context.handle(
        _descricaoMeta,
        descricao.isAcceptableOrUnknown(data['descricao']!, _descricaoMeta),
      );
    } else if (isInserting) {
      context.missing(_descricaoMeta);
    }
    if (data.containsKey('valor_centavos')) {
      context.handle(
        _valorCentavosMeta,
        valorCentavos.isAcceptableOrUnknown(
          data['valor_centavos']!,
          _valorCentavosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_valorCentavosMeta);
    }
    if (data.containsKey('tipo')) {
      context.handle(
        _tipoMeta,
        tipo.isAcceptableOrUnknown(data['tipo']!, _tipoMeta),
      );
    } else if (isInserting) {
      context.missing(_tipoMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    if (data.containsKey('categoria')) {
      context.handle(
        _categoriaMeta,
        categoria.isAcceptableOrUnknown(data['categoria']!, _categoriaMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Lancamento map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Lancamento(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      descricao: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}descricao'],
      )!,
      valorCentavos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}valor_centavos'],
      )!,
      tipo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo'],
      )!,
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}data'],
      )!,
      categoria: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}categoria'],
      ),
    );
  }

  @override
  $LancamentosTable createAlias(String alias) {
    return $LancamentosTable(attachedDatabase, alias);
  }
}

class Lancamento extends DataClass implements Insertable<Lancamento> {
  final String id;
  final String descricao;

  /// Em centavos, como todo dinheiro no app. Ver Dividas.
  final int valorCentavos;

  /// 'gasto' ou 'entrada'.
  final String tipo;
  final DateTime data;
  final String? categoria;
  const Lancamento({
    required this.id,
    required this.descricao,
    required this.valorCentavos,
    required this.tipo,
    required this.data,
    this.categoria,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['descricao'] = Variable<String>(descricao);
    map['valor_centavos'] = Variable<int>(valorCentavos);
    map['tipo'] = Variable<String>(tipo);
    map['data'] = Variable<DateTime>(data);
    if (!nullToAbsent || categoria != null) {
      map['categoria'] = Variable<String>(categoria);
    }
    return map;
  }

  LancamentosCompanion toCompanion(bool nullToAbsent) {
    return LancamentosCompanion(
      id: Value(id),
      descricao: Value(descricao),
      valorCentavos: Value(valorCentavos),
      tipo: Value(tipo),
      data: Value(data),
      categoria: categoria == null && nullToAbsent
          ? const Value.absent()
          : Value(categoria),
    );
  }

  factory Lancamento.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Lancamento(
      id: serializer.fromJson<String>(json['id']),
      descricao: serializer.fromJson<String>(json['descricao']),
      valorCentavos: serializer.fromJson<int>(json['valorCentavos']),
      tipo: serializer.fromJson<String>(json['tipo']),
      data: serializer.fromJson<DateTime>(json['data']),
      categoria: serializer.fromJson<String?>(json['categoria']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'descricao': serializer.toJson<String>(descricao),
      'valorCentavos': serializer.toJson<int>(valorCentavos),
      'tipo': serializer.toJson<String>(tipo),
      'data': serializer.toJson<DateTime>(data),
      'categoria': serializer.toJson<String?>(categoria),
    };
  }

  Lancamento copyWith({
    String? id,
    String? descricao,
    int? valorCentavos,
    String? tipo,
    DateTime? data,
    Value<String?> categoria = const Value.absent(),
  }) => Lancamento(
    id: id ?? this.id,
    descricao: descricao ?? this.descricao,
    valorCentavos: valorCentavos ?? this.valorCentavos,
    tipo: tipo ?? this.tipo,
    data: data ?? this.data,
    categoria: categoria.present ? categoria.value : this.categoria,
  );
  Lancamento copyWithCompanion(LancamentosCompanion data) {
    return Lancamento(
      id: data.id.present ? data.id.value : this.id,
      descricao: data.descricao.present ? data.descricao.value : this.descricao,
      valorCentavos: data.valorCentavos.present
          ? data.valorCentavos.value
          : this.valorCentavos,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      data: data.data.present ? data.data.value : this.data,
      categoria: data.categoria.present ? data.categoria.value : this.categoria,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Lancamento(')
          ..write('id: $id, ')
          ..write('descricao: $descricao, ')
          ..write('valorCentavos: $valorCentavos, ')
          ..write('tipo: $tipo, ')
          ..write('data: $data, ')
          ..write('categoria: $categoria')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, descricao, valorCentavos, tipo, data, categoria);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Lancamento &&
          other.id == this.id &&
          other.descricao == this.descricao &&
          other.valorCentavos == this.valorCentavos &&
          other.tipo == this.tipo &&
          other.data == this.data &&
          other.categoria == this.categoria);
}

class LancamentosCompanion extends UpdateCompanion<Lancamento> {
  final Value<String> id;
  final Value<String> descricao;
  final Value<int> valorCentavos;
  final Value<String> tipo;
  final Value<DateTime> data;
  final Value<String?> categoria;
  final Value<int> rowid;
  const LancamentosCompanion({
    this.id = const Value.absent(),
    this.descricao = const Value.absent(),
    this.valorCentavos = const Value.absent(),
    this.tipo = const Value.absent(),
    this.data = const Value.absent(),
    this.categoria = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LancamentosCompanion.insert({
    required String id,
    required String descricao,
    required int valorCentavos,
    required String tipo,
    required DateTime data,
    this.categoria = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       descricao = Value(descricao),
       valorCentavos = Value(valorCentavos),
       tipo = Value(tipo),
       data = Value(data);
  static Insertable<Lancamento> custom({
    Expression<String>? id,
    Expression<String>? descricao,
    Expression<int>? valorCentavos,
    Expression<String>? tipo,
    Expression<DateTime>? data,
    Expression<String>? categoria,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (descricao != null) 'descricao': descricao,
      if (valorCentavos != null) 'valor_centavos': valorCentavos,
      if (tipo != null) 'tipo': tipo,
      if (data != null) 'data': data,
      if (categoria != null) 'categoria': categoria,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LancamentosCompanion copyWith({
    Value<String>? id,
    Value<String>? descricao,
    Value<int>? valorCentavos,
    Value<String>? tipo,
    Value<DateTime>? data,
    Value<String?>? categoria,
    Value<int>? rowid,
  }) {
    return LancamentosCompanion(
      id: id ?? this.id,
      descricao: descricao ?? this.descricao,
      valorCentavos: valorCentavos ?? this.valorCentavos,
      tipo: tipo ?? this.tipo,
      data: data ?? this.data,
      categoria: categoria ?? this.categoria,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (descricao.present) {
      map['descricao'] = Variable<String>(descricao.value);
    }
    if (valorCentavos.present) {
      map['valor_centavos'] = Variable<int>(valorCentavos.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(tipo.value);
    }
    if (data.present) {
      map['data'] = Variable<DateTime>(data.value);
    }
    if (categoria.present) {
      map['categoria'] = Variable<String>(categoria.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LancamentosCompanion(')
          ..write('id: $id, ')
          ..write('descricao: $descricao, ')
          ..write('valorCentavos: $valorCentavos, ')
          ..write('tipo: $tipo, ')
          ..write('data: $data, ')
          ..write('categoria: $categoria, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$Banco extends GeneratedDatabase {
  _$Banco(QueryExecutor e) : super(e);
  $BancoManager get managers => $BancoManager(this);
  late final $DividasTable dividas = $DividasTable(this);
  late final $PerfisTable perfis = $PerfisTable(this);
  late final $LancamentosTable lancamentos = $LancamentosTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    dividas,
    perfis,
    lancamentos,
  ];
}

typedef $$DividasTableCreateCompanionBuilder = DividasCompanion Function({
  required String id,
  required String nome,
  Value<int> saldoCentavos,
  Value<int> parcelaCentavos,
  Value<int> diaVencimento,
  Value<int> parcelasRestantes,
  Value<int> parcelasTotal,
  Value<DateTime?> quitadaEm,
  Value<DateTime> criadaEm,
  Value<int> rowid,
});
typedef $$DividasTableUpdateCompanionBuilder = DividasCompanion Function({
  Value<String> id,
  Value<String> nome,
  Value<int> saldoCentavos,
  Value<int> parcelaCentavos,
  Value<int> diaVencimento,
  Value<int> parcelasRestantes,
  Value<int> parcelasTotal,
  Value<DateTime?> quitadaEm,
  Value<DateTime> criadaEm,
  Value<int> rowid,
});

class $$DividasTableFilterComposer extends Composer<_$Banco, $DividasTable> {
  $$DividasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get saldoCentavos => $composableBuilder(
    column: $table.saldoCentavos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get parcelaCentavos => $composableBuilder(
    column: $table.parcelaCentavos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get diaVencimento => $composableBuilder(
    column: $table.diaVencimento,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get parcelasRestantes => $composableBuilder(
    column: $table.parcelasRestantes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get parcelasTotal => $composableBuilder(
    column: $table.parcelasTotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get quitadaEm => $composableBuilder(
    column: $table.quitadaEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get criadaEm => $composableBuilder(
    column: $table.criadaEm,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DividasTableOrderingComposer extends Composer<_$Banco, $DividasTable> {
  $$DividasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get saldoCentavos => $composableBuilder(
    column: $table.saldoCentavos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get parcelaCentavos => $composableBuilder(
    column: $table.parcelaCentavos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get diaVencimento => $composableBuilder(
    column: $table.diaVencimento,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get parcelasRestantes => $composableBuilder(
    column: $table.parcelasRestantes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get parcelasTotal => $composableBuilder(
    column: $table.parcelasTotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get quitadaEm => $composableBuilder(
    column: $table.quitadaEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get criadaEm => $composableBuilder(
    column: $table.criadaEm,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DividasTableAnnotationComposer
    extends Composer<_$Banco, $DividasTable> {
  $$DividasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nome =>
      $composableBuilder(column: $table.nome, builder: (column) => column);

  GeneratedColumn<int> get saldoCentavos => $composableBuilder(
    column: $table.saldoCentavos,
    builder: (column) => column,
  );

  GeneratedColumn<int> get parcelaCentavos => $composableBuilder(
    column: $table.parcelaCentavos,
    builder: (column) => column,
  );

  GeneratedColumn<int> get diaVencimento => $composableBuilder(
    column: $table.diaVencimento,
    builder: (column) => column,
  );

  GeneratedColumn<int> get parcelasRestantes => $composableBuilder(
    column: $table.parcelasRestantes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get parcelasTotal => $composableBuilder(
    column: $table.parcelasTotal,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get quitadaEm =>
      $composableBuilder(column: $table.quitadaEm, builder: (column) => column);

  GeneratedColumn<DateTime> get criadaEm =>
      $composableBuilder(column: $table.criadaEm, builder: (column) => column);
}

class $$DividasTableTableManager
    extends
        RootTableManager<
          _$Banco,
          $DividasTable,
          Divida,
          $$DividasTableFilterComposer,
          $$DividasTableOrderingComposer,
          $$DividasTableAnnotationComposer,
          $$DividasTableCreateCompanionBuilder,
          $$DividasTableUpdateCompanionBuilder,
          (Divida, BaseReferences<_$Banco, $DividasTable, Divida>),
          Divida,
          PrefetchHooks Function()
        > {
  $$DividasTableTableManager(_$Banco db, $DividasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DividasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DividasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DividasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> nome = const Value.absent(),
                Value<int> saldoCentavos = const Value.absent(),
                Value<int> parcelaCentavos = const Value.absent(),
                Value<int> diaVencimento = const Value.absent(),
                Value<int> parcelasRestantes = const Value.absent(),
                Value<int> parcelasTotal = const Value.absent(),
                Value<DateTime?> quitadaEm = const Value.absent(),
                Value<DateTime> criadaEm = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DividasCompanion(
                id: id,
                nome: nome,
                saldoCentavos: saldoCentavos,
                parcelaCentavos: parcelaCentavos,
                diaVencimento: diaVencimento,
                parcelasRestantes: parcelasRestantes,
                parcelasTotal: parcelasTotal,
                quitadaEm: quitadaEm,
                criadaEm: criadaEm,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String nome,
                Value<int> saldoCentavos = const Value.absent(),
                Value<int> parcelaCentavos = const Value.absent(),
                Value<int> diaVencimento = const Value.absent(),
                Value<int> parcelasRestantes = const Value.absent(),
                Value<int> parcelasTotal = const Value.absent(),
                Value<DateTime?> quitadaEm = const Value.absent(),
                Value<DateTime> criadaEm = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DividasCompanion.insert(
                id: id,
                nome: nome,
                saldoCentavos: saldoCentavos,
                parcelaCentavos: parcelaCentavos,
                diaVencimento: diaVencimento,
                parcelasRestantes: parcelasRestantes,
                parcelasTotal: parcelasTotal,
                quitadaEm: quitadaEm,
                criadaEm: criadaEm,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DividasTable, Divida>(table),
                  BaseReferences<_$Banco, $DividasTable, Divida>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DividasTableProcessedTableManager =
    ProcessedTableManager<
      _$Banco,
      $DividasTable,
      Divida,
      $$DividasTableFilterComposer,
      $$DividasTableOrderingComposer,
      $$DividasTableAnnotationComposer,
      $$DividasTableCreateCompanionBuilder,
      $$DividasTableUpdateCompanionBuilder,
      (Divida, BaseReferences<_$Banco, $DividasTable, Divida>),
      Divida,
      PrefetchHooks Function()
    >;
typedef $$PerfisTableCreateCompanionBuilder = PerfisCompanion Function({
  Value<int> id,
  Value<int?> rendaCentavos,
  Value<int?> diaRenda,
  Value<int?> gastoDiarioCentavos,
  Value<int?> contasFixasCentavos,
  Value<String> origem,
  Value<DateTime> atualizadoEm,
});
typedef $$PerfisTableUpdateCompanionBuilder = PerfisCompanion Function({
  Value<int> id,
  Value<int?> rendaCentavos,
  Value<int?> diaRenda,
  Value<int?> gastoDiarioCentavos,
  Value<int?> contasFixasCentavos,
  Value<String> origem,
  Value<DateTime> atualizadoEm,
});

class $$PerfisTableFilterComposer extends Composer<_$Banco, $PerfisTable> {
  $$PerfisTableFilterComposer({
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

  ColumnFilters<int> get rendaCentavos => $composableBuilder(
    column: $table.rendaCentavos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get diaRenda => $composableBuilder(
    column: $table.diaRenda,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get gastoDiarioCentavos => $composableBuilder(
    column: $table.gastoDiarioCentavos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get contasFixasCentavos => $composableBuilder(
    column: $table.contasFixasCentavos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get origem => $composableBuilder(
    column: $table.origem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PerfisTableOrderingComposer extends Composer<_$Banco, $PerfisTable> {
  $$PerfisTableOrderingComposer({
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

  ColumnOrderings<int> get rendaCentavos => $composableBuilder(
    column: $table.rendaCentavos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get diaRenda => $composableBuilder(
    column: $table.diaRenda,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get gastoDiarioCentavos => $composableBuilder(
    column: $table.gastoDiarioCentavos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get contasFixasCentavos => $composableBuilder(
    column: $table.contasFixasCentavos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origem => $composableBuilder(
    column: $table.origem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PerfisTableAnnotationComposer extends Composer<_$Banco, $PerfisTable> {
  $$PerfisTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get rendaCentavos => $composableBuilder(
    column: $table.rendaCentavos,
    builder: (column) => column,
  );

  GeneratedColumn<int> get diaRenda =>
      $composableBuilder(column: $table.diaRenda, builder: (column) => column);

  GeneratedColumn<int> get gastoDiarioCentavos => $composableBuilder(
    column: $table.gastoDiarioCentavos,
    builder: (column) => column,
  );

  GeneratedColumn<int> get contasFixasCentavos => $composableBuilder(
    column: $table.contasFixasCentavos,
    builder: (column) => column,
  );

  GeneratedColumn<String> get origem =>
      $composableBuilder(column: $table.origem, builder: (column) => column);

  GeneratedColumn<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => column,
  );
}

class $$PerfisTableTableManager
    extends
        RootTableManager<
          _$Banco,
          $PerfisTable,
          Perfi,
          $$PerfisTableFilterComposer,
          $$PerfisTableOrderingComposer,
          $$PerfisTableAnnotationComposer,
          $$PerfisTableCreateCompanionBuilder,
          $$PerfisTableUpdateCompanionBuilder,
          (Perfi, BaseReferences<_$Banco, $PerfisTable, Perfi>),
          Perfi,
          PrefetchHooks Function()
        > {
  $$PerfisTableTableManager(_$Banco db, $PerfisTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PerfisTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PerfisTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PerfisTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> rendaCentavos = const Value.absent(),
                Value<int?> diaRenda = const Value.absent(),
                Value<int?> gastoDiarioCentavos = const Value.absent(),
                Value<int?> contasFixasCentavos = const Value.absent(),
                Value<String> origem = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
              }) => PerfisCompanion(
                id: id,
                rendaCentavos: rendaCentavos,
                diaRenda: diaRenda,
                gastoDiarioCentavos: gastoDiarioCentavos,
                contasFixasCentavos: contasFixasCentavos,
                origem: origem,
                atualizadoEm: atualizadoEm,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> rendaCentavos = const Value.absent(),
                Value<int?> diaRenda = const Value.absent(),
                Value<int?> gastoDiarioCentavos = const Value.absent(),
                Value<int?> contasFixasCentavos = const Value.absent(),
                Value<String> origem = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
              }) => PerfisCompanion.insert(
                id: id,
                rendaCentavos: rendaCentavos,
                diaRenda: diaRenda,
                gastoDiarioCentavos: gastoDiarioCentavos,
                contasFixasCentavos: contasFixasCentavos,
                origem: origem,
                atualizadoEm: atualizadoEm,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PerfisTable, Perfi>(table),
                  BaseReferences<_$Banco, $PerfisTable, Perfi>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PerfisTableProcessedTableManager =
    ProcessedTableManager<
      _$Banco,
      $PerfisTable,
      Perfi,
      $$PerfisTableFilterComposer,
      $$PerfisTableOrderingComposer,
      $$PerfisTableAnnotationComposer,
      $$PerfisTableCreateCompanionBuilder,
      $$PerfisTableUpdateCompanionBuilder,
      (Perfi, BaseReferences<_$Banco, $PerfisTable, Perfi>),
      Perfi,
      PrefetchHooks Function()
    >;
typedef $$LancamentosTableCreateCompanionBuilder =
    LancamentosCompanion Function({
      required String id,
      required String descricao,
      required int valorCentavos,
      required String tipo,
      required DateTime data,
      Value<String?> categoria,
      Value<int> rowid,
    });
typedef $$LancamentosTableUpdateCompanionBuilder =
    LancamentosCompanion Function({
      Value<String> id,
      Value<String> descricao,
      Value<int> valorCentavos,
      Value<String> tipo,
      Value<DateTime> data,
      Value<String?> categoria,
      Value<int> rowid,
    });

class $$LancamentosTableFilterComposer
    extends Composer<_$Banco, $LancamentosTable> {
  $$LancamentosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descricao => $composableBuilder(
    column: $table.descricao,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get valorCentavos => $composableBuilder(
    column: $table.valorCentavos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoria => $composableBuilder(
    column: $table.categoria,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LancamentosTableOrderingComposer
    extends Composer<_$Banco, $LancamentosTable> {
  $$LancamentosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descricao => $composableBuilder(
    column: $table.descricao,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get valorCentavos => $composableBuilder(
    column: $table.valorCentavos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoria => $composableBuilder(
    column: $table.categoria,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LancamentosTableAnnotationComposer
    extends Composer<_$Banco, $LancamentosTable> {
  $$LancamentosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get descricao =>
      $composableBuilder(column: $table.descricao, builder: (column) => column);

  GeneratedColumn<int> get valorCentavos => $composableBuilder(
    column: $table.valorCentavos,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<DateTime> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<String> get categoria =>
      $composableBuilder(column: $table.categoria, builder: (column) => column);
}

class $$LancamentosTableTableManager
    extends
        RootTableManager<
          _$Banco,
          $LancamentosTable,
          Lancamento,
          $$LancamentosTableFilterComposer,
          $$LancamentosTableOrderingComposer,
          $$LancamentosTableAnnotationComposer,
          $$LancamentosTableCreateCompanionBuilder,
          $$LancamentosTableUpdateCompanionBuilder,
          (Lancamento, BaseReferences<_$Banco, $LancamentosTable, Lancamento>),
          Lancamento,
          PrefetchHooks Function()
        > {
  $$LancamentosTableTableManager(_$Banco db, $LancamentosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LancamentosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LancamentosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LancamentosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> descricao = const Value.absent(),
                Value<int> valorCentavos = const Value.absent(),
                Value<String> tipo = const Value.absent(),
                Value<DateTime> data = const Value.absent(),
                Value<String?> categoria = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LancamentosCompanion(
                id: id,
                descricao: descricao,
                valorCentavos: valorCentavos,
                tipo: tipo,
                data: data,
                categoria: categoria,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String descricao,
                required int valorCentavos,
                required String tipo,
                required DateTime data,
                Value<String?> categoria = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LancamentosCompanion.insert(
                id: id,
                descricao: descricao,
                valorCentavos: valorCentavos,
                tipo: tipo,
                data: data,
                categoria: categoria,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LancamentosTable, Lancamento>(table),
                  BaseReferences<_$Banco, $LancamentosTable, Lancamento>(
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

typedef $$LancamentosTableProcessedTableManager =
    ProcessedTableManager<
      _$Banco,
      $LancamentosTable,
      Lancamento,
      $$LancamentosTableFilterComposer,
      $$LancamentosTableOrderingComposer,
      $$LancamentosTableAnnotationComposer,
      $$LancamentosTableCreateCompanionBuilder,
      $$LancamentosTableUpdateCompanionBuilder,
      (Lancamento, BaseReferences<_$Banco, $LancamentosTable, Lancamento>),
      Lancamento,
      PrefetchHooks Function()
    >;

class $BancoManager {
  final _$Banco _db;
  $BancoManager(this._db);
  $$DividasTableTableManager get dividas =>
      $$DividasTableTableManager(_db, _db.dividas);
  $$PerfisTableTableManager get perfis =>
      $$PerfisTableTableManager(_db, _db.perfis);
  $$LancamentosTableTableManager get lancamentos =>
      $$LancamentosTableTableManager(_db, _db.lancamentos);
}
