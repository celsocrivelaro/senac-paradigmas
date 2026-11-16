:- use_module(library(clpfd)).   % restrições sobre inteiros: #=, #\=, #<, #>, in, ins, label
:- use_module(library(clpr)).    % restrições sobre reais: { ... }

% 1. Aritmética comum (is) exige que o lado direito já tenha valor.
/*
?- X is 4 + 1.
X = 5.

?- 5 is Y + 1.
ERROR: Arguments are not sufficiently instantiated
*/

% 2. Restrição (#=) funciona nos dois sentidos.
/*
?- X #= 4 + 1.
X = 5.

?- 5 #= Y + 1.
Y = 4.
*/

% 3. Restrição sem valor definido: o Prolog guarda o domínio possível.
/*
?- X #> 1.
X in 2..sup.

?- X #> 1, X #< 5.
X in 2..4.

?- X #> 1, X #< 5, X #\= 3.
X in 2\/4.          % 2 ou 4: o 3 saiu do domínio
*/

% 4. Domínio de várias variáveis (ins) e busca de valores concretos (label).
/*
?- X in 1..3, label([X]).
X = 1 ;
X = 2 ;
X = 3.

?- [X, Y] ins 1..2, X #\= Y, label([X, Y]).
X = 1, Y = 2 ;
X = 2, Y = 1.

?- [X, Y, Z] ins 1..2, X #\= Y, Y #\= Z, X #\= Z, label([X, Y, Z]).
false.
*/

% 5. Problema com inteiros: o pai tem o triplo da idade do filho e,
%    daqui a 10 anos, terá o dobro.

% Sem domínio: o Prolog só guarda as restrições, não chega aos números.
idades_sem_dominio(Pai, Filho) :-
    Pai #= 3 * Filho,
    Pai + 10 #= 2 * (Filho + 10).
/*
?- idades_sem_dominio(Pai, Filho).
Pai#=2*Filho+10,
3*Filho#=Pai.
*/

% Com domínio (idades entre 0 e 120): a propagação reduz até sobrar um valor.
idades(Pai, Filho) :-
    [Pai, Filho] ins 0..120,
    Pai #= 3 * Filho,
    Pai + 10 #= 2 * (Filho + 10).
/*
?- idades(Pai, Filho).
Pai = 30,
Filho = 10.
*/

% 6. clpfd trabalha só com inteiros; clpr trabalha com reais.
/*
?- X * 2 #= 5.
false.

?- { X * 2 = 5 }.
X = 2.5.

?- { X + 1 = 5 }.
X = 4.0.

?- { X > 1, X < 5 }.
{X>1.0, X<5.0}.     % sem valor único: devolve o intervalo
*/

% 7. Conversão de temperatura nos dois sentidos com uma única regra.
celsius_fahrenheit(C, F) :-
    { F = C * 9 / 5 + 32 }.
/*
?- celsius_fahrenheit(100, F).
F = 212.0.

?- celsius_fahrenheit(C, 212).
C = 100.0.
*/
