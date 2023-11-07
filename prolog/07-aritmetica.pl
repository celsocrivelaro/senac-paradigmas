populacao(eua, 203).
populacao(india, 548).
populacao(china, 800).
populacao(brasil, 108).

area(eua, 8).
area(india, 3).
area(china, 10).
area(brasil, 8).

dens(PAIS, DENSIDADE) :-
    populacao(PAIS, P),
    area(PAIS, A),
    DENSIDADE is P/A. % IS => Faz a conta

% fatorial
fatorial(0, 1). %  Fato
% Regra
fatorial(N, Resultado) :- 
  N > 0,
  M is N - 1,
  fatorial(M, Parcial),
  Resultado is N * Parcial.