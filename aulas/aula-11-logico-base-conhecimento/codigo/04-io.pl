% Lê um número e escreve o dobro
ler_e_dobrar :-
    write('Digite um número: '),
    read(X),
    Y is X * 2,
    write('O dobro é: '), write(Y), nl.

% escreve em um arquivo
escrever_arquivo :-
    open('resultado.txt', write, Stream),
    write(Stream, 'Prolog é interessante!'),
    close(Stream).

% lê de um arquivo
ler_arquivo :-
    open('resultado.txt', read, Stream),
    read_line_to_string(Stream, Conteudo),
    write('Conteúdo: '), write(Conteudo), nl,
    close(Stream).
