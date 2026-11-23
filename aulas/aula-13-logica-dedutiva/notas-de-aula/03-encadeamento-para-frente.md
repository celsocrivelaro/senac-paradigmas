# Paradigmas — Aula 13: Lógica Dedutiva — Encadeamento para frente

---

## Objetivos de aprendizagem

Ao final desta nota, espera-se que o aluno seja capaz de:

- descrever o encadeamento para frente e a condição de parada no ponto fixo;
- implementar em Prolog um motor de encadeamento para frente sobre regras representadas como dados;
- comparar o encadeamento para frente com o encadeamento para trás quanto ao ponto de partida, ao que é deduzido, ao custo e ao uso típico.

## Desenvolvimento teórico

### Encadeamento para frente

O **encadeamento para frente** (*forward chaining*) aplica o *modus ponens*, apresentado na nota sobre encadeamento para trás, a partir dos fatos conhecidos. A cada rodada, dispara toda regra cujas premissas são todas conhecidas e cuja conclusão ainda não é, e acrescenta a conclusão à base. O processo termina no **ponto fixo**, quando nenhuma regra produz fato novo:

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

A busca é **dirigida pelos dados**: deduz tudo o que decorre da base, independentemente de pergunta. Para bases de Horn proposicionais, o algoritmo é correto e completo. O laço termina porque cada rodada útil acrescenta um fato novo e o número de conclusões possíveis é finito; com um contador de premissas pendentes por regra, o custo total é linear no tamanho da base (DOWLING; GALLIER, 1984).

```text
 fatos            regras disparadas                    base no ponto fixo
 ---------        ----------------------------------   ---------------------
 febre            dengue <- febre, fadiga, manchas     febre, fadiga,
 fadiga      -->  procurar_atendimento <- dengue  -->  manchas_na_pele,
 manchas_na_pele  (gripe não dispara: falta            dengue,
                   dor_de_cabeca)                      procurar_atendimento
```

### Um motor para frente em Prolog

O motor de inferência do Prolog é para trás. Para encadear para frente, `codigo/04-encadeamento-para-frente.pl` escreve um motor à mão. As regras deixam de ser cláusulas e passam a ser **dados**, no formato `regra(Conclusao, Premissas)`, para que o motor possa percorrê-las e inspecionar as premissas; os fatos conhecidos ficam num predicado dinâmico que cresce durante a execução:

```prolog
:- dynamic conhecido/1.

conhecido(febre).
conhecido(fadiga).
conhecido(manchas_na_pele).

regra(gripe, [febre, dor_de_cabeca]).
regra(dengue, [febre, fadiga, manchas_na_pele]).
regra(hidratacao_e_repouso, [gripe]).
regra(procurar_atendimento, [dengue]).
```

Disparar uma regra é encontrar uma cuja conclusão ainda não é conhecida e cujas premissas todas são, e acrescentar a conclusão com `assertz`:

```prolog
disparar :-
    regra(Conclusao, Premissas),
    \+ conhecido(Conclusao),
    todas_conhecidas(Premissas),
    assertz(conhecido(Conclusao)),
    format("deduzido: ~w (de ~w)~n", [Conclusao, Premissas]).
```

O laço repete o disparo até o ponto fixo. A primeira cláusula de `encadear` dispara uma regra e recomeça; a segunda só é provada quando nenhuma regra dispara:

```prolog
encadear :-
    disparar,
    encadear.
encadear :-
    \+ disparar,
    format("ponto fixo: nenhuma regra produz fato novo~n").
```

```text
?- encadear.
deduzido: dengue (de [febre,fadiga,manchas_na_pele])
deduzido: procurar_atendimento (de [dengue])
ponto fixo: nenhuma regra produz fato novo
```

As regras são as mesmas do sistema de diagnóstico de `codigo/02-encadeamento-para-tras.pl`. A diferença está em quem conduz a dedução: lá, a pergunta `recomendacao(bruno, R)` escolhe as regras a examinar; aqui, os fatos disparam todas as regras aplicáveis, inclusive as que nenhuma pergunta usaria. O teste `\+ conhecido(Conclusao)` é a negação por falha sob a hipótese do mundo fechado: uma conclusão que não está na base conta como ainda não deduzida.

### Comparação das estratégias

| | Para trás | Para frente |
|---|---|---|
| Ponto de partida | o objetivo (pergunta) | os fatos |
| O que deduz | só o necessário para a pergunta | tudo o que decorre da base |
| Parada | o objetivo é provado ou todas as alternativas falham | ponto fixo |
| Uso típico | diagnóstico, consulta, verificação | monitoramento, configuração, reação a eventos |
| Sistemas | Prolog, MYCIN | XCON (McDERMOTT, 1982), CLIPS, motores de regras de negócio |
| Custo dominante | pode reprovar o mesmo subobjetivo várias vezes | deriva fatos que nenhuma pergunta usa |

Na forma, as duas estratégias aplicam o mesmo *modus ponens*; a diferença está no sentido da busca. Um agente que precisa reagir a cada percepção nova tende ao encadeamento para frente: cada fato que chega dispara as conclusões que dependem dele. Um agente que precisa responder a uma pergunta específica, como o agente de triagem, tende ao encadeamento para trás: só examina as regras que levam à resposta.

## Fontes e leituras

DOWLING, W. F.; GALLIER, J. H. Linear-time algorithms for testing the satisfiability of propositional Horn formulae. **The Journal of Logic Programming**, v. 1, n. 3, p. 267-284, 1984.

McDERMOTT, J. R1: a rule-based configurer of computer systems. **Artificial Intelligence**, v. 19, n. 1, p. 39-88, 1982.

RUSSELL, S.; NORVIG, P. **Artificial intelligence**: a modern approach. 4. ed. Harlow: Pearson, 2022. Cap. 7 (agentes lógicos) e cap. 9 (inferência em lógica de primeira ordem).
