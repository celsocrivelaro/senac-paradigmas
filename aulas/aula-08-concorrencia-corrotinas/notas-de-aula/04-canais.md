# Paradigmas de Programação — Aula 08: Concorrência, gorrotinas e canais — Canais

## Introdução

Gorrotinas executam de forma concorrente, mas raramente trabalham isoladas: uma
produz um dado que outra consome, ou várias entregam resultados a uma que os
reúne. Em Go, essa troca é feita por **canais**. Esta nota define o canal,
descreve o bloqueio que ele impõe a quem envia e a quem recebe, e apresenta as
três construções que completam o modelo: `close`, `range` e `select`.

## Objetivos de aprendizagem

Ao final desta nota, espera-se que o aluno seja capaz de:

1. Comunicar duas gorrotinas por um canal, enviando e recebendo valores.
2. Explicar o bloqueio de um canal sem *buffer*.
3. Usar `close` e `range` para consumir um canal sem saber quantos valores virão.
4. Usar `select` com `time.After` para impor um prazo à espera.

## Desenvolvimento teórico

### Canal

Um **canal** (*channel*) é um conduto tipado por onde uma gorrotina envia
valores e outra os recebe. É criado com `make`, e o tipo dos valores que
transporta faz parte do tipo do canal:

```go
ch := make(chan string) // canal de strings

ch <- "ping"            // envia
msg := <-ch             // recebe
```

O operador `<-` indica a direção: à esquerda do canal, envio; à direita,
recebimento. Na assinatura de uma função, `chan<- int` declara um canal em que
a função só envia, e `<-chan int`, um em que só recebe. A restrição é
verificada pelo compilador.

### Canal sem *buffer*

Um canal criado com `make(chan T)` não tem *buffer*: não guarda valor algum.
O envio **bloqueia** até que outra gorrotina receba, e o recebimento bloqueia
até que outra envie. As duas operações se encontram: quando o envio termina, o
valor já está nas mãos de quem recebeu.

Decorre daí que o canal é, ao mesmo tempo, meio de **comunicação** e de
**sincronização**. Depois de `msg := <-ch`, o programa sabe não só o valor
enviado, mas também que a gorrotina que o enviou já passou daquele ponto.

```go
ch := make(chan string)
go func() {
	ch <- "ping" // bloqueia até o main receber
}()
msg := <-ch      // bloqueia até a gorrotina enviar
```

Um canal com *buffer*, criado com `make(chan T, n)`, aceita até `n` envios sem
receptor; o envio só bloqueia quando o *buffer* está cheio. É uma variação
útil para desacoplar o ritmo de quem produz do de quem consome, e aparece no
exemplo da nota 05.

Quando nenhuma gorrotina pode prosseguir — todas bloqueadas em canais que
ninguém vai atender —, o *runtime* de Go encerra o programa com a mensagem
`fatal error: all goroutines are asleep - deadlock!`.

### Produtor e consumidor

O arranjo mais comum é o de **produtor e consumidor**: uma gorrotina gera
valores e os envia; outra os recebe e processa. Nenhuma variável é acessada
pelas duas — o dado passa de uma à outra pelo canal.

### `close` e `range`

O produtor sinaliza que não enviará mais nada **fechando** o canal com
`close(ch)`. O consumidor pode então percorrer o canal com `range`, que recebe
valor por valor e encerra quando o canal é fechado:

```go
func produzir(n int, saida chan<- int) {
	for i := 1; i <= n; i++ {
		saida <- i
	}
	close(saida)
}

numeros := make(chan int)
go produzir(10, numeros)
soma := 0
for n := range numeros {
	soma += n
}
// soma == 55
```

O consumidor não precisa saber quantos valores virão. Só quem envia fecha o
canal: enviar para um canal fechado é erro de execução.

### `select`

`select` espera em **vários canais ao mesmo tempo** e segue pelo primeiro caso
que ficar pronto. Sua sintaxe lembra a de um `switch`, mas cada caso é uma
operação de canal:

```go
select {
case r := <-respostas:
	fmt.Println("chegou:", r)
case <-time.After(100 * time.Millisecond):
	fmt.Println("prazo esgotado")
}
```

`time.After(d)` devolve um canal que recebe um valor depois de decorrido `d`.
Combinado com `select`, implementa **prazo**: se a resposta não chegar antes, o
caso do temporizador é o escolhido, e o programa segue sem ela.

### O princípio

A documentação da linguagem resume o modelo na máxima: *"Do not communicate by
sharing memory; instead, share memory by communicating"* — não comunique
compartilhando memória; compartilhe memória comunicando (THE GO AUTHORS, s.d.).

A frase descreve a mudança de arranjo em relação ao modelo da nota 02. Lá,
várias threads acessam o mesmo dado e o protegem com trava. Aqui, cada dado tem
um único dono, e as demais gorrotinas conversam com ele por canal. Como só o
dono acessa o dado, não há seção crítica a proteger.

Go também oferece travas (`sync.Mutex`), e há casos em que elas são a solução
mais simples. O canal é a forma preferida quando o problema é passar dados de
uma tarefa a outra.

## Exemplos

O arquivo `codigo/07-canais.go` reúne os três usos desta nota:

| Parte | O que demonstra | Saída |
|---|---|---|
| 1 | canal sem *buffer*: o `main` recebe o que a gorrotina envia | `recebido: ping` |
| 2 | produtor e consumidor com `close` e `range` | `soma de 1 a 10: 55` |
| 3 | `select` com prazo de 100 ms sobre uma resposta de 50 ms e outra de 300 ms | a primeira chega; a segunda, `prazo esgotado` |

## Fontes e leituras

- DONOVAN, Alan A. A.; KERNIGHAN, Brian W. **The Go Programming Language.**
  Boston: Addison-Wesley, 2015. Capítulo 8 (*Goroutines and Channels*).
- THE GO AUTHORS. **Effective Go**, seção *Concurrency*. Disponível em:
  https://go.dev/doc/effective_go.
