:- use_module(library(clpfd)).
:- use_module(library(clpr)).

calc(Chickens, Cows) :- 
   Chickens + Cows #= 30, % Restricao aritmetica: http://www.gprolog.org/manual/gprolog.html#sec315
   Chickens*2 + Cows*4 #= 74. 

calc2(G,C,P,N) :-
   G + G + G #= 30,
   G + C + C #= 20,
   C + P + P #= 13,
   G + C + P #= N.
