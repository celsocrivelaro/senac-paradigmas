-- Aula 07 -- Tipos recursivos e estruturas de dados
--
-- Continua o 03. La os tipos eram planos: um construtor guardava Int, Float ou
-- String. Aqui um construtor guarda o PROPRIO TIPO que esta sendo declarado, e
-- e dessa recursao que saem as estruturas de dados.
-- O arquivo tambem e monomorfico do inicio ao fim: a arvore guarda Int. O 05
-- generaliza exatamente esta declaracao.

-- TIPO RECURSIVO: UMA ARVORE BINARIA DE BUSCA.
-- A definicao do tipo e a definicao da estrutura. Nao ha ponteiro a declarar e
-- nao ha caso nulo a documentar a parte: a arvore vazia e um VALOR do tipo,
-- com construtor proprio. Nenhum estado invalido e representavel.
-- A arvore esta FIXADA EM Int. O Bloco 4 generaliza exatamente esta declaracao.
data Arv = Vazia | No Arv Int Arv
  deriving (Show, Eq)

-- CASAMENTO EXAUSTIVO: uma equacao por construtor, em toda funcao.
-- Ligado o aviso de casamento nao exaustivo, acrescentar um construtor a Arv
-- faz falhar toda
-- funcao que nao o tratar. E o que separa isto de um switch sobre inteiro, onde
-- o caso omitido e silencioso.
tamanho :: Arv -> Int
tamanho Vazia          = 0
tamanho (No esq _ dir) = 1 + tamanho esq + tamanho dir

profundidade :: Arv -> Int
profundidade Vazia          = 0
profundidade (No esq _ dir) = 1 + max (profundidade esq) (profundidade dir)

-- ALGORITMO SOBRE O TIPO.
-- A invariante da arvore de busca -- tudo a esquerda e menor, tudo a direita e
-- maior -- nao esta no tipo; esta nas guardas de inserir e de buscar, e as duas
-- funcoes precisam concorda-la entre si.
inserir :: Int -> Arv -> Arv
inserir x Vazia = No Vazia x Vazia
inserir x t@(No esq v dir)
  | x < v     = No (inserir x esq) v dir   -- 'dir' atravessa pelo nome
  | x > v     = No esq v (inserir x dir)   -- 'esq' atravessa pelo nome
  | otherwise = t                          -- ja esta na arvore

buscar :: Int -> Arv -> Bool
buscar _ Vazia = False
buscar x (No esq v dir)
  | x < v     = buscar x esq
  | x > v     = buscar x dir
  | otherwise = True

-- O percurso em ordem devolve os elementos ordenados, e e onde a invariante se
-- verifica: se o resultado nao sai ordenado, a invariante foi quebrada.
emOrdem :: Arv -> [Int]
emOrdem Vazia          = []
emOrdem (No esq v dir) = emOrdem esq ++ [v] ++ emOrdem dir

-- IMUTABILIDADE E COMPARTILHAMENTO ESTRUTURAL.
-- Nada e alterado no lugar: inserir CONSTROI UMA ARVORE NOVA. So o caminho da
-- raiz ate a posicao da insercao e reconstruido -- veja-se, nas duas guardas de
-- inserir, que um lado e reconstruido e o outro aparece a direita do construtor
-- exatamente como chegou. O custo e a profundidade, nao o tamanho, e a arvore
-- anterior continua valida: e a definicao de estrutura persistente.

-- AS ARVORES DOS EXEMPLOS, ESCRITAS POR EXTENSO.
-- Escrever os construtores a mao, em vez de derivar a arvore de uma lista, poe
-- a FORMA a vista: e ela, e nao o conjunto de elementos, que decide o custo.
-- As duas abaixo tem exatamente os mesmos sete elementos e ambas respeitam a
-- invariante -- emOrdem devolve [1..7] nas duas.

-- Equilibrada: profundidade 3.
equilibrada :: Arv
equilibrada =
  No (No (No Vazia 1 Vazia) 2 (No Vazia 3 Vazia))
     4
     (No (No Vazia 5 Vazia) 6 (No Vazia 7 Vazia))

-- Degenerada: cada no so tem filho direito. Profundidade 7 -- e uma lista
-- encadeada com sintaxe de arvore. E a forma que sai de inserir 1, depois 2,
-- e assim por diante ate 7, numa arvore vazia.
degenerada :: Arv
degenerada =
  No Vazia 1
    (No Vazia 2
      (No Vazia 3
        (No Vazia 4
          (No Vazia 5
            (No Vazia 6
              (No Vazia 7 Vazia))))))

-- Auxiliares totais, so para a demonstracao do compartilhamento.
subEsq :: Arv -> Arv
subEsq Vazia          = Vazia
subEsq (No esq _ _)   = esq

subDir :: Arv -> Arv
subDir Vazia          = Vazia
subDir (No _ _ dir)   = dir

main :: IO ()
main = do
  putStrLn "-- Arvore binaria de busca"
  print (emOrdem equilibrada)
  print (tamanho equilibrada, profundidade equilibrada)
  print (buscar 5 equilibrada, buscar 8 equilibrada)

  putStrLn "\n-- Imutabilidade: inserir devolve OUTRA arvore"
  let nova = inserir 8 equilibrada
  print (emOrdem equilibrada)   -- a original permanece exatamente como estava
  print (emOrdem nova)
  print (tamanho equilibrada, tamanho nova)

  -- O COMPARTILHAMENTO NAO SE VE AQUI. A igualdade abaixo diz que as subarvores
  -- tem o mesmo VALOR, e nao que ocupam a mesma memoria -- e condicao
  -- necessaria, nao suficiente. Quem mostra que a subarvore nao foi
  -- reconstruida e a leitura das guardas de inserir.
  putStrLn "\n-- O 8 desce sempre a direita; a esquerda nao e tocada"
  print (subEsq equilibrada == subEsq nova)
  print (subDir equilibrada == subDir nova)

  putStrLn "\n-- Mesmos elementos, formas diferentes, custos diferentes"
  print (emOrdem degenerada)
  print (emOrdem equilibrada == emOrdem degenerada)
  print (profundidade equilibrada, profundidade degenerada)

  -- A busca percorre um caminho da raiz ate o elemento, logo o custo dela e a
  -- profundidade: log n na equilibrada, n na degenerada -- o custo da busca
  -- linear. E o problema que as arvores auto-equilibrantes resolvem.
  print (buscar 7 equilibrada, buscar 7 degenerada)
