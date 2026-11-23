% Sistema especialista de diagnóstico: dedução por encadeamento para trás.
%
% A base de conhecimento tem fatos (sintomas observados) e regras em dois
% níveis: sintomas -> diagnóstico -> recomendação. A pergunta parte da
% conclusão (recomendacao) e o Prolog procura, regra a regra, os fatos que a
% sustentam.

% Fatos: sintomas observados em cada paciente.
sintoma(ana, febre).
sintoma(ana, dor_de_cabeca).
sintoma(ana, fadiga).

sintoma(bruno, febre).
sintoma(bruno, fadiga).
sintoma(bruno, manchas_na_pele).

sintoma(carla, tosse).

% Regras de diagnóstico: cada uma vale para o MESMO paciente P em todas as
% condições. Uma regra escrita com sintoma(_, febre) aceitaria a febre de
% qualquer paciente.
diagnostico(P, gripe) :-
    sintoma(P, febre),
    sintoma(P, dor_de_cabeca).
diagnostico(P, dengue) :-
    sintoma(P, febre),
    sintoma(P, fadiga),
    sintoma(P, manchas_na_pele).

% Regras de recomendação: dependem de um diagnóstico, que por sua vez é
% deduzido. A cadeia de dedução tem dois passos.
recomendacao(P, hidratacao_e_repouso) :-
    diagnostico(P, gripe).
recomendacao(P, procurar_atendimento) :-
    diagnostico(P, dengue).

% ?- diagnostico(ana, D).
% D = gripe ;
% false.
% ?- recomendacao(bruno, R).
% R = procurar_atendimento.
% ?- diagnostico(P, dengue).
% P = bruno ;
% false.
%
% Mundo fechado: carla tem tosse, mas nenhuma regra conclui algo a partir de
% tosse. A resposta false significa "não se deduz da base", não "carla está
% saudável".
% ?- diagnostico(carla, D).
% false.
%
% Para ver a busca regra a regra:
% ?- trace, recomendacao(bruno, R).
