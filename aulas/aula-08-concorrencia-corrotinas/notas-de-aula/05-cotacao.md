# Paradigmas de Programação — Aula 08: Concorrência, gorrotinas e canais — Exemplo: cotação em vários fornecedores

## Introdução

Esta nota aplica gorrotinas, canais e `select` a um problema recorrente em
sistemas reais: obter uma resposta de vários serviços externos, cada um com um
tempo de resposta diferente, sem esperar por todos em sequência. O caso é o de
um buscador de passagens ou de uma calculadora de frete, que consulta vários
fornecedores e apresenta o menor preço. O exemplo reúne os conceitos das notas
anteriores e torna mensurável a distinção da nota 01 entre esperar e calcular.

## Objetivos de aprendizagem

Ao final desta nota, espera-se que o aluno seja capaz de:

1. Estruturar consultas independentes como gorrotinas que respondem por um
   canal.
2. Impor um prazo à coleta das respostas com `select` e `time.After`.
3. Explicar por que o tempo total é o da consulta mais lenta, e não a soma, e
   por que o ganho existe mesmo em um único núcleo.

## Desenvolvimento teórico

### O problema

Um serviço precisa do menor preço entre três fornecedores. Cada fornecedor é
consultado por uma chamada que demora um tempo diferente:

| Fornecedor | Preço | Latência |
|---|---|---|
| Loja A | R$ 129,90 | 100 ms |
| Loja B | R$ 99,90 | 250 ms |
| Loja C | R$ 114,50 | 180 ms |

Consultadas uma de cada vez, as três levam 100 + 250 + 180 = 530 ms. As
consultas são **independentes** — nenhuma precisa do resultado de outra — e
passam quase todo o tempo **esperando** a resposta, sem usar CPU. São
exatamente as condições em que a concorrência reduz o tempo total.

No exemplo, a latência é simulada com `time.Sleep`, para que o programa execute
sem rede e com saída previsível. Num sistema real, a espera seria uma chamada
HTTP.

### A estrutura

Cada fornecedor é um `struct`, e cada consulta é uma gorrotina que espera a
latência e envia o fornecedor pelo canal de respostas:

```go
type Fornecedor struct {
	Nome     string
	Preco    float64
	Latencia time.Duration
}

func consultar(f Fornecedor, respostas chan<- Fornecedor) {
	time.Sleep(f.Latencia)
	respostas <- f
}
```

A função que cota dispara as três consultas e recebe as respostas à medida que
chegam, guardando a mais barata:

```go
respostas := make(chan Fornecedor, len(fornecedores))
for _, f := range fornecedores {
	go consultar(f, respostas)
}
```

O canal tem *buffer* do tamanho da lista. A razão aparece com o prazo: uma
consulta que responde depois do prazo encontra o `main` já sem receber, e num
canal sem *buffer* ficaria bloqueada para sempre. Com o *buffer*, ela envia e
termina.

### O prazo

Um serviço real não espera indefinidamente por um fornecedor lento. O `select`
recebe respostas até que todas cheguem ou até que o prazo se esgote, o que
ocorrer primeiro:

```go
limite := time.After(prazo)
espera:
for recebidas < len(fornecedores) {
	select {
	case f := <-respostas:
		recebidas++
		// compara com o melhor preço até aqui
	case <-limite:
		break espera
	}
}
```

`espera` é um rótulo: `break espera` sai do `for`, e não apenas do `select`.
O temporizador é criado **uma vez**, antes do laço; criado dentro do `select`,
ele recomeçaria a cada resposta.

### A medição

O programa executa a cotação duas vezes, com a mesma lista e prazos diferentes:

```
== Prazo de 500 ms: os tres respondem
  Loja A   R$ 129.90  (100ms)
  Loja C   R$ 114.50  (180ms)
  Loja B   R$  99.90  (250ms)
  melhor: Loja B, R$ 99.90
  tempo total: 250ms

== Prazo de 200 ms: a Loja B, a mais barata, fica de fora
  Loja A   R$ 129.90  (100ms)
  Loja C   R$ 114.50  (180ms)
  prazo esgotado: 1 fornecedor(es) descartado(s)
  melhor: Loja C, R$ 114.50
  tempo total: 200ms
```

Três observações decorrem da saída:

1. **As respostas chegam em ordem de latência**, e não na ordem da lista. A
   ordem de chegada é decidida pelo tempo de cada consulta.
2. **Com prazo folgado, o tempo total é 250 ms**, a latência da consulta mais
   lenta, e não os 530 ms da soma. As três esperas se sobrepõem. O ganho não
   depende de haver três núcleos: enquanto uma consulta espera, as outras
   também esperam, e nenhuma ocupa o processador. É o caso de tarefa limitada
   por E/S da nota 01.
3. **Com prazo curto, o tempo total é o próprio prazo**, e o resultado muda: a
   Loja B, a mais barata, é descartada por ser a mais lenta. O prazo troca
   qualidade da resposta por previsibilidade do tempo, e a escolha entre os
   dois é uma decisão de projeto.

### Comparação com o modelo de threads

O mesmo problema no modelo da nota 02 exigiria três threads, uma estrutura
compartilhada onde cada uma registrasse a sua resposta e uma trava sobre essa
estrutura. No programa em Go, nenhum dado é compartilhado: cada resposta viaja
pelo canal, e só a função `cotar` lê e compara os preços. É a máxima da nota 04
aplicada — o melhor preço tem um único dono, e as consultas conversam com ele
por canal.

## Exemplos

O programa completo está em `codigo/08-cotacao.go`:

```sh
docker run --rm -v "$PWD":/w -w /w golang:1.23 go run 08-cotacao.go
```

Os tempos medidos variam alguns milissegundos entre execuções; a ordem das
respostas e o fornecedor escolhido não variam.

## Fontes e leituras

- DONOVAN, Alan A. A.; KERNIGHAN, Brian W. **The Go Programming Language.**
  Boston: Addison-Wesley, 2015. Capítulo 8 (*Goroutines and Channels*).
- PIKE, Rob. **Concurrency is not Parallelism.** Palestra apresentada na
  Heroku Waza, São Francisco, 2012.
