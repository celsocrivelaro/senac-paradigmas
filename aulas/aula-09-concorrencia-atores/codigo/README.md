# Aula 09 — código de exemplo

Sete arquivos em Elixir, um por caso. O primeiro apresenta a linguagem; os dois
seguintes, as primitivas do modelo de atores; o quarto, um Supervisor sobre um
processo escrito só com as primitivas; os três últimos, o OTP completo —
GenServer, Supervisor e o processador de pagamentos que reúne os dois.

| Arquivo | Bloco | Assunto |
|---------|-------|---------|
| `01-basico.exs` | 2 | Átomo, tupla, *pattern matching*, `case`, módulo, cláusulas e guarda, recursão sobre lista, `\|>`, *map* |
| `02-processos.exs` | 3 | `spawn`, `send`, `receive`, `self()`, resposta por PID, `receive ... after`, ordem de chegada, `Process.monitor` |
| `03-calculadora.exs` | 3 | Calculadora e memória como dois processos; estado por recursão; mensagem desconhecida |
| `04-supervisor-simples.exs` | 4 | Supervisor `:one_for_one` sobre um contador com `spawn_link` e `receive`; o contador explode e é reiniciado com PID novo e valor inicial |
| `05-genserver.exs` | 4 | A memória como GenServer: `init`, `handle_call`, `handle_cast`, registro por nome |
| `06-supervisor.exs` | 4 | Supervisor `:one_for_one`; mensagem malformada derruba a memória, que é reiniciada com o valor inicial |
| `07-pagamentos.exs` | 5 | Cinco pagamentos em processos supervisionados; gateway simulado; falha transitória reiniciada |

## Verificação

Os sete foram executados em `elixir:1.17` (Elixir 1.17.3, Erlang/OTP 27),
terminam com código 0 e passam em `mix format --check-formatted` sem
apontamento.

**Saídas que merecem atenção antes da aula:**

- `02-processos.exs`, na parte 3, imprime os processos na ordem `B`, `C`, `A`:
  a ordem das latências (100, 200 e 300 ms), e não a de criação.
- `03-calculadora.exs`: a intercalação entre as linhas da calculadora e as do
  `main` pode variar entre execuções, porque são dois processos imprimindo; o
  valor final é sempre `memoria depois: 17`.
- `04-supervisor-simples.exs`: o valor vai de `3` para `0`, e o PID muda (`#PID<0.103.0>` → `#PID<0.104.0>` numa execução).
- `06-supervisor.exs`: o PID da memória muda depois do reinício
  (`PID antes: #PID<0.103.0>, PID depois: #PID<0.104.0>` numa execução), e o
  valor guardado volta de `42` para `0`.
- `07-pagamentos.exs` imprime, com variação de alguns milissegundos entre
  execuções:

  ```
  == 5 pagamentos processados ao mesmo tempo
    pg-3  recusado: saldo insuficiente  (86 ms)
    pg-1  aprovado  R$ 120.00  (105 ms)
    pg-5  aprovado  R$ 310.00  (123 ms)
    [log] pg-2 caiu na tentativa 1: timeout do gateway -> supervisor reinicia
    pg-4  aprovado  R$ 45.00  (204 ms)
    pg-2  aprovado  R$ 89.90  (317 ms, 2a tentativa)
  tempo total: 317 ms (em sequencia seriam 800 ms)
  ```

  A ordem das linhas e os desfechos não variam. O tempo total fica perto de
  300 ms: a pg-2 soma a tentativa que falhou (150 ms) e a nova (150 ms), e
  termina depois da pg-4 (200 ms).
