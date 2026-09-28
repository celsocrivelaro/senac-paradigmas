-- Aula 07 -- Exercicio 1: funcoes, aplicacao parcial e funcoes nao-totais
--
-- ESTE ARQUIVO ESTA INCOMPLETO DE PROPOSITO. As funcoes marcadas com
-- 'undefined' sao a atividade. O arquivo compila como esta e falha em execucao
-- enquanto elas nao forem escritas.
--
-- Registros pedidos no enunciado -- preencher aqui:
--
-- Parte 2. Quantos argumentos 'mesmoNaipe' recebe, e o que e 'mesmoNaipe Espadas':
--
-- Parte 3. Por que 'soCopas' nao pode ser definida a partir de 'mesmoNaipeInv':
--
-- Parte 4. Entrada para a qual 'primeiraDoNaipe' falha, e a mensagem:
--

data Naipe = Espadas | Copas | Ouros | Paus
  deriving (Show, Eq)

data Valor = As | Dois | Tres | Quatro | Cinco | Seis | Sete
           | Oito | Nove | Dez | Valete | Dama | Rei
  deriving (Show, Eq)

data Carta = Carta Naipe Valor
  deriving (Show, Eq)

maoBaralho :: [Carta]
maoBaralho =
  [ Carta Espadas As
  , Carta Copas   Dez
  , Carta Ouros   Dama
  , Carta Paus    Sete
  , Carta Copas   Rei
  ]

-- PARTE 1 -- uma equacao, casando o padrao do construtor Carta.
mesmoNaipe :: Naipe -> Carta -> Bool
mesmoNaipe = undefined

-- PARTE 2 -- aplicacao parcial.
-- Definir SEM escrever o argumento da carta: nenhum dos dois lados do '='
-- pode mencionar uma carta.
soEspadas :: Carta -> Bool
soEspadas = undefined

-- PARTE 3 -- a ordem dos argumentos.
-- Esta versao ja esta escrita. Tentar definir 'soCopas' a partir dela do mesmo
-- jeito da Parte 2, e registrar no topo por que nao da.
mesmoNaipeInv :: Carta -> Naipe -> Bool
mesmoNaipeInv (Carta n _) m = n == m

-- PARTE 4 -- uma funcao nao-total.
-- Devolve a primeira carta do naipe pedido.
primeiraDoNaipe :: Naipe -> [Carta] -> Carta
primeiraDoNaipe = undefined

main :: IO ()
main = do
  putStrLn "-- Parte 1"
  print (mesmoNaipe Espadas (Carta Espadas As))
  print (mesmoNaipe Espadas (Carta Copas Dez))

  putStrLn "\n-- Parte 2"
  print (filter soEspadas maoBaralho)
  print (length (filter soEspadas maoBaralho))

  putStrLn "\n-- Parte 4"
  print (primeiraDoNaipe Copas maoBaralho)
