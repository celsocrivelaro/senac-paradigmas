
; função pura
; não altera os valores do contexto
; tudo que a função precisa é recebido pelos argumentos
; todas as variáveis são locais
; retorna algum processamento
(def a 1224)
(defn calculo [arg1 arg2] (+ (/ 500 arg1) (* 211 arg2)))
; uma função pura pode ser composta por outras funções
(defn adicionar50 [arg1 arg2] (+ (calculo arg1 arg2) 50))
; Porque funções puras são importantes: evitam o side-effects
; que são muito comuns em Orientação a Objetos

; função anônima 2
; função sem nome que:
; ou geralmente associada a variável
; ou passada para outras funções
; ou retornada por uma função
(defn retorna-funcao 
  [tipo]
  (if 
    (= tipo 1) ; teste lógico
    (fn [arg1] (+ 1 arg1)) ; if true => função anônima
    (fn [arg1] (* 4 arg1)) ; else => função anônima
  )
)

; Função Recursiva
; recursão é uma forma de fazer um loop em funcional
(defn fact [n] 
  (if 
    (= n 0) 
    1 
    (* n (fact (- n 1)))
  )
)
; Tail Call Optimization
; http://rmulhol.github.io/clojure/2015/05/05/clojure-loop-recur.html
(defn fact-tail [x]
  (loop [n x prod 1]
    (if (= 1 n)
      prod
      (recur (- n 1) (* prod n)))))


; função recursiva
; função que chava ela mesma
; bom uso para loops
  
(println "\n---- DEFINIÇÃO DE FUNÇÃO ----")
; Os parêntese em clojure são a chamada
; de execução de função
(println (calculo 30 34))
(println (adicionar50 30 34))

; função anônima 1
(println "\n---- FUNÇÃO ANÔNIMA ----")
; função sem nome

(println ((fn [x] (+ x 2)) 5))
; função retornada
(println ((retorna-funcao 1) 10))
(println ((retorna-funcao 2) 10))

(println "\n---- FUNÇÃO RECURSIVA ----")
; função recursiva
(println (fact 20))
; função com Tail call optmization
(println (fact-tail 20))
