// Aula 08, Bloco 3 -- Gorrotinas
//
// A mesma funcao tarefa chamada de tres formas: em sequencia, como gorrotinas
// aguardadas por um WaitGroup e como gorrotinas que ninguem aguarda.

package main

import (
	"fmt"
	"sync"
	"time"
)

// tarefa imprime tres passos, com uma pausa entre eles. Se receber um
// WaitGroup, avisa o termino a ele; com nil, ninguem a aguarda.
func tarefa(nome string, wg *sync.WaitGroup) {
	if wg != nil {
		defer wg.Done() // avisa o termino ao WaitGroup
	}
	for i := 1; i <= 3; i++ {
		fmt.Println(nome, "passo", i)
		time.Sleep(100 * time.Millisecond)
	}
}

func main() {
	fmt.Println("== 1. Em sequencia: B so comeca quando A termina")
	inicio := time.Now()
	tarefa("A", nil)
	tarefa("B", nil)
	fmt.Println("tempo:", time.Since(inicio).Round(100*time.Millisecond))

	fmt.Println("\n== 2. Gorrotinas: A e B intercalam")
	inicio = time.Now()
	var wg sync.WaitGroup
	wg.Add(2) // duas gorrotinas a aguardar
	go tarefa("A", &wg)
	go tarefa("B", &wg)
	wg.Wait() // bloqueia o main ate as duas chamarem Done
	fmt.Println("tempo:", time.Since(inicio).Round(100*time.Millisecond))

	fmt.Println("\n== 3. Gorrotinas sem espera: o main termina antes delas")
	go tarefa("C", nil)
	go tarefa("D", nil)
	// Sem wg.Wait(), o main chega ao fim imediatamente. Quando main retorna, o
	// programa termina, e as gorrotinas C e D sao interrompidas no caminho.
	time.Sleep(50 * time.Millisecond)
	fmt.Println("fim do main")
}
