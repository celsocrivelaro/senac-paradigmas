// Aula 08 -- Exercicio 1: soma em partes
//
// O slice numeros ja esta preenchido com os inteiros de 1 a 1000.
// O resultado esperado e 500500.

package main

import "fmt"

// somarParte soma os elementos de parte e envia o resultado pelo canal.
func somarParte(parte []int, resultado chan<- int) {
	// a completar
}

func main() {
	numeros := make([]int, 1000)
	for i := range numeros {
		numeros[i] = i + 1
	}

	// a completar:
	//   1. criar o canal que recebe as somas parciais
	//   2. dividir numeros em quatro partes de 250 elementos
	//      (numeros[0:250], numeros[250:500], ...)
	//   3. disparar uma gorrotina somarParte para cada parte
	//   4. receber as quatro somas parciais do canal e acumula-las em total

	total := 0
	fmt.Println("total:", total)
}
