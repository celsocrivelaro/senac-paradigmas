# Aula 09 -- Exercicio: leilao com prazo
#
# Registro -- preencher aqui:
#   1. Por que dois compradores nunca vencem ao mesmo tempo:
#
#   2. O que aconteceria com a mesma logica escrita com threads e uma variavel
#      compartilhada para o maior lance, sem trava:
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

  # --- Estado: o dado que o leilao guarda entre uma mensagem e outra ---
  #
  # A COMPLETAR -- escolher a forma do estado. Ele precisa guardar o maior
  # lance aceito ate agora (nome e valor) e se o leilao esta aberto ou
  # encerrado. O estado e criado em init/1 e chega a cada callback como ultimo
  # argumento; o novo estado e o ultimo elemento da tupla devolvida.

  # --- Callbacks: o codigo que trata cada mensagem ---
  #
  # A COMPLETAR.
  #
  # init/1: devolve o estado inicial (nenhum lance, leilao aberto) e agenda o
  #   encerramento:
  #     Process.send_after(self(), :encerrar, @prazo)
  #
  # handle_call/3: trata {:lance, nome, valor} e :vencedor.
  #
  # handle_info/2: trata :encerrar, que chega como mensagem comum.
end

# {nome, valor do lance, latencia em ms antes de dar o lance}
compradores = [
  {"ana", 150, 20},
  {"bruno", 120, 50},
  {"carla", 260, 90},
  {"davi", 200, 130},
  {"elisa", 340, 170},
  {"fabio", 300, 210},
  {"gabi", 500, 350},
  {"heitor", 280, 400}
]

{:ok, _leilao} = Leilao.start_link(:ok)
main = self()

# Um processo por comprador, todos ao mesmo tempo. Cada um espera a sua
# latencia, da o lance e envia a resposta ao main.
for {nome, valor, latencia} <- compradores do
  spawn(fn ->
    Process.sleep(latencia)
    resposta = Leilao.lance(nome, valor)
    send(main, {:resposta, nome, valor, resposta})
  end)
end

# O main imprime as respostas na ordem em que chegam.
for _ <- compradores do
  receive do
    {:resposta, nome, valor, resposta} ->
      IO.puts("#{nome} (#{valor}): #{inspect(resposta)}")
  end
end

{nome, valor} = Leilao.vencedor()
IO.puts("vencedor: #{nome}, #{valor}")
