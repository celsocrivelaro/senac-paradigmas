% Agente lógico: triagem que faz perguntas a uma pessoa.
%
% Variação do agente de triagem em que o ambiente deixa de ser um paciente
% simulado: as perguntas aparecem no terminal e as respostas são digitadas
% por quem está usando o programa. O AGENTE é o mesmo: guarda numa base de
% conhecimento própria as respostas já obtidas e decide, por regras, a
% próxima pergunta ou o diagnóstico.
%
% O ciclo do agente segue o agente baseado em conhecimento de Russell e Norvig:
% perguntar à base qual ação tomar (ASK), agir, perceber a resposta,
% informar a base (TELL). O ciclo começa pelo ASK porque, no início da
% consulta, ainda não há percepção.
%
% Execução:
%   $ swipl 01.1-agente-triagem-interativo.pl
%   ?- atender.

% ------------------------------------------------------------------
% AMBIENTE: a pessoa no terminal
% ------------------------------------------------------------------

% A percepção é a resposta digitada à pergunta.
% format/2 escreve a pergunta; read_line_to_string/2 lê a linha digitada até o
% Enter, como string; atom_string/2 converte a string no átomo correspondente,
% para que a resposta possa ser comparada com os átomos sim e nao.
responder(Sintoma, Resposta) :-
    format("        sente ~w? (sim/nao) ", [Sintoma]),
    read_line_to_string(user_input, Texto),
    atom_string(Lido, Texto),
    validar(Sintoma, Lido, Resposta).

% Só sim e nao são percepções válidas. Qualquer outra resposta faz a pergunta
% ser repetida.
validar(_, sim, sim).
validar(_, nao, nao).
validar(Sintoma, Lido, Resposta) :-
    Lido \== sim,
    Lido \== nao,
    format("        responda sim ou nao~n"),
    responder(Sintoma, Resposta).

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
% \+ é a negação por falha: \+ descartado(Sintoma) é provado quando a base
% não registra o sintoma como descartado.
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
% Perguntar gera uma percepção (a resposta digitada), que é informada à base
% (TELL) antes do próximo passo.
agir(perguntar(Sintoma), Passo) :-
    responder(Sintoma, Resposta),
    informar(Sintoma, Resposta),
    Proximo is Passo + 1,
    ciclo(Proximo).

% Começa uma consulta com a base do caso vazia.
atender :-
    retractall(confirmado(_)),
    retractall(descartado(_)),
    ciclo(1).

% ?- atender.
% passo 1: perguntar(febre)
%         sente febre? (sim/nao) sim
% passo 2: perguntar(dor_de_cabeca)
%         sente dor_de_cabeca? (sim/nao) talvez
%         responda sim ou nao
%         sente dor_de_cabeca? (sim/nao) nao
% passo 3: perguntar(fadiga)
%         sente fadiga? (sim/nao) sim
% passo 4: perguntar(manchas_na_pele)
%         sente manchas_na_pele? (sim/nao) sim
% passo 5: concluir(dengue)
% true .
