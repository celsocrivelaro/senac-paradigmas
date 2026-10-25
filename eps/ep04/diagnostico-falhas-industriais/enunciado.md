**Tema:** 🏭 Sistema de Diagnóstico de Falhas Industriais

---

## 🎯 Objetivo

Modelar, em **Prolog**, um sistema lógico que diagnostica **falhas em máquinas** de uma linha de produção com base em sintomas observados.

O sistema deve:

1. Representar uma **hierarquia de componentes** (máquina → subsistemas → peças)
2. Associar **sintomas** a **causas prováveis**, com pesos de confiança
3. Permitir **raciocínio recursivo**: se um subsistema falha, o sistema deduz que a máquina também está comprometida
4. Suportar **regras explicativas**, como "a falha X pode ser causada por Y ou Z"
5. Determinar **falhas-raiz** — causas originais que explicam as falhas detectadas

O sistema deve responder consultas como:

```prolog
falha_possivel(maquina_a, Falha).
causa_raiz(maquina_a, FalhaRaiz).
explicacao(maquina_a, Falha, Justificativa).
por_que(maquina_a, superaquecimento, Justificativa).
```

---

## 🧩 Descrição do Problema

Você é o **engenheiro responsável** por criar um sistema especialista para diagnosticar **falhas em uma fábrica automatizada**.

Cada máquina é composta de **módulos e sensores**, e as falhas podem se propagar hierarquicamente. Por exemplo, uma bomba de óleo com fluxo reduzido pode causar baixa pressão de óleo, que por sua vez pode causar superaquecimento do motor.

Implemente um sistema lógico que:
- Mapeia a estrutura hierárquica das máquinas (componentes e subcomponentes)
- Associa **falhas conhecidas** a **sintomas observados** e **causas prováveis**
- Permite inferir **falhas indiretas** (por herança ou dependência)
- Determina **falhas-raiz** — causas originais que explicam as falhas detectadas
- Explica o raciocínio (por que uma falha foi inferida)

---

## 🎯 Objetivos de Aprendizagem

- Modelar hierarquias de componentes usando o paradigma lógico
- Implementar raciocínio causal com encadeamento de causas
- Utilizar recursão para propagação hierárquica de falhas
- Criar predicados explicativos para diagnósticos
- Trabalhar com incerteza através de pesos de confiança
- Organizar o sistema em múltiplos arquivos

---

## 🏭 Base de Fatos (Exemplo Didático)

### Hierarquia de Componentes
```prolog
% ============================
% HIERARQUIA DE COMPONENTES
% componente(Pai, Filho)
% ============================
componente(maquina_a, motor_principal).
componente(maquina_a, sistema_eletrico).
componente(sistema_eletrico, sensor_temperatura).
componente(sistema_eletrico, circuito_controle).
componente(motor_principal, bomba_oleo).
componente(motor_principal, eixo_rotacao).
```

### Falhas Possíveis
```prolog
% ============================
% FALHAS POSSÍVEIS
% falha(Falha, Tipo, Severidade)
% ============================
falha(superaquecimento, mecanica, alta).
falha(baixa_pressao_oleo, mecanica, media).
falha(curto_circuito, eletrica, alta).
falha(sensor_inoperante, eletrica, baixa).
falha(vibracao_excessiva, mecanica, media).
falha(parada_inesperada, geral, alta).
falha(eixo_desalinhado, mecanica, media).
```

### Sintomas Observados
```prolog
% ============================
% SINTOMAS OBSERVADOS
% sintoma(Componente, Sintoma)
% ============================
sintoma(sensor_temperatura, leitura_inconstante).
sintoma(eixo_rotacao, ruido).
sintoma(bomba_oleo, fluxo_reduzido).
```

### Relações de Causa e Efeito
```prolog
% ============================
% RELAÇÕES DE CAUSA E EFEITO
% causa(FalhaCausa, FalhaConsequencia, Confianca)
% Confiança: 0.0 a 1.0
% ============================
causa(baixa_pressao_oleo, superaquecimento, 0.7).
causa(curto_circuito, parada_inesperada, 0.9).
causa(sensor_inoperante, leitura_inconstante, 0.8).
causa(vibracao_excessiva, eixo_desalinhado, 0.6).
```

### Associação de Sintomas a Falhas
```prolog
% ============================
% ASSOCIAÇÃO DE SINTOMAS A FALHAS PROVÁVEIS
% relacao_sintoma_falha(Sintoma, Falha, Confianca)
% ============================
relacao_sintoma_falha(leitura_inconstante, sensor_inoperante, 0.8).
relacao_sintoma_falha(ruido, vibracao_excessiva, 0.7).
relacao_sintoma_falha(fluxo_reduzido, baixa_pressao_oleo, 0.9).
```

### Falhas Observadas
```prolog
% ============================
% FALHAS CONHECIDAS (observadas diretamente)
% falha_observada(Componente, Sintoma)
% ============================
falha_observada(sensor_temperatura, leitura_inconstante).
falha_observada(bomba_oleo, fluxo_reduzido).
```

---

## 📂 Estrutura dos Arquivos e Entrada-Saída

### Arquivos de Entrada
- **`entrada.txt`**: Contém os fatos da base de conhecimento (componentes, falhas, sintomas, causas)

### Arquivos Prolog
- **`principal.pl`**: Arquivo principal que carrega os demais módulos e a base de dados
- **`equipamentos.pl`**: Predicados relacionados à hierarquia de componentes
- **`sintomas.pl`**: Predicados de sintomas e observações
- **`diagnostico.pl`**: Predicados de diagnóstico e inferência de falhas
- **`acoes.pl`**: Predicados de ações corretivas e recomendações

### Arquivo de Saída
- **`saida.txt`**: Resultados dos diagnósticos e explicações

---

## 🧱 Tarefas Obrigatórias

### 1. Herança Estrutural (Subcomponentes Recursivos)

#### 1.1. `subcomponente/2` - Fecho Transitivo de Componentes
```prolog
% ============================================
% SUBCOMPONENTE/2
% ============================================
% Descrição: Implementa o fecho transitivo da relação de componentes. Permite
%            navegar por toda a hierarquia de componentes de uma máquina,
%            incluindo subcomponentes diretos e indiretos.
%
% Parâmetros:
%   - X: átomo representando o componente pai
%   - Y: átomo representando o subcomponente (direto ou indireto)
%
% Comportamento:
%   - Caso base: Y é subcomponente direto de X (componente(X, Y))
%   - Caso recursivo: Y é subcomponente indireto via Z
%     * X contém Z (componente(X, Z))
%     * Z contém Y (subcomponente(Z, Y))
%   - Permite navegar por múltiplos níveis de hierarquia
%
% Hierarquia típica:
%   maquina_a → motor_principal → bomba_oleo → sensor_pressao
%   subcomponente(maquina_a, sensor_pressao) é verdadeiro (transitivo)
%
% Exemplos de uso:
%   ?- subcomponente(maquina_a, motor_principal).
%   true.  % subcomponente direto
%
%   ?- subcomponente(maquina_a, bomba_oleo).
%   true.  % subcomponente indireto (via motor_principal)
%
%   ?- subcomponente(motor_principal, sensor_pressao).
%   true.  % subcomponente indireto (via bomba_oleo)
%
subcomponente(X, Y).
```

### 2. Falhas Possíveis a Partir de Sintomas

#### 2.1. `falha_possivel/2` - Inferência de Falhas
```prolog
% ============================================
% FALHA_POSSIVEL/2
% ============================================
% Descrição: Infere falhas possíveis em um componente baseado em sintomas
%            observados e propagação hierárquica. Implementa raciocínio diagnóstico
%            bottom-up (de subcomponentes para componentes pai).
%
% Parâmetros:
%   - Componente: átomo identificando o componente
%   - Falha: átomo representando a falha possível
%
% Comportamento:
%   - **Caso 1: Falha direta por sintoma**
%     * Componente apresenta sintoma
%     * Sintoma está relacionado a falha (via relacao_sintoma_falha/3)
%   - **Caso 2: Falha propagada de subcomponente**
%     * Filho é subcomponente direto de Pai (componente(Pai, Filho))
%     * Filho tem falha possível
%     * Falha se propaga para Pai (falha em subcomponente afeta componente pai)
%
% Propagação hierárquica:
%   - Falhas em componentes internos afetam componentes externos
%   - Permite diagnóstico em múltiplos níveis
%   - Essencial para identificar impacto sistêmico
%
% Exemplos de uso:
%   ?- falha_possivel(bomba_oleo, F).
%   F = baixa_pressao_oleo.  % falha direta por sintoma
%
%   ?- falha_possivel(motor_principal, F).
%   F = baixa_pressao_oleo ;  % propagada da bomba_oleo
%   F = superaquecimento.     % propagada da bomba_oleo
%
%   ?- falha_possivel(maquina_a, F).
%   % retorna todas as falhas (diretas e propagadas)
%
falha_possivel(Componente, Falha).
```

### 3. Causa Indireta (Encadeamento de Causas)

#### 3.1. `causa_indireta/2` - Fecho Transitivo de Causas
```prolog
% ============================================
% CAUSA_INDIRETA/2
% ============================================
% Descrição: Implementa o fecho transitivo da relação de causalidade entre falhas.
%            Permite rastrear cadeias de causas: F1 → F2 → F3.
%
% Parâmetros:
%   - F1: átomo representando a falha causa
%   - F2: átomo representando a falha efeito (direto ou indireto)
%
% Comportamento:
%   - Caso base: F1 causa F2 diretamente (causa(F1, F2, _))
%   - Caso recursivo: F1 causa F3 indiretamente via F2
%     * F1 causa F2 (causa(F1, F2, _))
%     * F2 causa F3 (causa_indireta(F2, F3))
%   - Permite rastrear cadeias causais de qualquer comprimento
%
% Raciocínio causal:
%   - Essencial para identificar causas raiz
%   - Permite entender efeitos em cascata
%   - Suporta análise de impacto
%
% Exemplos de uso:
%   ?- causa_indireta(baixa_pressao_oleo, superaquecimento).
%   true.  % causa direta
%
%   ?- causa_indireta(baixa_pressao_oleo, parada_inesperada).
%   true.  % causa indireta (via superaquecimento)
%
%   ?- causa_indireta(F1, parada_inesperada).
%   F1 = baixa_pressao_oleo ;  % causa indireta
%   F1 = superaquecimento.     % causa direta
%
causa_indireta(F1, F2).
```

### 4. Identificação de Falha Raiz

#### 4.1. `causa_raiz/2` - Identificação de Causa Raiz
```prolog
% ============================================
% CAUSA_RAIZ/2
% ============================================
% Descrição: Identifica falhas raiz em uma máquina. Falha raiz é uma falha possível
%            que não é causada por nenhuma outra falha (ponto inicial da cadeia causal).
%
% Parâmetros:
%   - Maquina: átomo identificando a máquina
%   - FalhaRaiz: átomo representando a falha raiz (saída)
%
% Comportamento:
%   - Verifica que FalhaRaiz é falha possível na máquina
%   - Verifica que NÃO existe outra falha que cause FalhaRaiz
%   - Usa negação como falha (\+) para verificar ausência de causa
%   - Retorna apenas falhas que são pontos iniciais de cadeias causais
%
% Importância:
%   - Falhas raiz são alvos prioritários de correção
%   - Corrigir falha raiz elimina efeitos em cascata
%   - Essencial para manutenção eficiente
%
% Exemplos de uso:
%   ?- causa_raiz(maquina_a, F).
%   F = baixa_pressao_oleo.  % falha raiz (não é causada por outra)
%
%   ?- causa_raiz(maquina_a, superaquecimento).
%   false.  % superaquecimento é causado por baixa_pressao_oleo
%
causa_raiz(Maquina, FalhaRaiz).
```

### 5. Diagnóstico com Confiança

#### 5.1. `diagnostico/3` - Diagnóstico com Nível de Confiança
```prolog
% ============================================
% DIAGNOSTICO/3
% ============================================
% Descrição: Realiza diagnóstico de falhas com nível de confiança associado.
%            Implementa propagação hierárquica com degradação de confiança.
%
% Parâmetros:
%   - Componente: átomo identificando o componente
%   - Falha: átomo representando a falha diagnosticada
%   - Confianca: número (0-100) representando o nível de confiança
%
% Comportamento:
%   - **Caso 1: Diagnóstico direto**
%     * Componente apresenta sintoma
%     * Sintoma está relacionado a falha com confiança
%     * Retorna confiança original da relação
%   - **Caso 2: Diagnóstico propagado**
%     * Filho é subcomponente direto de Pai
%     * Filho tem diagnóstico com confiança Conf
%     * Propaga para Pai com confiança reduzida (Conf * 0.8)
%     * Redução de 20% reflete incerteza da propagação
%
% Interpretação da confiança:
%   - 90-100%: Alta confiança (diagnóstico direto)
%   - 70-89%: Confiança moderada (propagação 1 nível)
%   - 50-69%: Confiança baixa (propagação 2+ níveis)
%   - <50%: Confiança muito baixa (requer investigação)
%
% Exemplos de uso:
%   ?- diagnostico(bomba_oleo, baixa_pressao_oleo, C).
%   C = 90.  % diagnóstico direto (alta confiança)
%
%   ?- diagnostico(motor_principal, baixa_pressao_oleo, C).
%   C = 72.  % propagado (90 * 0.8 = 72)
%
%   ?- diagnostico(maquina_a, baixa_pressao_oleo, C).
%   C = 57.6.  % propagado 2 níveis (90 * 0.8 * 0.8 = 57.6)
%
diagnostico(Componente, Falha, Confianca).
```

### 6. Explicação Textual

#### 6.1. `explicacao/3` - Explicação Simples
```prolog
% ============================================
% EXPLICACAO/3
% ============================================
% Descrição: Gera explicação textual simples de uma falha, listando os sintomas
%            observados que levaram ao diagnóstico.
%
% Parâmetros:
%   - Maquina: átomo identificando a máquina
%   - Falha: átomo representando a falha
%   - Justificativa: átomo contendo a explicação formatada (saída)
%
% Comportamento:
%   - Verifica que Falha é possível na Máquina
%   - Coleta todos os sintomas observados (findall)
%   - Formata mensagem: "Falha (X) deduzida por sintomas: [...]"
%   - Usa format/2 para criar átomo formatado
%
% Uso:
%   - Explicação rápida para operadores
%   - Relatórios simples de diagnóstico
%   - Interface com usuário
%
% Exemplos de uso:
%   ?- explicacao(maquina_a, baixa_pressao_oleo, J).
%   J = 'Falha (baixa_pressao_oleo) deduzida por sintomas: [luz_vermelha, temperatura_alta]'.
%
explicacao(Maquina, Falha, Justificativa).
```

#### 6.2. `por_que/3` - Explicação Detalhada
```prolog
% ============================================
% POR_QUE/3
% ============================================
% Descrição: Gera explicação textual detalhada de uma falha, incluindo sintomas
%            observados e relações causais conhecidas. Mais completa que explicacao/3.
%
% Parâmetros:
%   - Maquina: átomo identificando a máquina
%   - Falha: átomo representando a falha
%   - Justificativa: átomo contendo a explicação detalhada (saída)
%
% Comportamento:
%   - Verifica que Falha é possível na Máquina
%   - Coleta todos os sintomas observados
%   - Coleta todas as relações sintoma-falha-confiança
%   - Formata mensagem detalhada com sintomas E relações
%   - Formato: "Falha (X) inferida por sintomas: [...] e relações conhecidas: [...]"
%
% Uso:
%   - Explicação para técnicos especializados
%   - Auditoria de diagnóstico
%   - Treinamento e documentação
%   - Debugging do sistema de diagnóstico
%
% Exemplos de uso:
%   ?- por_que(maquina_a, baixa_pressao_oleo, J).
%   J = 'Falha (baixa_pressao_oleo) inferida por sintomas: [luz_vermelha, temperatura_alta]
%        e relações conhecidas: [(luz_vermelha, baixa_pressao_oleo, 90),
%        (temperatura_alta, superaquecimento, 85)]'.
%
por_que(Maquina, Falha, Justificativa).
```

### 7. Ações Corretivas

#### 7.1. `acao_corretiva/2` - Base de Conhecimento de Ações
```prolog
% ============================================
% ACAO_CORRETIVA/2
% ============================================
% Descrição: Base de conhecimento que mapeia cada tipo de falha para sua ação
%            corretiva recomendada. Fatos puros (não há implementação).
%
% Parâmetros:
%   - Falha: átomo representando o tipo de falha
%   - Acao: string contendo a descrição da ação corretiva
%
% Comportamento:
%   - Cada cláusula mapeia uma falha para uma ação
%   - Ações são strings descritivas para técnicos
%   - Usado por recomendar_acao/4 para gerar recomendações
%
% Falhas cobertas:
%   - superaquecimento
%   - baixa_pressao_oleo
%   - curto_circuito
%   - sensor_inoperante
%   - vibracao_excessiva
%   - parada_inesperada
%   - eixo_desalinhado
%
% Exemplos de uso:
%   ?- acao_corretiva(superaquecimento, A).
%   A = 'Verificar sistema de refrigeração e nível de óleo'.
%
acao_corretiva(Falha, Acao).
```

#### 7.2. `recomendar_acao/4` - Recomendação Priorizada
```prolog
% ============================================
% RECOMENDAR_ACAO/4
% ============================================
% Descrição: Recomenda ação corretiva para uma falha, com prioridade baseada na
%            severidade. Combina diagnóstico com base de conhecimento de ações.
%
% Parâmetros:
%   - Maquina: átomo identificando a máquina
%   - Falha: átomo representando a falha
%   - Prioridade: átomo representando o nível de urgência (saída)
%   - Acao: string contendo a ação corretiva (saída)
%
% Comportamento:
%   - Verifica que Falha é possível na Máquina
%   - Obtém severidade da falha (via falha/3)
%   - Obtém ação corretiva da base de conhecimento
%   - Mapeia severidade para prioridade:
%     * alta → urgente (ação imediata)
%     * media → moderada (ação em 24-48h)
%     * baixa → baixa (ação em manutenção programada)
%
% Uso:
%   - Priorização de ordens de serviço
%   - Alocação de recursos de manutenção
%   - Planejamento de paradas
%
% Exemplos de uso:
%   ?- recomendar_acao(maquina_a, baixa_pressao_oleo, P, A).
%   P = urgente,
%   A = 'Verificar bomba de óleo e nível do reservatório'.
%
%   ?- recomendar_acao(maquina_a, vibracao_excessiva, P, A).
%   P = moderada,
%   A = 'Verificar balanceamento e fixação de componentes'.
%
recomendar_acao(Maquina, Falha, Prioridade, Acao).
```

---

## ✨ Extensões (Escolha pelo menos UMA)

| Conceito | Extensão |
|----------|----------|
| **Probabilidade Agregada** | Propagar probabilidades (`Confiança`) com média ponderada ao subir na hierarquia. Calcular confiança combinada de múltiplos sintomas. |
| **Classificação por Severidade** | Priorizar falhas de severidade alta no diagnóstico. Ordenar recomendações por criticidade. |
| **Árvore de Decisão** | Montar uma árvore `falha_raiz → causa → efeito` e percorrê-la para explicação visual. |
| **Diagnóstico Reverso** | Dado um sintoma, retornar a sequência de causas prováveis (`diagnosticar/2`). Raciocínio backward chaining. |
| **Explicabilidade Avançada** | Predicado `trilha_diagnostico/3` que lista todos os fatos que sustentam a inferência com pesos. |
| **Manutenção Preventiva** | `recomendar_inspecao/1` se houver sintomas frequentes ou confiança alta de falha. Histórico de falhas recorrentes. |

### Exemplo de Extensão: Árvore de Diagnóstico
```prolog
% Gera árvore textual de diagnóstico
arvore_diagnostico(Maquina, Arvore) :-
    findall(
        (Componente, Falha, Confianca),
        (subcomponente(Maquina, Componente),
         diagnostico(Componente, Falha, Confianca)),
        Diagnosticos
    ),
    format(atom(Arvore), '~w~n~w', [Maquina, Diagnosticos]).

% Exemplo de uso:
% ?- arvore_diagnostico(maquina_a, A).
% A = 'maquina_a
%      ├── motor_principal
%      │    └── bomba_oleo → baixa_pressao_oleo (90%)
%      │         └── superaquecimento (70%)
%      └── sistema_eletrico
%           └── sensor_temperatura → sensor_inoperante (80%)'
```

---

## ▶️ Exemplos de Execução

```prolog
% 1) Falhas possíveis em cada componente
?- falha_possivel(bomba_oleo, F).
F = baixa_pressao_oleo.

?- falha_possivel(sensor_temperatura, F).
F = sensor_inoperante.

% 2) Falhas possíveis na máquina (propagação hierárquica)
?- falha_possivel(maquina_a, F).
F = baixa_pressao_oleo ;
F = superaquecimento ;
F = sensor_inoperante ;
F = vibracao_excessiva.

% 3) Falhas causais encadeadas
?- causa_indireta(baixa_pressao_oleo, X).
X = superaquecimento.

?- causa_indireta(curto_circuito, X).
X = parada_inesperada.

% 4) Falhas raiz da máquina
?- causa_raiz(maquina_a, F).
F = baixa_pressao_oleo ;
F = sensor_inoperante ;
F = vibracao_excessiva.

% 5) Diagnóstico com confiança
?- diagnostico(bomba_oleo, F, C).
F = baixa_pressao_oleo,
C = 0.9.

?- diagnostico(sensor_temperatura, F, C).
F = sensor_inoperante,
C = 0.8.

% 6) Diagnóstico propagado (confiança reduzida)
?- diagnostico(motor_principal, baixa_pressao_oleo, C).
C = 0.72.  % 0.9 * 0.8 = 0.72

% 7) Explicação da inferência
?- explicacao(maquina_a, superaquecimento, J).
J = 'Falha (superaquecimento) deduzida por sintomas: [leitura_inconstante, fluxo_reduzido, ruido]'.

% 8) Explicação detalhada
?- por_que(maquina_a, baixa_pressao_oleo, J).
J = 'Falha (baixa_pressao_oleo) inferida por sintomas: [leitura_inconstante, fluxo_reduzido, ruido] e relações conhecidas: [(fluxo_reduzido, baixa_pressao_oleo, 0.9), ...]'.

% 9) Ações corretivas
?- acao_corretiva(superaquecimento, A).
A = 'Verificar sistema de refrigeração e nível de óleo'.

?- acao_corretiva(baixa_pressao_oleo, A).
A = 'Verificar bomba de óleo e nível do reservatório'.

% 10) Recomendações com prioridade
?- recomendar_acao(maquina_a, superaquecimento, P, A).
P = urgente,
A = 'Verificar sistema de refrigeração e nível de óleo'.

?- recomendar_acao(maquina_a, sensor_inoperante, P, A).
P = baixa,
A = 'Calibrar ou substituir sensor'.

% 11) Listar todos os subcomponentes de uma máquina
?- subcomponente(maquina_a, S).
S = motor_principal ;
S = sistema_eletrico ;
S = bomba_oleo ;
S = eixo_rotacao ;
S = sensor_temperatura ;
S = circuito_controle.

% 12) Verificar hierarquia transitiva
?- subcomponente(maquina_a, bomba_oleo).
true.

?- subcomponente(maquina_a, sensor_temperatura).
true.

% 13) Listar todas as falhas de alta severidade
?- falha(F, _, alta).
F = superaquecimento ;
F = curto_circuito ;
F = parada_inesperada.

% 14) Listar todas as falhas mecânicas
?- falha(F, mecanica, _).
F = superaquecimento ;
F = baixa_pressao_oleo ;
F = vibracao_excessiva ;
F = eixo_desalinhado.

% 15) Verificar cadeia causal completa
?- causa_indireta(baixa_pressao_oleo, F).
F = superaquecimento.

% 16) Listar todos os sintomas observados
?- sintoma(C, S).
C = sensor_temperatura, S = leitura_inconstante ;
C = eixo_rotacao, S = ruido ;
C = bomba_oleo, S = fluxo_reduzido.
```

---

## 🧠 Conceitos Aplicados

- **Herança e Propagação Recursiva**: Fecho transitivo de subcomponentes (`subcomponente/2`)
- **Raciocínio Causal**: Encadeamento de causas e efeitos (`causa/3` e `causa_indireta/2`)
- **Combinação de Fatos**: Sintomas ↔ Falhas ↔ Causas (múltiplas fontes de evidência)
- **Busca Lógica com Incerteza**: Pesos de confiança (0.0 a 1.0) para probabilidades
- **Explicabilidade Simbólica**: Geração automática de justificativas textuais
- **Diagnóstico Hierárquico**: Raciocínio "bottom-up" (da peça → máquina)
- **Findall e Agregação**: Coleta de todos os sintomas e relações para explicação
- **Negação como Falha**: Identificação de falhas-raiz (não causadas por outras)

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

1. A base de dados deve conter **pelo menos 5 componentes**, **10 sintomas** e **8 falhas**
2. Teste casos de **propagação hierárquica** (falha em subcomponente afeta componente pai)
3. Teste casos de **encadeamento causal** (falha A causa B, B causa C)
4. Implemente **pesos de confiança** para todas as relações sintoma-falha e causa-efeito
5. Todas as falhas devem ter **tipo** (mecânica, elétrica, geral) e **severidade** (alta, média, baixa)
6. Implemente **explicações textuais** para todos os diagnósticos
7. Use **findall** para coletar evidências e gerar explicações completas
8. Teste **identificação de falhas-raiz** (causas originais que não são causadas por outras)
9. Implemente **pelo menos uma extensão** da tabela de extensões sugeridas
10. Organize o código em **múltiplos arquivos** conforme a estrutura sugerida

