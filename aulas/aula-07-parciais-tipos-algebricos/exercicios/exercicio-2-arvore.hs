-- Aula 07 -- Exercicio 2: o que acontece com as funcoes quando o tipo muda
--
-- As tres primeiras funcoes ja estao escritas: sao as mesmas de
-- 04-tipos-recursivos.hs. A atividade nao e reescreve-las, e ver o que
-- acontece com elas nas Partes 2 e 3.
--
-- Registros pedidos no enunciado -- preencher aqui:
--
-- Parte 2. Funcoes que falharam ao acrescentar o construtor, e a mensagem:
--
-- Parte 3. Funcoes que atravessaram a generalizacao sem contexto:
--          Funcoes que passaram a exigir contexto, e qual classe cada uma:
--

data Arv = Vazia | No Arv Int Arv
  deriving (Show, Eq)

tamanho :: Arv -> Int
tamanho Vazia          = 0
tamanho (No esq _ dir) = 1 + tamanho esq + tamanho dir

emOrdem :: Arv -> [Int]
emOrdem Vazia          = []
emOrdem (No esq v dir) = emOrdem esq ++ [v] ++ emOrdem dir

inserir :: Int -> Arv -> Arv
inserir x Vazia = No Vazia x Vazia
inserir x t@(No esq v dir)
  | x < v     = No (inserir x esq) v dir
  | x > v     = No esq v (inserir x dir)
  | otherwise = t

-- PARTE 1 -- uma equacao por construtor.
-- Devolve a arvore entre parenteses, com '.' no lugar da subarvore vazia:
--   descrever (No (No Vazia 1 Vazia) 2 Vazia)  ==  "((.1.)2.)"
descrever :: Arv -> String
descrever = undefined

equilibrada :: Arv
equilibrada =
  No (No (No Vazia 1 Vazia) 2 (No Vazia 3 Vazia))
     4
     (No (No Vazia 5 Vazia) 6 (No Vazia 7 Vazia))

main :: IO ()
main = do
  putStrLn "-- Parte 1"
  print (tamanho equilibrada)
  print (emOrdem equilibrada)
  putStrLn (descrever equilibrada)
  print (emOrdem (inserir 8 equilibrada))
