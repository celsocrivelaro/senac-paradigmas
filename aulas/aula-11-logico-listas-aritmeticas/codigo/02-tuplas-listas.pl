%% TUPLAS
% executar
(1, 2, 3) = (1, 2, 3).
% true
(1, 2, 3) = (1, 2, 3, 4).
% false
(A, B, C) = (1, 2, 3). 
% Unificação
% A = 1, B = 2, C = 3
(A, 1, 3) = (2, B, C).
% Unificação
% A = 2, B = 1, C = 3
(A, 1, 3) = (2, A, C).  
% Unificação falha
% false

%% LISTAS
% executar
[1, 2, 3] = [1, 2, 3].
% true
[_, 2, 3] = [1, 2, 3].
% true
[1, 2, 3] = [1, 2, 3, 4].
% false
(A, B, C) = [1, 2, 3].
% Unificação
% A = 1
% B = 2

[1, 2, 3, 4] = [Head|Tail].
% Head = 1,
% Tail = [2, 3, 4].

% Podemos testar estruturas complexas
[1, 2, 3, 4] = [_|[Head|_]].
% Head = 2.

% Operações com listas
% Concatenação de 2 listas: C(L1, L2, L), sendo L a lista de resultado
concatenar([],L,L).
concatenar([H|[]], Y, [H|Y]).
concatenar([H|T], Y, [H|Z]) :- concatenar(T, Y, Z).

% Checa se um elemento X pertence a uma lista L
pertence(X, [X|_]).
pertence(X, [_ | Y]) :- pertence(X, Y).

% Adicionar um prefixo L1 à lista L: prefixo(L1, L)
prefixo(X, Z) :- concatena(X, Y, Z).
% Adicionar um sufixo L1 à lista L: sufixo(L1, L)
sufixo(Y, Z) :- concatena(X, Y, Z).
