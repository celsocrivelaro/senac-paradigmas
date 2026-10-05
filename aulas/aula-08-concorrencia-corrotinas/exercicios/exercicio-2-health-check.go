// Aula 08 -- Exercicio 2: health check de servicos
//
// Explicacao da diferenca de tempo entre as duas versoes -- preencher aqui:
//

package main

import (
	"fmt"
	"time"
)

type Servico struct {
	Nome     string
	Latencia time.Duration
}

var servicos = []Servico{
	{Nome: "autenticacao", Latencia: 120 * time.Millisecond},
	{Nome: "pagamentos", Latencia: 300 * time.Millisecond},
	{Nome: "estoque", Latencia: 80 * time.Millisecond},
	{Nome: "notificacoes", Latencia: 200 * time.Millisecond},
}

// verificar simula a verificacao de um servico: espera a latencia dele e
// devolve a linha de status.
func verificar(s Servico) string {
	time.Sleep(s.Latencia)
	return fmt.Sprintf("%s: ok (%v)", s.Nome, s.Latencia)
}

// PARTE 1 -- verifica um servico de cada vez e imprime cada linha.
func sequencial() {
	// a completar
}

// PARTE 2 -- cada verificacao em uma gorrotina, que envia a linha por um
// canal; imprime as linhas na ordem em que chegam.
func concorrente() {
	// a completar
}

func main() {
	fmt.Println("== Sequencial")
	inicio := time.Now()
	sequencial()
	fmt.Println("tempo:", time.Since(inicio).Round(10*time.Millisecond))

	fmt.Println("\n== Concorrente")
	inicio = time.Now()
	concorrente()
	fmt.Println("tempo:", time.Since(inicio).Round(10*time.Millisecond))
}
