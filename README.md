# Kitamo — app

App que tira a pessoa da dívida. Flutter.

> primeiro a gente quita, depois a gente cresce

## Estado

Início funcionando com as duas faces: conta que fecha (verde, diário) e
conta que não fecha (vermelho, quanto falta). 17 testes passando.

```bash
export PATH="$HOME/flutter/bin:$PATH"
flutter test          # 17 testes
flutter run -d chrome
```

## Como está organizado

```
lib/
  design/       cores, tipografia, medidas — tokens do Claude Design
  models/       Divida, PerfilFinanceiro
  services/     DiarioService — o número da tela
  features/     uma pasta por tela
  widgets/      formatação de moeda
assets/images/  joão-de-barro, casa em 5 fases, ícones
```

## O design é a fonte da verdade

`HANDOFF-DESIGN.md` e o zip do Claude Design mandam. A paleta em
`lib/design/cores.dart` veio dele — é mais escura que a proposta original
porque garante contraste AA: o app precisa ser legível a 60 anos.

**Regra que não se quebra:** fundo sempre creme, cartão sempre branco, um
acento por tela. O barro é acento, nunca parede.

## Regras de negócio que os testes guardam

- **Sobra negativa não vira "R$ 0".** O app diz quanto falta. Mostrar zero
  fingiria que dá pra viver sem gastar nada
- **Sobra exatamente zero não fecha.** Zero é o limite, não o começo do
  positivo
- **Vencimento dia 31 encolhe em mês curto.** Sem isso a parcela sumiria de
  fevereiro e o mês pareceria folgado
- **A data de quitação é a dívida mais longa.** Só promete "livre" quando a
  última parcela cair
- **"7 de 10" nunca é negativo**, mesmo com dado inconsistente

## Falta

Onboarding (6 telas), horizonte do mês e de 12 meses, "quitei essa",
lançamentos, chat, perfil, persistência. Ver `HANDOFF-DESIGN.md` §8.
