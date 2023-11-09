-- set :+t -- imprimir todos os tipos no terminal

-- Algebric Data Type 
-- Parece enum, mas é sem ordem
data Naipe = Espadas | Copas | Ouros | Paus deriving (Show)
data Numero = A | DOIS | TRES | QUATRO | CINCO | SEIS | SETE | OITO | NOVE | J | Q | K deriving (Show)

-- type Carta = (Naipe, Valor)
-- type Mao = [Carta]

valorNaipe :: Naipe -> Integer
valorNaipe Espadas = 1
valorNaipe Copas = 2
valorNaipe Ouros = 3
valorNaipe Paus = 4

-- Circulo x1 x2 r | Retangulo x1 y1 x2 y2
data Forma = Circulo Float Float Float | Retangulo Float Float Float Float deriving (Show)  

area :: Forma -> Float  
area (Circulo _ _ r) = pi * r ^ 2  
area (Retangulo x1 y1 x2 y2) = (abs $ x2 - x1) * (abs $ y2 - y1) 

-- data Car = Car {company :: String, model :: String, year :: Int} deriving (Show)
-- Car {company="Ford", model="Mustang", year=1967}

data Tree a = Children [Tree a] | Leaf a deriving (Show)

--Children[Leaf 1, Leaf 2]
let tree = Children[Leaf 1, Children [Leaf 2, Leaf 3]]

main = do
  let forma = Circulo 0 0 10
  print (area forma)
  let forma = Retangulo 0 0 10 10
  print (area forma)
  print(valorNaipe Espadas)