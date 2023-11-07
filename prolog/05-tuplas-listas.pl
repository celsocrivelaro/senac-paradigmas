%% TUPLAS
% executar
% (1, 2, 3) = (1, 2, 3).  => true
% (1, 2, 3) = (1, 2, 3, 4).  => false
% (A, B, C) = (1, 2, 3).  => Unificação

% (A, 1, 3) = (2, B, C).  => Unificação

%% LISTAS
% executar
% [1, 2, 3] = [1, 2, 3].  => true
% [1, 2, 3] = [1, 2, 3, 4].  => false
% (A, B, C) = [1, 2, 3].  => Unificação

% (A, 1, 3) = (2, B, C).  => Unificação
% (A, 1, 3) = (2, A, C).  => Unificação falha

% head / tail
% [1, 2, 3, 4]
% head = 1
% tail = [2, 3 4]

% [1, 2, 3, 4] = [Head|Tail].
% Head = 1,
% Tail = [2, 3, 4].

% [1, 2, 3, 4] = [_|[Head|_]].
% Head = 2.