% dada uma lista L de números, como calculo o maximo N?
% L = [0, 10, 3, -2], N = 10
% max(N,L). 

max(N,[N|[]]).
max(N,[X|Cauda]) :- max(M,Cauda), M >= X, N is M.
max(N,[X|Cauda]) :- max(M,Cauda), M < X, N is X.
