%% TUPLAS
% executar
(1, 2, 3) = (1, 2, 3).  => true
(1, 2, 3) = (1, 2, 3, 4).  => false
(A, B, C) = (1, 2, 3).  => Unificação
(A, 1, 3) = (2, B, C).  => Unificação
A = 2
B = 1
C = 3
(A, 1, 3) = (2, A, C).  => Unificação falha

%% LISTAS
% executar
[1, 2, 3] = [1, 2, 3].  => true
[_, 2, 3] = [1, 2, 3].  => true
[1, 2, 3] = [1, 2, 3, 4].  => false
(A, B, C) = [1, 2, 3].  => Unificação
A = 1
B = 2

[1, 2, 3, 4] = [Head|Tail].
% Head = 1,
% Tail = [2, 3, 4].

% Podemos testar estruturas complexas
[1, 2, 3, 4] = [_|[Head|_]].
% Head = 2.
