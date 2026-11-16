# Exercício — Futoshiki 4×4

## Regras

O **Futoshiki** é um quebra-cabeça de grade, parecido com o Sudoku. A grade 4×4 abaixo tem duas casas preenchidas e as demais em branco (`_`). Preenchê-la exige respeitar três regras:

1. cada casa recebe um número de 1 a 4;
2. nenhum número se repete numa linha nem numa coluna;
3. os sinais entre casas vizinhas valem como desigualdades: `<` e `>` entre casas da mesma linha, e `∧` e `∨` entre casas da mesma coluna. O `∧` indica que a casa de cima é **menor** que a de baixo; o `∨`, que é **maior**.

Ao contrário do Sudoku 4×4, não há a regra dos quadrados 2×2.

```
 _ > _   _ > _
 ∧
 _   4   _   _

 _ < _   _ < _
             ∨
 4   _ < _   _
```

Chamando de `Aij` a casa da linha `i` e coluna `j`, como no Sudoku do código da aula, as desigualdades da grade são:

| Onde | Desigualdade |
|------|--------------|
| linha 1 | `A11 > A12`, `A13 > A14` |
| linha 3 | `A31 < A32`, `A33 < A34` |
| linha 4 | `A42 < A43` |
| coluna 1 | `A11 < A21` |
| coluna 4 | `A34 > A44` |

## Parte 1 — Modelagem

No arquivo [02-futoshiki.pl](02-futoshiki.pl), implemente o predicado `futoshiki(Grade)` usando a biblioteca `clpfd`, a partir do Sudoku com `clpfd` do código da aula (`03-sudoku-com-clpfd.pl`). A grade é uma lista de 16 casas, linha por linha. O predicado precisa:

1. restringir o domínio das 16 casas a `1..4`;
2. impor `all_distinct` em cada linha e em cada coluna;
3. impor as sete desigualdades da tabela, com `#<` e `#>`;
4. pedir ao Prolog valores concretos para as casas, com `label(Grade)`.

## Parte 2 — Preencher as lacunas

Resolva a grade com a consulta abaixo, em que `_` marca as lacunas, e escreva a grade preenchida no formato 4×4:

```prolog
?- Grade = [_, _, _, _,
            _, 4, _, _,
            _, _, _, _,
            4, _, _, _],
   futoshiki(Grade).
```

## Parte 3 — Por que cada sinal importa

Um quebra-cabeça bem formado tem exatamente uma solução. Na consulta da Parte 2, depois da primeira resposta, digite `;` para pedir a próxima: o Prolog responde `false`, porque não há outra.

Retire do predicado a desigualdade `A42 < A43`, carregue o arquivo de novo e repita a consulta da Parte 2, digitando `;` depois de cada resposta até aparecer `false`. Liste as soluções encontradas e explique, a partir delas, por que o sinal entre `A42` e `A43` é necessário.
