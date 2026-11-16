% Módulos importados:
%   clpfd: Constraint Logic Programming over Finite Domains. Restrições sobre
%          números inteiros: #=, #\=, #<, #>, #=<, #>=, in, ins, all_distinct, label.
%   clpr:  Constraint Logic Programming over Reals. Restrições sobre números
%          reais, escritas entre chaves: { X + 1 = 5 }. (não usado neste arquivo)

:- use_module(library(clpfd)).
:- use_module(library(clpr)).

calc(Chickens, Cows) :- 
   Chickens + Cows #= 30,
   Chickens*2 + Cows*4 #= 74. 

calc2(G,C,P,N) :-
   G + G + G #= 30,
   G + C + C #= 20,
   C + P + P #= 13,
   G + C + P #= N.
