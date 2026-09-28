-- Aula 07, Bloco 1 -- Funcoes
-- Deriva de codigo/funcional-haskell/03-funcoes.hs.

-- Sem assinatura: o tipo e inferido.
duplicar x = x * 2

-- Com assinatura explicita.
triplicar :: Integer -> Integer
triplicar x = x * 3

somaTres :: Int -> Int -> Int -> Int
somaTres x y z = x + y + z

-- Variaveis de tipo. No corpo de cabeca, 'a' e desconhecido: nao ha operacao
-- aplicavel ao elemento. A unica implementacao total possivel desta assinatura
-- devolve um dos elementos recebidos. O tipo restringe antes de qualquer teste.
cabeca :: [a] -> a
cabeca (h:_) = h

cauda :: [a] -> [a]
cauda (_:t) = t

-- Nenhuma das duas trata a lista vazia. A assinatura [a] -> a nao registra essa
-- ausencia; o Bloco 2 retoma o ponto e o Bloco 3 o resolve com Maybe.
-- O GHC acusa as duas com o aviso de casamento nao exaustivo. O aviso e esperado
-- e faz parte da exposicao: o compilador ve a lacuna que o tipo nao registra.

-- Definicao por equacoes: a avaliacao desce ate a primeira cujo padrao case.
-- Promover a ultima equacao ao topo faz todas as demais deixarem de ser
-- alcancadas.
digaMe :: Integer -> String
digaMe 1 = "Um"
digaMe 2 = "Dois"
digaMe 3 = "Tres"
digaMe 4 = "Quatro"
digaMe 5 = "Cinco"
digaMe _ = "Outro numero fora do intervalo de 1 a 5"

-- Recursao no lugar do laco: o caso-base e uma equacao, nao um desvio.
fatorial :: Integer -> Integer
fatorial 0 = 1
fatorial n = n * fatorial (n - 1)

fib :: Integer -> Integer
fib 0 = 1
fib 1 = 1
fib n = fib (n - 1) + fib (n - 2)

-- ERRO DELIBERADO, discutido no fecho do Bloco 1.
-- A assinatura esta correta. O corpo chama fib no lugar da propria funcao.
-- O programa compila sem aviso e devolve resultado incorreto, porque duas
-- funcoes distintas partilham o tipo Integer -> Integer. A checagem de tipos
-- restringe o espaco de programas aceitos; nao o reduz ao dos programas
-- corretos.
fatorialQuebrado :: Integer -> Integer
fatorialQuebrado 0 = 1
fatorialQuebrado n = n * fib (n - 1)

main :: IO ()
main = do
  putStrLn "-- Aplicacao simples"
  print (duplicar 5)
  print (triplicar 5)
  print (somaTres 1 2 3)

  putStrLn "\n-- Casamento de padrao sobre listas"
  print (cabeca [1, 2, 4, 5 :: Int])
  print (cauda [1, 2, 4, 5 :: Int])

  putStrLn "\n-- Funcao anonima"
  print ((\x -> x + 1) (4 :: Int))

  putStrLn "\n-- Funcoes de alta ordem"
  print (map (\x -> x + 1) [1, 2, 3, 4 :: Int])
  print (filter odd [1, 2, 3, 4 :: Int])
  print (foldl (\acc x -> acc + x) 0 [1, 2, 3, 4 :: Int])

  putStrLn "\n-- Definicao por equacoes"
  putStrLn (digaMe 1)
  putStrLn (digaMe 5)
  putStrLn (digaMe 7)

  putStrLn "\n-- Recursao"
  print (fatorial 10)
  print (fib 10)

  putStrLn "\n-- O que o tipo nao garante"
  print (fatorialQuebrado 10)
