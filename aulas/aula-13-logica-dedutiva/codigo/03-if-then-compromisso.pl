% O compromisso do ->: a condição é provada uma vez só.
%
% Em ( Condicao -> Entao ; Senao ), o Prolog busca a PRIMEIRA prova da
% condição e descarta as alternativas dela. Com a variável ainda livre, a
% condição liga a variável ao primeiro valor encontrado, e os demais valores
% nunca são considerados.

pedido(p1).
pedido(p2).
pedido(p3).

pago(p1).
pago(p2).

enviado(p1).

% Sem pedido(P) antes do condicional: pago(P) liga P a p1 e se compromete.
status_sem_gerador(P, Status) :-
    (   pago(P)
    ->  (   enviado(P)
        ->  Status = concluido
        ;   Status = aguardando_envio
        )
    ;   Status = aguardando_pagamento
    ).

% Com o pedido conhecido, funciona:
% ?- status_sem_gerador(p2, S).
% S = aguardando_envio.
%
% Com o pedido livre, só aparece p1, e a pergunta inversa falha:
% ?- status_sem_gerador(P, S).
% P = p1, S = concluido.
% ?- status_sem_gerador(P, aguardando_envio).
% false.

% Sem senão, o condicional falha quando a condição falha.
so_se_pago(P) :-
    (   pago(P)
    ->  format("~w está pago~n", [P])
    ).

% ?- so_se_pago(p1).
% p1 está pago
% true.
% ?- so_se_pago(p3).
% false.

% O if-then-else equivale a duas cláusulas com corte: o corte depois da
% condição impede o retrocesso para a segunda cláusula.
status_com_corte(P, Status) :-
    pago(P),
    !,
    (   enviado(P)
    ->  Status = concluido
    ;   Status = aguardando_envio
    ).
status_com_corte(_, aguardando_pagamento).

% ?- status_com_corte(p3, S).
% S = aguardando_pagamento.
% ?- status_com_corte(P, S).
% P = p1, S = concluido.
