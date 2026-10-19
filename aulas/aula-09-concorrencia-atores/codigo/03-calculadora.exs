# Aula 09, Bloco 3 -- Calculadora e memoria
#
# Dois atores. A calculadora recebe uma operacao, imprime o resultado e o envia
# para a memoria. A memoria guarda o ultimo valor recebido, confirma a quem
# pediu a operacao e devolve o valor quando consultada. Nenhum dos dois tem
# variavel: o estado da memoria e o argumento da funcao, e muda porque a
# funcao chama a si mesma com outro valor.

defmodule Calculadora do
  def loop do
    receive do
      {:soma, memoria, pid_processo, primeiro, segundo} ->
        IO.puts("calculadora: #{primeiro} + #{segundo} = #{primeiro + segundo}")
        send(memoria, {:salvar, primeiro + segundo, pid_processo})
        loop()

      {:subtracao, memoria, pid_processo, primeiro, segundo} ->
        IO.puts("calculadora: #{primeiro} - #{segundo} = #{primeiro - segundo}")
        send(memoria, {:salvar, primeiro - segundo, pid_processo})
        loop()

      {operacao, _memoria, pid_processo, _primeiro, _segundo} ->
        IO.puts("calculadora: nao entendi #{operacao}")
        send(pid_processo, {:nao_entendi, operacao})
        loop()

      mensagem_desconhecida ->
        IO.puts("calculadora: mensagem invalida #{inspect(mensagem_desconhecida)}")
        loop()
    end
  end
end

defmodule Memoria do
  # O valor guardado e o argumento. Chamada de cauda: a pilha nao cresce.
  def loop(valor) do
    receive do
      {:salvar, novo_valor, pid_processo} ->
        send(pid_processo, {:salvo, novo_valor})
        loop(novo_valor)

      {:ler, pid_processo} ->
        send(pid_processo, {:valor, valor})
        loop(valor)

      mensagem_desconhecida ->
        IO.puts("memoria: nao entendi #{inspect(mensagem_desconhecida)}")
        loop(valor)
    end
  end
end

calculadora = spawn(fn -> Calculadora.loop() end)
memoria = spawn(fn -> Memoria.loop(0) end)

# Pede o valor guardado e espera a resposta.
ler = fn ->
  send(memoria, {:ler, self()})

  receive do
    {:valor, valor} -> valor
  end
end

IO.puts("memoria antes: #{ler.()}")

send(calculadora, {:soma, memoria, self(), 7, 5})
send(calculadora, {:subtracao, memoria, self(), 20, 3})
send(calculadora, {:multiplicacao, memoria, self(), 3, 4})

# A ordem so e garantida entre um mesmo par remetente -> destinatario. O :ler
# vai do main para a memoria; o :salvar, da calculadora para a memoria. Sem
# esperar as respostas, o :ler poderia chegar antes de algum :salvar. Por
# isso o main espera uma resposta por operacao enviada.
for _ <- 1..3 do
  receive do
    {:salvo, valor_salvo} -> IO.puts("main: memoria confirmou #{valor_salvo}")
    {:nao_entendi, operacao} -> IO.puts("main: calculadora recusou #{operacao}")
  end
end

IO.puts("memoria depois: #{ler.()}")
