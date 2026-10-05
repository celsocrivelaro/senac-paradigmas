# Paradigmas de Programação — Aula 08: Concorrência, gorrotinas e canais — Go e gorrotinas

## Introdução

Go é uma linguagem compilada e de tipagem estática, criada no Google e lançada
em 2009, com a concorrência como recurso da própria linguagem: uma palavra-chave
para iniciar uma tarefa concorrente e um tipo para comunicar tarefas entre si.
Esta nota apresenta o básico da linguagem — o suficiente para ler os exemplos
da aula — e a primeira das duas construções: a **gorrotina**. A segunda, o
canal, é assunto da nota seguinte.

## Objetivos de aprendizagem

Ao final desta nota, espera-se que o aluno seja capaz de:

1. Ler e escrever um programa Go básico, com funções, variáveis, laço, *slice*,
   `struct` e função de dois retornos.
2. Disparar gorrotinas e aguardar o seu término com `sync.WaitGroup`.
3. Explicar por que o programa termina sem esperar as gorrotinas quando nada as
   aguarda.

## Desenvolvimento teórico

### O básico da linguagem

Esta seção serve de referência de leitura, e não de curso da linguagem. Os
trechos estão em `codigo/05-basico.go`.

**Programa.** Todo programa executável pertence ao pacote `main` e começa pela
função `main`. Pacotes da biblioteca padrão são importados pelo nome:

```go
package main

import "fmt"

func main() {
	fmt.Println("ola")
}
```

**Função.** O tipo de cada parâmetro vem depois do nome, e o tipo de retorno,
depois da lista de parâmetros:

```go
func dobro(x int) int {
	return x * 2
}
```

**Variáveis.** `var` declara com tipo explícito; `:=` declara e infere o tipo a
partir do valor. A segunda forma só existe dentro de funções e é a mais usada:

```go
var nome string = "Go"
versao := 1.23
```

**Laço.** `for` é o único laço da linguagem. Na forma de três cláusulas,
equivale ao `for` de C e Java; com só a condição, faz o papel do `while`:

```go
total := 0
for i := 1; i <= n; i++ {
	total += i
}
```

***Slice* e `range`.** Um *slice* é uma sequência de tamanho variável,
escrita `[]int`. `range` percorre um *slice* devolvendo, a cada volta, o índice
e o valor; o identificador `_` descarta o que não se usa:

```go
for _, n := range []int{3, 9, 4, 1} {
	fmt.Println(n)
}
```

**`struct`.** Agrupa campos com nome. Não há classes; um `struct` é um tipo de
dado, e a notação de ponto acessa os campos:

```go
type Fornecedor struct {
	Nome  string
	Preco float64
}

f := Fornecedor{Nome: "Loja A", Preco: 99.90}
fmt.Println(f.Nome)
```

**Dois retornos e erro.** Go não tem exceções. Uma função que pode falhar
devolve dois valores — o resultado e um `error` — e quem chama confere se o erro
é `nil`:

```go
func dividir(a, b int) (int, error) {
	if b == 0 {
		return 0, errors.New("divisao por zero")
	}
	return a / b, nil
}

if q, err := dividir(10, 2); err == nil {
	fmt.Println(q)
}
```

### Gorrotina

Uma **gorrotina** (*goroutine*) é uma função executada de forma concorrente com
o restante do programa. É criada escrevendo a palavra-chave `go` antes de uma
chamada de função:

```go
tarefa("A")    // chamada comum: o programa espera tarefa terminar
go tarefa("A") // gorrotina: o programa segue imediatamente
```

A chamada comum só devolve o controle quando a função termina. A chamada com
`go` devolve o controle na hora: a função passa a executar concorrentemente, e
a linha seguinte do programa já é executada.

O mecanismo que torna gorrotinas diferentes de threads é o **escalonador do
*runtime* de Go**. Uma gorrotina não é uma thread do sistema operacional: o
*runtime* mantém um conjunto pequeno de threads — por padrão, uma por núcleo
disponível — e distribui as gorrotinas sobre elas, trocando a gorrotina em
execução quando uma delas bloqueia (DONOVAN; KERNIGHAN, 2015). Esse arranjo,
em que muitas tarefas da linguagem são executadas sobre poucas threads do
sistema, é chamado de escalonamento *M:N*.

A consequência prática é o custo. Uma gorrotina começa com uma pilha de poucos
kilobytes, que cresce conforme a necessidade; uma thread do sistema operacional
reserva uma pilha de tamanho fixo, tipicamente da ordem de um megabyte. Um
programa Go cria milhares de gorrotinas sem esforço, quantidade que, em threads,
esgotaria a memória.

A função disparada pode ser anônima. Nesse caso, é uma closure, no sentido da
aula 07: captura as variáveis do escopo em que foi escrita.

```go
go func() {
	tarefa("A")
}()
```

### O `main` não espera

Quando a função `main` retorna, o programa termina — com ou sem gorrotinas em
andamento. As gorrotinas não terminadas são interrompidas no ponto em que
estavam, sem aviso.

Um programa que dispara gorrotinas e chega ao fim do `main` logo em seguida
perde, portanto, o trabalho delas. É preciso que o `main` **aguarde**. A forma
mais direta é o `sync.WaitGroup`, um contador de tarefas pendentes:

| Operação | Efeito |
|---|---|
| `wg.Add(n)` | soma `n` ao contador de tarefas pendentes, antes de disparar as gorrotinas |
| `wg.Done()` | subtrai 1, chamado por cada gorrotina ao terminar |
| `wg.Wait()` | bloqueia até o contador chegar a zero |

```go
var wg sync.WaitGroup
wg.Add(2)
go func() {
	defer wg.Done()
	tarefa("A")
}()
go func() {
	defer wg.Done()
	tarefa("B")
}()
wg.Wait()
```

`defer` adia a chamada para o momento em que a função anônima retorna; assim,
`Done` é chamado mesmo que `tarefa` termine por um caminho inesperado.

A função anônima existe só para chamar `Done`. Se a própria `tarefa` receber o
`WaitGroup`, ela mesma avisa o término, e a gorrotina é disparada direto. O
parâmetro é um **ponteiro** (`*sync.WaitGroup`): passado por valor, a função
receberia uma cópia, o `Done` diminuiria o contador da cópia e o `wg.Wait()` do
`main` nunca terminaria.

```go
func tarefa(nome string, wg *sync.WaitGroup) {
	defer wg.Done()
	// ...
}

wg.Add(2)
go tarefa("A", &wg)
go tarefa("B", &wg)
wg.Wait()
```

## Exemplos

O arquivo `codigo/06-gorrotinas.go` chama a mesma função `tarefa` — três passos
com pausa de 100 ms entre eles — de três formas. A `tarefa` recebe um
`*sync.WaitGroup` e só chama `Done` quando ele não é `nil`; as partes que não
aguardam passam `nil`.

| Parte | Forma | Saída |
|---|---|---|
| 1 | `tarefa("A", nil)` e depois `tarefa("B", nil)` | todos os passos de A, depois todos os de B; 600 ms |
| 2 | `go tarefa("A", &wg)`, `go tarefa("B", &wg)` e `wg.Wait()` | passos de A e de B intercalados; 300 ms |
| 3 | duas gorrotinas com `nil`, sem espera | só o primeiro passo de cada uma, e o programa termina |

A Parte 2 leva metade do tempo da Parte 1 porque as pausas das duas tarefas se
sobrepõem — a tarefa espera, e não calcula, como na nota 01. A Parte 3 mostra o
`main` terminando antes das gorrotinas.

## Fontes e leituras

- DONOVAN, Alan A. A.; KERNIGHAN, Brian W. **The Go Programming Language.**
  Boston: Addison-Wesley, 2015. Capítulos 1 (*Tutorial*) e 8 (*Goroutines and
  Channels*).
- THE GO AUTHORS. **A Tour of Go.** Disponível em: https://go.dev/tour/.
