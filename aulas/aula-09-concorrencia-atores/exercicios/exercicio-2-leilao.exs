# Aula 09 -- Exercicio 2: leilao com prazo
#
# Registro -- preencher aqui:
#   1. Por que dois compradores nunca vencem ao mesmo tempo:
#
#   2. O que aconteceria com a mesma logica escrita com threads e uma variavel
#      compartilhada para o maior lance:
#

defmodule Leilao do
  use GenServer

  @prazo 300

  def start_link(_), do: GenServer.start_link(__MODULE__, :ok, name: __MODULE__)

  # Respostas possiveis:
  #   :aceito                  -- o valor supera o maior lance atual
  #   {:recusado, atual}       -- o valor nao supera o maior lance atual
  #   {:recusado, :encerrado}  -- o leilao ja terminou
  def lance(nome, valor), do: GenServer.call(__MODULE__, {:lance, nome, valor})

  # Devolve {nome, valor} do maior lance aceito.
  def vencedor, do: GenServer.call(__MODULE__, :vencedor)

  # PARTE 1 -- o leilao.
  #
  # init/1: estado inicial (sem lance, aberto) e agendamento do encerramento:
  #   Process.send_after(self(), :encerrar, @prazo)
  #
  # handle_call/3: trata {:lance, nome, valor} e :vencedor.
  #
  # handle_info/2: trata :encerrar, que chega como mensagem comum.

  # a completar
end

# {nome, valor do lance, latencia em ms antes de dar o lance}
compradores = [
  {"ana", 150, 10},
  {"bruno", 180, 28},
  {"carla", 120, 46},
  {"davi", 260, 64},
  {"elisa", 200, 82},
  {"fabio", 310, 100},
  {"gabi", 290, 118},
  {"heitor", 330, 136},
  {"iris", 240, 154},
  {"joao", 400, 172},
  {"karen", 380, 190},
  {"lucas", 350, 208},
  {"marina", 420, 226},
  {"nina", 390, 244},
  {"otavio", 410, 262},
  {"paula", 520, 340},
  {"rafael", 300, 360},
  {"sofia", 450, 380},
  {"tiago", 600, 400},
  {"vera", 280, 420}
]

{:ok, _} = Leilao.start_link(:ok)
main = self()

# PARTE 2 -- dispare um processo por comprador, todos ao mesmo tempo. Cada um
# espera a sua latencia (Process.sleep), da o lance e envia ao main
# {:resposta, nome, valor, resposta}. O main recebe as 20 respostas e imprime
# uma linha por resposta, na ordem em que chegam.

# a completar

{nome, valor} = Leilao.vencedor()
IO.puts("vencedor: #{nome}, #{valor}")
