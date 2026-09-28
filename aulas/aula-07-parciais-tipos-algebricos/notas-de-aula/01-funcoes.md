# Paradigmas de Programação — Aula 07: Funções parciais, tipos algébricos e tipos polimórficos — Funções

## Introdução

Uma **função** em Haskell é definida por um conjunto de **equações**, e não por
um corpo de comandos. Cada equação descreve o resultado da função para uma forma
particular do argumento; a avaliação percorre as equações de cima para baixo e
usa a primeira cujo padrão case com o valor recebido.

Esta nota trata de como funções se definem, do que a assinatura de tipo diz
sobre uma função antes que seu corpo seja lido, e de onde a checagem de tipos
deixa de ajudar. Os três assuntos se sustentam: a assinatura restringe o
conjunto de implementações possíveis, e a última seção mede o tamanho do que
essa restrição não alcança.

## Objetivos de aprendizagem

Ao final desta nota, espera-se que o aluno seja capaz de:

1. Definir funções por equações com casamento de padrão, e justificar por que a
   ordem das equações altera o resultado.
2. Ler assinaturas com variáveis de tipo e enunciar quais implementações de
   `[a] -> a` a assinatura já exclui.
3. Enunciar a transparência referencial e justificar que substituir uma chamada
   pelo seu resultado não altera o programa, listando o que essa propriedade
   autoriza.
4. Identificar uma classe de erro que o sistema de tipos de Haskell não captura,
   a partir de um programa que compila e produz resultado incorreto.

## Desenvolvimento teórico

### Definição por equações

Uma definição de função é uma lista de equações da forma
`nome padrão₁ padrão₂ … = expressão`. A aplicação da função a um argumento
seleciona a **primeira** equação cujos padrões casem com os valores recebidos.

```haskell
digaMe :: Integer -> String
digaMe 1 = "Um"
digaMe 2 = "Dois"
digaMe 3 = "Três"
digaMe 4 = "Quatro"
digaMe 5 = "Cinco"
digaMe _ = "Outro número fora do intervalo de 1 a 5"
```

O padrão `_` — o **curinga** — casa com qualquer valor. Daí decorre que a ordem
das equações é **semântica, e não questão de estilo**: promover a última equação
ao topo torna todas as demais inalcançáveis, e a função passa a devolver a mesma
resposta para todo argumento. O compilador aceita a versão reordenada; ela
simplesmente computa outra coisa.

A diferença em relação a uma cadeia de desvios condicionais não é apenas
sintática. Os padrões descrevem a **forma** do valor, não uma condição sobre
ele, e essa forma é verificável pelo compilador — propriedade explorada na nota
sobre tipos algébricos.

### Casamento de padrão sobre listas

Uma lista tem duas formas possíveis: vazia, escrita `[]`, ou composta por um
elemento seguido de outra lista, escrita `(h:t)`. Os padrões decompõem o valor
na própria posição do parâmetro:

```haskell
cabeca :: [a] -> a
cabeca (h:_) = h

cauda :: [a] -> [a]
cauda (_:t) = t
```

A decomposição dispensa o acesso por índice e o teste sobre o tamanho. Nenhuma
das duas definições acima trata a lista vazia, e essa omissão é o assunto da
seção seguinte.

### Variáveis de tipo e o que a assinatura exclui

Em `cabeca :: [a] -> a`, o identificador `a` é uma **variável de tipo**: a
assinatura vale para todo tipo que substitua `a`. A consequência é que, dentro
do corpo da função, o tipo de `a` é desconhecido — nenhuma operação específica
lhe é aplicável. Não há como somar, comparar, imprimir ou construir um valor de
`a`.

Essa ignorância restringe fortemente o conjunto de implementações possíveis.
Uma função de tipo `[a] -> a` só pode devolver **um dos elementos que recebeu**,
porque não há outra fonte de valores daquele tipo. Ela não pode devolver uma
constante, não pode escolher um elemento comparando os outros, e não pode
combinar elementos.

A restrição vai além: **não existe função total de tipo `[a] -> a`**. Para a
lista vazia não há elemento algum a devolver, e nenhum valor de tipo `a` pode
ser fabricado. Toda implementação dessa assinatura é indefinida em pelo menos um
ponto do domínio.

O contraste com a versão monomórfica mede o efeito. O tipo `[Int] -> Int` admite
infinitas implementações totais — `sum`, `length`, `maximum`, `const 42`, e toda
combinação aritmética imaginável — porque `Int` traz consigo operações e
constantes. Daí um princípio que reaparece na nota sobre tipos polimórficos:
**quanto mais geral a assinatura, menos implementações ela admite, e portanto
mais ela informa** sobre o que a função faz.

### Funções de alta ordem

Uma **função de alta ordem** recebe funções como argumento ou devolve funções
como resultado. As três formas canônicas de consumir uma lista são funções de
alta ordem:

| Função | Assinatura | Efeito |
|--------|-----------|--------|
| `map` | `(a -> b) -> [a] -> [b]` | aplica a função a cada elemento |
| `filter` | `(a -> Bool) -> [a] -> [a]` | mantém os elementos que satisfazem o predicado |
| `foldl` | `(b -> a -> b) -> b -> [a] -> b` | reduz a lista a um único valor |

Funções anônimas são escritas com `\argumento -> expressão`:

```haskell
map (\x -> x + 1) [1, 2, 3, 4]      -- [2,3,4,5]
filter odd [1, 2, 3, 4]              -- [1,3]
foldl (\acc x -> acc + x) 0 [1..4]   -- 10
```

### Recursão no lugar do laço

Não há construção de repetição na linguagem. A recursão ocupa o lugar do laço, e
o caso-base é uma **equação**, não um desvio dentro do corpo:

```haskell
fatorial :: Integer -> Integer
fatorial 0 = 1
fatorial n = n * fatorial (n - 1)
```

A estrutura da definição espelha a definição matemática da função, e a
terminação depende de que a chamada recursiva se aproxime do caso-base — o que o
compilador não verifica.

### Transparência referencial

Uma função, no sentido desta disciplina, é a função da matemática: para a mesma
entrada, o mesmo resultado, sempre. A propriedade que decorre disso chama-se
**transparência referencial**: em qualquer ponto do programa, **substituir uma
chamada pelo seu resultado não altera o comportamento do programa**.

É essa propriedade, e não a sintaxe da linguagem, que autoriza três coisas:

- **memoizar** — guardar o resultado de uma chamada e reusá-lo, já que ele não
  muda;
- **reordenar** — trocar a ordem de duas subexpressões independentes, já que
  nenhuma afeta a outra;
- **avaliar em qualquer ordem**, inclusive não avaliar o que não for usado.

A contrapartida aparece na aula seguinte: nada que dependa do mundo externo —
leitura de teclado, hora do relógio, resposta de rede — cabe nessa definição, e
é essa incompatibilidade que obriga o tipo `IO` a existir.

### O limite da checagem de tipos

A checagem de tipos restringe o espaço de programas aceitos. Não o reduz ao
espaço dos programas corretos, e a distância entre os dois é grande.

```haskell
fatorialQuebrado :: Integer -> Integer
fatorialQuebrado 0 = 1
fatorialQuebrado n = n * fib (n - 1)
```

A assinatura está correta. O corpo chama `fib` no lugar da própria função. O
programa compila sem aviso e devolve `550` para a entrada `10`, onde o resultado
correto é `3628800` — o valor obtido é `10 × fib 9`.

O defeito passa porque **duas funções distintas partilham a assinatura
`Integer -> Integer`**, e o compilador verifica a assinatura, não a intenção.
Quanto mais habitado o tipo, menor a fração de erros que a checagem alcança — o
que reforça o princípio enunciado na seção sobre variáveis de tipo, agora pelo
lado negativo.

## Exemplos

O arquivo `codigo/01-funcoes.hs` reúne os exemplos desta nota e é executado com:

```sh
docker run --rm -v "$PWD":/w -w /w haskell:9.6-slim \
  runghc -Wincomplete-patterns 01-funcoes.hs
```

A execução emite dois avisos de casamento não exaustivo, para `cabeca` e para
`cauda`. Os avisos são esperados e fazem parte da exposição: é o compilador
exibindo a lacuna que a assinatura `[a] -> a` não registra, e que a nota sobre
tipos polimórficos fecha com `Maybe`.

O último valor impresso pelo programa é `550`, saída de `fatorialQuebrado 10`,
contra `3628800` de `fatorial 10`.

## Fontes e leituras

- LIPOVAČA, Miran. **Learn You a Haskell for Great Good!: a beginner's guide.**
  San Francisco: No Starch Press, 2011. Capítulo 4 (*Syntax in Functions*), para
  casamento de padrão e definição por equações; capítulo 6 (*Higher Order
  Functions*), para `map`, `filter` e `foldl`. Versão online em
  https://learnyouahaskell.github.io/ (*fork* comunitário, licença Creative
  Commons BY-NC-SA 3.0; a autoria indicada acima provém da edição impressa e não
  consta do site).

- TATE, Bruce A. **Seven Languages in Seven Weeks: a pragmatic guide to learning
  programming languages.** Raleigh: Pragmatic Bookshelf, 2010. Capítulo 8
  (Haskell), dias 1 e 2.
