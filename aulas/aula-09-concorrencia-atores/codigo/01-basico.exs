# Aula 09, Bloco 2 -- O basico de Elixir
#
# O suficiente para ler os arquivos seguintes: atomo, tupla, pattern matching,
# case, modulo, funcao com varias clausulas e guarda, recursao sobre lista,
# o operador |> e map. Uma ideia por funcao.

defmodule Basico do
  # Atomo: constante cujo valor e o proprio nome. Muito usado como rotulo.
  def atomos do
    IO.inspect(:ok)
    IO.inspect(:erro)
    IO.inspect(:ok == :ok)
  end

  # Tupla: sequencia fixa de valores. O padrao {:ok, valor} / {:erro, motivo}
  # e a forma corrente de devolver sucesso ou falha.
  def dividir(_dividendo, 0), do: {:erro, :divisao_por_zero}
  def dividir(dividendo, divisor), do: {:ok, dividendo / divisor}

  # Pattern matching: = nao e atribuicao, e casamento. O lado esquerdo e um
  # padrao; as variaveis dele recebem as partes correspondentes do lado direito.
  def casamento do
    {:ok, resultado} = dividir(10, 4)
    IO.puts("10 / 4 = #{resultado}")

    [primeiro | resto] = [1, 2, 3]
    IO.puts("primeiro: #{primeiro}, resto: #{inspect(resto)}")
  end

  # case escolhe o primeiro padrao que casa com o valor.
  def descrever(divisao) do
    case divisao do
      {:ok, valor} -> "resultado #{valor}"
      {:erro, motivo} -> "falhou: #{motivo}"
    end
  end

  # Varias clausulas da mesma funcao, escolhidas por padrao e por guarda (when).
  def classificar(numero) when numero < 0, do: :negativo
  def classificar(0), do: :zero
  def classificar(_numero), do: :positivo

  # Recursao no lugar de laco: a lista vazia encerra; a nao vazia e separada
  # em cabeca e cauda.
  def somar([]), do: 0
  def somar([cabeca | cauda]), do: cabeca + somar(cauda)

  # |> passa o valor da esquerda como primeiro argumento da funcao da direita.
  def pares_ao_quadrado(lista) do
    lista
    |> Enum.filter(fn numero -> rem(numero, 2) == 0 end)
    |> Enum.map(fn numero -> numero * numero end)
  end

  # Map: chave e valor. Todo dado e imutavel: Map.put devolve um map novo.
  def maps do
    pagamento = %{id: "pg-1", valor: 120.0}
    aprovado = Map.put(pagamento, :status, :aprovado)
    IO.inspect(pagamento)
    IO.inspect(aprovado)
    IO.puts("valor: #{aprovado.valor}")
  end
end

IO.puts("== Atomos")
Basico.atomos()

IO.puts("\n== Tuplas e pattern matching")
Basico.casamento()
IO.puts(Basico.descrever(Basico.dividir(9, 3)))
IO.puts(Basico.descrever(Basico.dividir(9, 0)))

IO.puts("\n== Clausulas e guarda")
IO.inspect(Enum.map([-5, 0, 7], &Basico.classificar/1))

IO.puts("\n== Recursao e |>")
IO.puts("soma: #{Basico.somar([1, 2, 3, 4])}")
IO.inspect(Basico.pares_ao_quadrado([1, 2, 3, 4, 5, 6]))

IO.puts("\n== Maps")
Basico.maps()
