% Módulos importados:
%   clpfd: Constraint Logic Programming over Finite Domains. Restrições sobre
%          números inteiros: #=, #\=, #<, #>, #=<, #>=, in, ins, all_distinct, label.
%   clpr:  Constraint Logic Programming over Reals. Restrições sobre números
%          reais, escritas entre chaves: { X + 1 = 5 }. (não usado neste arquivo)

:- use_module(library(clpfd)).
:- use_module(library(clpr)).

% ins e all_distinct são predicados da biblioteca clpfd:
%   L ins 1..4      -> toda variável da lista L fica no domínio 1..4
%   all_distinct(L) -> as variáveis da lista L têm valores diferentes entre si
valido([]).
valido([L|T]) :-
    L ins 1..4,
    all_distinct(L),
    valido(T).

sudoku(Sudoku,Solucao) :-
    Solucao = Sudoku,
    Sudoku = [A11, A12, A13, A14,
              A21, A22, A23, A24,
              A31, A32, A33, A34,
              A41, A42, A43, A44],
    Linha1 = [A11, A12, A13, A14],
    Linha2 = [A21, A22, A23, A24],
    Linha3 = [A31, A32, A33, A34],
    Linha4 = [A41, A42, A43, A44],
    Coluna1 = [A11, A21, A31, A41],
    Coluna2 = [A12, A22, A32, A42],
    Coluna3 = [A13, A23, A33, A43],
    Coluna4 = [A14, A24, A34, A44],
    Quadrado1 = [A11, A12, A21, A22],
    Quadrado2 = [A13, A14, A23, A24],
    Quadrado3 = [A31, A32, A41, A42],
    Quadrado4 = [A33, A34, A43, A44],
    
    valido([Linha1, Linha2, Linha3, Linha4,
    Coluna1, Coluna2, Coluna3, Coluna4,
    Quadrado1, Quadrado2, Quadrado3, Quadrado4]).


%sudoku([1,_,3,_,
%        _,_,_,2,
%        3,_,_,_,
%        _,1,_,_
%         ],Resposta).
