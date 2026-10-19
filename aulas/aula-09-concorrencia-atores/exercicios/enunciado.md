# Exercício em sala — Paradigmas de Programação — Aula 09: Modelo de atores com Elixir

# Leilão com prazo

Arquivo: [`exercicio-leilao.exs`](exercicio-leilao.exs). Nenhuma biblioteca fora
da padrão (Elixir e OTP), projeto Mix, arquivo ou rede: todo dado está no
próprio código.

Execução, em contêiner:

```sh
docker run --rm -v "$PWD":/w -w /w elixir:1.17 elixir exercicio-leilao.exs
```

Um leilão recebe lances durante 300 ms. Um lance é aceito se supera o maior
lance até então; depois do prazo, todo lance é recusado. O esqueleto já traz a
API do cliente (`start_link/1`, `lance/2` e `vencedor/0`), o prazo `@prazo` e o
programa principal: oito compradores, um processo cada, disparados ao mesmo
tempo. Cada comprador espera a sua latência, dá o lance e envia a resposta ao
`main`, que a imprime.

| Comprador | Lance | Latência |
|---|---|---|
| ana | 150 | 20 ms |
| bruno | 120 | 50 ms |
| carla | 260 | 90 ms |
| davi | 200 | 130 ms |
| elisa | 340 | 170 ms |
| fabio | 300 | 210 ms |
| gabi | 500 | 350 ms |
| heitor | 280 | 400 ms |

O esqueleto, executado antes de completado, cai no primeiro lance: `Leilao`
ainda não tem `handle_call/3`.

## O GenServer `Leilao`

Implemente os *callbacks* de `Leilao`, no ponto marcado como `A COMPLETAR`:

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

## O registro

Preencha os dois itens do comentário no topo do arquivo, em duas ou três frases
cada:

1. por que dois compradores nunca vencem ao mesmo tempo. O lance é uma operação
   de **verificar e depois escrever** (*check-then-act*): comparar com o maior
   lance atual e, se maior, substituí-lo. Justifique a partir do lugar onde a
   comparação e a escrita acontecem;
2. o que aconteceria com a mesma lógica escrita com threads e uma variável
   compartilhada para o maior lance, sem trava.

## Entregável e verificação

O arquivo executando, com o registro no topo. Em toda execução, o programa
imprime:

```
ana (150): :aceito
bruno (120): {:recusado, 150}
carla (260): :aceito
davi (200): {:recusado, 260}
elisa (340): :aceito
fabio (300): {:recusado, 340}
gabi (500): {:recusado, :encerrado}
heitor (280): {:recusado, :encerrado}
vencedor: elisa, 340
```

gabi deu o maior lance de todos, mas depois dos 300 ms: o encerramento chegou
antes à caixa de correio do leilão, e o lance foi recusado.
