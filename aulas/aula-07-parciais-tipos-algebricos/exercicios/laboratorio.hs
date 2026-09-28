-- Aula 07 -- Laboratorio em sala
--
-- ESTE ARQUIVO ESTA INCOMPLETO DE PROPOSITO. As funcoes tem assinatura e corpo
-- 'undefined'; preenche-las e a atividade. O arquivo COMPILA como esta, e
-- falha em execucao ate que a funcao chamada tenha sido escrita.
--
-- Registros pedidos no enunciado (Partes 4 e 5) -- preencher aqui:
--
-- Parte 4. Funcoes que falharam ao acrescentar o construtor:
--
-- Parte 5. Funcoes que atravessaram a generalizacao intactas:
--          Funcoes que passaram a exigir contexto, e qual:
--

-- PARTE 1 -- o tipo.
-- Antes de ler a declaracao abaixo, escreve-se a propria e comparam-se as duas.
data Expr = Lit Int
          | Soma Expr Expr
          | Mult Expr Expr
          | Neg Expr
  deriving (Show, Eq)

-- PARTE 2 -- o avaliador, uma equacao por construtor.
avaliar :: Expr -> Int
avaliar = undefined

-- PARTE 3 -- uma segunda funcao sobre o mesmo tipo.
-- Escolher UMA das duas e implementar; a outra pode ficar como esta.
-- O ponto da parte e observar que a estrutura das duas e a mesma do avaliador.
contarOperacoes :: Expr -> Int
contarOperacoes = undefined

emInfixa :: Expr -> String
emInfixa = undefined

-- Expressoes de teste. Valores esperados, para conferencia:
--   avaliar e1 == 14        (3 + 4) * 2
--   avaliar e2 == -6        -(1 + 5)
--   avaliar e3 == 20        (3 + 4) * 2 + (1 + 5)
e1, e2, e3 :: Expr
e1 = Mult (Soma (Lit 3) (Lit 4)) (Lit 2)
e2 = Neg (Soma (Lit 1) (Lit 5))
e3 = Soma e1 (Soma (Lit 1) (Lit 5))

main :: IO ()
main = do
  putStrLn "-- Parte 2: o avaliador"
  print (avaliar e1)
  print (avaliar e2)
  print (avaliar e3)

  putStrLn "\n-- Parte 3: a segunda funcao"
  print (contarOperacoes e1)
  putStrLn (emInfixa e1)
