**Tema:** 💰 Sistema de Concessão de Crédito

---

## 🎯 Objetivo

Modelar, em **Prolog**, um motor de crédito que:

1. Representa uma **ontologia** de solicitantes, produtos, garantias e empregadores
2. Avalia **regras de política** (hard stops): idade mínima, sanções, LTV máximo
3. Calcula **métricas financeiras** e **sinais** (positivos/negativos) com **pesos**:
   - **DTI** (Debt-to-Income): razão entre dívidas e renda
   - **LTV** (Loan-to-Value): razão entre empréstimo e valor da garantia
   - **Parcela estimada**: prestação mensal do empréstimo
4. Agrega pontuação e decide: **aprovar** / **revisar** / **recusar**
5. Explica **por que** foi (ou não) aprovado

### 📚 Glossário de Siglas Financeiras

| Sigla | Nome Completo | Significado |
|-------|---------------|-------------|
| **DTI** | Debt-to-Income Ratio | Percentual da renda comprometido com dívidas. Quanto menor, melhor. Ex: DTI de 30% significa que 30% da renda vai para pagamento de dívidas. |
| **LTV** | Loan-to-Value Ratio | Percentual do valor da garantia que está sendo financiado. Quanto menor, menor o risco. Ex: LTV de 80% significa que o empréstimo é 80% do valor do imóvel. |
| **Hard Stop** | Regra Eliminatória | Condição que automaticamente recusa a proposta, independente de outros fatores (ex: idade < 18 anos). |
| **Score** | Pontuação de Crédito | Nota que representa o risco de crédito, geralmente de 0 a 1000. Quanto maior, melhor o histórico. |

Consultas esperadas:

```prolog
pontuacao(loan1, Score, Evidencias).
decisao(loan1, Acao).
motivos(loan1, ListaExplicativa).
metricas(loan1, dti(DTI), ltv(LTV), parcela(Parc)).
```

---

## 🧩 Descrição do Problema

Você é um **analista de crédito** responsável por avaliar propostas de empréstimo.

Cada proposta envolve um solicitante com histórico financeiro, um produto de crédito (pessoal, imobiliário, cartão) e, opcionalmente, uma garantia (imóvel, veículo).

Implemente um sistema lógico que:
- Calcule métricas financeiras automaticamente
- Aplique regras de política (hard stops) que eliminam propostas inviáveis
- Avalie sinais de risco e benefício com pesos configuráveis
- Agregue uma pontuação final e tome decisão
- Explique de forma clara os motivos da decisão

---

## 🧩 Base de Fatos (Ontologia + Dados Didáticos)

### Ontologia
```prolog
% =========================
% ONTOLOGIA
% =========================
classe(entidade).
classe(pessoa).          herda(pessoa, entidade).
classe(solicitante).     herda(solicitante, pessoa).
classe(empregador).      herda(empregador, entidade).
classe(produto_credito). herda(produto_credito, entidade).
classe(garantia).        herda(garantia, entidade).

% Subclasses de produtos
classe(credito_pessoal).           herda(credito_pessoal, produto_credito).
classe(financiamento_imobiliario). herda(financiamento_imobiliario, produto_credito).
classe(cartao_credito).            herda(cartao_credito, produto_credito).

% Subclasses de garantias
classe(imovel).  herda(imovel, garantia).
classe(veiculo). herda(veiculo, garantia).

% Herança transitiva
herda_trans(F, P) :- herda(F, P).
herda_trans(F, Avo) :- herda(F, P), herda_trans(P, Avo).
```

### Entidades
```prolog
% =========================
% ENTIDADES
% =========================
instancia(ana,   solicitante).
instancia(bruno, solicitante).

instancia(fab_tech, empregador).
instancia(loja_xyz, empregador).

instancia(casa_ana, imovel).
instancia(carro_bruno, veiculo).
```

### Atributos dos Solicitantes
```prolog
% =========================
% ATRIBUTOS DO SOLICITANTE
% =========================
% Idade em anos
idade(ana,   29).
idade(bruno, 22).

% Renda mensal declarada (BRL)
renda(ana,   7800).
renda(bruno, 2800).

% Despesas/compromissos mensais (BRL)
despesa(ana,   2200).
despesa(bruno,  900).

% Tempo de emprego em meses
tempo_emprego(ana, fab_tech, 36).
tempo_emprego(bruno, loja_xyz, 8).

% Score de bureau (0-1000)
score_bureau(ana,   765).
score_bureau(bruno, 560).

% Atrasos nos últimos 12 meses
atrasos_12m(ana,   0).
atrasos_12m(bruno, 2).

% Consultas de crédito nos últimos 30 dias
consultas_30d(ana,   1).
consultas_30d(bruno, 4).

% Bandeiras
em_lista_sancoes(bruno, nao).
em_lista_sancoes(ana, nao).
```

### Garantias e Propostas
```prolog
% =========================
% DADOS DAS GARANTIAS (quando houver)
% =========================
valor_garantia(casa_ana,    520000).
valor_garantia(carro_bruno, 48000).

% =========================
% PRODUTOS (propostas)
% proposta(Id, Solicitante, Produto, Valor, PrazoMeses, TaxaMes, GarantiaOpcional)
% TaxaMes = juros simples aproximado (para exercício didático)
% =========================
proposta(loan1, ana,   financiamento_imobiliario, 390000, 360, 0.012, casa_ana).
proposta(loan2, bruno, credito_pessoal,              12000,  24, 0.025, sem_garantia).
```

---

## 🎯 Objetivos de Aprendizagem

- Modelar ontologias com herança em Prolog
- Implementar regras de política (hard stops) vs. scoring ponderado
- Realizar cálculos lógicos (DTI, LTV, parcela)
- Combinar evidências para decisão multicritério
- Gerar explicações automáticas
- Explorar cenários "what-if"

---

## 📂 Estrutura dos Arquivos

**Entrada:** `entrada.txt` - Ontologia, solicitantes, propostas, garantias
**Prolog:** `principal.pl`, `ontologia.pl`, `metricas.pl`, `politicas.pl`, `sinais.pl`, `decisao.pl`, `explicacao.pl`
**Saída:** `saida.txt` - Análise de propostas com decisões e justificativas

---

## 🧱 Tarefas Obrigatórias

### 1. Métricas Financeiras

#### 📐 Cálculo de Parcela (Simplificado)
```prolog
% Parcela estimada simplificada (didática):
% Prestacao = Valor * (Taxa + 1/Prazo)
parcela(Valor, TaxaMes, Prazo, Prest) :-
    Prest is Valor * (TaxaMes + 1.0 / Prazo).
```

#### 📊 DTI (Debt-to-Income Ratio)
```prolog
% DTI = (despesa + parcela) / renda * 100
% Quanto menor o DTI, melhor (menos comprometimento da renda)
dti(Solicitante, Parcela, DTI) :-
    despesa(Solicitante, Desp),
    renda(Solicitante, R),
    R > 0,
    DTI is (Desp + Parcela) / R * 100.
```

#### 🏠 LTV (Loan-to-Value Ratio)
```prolog
% LTV = ValorEmprestimo / ValorGarantia * 100
% Quanto menor o LTV, menor o risco (mais garantia)
ltv(sem_garantia, _, 0).
ltv(Garantia, Valor, LTV) :-
    valor_garantia(Garantia, VG),
    VG > 0,
    LTV is Valor / VG * 100.
```

#### 📦 Pacote de Métricas
```prolog
% Agrega todas as métricas de uma proposta
metricas(ID, dti(DTI), ltv(LTV), parcela(Prest)) :-
    proposta(ID, Sol, Prod, Valor, Prazo, Taxa, Gar),
    parcela(Valor, Taxa, Prazo, Prest),
    dti(Sol, Prest, DTI),
    ( herda_trans(Prod, financiamento_imobiliario) ->
        ltv(Gar, Valor, LTV)
    ;   LTV = 0
    ).
```

### 2. Regras de Política (Hard Stops)

```prolog
% 🚫 Idade mínima legal
hardstop(ID, idade_minima) :-
    proposta(ID, Sol, _, _, _, _, _),
    idade(Sol, I),
    I < 18.

% 🚫 Sanções/Lista restritiva
hardstop(ID, sancao) :-
    proposta(ID, Sol, _, _, _, _, _),
    em_lista_sancoes(Sol, sim).

% 🚫 LTV máximo por produto (ex.: imobiliário <= 90%)
hardstop(ID, ltv_excedido) :-
    proposta(ID, _, Prod, Valor, _, _, Gar),
    herda_trans(Prod, financiamento_imobiliario),
    ltv(Gar, Valor, L),
    L > 90.

% 🚫 Renda inválida
hardstop(ID, renda_invalida) :-
    proposta(ID, Sol, _, _, _, _, _),
    ( \+ renda(Sol, _) ; renda(Sol, R), R =< 0 ).
```

### 3. Sinais de Risco/Benefício

```prolog
% Utilitário: classificação de DTI
lim(DTI, bom)   :- DTI =< 25.
lim(DTI, ok)    :- DTI > 25, DTI =< 35.
lim(DTI, alto)  :- DTI > 35, DTI =< 45.
lim(DTI, ruim)  :- DTI > 45.

% 1️⃣ DTI (maior DTI => mais risco)
sinal(ID, dti_bom,  -20) :- metricas(ID, dti(D), _, _), lim(D, bom).
sinal(ID, dti_ok,   -10) :- metricas(ID, dti(D), _, _), lim(D, ok).
sinal(ID, dti_alto,  15) :- metricas(ID, dti(D), _, _), lim(D, alto).
sinal(ID, dti_ruim,  30) :- metricas(ID, dti(D), _, _), lim(D, ruim).

% 2️⃣ LTV (apenas para imobiliário)
sinal(ID, ltv_saude, -15) :- metricas(ID, _, ltv(L), _), L > 0, L =< 70.
sinal(ID, ltv_medio,   5) :- metricas(ID, _, ltv(L), _), L > 70, L =< 85.
sinal(ID, ltv_limite, 15) :- metricas(ID, _, ltv(L), _), L > 85, L =< 90.

% 3️⃣ Score de bureau
sinal(ID, bureau_excelente, -25) :-
    proposta(ID, Sol, _, _, _, _, _),
    score_bureau(Sol, S), S >= 750.
sinal(ID, bureau_medio, 10) :-
    proposta(ID, Sol, _, _, _, _, _),
    score_bureau(Sol, S), S >= 600, S < 750.
sinal(ID, bureau_baixo, 25) :-
    proposta(ID, Sol, _, _, _, _, _),
    score_bureau(Sol, S), S < 600.

% 4️⃣ Atrasos / consultas recentes
sinal(ID, atrasos_rec, 20) :-
    proposta(ID, Sol, _, _, _, _, _),
    atrasos_12m(Sol, N), N >= 2.
sinal(ID, consultas_alta, 10) :-
    proposta(ID, Sol, _, _, _, _, _),
    consultas_30d(Sol, Q), Q >= 3.

% 5️⃣ Antiguidade no emprego
sinal(ID, emprego_estavel, -10) :-
    proposta(ID, Sol, _, _, _, _, _),
    tempo_emprego(Sol, _, Meses), Meses >= 24.
sinal(ID, emprego_recente, 8) :-
    proposta(ID, Sol, _, _, _, _, _),
    tempo_emprego(Sol, _, Meses), Meses < 12.

% 6️⃣ Valor/parcela elevada em crédito pessoal (stress)
sinal(ID, stress_parcela_pessoal, 15) :-
    proposta(ID, Sol, Prod, Valor, Prazo, Taxa, _),
    herda_trans(Prod, credito_pessoal),
    parcela(Valor, Taxa, Prazo, Prest),
    dti(Sol, Prest, DTI), DTI >= 35.

% 7️⃣ Benefício por DTI + bureau fortes (perfil premium)
sinal(ID, perfil_premium, -15) :-
    metricas(ID, dti(D), _, _), D =< 25,
    proposta(ID, Sol, _, _, _, _, _),
    score_bureau(Sol, S), S >= 780.
```

### 4. Agregação, Decisão e Explicação

```prolog
% Coleta todos os sinais aplicáveis
sinais(ID, Lista) :-
    findall((Lbl, P), sinal(ID, Lbl, P), Lista).

% Pontuação total (soma dos pesos)
pontuacao(ID, Score, Evid) :-
    sinais(ID, S),
    findall(P, member((_, P), S), Ps),
    sum_list(Ps, Score),
    Evid = S.

% Limiares de decisão
limiar_revisao(20).
limiar_recusa(50).

% Decisão considerando hard stops primeiro
decisao(ID, recusar) :-
    hardstop(ID, _), !.
decisao(ID, aprovar) :-
    pontuacao(ID, S, _),
    limiar_revisao(Lr),
    S < Lr.
decisao(ID, revisar) :-
    pontuacao(ID, S, _),
    limiar_revisao(Lr), limiar_recusa(Ld),
    S >= Lr, S < Ld.
decisao(ID, recusar) :-
    pontuacao(ID, S, _),
    limiar_recusa(Ld),
    S >= Ld.

% Rótulos legíveis para sinais
rotulo(dti_bom,                  'DTI muito saudável').
rotulo(dti_ok,                   'DTI aceitável').
rotulo(dti_alto,                 'DTI elevado').
rotulo(dti_ruim,                 'DTI muito elevado').
rotulo(ltv_saude,                'LTV baixo (garantia forte)').
rotulo(ltv_medio,                'LTV moderado').
rotulo(ltv_limite,               'LTV próximo do limite').
rotulo(bureau_excelente,         'score de crédito excelente').
rotulo(bureau_medio,             'score de crédito mediano').
rotulo(bureau_baixo,             'score de crédito baixo').
rotulo(atrasos_rec,              'atrasos recentes em pagamentos').
rotulo(consultas_alta,           'muitas consultas recentes').
rotulo(emprego_estavel,          'emprego estável (>=24m)').
rotulo(emprego_recente,          'emprego recente (<12m)').
rotulo(stress_parcela_pessoal,   'parcela alta para crédito pessoal').
rotulo(perfil_premium,           'perfil premium (DTI baixo + bureau alto)').

% Rótulos para hard stops
rotulo_hard(idade_minima,   'idade abaixo do mínimo legal').
rotulo_hard(sancao,         'solicitante em lista de sanções').
rotulo_hard(ltv_excedido,   'LTV excede o limite da política').
rotulo_hard(renda_invalida, 'renda inválida ou não informada').

% Motivos legíveis (sinais + hard stops, se houver)
motivos(ID, Motivos) :-
    ( findall(T,
              (hardstop(ID, H), rotulo_hard(H, R), atom_string(R, T)),
              Hs),
      Hs \= [] ->
        Motivos = Hs
    ; sinais(ID, S),
      findall(Tx,
              (member((Lbl, _), S), rotulo(Lbl, R), atom_string(R, Tx)),
              Motivos)
    ).
```

---

## ✨ Extensões (Escolha pelo menos UMA)

| Tema Lógico | Extensão Prática |
|-------------|------------------|
| **Política por Produto** | DTI/LTV e limiares distintos por `produto_credito`. Implementar `limiar_dti_produto/2` e `limiar_ltv_produto/2` que variam conforme o tipo de crédito. |
| **Risco Setorial** | Adicionar `setor_empregador/2` (tecnologia, varejo, construção) com pesos por setor. Setores sazonais ou voláteis aumentam risco. |
| **Garantias Múltiplas** | Permitir múltiplas garantias por proposta. Implementar `soma_garantias/2` e calcular LTV sobre o total. |
| **Tempo e Histórico** | Janelas deslizantes para renda variável (últimos 6 meses). Redução de risco por tempo de relacionamento com o banco. |
| **ABAC Leve** | Atributos adicionais (estado civil, dependentes) com regras condicionais. Ex: casado com dependentes → maior estabilidade. |
| **Otimização** | Sugerir **contraproposta**: reduzir valor/prazo para atingir DTI alvo. Implementar `contraproposta/5` que ajusta parâmetros. |
| **Explicabilidade Avançada** | Implementar `por_que/2` retornando `(regra -> fatos_usados)` com rastro completo de decisão, mostrando cada validação. |

### Exemplo de Extensão: Otimização (Contraproposta)
```prolog
% Sugere ajustes para atingir DTI alvo
contraproposta(ID, ValorNovo, PrazoNovo, DTINovo, Ajuste) :-
    proposta(ID, Sol, Prod, ValorOrig, PrazoOrig, Taxa, Gar),
    metricas(ID, dti(DTIOrig), _, _),
    DTIOrig > 35,  % DTI muito alto
    % Tentar reduzir valor em 20%
    ValorNovo is ValorOrig * 0.8,
    PrazoNovo = PrazoOrig,
    parcela(ValorNovo, Taxa, PrazoNovo, PrestNova),
    dti(Sol, PrestNova, DTINovo),
    DTINovo =< 35,
    Ajuste = 'reduzir valor em 20%'.

contraproposta(ID, ValorNovo, PrazoNovo, DTINovo, Ajuste) :-
    proposta(ID, Sol, Prod, ValorOrig, PrazoOrig, Taxa, Gar),
    metricas(ID, dti(DTIOrig), _, _),
    DTIOrig > 35,
    % Tentar aumentar prazo em 50%
    ValorNovo = ValorOrig,
    PrazoNovo is PrazoOrig * 1.5,
    parcela(ValorNovo, Taxa, PrazoNovo, PrestNova),
    dti(Sol, PrestNova, DTINovo),
    DTINovo =< 35,
    Ajuste = 'aumentar prazo em 50%'.

% Exemplo de uso:
% ?- contraproposta(loan2, V, P, DTI, A).
% V = 9600, P = 24, DTI = 51.42857142857143, A = 'reduzir valor em 20%' ;
% V = 12000, P = 36, DTI = 47.61904761904762, A = 'aumentar prazo em 50%'.
```

---

## ▶️ Exemplos de Execução

```prolog
% 1) Métricas das propostas
?- metricas(loan1, DTI, LTV, Parc).
DTI = dti(55.64102564102564),
LTV = ltv(75.0),
Parc = parcela(1366.6666666666667).

?- metricas(loan2, DTI, LTV, Parc).
DTI = dti(60.71428571428571),
LTV = ltv(0),
Parc = parcela(700.0).

% 2) Sinais, pontuação e decisão para loan1 (Ana - Financiamento Imobiliário)
?- sinais(loan1, S), pontuacao(loan1, Score, _), decisao(loan1, D), motivos(loan1, M).
S = [(dti_ruim, 30), (ltv_medio, 5), (bureau_excelente, -25), (emprego_estavel, -10)],
Score = 0,
D = aprovar,
M = ["DTI muito elevado", "LTV moderado", "score de crédito excelente",
     "emprego estável (>=24m)"].

% 3) Sinais, pontuação e decisão para loan2 (Bruno - Crédito Pessoal)
?- sinais(loan2, S), pontuacao(loan2, Score, _), decisao(loan2, D), motivos(loan2, M).
S = [(dti_ruim, 30), (bureau_baixo, 25), (atrasos_rec, 20), (consultas_alta, 10),
     (emprego_recente, 8), (stress_parcela_pessoal, 15)],
Score = 108,
D = recusar,
M = ["DTI muito elevado", "score de crédito baixo", "atrasos recentes em pagamentos",
     "muitas consultas recentes", "emprego recente (<12m)",
     "parcela alta para crédito pessoal"].

% 4) Verificar hard stops (se existissem)
?- hardstop(loan1, H).
false.

?- hardstop(loan2, H).
false.

% 5) Explicabilidade curta para comitê
?- decisao(loan2, D), pontuacao(loan2, S, _), motivos(loan2, M).
D = recusar,
S = 108,
M = ["DTI muito elevado", "score de crédito baixo", "atrasos recentes em pagamentos",
     "muitas consultas recentes", "emprego recente (<12m)",
     "parcela alta para crédito pessoal"].

% 6) Listar todas as propostas e suas decisões
?- proposta(ID, Sol, Prod, _, _, _, _), decisao(ID, D).
ID = loan1, Sol = ana, Prod = financiamento_imobiliario, D = aprovar ;
ID = loan2, Sol = bruno, Prod = credito_pessoal, D = recusar.

% 7) Verificar apenas sinais positivos (benefícios)
?- sinal(loan1, Lbl, P), P < 0.
Lbl = bureau_excelente, P = -25 ;
Lbl = emprego_estavel, P = -10.

% 8) Verificar apenas sinais negativos (riscos)
?- sinal(loan2, Lbl, P), P > 0.
Lbl = dti_ruim, P = 30 ;
Lbl = bureau_baixo, P = 25 ;
Lbl = atrasos_rec, P = 20 ;
Lbl = consultas_alta, P = 10 ;
Lbl = emprego_recente, P = 8 ;
Lbl = stress_parcela_pessoal, P = 15.

% 9) Simular alteração de limiar (what-if)
?- retract(limiar_revisao(20)), assert(limiar_revisao(10)), decisao(loan1, D).
D = revisar.  % Com limiar mais rigoroso, loan1 vai para revisão

% 10) Verificar herança da ontologia
?- herda_trans(financiamento_imobiliario, produto_credito).
true.

?- herda_trans(credito_pessoal, entidade).
true.
```

---

## 🧠 Conceitos Aplicados

Este trabalho exercita os seguintes conceitos de Programação Lógica:

- **Ontologia + Herança**
  - Modelagem de classes e subclasses (solicitante, produto, garantia)
  - Herança transitiva (`herda_trans/2`)
  - Instanciação de entidades

- **Regras de Política (Hard Stops) vs. Scoring**
  - Regras eliminatórias que recusam automaticamente
  - Sistema de pontuação ponderada com sinais positivos/negativos
  - Separação clara entre restrições absolutas e avaliação gradual

- **Cálculos Lógicos**
  - DTI (Debt-to-Income): comprometimento de renda
  - LTV (Loan-to-Value): razão empréstimo/garantia
  - Parcela estimada com juros simplificados
  - Agregação de métricas financeiras

- **Combinação de Evidências**
  - Coleta de múltiplos sinais com `findall/3`
  - Agregação de pesos com `sum_list/2`
  - Decisão multicritério baseada em limiares

- **Explicabilidade**
  - Rótulos legíveis para sinais técnicos
  - Justificativas automáticas de decisões
  - Rastreamento de motivos de recusa
  - Transparência no processo decisório

- **Exploração "What-If"**
  - Alteração dinâmica de pesos e limiares
  - Simulação de cenários
  - Contrapropostas automáticas
  - Análise de sensibilidade

---

## 📊 Critérios de Avaliação

- **Corretude das regras** (30%): Implementação correta das restrições
- **Derivação lógica** (15%): Uso adequado de backtracking e busca
- **Explicabilidade** (20%): Justificativas claras e completas
- **Extensão implementada** (15%): Implementação correta de pelo menos uma extensão
- **Organização do código** (10%): Modularização e clareza
- **Documentação** (10%): Comentários e exemplos

---

## 📝 Observações

- Base: **5+ solicitantes**, **8+ propostas**, **3+ garantias**
- Teste: aprovação, revisão, recusa, hard stops
- Implemente **8+ sinais** diferentes
- Limiares configuráveis
- Explicações automáticas

