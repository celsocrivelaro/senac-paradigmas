# Paradigmas — Aula 13: Lógica Dedutiva — Condicionais: regras alternativas e if-then-else

---

## Objetivos de aprendizagem

Ao final desta nota, espera-se que o aluno seja capaz de:

- escrever uma decisão em Prolog com cláusulas alternativas e com a construção `( Condicao -> Entao ; Senao )`;
- explicar a semântica operacional do `->`: a condição é provada uma vez só e suas alternativas são descartadas;
- relacionar o if-then-else ao corte;
- identificar quando o `->` faz um predicado perder a reversibilidade e como evitar isso.

## Desenvolvimento teórico

### Cláusulas alternativas como condicional declarativo

Em Prolog, um predicado definido por várias cláusulas é a **disjunção** dessas cláusulas: `p :- A. p :- B.` significa $p \leftarrow A \lor B$. Cada cláusula funciona como um ramo de um condicional, e o corpo da cláusula é a condição do ramo.

Para que os ramos sejam **mutuamente exclusivos**, cada cláusula precisa trazer a condição completa do seu caso, incluindo a negação das condições dos outros:

```prolog
status_por_clausulas(P, concluido) :-
    pago(P),
    enviado(P).
status_por_clausulas(P, aguardando_envio) :-
    pago(P),
    \+ enviado(P).
status_por_clausulas(P, aguardando_pagamento) :-
    pedido(P),
    \+ pago(P).
```

A forma é puramente lógica: cada cláusula se lê sozinha como uma afirmação verdadeira, a ordem das cláusulas não altera o conjunto de respostas, e o predicado funciona em qualquer direção — `status_por_clausulas(p2, S)` calcula o status, `status_por_clausulas(P, aguardando_envio)` encontra os pedidos nesse status. O custo é a repetição das condições: `pago(P)` é provado em duas cláusulas.

Quando os ramos **não** são exclusivos, como nas regras de ação do agente de triagem na nota sobre agentes lógicos, a prioridade entre eles fica implícita na ordem das cláusulas e só vale para a primeira solução.

### A construção `( Condicao -> Entao ; Senao )`

O **if-then-else** de Prolog é a construção

```prolog
(   Condicao
->  Entao
;   Senao
)
```

com a seguinte semântica operacional:

1. o interpretador tenta provar `Condicao`;
2. se encontra uma prova, **descarta as demais provas** de `Condicao` e executa `Entao`;
3. se `Condicao` falha, executa `Senao`.

As ligações de variáveis feitas pela primeira prova de `Condicao` valem dentro de `Entao`. O operador `->` tem precedência maior que `;`, de modo que `C1 -> T1 ; C2 -> T2 ; E` se lê como `C1 -> T1 ; (C2 -> T2 ; E)`: um **else-if** encadeado.

Sem o ramo `Senao`, a construção `( Condicao -> Entao )` **falha** quando a condição falha, em vez de seguir adiante como o `if` sem `else` de uma linguagem imperativa:

```text
?- so_se_pago(p1).
p1 está pago
true.
?- so_se_pago(p3).
false.
```

### Equivalência com o corte

O **corte** (`!`) é um objetivo que sempre é provado e, ao ser provado, elimina os pontos de escolha criados desde o início da cláusula em que aparece: as provas alternativas dos objetivos à sua esquerda e as cláusulas seguintes do mesmo predicado. O if-then-else é uma forma estruturada do corte. As duas definições abaixo têm o mesmo comportamento:

```prolog
p :- ( C -> T ; E ).

p :- C, !, T.
p :- E.
```

O corte depois de `C` faz duas coisas: descarta as outras provas de `C` e impede que a segunda cláusula seja tentada. É exatamente o efeito do `->`, com a diferença de que o `->` limita o efeito do corte ao interior dos parênteses, enquanto o `!` corta todas as alternativas da cláusula e do predicado.

### Exemplos

A regra de ação do agente de triagem, reescrita com else-if (`codigo/02-if-then.pl`), deixa a prioridade escrita no código:

```prolog
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
```

Com a base no meio de uma consulta — febre confirmada, dor de cabeça descartada:

```text
?- acao_triagem(A).
A = perguntar(fadiga).
```

A ligação de `Doenca` feita na condição vale no ramo então. Na versão por cláusulas, a consulta `melhor_acao(A)` devolve, por retrocesso, também as ações de prioridade menor (`concluir(sem_diagnostico)` é sempre deduzível); o ciclo do agente só usa a primeira. Com `->`, `acao_triagem(A)` tem uma única resposta: o compromisso com a primeira prova da condição é exatamente o que o agente precisa, porque ele executa **uma** ação por passo.

Um condicional aninhado expressa uma tabela de decisão com duas condições:

```prolog
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
```

| | comprou | não comprou |
|---|---|---|
| **premium** | `premio_especial` | `bonus_premium` |
| **não premium** | `bonus_simples` | `nenhum_bonus` |

```text
?- avaliar(ana, R).
R = premio_especial.
?- avaliar(joao, R).
R = bonus_simples.
?- avaliar(maria, R).
R = nenhum_bonus.
```

O status do pedido com if-then-else elimina a repetição das condições da versão por cláusulas: o ramo `Senao` já carrega a negação da condição.

```prolog
status_pedido(P, Status) :-
    pedido(P),
    (   pago(P)
    ->  (   enviado(P)
        ->  Status = concluido
        ;   Status = aguardando_envio
        )
    ;   Status = aguardando_pagamento
    ).
```

```text
?- status_pedido(P, S).
P = p1, S = concluido ;
P = p2, S = aguardando_envio ;
P = p3, S = aguardando_pagamento.
```

### O compromisso do `->` e a perda da reversibilidade

O descarte das alternativas da condição tem uma consequência quando a condição contém variáveis livres. Retirado o `pedido(P)` que antecede o condicional (`codigo/03-if-then-compromisso.pl`):

```prolog
status_sem_gerador(P, Status) :-
    (   pago(P)
    ->  (   enviado(P)
        ->  Status = concluido
        ;   Status = aguardando_envio
        )
    ;   Status = aguardando_pagamento
    ).
```

```text
?- status_sem_gerador(p2, S).
S = aguardando_envio.
?- status_sem_gerador(P, S).
P = p1, S = concluido.
?- status_sem_gerador(P, aguardando_envio).
false.
```

Com `P` livre, `pago(P)` liga `P` a `p1` na primeira prova e o `->` descarta a prova `P = p2`. O predicado responde corretamente quando o pedido é dado, mas deixa de enumerar pedidos e a pergunta inversa falha, embora `p2` esteja aguardando envio. O predicado perdeu a **reversibilidade**: só funciona no modo de uso em que `P` chega ligado.

A regra prática é **gerar e depois testar**: um objetivo que liga as variáveis (`pedido(P)`) vem antes do condicional, e a condição só testa valores já conhecidos. Assim cada valor gerado passa pelo condicional separadamente, e o retrocesso volta ao gerador, não à condição.

### Comparação

| | Cláusulas alternativas | `( C -> T ; E )` |
|---|---|---|
| Leitura | lógica: cada cláusula é uma afirmação | operacional: ordem de teste |
| Exclusão entre ramos | escrita à mão, com `\+` | implícita no `Senao` |
| Condições repetidas | sim | não |
| Prioridade entre ramos | implícita na ordem das cláusulas | explícita na ordem do else-if |
| Reversibilidade | preservada | perdida se a condição ligar variáveis |
| Relação com o corte | nenhuma | equivale a `C, !, T` + cláusula `E` |

A forma por cláusulas é a preferida quando a decisão é uma relação entre os argumentos e precisa funcionar em mais de uma direção. O if-then-else serve quando a decisão é uma função dos argumentos de entrada, já ligados, e a prioridade entre os casos é parte da regra, como no agente que precisa escolher **uma** ação.

## Fontes e leituras

BRATKO, I. **Prolog programming for artificial intelligence**. 4. ed. Harlow: Pearson, 2012. Cap. 5 (controle do retrocesso).

CLOCKSIN, W. F.; MELLISH, C. S. **Programming in Prolog**: using the ISO standard. 5. ed. Berlin: Springer, 2003.

SWI-PROLOG. **Control predicates**: ->/2, ;/2, !/0. Disponível em: https://www.swi-prolog.org/pldoc/man?section=control. Acesso em: 22 nov. 2026.
