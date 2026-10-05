# Aula 08 — código de exemplo

Oito arquivos, um por caso. Os quatro primeiros, em Java, tratam do modelo de
threads com memória compartilhada; os quatro últimos, em Go, de gorrotinas e
canais.

| Arquivo | Bloco | Assunto |
|---------|-------|---------|
| `01-processo.java` | 2 | Processo que dispara outro; cada um com a sua cópia da memória |
| `02-threads.java` | 2 | Duas threads; a ordem da saída muda entre execuções |
| `03-condicao-de-corrida.java` | 2 | `contador++` em duas threads; o total fica abaixo do esperado |
| `04-com-trava.java` | 2 | O mesmo contador com `synchronized` |
| `05-basico.go` | 3 | Função, `var` e `:=`, `for`, *slice* e `range`, `struct`, dois retornos |
| `06-gorrotinas.go` | 3 | Sequencial × gorrotinas, `sync.WaitGroup`, o `main` que não espera |
| `07-canais.go` | 4 | Canal sem *buffer*, produtor e consumidor com `close` e `range`, `select` com prazo |
| `08-cotacao.go` | 5 | Três fornecedores consultados ao mesmo tempo, o mais barato, prazo |

## Execução

Java, como programa de arquivo único (sem compilação prévia):

```sh
docker run --rm -v "$PWD":/w -w /w eclipse-temurin:21 \
  java 03-condicao-de-corrida.java
```

Go:

```sh
docker run --rm -v "$PWD":/w -w /w golang:1.23 \
  go run 08-cotacao.go
```

Nenhum exemplo usa biblioteca fora da padrão de cada linguagem, nem lê arquivo
ou rede: a latência dos exemplos em Go é simulada com `time.Sleep`.

## Verificação

Os oito foram executados em `eclipse-temurin:21` e `golang:1.23`, terminam com
código 0, e os quatro em Go passam em `go vet` e `gofmt` sem apontamento.

**Saídas que mudam a cada execução — e é essa a demonstração:**

- `02-threads.java` intercala as linhas de `A` e `B` em ordem diferente a cada
  execução. Executar duas ou três vezes seguidas em sala.
- `03-condicao-de-corrida.java` imprime um total **abaixo de 200 000**, e
  diferente a cada execução. Três execuções num contêiner com 14 núcleos deram
  `124129`, `122551` e `117646`. Numa máquina com um só núcleo a perda pode não
  aparecer, porque as threads raramente são interrompidas no meio de
  `contador++`.
- `04-com-trava.java` imprime sempre `200000`.

**Saídas que merecem atenção antes da aula:**

- `01-processo.java` dispara o próprio arquivo como processo filho, o que
  compila o código uma segunda vez; a execução leva alguns segundos. O pai
  imprime `contador = 10` antes e depois; o filho, `contador = 11`.
- `06-gorrotinas.go`, na terceira parte, imprime só o primeiro passo de `C` e
  `D` antes de `fim do main`: o programa termina e as gorrotinas são
  interrompidas. Os tempos das duas primeiras partes são `600ms` (sequencial) e
  `300ms` (gorrotinas).
- `08-cotacao.go` executa a cotação duas vezes. Com prazo de 500 ms, os três
  fornecedores respondem e o tempo total é `250ms` — a latência do mais lento,
  e não a soma, que seria 530 ms. Com prazo de 200 ms, a Loja B, que é a mais
  barata, é descartada, a cotação sai com a Loja C, e o tempo total é `200ms`,
  o próprio prazo.
