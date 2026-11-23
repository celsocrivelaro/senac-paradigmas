% Condicional em Prolog: a construção ( Condicao -> Entao ; Senao ).
%
% Três exemplos:
%   1. a regra de ação do agente de triagem, reescrita com if-then-else;
%   2. bônus de cliente, com if-then-else aninhado;
%   3. status de pedido, escrito das duas formas: com cláusulas alternativas
%      e com if-then-else.

% ------------------------------------------------------------------
% 1. Regra de ação do agente de triagem
% ------------------------------------------------------------------

% Conhecimento do domínio, o mesmo do arquivo do agente.
doenca(gripe, [febre, dor_de_cabeca]).
doenca(dengue, [febre, fadiga, manchas_na_pele]).

% Retrato da base do caso no meio de uma consulta: febre confirmada,
% dor de cabeça descartada.
% A diretiva dynamic declara que confirmado/1 e descartado/1 podem ganhar
% e perder fatos em tempo de execução. Os dois fatos abaixo são só o ponto
% de partida: a consulta de exemplo acrescenta outros com assertz, o que
% daria erro de permissão se os predicados fossem estáticos.
:- dynamic confirmado/1.
:- dynamic descartado/1.
confirmado(febre).
descartado(dor_de_cabeca).

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

% Com cláusulas alternativas (versão do arquivo do agente), a prioridade
% entre as regras fica implícita na ordem das cláusulas. Com ->, a
% prioridade fica escrita: cada condição só é testada se a anterior falhou.
% A ligação de Doenca feita na condição vale no ramo então.
acao_triagem(Acao) :-
    (   doenca(Doenca, Sintomas),
        todos_confirmados(Sintomas)
    ->  Acao = concluir(Doenca)
    ;   doenca(_, Possiveis),
        nenhum_descartado(Possiveis),
        primeiro_desconhecido(Possiveis, Sintoma)
    ->  Acao = perguntar(Sintoma)
    ;   Acao = concluir(sem_diagnostico)
    ).

% ?- acao_triagem(A).
% A = perguntar(fadiga).
% ?- assertz(confirmado(fadiga)), assertz(confirmado(manchas_na_pele)), acao_triagem(A).
% A = concluir(dengue).

% ------------------------------------------------------------------
% 2. Bônus de cliente: if-then-else aninhado
% ------------------------------------------------------------------

premium(ana).
comprou(ana).
comprou(joao).

avaliar(Pessoa, Resultado) :-
    (   premium(Pessoa)
    ->  (   comprou(Pessoa)
        ->  Resultado = premio_especial
        ;   Resultado = bonus_premium
        )
    ;   (   comprou(Pessoa)
        ->  Resultado = bonus_simples
        ;   Resultado = nenhum_bonus
        )
    ).

% ?- avaliar(ana, R).
% R = premio_especial.
% ?- avaliar(joao, R).
% R = bonus_simples.
% ?- avaliar(maria, R).
% R = nenhum_bonus.

% ------------------------------------------------------------------
% 3. Status de pedido: cláusulas alternativas e if-then-else
% ------------------------------------------------------------------

pedido(p1).
pedido(p2).
pedido(p3).

pago(p1).
pago(p2).

enviado(p1).

% Forma declarativa: uma cláusula por caso. Cada cláusula repete a condição
% completa do seu caso, inclusive a negação das condições dos outros casos.
status_por_clausulas(P, concluido) :-
    pago(P),
    enviado(P).
status_por_clausulas(P, aguardando_envio) :-
    pago(P),
    \+ enviado(P).
status_por_clausulas(P, aguardando_pagamento) :-
    pedido(P),
    \+ pago(P).

% Forma com if-then-else: o senão já carrega a negação da condição.
% pedido(P) vem antes do condicional para que P esteja ligado quando o
% condicional for avaliado.
status_pedido(P, Status) :-
    pedido(P),
    (   pago(P)
    ->  (   enviado(P)
        ->  Status = concluido
        ;   Status = aguardando_envio
        )
    ;   Status = aguardando_pagamento
    ).

% ?- status_pedido(p2, S).
% S = aguardando_envio.
% ?- status_pedido(P, S).
% P = p1, S = concluido ;
% P = p2, S = aguardando_envio ;
% P = p3, S = aguardando_pagamento.
% ?- status_por_clausulas(P, aguardando_envio).
% P = p2 ;
% false.
