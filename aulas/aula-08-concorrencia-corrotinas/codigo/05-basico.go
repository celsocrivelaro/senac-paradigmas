// Aula 08, Bloco 3 -- O basico de Go
//
// O minimo da linguagem para ler os arquivos seguintes, uma ideia por funcao.

package main

import (
	"errors"
	"fmt"
)

// Funcao: parametros com o tipo depois do nome, e o tipo de retorno no fim.
func dobro(x int) int {
	return x * 2
}

// Variaveis: var com tipo explicito, ou := que declara e infere o tipo.
func variaveis() {
	var nome string = "Go"
	versao := 1.23
	fmt.Println("linguagem:", nome, "versao:", versao)
}

// for e o unico laco da linguagem. Nao ha while: um for so com a condicao
// faz o mesmo papel.
func somaAte(n int) int {
	total := 0
	for i := 1; i <= n; i++ {
		total += i
	}
	return total
}

// Slice: sequencia de tamanho variavel. range percorre devolvendo indice e valor.
func maior(numeros []int) int {
	m := numeros[0]
	for _, n := range numeros {
		if n > m {
			m = n
		}
	}
	return m
}

// Struct: agrupa campos com nome. Fornecedor reaparece no exemplo da cotacao.
type Fornecedor struct {
	Nome  string
	Preco float64
}

// Dois retornos: o valor e um erro. Go nao tem excecao; a falha volta como
// valor, e quem chama confere se err e nil.
func dividir(a, b int) (int, error) {
	if b == 0 {
		return 0, errors.New("divisao por zero")
	}
	return a / b, nil
}

func main() {
	fmt.Println("dobro(21) =", dobro(21))

	variaveis()

	fmt.Println("somaAte(10) =", somaAte(10))

	fmt.Println("maior =", maior([]int{3, 9, 4, 1}))

	f := Fornecedor{Nome: "Loja A", Preco: 99.90}
	fmt.Println(f.Nome, "cobra", f.Preco)

	if q, err := dividir(10, 2); err == nil {
		fmt.Println("10 / 2 =", q)
	}
	if _, err := dividir(10, 0); err != nil {
		fmt.Println("erro:", err)
	}
}
