# Aula 09 -- Exercicio 1: sala de chat
#
# Registro -- preencher aqui:
#   1. Por que as mensagens chegam a cada pessoa na ordem em que a sala as
#      repassou, e por que o pedido de caixa passa pela sala em vez de ir
#      direto do main para a pessoa:
#
#   2. Por que a privada para quem nao esta na sala e respondida com
#      {:erro, :destinatario_desconhecido}, e nao derruba a sala:
#

# Uma pessoa e um processo escrito com as primitivas. Guarda, em ordem, as
# mensagens que recebeu, e as devolve quando pedidas. Ja esta pronta.
defmodule Pessoa do
  def iniciar(nome), do: spawn(fn -> loop(nome, []) end)

  defp loop(nome, recebidas) do
    receive do
      {:publica, de, texto} ->
        loop(nome, recebidas ++ ["#{de}: #{texto}"])

      {:privada, de, texto} ->
        loop(nome, recebidas ++ ["#{de} (privada): #{texto}"])

      {:caixa, do_processo} ->
        send(do_processo, {:caixa, nome, recebidas})
        loop(nome, recebidas)
    end
  end
end

# A sala e um GenServer: conhece quem esta nela e repassa as mensagens.
defmodule Sala do
  use GenServer

  # --- Interface publica (o que os outros chamam) ---

  def start_link(_), do: GenServer.start_link(__MODULE__, :ok, name: :sala)

  # Responde :ok, ou {:erro, :nome_em_uso} se ja ha alguem com esse nome.
  def entrar(nome, pid_pessoa), do: GenServer.call(:sala, {:entrar, nome, pid_pessoa})

  # Envia a mensagem a todos da sala, menos a quem a escreveu. Responde :ok.
  def publica(de, texto), do: GenServer.call(:sala, {:publica, de, texto})

  # Envia a mensagem so a uma pessoa. Responde :ok, ou
  # {:erro, :destinatario_desconhecido} se ela nao esta na sala.
  def privada(de, para, texto), do: GenServer.call(:sala, {:privada, de, para, texto})

  # Devolve a lista de mensagens recebidas pela pessoa. O pedido passa pela
  # sala, que o repassa a pessoa; a pessoa responde direto a quem pediu.
  def caixa(nome) do
    :ok = GenServer.call(:sala, {:caixa, nome, self()})

    receive do
      {:caixa, ^nome, recebidas} -> recebidas
    end
  end

  # --- Estado (o dado que a sala guarda) ---
  #
  # A COMPLETAR -- quem esta na sala: um map do nome da pessoa para o PID do
  # processo dela. Comeca vazio, em init/1.

  # --- Callbacks (o que o GenServer chama) ---

  # A COMPLETAR, nesta ordem, logo abaixo:
  #
  # init/1: devolve o estado inicial.
  #
  # handle_call/3 para {:entrar, nome, pid_pessoa}, {:publica, de, texto} e
  #   {:privada, de, para, texto}. A sala envia as mensagens as pessoas com
  #   send, como {:publica, de, texto} e {:privada, de, texto}.

  # Ja pronto, como modelo: repassa o pedido de caixa a pessoa.
  def handle_call({:caixa, nome, quem_pediu}, _do_processo, pessoas) do
    send(pessoas[nome], {:caixa, quem_pediu})
    {:reply, :ok, pessoas}
  end
end

# Quantas pessoas se quiser: basta acrescentar nomes a lista.
nomes = ["ana", "bruno", "carla", "davi"]

{:ok, _sala} = Sala.start_link(:ok)

for nome <- nomes do
  :ok = Sala.entrar(nome, Pessoa.iniciar(nome))
end

IO.puts("ana entra de novo: #{inspect(Sala.entrar("ana", Pessoa.iniciar("ana")))}")

Sala.publica("ana", "oi, pessoal")
Sala.privada("bruno", "carla", "almoco hoje?")
IO.puts("privada para zeca: #{inspect(Sala.privada("carla", "zeca", "oi"))}")
Sala.publica("davi", "cheguei")

for nome <- nomes do
  IO.puts("#{nome} recebeu: #{inspect(Sala.caixa(nome))}")
end
