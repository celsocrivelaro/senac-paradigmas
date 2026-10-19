# Exercícios em sala — Paradigmas de Programação — Aula 09: Modelo de atores com Elixir

Dois exercícios **independentes**, cada um com seu arquivo em Elixir, completado
a partir de um esqueleto. Nenhum usa biblioteca fora da padrão (Elixir e OTP),
projeto Mix, arquivo ou rede: todo dado está no próprio código.

Execução, em contêiner:

```sh
docker run --rm -v "$PWD":/w -w /w elixir:1.17 elixir exercicio-1-conta.exs
```

---

# Exercício 1 — Conta bancária com primitivas

Arquivo: [`exercicio-1-conta.exs`](exercicio-1-conta.exs). O exercício usa só
`spawn`, `send` e `receive`, sem GenServer.

O esqueleto, executado antes de completado, fica bloqueado: `Conta.loop/1` não
trata nenhuma mensagem, o processo da conta termina logo, e o `main` espera para
sempre a resposta do pedido de saldo. A saída mostra apenas os avisos de
variável não usada (`main` e `saldo`).

## Parte 1 — O processo da conta

Implemente `Conta.loop(saldo)`. O saldo é o argumento da função, e o novo saldo
passa a valer porque a função chama a si mesma com ele ao final de cada
`receive`. Mensagens tratadas:

| Mensagem | Efeito | Resposta enviada a `de` |
|---|---|---|
| `{:depositar, valor, do_processo}` | soma `valor` ao saldo | `:ok` |
| `{:sacar, valor, do_processo}` com saldo suficiente | subtrai `valor` do saldo | `:ok` |
| `{:sacar, valor, do_processo}` com saldo insuficiente | mantém o saldo | `{:erro, :saldo_insuficiente}` |
| `{:saldo, do_processo}` | mantém o saldo | `{:saldo, saldo}` |

O saque insuficiente é um erro de negócio: a conta responde e continua no laço,
sem cair. As funções `saldo` e `sacar` no fim do esqueleto já enviam os pedidos
correspondentes e esperam a resposta.

## Parte 2 — Cem depositantes ao mesmo tempo

No ponto marcado como `PARTE 2`, dispare 100 processos com `spawn`. Cada um
deposita 10 na conta, espera o `:ok` e avisa o `main` com `:depositado`. Em
seguida, o `main` recebe os 100 avisos, e só então o restante do arquivo pede o
saldo.

A espera pelos avisos é obrigatória. A ordem das mensagens é garantida apenas
entre um mesmo par remetente → destinatário: o pedido de saldo vai do `main`
para a conta, e cada depósito, de um depositante para a conta. Sem os avisos,
nada impede que o pedido de saldo chegue à conta antes de algum depósito.

## Parte 3 — O registro

Preencha os dois itens do comentário no topo do arquivo, em duas ou três frases
cada:

1. por que o saldo final não depende da ordem dos depósitos;
2. o que poderia acontecer se o `main` pedisse o saldo sem esperar as
   confirmações dos depositantes.

## Entregável e verificação

O arquivo executando, com o registro da Parte 3 no topo.

1. O programa imprime, em toda execução:

   ```
   saldo: 1000
   sacar 1500: {:erro, :saldo_insuficiente}
   sacar 300: :ok
   saldo: 700
   ```

2. O saldo existe só como argumento de `Conta.loop/1`: nenhum outro processo o
   lê ou escreve, e o código não usa trava. É o `contador++` da aula 08, com
   cem escritores concorrentes e nenhum depósito perdido.

---

# Exercício 2 — Leilão com prazo

Arquivo: [`exercicio-2-leilao.exs`](exercicio-2-leilao.exs).

Um leilão recebe lances durante 300 ms. Um lance é aceito se supera o maior
lance até então; depois do prazo, todo lance é recusado. O esqueleto já traz a
API do cliente (`start_link/1`, `lance/2` e `vencedor/0`), o prazo `@prazo` e a
lista `compradores`, com o nome, o valor do lance e a latência de cada
comprador — o tempo que ele espera antes de dar o lance:

| Comprador | Lance | Latência | | Comprador | Lance | Latência |
|---|---|---|---|---|---|---|
| ana | 150 | 10 ms | | karen | 380 | 190 ms |
| bruno | 180 | 28 ms | | lucas | 350 | 208 ms |
| carla | 120 | 46 ms | | marina | 420 | 226 ms |
| davi | 260 | 64 ms | | nina | 390 | 244 ms |
| elisa | 200 | 82 ms | | otavio | 410 | 262 ms |
| fabio | 310 | 100 ms | | paula | 520 | 340 ms |
| gabi | 290 | 118 ms | | rafael | 300 | 360 ms |
| heitor | 330 | 136 ms | | sofia | 450 | 380 ms |
| iris | 240 | 154 ms | | tiago | 600 | 400 ms |
| joao | 400 | 172 ms | | vera | 280 | 420 ms |

## Parte 1 — O GenServer `Leilao`

Implemente os *callbacks* de `Leilao`:

- **`init/1`**: o estado inicial — nenhum lance e o leilão aberto — e o
  agendamento do encerramento com `Process.send_after(self(), :encerrar, @prazo)`,
  que envia `:encerrar` ao próprio leilão depois de `@prazo` milissegundos.
- **`handle_call/3`** para `{:lance, nome, valor}`: responde `:aceito` e
  guarda o lance se o valor supera o maior lance atual; responde
  `{:recusado, atual}` se não supera; responde `{:recusado, :encerrado}` se o
  leilão já terminou.
- **`handle_call/3`** para `:vencedor`: responde `{nome, valor}` do maior lance
  aceito.
- **`handle_info/2`** para `:encerrar`: marca o leilão como encerrado. A
  mensagem chega como qualquer outra, pela caixa de correio, e por isso é
  tratada em `handle_info/2`, e não em `handle_call/3`.

## Parte 2 — Os vinte compradores

No ponto marcado como `PARTE 2`, dispare um processo por comprador, todos ao
mesmo tempo. Cada um espera a sua latência com `Process.sleep`, chama
`Leilao.lance/2` e envia ao `main` a tupla `{:resposta, nome, valor, resposta}`.
O `main` recebe as 20 respostas e imprime uma linha por resposta, na ordem em
que chegam. O final do esqueleto já consulta e imprime o vencedor.

## Parte 3 — O registro

Preencha os dois itens do comentário no topo do arquivo, em duas ou três frases
cada:

1. por que dois compradores nunca vencem ao mesmo tempo. O lance é uma operação
   de **verificar e depois escrever** (*check-then-act*): comparar com o maior
   lance atual e, se maior, substituí-lo. Justifique a partir do lugar onde a
   comparação e a escrita acontecem;
2. o que aconteceria com a mesma lógica escrita com threads e uma variável
   compartilhada para o maior lance, sem trava.

## Entregável e verificação

O arquivo executando, com o registro da Parte 3 no topo.

1. O programa imprime `vencedor: marina, 420`.
2. Os cinco compradores com latência acima de 300 ms — paula (340 ms), rafael
   (360 ms), sofia (380 ms), tiago (400 ms) e vera (420 ms) — recebem
   `{:recusado, :encerrado}`, inclusive tiago, que deu o maior lance de todos.
3. otavio (410, 262 ms) chega depois de marina e recebe `{:recusado, 420}`.
4. O resultado é o mesmo em toda execução.
