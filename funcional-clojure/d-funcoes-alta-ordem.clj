; Funções de alta ordem
; São funções que usam outras funções para o seu processamento
; é um tipo de Polimorfismo

(defn adulto-brasil? [idade] (>= idade 18))
(defn adulto-coreia? [idade] (>= idade 19))
(defn adulto-eua? [idade] (>= idade 16))

(defn assinatura [adulto? idade] 
	(if (adulto? idade) 
      (println "Assinatura liberada") 
      (println "Precisa ser adulto."))
)

(println "\n---- FUNÇÕES DE ALTA ORDEM ----")
(assinatura adulto-brasil? 30)
(assinatura adulto-brasil? 12)
(assinatura adulto-coreia? 18)
(assinatura adulto-eua? 17)

(println "\n---- MAP ----")
; Map é uma função de alta ordem que aplica um processamento
; em todos os itens de uma lista
(defn dobrar [v] (* v 2))
(println (map dobrar [1 5 6]))

(println "\n---- REDUCE ----")
; Reduce faz algum cálculo sobre toda a lista e
; retorn uma resultado baseado em um acumulador
; deve-se iniciar com um valor com um acumulador
(defn mais [acc,v] (+ acc v))
(println (reduce mais 0 [1 5 6])) ; + é a função e 0 é o valor inicial o acumulador

(println "\n---- FILTER ----")
; Função filter 
(defn positivo? [valor] (>= valor 0))
(println (filter positivo? [0 -1 10 -5]))