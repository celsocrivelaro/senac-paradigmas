% Exercício: agente de suporte técnico. Enunciado em 01-suporte-tecnico.md.
%
% O ambiente (usuários simulados), o TELL, as regras de ação e o ciclo já
% estão prontos. Falta o conhecimento do domínio: os fatos falha/2.

% ------------------------------------------------------------------
% AMBIENTE: usuários simulados
% ------------------------------------------------------------------

observa(lia, luz_do_roteador_apagada).

observa(marcos, outros_aparelhos_sem_internet).
observa(marcos, luz_de_internet_vermelha).

observa(nina, usa_wifi).
observa(nina, icone_de_rede_com_x).

observa(otavio, usa_cabo).
observa(otavio, icone_de_rede_com_x).

observa(paula, um_site_especifico_nao_abre).

observa(rafael, cheiro_de_queimado).
observa(rafael, luz_do_roteador_apagada).

% Usuário em atendimento.
% A diretiva dynamic declara que atendendo/1 é criado em tempo de execução:
% o arquivo não traz nenhum fato atendendo(...), e atender/1 o inclui com
% assertz e o remove com retractall a cada consulta.
:- dynamic atendendo/1.

responder(Sintoma, sim) :-
    atendendo(Usuario),
    observa(Usuario, Sintoma).
responder(Sintoma, nao) :-
    atendendo(Usuario),
    \+ observa(Usuario, Sintoma).

% ------------------------------------------------------------------
% AGENTE
% ------------------------------------------------------------------

% Parte 1: conhecimento do domínio. Um fato falha(Falha, Sintomas) por falha,
% na ordem em que as falhas devem ser investigadas.


% Conhecimento do caso (muda a cada resposta).
% confirmado/1 e descartado/1 são criados em tempo de execução: começam sem
% nenhum fato e ganham um fato a cada resposta, pelo assertz de informar/2.
% A diretiva dynamic faz o predicado existir mesmo vazio.
:- dynamic confirmado/1.
:- dynamic descartado/1.

informar(Sintoma, sim) :-
    assertz(confirmado(Sintoma)).
informar(Sintoma, nao) :-
    assertz(descartado(Sintoma)).

todos_confirmados([]).
todos_confirmados([Sintoma | Resto]) :-
    confirmado(Sintoma),
    todos_confirmados(Resto).

nenhum_descartado([]).
nenhum_descartado([Sintoma | Resto]) :-
    \+ descartado(Sintoma),
    nenhum_descartado(Resto).

primeiro_desconhecido([Sintoma | _], Sintoma) :-
    \+ confirmado(Sintoma),
    \+ descartado(Sintoma).
primeiro_desconhecido([Sintoma | Resto], Desconhecido) :-
    confirmado(Sintoma),
    primeiro_desconhecido(Resto, Desconhecido).

% Regras de ação, em ordem de prioridade.
% Parte 3: as regras de segurança entram aqui.
melhor_acao(concluir(Falha)) :-
    falha(Falha, Sintomas),
    todos_confirmados(Sintomas).
melhor_acao(perguntar(Sintoma)) :-
    falha(_, Sintomas),
    nenhum_descartado(Sintomas),
    primeiro_desconhecido(Sintomas, Sintoma).
melhor_acao(concluir(sem_diagnostico)).

ciclo(Passo) :-
    melhor_acao(Acao),
    format("passo ~w: ~w~n", [Passo, Acao]),
    agir(Acao, Passo).

agir(concluir(_), _).
agir(perguntar(Sintoma), Passo) :-
    responder(Sintoma, Resposta),
    format("        resposta: ~w~n", [Resposta]),
    informar(Sintoma, Resposta),
    Proximo is Passo + 1,
    ciclo(Proximo).

atender(Usuario) :-
    retractall(atendendo(_)),
    retractall(confirmado(_)),
    retractall(descartado(_)),
    assertz(atendendo(Usuario)),
    ciclo(1).
