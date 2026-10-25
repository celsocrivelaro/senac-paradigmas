# Prolog: Listas e Pattern Matching

Tema: Lógico

Em diversas linguagens de programação utilizamos listas e no Prolog não é diferente: [1, 2, 4, 5]

## Unificação

Em listas, quando tentamos unificar, o Prolog tenta fazer os 2 lados serem iguais. Assim, ele compara quantidade e elementos e faz a associação:

```prolog
?- [1, 2, 3] = [2, 3, 4].
false.

?- [1, 2, 3] = [1, 2, 3].
true.

?- [1, 2, 3] = [X, Y, Z].
X = 1,
Y = 2,
Z = 3.

?- [1, X, 3] = [Y, 5, Z].
X = 5,
Y = 1,
Z = 3.
```

Nos 2 últimos exemplo, podemos fazer que unificação ocorre dos 2 lados, ou seja, não é uma operação de associação como é nas linguagens imperativas ou funcionais.

## Cabeçalho e Cauda (Head e Tail)

Uma operação muito comum em código funcional para trabalhar com recursão é a operação para pegar o elemento cabeçalho (Head) e a lista cauda (Tail) de uma lista:

```prolog
?- [x, y, z] = [Cabecalho|Cauda].
Cabecalho = x,
Cauda = [y, z].

?- [z] = [Cabecalho|Cauda].
Cabecalho = z,
Cauda = [].

?- [] = [Cabecalho|Cauda].
false.
```

Caso seja o último elemento, Cauda virá vazio.

## Pattern Matching

Outra operação comum com listas é fazer pattern matching. 

Com um valor fixo:

```prolog
?- [x, y, z] = [x|Cauda].
Cauda = [y, z].

?- [w, y, z] = [x|Cauda].
false.
```

Pegando o segundo elemento:

```prolog
?- [x, y, z] = [x|[Cabecalho|Cauda]].
Cabecalho = y,
Cauda = [z].
```

Temos o operador "_" que significa "qualquer coisa":

```prolog
?- [w, x, y, z] = [_, _|[Cabecalho|_]].
Cabecalho = y.
```

## Funções comuns

Concatenação de listas:

```prolog
concatena([], X, X). % caso base da recursao. 3o argumento ou O segundo X é o resultado.
concatena([Cabecalho|Cauda], Y, [Cabecalho|Z]) :- concatena(Cauda, Y, Z). % regra recursiva
```

Exemplo

```prolog
?- concatena([1,2,3], [a,b,c], L).
L = [1, 2, 3, a, b, c].
```

Vendo a regra sendo executada:

```prolog
?- trace(concatena/3)
|    .
%         concatena/3: [all]
true.

?- concatena([1, 2,3],[a,b,c],L).
 T Call: concatena([1, 2, 3], [a, b, c], _45534)
 T Call: concatena([2, 3], [a, b, c], _46464)
 T Call: concatena([3], [a, b, c], _47088)
 T Call: concatena([], [a, b, c], _47712)
 T Exit: concatena([], [a, b, c], [a, b, c])
 T Exit: concatena([3], [a, b, c], [3, a, b, c])
 T Exit: concatena([2, 3], [a, b, c], [2, 3, a, b, c])
 T Exit: concatena([1, 2, 3], [a, b, c], [1, 2, 3, a, b, c])
L = [1, 2, 3, a, b, c].
```

Pertencimento:

```prolog
pertence(X, [X|_]).
pertence(X, [_ | Y]) :- pertence(X, Y).
```

Exemplo:

```prolog
?- trace(pertence/2).
%         pertence/2: [all]
true.

?- pertence(banana,[pera, uva, maca, banana]).
 T Call: pertence(banana, [pera, uva, maca, banana])
 T Call: pertence(banana, [uva, maca, banana])
 T Call: pertence(banana, [maca, banana])
 T Call: pertence(banana, [banana])
 T Exit: pertence(banana, [banana])
 T Exit: pertence(banana, [maca, banana])
 T Exit: pertence(banana, [uva, maca, banana])
 T Exit: pertence(banana, [pera, uva, maca, banana])
true ;
```