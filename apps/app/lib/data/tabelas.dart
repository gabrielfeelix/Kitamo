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

  /// O cartão em que esta compra está, ou nulo quando a dívida é solta
  /// (empréstimo, crediário, financiamento).
  ///
  /// Nulo é o normal: nem toda dívida mora num cartão, e quem já usava o
  /// app tem tudo solto. Ver [Cartoes].
  TextColumn get cartaoId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// As respostas do onboarding. Uma linha só, sempre com id = 1.
class Perfis extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();

  /// Como a pessoa quer ser chamada. Nulo até ela dizer.
  TextColumn get nome => text().nullable().withLength(max: 60)();

  IntColumn get rendaCentavos => integer().nullable()();
  IntColumn get diaRenda => integer().nullable()();
  IntColumn get gastoDiarioCentavos => integer().nullable()();
  IntColumn get contasFixasCentavos => integer().nullable()();

  /// 'feeling' (chute do onboarding) ou 'ofx' (extrato importado).
  TextColumn get origem => text().withDefault(const Constant('feeling'))();

  /// O passarinho escolhido em "Editar perfil": 'av-1' a 'av-8'. Nulo usa
  /// o primeiro do acervo.
  TextColumn get avatar => text().nullable().withLength(max: 20)();

  /// Como a pessoa entrou: 'google', 'facebook' ou nulo (sem conta).
  ///
  /// Guardado só para a tela saber o que mostrar. **Não há servidor**: o
  /// login é visual, decisão do Gabriel em 07/09/2026, e nada sai do
  /// aparelho enquanto não existir backend.
  TextColumn get provedor => text().nullable().withLength(max: 20)();

  /// O e-mail que veio do login social, para a linha de "Editar perfil".
  TextColumn get email => text().nullable().withLength(max: 160)();

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

/// Um cartão ou credor: a **caixa** onde as compras parceladas moram.
///
/// Existe porque 3 cartões viravam 3 dívidas soltas e ninguém sabia o que
/// tinha dentro de cada fatura. Na vida real a fatura chega junta e é paga
/// junta: uma fatura paga = **um toque**. Ver [Dividas.cartaoId].
class Cartoes extends Table {
  TextColumn get id => text()();
  TextColumn get nome => text().withLength(min: 1, max: 120)();

  /// O dia em que a fatura vence. As compras dentro herdam este dia.
  IntColumn get diaVencimento => integer().withDefault(const Constant(1))();

  DateTimeColumn get criadoEm => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// O que entra no mês, cada coisa com **seu dia**.
///
/// Um valor num dia só (o antigo `rendaMensal` + `diaRenda`) não cabe quem
/// recebe R$ 600 dia 5 e R$ 400 dia 20: o app prometia folga em dia que
/// ainda não tinha dinheiro na conta. O diário lê esta lista.
class Entradas extends Table {
  TextColumn get id => text()();

  /// "salário", "bico", "pensão" — o nome que a pessoa deu.
  TextColumn get nome => text().withLength(min: 1, max: 120)();

  /// Em centavos, como todo dinheiro no app. Ver [Dividas].
  IntColumn get valorCentavos => integer()();

  /// O dia do mês em que este dinheiro entra.
  IntColumn get dia => integer()();

  DateTimeColumn get criadaEm => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// As contas que saem todo mês: aluguel, luz, consórcio, escola.
///
/// Era um número só, digitado de cabeça — ninguém (nem ela) sabia do que
/// aquilo era feito, e quando o valor mudava era recalcular na mão. O
/// total é **soma do que ela cadastrou**, nunca um número solto: o app
/// pergunta, a pessoa responde.
class ContasFixas extends Table {
  TextColumn get id => text()();
  TextColumn get nome => text().withLength(min: 1, max: 120)();

  /// Em centavos. Ver [Dividas].
  IntColumn get valorCentavos => integer()();

  /// O dia do mês em que sai.
  IntColumn get dia => integer().withDefault(const Constant(1))();

  /// Desligada continua cadastrada, mas não entra na soma. É o botão da
  /// tela #06 — apagar exigiria digitar tudo de novo no mês que voltar.
  BoolColumn get ativa => boolean().withDefault(const Constant(true))();

  DateTimeColumn get criadaEm => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
