% Base de Conhecimento
gosta_de(jose, maria).
gosta_de(jose, vanessa).
gosta_de(maria, jose).
gosta_de(maria, vinicius).
gosta_de(vanessa, maria).
gosta_de(vanessa, vinicius).
gosta_de(vinicius, vanessa).

% Regras
amizade(X,Y) :- gosta_de(X, Y), gosta_de(Y, X).

% consultar
% amizade(maria,jose).
% amizade(maria,vinicius).
% amizade(vanessa,Y).
% amizade(X,Y).