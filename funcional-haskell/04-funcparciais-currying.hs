produto :: Int -> Int -> Int
produto x y = x * y

-- Funções parciais e currying
-- Todas as funções do Haskell são curried
duplicar = produto 2
triplicar = produto 3

logBase10 = logBase 10

main = do
  --print (duplicar 5)  -- Haskell computa ((produto 2) 5)
  --print (triplicar 5) -- Haskell computa ((produto 3) 5)
  print (logBase 10 1000)
  print (map (logBase10) [10, 20, 30, 40])