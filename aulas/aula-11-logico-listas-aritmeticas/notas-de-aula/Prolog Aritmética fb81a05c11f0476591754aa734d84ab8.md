# Prolog: Aritmética

Tema: Lógico

Para cálculos, há fator interessante:

```prolog
?- X = 1+2.
X = 1+2.

?- X is 1+2.
X = 3.
```

O operador "=" é um operador de unificação ou matching, por isso a conta não é feita na primeira linha. Para forçar a operação, precisamos do operador "is" que instancia X com o valor correto.

### Operações com funções

Diferente do código imperativo que definimos o passo a passo do cálculo, no código lógico, devemos definir as regras e restrições.

Exemplo: Fatorial de N

- N deve ser maior que zero
- Fatorial de 0 é 1
- Fatorial de N = Fatorial (N-1) * N

```prolog
fatorial(0, 1). 
fatorial(N, Resultado) :- 
  N > 0,
  M is N - 1,
  fatorial(M, Parcial),
  Resultado is N * Parcial.
```

Exemplo:

```prolog
?- fatorial(5, R).
R = 120 ;
false.
```

## Predicados definidos na linguagem

Cada dialeto do Prolog vai pré-definir seus predicados na Standard Library. No SWI Prolog, os predicados de Aritmética estão em: 

[https://www.swi-prolog.org/pldoc/man?section=arith](https://www.swi-prolog.org/pldoc/man?section=arith)

Assim, podemos usar coisas como "between":

```prolog
% between
bla(0, 1). 
bla(X, R) :- 
  between(0, 10, X),
  R is X + 12.
bla(X, R) :- 
  X >= 10 ,
  R is X + 25.
```

Exemplos:

```prolog
?- bla(5,R).
R = 17 .

?- bla(20,R).
R = 45.
```