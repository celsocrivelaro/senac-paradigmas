-- Aula 07, Bloco 3 -- Tipos de dados algebricos: soma e produto
-- Deriva de codigo/funcional-haskell/05-algebric-data-types.hs.
--
-- O ARQUIVO INTEIRO E MONOMORFICO. Nenhum tipo aqui tem parametro e nenhuma
-- assinatura tem '=>'. O unico deriving e (Show, Eq), sem o qual nada se
-- imprime nem se compara; o que deriving faz, e por que a linguagem consegue
-- faze-lo, e assunto do Bloco 4, no arquivo 05.
-- Os tipos recursivos, que sao a outra metade do Bloco 3, estao no 04.

-- ANTES DE TUDO: O QUE E 'deriving'.
-- A clausula manda o compilador GERAR automaticamente, para o tipo declarado
-- acima dela, as operacoes que ela nomeia:
--   Show  transforma um valor em texto. E o que print precisa.
--   Eq    compara dois valores com == e /=.
-- Sem ela, um tipo recem-declarado nao sabe fazer nem uma coisa nem outra, e
-- 'print Espadas' NAO COMPILA:
--   error: No instance for 'Show Naipe' arising from a use of 'print'
-- Aqui ela e usada como ferramenta: o tipo precisa imprimir para a aula andar.
-- POR QUE a linguagem consegue gerar essas operacoes sozinha, e o que mais da
-- para derivar, e assunto do Bloco 4 -- e a resposta depende de o tipo ser
-- algebrico.

-- SOMA. Quatro construtores sem argumento: o tipo tem exatamente 4 valores.
-- Nao e o enum da familia C -- os construtores nao sao inteiros disfarcados e
-- nao admitem aritmetica.
data Naipe = Espadas | Copas | Ouros | Paus
  deriving (Show, Eq)

data Valor = As | Dois | Tres | Quatro | Cinco | Seis | Sete
           | Oito | Nove | Dez | Valete | Dama | Rei
  deriving (Show, Eq)

-- As duas listas sao escritas a mao de proposito: e o que torna a contagem
-- visivel. A forma automatica, [minBound .. maxBound], depende de classes de
-- tipo e aparece no Bloco 4.
naipes :: [Naipe]
naipes = [Espadas, Copas, Ouros, Paus]

valores :: [Valor]
valores = [As, Dois, Tres, Quatro, Cinco, Seis, Sete,
           Oito, Nove, Dez, Valete, Dama, Rei]

-- PRODUTO. Carta tem 4 * 13 = 52 valores.
-- O identificador Carta aparece dos dois lados do '=' e nomeia duas coisas
-- distintas: a esquerda, o construtor de TIPO; a direita, o construtor de DADO,
-- que e a funcao Naipe -> Valor -> Carta.
data Carta = Carta Naipe Valor
  deriving (Show, Eq)

-- A cardinalidade nao e afirmacao sobre a notacao: e contavel.
baralho :: [Carta]
baralho = [Carta n v | n <- naipes, v <- valores]

-- Uma mao: cinco combinacoes escolhidas dos dois tipos, escritas a mao.
-- Cada elemento aplica o CONSTRUTOR DE DADO Carta, que e a funcao
--   Carta :: Naipe -> Valor -> Carta
-- a um naipe e a um valor. O baralho acima gera as 52 combinacoes; aqui cinco
-- delas sao nomeadas.
maoBaralho :: [Carta]
maoBaralho =
  [ Carta Espadas As
  , Carta Copas   Dez
  , Carta Ouros   Dama
  , Carta Paus    Sete
  , Carta Copas   Rei
  ]

valorNaipe :: Naipe -> Integer
valorNaipe Espadas = 1
valorNaipe Copas   = 2
valorNaipe Ouros   = 3
valorNaipe Paus    = 4

-- SOMA DE PRODUTOS. Forma e a soma de um produto de tres Float com um produto
-- de quatro Float: Float^3 + Float^4. Dai o nome algebrico -- o tipo e
-- construido por soma e produto de outros tipos.
data Forma = Circulo Float Float Float
           | Retangulo Float Float Float Float
  deriving (Show)

area :: Forma -> Float
area (Circulo _ _ r)         = pi * r ^ (2 :: Int)
area (Retangulo x1 y1 x2 y2) = abs (x2 - x1) * abs (y2 - y1)

-- Sintaxe de registro: o mesmo produto, com as projecoes geradas pela
-- linguagem.
data Carro = Carro { fabricante :: String, modelo :: String, ano :: Int }
  deriving (Show)

main :: IO ()
main = do
  putStrLn "-- Soma: os construtores sao os valores do tipo"
  print naipes
  print (length valores)

  putStrLn "\n-- Produto: 4 * 13 = 52"
  print (length baralho)
  print (take 3 baralho)
  print (valorNaipe Espadas)

  putStrLn "\n-- Uma mao: cinco combinacoes dos dois tipos"
  mapM_ print maoBaralho
  print (length maoBaralho)
  -- Toda carta da mao pertence ao baralho. A verificacao so e possivel porque
  -- Carta deriva Eq, e Eq de um tipo produto compara campo a campo.
  print (all (`elem` baralho) maoBaralho)

  putStrLn "\n-- Soma de produtos"
  print (area (Circulo 0 0 10))
  print (area (Retangulo 0 0 10 10))

  putStrLn "\n-- Registro"
  let carro = Carro { fabricante = "Ford", modelo = "Mustang", ano = 1967 }
  print carro
  print (ano carro)
