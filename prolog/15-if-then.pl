premium(ana).
comprou(ana).
comprou(joao).

avaliar(P, R) :-
    ( premium(P) ->
        ( comprou(P) ->
            R = premio_especial
        ;
            R = bonus_premium
        )
    ;
        ( comprou(P) ->
            R = bonus_simples
        ;
            R = nenhum_bonus
        )
    ).

%%%%% Exemplo 2:

pago(p1).
enviado(p1).
pago(p2).

status_pedido(P, Status) :-
    ( pago(P) ->
        ( enviado(P) ->
            Status = concluido
        ;
            Status = aguardando_envio
        )
    ;
        Status = aguardando_pagamento
    ).
