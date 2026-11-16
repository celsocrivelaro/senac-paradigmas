:- use_module(library(clpfd)).

% Calendário de provas: enunciado em 03-calendario-provas.md.
% Cada variável guarda o dia (1..K) da prova da disciplina.
% Ordem da lista: [LFA, PAR, IA, DAD, ES, CAL]

% Parte 1
calendario(K, [LFA, PAR, IA, DAD, ES, CAL]) :-
    true.  % substituir pela modelagem

% Parte 3 (opcional)
% minimo_dias(K, Dias) :- ...

/** Consultas
?- calendario(6, Dias).
?- calendario(1, Dias).
?- calendario(2, Dias).
?- calendario(3, Dias).
?- minimo_dias(K, Dias).
*/
