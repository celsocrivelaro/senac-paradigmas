% Dedução com regra recursiva: existe caminho entre duas cidades?
%
% Provar caminho(Origem, Destino, Caminho, Distancia) é deduzir, a partir dos
% fatos de rota, que o destino é alcançável. A prova traz junto o caminho que
% a sustenta.

% Fatos sobre cidades e distâncias (km).
rota(sao_paulo, rio_de_janeiro, 430).
rota(rio_de_janeiro, belo_horizonte, 440).
rota(sao_paulo, curitiba, 410).
rota(curitiba, porto_alegre, 710).

% As rotas valem nos dois sentidos.
conectado(X, Y, D) :- rota(X, Y, D).
conectado(X, Y, D) :- rota(Y, X, D).

% Busca com lista de cidades já visitadas. Sem essa lista, a regra recursiva
% vai de sao_paulo ao rio_de_janeiro, segue a belo_horizonte, volta ao
% rio_de_janeiro pela rota inversa, e a busca em profundidade fica nesse
% ciclo até estourar a pilha.
buscar(Destino, Destino, _, [Destino], 0).
buscar(Atual, Destino, Visitadas, [Atual | Resto], Distancia) :-
    conectado(Atual, Proxima, D1),
    \+ member(Proxima, Visitadas),
    buscar(Proxima, Destino, [Proxima | Visitadas], Resto, D2),
    Distancia is D1 + D2.

caminho(Origem, Destino, Caminho, Distancia) :-
    buscar(Origem, Destino, [Origem], Caminho, Distancia).

% ?- caminho(sao_paulo, porto_alegre, C, D).
% C = [sao_paulo, curitiba, porto_alegre],
% D = 1120 ;
% false.
% ?- caminho(belo_horizonte, curitiba, C, D).
% C = [belo_horizonte, rio_de_janeiro, sao_paulo, curitiba],
% D = 1280 ;
% false.
