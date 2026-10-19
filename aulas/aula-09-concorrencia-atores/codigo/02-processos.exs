# Aula 09, Bloco 3 -- spawn, send e receive
#
# As tres primitivas do modelo de atores em Elixir: criar um processo, enviar
# uma mensagem a ele e receber mensagens da propria caixa de correio. A
# resposta e outra mensagem, e por isso o remetente envia o proprio PID.

# Desliga o relatorio de erro que o runtime imprime quando um processo cai
# (parte 4); a queda e mostrada pela mensagem :DOWN.
Logger.configure(level: :none)

defmodule Dobrador do
  # Espera uma mensagem, responde ao remetente e termina.
  def atender do
    receive do
      {:dobro, do_processo, numero} -> send(do_processo, {:resultado, numero * 2})
    end
  end
end

IO.puts("== 1. Um processo que responde")
dobrador = spawn(fn -> Dobrador.atender() end)
IO.puts("main: #{inspect(self())}, dobrador: #{inspect(dobrador)}")

# send deposita a mensagem na caixa de correio e retorna na hora.
send(dobrador, {:dobro, self(), 21})

# receive bloqueia ate chegar uma mensagem que case com um dos padroes.
receive do
  {:resultado, valor} -> IO.puts("resposta: #{valor}")
end

IO.puts("\n== 2. receive com prazo")
# Ninguem envia :nunca_chega; o after encerra a espera.
receive do
  :nunca_chega -> IO.puts("nao acontece")
after
  200 -> IO.puts("nada chegou em 200 ms")
end

IO.puts("\n== 3. Muitos processos, ordem de chegada")
# Cada processo espera um tempo diferente e avisa o main. As respostas chegam
# na ordem dos tempos, e nao na ordem em que os processos foram criados.
main = self()

for {nome, espera_ms} <- [{"A", 300}, {"B", 100}, {"C", 200}] do
  spawn(fn ->
    Process.sleep(espera_ms)
    send(main, {:pronto, nome, espera_ms})
  end)
end

for _ <- 1..3 do
  receive do
    {:pronto, nome, espera_ms} -> IO.puts("#{nome} terminou (#{espera_ms} ms)")
  end
end

IO.puts("\n== 4. Um processo que cai nao derruba os outros")
# Process.monitor entrega ao observador uma mensagem :DOWN quando o processo
# monitorado termina, com o motivo do termino.
fragil =
  spawn(fn ->
    receive do
      :falhar -> raise "falha simulada"
    end
  end)

referencia = Process.monitor(fragil)
send(fragil, :falhar)

receive do
  {:DOWN, ^referencia, :process, _processo, {motivo, _pilha}} ->
    IO.puts("o processo caiu: #{Exception.message(motivo)}")
end

IO.puts("o main continua vivo")
