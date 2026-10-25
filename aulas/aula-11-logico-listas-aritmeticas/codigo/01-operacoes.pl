% contando usando recursao e listas
contar(0, []).
contar(Contador, [_|Tail]) :- contar(ContadorTail, Tail), Contador is ContadorTail + 1.

soma(0, []).
soma(Total, [Head|Tail]) :- soma(Soma, Tail), Total is Head + Soma.

media(Media, Lista) :- soma(Soma, Lista), contar(Contador, Lista), Media is Soma/Contador.
