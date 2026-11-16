# Exercício — Calendário de provas

## Contexto

Um período de provas distribui as provas de seis disciplinas ao longo de alguns
dias. Duas disciplinas **têm conflito** quando há pelo menos um aluno matriculado
nas duas: nesse caso, as provas delas não podem cair no mesmo dia.

A tabela abaixo lista os conflitos. A relação é simétrica: se LFA tem conflito
com Paradigmas, Paradigmas tem conflito com LFA.

| Disciplina | Sigla | Tem conflito com |
|------------|-------|------------------|
| Linguagens Formais e Autômatos | `LFA` | Paradigmas, IA, Cálculo |
| Paradigmas de Programação | `PAR` | LFA, IA |
| Inteligência Artificial | `IA` | LFA, Paradigmas, Dados |
| Ciência de Dados | `DAD` | IA, EngSoft |
| Engenharia de Software | `ES` | Dados, Cálculo |
| Cálculo | `CAL` | EngSoft, LFA |

Os dias do período são numerados `1, 2, ..., K`. Um **calendário** atribui a cada
disciplina um dia entre 1 e K, de modo que nenhum par de disciplinas em conflito
receba o mesmo dia.

O problema tem a mesma estrutura da coloração do mapa do Nordeste: a disciplina
ocupa o lugar do estado, o dia ocupa o lugar da cor e o conflito ocupa o lugar
da fronteira.

## Parte 1 — Modelagem

No arquivo [03-calendario-provas.pl](03-calendario-provas.pl), implemente o
predicado

```prolog
calendario(K, [LFA, PAR, IA, DAD, ES, CAL])
```

usando a biblioteca `clpfd`. O predicado recebe o número de dias `K` e devolve,
na lista, o dia da prova de cada disciplina, na ordem da tabela. A implementação
tem três passos:

1. restringir o domínio das seis variáveis ao intervalo `1..K` (`ins`);
2. impor uma restrição `#\=` para cada par de disciplinas em conflito;
3. pedir ao Prolog valores concretos para as variáveis (`label/1`).

Teste com `K = 6`. A consulta precisa devolver um calendário válido.

## Parte 2 — O mínimo de dias

Com seis disciplinas, sempre existe um calendário de seis dias: uma prova por
dia, sem nenhum conflito. Esse calendário é válido, mas desnecessariamente longo.
O **mínimo de dias** é o menor valor de K para o qual existe pelo menos um
calendário válido. Determinar esse mínimo é a pergunta da restrição 1 da
coloração de mapas ("a quantidade de cores precisa ser a mínima possível").

1. Consulte `calendario(K, Dias)` com `K = 1`, `K = 2`, `K = 3`, ..., em ordem
   crescente, até a primeira resposta diferente de `false`. Registre a resposta
   obtida para cada K.
2. Informe o mínimo de dias e o calendário encontrado, dizendo quais disciplinas
   fazem prova em cada dia.
3. Justifique, **olhando apenas para a tabela de conflitos**, por que o valor
   imediatamente abaixo do mínimo é impossível. A justificativa não pode depender
   da resposta do Prolog: ela precisa apontar, na tabela, o grupo de disciplinas
   que obriga o uso desse número de dias.

## Parte 3 — Desafio (opcional)

Implemente `minimo_dias(K, Dias)`, que encontra sozinho o mínimo de dias e um
calendário com esse número de dias, testando `K = 1, 2, 3, ...` em ordem e
parando no primeiro K que admite calendário. Use `between/3` para gerar os
valores de K e o corte (`!`) para interromper a busca após a primeira solução.
