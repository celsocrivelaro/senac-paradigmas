 (println "\n---- Expressões ----")
; Notação infixa (nome-funcao arg1 arg 2 ...)
; trate tudo como lista
(println (+ 1 3 23 234))
(println (/ 100 2 5)) ; primeiro argumento é numerador e os outros os denominadores

; booleanos
; a mesma lógica se aplica aos booleanos
(println "\n---- Booleanos ----")
(println (= 1 2 2)) ; este é um operador de igualdade
(println (< 10 24 77))

; strings
; função str converte os outros tipos para string ou concatena
(println "\n---- Strings ----")
(println (str 13 " é a idade de " "Enzo" ", gênero: " :masculino))

; definição de variavel
(println "\n---- Variável ----")
(def a 1243)
(println (str a " é o código de entrada"))
; as variávels são imutáveis
(def a (+ a 1)) ; mas se pode redefinir os valores
(println (str a " é o novo código de entrada"))

; definição de Listas
; conjunto elementos ordenados => Usado para codigo ()
(println "\n---- Listas ----")
; '(1 2 3)
(println (list 1 3 4))

; definição de Vetores
; conjunto elementos ordenados => Usado para dados []
; otimizados para acesso randômico
(println "\n---- Vetores ----")
(def vetor [1 3 4])
(println vetor)
(println (first [1 3 4]))
(println (last [1 3 4]))
(println (nth [1 3 4] 1))

; definição de Maps
; conjunto de chave-valor = {}
(println "\n---- Maps ----")
(def pessoa {:nome "maria", :idade 28} )
(println (pessoa :nome))


; ------------ FUNÇÕES --------------