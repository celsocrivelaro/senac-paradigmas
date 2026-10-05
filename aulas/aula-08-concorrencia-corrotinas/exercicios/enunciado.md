# Exercícios em sala — Paradigmas de Programação — Aula 08: Concorrência, gorrotinas e canais

Dois exercícios **independentes**, cada um com seu arquivo em Go. Os dois usam
apenas gorrotina e canal, e nenhum lê arquivo ou rede: todo dado está no próprio
código.

Execução, em contêiner:

```sh
docker run --rm -v "$PWD":/w -w /w golang:1.23 go run exercicio-1-soma.go
```

---

# Exercício 1 — Soma em partes

Arquivo: [`exercicio-1-soma.go`](exercicio-1-soma.go). O *slice* `numeros` já
está preenchido com os inteiros de 1 a 1000.

## Parte 1 — A soma de uma parte

Implemente `somarParte(parte []int, resultado chan<- int)`, que soma os
elementos de `parte` e envia a soma pelo canal `resultado`.

## Parte 2 — Quatro gorrotinas

No `main`, crie o canal, divida `numeros` em quatro partes de 250 elementos e
dispare uma gorrotina `somarParte` para cada parte. Receba as quatro somas
parciais do canal e acumule-as em `total`.

O `main` recebe **exatamente quatro** valores: nem mais, nem menos. Registre em
comentário, no topo do arquivo, o que acontece se o `main` tentar receber um
quinto valor, e o que acontece se receber só três.

## Entregável e verificação

O arquivo executando, com o registro da Parte 2 em comentário no topo.

1. O programa imprime `total: 500500`.
2. Cada parte é somada por uma gorrotina, e as somas parciais chegam ao `main`
   pelo canal — nenhuma variável é alterada por mais de uma gorrotina.

---

# Exercício 2 — Health check de serviços

Arquivo: [`exercicio-2-health-check.go`](exercicio-2-health-check.go).

Um sistema tem quatro serviços, e um painel de monitoramento verifica
periodicamente se cada um responde. A verificação de um serviço demora o tempo
de resposta dele. O arquivo já traz a lista `servicos`, com nome e latência de
cada um, e a função `verificar`, que simula a verificação e devolve a linha de
status:

| Serviço | Latência |
|---------|----------|
| `autenticacao` | 120 ms |
| `pagamentos` | 300 ms |
| `estoque` | 80 ms |
| `notificacoes` | 200 ms |

## Parte 1 — Versão sequencial

Implemente `sequencial()`, que verifica um serviço de cada vez, na ordem da
lista, e imprime cada linha de status. Execute e anote o tempo total.

## Parte 2 — Versão concorrente

Implemente `concorrente()`: cada verificação roda em uma gorrotina, que envia a
linha de status por um canal. A função recebe as quatro linhas e as imprime na
ordem em que chegam.

## Parte 3 — O registro

Preencha o comentário no topo do arquivo, em duas ou três frases:

- por que a ordem das linhas na versão concorrente não é a ordem da lista;
- por que o tempo total cai, e de quanto para quanto.

## Entregável e verificação

O arquivo executando, com o registro da Parte 3 no topo.

1. A versão sequencial leva cerca de 700 ms e imprime as linhas na ordem da
   lista.
2. A versão concorrente leva cerca de 300 ms e imprime as linhas em ordem
   crescente de latência.
3. O registro relaciona o tempo da versão concorrente ao serviço mais lento.
