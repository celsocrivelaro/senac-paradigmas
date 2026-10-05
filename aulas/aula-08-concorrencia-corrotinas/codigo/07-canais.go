// Aula 08, Bloco 4 -- Canais
//
// Tres usos de canal: o encontro entre quem envia e quem recebe, o par
// produtor e consumidor com close e range, e a espera com prazo usando select.

package main

import (
	"fmt"
	"time"
)

// produzir envia os inteiros de 1 a n pelo canal e o fecha ao terminar.
// O tipo chan<- int indica que esta funcao so envia.
func produzir(n int, saida chan<- int) {
	for i := 1; i <= n; i++ {
		saida <- i
	}
	close(saida) // avisa ao consumidor que nao vira mais nada
}

// demorar espera o tempo pedido e envia uma mensagem.
func demorar(d time.Duration, saida chan<- string) {
	time.Sleep(d)
	saida <- fmt.Sprint("respondeu em ", d)
}

func main() {
	fmt.Println("== 1. Canal sem buffer: envio e recebimento se encontram")
	ch := make(chan string)
	go func() {
		ch <- "ping" // bloqueia ate o main receber
	}()
	msg := <-ch // bloqueia ate a gorrotina enviar
	fmt.Println("recebido:", msg)

	fmt.Println("\n== 2. Produtor e consumidor")
	numeros := make(chan int)
	go produzir(10, numeros)
	soma := 0
	// range recebe ate o canal ser fechado; nao e preciso saber quantos valores virao.
	for n := range numeros {
		soma += n
	}
	fmt.Println("soma de 1 a 10:", soma)

	fmt.Println("\n== 3. select com prazo")
	rapido := make(chan string)
	go demorar(50*time.Millisecond, rapido)
	select {
	case r := <-rapido:
		fmt.Println("rapido:", r)
	case <-time.After(100 * time.Millisecond):
		fmt.Println("rapido: prazo esgotado")
	}

	lento := make(chan string, 1) // buffer de 1: o envio tardio nao bloqueia a gorrotina
	go demorar(300*time.Millisecond, lento)
	select {
	case r := <-lento:
		fmt.Println("lento:", r)
	case <-time.After(100 * time.Millisecond):
		fmt.Println("lento: prazo esgotado")
	}
}
