% Decomposição de termos
% Z =..[p, X, Y, f(X)]. (operador =..)
% ==> Z = p(X,Y,f(x)).

circle(Radius).
rectangle(Width, Height).
triangle(Base, Height).

% Área do círculo
area(circle(Radius), Area) :-
    Area is pi * Radius * Radius.

% Área do retângulo
area(rectangle(Width, Height), Area) :-
    Area is Width * Height.

% Área do triângulo
area(triangle(Base, Height), Area) :-
    Area is 0.5 * Base * Height.

% aumentar figuras
% aumentar(quadrado(Lado), Fator, quadrado(Lado2)) :- 
%  Lado2 is Fator * Lado.
% aumentar(circulo(Raio), Fator, quadrado(Raio2)) :- 
%  Raio2 is Fator * Raio.
% aumentar(retangulo(LadoA, LadoB), Fator, retangulo(LadoA2, LadoB2)) :- 
%  LadoA2 is Fator * LadoA, LadoB2 is Fator * LadoB.

multiplicar([], _, []).
multiplicar([E|L], F, [EM|L1]) :-
  multiplicar(L,F,L1), EM is E * F.

aumentar(Figura, Fator, FiguraResultado) :-
  Figura =.. [Tipo|Parametros],
  multiplicar(Parametros, Fator, ParametrosResultado),
  FiguraResultado =.. [Tipo|ParametrosResultado].

% aumentar(circulo(10), 6, FiguraResultado).
% aumentar(retangulo(12, 4), 3, FiguraResultado).

soma(R,A,B) :- R is A + B.
diferenca(R,A,B) :- R is A - B.

% Args, [10, 20], ops: [soma, diferenca], resultados: [30, -10]
% aplicaOp(A1, A2, Ops, Resultados).

aplicaOp(_, _, [], [], []) :- !.
aplicaOp(A1, A2, [Ops|L], [R|ListaResultados], [Operacao|ListaOperacaoes]) :-
  Operacao,
  Operacao =.. [Ops|[R, A1, A2]],
  aplicaOp(A1, A2, L, ListaResultados, ListaOperacaoes).

% aplicaOp(10, 20, [soma, diferenca], Resultados, Operacoes).
