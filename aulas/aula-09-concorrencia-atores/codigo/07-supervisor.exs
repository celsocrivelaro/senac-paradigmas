# Aula 09, Bloco 4 -- Supervisor
#
# A memoria do arquivo 04 iniciada por um Supervisor. Uma mensagem malformada
# derruba a memoria; o Supervisor a reinicia. O nome volta a responder, mas o
# valor guardado voltou ao inicial: o reinicio devolve um processo correto, nao
# o estado que o processo anterior tinha.

# Desliga o relatorio de queda do OTP, que ocupa dezenas de linhas; a queda
# e mostrada pela mensagem :DOWN abaixo.
Logger.configure(level: :none)

defmodule Memoria do
  use GenServer

  def start_link(inicial) do
    GenServer.start_link(__MODULE__, inicial, name: __MODULE__)
  end

  def salvar(valor), do: GenServer.cast(__MODULE__, {:salvar, valor})
  def ler, do: GenServer.call(__MODULE__, :ler)

  @impl true
  def init(inicial), do: {:ok, inicial}

  # A guarda aceita so numero. Um :salvar com texto nao casa com nenhuma
  # clausula, e o processo cai com FunctionClauseError. Nenhum try/rescue:
  # a memoria nao sabe o que fazer com o dado errado, entao nao tenta.
  @impl true
  def handle_cast({:salvar, novo_valor}, _estado) when is_number(novo_valor),
    do: {:noreply, novo_valor}

  @impl true
  def handle_call(:ler, _do_processo, estado), do: {:reply, estado, estado}
end

# O Supervisor inicia os filhos da lista e os vigia. :one_for_one: quando um
# filho cai, so ele e reiniciado.
filhos = [{Memoria, 0}]
{:ok, _supervisor} = Supervisor.start_link(filhos, strategy: :one_for_one)

Memoria.salvar(42)
IO.puts("valor guardado: #{Memoria.ler()}")

IO.puts("\n== Mensagem malformada")
antes = Process.whereis(Memoria)
# Monitora antes de enviar, para receber o :DOWN quando o processo cair.
referencia = Process.monitor(antes)
Memoria.salvar("quarenta e dois")

receive do
  {:DOWN, ^referencia, :process, _processo, {motivo, _pilha}} ->
    IO.puts("memoria caiu: #{inspect(motivo)}")
end

# O Supervisor reinicia a memoria logo depois da queda; a espera curta e so
# para o novo processo ja estar registrado com o nome.
Process.sleep(50)
depois = Process.whereis(Memoria)

IO.puts("\n== Depois do reinicio")
IO.puts("PID antes: #{inspect(antes)}, PID depois: #{inspect(depois)}")
IO.puts("valor guardado: #{Memoria.ler()}")
