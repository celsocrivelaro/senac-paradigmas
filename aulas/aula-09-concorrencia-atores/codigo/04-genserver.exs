# Aula 09, Bloco 4 -- GenServer
#
# GenServer (generic server) e o comportamento do OTP que implementa, uma vez
# so, o ator com estado do arquivo 03: um processo que espera uma mensagem no
# receive, trata-a, e chama a si mesmo com o novo estado. Esse laco e igual em
# todo servidor; o que muda de um para outro e apenas o que fazer com cada
# mensagem. O GenServer separa as duas partes:
#
#   - a parte generica, escrita pelo OTP: o laco receive, a recursao que guarda
#     o estado, o envio do PID de quem chamou e a devolucao da resposta, o
#     prazo de espera do chamador e o aviso de queda ao Supervisor;
#   - a parte especifica, escrita pelo modulo: funcoes de tratamento
#     (callbacks), cada uma recebe a mensagem e o estado atual e devolve o
#     novo estado.
#
# O processo continua sendo um ator: estado privado, caixa de correio e uma
# mensagem tratada por vez. Muda apenas quem escreve o laco.
#
# Duas formas de enviar uma mensagem ao GenServer:
#
#   - GenServer.call: sincrona. O chamador bloqueia ate a resposta, tratada
#     em handle_call/3, que devolve {:reply, resposta, novo_estado}.
#   - GenServer.cast: assincrona. O chamador segue sem esperar, e a mensagem
#     e tratada em handle_cast/2, que devolve {:noreply, novo_estado}.
#
# O estado inicial vem de init/1. Mensagens que nao chegam por call nem por
# cast (um send comum, um Process.send_after) vao para handle_info/2.
#
# Neste arquivo, a memoria do arquivo 03 e reescrita como GenServer: o laco
# receive, a chamada recursiva e o envio do PID para a resposta desaparecem do
# codigo; o modulo escreve so o tratamento de cada mensagem.

defmodule Memoria do
  # use GenServer declara que o modulo segue o comportamento GenServer: traz a
  # parte generica e define as funcoes de tratamento que o modulo sobrescreve.
  use GenServer

  # --- API do cliente: funcoes chamadas por outros processos ---

  # name: __MODULE__ registra o processo com o nome Memoria; quem o usa nao
  # precisa conhecer o PID.
  def start_link(inicial) do
    GenServer.start_link(__MODULE__, inicial, name: __MODULE__)
  end

  # cast: assincrono. Envia e retorna :ok na hora, sem esperar o tratamento.
  def salvar(valor), do: GenServer.cast(__MODULE__, {:salvar, valor})

  # call: sincrono. Bloqueia ate o servidor responder.
  def ler, do: GenServer.call(__MODULE__, :ler)

  # --- Callbacks: executados dentro do processo da memoria ---

  # Estado inicial. Corresponde a Memoria.loop(0) do arquivo 03.
  @impl true
  def init(inicial), do: {:ok, inicial}

  # Corresponde a clausula {:salvar, novo_valor} -> loop(novo_valor).
  @impl true
  def handle_cast({:salvar, novo_valor}, _estado), do: {:noreply, novo_valor}

  # Corresponde a {:ler, do_processo} -> send(do_processo, {:valor, valor}); loop(valor).
  # {:reply, resposta, novo_estado}: o OTP envia a resposta a quem chamou.
  @impl true
  def handle_call(:ler, _do_processo, estado), do: {:reply, estado, estado}
end

{:ok, pid_memoria} = Memoria.start_link(0)
IO.puts("memoria iniciada: #{inspect(pid_memoria)}")
IO.puts("antes: #{Memoria.ler()}")

Memoria.salvar(12)
Memoria.salvar(42)

# Aqui nao ha corrida com o cast: os tres pedidos vao do mesmo processo (main)
# para o mesmo destino (Memoria), e a ordem entre um mesmo par e preservada.
IO.puts("depois: #{Memoria.ler()}")
