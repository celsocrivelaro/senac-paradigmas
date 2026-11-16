% Módulos importados:
%   clpfd: Constraint Logic Programming over Finite Domains. Restrições sobre
%          números inteiros: #=, #\=, #<, #>, #=<, #>=, in, ins, all_distinct, label.

:- use_module(library(clpfd)).

% Futoshiki 4x4: enunciado em 02-futoshiki.md.
% A grade é uma lista de 16 casas, linha por linha.

futoshiki(Grade) :-
    Grade = [A11, A12, A13, A14,
             A21, A22, A23, A24,
             A31, A32, A33, A34,
             A41, A42, A43, A44],

    % 1. domínio das casas

    % 2. linhas e colunas sem repetição

    % 3. desigualdades

    % 4. valores concretos (label)
    true.

% Imprime a grade em 4 linhas de 4 casas (já pronto, não precisa alterar).
mostrar([]).
mostrar([A, B, C, D | Resto]) :-
    format("~w ~w ~w ~w~n", [A, B, C, D]),
    mostrar(Resto).

/** Consultas
?- Grade = [_, _, _, _,
            _, 4, _, _,
            _, _, _, _,
            4, _, _, _],
   futoshiki(Grade), mostrar(Grade).
% Depois de cada resposta, digite ; para pedir a próxima.
*/
