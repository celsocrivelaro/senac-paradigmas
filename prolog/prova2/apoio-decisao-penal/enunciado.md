**Tema:** ⚖️ Sistema de Apoio à Decisão Penal

---

## 🧩 Descrição do Problema

Você deve implementar um **sistema de apoio à decisão penal** em Prolog que simula o raciocínio jurídico para análise de casos criminais. O sistema deve:

- **Modelar o domínio penal** com tipos penais (furto, roubo), qualificadoras, situação fática e situação pessoal do réu
- **Aplicar regras jurídicas com exceções**, como:
  - Princípio da insignificância (valor irrisório + ausência de violência → atipicidade)
  - Furto privilegiado (primariedade + pequeno valor + sem violência → redução de pena)
  - Reincidência afasta benefícios (exceção que impede aplicação de institutos favoráveis)
- **Consultar precedentes jurisprudenciais** respeitando hierarquia de tribunais (STF > STJ > TJ) e vinculação
- **Usar negação como falha** (`\+`) para verificar hipóteses não provadas
- **Produzir decisão preliminar** (absolver, reduzir pena, dosimetria) com **fundamentos explicativos**

O sistema deve responder consultas como:
- "Qual a classificação jurídica do caso C1?" (furto, roubo, qualificado)
- "Quais precedentes se aplicam ao caso C2?"
- "Qual a decisão preliminar e seus fundamentos para o caso C3?"
- "Por que o caso C4 não se beneficia da insignificância?"

---

## 🗂️ Modelagem da Base de Conhecimento

A base de dados deve representar:

### Tribunais e Hierarquia
```prolog
tribunal(stf, prioridade(3), vinculante(sim)).
tribunal(stj, prioridade(2), vinculante(nao)).
tribunal(tj,  prioridade(1), vinculante(nao)).
```

### Precedentes Jurisprudenciais
```prolog
precedente(p1, stf, insignificancia,
  'valor irrisorio e ausencia de violencia podem afastar tipicidade',
  vinculante(nao)).

precedente(p2, stj, reincidencia_afasta_insignificancia,
  'reincidencia especifica afasta insignificancia como regra',
  vinculante(nao)).
```

### Casos e Fatos
```prolog
caso(c1, furto).
fatos_caso(c1, valor_bem(100)).
fatos_caso(c1, violencia(nao)).
fatos_caso(c1, primario(sim)).
fatos_caso(c1, reincidente(nao)).
fatos_caso(c1, confissao_espontanea(sim)).
fatos_caso(c1, devolucao_bem(sim)).
```

### Constantes e Limites
```prolog
salario_minimo(1412).
limite_irrisorio(F) :- salario_minimo(SM), F is 0.1*SM.
pequeno_valor(C) :- fatos_caso(C, valor_bem(V)),
                    limite_irrisorio(Lim),
                    V =< Lim * 2.
```

---

## 🎯 Objetivos de Aprendizagem

- Modelar regras jurídicas com exceções
- Implementar hierarquia de precedentes
- Usar negação como falha
- Gerar decisões e fundamentos
- Calcular dosimetria de pena

---

## 📂 Estrutura dos Arquivos

### Arquivos de Entrada
- **`entrada.txt`**: Base de conhecimento com:
  - Tribunais e hierarquia (STF, STJ, TJ com prioridades)
  - Precedentes jurisprudenciais (tema, tese, tribunal, vinculação)
  - Casos (identificador, tipo penal base)
  - Fatos dos casos (valor do bem, violência, primariedade, reincidência, etc.)
  - Constantes (salário mínimo, limites)

### Arquivos Prolog
- **`principal.pl`**: Arquivo principal que carrega os demais módulos
- **`precedentes.pl`**: Hierarquia de tribunais e aplicação de precedentes
- **`regras.pl`**: Regras materiais (insignificância, privilegiado, exceções)
- **`dosimetria.pl`**: Cálculo de pena-base e reduções
- **`decisao.pl`**: Decisão preliminar e fundamentos
- **`explicacao.pl`**: Geração de explicações humanizadas

### Arquivo de Saída
- **`saida.txt`**: Decisões preliminares com fundamentos e explicações

---

## 🧱 Tarefas Obrigatórias

Implemente os seguintes predicados principais:

### 1. Hierarquia de Tribunais e Precedentes

#### 1.1. `tribunal/3` - Definição de Tribunais
```prolog
% ============================================
% TRIBUNAL/3
% ============================================
% Descrição: Define as características de um tribunal no sistema judiciário brasileiro,
%            incluindo sua prioridade hierárquica e poder vinculante de suas decisões.
%
% Parâmetros:
%   - Nome: átomo representando o tribunal (stf, stj, tj, etc.)
%   - prioridade(N): termo estruturado onde N é um número inteiro indicando a hierarquia
%                    (quanto maior o número, maior a prioridade)
%   - vinculante(Sim/Nao): termo estruturado indicando se as decisões deste tribunal
%                          são vinculantes (obrigatórias) para instâncias inferiores
%
% Comportamento:
%   - STF (Supremo Tribunal Federal) tem a maior prioridade (5) e é vinculante
%   - STJ (Superior Tribunal de Justiça) tem prioridade 4 e é vinculante
%   - Tribunais de Justiça (TJ) têm prioridade 3 e não são vinculantes
%   - Tribunais Regionais Federais (TRF) têm prioridade 3 e não são vinculantes
%   - Juízos de primeira instância têm prioridade 1 e não são vinculantes
%
% Exemplos de uso:
%   ?- tribunal(stf, P, V).
%   P = prioridade(5), V = vinculante(sim).
%
%   ?- tribunal(T, prioridade(5), _).
%   T = stf.
%
tribunal(Nome, prioridade(N), vinculante(SimNao)).
```

#### 1.2. `precedente_aplicavel/3` - Seleção de Precedente por Hierarquia
```prolog
% ============================================
% PRECEDENTE_APLICAVEL/3
% ============================================
% Descrição: Seleciona o precedente mais adequado para um tema jurídico específico,
%            respeitando a hierarquia dos tribunais. Quando há múltiplos precedentes
%            sobre o mesmo tema, escolhe aquele do tribunal de maior prioridade.
%
% Parâmetros:
%   - Tema: átomo representando o tema jurídico (insignificancia, reincidencia_afasta,
%           furto_privilegiado, etc.)
%   - Tribunal: átomo representando o tribunal que emitiu o precedente (saída)
%   - Tese: string ou átomo contendo o texto da tese jurídica (saída)
%
% Comportamento:
%   - Busca todos os precedentes relacionados ao tema
%   - Ordena por prioridade do tribunal (maior primeiro)
%   - Retorna o precedente do tribunal de maior hierarquia
%   - Se houver empate, retorna o primeiro encontrado
%   - Falha se não houver precedente para o tema
%
% Exemplos de uso:
%   ?- precedente_aplicavel(insignificancia, T, Tese).
%   T = stf,
%   Tese = 'valor irrisorio e ausencia de violencia podem afastar tipicidade'.
%
%   ?- precedente_aplicavel(reincidencia_afasta, T, _).
%   T = stj.
%
precedente_aplicavel(Tema, Tribunal, Tese).
```

#### 1.3. `aplica_precedente/4` - Aplicação de Precedente ao Caso
```prolog
% ============================================
% APLICA_PRECEDENTE/4
% ============================================
% Descrição: Verifica se um precedente jurídico específico se aplica a um caso concreto,
%            considerando as características do caso e o tema do precedente.
%
% Parâmetros:
%   - Caso: átomo identificando o caso (c1, c2, c3, etc.)
%   - Tema: átomo representando o tema jurídico do precedente
%   - Tribunal: átomo representando o tribunal que emitiu o precedente (saída)
%   - Tese: string ou átomo contendo o texto da tese jurídica (saída)
%
% Comportamento:
%   - Verifica se o tema é relevante para o caso
%   - Busca o precedente aplicável usando precedente_aplicavel/3
%   - Confirma que as condições do precedente são satisfeitas pelo caso
%   - Retorna o tribunal e a tese aplicável
%   - Pode retornar múltiplas soluções via backtracking se houver vários precedentes aplicáveis
%
% Exemplos de uso:
%   ?- aplica_precedente(c1, insignificancia, T, Tese).
%   T = stf,
%   Tese = 'valor irrisorio e ausencia de violencia podem afastar tipicidade'.
%
%   ?- aplica_precedente(c2, reincidencia_afasta, T, _).
%   T = stj.
%
%   ?- aplica_precedente(c1, Tema, _, _).
%   Tema = insignificancia ;
%   Tema = confissao_espontanea ;
%   ...
%
aplica_precedente(Caso, Tema, Tribunal, Tese).
```

### 2. Classificação Jurídica

#### 2.1. `classificacao_juridica/2` - Classificação do Tipo Penal
```prolog
% ============================================
% CLASSIFICACAO_JURIDICA/2
% ============================================
% Descrição: Classifica o fato jurídico de um caso no tipo penal correspondente,
%            analisando as características do delito (violência, grave ameaça, valor,
%            circunstâncias, etc.) para determinar se é furto, roubo, estelionato, etc.
%
% Parâmetros:
%   - Caso: átomo identificando o caso (c1, c2, c3, etc.)
%   - TipoPenal: átomo representando o tipo penal (furto, roubo, estelionato, etc.)
%
% Comportamento:
%   - Analisa os fatos do caso (fato/2)
%   - Verifica presença de violência ou grave ameaça → roubo
%   - Verifica subtração de coisa alheia móvel sem violência → furto
%   - Verifica fraude ou engano → estelionato
%   - Considera qualificadoras que podem alterar a classificação
%   - Retorna o tipo penal mais específico aplicável
%
% Exemplos de uso:
%   ?- classificacao_juridica(c1, T).
%   T = furto.  % caso sem violência
%
%   ?- classificacao_juridica(c3, T).
%   T = roubo.  % caso com violência
%
%   ?- classificacao_juridica(C, furto).
%   C = c1 ;
%   C = c4.
%
classificacao_juridica(Caso, TipoPenal).
```

#### 2.2. `tem_qualificadora/2` - Verificação de Qualificadoras
```prolog
% ============================================
% TEM_QUALIFICADORA/2
% ============================================
% Descrição: Verifica se um caso possui qualificadoras que agravam o delito,
%            aumentando a pena-base. Qualificadoras são circunstâncias especiais
%            previstas em lei que tornam o crime mais grave.
%
% Parâmetros:
%   - Caso: átomo identificando o caso
%   - Qualificadora: átomo representando a qualificadora aplicável
%                    (rompimento_obstaculo, escalada, chave_falsa, concurso_pessoas,
%                     abuso_confianca, repouso_noturno, etc.)
%
% Comportamento:
%   - Analisa as circunstâncias do caso
%   - Identifica qualificadoras previstas no Código Penal
%   - Pode retornar múltiplas qualificadoras via backtracking
%   - Falha se não houver qualificadoras aplicáveis
%   - Qualificadoras aumentam a pena-base do delito
%
% Exemplos de uso:
%   ?- tem_qualificadora(c4, Q).
%   Q = rompimento_obstaculo.
%
%   ?- tem_qualificadora(c3, Q).
%   Q = concurso_pessoas ;
%   Q = arma.
%
%   ?- tem_qualificadora(c1, _).
%   false.  % caso sem qualificadoras
%
tem_qualificadora(Caso, Qualificadora).
```

### 3. Regras Materiais com Exceções

#### 3.1. `regra_insignificancia/1` - Princípio da Insignificância
```prolog
% ============================================
% REGRA_INSIGNIFICANCIA/1
% ============================================
% Descrição: Verifica se um caso atende aos requisitos do princípio da insignificância,
%            que permite afastar a tipicidade material quando o dano causado é mínimo.
%            Baseado em precedentes do STF que estabelecem critérios objetivos.
%
% Parâmetros:
%   - Caso: átomo identificando o caso
%
% Comportamento:
%   - Verifica se o valor subtraído é inferior a 10% do salário mínimo
%   - Confirma ausência de violência ou grave ameaça
%   - Confirma ausência de qualificadoras
%   - Verifica se não há exceções que impedem a aplicação (via excecao_insignificancia/1)
%   - Sucede se todos os requisitos forem atendidos
%   - Falha se qualquer requisito não for satisfeito
%
% Requisitos cumulativos:
%   1. Mínima ofensividade da conduta
%   2. Ausência de periculosidade social da ação
%   3. Reduzido grau de reprovabilidade do comportamento
%   4. Inexpressividade da lesão jurídica
%
% Exemplos de uso:
%   ?- regra_insignificancia(c1).
%   true.  % valor R$ 50, sem violência, primário
%
%   ?- regra_insignificancia(c2).
%   false.  % reincidente específico
%
%   ?- regra_insignificancia(c3).
%   false.  % roubo com violência
%
regra_insignificancia(Caso).
```

#### 3.2. `excecao_insignificancia/1` - Exceções ao Princípio
```prolog
% ============================================
% EXCECAO_INSIGNIFICANCIA/1
% ============================================
% Descrição: Verifica se existem circunstâncias que impedem a aplicação do princípio
%            da insignificância, mesmo quando os requisitos objetivos são atendidos.
%            Baseado em jurisprudência consolidada.
%
% Parâmetros:
%   - Caso: átomo identificando o caso
%
% Comportamento:
%   - Verifica reincidência específica (crimes patrimoniais anteriores)
%   - Verifica habitualidade delitiva (múltiplos crimes similares)
%   - Verifica maus antecedentes
%   - Verifica se o bem subtraído tem valor especial (sentimental, histórico)
%   - Sucede se houver ao menos uma exceção aplicável
%   - Falha se não houver exceções
%
% Exceções reconhecidas:
%   - Reincidência específica em crimes patrimoniais
%   - Habitualidade delitiva
%   - Maus antecedentes
%   - Valor especial do bem (não apenas econômico)
%   - Circunstâncias que revelam periculosidade
%
% Exemplos de uso:
%   ?- excecao_insignificancia(c2).
%   true.  % reincidente específico
%
%   ?- excecao_insignificancia(c1).
%   false.  % primário, sem exceções
%
excecao_insignificancia(Caso).
```

#### 3.3. `regra_furto_privilegiado/1` - Furto Privilegiado
```prolog
% ============================================
% REGRA_FURTO_PRIVILEGIADO/1
% ============================================
% Descrição: Verifica se um caso de furto atende aos requisitos do furto privilegiado
%            (art. 155, §2º do CP), que permite redução de pena de 1/3 a 2/3.
%
% Parâmetros:
%   - Caso: átomo identificando o caso
%
% Comportamento:
%   - Verifica se o tipo penal é furto (não roubo)
%   - Confirma primariedade do agente (sem condenações anteriores)
%   - Verifica se o valor é pequeno (critério jurisprudencial)
%   - Confirma ausência de violência ou grave ameaça
%   - Sucede se todos os requisitos forem atendidos
%   - Falha se qualquer requisito não for satisfeito
%
% Requisitos cumulativos (art. 155, §2º CP):
%   1. Réu primário (sem condenações anteriores)
%   2. Coisa de pequeno valor (critério relativo, geralmente até 1 SM)
%   3. Ausência de violência ou grave ameaça
%
% Efeito: Redução de pena de 1/3 a 2/3
%
% Exemplos de uso:
%   ?- regra_furto_privilegiado(c4).
%   true.  % primário, valor R$ 800, sem violência
%
%   ?- regra_furto_privilegiado(c2).
%   false.  % reincidente
%
%   ?- regra_furto_privilegiado(c3).
%   false.  % roubo (com violência)
%
regra_furto_privilegiado(Caso).
```

#### 3.4. `causas_caso/2` - Causas de Diminuição de Pena
```prolog
% ============================================
% CAUSAS_CASO/2
% ============================================
% Descrição: Identifica todas as causas de diminuição de pena aplicáveis a um caso,
%            retornando uma lista com todas as circunstâncias atenuantes e causas
%            especiais de redução previstas em lei.
%
% Parâmetros:
%   - Caso: átomo identificando o caso
%   - ListaCausas: lista de átomos representando as causas de diminuição
%                  (confissao_espontanea, devolucao_bem, furto_privilegiado,
%                   colaboracao_justica, reparacao_dano, etc.)
%
% Comportamento:
%   - Coleta todas as causas de diminuição aplicáveis usando findall
%   - Verifica confissão espontânea (redução de 1/3)
%   - Verifica devolução do bem antes da sentença
%   - Verifica furto privilegiado (redução de 1/3 a 2/3)
%   - Verifica colaboração com a justiça
%   - Verifica reparação do dano
%   - Retorna lista vazia se não houver causas aplicáveis
%   - Retorna lista ordenada de causas
%
% Causas de diminuição reconhecidas:
%   - confissao_espontanea: redução de até 1/3
%   - devolucao_bem: redução variável
%   - furto_privilegiado: redução de 1/3 a 2/3
%   - colaboracao_justica: redução variável
%   - reparacao_dano: redução variável
%
% Exemplos de uso:
%   ?- causas_caso(c1, L).
%   L = [confissao_espontanea, devolucao_bem].
%
%   ?- causas_caso(c4, L).
%   L = [furto_privilegiado].
%
%   ?- causas_caso(c3, L).
%   L = [].  % roubo sem atenuantes
%
causas_caso(Caso, ListaCausas).
```

### 4. Dosimetria e Cálculo de Pena

#### 4.1. `pena_base/2` - Pena-Base por Tipo Penal
```prolog
% ============================================
% PENA_BASE/2
% ============================================
% Descrição: Define a pena-base (em meses ou pontos) para cada tipo penal,
%            conforme previsto no Código Penal brasileiro. Esta é a primeira
%            fase da dosimetria da pena (sistema trifásico).
%
% Parâmetros:
%   - TipoPenal: átomo representando o tipo penal (furto, roubo, estelionato, etc.)
%   - Pontos: número inteiro representando a pena-base em meses de reclusão/detenção
%
% Comportamento:
%   - Retorna a pena mínima prevista em lei para o tipo penal
%   - Furto simples: 12 meses (1 a 4 anos, usa-se o mínimo)
%   - Furto qualificado: 24 meses (2 a 8 anos, usa-se o mínimo)
%   - Roubo simples: 48 meses (4 a 10 anos, usa-se o mínimo)
%   - Roubo qualificado: 60 meses (5 a 15 anos, usa-se o mínimo)
%   - Estelionato: 12 meses (1 a 5 anos, usa-se o mínimo)
%   - Falha se o tipo penal não estiver definido
%
% Observações:
%   - Usa-se a pena mínima como base para aplicação do sistema trifásico
%   - Qualificadoras aumentam a pena-base
%   - Esta é a 1ª fase da dosimetria (circunstâncias judiciais)
%
% Exemplos de uso:
%   ?- pena_base(furto, P).
%   P = 12.  % 12 meses (1 ano)
%
%   ?- pena_base(roubo, P).
%   P = 48.  % 48 meses (4 anos)
%
%   ?- pena_base(T, 12).
%   T = furto ;
%   T = estelionato.
%
pena_base(TipoPenal, Pontos).
```

#### 4.2. `aplica_reducao/3` - Aplicação de Redução Percentual
```prolog
% ============================================
% APLICA_REDUCAO/3
% ============================================
% Descrição: Aplica uma redução percentual sobre uma pena inicial, calculando
%            a pena final após a redução. Usado para aplicar atenuantes e
%            causas de diminuição de pena.
%
% Parâmetros:
%   - PenaInicial: número (inteiro ou float) representando a pena em meses
%   - Percentual: número (float) representando o percentual de redução (0.0 a 1.0)
%                 Exemplo: 0.33 para redução de 1/3, 0.5 para redução de 1/2
%   - PenaFinal: número (float) representando a pena após redução (saída)
%
% Comportamento:
%   - Calcula: PenaFinal = PenaInicial * (1 - Percentual)
%   - Aceita percentuais de 0.0 (sem redução) a 1.0 (redução total)
%   - Retorna valor com precisão de ponto flutuante
%   - Pode ser usado para aumentos (percentual negativo)
%
% Exemplos de redução:
%   - Confissão espontânea: 1/3 (0.33)
%   - Furto privilegiado: 1/3 a 2/3 (0.33 a 0.67)
%   - Tentativa: 1/3 a 2/3 (0.33 a 0.67)
%   - Menoridade relativa: 1/3 (0.33)
%
% Exemplos de uso:
%   ?- aplica_reducao(12, 0.33, P).
%   P = 8.04.  % redução de 1/3
%
%   ?- aplica_reducao(48, 0.5, P).
%   P = 24.0.  % redução de 1/2
%
%   ?- aplica_reducao(100, 0.67, P).
%   P = 33.0.  % redução de 2/3
%
aplica_reducao(PenaInicial, Percentual, PenaFinal).
```

#### 4.3. `acumula_reducoes/3` - Acúmulo de Reduções Cumulativas
```prolog
% ============================================
% ACUMULA_REDUCOES/3
% ============================================
% Descrição: Aplica múltiplas reduções de forma cumulativa sobre uma pena inicial,
%            processando uma lista de percentuais de redução em sequência.
%            Cada redução é aplicada sobre o resultado da redução anterior.
%
% Parâmetros:
%   - PenaInicial: número representando a pena inicial em meses
%   - ListaReducoes: lista de números (floats) representando percentuais de redução
%                    Exemplo: [0.33, 0.5] para redução de 1/3 seguida de 1/2
%   - PenaFinal: número representando a pena final após todas as reduções (saída)
%
% Comportamento:
%   - Processa a lista de reduções da esquerda para a direita
%   - Cada redução é aplicada sobre o resultado da anterior (cumulativo)
%   - Lista vazia resulta em PenaFinal = PenaInicial (sem reduções)
%   - Usa recursão para processar a lista
%   - Exemplo: Pena 100, reduções [0.33, 0.5]
%     * Após 1ª redução: 100 * (1 - 0.33) = 67
%     * Após 2ª redução: 67 * (1 - 0.5) = 33.5
%
% Observações:
%   - Reduções são cumulativas, não aditivas
%   - Ordem das reduções pode afetar o resultado final
%   - Jurisprudência define ordem de aplicação das reduções
%
% Exemplos de uso:
%   ?- acumula_reducoes(100, [0.33], P).
%   P = 67.0.  % uma redução de 1/3
%
%   ?- acumula_reducoes(100, [0.33, 0.5], P).
%   P = 33.5.  % 1/3 seguido de 1/2
%
%   ?- acumula_reducoes(48, [0.33, 0.33], P).
%   P = 21.5.  % duas reduções de 1/3
%
%   ?- acumula_reducoes(100, [], P).
%   P = 100.  % sem reduções
%
acumula_reducoes(PenaInicial, ListaReducoes, PenaFinal).
```

### 5. Decisão e Fundamentos

#### 5.1. `decisao_preliminar/3` - Decisão Preliminar com Fundamentos
```prolog
% ============================================
% DECISAO_PRELIMINAR/3
% ============================================
% Descrição: Produz uma decisão preliminar para o caso, analisando todas as regras
%            jurídicas aplicáveis e retornando o resultado com seus fundamentos.
%            Implementa a lógica de decisão judicial baseada em precedentes e regras.
%
% Parâmetros:
%   - Caso: átomo identificando o caso
%   - Resultado: termo estruturado representando a decisão:
%                * absolver_por_insignificancia: aplica princípio da insignificância
%                * reduzir_pena_por_privilegio: aplica furto privilegiado
%                * dosimetria(PenaFinal): calcula pena com reduções aplicáveis
%   - Fundamentos: lista de átomos/strings contendo os fundamentos da decisão
%                  (precedentes, causas de diminuição, qualificadoras, etc.)
%
% Comportamento:
%   - Verifica primeiro se aplica princípio da insignificância
%     * Se sim: retorna absolver_por_insignificancia
%   - Verifica se aplica furto privilegiado
%     * Se sim: retorna reduzir_pena_por_privilegio
%   - Caso contrário: calcula dosimetria completa
%     * Obtém pena-base do tipo penal
%     * Aplica qualificadoras (aumentam pena)
%     * Aplica causas de diminuição (reduzem pena)
%     * Retorna dosimetria(PenaFinal)
%   - Coleta todos os fundamentos relevantes para a decisão
%   - Inclui precedentes aplicáveis na lista de fundamentos
%
% Ordem de análise (hierarquia):
%   1. Princípio da insignificância (afasta tipicidade)
%   2. Furto privilegiado (redução significativa)
%   3. Dosimetria normal (cálculo de pena)
%
% Exemplos de uso:
%   ?- decisao_preliminar(c1, R, F).
%   R = absolver_por_insignificancia,
%   F = ['valor irrisorio...', confissao_espontanea, devolucao_bem].
%
%   ?- decisao_preliminar(c2, R, F).
%   R = dosimetria(180),
%   F = ['reincidencia especifica afasta insignificancia...'].
%
%   ?- decisao_preliminar(c4, R, F).
%   R = reduzir_pena_por_privilegio,
%   F = ['furto sem violencia...', furto_privilegiado, qualificadora(rompimento_obstaculo)].
%
decisao_preliminar(Caso, Resultado, Fundamentos).
```

#### 5.2. `fundamentos/2` - Coleta de Fundamentos
```prolog
% ============================================
% FUNDAMENTOS/2
% ============================================
% Descrição: Coleta todos os fundamentos jurídicos relevantes para um caso,
%            incluindo precedentes aplicáveis, causas de diminuição de pena,
%            qualificadoras e outras circunstâncias relevantes.
%
% Parâmetros:
%   - Caso: átomo identificando o caso
%   - ListaFundamentos: lista de termos representando os fundamentos
%                       (precedentes, causas, qualificadoras, circunstâncias)
%
% Comportamento:
%   - Busca todos os precedentes aplicáveis ao caso
%   - Coleta todas as causas de diminuição de pena
%   - Identifica qualificadoras aplicáveis
%   - Verifica circunstâncias judiciais relevantes
%   - Agrupa tudo em uma lista unificada
%   - Remove duplicatas
%   - Ordena por relevância (precedentes primeiro)
%
% Tipos de fundamentos coletados:
%   - Precedentes: teses de tribunais superiores
%   - Causas de diminuição: confissão, devolução, colaboração
%   - Qualificadoras: rompimento de obstáculo, escalada, etc.
%   - Circunstâncias: primariedade, reincidência, antecedentes
%   - Regras especiais: insignificância, furto privilegiado
%
% Exemplos de uso:
%   ?- fundamentos(c1, F).
%   F = [precedente(stf, insignificancia, '...'),
%        confissao_espontanea,
%        devolucao_bem,
%        primariedade].
%
%   ?- fundamentos(c4, F).
%   F = [precedente(stj, furto_privilegiado, '...'),
%        qualificadora(rompimento_obstaculo),
%        primariedade].
%
fundamentos(Caso, ListaFundamentos).
```

#### 5.3. `explicacao/2` - Explicação Humanizada
```prolog
% ============================================
% EXPLICACAO/2
% ============================================
% Descrição: Gera uma explicação humanizada e legível da decisão judicial,
%            traduzindo os fundamentos técnicos em mensagens compreensíveis
%            para leigos. Essencial para transparência e explicabilidade.
%
% Parâmetros:
%   - Caso: átomo identificando o caso
%   - MensagensLegiveis: lista de strings contendo explicações em linguagem natural
%
% Comportamento:
%   - Obtém a classificação jurídica do caso
%   - Traduz precedentes em linguagem acessível
%   - Explica causas de diminuição de forma clara
%   - Descreve qualificadoras em termos simples
%   - Justifica a decisão final
%   - Organiza mensagens em ordem lógica:
%     1. Classificação do fato
%     2. Precedentes aplicáveis
%     3. Circunstâncias atenuantes
%     4. Qualificadoras agravantes
%     5. Decisão final e pena
%
% Formato das mensagens:
%   - Frases completas e gramaticalmente corretas
%   - Linguagem acessível (evita jargão excessivo)
%   - Explicações causais ("porque", "portanto", "assim")
%   - Referências a artigos de lei quando relevante
%
% Exemplos de uso:
%   ?- explicacao(c1, M).
%   M = ['Classificacao do fato: furto simples',
%        'Valor irrisorio (R$ 50) e ausencia de violencia podem afastar tipicidade',
%        'Confissao espontanea justifica diminuicao de pena em ate 1/3',
%        'Devolucao do bem antes da sentenca favorece diminuicao',
%        'Decisao: absolvicao por aplicacao do principio da insignificancia'].
%
%   ?- explicacao(c4, M).
%   M = ['Classificacao do fato: furto qualificado',
%        'Rompimento de obstaculo qualifica o crime',
%        'Primario e pequeno valor permitem aplicacao do furto privilegiado',
%        'Decisao: reducao de pena de 1/3 a 2/3 por furto privilegiado'].
%
explicacao(Caso, MensagensLegiveis).
```

---

## ✨ Extensões

1. **Conflito de Precedentes**: Escolher maior prioridade
2. **Vinculação Forte**: Súmula vinculante obrigatória
3. **Arrependimento Posterior**: Redução 1/3 a 2/3
4. **Temporalidade**: Precedente com data
5. **Outros Ramos**: Civil/tributário

---

## ▶️ Exemplos de Execução

```prolog
% 1) Classificação jurídica do fato
?- classificacao_juridica(c1, T).
T = furto.

?- classificacao_juridica(c3, T).
T = roubo.  % caso com violência

% 2) Consulta de precedentes aplicáveis
?- aplica_precedente(c1, insignificancia, Trib, Tese).
Trib = stf,
Tese = 'valor irrisorio e ausencia de violencia podem afastar tipicidade'.

?- aplica_precedente(c2, reincidencia_afasta, Trib, Tese).
Trib = stj,
Tese = 'reincidencia especifica afasta insignificancia como regra'.

% 3) Decisão preliminar com fundamentos
?- decisao_preliminar(c1, R, F).
R = absolver_por_insignificancia,
F = ['valor irrisorio...', confissao_espontanea, devolucao_bem].

?- decisao_preliminar(c2, R, F).
R = dosimetria(180),
F = ['reincidencia especifica afasta insignificancia...'].

?- decisao_preliminar(c4, R, F).
R = reduzir_pena_por_privilegio,
F = ['furto sem violencia...', furto_privilegiado, qualificadora(rompimento_obstaculo)].

% 4) Explicação humanizada
?- explicacao(c1, M).
M = ['classificacao do fato: furto',
     'valor irrisorio e ausencia de violencia podem afastar tipicidade',
     'confissao espontanea justifica diminuicao de pena',
     'devolucao do bem antes da sentenca favorece diminuicao'].

% 5) Verificação de regras e exceções
?- regra_insignificancia(c1).
true.

?- excecao_insignificancia(c1).
false.

?- excecao_insignificancia(c2).
true.  % reincidente

% 6) Listar todos os casos com decisão de absolvição
?- decisao_preliminar(C, absolver_por_insignificancia, _).

% 7) Verificar hierarquia de precedentes
?- precedente_aplicavel(insignificancia, T, Tese).
T = stf,  % maior prioridade
Tese = '...'.
```

---

## 📊 Critérios de Avaliação

- **Corretude das regras** (30%): Implementação correta das restrições
- **Derivação lógica** (15%): Uso adequado de backtracking e busca
- **Explicabilidade** (20%): Justificativas claras e completas
- **Extensão implementada** (15%): Implementação correta de pelo menos uma extensão
- **Organização do código** (10%): Modularização e clareza
- **Documentação** (10%): Comentários e exemplos

---

## 📝 Observações Importantes

1. A base de dados deve conter **pelo menos 5 casos**, **3 precedentes** e **3 tribunais** (STF, STJ, TJ)
2. Teste casos de:
   - **Insignificância** (valor irrisório + sem violência → absolvição)
   - **Furto privilegiado** (primariedade + pequeno valor → redução)
   - **Reincidência** (exceção que afasta benefícios)
   - **Qualificadoras** (rompimento de obstáculo, concurso de pessoas)
   - **Causas de diminuição** (confissão espontânea, devolução do bem)
3. Implemente **hierarquia de precedentes** (STF > STJ > TJ)
4. Use **negação como falha** (`\+`) para verificar exceções
5. Todas as decisões devem ter **fundamentos explicativos**
6. Considere casos onde **regras conflitam com exceções**
7. Implemente **dosimetria simplificada** com pena-base e reduções percentuais
8. Gere **explicações humanizadas** além dos fundamentos técnicos

