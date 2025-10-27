% exemplo simples:
f(X,normal) :- X < 3.
f(X,alerta1) :- X <= 3, X < 6.
f(X,alerta2) :- X >= 6.

% Se rodar f(2,Y), vai retornar Y = normal e depois false no backtracking
% Pq ocorre? O prolog esta todas as regras. 
% Outra forma de ver é que as 3 regras são "OU"s
% Como fazer parar quando achar a primeira regra?

f(X,normal) :- X < 3, !.
f(X,alerta1) :- X <= 3, X < 6, !.
f(X,alerta2) :- X >= 6.

% O cut é "!" quando dá match na regra
% assim irá retornar apenas Y = normal

% podemos ver o passo a passo com o trace.
% ativar debug com "trace"
%
trace.
fat(0, 1) :- !.
fat(N, F) :- N1 is N - 1, fat(N1, F1), F is F1 * N.

% Exemplo com max(X,Y,Max)
%
max(X,Y,X) :- X >=Y, !.
max(X,Y,Y).
