-- Aula 07, Bloco 4 -- Tipos polimorficos
--
-- Todo exemplo aqui generaliza um antecedente monomorfico do Bloco 3.

-- CONSTRUTOR DE TIPO COM PARAMETRO.
-- Arv sozinho NAO e um tipo: e uma funcao no nivel dos tipos, que recebe um
-- tipo e devolve um tipo -- kind * -> *. Arv Int e que e um tipo (kind *).
-- No GHCi:  :kind Arv      devolve  * -> *
--           :kind Arv Int  devolve  *
-- Aplicar um construtor de tipo a menos argumentos do que ele aceita e a
-- aplicacao parcial do Bloco 2, um nivel acima.
data Arv a = Vazia | No (Arv a) a (Arv a)
  deriving (Show, Eq)

-- A GENERALIZACAO. Comparar com Arv do 04: os corpos abaixo nao mudam uma
-- linha. Muda so a assinatura, de Arv -> Int para Arv a -> Int.
tamanho :: Arv a -> Int
tamanho Vazia          = 0
tamanho (No esq _ dir) = 1 + tamanho esq + tamanho dir

profundidade :: Arv a -> Int
profundidade Vazia          = 0
profundidade (No esq _ dir) = 1 + max (profundidade esq) (profundidade dir)

-- PARAMETRICIDADE. Nos corpos acima, 'a' e desconhecido: nenhuma operacao se
-- aplica ao elemento. Essa ignorancia e o que torna as funcoes aplicaveis a
-- qualquer arvore.
-- emOrdem e o caso mais eloquente: ela TOCA em todos os elementos e ainda assim
-- nao precisa de contexto nenhum, porque so os move de lugar.
emOrdem :: Arv a -> [a]
emOrdem Vazia          = []
emOrdem (No esq v dir) = emOrdem esq ++ [v] ++ emOrdem dir

-- O LIMITE DA PARAMETRICIDADE.
-- A assinatura abaixo e impossivel de implementar: decidir para que lado desce
-- o elemento exige compara-lo com o da raiz, e Arv a -> Arv a nao oferece
-- comparacao alguma. Descomentar em sala para exibir a mensagem do GHC, que
-- nomeia a variavel de tipo e a classe ausente.
--
-- inserir :: a -> Arv a -> Arv a
-- inserir x Vazia = No Vazia x Vazia
-- inserir x t@(No esq v dir)
--   | x < v     = No (inserir x esq) v dir
--   | x > v     = No esq v (inserir x dir)
--   | otherwise = t

-- RESTRICAO DE CONTEXTO. A seta dupla => nao e a seta simples ->: o que esta a
-- esquerda nao e argumento, e exigencia sobre o tipo. Le-se "para todo 'a' que
-- ofereca as operacoes de Ord". A restricao devolve a funcao exatamente as
-- operacoes de que ela precisa, e nada alem: Ord autoriza comparar, e nao
-- autoriza somar nem imprimir.
-- Contagem de argumentos: so as setas A DIREITA do => contam. inserir recebe
-- dois argumentos, nao tres.
inserir :: Ord a => a -> Arv a -> Arv a
inserir x Vazia = No Vazia x Vazia
inserir x t@(No esq v dir)
  | x < v     = No (inserir x esq) v dir
  | x > v     = No esq v (inserir x dir)
  | otherwise = t

buscar :: Ord a => a -> Arv a -> Bool
buscar _ Vazia = False
buscar x (No esq v dir)
  | x < v     = buscar x esq
  | x > v     = buscar x dir
  | otherwise = True

deLista :: Ord a => [a] -> Arv a
deLista = foldl (flip inserir) Vazia

-- POLIMORFISMO AD-HOC: a implementacao escolhida depende do tipo, e a escolha e
-- feita em compilacao. No polimorfismo parametrico, o codigo e o mesmo para
-- todos os tipos.
-- Os generics de Java com extends sao um parente mais fraco da mesma ideia.
descrever :: Show a => a -> String
descrever x = "valor: " ++ show x

-- DERIVING. A estrutura do tipo algebrico determina a implementacao, e e por
-- isso que a linguagem consegue gera-la: comparar dois valores de uma soma de
-- produtos e comparar o construtor e depois os campos.
-- Enum e Bounded substituem a lista de naipes escrita a mao no Bloco 3, e Ord
-- e o que permite ao naipe entrar numa arvore de busca.
data Naipe = Espadas | Copas | Ouros | Paus
  deriving (Show, Eq, Ord, Enum, Bounded)

naipes :: [Naipe]
naipes = [minBound .. maxBound]

-- MAYBE: o encontro dos dois blocos. Algebrico pela soma, polimorfico pelo
-- parametro.  data Maybe a = Nothing | Just a
-- Ele torna total a funcao parcial do Bloco 2: primeiro [] nao diverge.
primeiro :: [a] -> Maybe a
primeiro []    = Nothing
primeiro (x:_) = Just x

buscaNaipe :: String -> Maybe Naipe
buscaNaipe "espadas" = Just Espadas
buscaNaipe "copas"   = Just Copas
buscaNaipe "ouros"   = Just Ouros
buscaNaipe "paus"    = Just Paus
buscaNaipe _         = Nothing

dividir :: Int -> Int -> Maybe Int
dividir _ 0 = Nothing
dividir x y = Just (x `div` y)

-- Compor duas funcoes que devolvem Maybe obriga a desempacotar e reempacotar em
-- cada passo. Os dois 'case' tem estrutura identica, e a repeticao fica a
-- vista. A aula termina aqui: dar nome a essa repeticao e assunto da proxima.
dividirDuasVezes :: Int -> Int -> Int -> Maybe Int
dividirDuasVezes x y z =
  case dividir x y of
    Nothing -> Nothing
    Just r  -> case dividir r z of
                 Nothing -> Nothing
                 Just s  -> Just s

main :: IO ()
main = do
  putStrLn "-- A mesma estrutura, agora para qualquer elemento"
  let numeros = deLista [4, 2, 6, 1, 3, 5, 7 :: Int]
  let textos  = deLista ["pera", "uva", "maca", "figo"]
  print (emOrdem numeros)
  print (emOrdem textos)

  putStrLn "\n-- Sem contexto: o que so move os elementos"
  print (tamanho numeros, profundidade numeros)
  print (tamanho textos, profundidade textos)

  putStrLn "\n-- Com contexto: o que precisa comparar"
  print (buscar 5 numeros, buscar 8 numeros)
  print (buscar "uva" textos, buscar "kiwi" textos)

  putStrLn "\n-- O que deriving comprou de volta"
  print naipes
  print (Espadas < Copas)
  print (succ Espadas)
  print (emOrdem (deLista [Paus, Espadas, Ouros, Copas]))

  putStrLn "\n-- Polimorfismo ad-hoc"
  putStrLn (descrever (42 :: Int))
  putStrLn (descrever "texto")
  putStrLn (descrever (emOrdem numeros))

  putStrLn "\n-- Maybe torna total a funcao parcial do Bloco 2"
  print (primeiro ([] :: [Int]))
  print (primeiro [7, 8 :: Int])
  print (buscaNaipe "copas")
  print (buscaNaipe "manilha")

  putStrLn "\n-- A composicao escrita a mao"
  print (dividirDuasVezes 100 5 2)
  print (dividirDuasVezes 100 0 2)
  print (dividirDuasVezes 100 5 0)
