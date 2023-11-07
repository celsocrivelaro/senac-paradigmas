concatenar([],L,L).
concatenar([H|[]], Y, [H|Y]).
concatenar([H|T], Y, [H|Z]) :- concatenar(T, Y, Z).

pertence(X, [X|_]).
pertence(X, [_ | Y]) :- pertence(X, Y).

prefixo(X, Z) :- concatena(X, Y, Z).
sufixo(Y, Z) :- concatena(X, Y, Z).