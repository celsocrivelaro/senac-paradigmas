# Aula 09, Bloco 5 -- Processador de pagamentos
#
# Cinco pagamentos chegam juntos e cada um precisa ser autorizado por um
# gateway externo, que demora (simulado com Process.sleep) e as vezes falha.
# Cada pagamento e um processo; um Supervisor reinicia o que cair por falha
# transitoria, sem afetar os demais. Recusa por saldo e resposta, nao falha.

# Desliga o relatorio de queda do OTP; o gateway imprime uma linha propria.
Logger.configure(level: :none)

defmodule Gateway do
  use GenServer

  # Desfecho fixo de cada pagamento, para a saida ser a mesma em toda execucao.
  # pg-2 falha so na primeira tentativa: e a falha transitoria.
  @desfechos %{
    "pg-1" => :aprovado,
    "pg-2" => {:falha_na_tentativa, 1},
    "pg-3" => {:recusado, "saldo insuficiente"},
    "pg-4" => :aprovado,
    "pg-5" => :aprovado
  }

  def start_link(_), do: GenServer.start_link(__MODULE__, %{}, name: __MODULE__)

  # Simula a chamada ao servico externo. A espera acontece no processo de quem
  # chama, e nao dentro do Gateway: um ator trata uma mensagem por vez, e se o
  # sleep estivesse no handle_call os cinco pagamentos seriam atendidos em fila.
  def autorizar(pagamento) do
    tentativa = GenServer.call(__MODULE__, {:tentativa, pagamento.id})
    Process.sleep(pagamento.latencia)

    case @desfechos[pagamento.id] do
      {:falha_na_tentativa, ^tentativa} -> {:falha, "timeout do gateway", tentativa}
      {:falha_na_tentativa, _} -> {:aprovado, tentativa}
      {:recusado, motivo} -> {:recusado, motivo, tentativa}
      :aprovado -> {:aprovado, tentativa}
    end
  end

  # O estado do Gateway e o numero de tentativas de cada pagamento. Ele fica
  # aqui, e nao no processo do pagamento, porque o pagamento reiniciado
  # comeca com estado novo e nao lembraria que ja tentou.
  @impl true
  def init(tentativas), do: {:ok, tentativas}

  @impl true
  def handle_call({:tentativa, id}, _do_processo, tentativas) do
    tentativa = Map.get(tentativas, id, 0) + 1
    {:reply, tentativa, Map.put(tentativas, id, tentativa)}
  end
end

defmodule Pagamento do
  # :transient -- o Supervisor reinicia o processo so se ele terminar de forma
  # anormal. Pagamento que termina com :normal fica terminado.
  use GenServer, restart: :transient

  def start_link({pagamento, main}), do: GenServer.start_link(__MODULE__, {pagamento, main})

  # init retorna logo; o trabalho fica no handle_continue, que roda em seguida,
  # dentro do proprio processo. Assim o Supervisor nao espera a autorizacao
  # para iniciar o proximo filho.
  @impl true
  def init(estado), do: {:ok, estado, {:continue, :processar}}

  @impl true
  def handle_continue(:processar, {pagamento, main} = estado) do
    case Gateway.autorizar(pagamento) do
      {:aprovado, tentativa} ->
        send(main, {:resultado, pagamento, :aprovado, tentativa})
        {:stop, :normal, estado}

      {:recusado, motivo, tentativa} ->
        send(main, {:resultado, pagamento, {:recusado, motivo}, tentativa})
        {:stop, :normal, estado}

      # Nenhum try/rescue: a falha transitoria derruba o processo, e quem
      # decide o que fazer e o Supervisor.
      {:falha, motivo, tentativa} ->
        IO.puts(
          "  [log] #{pagamento.id} caiu na tentativa #{tentativa}: #{motivo} -> supervisor reinicia"
        )

        raise motivo
    end
  end
end

pagamentos = [
  %{id: "pg-1", valor: 120.00, latencia: 100},
  %{id: "pg-2", valor: 89.90, latencia: 150},
  %{id: "pg-3", valor: 1500.00, latencia: 80},
  %{id: "pg-4", valor: 45.00, latencia: 200},
  %{id: "pg-5", valor: 310.00, latencia: 120}
]

main = self()
inicio = System.monotonic_time(:millisecond)

# Um filho por pagamento; o id do filho precisa ser unico no Supervisor.
filhos =
  [Gateway] ++
    Enum.map(pagamentos, fn pagamento ->
      Supervisor.child_spec({Pagamento, {pagamento, main}}, id: pagamento.id)
    end)

IO.puts("== 5 pagamentos processados ao mesmo tempo")
{:ok, _supervisor} = Supervisor.start_link(filhos, strategy: :one_for_one)

decorrido = fn -> System.monotonic_time(:millisecond) - inicio end
formatar_reais = fn quantia -> :erlang.float_to_binary(quantia / 1, decimals: 2) end

for _ <- pagamentos do
  receive do
    {:resultado, pagamento, :aprovado, tentativa} ->
      nota = if tentativa > 1, do: ", #{tentativa}a tentativa", else: ""

      IO.puts(
        "  #{pagamento.id}  aprovado  R$ #{formatar_reais.(pagamento.valor)}  (#{decorrido.()} ms#{nota})"
      )

    {:resultado, pagamento, {:recusado, motivo}, _tentativa} ->
      IO.puts("  #{pagamento.id}  recusado: #{motivo}  (#{decorrido.()} ms)")
  after
    1000 -> IO.puts("  prazo esgotado sem resposta")
  end
end

# Em sequencia: as cinco latencias mais a nova tentativa da pg-2.
latencias = pagamentos |> Enum.map(& &1.latencia) |> Enum.sum()
nova_tentativa = Enum.find(pagamentos, &(&1.id == "pg-2")).latencia
IO.puts("tempo total: #{decorrido.()} ms (em sequencia seriam #{latencias + nova_tentativa} ms)")
