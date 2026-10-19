# Paradigmas de Programação — Aula 09: Modelo de atores com Elixir — Elixir

## Introdução

Elixir é uma linguagem funcional, de tipagem dinâmica, criada por José Valim e
apresentada publicamente em 2012, que executa sobre a máquina virtual de Erlang. A linguagem é a
implementação do modelo de atores usada no restante da aula. Esta nota
apresenta a máquina virtual e o sentido que a palavra "processo" tem nela, e em
seguida o básico da linguagem — o suficiente para ler os exemplos das notas
seguintes. Serve de referência de leitura, e não de curso da linguagem.

## Objetivos de aprendizagem

Ao final desta nota, espera-se que o aluno seja capaz de:

1. Distinguir um processo da BEAM de um processo e de uma thread do sistema
   operacional.
2. Ler um programa Elixir básico, com átomos, tuplas, *pattern matching*,
   `case`, módulos, funções com várias cláusulas e guarda, recursão e o
   operador `|>`.
3. Explicar por que, em Elixir, "alterar" um dado produz um dado novo, e
   relacionar isso com a imutabilidade da aula 07.

## Desenvolvimento teórico

### A BEAM

A **BEAM** é a máquina virtual da linguagem Erlang, criada na Ericsson para
sistemas de telefonia que precisavam operar continuamente, com tolerância a
falhas e muitas atividades simultâneas (ARMSTRONG, 2003). Erlang interessa a
esta aula apenas como essa origem. Elixir compila para o mesmo *bytecode* que
Erlang, executa na mesma máquina virtual e usa a mesma biblioteca de padrões
de processo, o OTP, assunto da nota 04. Valim criou a linguagem para reunir a
robustez e a distribuição da máquina virtual de Erlang à metaprogramação e ao
polimorfismo de Clojure, sob uma sintaxe diferente da de Erlang (VALIM, 2014).

Um **processo**, na BEAM, é a unidade de execução concorrente da máquina
virtual: tem pilha, *heap* e caixa de correio próprios, não compartilha
memória com nenhum outro processo e se comunica apenas por mensagens. É,
portanto, um ator no sentido da nota 01.

Um processo da BEAM **não** é um processo nem uma thread do sistema
operacional. A máquina virtual executa algumas threads do sistema — em geral,
uma por núcleo, cada uma com o seu escalonador — e distribui os processos sobre
elas, no mesmo arranjo *M:N* das gorrotinas da aula 08. A diferença em relação
a Go está no isolamento: a gorrotina compartilha o espaço de endereçamento com
as demais, e o processo da BEAM não. Um processo começa com poucos kilobytes de
memória, e a documentação da linguagem registra como corrente um programa com
dezenas ou centenas de milhares de processos simultâneos (ELIXIR, s.d.).

| | Processo do SO | Thread do SO | Processo da BEAM |
|---|---|---|---|
| Escalonado por | sistema operacional | sistema operacional | máquina virtual |
| Memória | isolada | compartilhada com as threads do mesmo processo | isolada |
| Comunicação | *pipe*, *socket*, arquivo | variável compartilhada | mensagem |
| Custo de criação | o maior dos três: novo espaço de endereçamento | pilha da ordem de 1 MB | poucos kilobytes |

No restante da aula, "processo" designa sempre um processo da BEAM.

### O básico da linguagem

Os trechos desta seção estão em `codigo/01-basico.exs`, executado com
`elixir 01-basico.exs` na imagem `elixir:1.17`. Todo dado em Elixir é
**imutável**, como na aula 07: nenhuma operação altera um valor existente, e
toda "alteração" devolve um valor novo.

**Átomo.** Um **átomo** é uma constante cujo valor é o próprio nome, escrita com
`:` à frente. Funciona como rótulo, e dois átomos de mesmo nome são iguais:

```elixir
IO.inspect(:ok)          # :ok
IO.inspect(:ok == :ok)   # true
```

**Tupla e o padrão de resultado.** Uma **tupla** é uma sequência fixa de
valores entre chaves. A convenção da linguagem é devolver `{:ok, valor}` no
sucesso e `{:erro, motivo}` na falha — a falha volta como valor, como o par
`(resultado, error)` de Go:

```elixir
def dividir(_dividendo, 0), do: {:erro, :divisao_por_zero}
def dividir(dividendo, divisor), do: {:ok, dividendo / divisor}
```

***Pattern matching*.** O operador `=` não é atribuição, é **casamento de
padrão** (*pattern matching*): o lado esquerdo é um padrão, e as variáveis dele
recebem as partes correspondentes do lado direito. Se o valor não casa com o
padrão, ocorre erro de execução. O padrão `[cabeca | cauda]` separa o primeiro
elemento de uma lista do restante:

```elixir
{:ok, resultado} = dividir(10, 4)   # resultado = 2.5
[primeiro | resto] = [1, 2, 3]      # primeiro = 1, resto = [2, 3]
```

**`case`.** Escolhe o primeiro padrão que casa com o valor:

```elixir
case divisao do
  {:ok, valor} -> "resultado #{valor}"
  {:erro, motivo} -> "falhou: #{motivo}"
end
```

`#{...}` é **interpolação**: insere o valor da expressão na *string*.

**Módulo e função.** `defmodule` define um módulo, e `def`, uma função dentro
dele. Uma função de várias **cláusulas** tem uma definição por caso; na
chamada, vale a primeira cuja lista de parâmetros casa com os argumentos e cuja
**guarda** (`when`), se houver, é verdadeira. O `_` casa com qualquer valor e o
descarta:

```elixir
def classificar(numero) when numero < 0, do: :negativo
def classificar(0), do: :zero
def classificar(_numero), do: :positivo
```

A forma `def f(x), do: expr` é a abreviação de uma linha para
`def f(x) do expr end`. Uma função é identificada pelo nome e pela aridade:
`classificar/1` é a função `classificar` de um argumento.

**Recursão no lugar de laço.** Não há laço com variável de controle, porque não
há variável a atualizar (o `for` de Elixir é uma compreensão, que produz uma
lista nova). A repetição é escrita por recursão, e as cláusulas
separam o caso base do caso recursivo:

```elixir
def somar([]), do: 0
def somar([cabeca | cauda]), do: cabeca + somar(cauda)
```

Esta `somar` não é recursiva de cauda: a soma com `cabeca` é feita depois que a
chamada recursiva retorna, e a pilha cresce com o tamanho da lista. A
recursão de cauda, em que a chamada recursiva é a última operação, reaparece na
nota 03 como a forma de um processo manter estado sem fazer a pilha crescer.

**O operador `|>`.** `x |> f(a)` equivale a `f(x, a)`: o valor da esquerda
entra como **primeiro** argumento da função da direita. Uma sequência de
transformações passa a ser lida na ordem em que é aplicada:

```elixir
lista
|> Enum.filter(fn numero -> rem(numero, 2) == 0 end)
|> Enum.map(fn numero -> numero * numero end)
```

`fn numero -> ... end` é uma função anônima. Sem o operador, a mesma expressão
seria `Enum.map(Enum.filter(lista, ...), ...)`, lida de dentro para fora.

***Map*.** Associa chaves a valores. `Map.put` não altera o *map* recebido:
devolve um novo, com a chave acrescentada, e o original permanece intacto:

```elixir
pagamento = %{id: "pg-1", valor: 120.0}
aprovado = Map.put(pagamento, :status, :aprovado)
```

Quando as chaves são átomos, `aprovado.valor` lê o campo.

### Imutabilidade e estado

A aula 07 mostrou que "alterar" uma estrutura imutável produz uma estrutura
nova. Em Elixir não há outra forma de dado, e isso vale também para o estado de
um processo: como nenhuma variável pode ser reescrita, o estado de um ator muda
apenas porque a função que o representa é chamada de novo com outro argumento.
É a terceira ação da nota 01 — definir o comportamento para a próxima mensagem
— e a forma que a nota 03 usa para escrever um ator.

## Exemplos

Saída de `elixir 01-basico.exs` (Elixir 1.17.3):

```
== Atomos
:ok
:erro
true

== Tuplas e pattern matching
10 / 4 = 2.5
primeiro: 1, resto: [2, 3]
resultado 3.0
falhou: divisao_por_zero

== Clausulas e guarda
[:negativo, :zero, :positivo]

== Recursao e |>
soma: 10
[4, 16, 36]

== Maps
%{id: "pg-1", valor: 120.0}
%{id: "pg-1", status: :aprovado, valor: 120.0}
valor: 120.0
```

| Seção | O que mostra |
|---|---|
| Átomos | átomo como valor que se imprime e se compara pelo nome |
| Tuplas e *pattern matching* | `/` devolve sempre número de ponto flutuante (`9 / 3` é `3.0`); `case` separa sucesso e falha |
| Cláusulas e guarda | `&Basico.classificar/1` passa a função como argumento a `Enum.map`; cada elemento cai numa cláusula |
| Recursão e `\|>` | `somar` percorre a lista por recursão; o *pipeline* filtra os pares e eleva ao quadrado |
| *Maps* | o *map* original continua sem `:status` depois de `Map.put` |

## Fontes e leituras

- ARMSTRONG, Joe. **Making reliable distributed systems in the presence of
  software errors.** 2003. Tese (Doutorado) — Royal Institute of Technology,
  Estocolmo, 2003.
- ELIXIR. **Getting Started**, seções *Basic types*, *Pattern matching*,
  *case, cond, and if*, *Modules and functions*, *Recursion* e *Processes*.
  Disponível em: https://hexdocs.pm/elixir.
- TATE, Bruce A. et al. **Seven More Languages in Seven Weeks: Languages That
  Are Shaping the Future.** Dallas: The Pragmatic Bookshelf, 2014. Capítulo 4
  (*Elixir*), p. 125–169.
- VALIM, José. Foreword. In: TATE, Bruce A. et al. **Seven More Languages in
  Seven Weeks.** Dallas: The Pragmatic Bookshelf, 2014. p. vii–viii.
