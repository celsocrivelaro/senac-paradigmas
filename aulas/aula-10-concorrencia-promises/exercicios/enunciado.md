# Exercício em sala — Paradigmas de Programação — Concorrência com promises

Arquivo: [`exercicio-checkout.js`](exercicio-checkout.js).

O checkout de uma loja virtual calcula o total de um pedido consultando serviços externos, cada um com latência própria. Uma etapa depende do resultado de outra; as demais são independentes e podem rodar ao mesmo tempo.

O arquivo já traz os serviços simulados, que **não devem ser alterados**. Cada um devolve uma `Promise` e imprime uma linha quando termina:

| Serviço | Latência | Devolve | Falha quando |
|---|---|---|---|
| `buscarCliente(clienteId)` | 100 ms | o cliente, com `cep` | — |
| `calcularFrete(cep)` | 300 ms | o valor do frete | o CEP não é atendido |
| `validarCupom(codigo)` | 150 ms | a fração de desconto (`0` sem cupom) | — |

O total é calculado por `calcularTotal(pedido, frete, desconto)`, também pronta.

| Pedido | Cliente | Subtotal | Cupom | Desfecho |
|---|---|---|---|---|
| 1 | Ana | R$ 160 | `DEZ` (10%) | confirmado, total R$ 164 |
| 2 | Carla | R$ 120 | — | CEP não atendido no frete |

## Parte 1 — Versão sequencial

Implemente `finalizarSequencial(pedido)`: busque o cliente, calcule o frete, valide o cupom e calcule o total, uma etapa depois da outra, com `await` em cada uma. Devolva `{ pedido, status: "confirmado", total }`. Só o pedido 1 passa por esta versão, e não é preciso tratar erro.

## Parte 2 — Versão concorrente

Implemente `finalizarConcorrente(pedido)`. O frete precisa do CEP do cliente, então `buscarCliente` vem primeiro; o frete e o cupom não dependem um do outro e rodam juntos, aguardados com `Promise.all`.

## Parte 3 — CEP não atendido

No pedido 2, `calcularFrete` rejeita a promise, e a rejeição chega ao `await` do `Promise.all`. Trate o erro com `try`/`catch` em `finalizarConcorrente` e devolva `{ pedido, status: "cancelado", motivo }`, com a mensagem do erro como motivo.

## Parte 4 — O registro

Preencha o comentário no topo do arquivo, em duas ou três frases: o serviço mais lento leva 300 ms, mas a versão concorrente leva cerca de 400 ms. Explique a diferença pela dependência entre as etapas.

## Entregável e verificação

O arquivo executando, com o registro da Parte 4 no topo.

1. A versão sequencial do pedido 1 leva cerca de 550 ms, e a concorrente cerca de 400 ms; as duas devolvem `{"pedido":1,"status":"confirmado","total":164}`.
2. O pedido 2 devolve `{"pedido":2,"status":"cancelado","motivo":"CEP 69900-000 nao atendido"}`.

## Desafio (opcional)

Com `Promise.all`, quando o frete rejeita, o resultado do cupom é descartado. Reescreva a Parte 3 com `Promise.allSettled` e imprima o desfecho de cada etapa (`"fulfilled"` ou `"rejected"`) antes de cancelar o pedido.
