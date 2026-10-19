# Aula 09 -- Exercicio 1: conta bancaria com primitivas
#
# Registro -- preencher aqui:
#   1. Por que o saldo final nao depende da ordem dos depositos:
#
#   2. O que poderia acontecer se o main pedisse o saldo sem esperar as
#      confirmacoes dos depositantes:
#

defmodule Conta do
  # PARTE 1 -- o processo da conta. O saldo e o argumento de loop/1.
  # Mensagens tratadas:
  #   {:depositar, valor, do_processo} -> soma ao saldo e responde :ok a do_processo
  #   {:sacar, valor, do_processo}     -> responde :ok e subtrai, ou responde
  #                              {:erro, :saldo_insuficiente} e mantem o saldo
  #   {:saldo, do_processo}            -> responde {:saldo, saldo} a do_processo
  def loop(saldo) do
    # a completar
  end
end

conta = spawn(fn -> Conta.loop(0) end)
main = self()

# PARTE 2 -- dispare 100 processos. Cada um deposita 10 na conta, espera o :ok
# e avisa o main com :depositado. Depois, receba os 100 avisos.

# a completar

# Pede o saldo e espera a resposta.
saldo = fn ->
  send(conta, {:saldo, self()})

  receive do
    {:saldo, saldo_atual} -> saldo_atual
  end
end

# Envia um saque e espera a resposta.
sacar = fn valor ->
  send(conta, {:sacar, valor, self()})

  receive do
    resposta -> resposta
  end
end

IO.puts("saldo: #{saldo.()}")

# Saques, ja escritos: um acima do saldo e um dentro dele.
IO.puts("sacar 1500: #{inspect(sacar.(1500))}")
IO.puts("sacar 300: #{inspect(sacar.(300))}")
IO.puts("saldo: #{saldo.()}")
