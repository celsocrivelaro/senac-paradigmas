% Problema do caixaeiro viajante

% member(X, L) verifica se X pertence a lista L
% \+ negador lógico. Assim, \+ member(X, L) verifica se X is not in L

%%%% Grafo Simples

conectado(a, b).
conectado(b, c).
conectado(c, d).
conectado(b, e).

caminho(X, Y, [X, Y]) :- conectado(X, Y).
caminho(X, Y, [X|T]) :-
    conectado(X, Z),
    caminho(Z, Y, T),
    \+ member(X, T).

?- caminho(a, e, Rota).
Rota = [a, b, e].

%%%% Rota de linhas do Metrô

ligacao(linha1, estacaoA, estacaoB).
ligacao(linha1, estacaoB, estacaoC).
ligacao(linha2, estacaoC, estacaoD).

rota(Origem, Destino, [Origem, Destino]) :-
    ligacao(_, Origem, Destino).
rota(Origem, Destino, [Origem|Caminho]) :-
    ligacao(_, Origem, Inter),
    rota(Inter, Destino, Caminho),
    \+ member(Origem, Caminho).

?- rota(estacaoA, estacaoD, Caminho).
Caminho = [estacaoA, estacaoB, estacaoC, estacaoD]
