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

#### 1.1. `parcela/4` - Cálculo de Parcela (Simplificado)
```prolog
% ============================================
% PARCELA/4
% ============================================
% Descrição: Calcula a parcela mensal estimada de um empréstimo usando fórmula
%            simplificada para fins didáticos. Não usa a fórmula Price completa,
%            mas uma aproximação linear que facilita o entendimento.
%
% Parâmetros:
%   - Valor: número (float) representando o valor total do empréstimo
%   - TaxaMes: número (float) representando a taxa de juros mensal (ex: 0.02 = 2%)
%   - Prazo: número inteiro representando o número de meses
%   - Prest: número (float) representando a parcela mensal calculada (saída)
%
% Comportamento:
%   - Usa fórmula simplificada: Prestacao = Valor * (Taxa + 1/Prazo)
%   - Componentes da fórmula:
%     * Taxa: custo dos juros por mês
%     * 1/Prazo: amortização linear do principal
%   - Não é a fórmula Price real (que usa juros compostos)
%   - Adequada para fins didáticos e estimativas rápidas
%
% Observações:
%   - Fórmula Price real: P = V * [i(1+i)^n] / [(1+i)^n - 1]
%   - Esta simplificação facilita cálculos manuais
%   - Resulta em valores aproximados (geralmente um pouco maiores)
%
% Exemplos de uso:
%   ?- parcela(10000, 0.02, 12, P).
%   P = 1033.33.  % R$ 10.000 a 2% a.m. em 12 meses
%
%   ?- parcela(50000, 0.015, 24, P).
%   P = 2833.33.  % R$ 50.000 a 1.5% a.m. em 24 meses
%
parcela(Valor, TaxaMes, Prazo, Prest).
```

#### 1.2. `dti/3` - DTI (Debt-to-Income Ratio)
```prolog
% ============================================
% DTI/3
% ============================================
% Descrição: Calcula o DTI (Debt-to-Income Ratio), que mede o percentual da renda
%            comprometido com dívidas. Métrica fundamental para análise de crédito.
%            DTI = (despesas + nova parcela) / renda * 100
%
% Parâmetros:
%   - Solicitante: átomo identificando o solicitante
%   - Parcela: número representando a parcela do novo empréstimo
%   - DTI: número (float) representando o DTI em percentual (saída)
%
% Comportamento:
%   - Obtém despesas mensais atuais do solicitante
%   - Obtém renda mensal do solicitante
%   - Verifica se renda > 0 (evita divisão por zero)
%   - Calcula: DTI = (Despesas + Parcela) / Renda * 100
%   - Retorna percentual (0-100+)
%
% Interpretação do DTI:
%   - DTI <= 25%: Excelente (baixo comprometimento)
%   - DTI 25-35%: Bom (comprometimento aceitável)
%   - DTI 35-45%: Alto (comprometimento elevado)
%   - DTI > 45%: Muito alto (risco significativo)
%
% Uso em análise de crédito:
%   - Indicador de capacidade de pagamento
%   - Quanto menor, melhor
%   - Bancos geralmente limitam DTI a 30-40%
%
% Exemplos de uso:
%   ?- dti(s1, 1000, DTI).
%   DTI = 25.0.  % renda 5000, despesas 250, parcela 1000
%
%   ?- dti(s2, 2000, DTI).
%   DTI = 50.0.  % renda 5000, despesas 500, parcela 2000 (alto!)
%
dti(Solicitante, Parcela, DTI).
```

#### 1.3. `ltv/3` - LTV (Loan-to-Value Ratio)
```prolog
% ============================================
% LTV/3
% ============================================
% Descrição: Calcula o LTV (Loan-to-Value Ratio), que mede o percentual do valor
%            da garantia que está sendo financiado. Usado principalmente em
%            financiamentos imobiliários. LTV = Valor Empréstimo / Valor Garantia * 100
%
% Parâmetros:
%   - Garantia: átomo identificando a garantia (ou sem_garantia)
%   - Valor: número representando o valor do empréstimo
%   - LTV: número (float) representando o LTV em percentual (saída)
%
% Comportamento:
%   - Caso especial: sem_garantia → LTV = 0
%   - Caso normal:
%     * Obtém valor da garantia
%     * Verifica se valor da garantia > 0
%     * Calcula: LTV = Valor / ValorGarantia * 100
%   - Retorna percentual (0-100+)
%
% Interpretação do LTV:
%   - LTV <= 70%: Baixo risco (garantia forte)
%   - LTV 70-85%: Risco moderado
%   - LTV 85-90%: Risco elevado (próximo do limite)
%   - LTV > 90%: Geralmente não aprovado
%
% Uso em financiamento imobiliário:
%   - Quanto menor, menor o risco para o banco
%   - LTV alto significa pouca entrada do cliente
%   - Bancos limitam LTV a 80-90% do valor do imóvel
%
% Exemplos de uso:
%   ?- ltv(sem_garantia, 50000, LTV).
%   LTV = 0.  % sem garantia
%
%   ?- ltv(g1, 200000, LTV).
%   LTV = 80.0.  % imóvel vale 250.000, financia 200.000
%
%   ?- ltv(g2, 180000, LTV).
%   LTV = 90.0.  % imóvel vale 200.000, financia 180.000 (limite!)
%
ltv(Garantia, Valor, LTV).
```

#### 1.4. `metricas/4` - Pacote Completo de Métricas
```prolog
% ============================================
% METRICAS/4
% ============================================
% Descrição: Agrega todas as métricas financeiras de uma proposta em um único
%            predicado, calculando DTI, LTV e parcela. Facilita análise completa.
%
% Parâmetros:
%   - ID: átomo identificando a proposta
%   - dti(DTI): termo estruturado contendo o DTI calculado
%   - ltv(LTV): termo estruturado contendo o LTV calculado (0 se não aplicável)
%   - parcela(Prest): termo estruturado contendo a parcela calculada
%
% Comportamento:
%   - Obtém dados da proposta (solicitante, produto, valor, prazo, taxa, garantia)
%   - Calcula parcela mensal
%   - Calcula DTI do solicitante com a nova parcela
%   - Se produto é financiamento imobiliário:
%     * Calcula LTV com a garantia
%   - Caso contrário:
%     * LTV = 0 (não aplicável)
%   - Retorna tripla de métricas estruturadas
%
% Lógica condicional:
%   - Usa herda_trans/2 para verificar hierarquia de produtos
%   - Financiamento imobiliário herda de produto base
%   - Apenas financiamentos imobiliários têm LTV relevante
%
% Uso:
%   - Predicado central para análise de crédito
%   - Agrega todas as métricas em uma consulta
%   - Facilita decisões baseadas em múltiplos indicadores
%
% Exemplos de uso:
%   ?- metricas(p1, dti(D), ltv(L), parcela(P)).
%   D = 28.5, L = 0, P = 1200.0.  % crédito pessoal
%
%   ?- metricas(p2, dti(D), ltv(L), parcela(P)).
%   D = 32.0, L = 85.0, P = 2500.0.  % financiamento imobiliário
%
metricas(ID, dti(DTI), ltv(LTV), parcela(Prest)).
```

### 2. Regras de Política (Hard Stops)

#### 2.1. `hardstop/2` - Restrições Absolutas
```prolog
% ============================================
% HARDSTOP/2
% ============================================
% Descrição: Identifica violações de políticas absolutas (hard stops) que resultam
%            em recusa automática da proposta, independente de outros fatores.
%            Hard stops são regras não negociáveis da instituição financeira.
%
% Parâmetros:
%   - ID: átomo identificando a proposta
%   - Motivo: átomo representando o tipo de violação (saída)
%
% Comportamento:
%   - Verifica múltiplas regras de política em paralelo
%   - Cada cláusula representa um hard stop diferente
%   - Sucede se houver pelo menos uma violação
%   - Pode retornar múltiplos motivos via backtracking
%   - Usado antes de qualquer análise de scoring
%
% Hard Stops Implementados:
%
%   1. **idade_minima**: Solicitante com idade < 18 anos
%      - Restrição legal (capacidade civil)
%      - Verifica fato idade/2
%
%   2. **sancao**: Solicitante em lista de sanções
%      - Lista restritiva (OFAC, PEP, etc.)
%      - Verifica fato em_lista_sancoes/2
%      - Compliance regulatório
%
%   3. **ltv_excedido**: LTV > 90% em financiamento imobiliário
%      - Política de risco da instituição
%      - Apenas para produtos imobiliários
%      - Usa herda_trans/2 para verificar tipo de produto
%
%   4. **renda_invalida**: Renda não informada ou <= 0
%      - Usa negação como falha (\+)
%      - Verifica ausência de fato renda/2 OU valor inválido
%      - Impossibilita cálculo de DTI
%
% Lógica de negação:
%   - Usa \+ (negação como falha) para verificar ausência
%   - Usa disjunção (;) para múltiplas condições de falha
%
% Exemplos de uso:
%   ?- hardstop(p1, M).
%   M = idade_minima.  % solicitante menor de idade
%
%   ?- hardstop(p2, M).
%   M = sancao.  % solicitante em lista restritiva
%
%   ?- hardstop(p3, M).
%   M = ltv_excedido.  % LTV 95% (acima do limite)
%
%   ?- hardstop(p4, M).
%   false.  % nenhum hard stop (pode prosseguir)
%
hardstop(ID, Motivo).
```

### 3. Sinais de Risco/Benefício

#### 3.1. `lim/2` - Classificação de DTI (Utilitário)
```prolog
% ============================================
% LIM/2
% ============================================
% Descrição: Classifica o DTI em faixas qualitativas (bom, ok, alto, ruim).
%            Predicado utilitário usado pelos sinais de risco.
%
% Parâmetros:
%   - DTI: número representando o DTI em percentual
%   - Classificacao: átomo representando a faixa (bom, ok, alto, ruim)
%
% Comportamento:
%   - DTI <= 25: bom (baixo comprometimento)
%   - DTI 25-35: ok (comprometimento aceitável)
%   - DTI 35-45: alto (comprometimento elevado)
%   - DTI > 45: ruim (comprometimento crítico)
%
% Exemplos de uso:
%   ?- lim(20, C).
%   C = bom.
%
%   ?- lim(30, C).
%   C = ok.
%
lim(DTI, Classificacao).
```

#### 3.2. `sinal/3` - Sinais de Risco e Benefício
```prolog
% ============================================
% SINAL/3
% ============================================
% Descrição: Identifica sinais de risco (peso positivo) ou benefício (peso negativo)
%            em uma proposta de crédito. Cada sinal contribui para o score final.
%            Múltiplos sinais podem ser aplicáveis a uma mesma proposta.
%
% Parâmetros:
%   - ID: átomo identificando a proposta
%   - Label: átomo identificando o tipo de sinal
%   - Peso: número inteiro representando o impacto no score
%           (negativo = benefício, positivo = risco)
%
% Comportamento:
%   - Cada cláusula representa um sinal diferente
%   - Sinais são independentes (podem coexistir)
%   - Pesos são somados para calcular score final
%   - Usa backtracking para retornar todos os sinais aplicáveis
%
% Sinais Implementados:
%
%   **1. Sinais de DTI** (baseados em faixas):
%   - dti_bom (-20): DTI <= 25% (excelente capacidade)
%   - dti_ok (-10): DTI 25-35% (boa capacidade)
%   - dti_alto (+15): DTI 35-45% (capacidade limitada)
%   - dti_ruim (+30): DTI > 45% (capacidade crítica)
%
%   **2. Sinais de LTV** (apenas financiamento imobiliário):
%   - ltv_saude (-15): LTV <= 70% (garantia forte)
%   - ltv_medio (+5): LTV 70-85% (garantia moderada)
%   - ltv_limite (+15): LTV 85-90% (garantia fraca)
%
%   **3. Sinais de Score de Bureau** (histórico de crédito):
%   - bureau_excelente (-25): Score >= 750 (histórico excelente)
%   - bureau_medio (+10): Score 600-749 (histórico mediano)
%   - bureau_baixo (+25): Score < 600 (histórico ruim)
%
%   **4. Sinais de Comportamento**:
%   - atrasos_rec (+20): >= 2 atrasos nos últimos 12 meses
%   - consultas_alta (+10): >= 3 consultas nos últimos 30 dias
%
%   **5. Sinais de Emprego**:
%   - emprego_estavel (-10): >= 24 meses no emprego atual
%   - emprego_recente (+8): < 12 meses no emprego atual
%
%   **6. Sinais Compostos**:
%   - stress_parcela_pessoal (+15): Crédito pessoal com DTI >= 35%
%   - perfil_premium (-15): DTI <= 25% E score >= 780
%
% Interpretação dos pesos:
%   - Pesos negativos reduzem score (benefícios)
%   - Pesos positivos aumentam score (riscos)
%   - Magnitude reflete importância do fator
%
% Exemplos de uso:
%   ?- sinal(p1, L, P).
%   L = dti_bom, P = -20 ;
%   L = bureau_excelente, P = -25 ;
%   L = emprego_estavel, P = -10.
%
%   ?- sinal(p2, bureau_baixo, P).
%   P = 25.  % verifica se sinal específico se aplica
%
sinal(ID, Label, Peso).
```

### 4. Agregação, Decisão e Explicação

#### 4.1. `sinais/2` - Coleta de Sinais Aplicáveis
```prolog
% ============================================
% SINAIS/2
% ============================================
% Descrição: Coleta todos os sinais de risco e benefício aplicáveis a uma proposta,
%            retornando uma lista de pares (Label, Peso).
%
% Parâmetros:
%   - ID: átomo identificando a proposta
%   - Lista: lista de pares (Label, Peso) com todos os sinais aplicáveis
%
% Comportamento:
%   - Usa findall/3 para coletar todos os sinais
%   - Cada elemento é um par (Label, Peso)
%   - Lista pode estar vazia (nenhum sinal aplicável)
%   - Lista pode ter múltiplos elementos
%
% Exemplos de uso:
%   ?- sinais(p1, L).
%   L = [(dti_bom, -20), (bureau_excelente, -25), (emprego_estavel, -10)].
%
sinais(ID, Lista).
```

#### 4.2. `pontuacao/3` - Cálculo de Score Total
```prolog
% ============================================
% PONTUACAO/3
% ============================================
% Descrição: Calcula o score total de risco de uma proposta somando os pesos de
%            todos os sinais aplicáveis. Retorna também a lista de evidências.
%
% Parâmetros:
%   - ID: átomo identificando a proposta
%   - Score: número inteiro representando o score total (saída)
%   - Evid: lista de pares (Label, Peso) usados no cálculo (saída)
%
% Comportamento:
%   - Coleta todos os sinais da proposta
%   - Extrai apenas os pesos (segundo elemento dos pares)
%   - Soma todos os pesos usando sum_list/2
%   - Retorna score e evidências
%
% Interpretação do score:
%   - Score < 20: Baixo risco (aprovar)
%   - Score 20-49: Risco moderado (revisar)
%   - Score >= 50: Alto risco (recusar)
%   - Score negativo: Perfil excelente (muitos benefícios)
%
% Exemplos de uso:
%   ?- pontuacao(p1, S, E).
%   S = -55, E = [(dti_bom, -20), (bureau_excelente, -25), (perfil_premium, -15)].
%
pontuacao(ID, Score, Evid).
```

#### 4.3. `limiar_revisao/1` e `limiar_recusa/1` - Limiares de Decisão
```prolog
% ============================================
% LIMIAR_REVISAO/1 e LIMIAR_RECUSA/1
% ============================================
% Descrição: Define os limiares de score para decisões de crédito.
%            Configuráveis pela instituição financeira.
%
% Parâmetros:
%   - Limiar: número inteiro representando o limiar
%
% Comportamento:
%   - limiar_revisao(20): Score >= 20 requer revisão manual
%   - limiar_recusa(50): Score >= 50 resulta em recusa automática
%
% Exemplos de uso:
%   ?- limiar_revisao(L).
%   L = 20.
%
limiar_revisao(Limiar).
limiar_recusa(Limiar).
```

#### 4.4. `decisao/2` - Decisão Final de Crédito
```prolog
% ============================================
% DECISAO/2
% ============================================
% Descrição: Determina a decisão final sobre uma proposta de crédito, considerando
%            hard stops e score de risco. Implementa a lógica de decisão completa.
%
% Parâmetros:
%   - ID: átomo identificando a proposta
%   - Decisao: átomo representando a decisão (aprovar, revisar, recusar)
%
% Comportamento:
%   - **Prioridade 1**: Verifica hard stops
%     * Se houver qualquer hard stop → recusar (com cut!)
%     * Cut (!) impede backtracking para outras cláusulas
%   - **Prioridade 2**: Calcula score e compara com limiares
%     * Score < 20 → aprovar (baixo risco)
%     * Score 20-49 → revisar (risco moderado, análise manual)
%     * Score >= 50 → recusar (alto risco)
%
% Lógica de decisão:
%   1. Hard stops têm precedência absoluta
%   2. Aprovação automática para baixo risco
%   3. Revisão manual para risco moderado
%   4. Recusa automática para alto risco
%
% Uso do cut (!):
%   - Garante que hard stops sempre resultam em recusa
%   - Evita múltiplas decisões para mesma proposta
%   - Otimiza performance (não testa outras cláusulas)
%
% Exemplos de uso:
%   ?- decisao(p1, D).
%   D = aprovar.  % score -55 (muito bom)
%
%   ?- decisao(p2, D).
%   D = revisar.  % score 25 (moderado)
%
%   ?- decisao(p3, D).
%   D = recusar.  % score 60 (alto risco)
%
%   ?- decisao(p4, D).
%   D = recusar.  % tem hard stop (idade_minima)
%
decisao(ID, Decisao).
```

#### 4.5. `rotulo/2` e `rotulo_hard/2` - Rótulos Legíveis
```prolog
% ============================================
% ROTULO/2 e ROTULO_HARD/2
% ============================================
% Descrição: Traduz códigos de sinais e hard stops em mensagens legíveis para
%            humanos. Essencial para explicabilidade do sistema.
%
% Parâmetros:
%   - Codigo: átomo representando o código do sinal ou hard stop
%   - Mensagem: string contendo a descrição legível
%
% Comportamento:
%   - rotulo/2: traduz sinais de risco/benefício
%   - rotulo_hard/2: traduz hard stops
%   - Cada código tem uma mensagem associada
%   - Usado para gerar explicações humanizadas
%
% Exemplos de uso:
%   ?- rotulo(dti_bom, M).
%   M = 'DTI muito saudável'.
%
%   ?- rotulo_hard(idade_minima, M).
%   M = 'idade abaixo do mínimo legal'.
%
rotulo(Codigo, Mensagem).
rotulo_hard(Codigo, Mensagem).
```

#### 4.6. `motivos/2` - Explicação Humanizada
```prolog
% ============================================
% MOTIVOS/2
% ============================================
% Descrição: Gera uma lista de motivos legíveis que explicam a decisão de crédito.
%            Prioriza hard stops se existirem, caso contrário lista todos os sinais.
%
% Parâmetros:
%   - ID: átomo identificando a proposta
%   - Motivos: lista de strings contendo explicações legíveis
%
% Comportamento:
%   - **Caso 1**: Se houver hard stops
%     * Coleta todos os hard stops
%     * Traduz usando rotulo_hard/2
%     * Converte para strings
%     * Retorna apenas hard stops (são suficientes para explicar recusa)
%   - **Caso 2**: Se não houver hard stops
%     * Coleta todos os sinais
%     * Traduz usando rotulo/2
%     * Converte para strings
%     * Retorna lista completa de sinais
%
% Lógica condicional:
%   - Usa if-then-else (-> ; )
%   - Verifica se lista de hard stops não é vazia (Hs \= [])
%   - Prioriza hard stops sobre sinais
%
% Uso para explicabilidade:
%   - Permite justificar decisões para clientes
%   - Facilita auditoria e compliance
%   - Ajuda analistas em revisões manuais
%
% Exemplos de uso:
%   ?- motivos(p1, M).
%   M = ['DTI muito saudável', 'score de crédito excelente', 'emprego estável (>=24m)'].
%
%   ?- motivos(p4, M).
%   M = ['idade abaixo do mínimo legal'].  % hard stop
%
motivos(ID, Motivos).
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

