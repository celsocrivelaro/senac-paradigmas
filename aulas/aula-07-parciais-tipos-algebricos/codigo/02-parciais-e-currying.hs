-- Aula 07, Bloco 2 -- Funcoes parciais e currying
-- Deriva de codigo/funcional-haskell/04-funcparciais-currying.hs.

produto :: Int -> Int -> Int
produto x y = x * y

-- A seta associa a direita:      Int -> Int -> Int  e  Int -> (Int -> Int).
-- A aplicacao associa a esquerda: produto 2 5       e  (produto 2) 5.
-- As duas convencoes juntas produzem a aparencia de funcao de dois argumentos.
-- Nao existe funcao de dois argumentos em Haskell.

-- Aplicacao parcial: produto 2 e uma funcao completa de tipo Int -> Int, nao
-- uma chamada inacabada. Nenhum mecanismo novo entra aqui -- e a aplicacao
-- comum, interrompida onde o tipo permite.
duplicar :: Int -> Int
duplicar = produto 2

triplicar :: Int -> Int
triplicar = produto 3

-- Estilo point-free: a definicao e uma igualdade entre funcoes, sem nomear o
-- argumento.
-- Atencao na exibicao: logBase10 1000 imprime 2.9999999999999996, e nao 3.0.
-- O resultado e da aritmetica de ponto flutuante binaria, nao do currying.
logBase10 :: Double -> Double
logBase10 = logBase 10

-- curry e uncurry testemunham o isomorfismo entre (a, b) -> c e a -> b -> c.
produtoEmPar :: (Int, Int) -> Int
produtoEmPar = uncurry produto

produtoDeVolta :: Int -> Int -> Int
produtoDeVolta = curry produtoEmPar

-- SEGUNDO SENTIDO DE "PARCIAL" -- sem relacao com a aplicacao parcial acima.
-- Uma funcao e TOTAL quando, para TODO valor do dominio declarado, a aplicacao
-- termina e devolve um valor do tipo prometido. Falhando qualquer das tres
-- exigencias -- devolver algo, em tempo finito, do tipo certo -- ela e PARCIAL.
--
-- Faltar equacao e so UMA das quatro formas de nao ser total:
--   1. equacao faltando        cabeca []   Non-exhaustive patterns
--   2. error/undefined         head []     Prelude.head: empty list
--   3. nao-terminacao          laco x = laco x   nada: o programa nao termina
--   4. operacao parcial        div 1 0     divide by zero
-- So a primeira e acusada pelo aviso de casamento nao exaustivo. A terceira
-- nao produz erro
-- nenhum, e nao e detectavel em geral.
cabeca :: [a] -> a
cabeca (h:_) = h

-- Ha tres formas de tornar total. Esta e a mais barata e a pior: a funcao passa
-- a ser total, mas CONFUNDE "nao ha primeiro elemento" com "o primeiro elemento
-- e zero". O defeito saiu da execucao e entrou na logica, onde nao ha mensagem
-- de erro. As outras duas sao restringir o dominio (lista nao-vazia) ou alargar
-- o contradominio (Maybe), e so a segunda e geral -- ver a nota 02.
primeiroOuZero :: [Int] -> Int
primeiroOuZero []      = 0
primeiroOuZero (x:_)   = x

main :: IO ()
main = do
  putStrLn "-- Aplicacao parcial"
  print (duplicar 5)
  print (triplicar 5)
  print (map (produto 10) [1, 2, 3])

  putStrLn "\n-- A aplicacao e associativa a esquerda"
  print (produto 2 5)
  print ((produto 2) 5)

  putStrLn "\n-- Point-free"
  print (logBase10 1000)
  print (map logBase10 [10, 100, 1000])

  putStrLn "\n-- curry e uncurry"
  print (produtoEmPar (3, 4))
  print (produtoDeVolta 3 4)

  putStrLn "\n-- Funcao nao-total e a versao total"
  print (cabeca [7, 8 :: Int])
  print (primeiroOuZero [7, 8])
  print (primeiroOuZero [])
  -- A linha abaixo compila e falha em execucao. Descomentar em sala para
  -- exibir a mensagem, que e a prova de que o tipo nao cobriu o caso.
  -- print (cabeca ([] :: [Int]))
