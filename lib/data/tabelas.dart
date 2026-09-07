import 'package:drift/drift.dart';

/// Dívidas a quitar.
///
/// A fatura de cartão em aberto é uma dívida como as outras — o que muda é
/// só a origem do dado.
class Dividas extends Table {
  TextColumn get id => text()();
  TextColumn get nome => text().withLength(min: 1, max: 120)();

  /// Guardado em **centavos**, como inteiro.
  ///
  /// double para dinheiro acumula erro de ponto flutuante: 0.1 + 0.2 dá
  /// 0.30000000000000004. Num app que soma parcela todo mês por 24 meses,
  /// isso vira centavo errado na tela — e o usuário confere na fatura.
  IntColumn get saldoCentavos => integer().withDefault(const Constant(0))();
  IntColumn get parcelaCentavos => integer().withDefault(const Constant(0))();

  IntColumn get diaVencimento => integer().withDefault(const Constant(1))();
  IntColumn get parcelasRestantes => integer().withDefault(const Constant(0))();
  IntColumn get parcelasTotal => integer().withDefault(const Constant(0))();

  DateTimeColumn get quitadaEm => dateTime().nullable()();
  DateTimeColumn get criadaEm => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// As respostas do onboarding. Uma linha só, sempre com id = 1.
class Perfis extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();

  IntColumn get rendaCentavos => integer().nullable()();
  IntColumn get diaRenda => integer().nullable()();
  IntColumn get gastoDiarioCentavos => integer().nullable()();
  IntColumn get contasFixasCentavos => integer().nullable()();

  /// 'feeling' (chute do onboarding) ou 'ofx' (extrato importado).
  TextColumn get origem => text().withDefault(const Constant('feeling'))();

  DateTimeColumn get atualizadoEm => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Gastos e entradas registrados pela pessoa.
class Lancamentos extends Table {
  TextColumn get id => text()();
  TextColumn get descricao => text().withLength(min: 1, max: 200)();

  /// Em centavos, como todo dinheiro no app. Ver Dividas.
  IntColumn get valorCentavos => integer()();

  /// 'gasto' ou 'entrada'.
  TextColumn get tipo => text()();

  DateTimeColumn get data => dateTime()();
  TextColumn get categoria => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
