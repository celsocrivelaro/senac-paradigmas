% Agente lógico: triagem que faz perguntas.
%
% O arquivo tem duas partes separadas:
%   - o AMBIENTE, um paciente simulado: guarda o que o paciente sente e só é
%     acessado pelo predicado responder/2;
%   - o AGENTE, que guarda numa base de conhecimento própria as respostas já
%     obtidas e decide, por regras, a próxima pergunta ou o diagnóstico.
%
% O ciclo do agente segue o agente baseado em conhecimento de Russell e Norvig:
% perguntar à base qual ação tomar (ASK), agir, perceber a resposta,
% informar a base (TELL). O ciclo começa pelo ASK porque, no início da
% consulta, ainda não há percepção.

% ------------------------------------------------------------------
% AMBIENTE: pacientes simulados
% ------------------------------------------------------------------

% O agente não consulta sente/2 diretamente: só conhece o que perguntou.
sente(ana, febre).
sente(ana, dor_de_cabeca).
sente(ana, fadiga).

sente(bruno, febre).
sente(bruno, fadiga).
sente(bruno, manchas_na_pele).

sente(carla, tosse).

% Paciente em atendimento.
% A diretiva dynamic declara que atendendo/1 é criado em tempo de execução:
% o arquivo não traz nenhum fato atendendo(...), e atender/1 o inclui com
% assertz e o remove com retractall a cada consulta. Sem a diretiva, o
% predicado seria estático (parte fixa do programa) e não poderia ser
% alterado.
:- dynamic atendendo/1.

% A percepção é a resposta do paciente à pergunta.
responder(Sintoma, sim) :-
    atendendo(Paciente),
    sente(Paciente, Sintoma).
responder(Sintoma, nao) :-
    atendendo(Paciente),
    \+ sente(Paciente, Sintoma).

% ------------------------------------------------------------------
% AGENTE
% ------------------------------------------------------------------

% Conhecimento do domínio (fixo): cada doença e os sintomas que a confirmam.
% São as mesmas regras do sistema de diagnóstico, escritas como dados para
% que o agente possa escolher o que perguntar.
doenca(gripe, [febre, dor_de_cabeca]).
doenca(dengue, [febre, fadiga, manchas_na_pele]).

% Conhecimento do caso (muda a cada resposta).
% confirmado/1 e descartado/1 são criados em tempo de execução: começam sem
% nenhum fato e ganham um fato a cada resposta, pelo assertz de informar/2.
% A diretiva dynamic faz o predicado existir mesmo vazio, de modo que a
% consulta confirmado(febre) responde false em vez de dar erro de
% predicado desconhecido.
:- dynamic confirmado/1.
:- dynamic descartado/1.

% TELL: a resposta vira conhecimento.
informar(Sintoma, sim) :-
    assertz(confirmado(Sintoma)).
informar(Sintoma, nao) :-
    assertz(descartado(Sintoma)).

% Todos os sintomas da lista foram confirmados.
todos_confirmados([]).
todos_confirmados([Sintoma | Resto]) :-
    confirmado(Sintoma),
    todos_confirmados(Resto).

% Nenhum sintoma da lista foi descartado: a doença ainda é possível.
nenhum_descartado([]).
nenhum_descartado([Sintoma | Resto]) :-
    \+ descartado(Sintoma),
    nenhum_descartado(Resto).

% Primeiro sintoma da lista sobre o qual ainda não se sabe nada.
primeiro_desconhecido([Sintoma | _], Sintoma) :-
    \+ confirmado(Sintoma),
    \+ descartado(Sintoma).
primeiro_desconhecido([Sintoma | Resto], Desconhecido) :-
    confirmado(Sintoma),
    primeiro_desconhecido(Resto, Desconhecido).

% ASK: regras de ação. A ordem das cláusulas é a prioridade: a primeira regra
% cujas condições são deduzidas da base decide a ação.
melhor_acao(concluir(Doenca)) :-
    doenca(Doenca, Sintomas),
    todos_confirmados(Sintomas).
melhor_acao(perguntar(Sintoma)) :-
    doenca(_, Sintomas),
    nenhum_descartado(Sintomas),
    primeiro_desconhecido(Sintomas, Sintoma).
melhor_acao(concluir(sem_diagnostico)).

% Um passo do ciclo: ASK, depois agir.
ciclo(Passo) :-
    melhor_acao(Acao),
    format("passo ~w: ~w~n", [Passo, Acao]),
    agir(Acao, Passo).

% Concluir encerra a consulta.
agir(concluir(_), _).
% Perguntar gera uma percepção (a resposta), que é informada à base (TELL)
% antes do próximo passo.
agir(perguntar(Sintoma), Passo) :-
    responder(Sintoma, Resposta),
    format("        resposta: ~w~n", [Resposta]),
    informar(Sintoma, Resposta),
    Proximo is Passo + 1,
    ciclo(Proximo).

% Começa uma consulta com a base do caso vazia.
atender(Paciente) :-
    retractall(atendendo(_)),
    retractall(confirmado(_)),
    retractall(descartado(_)),
    assertz(atendendo(Paciente)),
    ciclo(1).

% ?- atender(bruno).
% passo 1: perguntar(febre)
%         resposta: sim
% passo 2: perguntar(dor_de_cabeca)
%         resposta: nao
% passo 3: perguntar(fadiga)
%         resposta: sim
% passo 4: perguntar(manchas_na_pele)
%         resposta: sim
% passo 5: concluir(dengue)
% true .
%
% ?- atender(ana).
% passo 1: perguntar(febre)
%         resposta: sim
% passo 2: perguntar(dor_de_cabeca)
%         resposta: sim
% passo 3: concluir(gripe)
% true .
%
% ?- atender(carla).
% passo 1: perguntar(febre)
%         resposta: nao
% passo 2: concluir(sem_diagnostico)
% true .
