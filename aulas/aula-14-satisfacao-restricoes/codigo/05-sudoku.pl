membro(X,[X]). 
membro(X,[X|_]). 
membro(X,[_|T]) :- membro(X,T). 

% verifica se todos os itens de uma lista
% são diferentes enter si
diferentes([]) :- !. 
diferentes([H|T]) :- \+ membro(H,T), diferentes(T). 

% validar uma lista de listas L
% que são todas variáveis dentro
% do domínio e são diferentes entre si
valido([]) :- !.
valido([L|T]) :- 
    todos_no_dominio(L), diferentes(L), valido(T).

entre(Minimo, Maximo, Minimo) :-
    Minimo =< Maximo.
entre(Minimo, Maximo, X) :-
    Minimo < Maximo,
    Proximo is Minimo + 1,
    entre(Proximo, Maximo, X).

domino(X) :- entre(1,4,X).

todos_no_dominio([]) :- !.
todos_no_dominio([A|T]) :- 
    todos_no_dominio(T),
    domino(A).

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


% entrada
?- sudoku([1,_,3,_, _,_,_,2, 3,_,_,_, _,1,_,_],Resposta).

sudoku([_,_,_,4, 
        _,_,_,_, 
        2,_,_,3, 
        4,_,1,2],Resposta).
