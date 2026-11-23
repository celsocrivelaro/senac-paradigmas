% Dedução por encadeamento para frente.
%
% As mesmas regras de 02-encadeamento-para-tras.pl, agora guardadas como dados:
% regra(Conclusao, Premissas). O motor parte dos fatos conhecidos, dispara
% toda regra cujas premissas já são conhecidas e acrescenta a conclusão à
% base, até que nenhuma regra produza fato novo (ponto fixo).
%
% O motor de inferência do Prolog faz encadeamento para trás; este arquivo
% escreve à mão um motor para frente, para comparar as duas estratégias.

% A diretiva dynamic declara que conhecido/1 cresce em tempo de execução:
% além dos fatos iniciais escritos abaixo, cada regra disparada acrescenta
% sua conclusão com assertz. Sem a diretiva, o predicado seria estático e
% o assertz daria erro de permissão.
:- dynamic conhecido/1.

% Fatos iniciais: sintomas de um paciente só.
conhecido(febre).
conhecido(fadiga).
conhecido(manchas_na_pele).

% Regras como dados.
regra(gripe, [febre, dor_de_cabeca]).
regra(dengue, [febre, fadiga, manchas_na_pele]).
regra(hidratacao_e_repouso, [gripe]).
regra(procurar_atendimento, [dengue]).

% Todas as premissas da lista são conhecidas.
todas_conhecidas([]).
todas_conhecidas([Premissa | Resto]) :-
    conhecido(Premissa),
    todas_conhecidas(Resto).

% Dispara uma regra que produz fato novo.
disparar :-
    regra(Conclusao, Premissas),
    \+ conhecido(Conclusao),
    todas_conhecidas(Premissas),
    assertz(conhecido(Conclusao)),
    format("deduzido: ~w (de ~w)~n", [Conclusao, Premissas]).

% Repete até o ponto fixo.
encadear :-
    disparar,
    encadear.
encadear :-
    \+ disparar,
    format("ponto fixo: nenhuma regra produz fato novo~n").

% ?- encadear.
% deduzido: dengue (de [febre,fadiga,manchas_na_pele])
% deduzido: procurar_atendimento (de [dengue])
% ponto fixo: nenhuma regra produz fato novo
% true .
% ?- conhecido(X).
% X = febre ; X = fadiga ; X = manchas_na_pele ; X = dengue ;
% X = procurar_atendimento.
