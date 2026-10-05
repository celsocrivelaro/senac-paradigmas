// Aula 08, Bloco 5 -- Cotacao em varios fornecedores
//
// Um servico precisa do menor preco entre tres fornecedores. Cada consulta
// demora um tempo diferente (simulado com time.Sleep). As consultas rodam em
// gorrotinas, as respostas voltam por um canal, e um prazo descarta quem
// demorar demais.

package main

import (
	"fmt"
	"time"
)

type Fornecedor struct {
	Nome     string
	Preco    float64
	Latencia time.Duration
}

// consultar simula a chamada ao fornecedor: espera a latencia e envia a resposta.
func consultar(f Fornecedor, respostas chan<- Fornecedor) {
	time.Sleep(f.Latencia)
	respostas <- f
}

// cotar consulta todos os fornecedores ao mesmo tempo e devolve o mais barato
// entre os que responderam dentro do prazo.
func cotar(fornecedores []Fornecedor, prazo time.Duration) {
	inicio := time.Now()

	// Buffer do tamanho da lista: quem responder depois do prazo consegue
	// enviar e terminar, mesmo sem ninguem recebendo.
	respostas := make(chan Fornecedor, len(fornecedores))
	for _, f := range fornecedores {
		go consultar(f, respostas)
	}

	limite := time.After(prazo)
	var melhor *Fornecedor
	recebidas := 0

espera:
	for recebidas < len(fornecedores) {
		select {
		case f := <-respostas:
			recebidas++
			fmt.Printf("  %-8s R$ %6.2f  (%v)\n", f.Nome, f.Preco, f.Latencia)
			if melhor == nil || f.Preco < melhor.Preco {
				melhor = &f
			}
		case <-limite:
			fmt.Println("  prazo esgotado:", len(fornecedores)-recebidas, "fornecedor(es) descartado(s)")
			break espera
		}
	}

	if melhor != nil {
		fmt.Printf("  melhor: %s, R$ %.2f\n", melhor.Nome, melhor.Preco)
	}
	fmt.Println("  tempo total:", time.Since(inicio).Round(10*time.Millisecond))
}

func main() {
	fornecedores := []Fornecedor{
		{Nome: "Loja A", Preco: 129.90, Latencia: 100 * time.Millisecond},
		{Nome: "Loja B", Preco: 99.90, Latencia: 250 * time.Millisecond},
		{Nome: "Loja C", Preco: 114.50, Latencia: 180 * time.Millisecond},
	}

	// Em sequencia, o tempo seria a soma das latencias: 100 + 250 + 180 = 530 ms.
	fmt.Println("== Prazo de 500 ms: os tres respondem")
	cotar(fornecedores, 500*time.Millisecond)

	fmt.Println("\n== Prazo de 200 ms: a Loja B, a mais barata, fica de fora")
	cotar(fornecedores, 200*time.Millisecond)
}
