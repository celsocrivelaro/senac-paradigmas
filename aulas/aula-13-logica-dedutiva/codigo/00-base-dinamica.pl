% Base de conhecimento dinâmica: dynamic, assertz, asserta, retract,
% retractall e a negação por falha (\+).
%
% Cenário: a fila de espera de um pronto-socorro. Cada fato na_fila(P) diz
% que o paciente P está esperando atendimento. A fila muda enquanto o
% programa roda: pacientes chegam, são chamados e a fila é esvaziada.
%
% Os exemplos de cada seção podem ser digitados um a um no interpretador,
% na ordem. O predicado demonstracao/0, no fim do arquivo, executa todos
% eles em sequência.

% ------------------------------------------------------------------
% 1. dynamic
% ------------------------------------------------------------------

% A diretiva dynamic declara que o predicado é criado e alterado em tempo
% de execução. Por padrão, os predicados escritos no arquivo são estáticos:
% fazem parte fixa do programa e não podem ganhar nem perder cláusulas.
%
% O arquivo não traz nenhum fato na_fila(...). Sem a diretiva, a consulta
% na_fila(X) daria erro de predicado desconhecido. Com ela, o predicado
% existe mesmo vazio, e a consulta simplesmente falha:
%   ?- na_fila(X).
%   false.
%
% O /1 é a aridade: o número de argumentos do predicado.
:- dynamic na_fila/1.

% ------------------------------------------------------------------
% 2. assertz e asserta
% ------------------------------------------------------------------

% assertz(Clausula) acrescenta a cláusula no FIM do predicado.
% asserta(Clausula) acrescenta a cláusula no INÍCIO do predicado.
% Depois de acrescentado, o fato vale como se estivesse escrito no arquivo.
%
% A posição importa porque o Prolog tenta as cláusulas de cima para baixo:
% o fato que está no início é encontrado primeiro. Na fila, assertz é a
% chegada comum (entra no fim) e asserta é a chegada urgente (fura a fila).
%   ?- assertz(na_fila(ana)), assertz(na_fila(bruno)), asserta(na_fila(davi)).
%   ?- na_fila(X).
%   X = davi ; X = ana ; X = bruno.

% ------------------------------------------------------------------
% 3. retract e retractall
% ------------------------------------------------------------------

% retract(Clausula) remove a PRIMEIRA cláusula que unifica com o argumento.
% Com variável, retract(na_fila(P)) remove o primeiro da fila e liga P a
% ele: é o "chamar o próximo".
%   ?- retract(na_fila(P)).
%   P = davi.
%
% retractall(Clausula) remove TODAS as cláusulas que unificam com o
% argumento, e é provado mesmo que não haja nenhuma. retractall(na_fila(_))
% esvazia a fila.
%   ?- retractall(na_fila(_)).
%   ?- na_fila(X).
%   false.

% ------------------------------------------------------------------
% 4. \+ (negação por falha)
% ------------------------------------------------------------------

% \+ Objetivo é provado quando o Prolog NÃO consegue provar o objetivo, e
% falha quando consegue. Lê-se "não é possível provar que...".
%
% Vale a hipótese do mundo fechado: o que não está na base conta como
% falso. \+ na_fila(carla) não afirma nada sobre carla no mundo; afirma que
% a base não registra carla na fila.
%
% O \+ nunca liga variáveis. \+ na_fila(P), com P livre, pergunta "não
% existe NENHUM paciente na fila?", ou seja, se a fila está vazia.

% Entra na fila só quem ainda não está nela.
chegar(Paciente) :-
    \+ na_fila(Paciente),
    assertz(na_fila(Paciente)).

% A fila está vazia quando não se prova na_fila de ninguém.
fila_vazia :-
    \+ na_fila(_).

%   ?- chegar(ana), chegar(ana).
%   false.        (a segunda chegada falha: ana já está na fila)
%   ?- fila_vazia.
%   false.

% ------------------------------------------------------------------
% 5. Efeito colateral
% ------------------------------------------------------------------

% assertz e retract alteram a base de verdade: a alteração permanece mesmo
% quando o Prolog volta atrás por retrocesso. Ligações de variável se
% desfazem no retrocesso; fatos acrescentados ou removidos, não. Por isso a
% resposta de uma consulta passa a depender do que foi executado antes, e
% um programa que reutiliza a base precisa limpá-la com retractall antes de
% começar de novo.

% ------------------------------------------------------------------
% Demonstração
% ------------------------------------------------------------------

% findall(X, Objetivo, Lista) reúne numa lista todos os X que tornam o
% objetivo verdadeiro; serve aqui só para imprimir a fila inteira.
mostrar_fila :-
    findall(P, na_fila(P), Fila),
    format("    fila: ~w~n", [Fila]).

demonstracao :-
    format("1. fila recém-criada~n"),
    mostrar_fila,

    format("2. ana e bruno chegam (assertz); davi chega urgente (asserta)~n"),
    assertz(na_fila(ana)),
    assertz(na_fila(bruno)),
    asserta(na_fila(davi)),
    mostrar_fila,

    format("3. chamar o próximo (retract)~n"),
    retract(na_fila(Chamado)),
    format("    chamado: ~w~n", [Chamado]),
    mostrar_fila,

    format("4. carla chega duas vezes (chegar/1 usa \\+)~n"),
    chegar(carla),
    (   chegar(carla)
    ->  format("    segunda chegada aceita~n")
    ;   format("    segunda chegada recusada: carla já está na fila~n")
    ),
    mostrar_fila,

    format("5. esvaziar a fila (retractall)~n"),
    retractall(na_fila(_)),
    mostrar_fila,
    (   fila_vazia
    ->  format("    fila_vazia é verdadeiro~n")
    ;   format("    fila_vazia é falso~n")
    ).

% ?- demonstracao.
% 1. fila recém-criada
%     fila: []
% 2. ana e bruno chegam (assertz); davi chega urgente (asserta)
%     fila: [davi,ana,bruno]
% 3. chamar o próximo (retract)
%     chamado: davi
%     fila: [ana,bruno]
% 4. carla chega duas vezes (chegar/1 usa \+)
%     segunda chegada recusada: carla já está na fila
%     fila: [ana,bruno,carla]
% 5. esvaziar a fila (retractall)
%     fila: []
%     fila_vazia é verdadeiro
% true.
