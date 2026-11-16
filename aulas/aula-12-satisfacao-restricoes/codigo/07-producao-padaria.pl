:- use_module(library(clpfd)).

% Planejamento de produção de uma padaria.
%
% A padaria produz três itens, em lotes. Cada lote consome farinha,
% ovos e horas de forno, e dá um lucro:
%
%   | Item  | Farinha (kg) | Ovos | Forno (h) | Lucro (R$) |
%   |-------|--------------|------|-----------|------------|
%   | Pão   | 2            | 0    | 1         | 30         |
%   | Bolo  | 1            | 4    | 2         | 50         |
%   | Torta | 1            | 2    | 3         | 60         |
%
% Estoque do dia: 20 kg de farinha, 24 ovos, 24 horas de forno.
% Encomendas: pelo menos 2 bolos e pelo menos 1 torta.
% Venda: no máximo 8 lotes de pão (o resto não seria vendido).
%
% Pergunta: quantos lotes de cada item produzir para ter o maior lucro?
%
% O programa não diz COMO procurar a resposta. Ele só declara as
% restrições, em blocos, e pede ao Prolog o melhor valor.

% Passo 1: as restrições, sem o objetivo.
producao(Pao, Bolo, Torta) :-
    % 1a. domínio: quantidade de lotes de cada item
    [Pao, Bolo, Torta] ins 0..20,

    % 1b. recursos: o consumo não passa do estoque
    2*Pao + 1*Bolo + 1*Torta #=< 20,      % farinha
    0*Pao + 4*Bolo + 2*Torta #=< 24,      % ovos
    1*Pao + 2*Bolo + 3*Torta #=< 24,      % forno

    % 1c. encomendas e venda
    Bolo #>= 2,
    Torta #>= 1,
    Pao #=< 8.

% Passo 2: o lucro de uma produção.
lucro(Pao, Bolo, Torta, Lucro) :-
    Lucro #= 30*Pao + 50*Bolo + 60*Torta.

% Passo 3: a melhor produção.
% labeling([max(Lucro)], ...) devolve primeiro a solução de maior lucro.
% O corte (!) fica só com essa primeira solução.
melhor_producao(Pao, Bolo, Torta, Lucro) :-
    producao(Pao, Bolo, Torta),
    lucro(Pao, Bolo, Torta, Lucro),
    labeling([max(Lucro)], [Pao, Bolo, Torta]),
    !.

% Passo 4: relatório com o que sobra de cada recurso.
relatorio :-
    melhor_producao(Pao, Bolo, Torta, Lucro),
    Farinha is 20 - (2*Pao + Bolo + Torta),
    Ovos is 24 - (4*Bolo + 2*Torta),
    Forno is 24 - (Pao + 2*Bolo + 3*Torta),
    format("Pão: ~w lotes, Bolo: ~w lotes, Torta: ~w lotes~n", [Pao, Bolo, Torta]),
    format("Lucro: R$ ~w~n", [Lucro]),
    format("Sobra: ~w kg de farinha, ~w ovos, ~w h de forno~n", [Farinha, Ovos, Forno]).

/** Consultas

% Só as restrições: a propagação já cortou os domínios.
% Bolo começou em 0..20 e caiu para 2..5 (4 ovos por bolo, 24 ovos);
% Torta caiu para 1..6.
?- producao(Pao, Bolo, Torta).
Pao in 0..8,
Pao+2*Bolo+3*Torta#=<24,
2*Pao+Bolo+Torta#=<20,
Bolo in 2..5,
4*Bolo+2*Torta#=<24,
Torta in 1..6.

% Uma produção qualquer que respeita tudo (a primeira encontrada).
?- producao(Pao, Bolo, Torta), label([Pao, Bolo, Torta]).
Pao = 0,
Bolo = 2,
Torta = 1 ;
...

% Quantas produções respeitam as restrições.
?- aggregate_all(count, (producao(P, B, T), label([P, B, T])), Quantas).
Quantas = 123.

% A de maior lucro entre as 123.
?- melhor_producao(Pao, Bolo, Torta, Lucro).
Pao = 6,
Bolo = 3,
Torta = 4,
Lucro = 570.

?- relatorio.
Pão: 6 lotes, Bolo: 3 lotes, Torta: 4 lotes
Lucro: R$ 570
Sobra: 1 kg de farinha, 4 ovos, 0 h de forno
true.
*/
