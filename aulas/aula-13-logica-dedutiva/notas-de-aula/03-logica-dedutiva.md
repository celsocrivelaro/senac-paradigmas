# Paradigmas — Aula 13: Lógica Dedutiva — Dedução: encadeamento para trás e para frente

---

## Objetivos de aprendizagem

Ao final desta nota, espera-se que o aluno seja capaz de:

- distinguir consequência lógica de inferência e definir correção e completude de um procedimento de inferência;
- aplicar o *modus ponens* sobre cláusulas de Horn;
- descrever o encadeamento para trás executado pelo Prolog e o encadeamento para frente, e comparar as duas estratégias;
- interpretar a resposta `false` do Prolog sob a hipótese do mundo fechado e a negação por falha;
- reconhecer a incompletude da busca em profundidade do Prolog em regras recursivas.

## Desenvolvimento teórico

### Dedução, consequência lógica e inferência

Uma sentença $\alpha$ é **consequência lógica** de uma base de conhecimento $KB$, escrito $KB \models \alpha$, quando $\alpha$ é verdadeira em todo modelo em que todas as sentenças de $KB$ são verdadeiras. A consequência lógica é uma relação semântica: diz o que decorre da base, não como obtê-lo.

Um **procedimento de inferência** $i$ deriva sentenças a partir da base por regras sintáticas; escreve-se $KB \vdash_i \alpha$. **Dedução** é a obtenção de uma conclusão por inferência a partir de premissas, de modo que a conclusão seja necessariamente verdadeira quando as premissas o são. Duas propriedades qualificam o procedimento (RUSSELL; NORVIG, 2022):

- **correção** (*soundness*): se $KB \vdash_i \alpha$, então $KB \models \alpha$ — o procedimento só deriva consequências;
- **completude** (*completeness*): se $KB \models \alpha$, então $KB \vdash_i \alpha$ — toda consequência é derivável.

### *Modus ponens* sobre cláusulas de Horn

A regra de inferência central da programação em lógica é o ***modus ponens***:

$$\frac{\alpha_1 \land \dots \land \alpha_n \Rightarrow \beta \qquad \alpha_1 \quad \dots \quad \alpha_n}{\beta}$$

Uma regra Prolog `beta :- alfa1, ..., alfaN.` é exatamente a implicação do numerador; os fatos são as premissas atômicas. As cláusulas com no máximo um literal positivo, apresentadas na aula de base de conhecimento como **cláusulas de Horn**, são a forma em que o *modus ponens* basta como regra de inferência: sobre uma base de Horn, ele é correto e completo para consultas atômicas (RUSSELL; NORVIG, 2022). Com variáveis, o *modus ponens* generalizado usa a **unificação** para casar as premissas da regra com os fatos.

O *modus ponens* pode ser aplicado em dois sentidos, que dão as duas estratégias de dedução.

### Encadeamento para trás

O **encadeamento para trás** (*backward chaining*) parte da sentença a provar, o **objetivo**. Para provar $\beta$, procura uma regra cuja cabeça unifica com $\beta$ e passa a provar cada premissa do corpo como subobjetivo; um subobjetivo que unifica com um fato está provado. A busca é **dirigida pelo objetivo**: só são consideradas as regras relevantes para a pergunta feita.

O motor do Prolog é o encadeamento para trás implementado como **resolução SLD** (KOWALSKI, 1974), com três escolhas fixas: os subobjetivos são resolvidos da esquerda para a direita, as cláusulas são tentadas na ordem em que aparecem no programa, e a árvore de busca é percorrida em profundidade, com retrocesso na falha.

O sistema de diagnóstico de `codigo/04-diagnostico.pl` tem regras em dois níveis:

```prolog
diagnostico(P, gripe) :-
    sintoma(P, febre),
    sintoma(P, dor_de_cabeca).
diagnostico(P, dengue) :-
    sintoma(P, febre),
    sintoma(P, fadiga),
    sintoma(P, manchas_na_pele).

recomendacao(P, hidratacao_e_repouso) :-
    diagnostico(P, gripe).
recomendacao(P, procurar_atendimento) :-
    diagnostico(P, dengue).
```

A consulta `recomendacao(bruno, R)` produz a seguinte árvore de busca:

```text
recomendacao(bruno, R)
|
+-- cláusula 1: R = hidratacao_e_repouso
|   +-- diagnostico(bruno, gripe)
|       +-- sintoma(bruno, febre)           sucesso
|       +-- sintoma(bruno, dor_de_cabeca)   FALHA -> retrocede
|
+-- cláusula 2: R = procurar_atendimento
    +-- diagnostico(bruno, dengue)
        +-- sintoma(bruno, febre)           sucesso
        +-- sintoma(bruno, fadiga)          sucesso
        +-- sintoma(bruno, manchas_na_pele) sucesso
                                            => R = procurar_atendimento
```

A sequência de regras do ramo de sucesso é a **explicação** da conclusão — o que a interface de explicação de um sistema especialista mostra ao usuário. Em Prolog, `trace` exibe essa sequência passo a passo, como na aula de base de conhecimento.

### Encadeamento para frente

O **encadeamento para frente** (*forward chaining*) parte dos fatos conhecidos. A cada rodada, dispara toda regra cujas premissas são todas conhecidas e cuja conclusão ainda não é, e acrescenta a conclusão à base. O processo termina no **ponto fixo**, quando nenhuma regra produz fato novo:

```text
função ENCADEAR-PARA-FRENTE(KB)
    repita
        novo <- falso
        para cada regra (p1 ∧ ... ∧ pn => q) em KB
            se p1, ..., pn estão em KB e q não está
                acrescenta q a KB
                novo <- verdadeiro
    até novo = falso
```

A busca é **dirigida pelos dados**: deduz tudo o que decorre da base, independentemente de pergunta. Para bases de Horn proposicionais, o algoritmo é correto e completo, e com contadores de premissas pendentes por regra roda em tempo linear no tamanho da base (DOWLING; GALLIER, 1984).

Como o motor do Prolog é para trás, `codigo/05-encadeamento-para-frente.pl` escreve um motor para frente à mão, com as regras guardadas como dados:

```prolog
regra(gripe, [febre, dor_de_cabeca]).
regra(dengue, [febre, fadiga, manchas_na_pele]).
regra(hidratacao_e_repouso, [gripe]).
regra(procurar_atendimento, [dengue]).

disparar :-
    regra(Conclusao, Premissas),
    \+ conhecido(Conclusao),
    todas_conhecidas(Premissas),
    assertz(conhecido(Conclusao)),
    format("deduzido: ~w (de ~w)~n", [Conclusao, Premissas]).

encadear :-
    disparar,
    encadear.
encadear :-
    \+ disparar,
    format("ponto fixo: nenhuma regra produz fato novo~n").
```

Com os fatos `febre`, `fadiga` e `manchas_na_pele`:

```text
?- encadear.
deduzido: dengue (de [febre,fadiga,manchas_na_pele])
deduzido: procurar_atendimento (de [dengue])
ponto fixo: nenhuma regra produz fato novo
```

### Comparação das estratégias

| | Para trás | Para frente |
|---|---|---|
| Ponto de partida | o objetivo (pergunta) | os fatos |
| O que deduz | só o necessário para a pergunta | tudo o que decorre da base |
| Uso típico | diagnóstico, consulta, verificação | monitoramento, configuração, reação a eventos |
| Sistemas | Prolog, MYCIN | XCON, CLIPS, motores de regras de negócio |
| Custo dominante | regras irrelevantes ao objetivo não são tocadas; pode reprovar o mesmo subobjetivo várias vezes | deriva fatos que nenhuma pergunta usa |

Na forma, as duas estratégias aplicam o mesmo *modus ponens*; a diferença está no sentido da busca. Um agente que precisa reagir a cada percepção nova tende ao encadeamento para frente; um agente que precisa responder a uma pergunta específica, ao encadeamento para trás.

### Mundo fechado e negação por falha

Uma base de conhecimento finita não lista o que é falso. A **hipótese do mundo fechado** (*closed world assumption*) considera falsa toda sentença atômica que não é deduzível da base (REITER, 1978). O Prolog opera sob essa hipótese: a resposta `false` significa "não se deduz da base", não "é falso no mundo".

```text
?- diagnostico(carla, D).
false.
```

A base registra `sintoma(carla, tosse)`, mas nenhuma regra conclui um diagnóstico a partir de tosse. A resposta não afirma que carla está saudável; afirma que a base não sustenta nenhum dos diagnósticos conhecidos.

O operador `\+ G` implementa a **negação por falha** (*negation as failure*): `\+ G` é provado quando a tentativa de provar `G` falha finitamente (CLARK, 1978). Duas consequências:

- **Não monotonicidade**: acrescentar um fato pode invalidar uma conclusão anterior. Antes de `assertz(enviado(p2))`, `\+ enviado(p2)` é provado; depois, não. Na lógica clássica, acrescentar premissas nunca retira consequências.
- **Variáveis livres**: `\+ G` não liga variáveis. A consulta `\+ pago(P)` com `P` livre pergunta "não existe nenhum pedido pago?", e não "qual pedido não está pago?". Por isso, nas cláusulas de status, `pedido(P)` vem antes de `\+ pago(P)` — a mesma regra de gerar e depois testar da nota sobre condicionais.

### Dedução com regra recursiva e a incompletude do Prolog

Uma regra recursiva deduz uma relação de alcance arbitrário a partir de fatos locais. Em `codigo/06-rotas.pl`, os fatos são rotas diretas entre cidades, válidas nos dois sentidos, e provar `caminho(Origem, Destino, Caminho, Distancia)` é deduzir que o destino é alcançável; a prova traz o caminho como testemunho.

A formulação direta da recursão, sem controle de visitas, é logicamente correta, mas não termina em Prolog: a busca em profundidade vai de `sao_paulo` a `rio_de_janeiro`, segue a `belo_horizonte`, volta ao `rio_de_janeiro` pela rota inversa e repete o ciclo entre as duas cidades até estourar a pilha, sem chegar a explorar `curitiba`. O caminho existe ($KB \models \alpha$), e o procedimento não o encontra. A resolução SLD é completa para cláusulas de Horn, mas a estratégia em profundidade do Prolog não é: um ramo infinito à esquerda impede que os ramos à direita sejam visitados.

A correção acrescenta a lista de cidades visitadas e proíbe revisitar:

```prolog
buscar(Destino, Destino, _, [Destino], 0).
buscar(Atual, Destino, Visitadas, [Atual | Resto], Distancia) :-
    conectado(Atual, Proxima, D1),
    \+ member(Proxima, Visitadas),
    buscar(Proxima, Destino, [Proxima | Visitadas], Resto, D2),
    Distancia is D1 + D2.

caminho(Origem, Destino, Caminho, Distancia) :-
    buscar(Origem, Destino, [Origem], Caminho, Distancia).
```

```text
?- caminho(sao_paulo, porto_alegre, C, D).
C = [sao_paulo, curitiba, porto_alegre],
D = 1120 ;
false.
```

O preço da terminação é sair da lógica pura: a lista de visitadas é controle, não conhecimento do domínio. É a mesma divisão da equação de Kowalski (1979), algoritmo = lógica + controle: as regras de rota descrevem o que é um caminho, e a lista de visitadas é a parte de controle que o programador precisa escrever porque a estratégia fixa do interpretador não a fornece.

## Fontes e leituras

CLARK, K. L. Negation as failure. In: GALLAIRE, H.; MINKER, J. (ed.). **Logic and data bases**. New York: Plenum, 1978. p. 293-322.

DOWLING, W. F.; GALLIER, J. H. Linear-time algorithms for testing the satisfiability of propositional Horn formulae. **The Journal of Logic Programming**, v. 1, n. 3, p. 267-284, 1984.

KOWALSKI, R. Predicate logic as programming language. In: IFIP CONGRESS, 1974, Stockholm. **Proceedings** [...]. Amsterdam: North-Holland, 1974. p. 569-574.

KOWALSKI, R. Algorithm = logic + control. **Communications of the ACM**, v. 22, n. 7, p. 424-436, 1979.

REITER, R. On closed world data bases. In: GALLAIRE, H.; MINKER, J. (ed.). **Logic and data bases**. New York: Plenum, 1978. p. 55-76.

RUSSELL, S.; NORVIG, P. **Artificial intelligence**: a modern approach. 4. ed. Harlow: Pearson, 2022. Cap. 7 (agentes lógicos) e cap. 9 (inferência em lógica de primeira ordem).
