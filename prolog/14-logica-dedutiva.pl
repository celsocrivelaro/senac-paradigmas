% Fatos
sintoma(ana, febre).
sintoma(ana, dor_de_cabeca).
sintoma(ana, fadiga).

doenca(gripe) :- sintoma(_, febre), sintoma(_, dor_de_cabeca).
doenca(dengue) :- sintoma(_, febre), sintoma(_, fadiga), sintoma(_, manchas_na_pele).

% Regra para diagnóstico
diagnostico(Pessoa, Doenca) :-
    sintoma(Pessoa, febre),
    (
        (sintoma(Pessoa, dor_de_cabeca), Doenca = gripe);
        (sintoma(Pessoa, fadiga), sintoma(Pessoa, manchas_na_pele), Doenca = dengue)
    ).

% ?- diagnostico(ana, D).
% D = gripe.

%%%%%%% ---------------

% Fatos sobre cidades e conexões
rota(sao_paulo, rio_de_janeiro, 430).
rota(rio_de_janeiro, belo_horizonte, 440).
rota(sao_paulo, curitiba, 410).
rota(curitiba, porto_alegre, 710).

% As rotas são bidirecionais
conectado(X, Y, D) :- rota(X, Y, D).
conectado(X, Y, D) :- rota(Y, X, D).

% Regra recursiva para encontrar caminhos
caminho(Origem, Destino, [Origem, Destino], D) :-
    conectado(Origem, Destino, D).

caminho(Origem, Destino, [Origem|Resto], Distancia) :-
    conectado(Origem, Intermediario, D1),
    caminho(Intermediario, Destino, Resto, D2),
    Distancia is D1 + D2.

% Consulta exemplo:
% ?- caminho(sao_paulo, porto_alegre, C, D).
% C = [sao_paulo, curitiba, porto_alegre], D = 1120.
