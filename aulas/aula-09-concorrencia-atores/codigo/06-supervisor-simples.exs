# Aula 09, Bloco 4 -- Supervisor simples
#
# O contador do arquivo 05, aqui escrito so com as primitivas (spawn_link,
# receive e registro por nome), sem GenServer, e iniciado por um Supervisor. Sem
# abstracao entre o Supervisor e o laco receive, fica a vista o que o
# Supervisor exige do filho: uma funcao start_link que cria o processo ligado
# a ele e devolve {:ok, pid}. O contador cai; o Supervisor o reinicia.
# O nome volta a responder com PID novo, e o valor voltou ao inicial: o
# reinicio devolve um processo correto, nao o estado que o anterior tinha.

# Desliga o relatorio de queda do OTP; a queda e mostrada por uma linha propria.
Logger.configure(level: :none)

defmodule Contador do
  # O Supervisor chama esta funcao para iniciar o processo, e de novo para
  # reinicia-lo. Duas exigencias: criar o processo com spawn_link, que liga o
  # processo ao Supervisor e o avisa da queda, e devolver {:ok, pid}.
  def start_link(valor_inicial) do
    pid_contador = spawn_link(fn -> loop(valor_inicial) end)
    Process.register(pid_contador, :contador)
    {:ok, pid_contador}
  end

  defp loop(valor) do
    receive do
      :incrementar ->
        loop(valor + 1)

      {:valor, pid_processo} ->
        send(pid_processo, {:valor, valor})
        loop(valor)

      :explodir ->
        raise "o contador explodiu"
    end
  end

  # Funcoes de uso do contador: enviam a mensagem ao nome :contador, sem
  # conhecer o PID.
  def incrementar, do: send(:contador, :incrementar)
  def explodir, do: send(:contador, :explodir)

  def valor do
    send(:contador, {:valor, self()})

    receive do
      {:valor, valor} -> valor
    end
  end
end

# 1. A lista de filhos diz ao Supervisor quem ele vigia e como inicia-lo.
#    Cada filho e descrito por um map (a especificacao do filho, child spec):
#
#    id:    nome do filho dentro do Supervisor. Serve para o Supervisor
#           distinguir um filho do outro; nao e o PID nem o nome registrado
#           (:contador). Aqui o proprio modulo, Contador, faz esse papel.
#
#    start: como criar o processo, na forma {Modulo, :funcao, [argumentos]}.
#           O Supervisor nao chama a funcao na hora em que a lista e escrita:
#           guarda a receita e a executa ao iniciar e a cada reinicio.
#
#      Contador     -- o modulo onde a funcao esta.
#      :start_link  -- o nome da funcao, como atomo. "start_link" e a
#                      convencao do OTP: inicia (start) o processo ligado
#                      (link) ao Supervisor, para que a queda dele chegue ao
#                      Supervisor como aviso. A funcao precisa devolver
#                      {:ok, pid}.
#      [0]          -- a lista de argumentos passados a funcao. A chamada
#                      fica Contador.start_link(0): o 0 e o valor_inicial do
#                      contador. Por ser a receita, e o mesmo 0 que o
#                      Supervisor usa no reinicio, e por isso o contador
#                      reiniciado volta a zero. Uma funcao de dois argumentos
#                      levaria uma lista de dois elementos, como [0, :outro].
filhos = [
  %{id: Contador, start: {Contador, :start_link, [0]}}
]

# 2. :one_for_one: quando um filho cai, so ele e reiniciado.
{:ok, _supervisor} = Supervisor.start_link(filhos, strategy: :one_for_one)

# 3. O contador em uso normal.
Contador.incrementar()
Contador.incrementar()
Contador.incrementar()
IO.puts("valor antes da falha: #{Contador.valor()}")
IO.puts("PID antes da falha:   #{inspect(Process.whereis(:contador))}")

# 4. A falha.
IO.puts("\n== O contador recebe :explodir e cai")
Contador.explodir()

# O Supervisor reinicia o contador logo depois da queda; a espera curta e so
# para o novo processo ja estar registrado com o nome.
Process.sleep(100)

# 5. Depois do reinicio: processo novo, mesmo nome, valor inicial.
IO.puts("\nPID depois da falha:   #{inspect(Process.whereis(:contador))}")
IO.puts("valor depois da falha: #{Contador.valor()}")

# 6. O contador continua funcionando.
Contador.incrementar()
IO.puts("valor apos incrementar: #{Contador.valor()}")
