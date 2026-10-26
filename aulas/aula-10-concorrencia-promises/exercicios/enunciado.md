# Exercício em sala — Paradigmas de Programação — Concorrência com promises

Arquivo: [`exercicio-health-check.js`](exercicio-health-check.js).

O problema é o mesmo do health check de serviços resolvido com gorrotinas e canais na aula de corrotinas em Go: um painel verifica se quatro serviços respondem, e cada verificação demora a latência do serviço. Aqui a espera é feita com `Promise`, sem thread nem canal: uma única thread e o *event loop* do Node.js.

| Serviço | Latência |
|---------|----------|
| `autenticacao` | 120 ms |
| `pagamentos` | 300 ms |
| `estoque` | 80 ms |
| `notificacoes` | 200 ms |

Execução, em contêiner:

```sh
docker run --rm -v "$PWD":/w -w /w node:22 node exercicio-health-check.js
```

## Parte 1 — A verificação como Promise

Implemente `verificar(servico)`, que devolve uma `Promise` resolvida depois de `servico.latencia` milissegundos com a linha de status `"<nome>: ok (<latencia> ms)"`. Use `setTimeout` dentro do executor da `Promise` e chame `resolve` **dentro** do *callback* do `setTimeout`.

## Parte 2 — Versão sequencial

Implemente `sequencial()`: para cada serviço, na ordem da lista, aguarde `verificar` com `await` e imprima a linha de status.

## Parte 3 — Versão concorrente

Implemente `concorrente()`: chame `verificar` para os quatro serviços **sem** `await`, guarde as quatro promises num vetor e aguarde todas com `Promise.all`. Imprima as linhas na ordem do vetor devolvido.

## Parte 4 — O registro

Preencha o comentário no topo do arquivo, em duas ou três frases:

- por que a versão concorrente fica mais rápida, se o Node.js executa o código JavaScript numa única thread;
- por que, na versão concorrente, as linhas saem na ordem da lista, ao contrário da versão com canais em Go, em que saíam em ordem de latência.

## Entregável e verificação

O arquivo executando, com o registro da Parte 4 no topo.

1. A versão sequencial leva cerca de 700 ms.
2. A versão concorrente leva cerca de 300 ms.
3. Nas duas versões, as linhas saem na ordem da lista: `autenticacao`, `pagamentos`, `estoque`, `notificacoes`.
