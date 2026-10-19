# Aula 09, Bloco 4 -- GenServer: estado e callbacks
#
# Um contador como GenServer. O arquivo 04 mostrou a parte generica, escrita
# pelo OTP; este separa as tres coisas que o modulo escreve:
#
#   - a interface publica: funcoes que os outros processos chamam. Executam no
#     processo de quem chama e so enviam a mensagem, com GenServer.cast ou
#     GenServer.call;
#   - o estado: o dado que o processo guarda entre uma mensagem e outra;
#   - os callbacks: o codigo que o GenServer chama, dentro do processo do
#     contador, uma mensagem por vez.

defmodule Contador do
  use GenServer

  # --- Interface publica (o que os outros chamam) ---
  def start_link(valor_inicial),
    do: GenServer.start_link(__MODULE__, valor_inicial, name: :contador)

  def incrementar, do: GenServer.cast(:contador, :incrementar)
  def valor, do: GenServer.call(:contador, :valor)

  # --- Estado (o dado que o processo guarda) ---
  #
  # O estado do contador e um numero: o valor atual. Ele nao fica em variavel
  # do modulo nem em atributo; existe so dentro do processo, e quem esta fora
  # so o conhece por mensagem. Faz o papel do argumento valor de loop/1 da
  # memoria do arquivo 03, agora guardado pelo OTP.
  #
  # O OTP entrega o estado atual como ultimo argumento de cada callback e
  # guarda, como novo estado, o ultimo elemento da tupla que o callback
  # devolve:
  #
  #   init/1         cria o estado       -> {:ok, estado}
  #   handle_call/3  le e substitui      -> {:reply, resposta, novo_estado}
  #   handle_cast/2  substitui           -> {:noreply, novo_estado}

  # --- Callbacks (o que o GenServer chama) ---
  #
  # Executados dentro do processo do contador, um por vez. Nao guardam nada
  # entre chamadas: recebem o estado, devolvem o novo estado, e o que nao for
  # devolvido se perde.

  # Cria o estado inicial.
  @impl true
  def init(valor_inicial), do: {:ok, valor_inicial}

  # Devolve o estado mais um como novo estado.
  @impl true
  def handle_cast(:incrementar, valor), do: {:noreply, valor + 1}

  # Responde com o estado e o mantem igual.
  @impl true
  def handle_call(:valor, _pid_processo, valor), do: {:reply, valor, valor}
end

# start_link chama init(0) dentro do novo processo: o estado inicial e 0.
{:ok, _pid_contador} = Contador.start_link(0)

# Cada incrementar e um cast: o main envia e segue. No processo do contador,
# handle_cast(:incrementar, 0) devolve 1, depois handle_cast(:incrementar, 1)
# devolve 2, e assim por diante.
Contador.incrementar()
Contador.incrementar()
Contador.incrementar()

# valor e um call: o main espera a resposta. Os tres cast e o call vao do
# mesmo processo para o mesmo destino, e chegam na ordem em que foram enviados.
IO.puts("valor: #{Contador.valor()}")
