mae(maria, joana).
mae(joana, luis).
mae(cleia, otavio).
pai(joao, joana).
pai(orozimbo, otavio).
pai(otavio, luis).
pai(serafim, orozimbo).
irmao(orozimbo, manuel).

% X = avo
% Y = neto(a)
avo_masculino(X,Y) :- (mae(W,Y) ; pai(W,Y)), pai(X,W).
bisavo_masculino(X,Y) :- avo_masculino(W,Y), pai(X,W).

% Posso ter regras recursivas
% As regras pode ser repetidas, uma delas precisa ser critério de parada
ancestral(X, Y) :- mae(X, Y); pai(X, Y). % * ";" para "ou". => Criterio de parada
ancestral(X, Y) :- (mae(X, Z); pai(X, Z)), ancestral(Z, Y). % "," para "e" => Regra recursiva

/*
?- ancestral(maria, luis).
true .

?- ancestral(X, luis).
X = joana .
*/