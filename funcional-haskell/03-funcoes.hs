-- Sem definição de tipos
duplicar x = x*2

-- Com definição de tipos
triplicar :: Integer -> Integer 
triplicar x = x*3

-- Com múltiplas variáveis
somaTres :: Int -> Int -> Int -> Int  
somaTres x y z = x + y + z  

-- Type variables
cabeca :: [a] -> a
cabeca (h:t) = h

rabo :: [a] -> [a]
rabo (h:t) = t

-- Pattern Matching
digaMe :: Integer -> String  
digaMe 1 = "Um"  
digaMe 2 = "Dois"  
digaMe 3 = "Três"  
digaMe 4 = "Quatro"  
digaMe 5 = "Cinco"  
digaMe x = "Outro número não entre 1 e 5" 

fact :: Integer -> Integer
fact 0 = 1
fact x = x*fib(x-1)

fib 0 = 1
fib 1 = 1
fib x = fib(x-1) + fib(x-2)

-- somaLista :: [a] -> Integer
-- somaLista [] = 0
-- somaLista (elemento:cauda) = elemento + (somaLista cauda)

main = do
  print (duplicar 5)
  print (triplicar 5)
  print (cabeca [1, 2, 4, 5])
  print (rabo [1, 2, 4, 5])

  -- função anônima
  putStrLn "\nFunção Anônima"
  print ((\x -> x + 1) 4)

  -- Funções de alta ordem
  putStrLn "\nFunções de alta ordem"
  print (map (\x -> x + 1) [1, 2, 3, 4])
  print (filter odd [1, 2, 3, 4])
  print (foldl (\x acc -> x + acc) 0 [1, 2, 3, 4])

  -- Pattern Matching
  putStrLn "\nPattern Matching"
  putStrLn (digaMe 1)
  putStrLn (digaMe 5)
  putStrLn (digaMe 7)
  print (fact 10)
  print (fib 10)
  --print (somaLista [1, 5, 10])