# Lógico: Cláusulas de Horn e Base de Conhecimento

Tema: Lógico

# 🔬 Teoria

# Literais

Literal é uma fórmula atômica ou sua negação. Podem ser:

- Um literal positivo é apenas um átormo (Ex: x)
- Um literal negativo é a negação do átomo

Em funções booleanas, cada variável ou sua forma inversa é um literal. ABC ⇒ 3 literais

Em cálculo de predicados o literal é um símbolo de predicado com alguns termos P(t1, ..., tn) com definição recursiva de símbolos de constantes, variáveis e funções.. Exemplo !Q(f(g(x)),y,2),x) é um literal negativo.

# Cláusula

Cláusula é uma expressão formada por uma coleção finita de literais. A cláusula é verdadeira se o conjunto é verdadeiro.

- Cláusula disjuntiva (ou): Se pelo menos um é verdadeiro
- Cláusula conjuntiva (e): Se todos são verdadeiros.

# Predicados

Predicado é uma função booleana de valor P: X → {verdadeiro,falso}. Em lógica, define o conceito de uma relação, sendo uma função de características de uma relação.

De forma simplificada, um predicado é uma afirmação que pode ser verdadeira ou falsa dependendo do valor das suas variáveis. Exemplo:

P(x) = {x | x ≥ 4}. Verdadeiro para 5 e falso para 2

Podemos ler isso da seguinte forma: x é número maior ou igual a 4.

# Lógica de Predicados ou Proposicional

Sistema de lógica que usa variáveis, funções e constantes.

Exemplo: 

Todo carro é dirigido por um motorista.

"(Todos C)  DirigeCarro(C) ⇒ Motorista(C)

variável C

Símbolo predicado: Carro, Motorista

quantificadores: Todos, Existe

Conector lógico: e, ou, não, ⇒ ...

Com isso, podemos fazer inferências computacional sobre a variável C

# Cláusulas de Horn

## Definição

Cláusulas de Horn são uma variante de cálculo de predicados. Para ser uma cláusula de Horn, preciso de, no máximo, um predicado verdadeiro.

Uma cláusula de Horn tem uma cabeçalho predicado *h* e corpo com a uma lista de predicados *p1, p2, p3, ..., pn* .

h ← p1, p2, p3, ..., pn

Isto é, *h* é verdadeiro quando p1, p2, ... e pn forem verdadeiros.

Exemplo: 

Definição de pato do animal a:

pato(a) ← !voa(a), nada(a), faz_quack(a)

Se o animal *a* não voa, nada e faz quack, então ele é um pato.

## Resolução e Unificação

A inferência usando clausulas de Horn  é chamada de Resolução que é um princípio similar de transitividade da álgebra:

Transitividade: Se a = b, b = c ⇒ a = c

## Resolução

Se  *h* é cabeçalho de um Cláusula de Horn e é verdadeiro no corpo de outra cláusula de Horn, então podemos resolver esta última com os termos de *h.*

h ← t1, t2

t ← t3, h, t4

Então:

t ← t3, t1, t2, t4

Exemplo: 

falaLingua(Marie, francês)

falaLingua(Giovanni, italiano)

falaLingua(Pièrre, francês)

falaLingua(Noel, francês)

falaLingua(Lana, português)

podemConversar(X, Y) ← falaLingua(X,L),   falaLingua(Y,L), X ≠ Y

Assim, podemos deduzir que a partir de Marie:

podemConversar(Marie, Y) ← falaLingua(Marie,francês),   falaLingua(Y,francês), Marie ≠ Y

com associação de variáveis X = Marie e L = francês.

## Unificação

Unificação é o processo de pattern matching que determina quais instâncias podem ser usadas para que a cláusula seja verdadeira.

No exemplo anterior, só é possível 2 situações para L = francês

Y = Pièrre ou Y = Noel

# Inferência de Base de conhecimento

Dada a Base de Conhecimento BC (Knowledge Base KB) ⇒ Conjuntos de regras 

Este conjunto de regras é o conhecimento de especialistas em um assunto.

Exemplo: Padrões de comportamento, regras de negócio

Queremos saber se a afirmação ou frase $\alpha$ é verdadeira dada a BC. Outra forma de usar este contexto é te afirmações parciais $\alpha X \gamma$  e queremos descobrir o valor de X.  

Prolog

[https://en.wikipedia.org/wiki/Prolog_syntax_and_semantics](https://en.wikipedia.org/wiki/Prolog_syntax_and_semantics)

[https://rodrigorgs.github.io/aulas/mata56/](https://rodrigorgs.github.io/aulas/mata56/)

[https://github.com/rodrigorgs/mata56-20162](https://github.com/rodrigorgs/mata56-20162)

Recursão

[https://github.com/rodrigorgs/mata56-20162/blob/gh-pages/aula06-prolog-listas.md](https://github.com/rodrigorgs/mata56-20162/blob/gh-pages/aula06-prolog-listas.md)

[https://www.youtube.com/watch?v=hEOVcLAPRG8](https://www.youtube.com/watch?v=hEOVcLAPRG8)

[https://www.slideserve.com/olaf/horn-clauses-and-unification](https://www.slideserve.com/olaf/horn-clauses-and-unification)