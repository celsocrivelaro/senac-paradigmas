# Paradigmas — Aula 13: Lógica Dedutiva — Agentes lógicos e sistemas especialistas

---

## Objetivos de aprendizagem

Ao final desta nota, espera-se que o aluno seja capaz de:

- definir agente, função de agente e agente baseado em conhecimento;
- descrever o ciclo perceber–informar–perguntar–agir e as operações TELL e ASK;
- mapear os componentes de um agente baseado em conhecimento para um programa Prolog (base de conhecimento, `assertz`/`retract`, consulta);
- caracterizar um sistema especialista e situar MYCIN, DENDRAL, XCON e CLIPS.

## Desenvolvimento teórico

### Agente e função de agente

Um **agente** é uma entidade que percebe o ambiente por sensores e age sobre ele por atuadores (RUSSELL; NORVIG, 2022). A **percepção** (*percept*) é a entrada recebida num instante; a **sequência de percepções** é o histórico completo dessas entradas. O comportamento do agente é descrito pela **função de agente**

$$f : \mathcal{P}^* \to \mathcal{A}$$

que leva toda sequência de percepções $\mathcal{P}^*$ a uma ação de $\mathcal{A}$. A função é a especificação; o **programa de agente** é a implementação que a realiza com memória finita.

Um **agente reativo simples** decide só pela percepção atual. Um agente que precisa levar em conta o que já percebeu mantém um estado interno, e a forma de representar esse estado define o tipo de agente.

### Agente baseado em conhecimento

Um **agente baseado em conhecimento** (*knowledge-based agent*) mantém o estado interno como uma **base de conhecimento** (*knowledge base*, KB): um conjunto de **sentenças** escritas numa linguagem formal de representação. A base é acessada por duas operações:

- **TELL**: acrescenta uma sentença à base;
- **ASK**: pergunta se uma sentença decorre da base.

A resposta do ASK não é uma busca textual pelo que foi inserido: é obtida por **inferência**, isto é, deduzida das sentenças presentes. O programa do agente, na formulação de Russell e Norvig (2022), é:

```text
função AGENTE-KB(percepção) retorna ação
    TELL(KB, sentença-da-percepção(percepção, t))
    ação <- ASK(KB, sentença-que-pergunta-a-ação(t))
    TELL(KB, sentença-da-ação(ação, t))
    t <- t + 1
    retorna ação
```

```text
            +-------------------- AGENTE -------------------+
            |                                               |
 percepção  |   TELL     +-----------------------+   ASK    |  ação
 ---------->|----------->|  base de conhecimento |<---------|------->
            |            |  (fatos + regras)     |          |
            |            +-----------+-----------+          |
            |                        |                      |
            |               motor de inferência             |
            +-----------------------------------------------+
                  ^                                    |
                  |             AMBIENTE               v
                  +------------------------------------+
```

A separação entre **o que o agente sabe** (a base) e **como ele deduz** (o motor de inferência) permite descrever o agente no **nível do conhecimento**: para mudar o comportamento, acrescentam-se ou alteram-se sentenças, sem reescrever o procedimento de decisão. É a mesma separação que define o paradigma lógico: o programa é a lógica, e o controle fica a cargo do interpretador (KOWALSKI, 1979).

### O agente baseado em conhecimento em Prolog

Prolog já fornece as três peças:

| Componente | Em Prolog |
|------------|-----------|
| base de conhecimento | fatos e regras (cláusulas de Horn) |
| TELL | `assertz/1`, `retract/1`, `retractall/1` sobre predicados declarados `:- dynamic` |
| ASK | uma consulta (`?- melhor_acao(A).`) |
| motor de inferência | resolução SLD com retrocesso, construída no interpretador |

A diretiva `:- dynamic p/1.` declara que o predicado `p/1` pode ganhar e perder cláusulas durante a execução. Sem ela, o predicado é tratado como parte fixa do programa. A base de conhecimento estática (as regras) e a dinâmica (os fatos que chegam pelas percepções) convivem no mesmo banco de cláusulas. O arquivo `codigo/00-base-dinamica.pl` demonstra, isoladamente e sobre uma fila de espera, `dynamic`, `assertz` (acrescenta no fim do predicado), `asserta` (no início), `retract`, `retractall` e a negação por falha `\+`, que é provada quando o objetivo não pode ser provado.

### Exemplo: agente de triagem que faz perguntas

O agente do exemplo conduz uma consulta: a cada passo, pergunta ao paciente por um sintoma ou conclui um diagnóstico. A **percepção** é a resposta do paciente (`sim` ou `nao`); as **ações** são `perguntar(Sintoma)` e `concluir(Diagnostico)`. O arquivo `codigo/01-agente-triagem.pl` separa o **ambiente** — um paciente simulado, acessado só por `responder/2` — do **agente**, que conhece apenas as respostas às perguntas que fez.

A base de conhecimento do agente tem duas partes. O **conhecimento do domínio** é fixo: cada doença e os sintomas que a confirmam, as mesmas regras do sistema de diagnóstico da nota sobre dedução, escritas como dados para que o agente possa escolher o que perguntar:

```prolog
doenca(gripe, [febre, dor_de_cabeca]).
doenca(dengue, [febre, fadiga, manchas_na_pele]).
```

O **conhecimento do caso** cresce a cada resposta. O TELL transforma a percepção em fato:

```prolog
informar(Sintoma, sim) :-
    assertz(confirmado(Sintoma)).
informar(Sintoma, nao) :-
    assertz(descartado(Sintoma)).
```

O ASK é uma consulta a regras de ação, em ordem de prioridade: concluir se alguma doença tem todos os sintomas confirmados; senão, perguntar o primeiro sintoma ainda desconhecido de uma doença que continua possível (nenhum sintoma dela descartado); senão, encerrar sem diagnóstico.

```prolog
melhor_acao(concluir(Doenca)) :-
    doenca(Doenca, Sintomas),
    todos_confirmados(Sintomas).
melhor_acao(perguntar(Sintoma)) :-
    doenca(_, Sintomas),
    nenhum_descartado(Sintomas),
    primeiro_desconhecido(Sintomas, Sintoma).
melhor_acao(concluir(sem_diagnostico)).
```

O ciclo começa pelo ASK, porque no início da consulta ainda não há percepção. Uma pergunta produz a resposta, que é informada à base antes do passo seguinte:

```prolog
ciclo(Passo) :-
    melhor_acao(Acao),
    format("passo ~w: ~w~n", [Passo, Acao]),
    agir(Acao, Passo).

agir(concluir(_), _).
agir(perguntar(Sintoma), Passo) :-
    responder(Sintoma, Resposta),
    format("        resposta: ~w~n", [Resposta]),
    informar(Sintoma, Resposta),
    Proximo is Passo + 1,
    ciclo(Proximo).
```

Para um paciente com febre, fadiga e manchas na pele:

```text
?- atender(bruno).
passo 1: perguntar(febre)
        resposta: sim
passo 2: perguntar(dor_de_cabeca)
        resposta: nao
passo 3: perguntar(fadiga)
        resposta: sim
passo 4: perguntar(manchas_na_pele)
        resposta: sim
passo 5: concluir(dengue)
```

Para um paciente só com tosse, a primeira resposta descarta as duas doenças:

```text
?- atender(carla).
passo 1: perguntar(febre)
        resposta: nao
passo 2: concluir(sem_diagnostico)
```

Três propriedades do exemplo:

- **A ordem das cláusulas é a prioridade.** No passo 5, a regra `concluir(dengue)` e a regra de encerrar sem diagnóstico são ambas deduzíveis da base. O Prolog tenta as cláusulas de cima para baixo, e a primeira que se prova decide; a última cláusula, sem condições, funciona como o caso padrão. A nota sobre condicionais mostra como tornar essa prioridade explícita com `->`.
- **O estado interno muda o comportamento.** No passo 3, a pergunta sobre fadiga só é escolhida porque a base registra `descartado(dor_de_cabeca)`, o que elimina a gripe, e `confirmado(febre)`, o que dispensa repetir a pergunta sobre febre para a dengue. Um agente reativo simples, que só vê a última resposta (`nao`), não sabe a que pergunta ela se refere nem o que já foi perguntado.
- **As perguntas seguem as regras.** O agente só pergunta o que alguma regra ainda pode usar, na ordem em que as premissas aparecem. Era assim que o MYCIN conduzia a consulta: quando uma premissa da regra em teste não estava na base, o sistema a perguntava ao médico (SHORTLIFFE, 1976). É o encadeamento para trás, tratado na nota sobre dedução, com o usuário como fonte de fatos.

### Sistemas especialistas

Um **sistema especialista** (*expert system*) é um agente baseado em conhecimento cuja base codifica o conhecimento de especialistas humanos num domínio restrito, em geral como regras de produção "se condições, então conclusão". A arquitetura clássica tem três partes: a **base de conhecimento** do domínio, o **motor de inferência**, que aplica as regras aos fatos do caso, e a **interface de explicação**, que mostra a cadeia de regras usada para chegar à conclusão.

| Sistema | Origem | Domínio | Estratégia de inferência |
|---------|--------|---------|--------------------------|
| DENDRAL | Stanford, a partir de 1965 | estrutura molecular a partir de espectrometria de massa (LINDSAY et al., 1993) | gerar hipóteses e testar contra regras do domínio |
| MYCIN | Stanford, 1976 | diagnóstico de infecções bacterianas e escolha de antibiótico (SHORTLIFFE, 1976) | encadeamento para trás, com fatores de certeza |
| XCON (R1) | DEC, 1980 | configuração de computadores VAX a partir do pedido do cliente (McDERMOTT, 1982) | encadeamento para frente (regras OPS5) |
| CLIPS | NASA, 1985 | ferramenta genérica para construir sistemas de regras, escrita em C | encadeamento para frente |

O encadeamento para trás parte da conclusão a provar e procura as regras e fatos que a sustentam; o encadeamento para frente parte dos fatos e dispara regras até não haver conclusão nova. A nota sobre lógica dedutiva formaliza as duas estratégias. O motor do Prolog faz encadeamento para trás, o mesmo do MYCIN; por isso um sistema especialista de diagnóstico se escreve em Prolog só com fatos e regras (`codigo/04-diagnostico.pl`).

Os limites desses sistemas são conhecidos desde os anos 1980: a **aquisição de conhecimento** (extrair e formalizar as regras de um especialista) é o gargalo de construção; o sistema é **frágil** fora do domínio, porque não tem regra para o que não foi previsto; e a manutenção de milhares de regras interdependentes cresce com a base. As aplicações atuais de regras — validação de pedidos, conformidade com normas, diagnóstico de falhas em equipamentos, regras de negócio em motores como o Drools — mantêm a arquitetura base + motor em domínios estreitos e estáveis.

## Fontes e leituras

KOWALSKI, R. Algorithm = logic + control. **Communications of the ACM**, v. 22, n. 7, p. 424-436, 1979.

LINDSAY, R. K. et al. DENDRAL: a case study of the first expert system for scientific hypothesis formation. **Artificial Intelligence**, v. 61, n. 2, p. 209-261, 1993.

McDERMOTT, J. R1: a rule-based configurer of computer systems. **Artificial Intelligence**, v. 19, n. 1, p. 39-88, 1982.

RUSSELL, S.; NORVIG, P. **Artificial intelligence**: a modern approach. 4. ed. Harlow: Pearson, 2022. Cap. 2 (agentes inteligentes) e cap. 7 (agentes lógicos).

SHORTLIFFE, E. H. **Computer-based medical consultations**: MYCIN. New York: Elsevier, 1976.

SWI-PROLOG. **Database**: assertz/1, retract/1, dynamic/1. Disponível em: https://www.swi-prolog.org/pldoc/man?section=db. Acesso em: 22 nov. 2026.
