# Laboratório em sala — Paradigmas de Programação — Aula 07: Funções parciais, tipos algébricos e tipos polimórficos

Atividade feita durante a aula, sobre um tipo algébrico que não aparece na
exposição. As seis partes são **sequenciais**: cada uma altera o arquivo
deixado pela anterior, e o arquivo final é o entregável.

O ponto da atividade não é o avaliador de expressões, que é conhecido. É o que
acontece com as funções já escritas quando o **tipo** muda — nas Partes 4 e 5 —
e é por isso que as alterações são feitas nesta ordem e sem desfazer as
anteriores.

## Arquivo e execução

Ponto de partida: [`laboratorio.hs`](laboratorio.hs), que compila como está e
falha em execução enquanto as funções forem `undefined`.

```sh
docker run --rm -v "$PWD":/w -w /w haskell:9.6-slim \
  runghc -Wincomplete-patterns laboratorio.hs
```

O aviso `-Wincomplete-patterns` é obrigatório em toda execução. Sem ele, as
Partes 4 e 5 não produzem o que se espera delas.

---

## Parte 1 — O tipo

**Antes de abrir o arquivo**, escreva a declaração de um tipo algébrico para
expressões aritméticas com quatro alternativas: literal inteiro, soma,
multiplicação e negação.

Compare em seguida com a declaração de `Expr` no arquivo. Havendo diferença na
quantidade ou no tipo dos campos, **justifique qual das duas versões representa
o mesmo conjunto de expressões**, e siga com a do arquivo.

Responda, por escrito, em comentário: quais construtores de `Expr` são somas
puras e quais são produtos.

## Parte 2 — O avaliador

Implemente `avaliar :: Expr -> Int` por casamento exaustivo, **uma equação por
construtor**.

Os valores esperados para `e1`, `e2` e `e3` estão em comentário no arquivo.

## Parte 3 — Uma segunda função sobre o mesmo tipo

Implemente **uma** das duas funções declaradas:

- `contarOperacoes :: Expr -> Int`, que conta quantas operações a expressão
  contém — literais não contam;
- `emInfixa :: Expr -> String`, que devolve a expressão em notação infixa, com
  parênteses suficientes para preservar a estrutura.

Compare a estrutura da função escolhida com a de `avaliar` e descreva, em uma
frase, o que as duas têm em comum.

## Parte 4 — Acrescentar um construtor

Acrescente a `Expr` um construtor `Sub Expr Expr`, para a subtração.

**Não altere nenhuma função.** Compile.

Registre no topo do arquivo **quais funções falharam** e com que mensagem.
Só então corrija cada uma.

## Parte 5 — Generalizar o tipo

Troque o `Int` de `Lit` por uma variável de tipo, de modo que `Expr` passe a ser
`Expr a`. Ajuste apenas a declaração do tipo e as assinaturas que o compilador
recusar — **nada mais**.

Compile e registre no topo do arquivo, em duas listas:

- as funções que atravessaram a generalização **sem qualquer alteração de
  assinatura**;
- as funções que passaram a exigir **restrição de contexto**, e qual classe cada
  uma exige.

Acrescente a restrição **apenas onde o compilador a exigir**. Uma restrição que
o compilador não pediu é um erro de resposta, ainda que o programa compile.

Duas observações sobre esta parte:

- **Mantenha o tipo de retorno de `contarOperacoes` como `Int`.** Suprimida a
  assinatura inteira, o compilador infere um retorno polimórfico e acrescenta um
  contexto que **não** diz respeito ao elemento da expressão. A assinatura dada
  no arquivo evita essa confusão.
- Espera-se **mais de uma resposta** nesta parte: as funções não se dividem em
  "com contexto" e "sem contexto", e sim em três grupos, com classes distintas.
  A lista pedida deve nomear a classe de cada uma.

## Parte 6 — Divisão e composição

Acrescente a `Expr a` um construtor `Div (Expr a) (Expr a)`.

A divisão por zero não tem resultado. Escreva `avaliarSeguro`, com tipo de
retorno `Maybe a`, de forma que nenhuma entrada faça a função divergir.

Componha em seguida duas avaliações em sequência: uma função que recebe duas
expressões, avalia a primeira, e só avalia a segunda se a primeira tiver
produzido resultado.

A classe exigida por `avaliarSeguro` **depende da divisão escolhida**: a divisão
inteira e a divisão fracionária pedem classes diferentes. As duas escolhas são
aceitáveis; o que se cobra é que a restrição declarada seja a que o compilador
apontou para a escolha feita.

**Restrição:** a composição deve ser escrita com `case`. É proibido usar
`>>=`, notação `do`, `fmap`, `<$>`, `<*>`, `maybe`, `fromMaybe` ou qualquer
outra função da biblioteca padrão que já resolva o encadeamento. A repetição que
aparecer é o objeto da próxima aula, e escrevê-la à mão é o ponto desta parte.

---

## Entregável

O arquivo `.hs` ao final da Parte 6, compilando e executando, com os registros
pedidos nas Partes 1, 4 e 5 em comentário no topo.

## Critérios de verificação

1. O arquivo compila com `-Wincomplete-patterns` **sem nenhum aviso**.
2. O tipo da expressão está na forma paramétrica.
3. Nenhuma função carrega restrição de contexto que o compilador não tenha
   exigido.
4. A composição da Parte 6 não usa nenhuma das construções proibidas.
5. Os registros das Partes 4 e 5 estão presentes e correspondem ao que o
   compilador de fato apontou.

## Se o tempo acabar

A Parte 5 é a que não pode ser cortada: é a única em que a restrição de contexto
aparece como resposta a um problema, e não como notação a decorar. Em caso de
falta de tempo, entregue até a Parte 5 e conclua a Parte 6 fora de aula.
