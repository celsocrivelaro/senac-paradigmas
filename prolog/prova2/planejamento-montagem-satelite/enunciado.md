**Tema:** 🛰️ Planejamento de Montagem de Satélite

---

## 🎯 Objetivo

Modelar, em **Prolog**, um sistema lógico para planejar **a montagem de um satélite**, onde cada **módulo** depende de outros módulos estarem prontos.

O sistema deve:

1. Representar **etapas com dependências diretas e indiretas**
2. Gerar uma **sequência válida de montagem** (ordenamento topológico)
3. Calcular o **tempo total estimado**
4. Verificar se uma sequência proposta **viola alguma dependência**
5. (Extensão) Planejar a montagem em **duas estações paralelas**, com restrição de **tipos de técnicos** e **equipamentos**

Consultas esperadas:

```prolog
topologica(Ordem).
sequencia_valida(Sequencia).
tempo_total(Sequencia, Tempo).
ciclo_existe.
planejar_paralelo(Plano).
compat_estacao(Modulo, Estacao).
```

---

## 🧩 Descrição do Problema

### 🛰️ Contexto e Motivação

Você é o **engenheiro de integração e testes** responsável por planejar a montagem de um satélite de comunicações em uma instalação aeroespacial.

**O Problema Real:**

A montagem de um satélite é um processo complexo que envolve dezenas de módulos interdependentes:

1. **Dependências Rígidas**: Você não pode instalar painéis solares antes da estrutura principal estar pronta. Não pode testar comunicação antes de integrar a antena. Cada módulo tem pré-requisitos que devem ser respeitados.

2. **Ordenamento Topológico**: Com 11 módulos e múltiplas dependências, encontrar uma sequência válida manualmente é propenso a erros. O sistema deve gerar automaticamente uma ordem que respeite todas as precedências.

3. **Recursos Limitados**: Você tem apenas 2 estações de trabalho:
   - **Estação 1**: bancada eletrônica + plataforma de montagem
   - **Estação 2**: bancada eletrônica + guindaste leve

   Cada módulo requer equipamentos específicos. Por exemplo, a estrutura principal precisa da plataforma de montagem, enquanto a antena precisa do guindaste leve.

4. **Planejamento Temporal**: Cada módulo tem uma duração estimada (4 a 12 horas). Em montagem sequencial, o projeto levaria 78 horas. Com paralelização inteligente, você pode reduzir para ~61 horas.

5. **Detecção de Erros**: Se alguém acidentalmente criar uma dependência circular (A depende de B, B depende de A), o sistema deve detectar e alertar.

6. **Otimização**: O objetivo é minimizar o **makespan** (tempo total do projeto), alocando módulos às estações de forma inteligente, respeitando dependências e disponibilidade de equipamentos.

**Exemplo Concreto:**

```
estrutura_principal (10h) → painel_solar (8h) → gerador_energia (5h)
                          ↘ computador_bordo (6h) → sensores (4h)
                                                  → antena (4h)
tanque_combustivel (8h) → sistema_propulsao (12h)

Todos convergem para → integracao_final (10h) → testes (6h + 5h)
```

**O Desafio:**

Implementar um sistema lógico que:
- Modela **dependências diretas e transitivas**
- Gera **ordenamento topológico** automaticamente
- Detecta **ciclos** (erros de modelagem)
- Verifica **validade de sequências** propostas
- Calcula **tempo total** de montagem
- Planeja **alocação paralela** em múltiplas estações
- Respeita **compatibilidade de equipamentos**

### 🎯 Objetivos de Aprendizagem

- Modelar grafos de dependências usando o paradigma lógico
- Implementar algoritmo de ordenamento topológico
- Detectar ciclos em grafos direcionados
- Aplicar raciocínio temporal e planejamento
- Simular alocação paralela de recursos
- Utilizar findall para agregação de durações
- Organizar planejamento em múltiplos arquivos

---

## 🛰️ Base de Fatos (Projeto de Satélite)

### Módulos do Satélite
```prolog
% =========================
% MÓDULOS DO SATÉLITE
% =========================
modulo(estrutura_principal).
modulo(painel_solar).
modulo(gerador_energia).
modulo(computador_bordo).
modulo(sensores).
modulo(antena).
modulo(sistema_propulsao).
modulo(tanque_combustivel).
modulo(integracao_final).
modulo(teste_vibracao).
modulo(teste_comunicacao).
```

### Dependências de Montagem
```prolog
% =========================
% DEPENDÊNCIAS DE MONTAGEM
% depende(Posterior, Anterior)
% "Posterior" só pode ser montado após "Anterior" estar pronto
% =========================
% Estrutura principal é a base
depende(painel_solar, estrutura_principal).
depende(gerador_energia, painel_solar).
depende(computador_bordo, estrutura_principal).
depende(sensores, computador_bordo).
depende(antena, computador_bordo).

% Sistema de propulsão
depende(sistema_propulsao, tanque_combustivel).

% Integração final depende de múltiplos módulos
depende(integracao_final, [estrutura_principal, gerador_energia, sensores,
                           antena, sistema_propulsao]).

% Testes finais
depende(teste_vibracao, integracao_final).
depende(teste_comunicacao, integracao_final).
```

### Durações Estimadas
```prolog
% =========================
% DURAÇÕES ESTIMADAS (em horas)
% =========================
duracao(estrutura_principal, 10).
duracao(painel_solar, 8).
duracao(gerador_energia, 5).
duracao(computador_bordo, 6).
duracao(sensores, 4).
duracao(antena, 4).
duracao(sistema_propulsao, 12).
duracao(tanque_combustivel, 8).
duracao(integracao_final, 10).
duracao(teste_vibracao, 6).
duracao(teste_comunicacao, 5).
```

### Estações de Trabalho e Equipamentos
```prolog
% =========================
% ESTAÇÕES DE TRABALHO E EQUIPAMENTOS
% =========================
estacao(e1).
estacao(e2).

% Equipamentos disponíveis em cada estação
equipamento(e1, bancada_eletronica).
equipamento(e1, plataforma_montagem).

equipamento(e2, bancada_eletronica).
equipamento(e2, guindaste_leve).
```

### Recursos Requeridos por Módulo
```prolog
% =========================
% RECURSOS REQUERIDOS POR MÓDULO
% =========================
requer(estrutura_principal, plataforma_montagem).
requer(painel_solar, bancada_eletronica).
requer(gerador_energia, bancada_eletronica).
requer(computador_bordo, bancada_eletronica).
requer(sensores, bancada_eletronica).
requer(antena, guindaste_leve).
requer(sistema_propulsao, plataforma_montagem).
requer(tanque_combustivel, guindaste_leve).
requer(integracao_final, plataforma_montagem).
requer(teste_vibracao, guindaste_leve).
requer(teste_comunicacao, bancada_eletronica).
```

---

## 📂 Estrutura dos Arquivos e Entrada-Saída

### Arquivos de Entrada
- **`entrada.txt`**: Contém os fatos da base de conhecimento (módulos, dependências, durações, equipamentos)

### Arquivos Prolog
- **`principal.pl`**: Arquivo principal que carrega os demais módulos e a base de dados
- **`componentes.pl`**: Predicados relacionados a módulos e durações
- **`dependencias.pl`**: Predicados de dependências e ordenamento topológico
- **`planejamento.pl`**: Predicados de planejamento sequencial e paralelo
- **`recursos.pl`**: Predicados de alocação de estações e equipamentos

### Arquivo de Saída
- **`saida.txt`**: Sequências de montagem, cronogramas e alocações

---

## 🧱 Tarefas Obrigatórias

### 1. Flatten de Dependências Compostas

#### 1.1. `depende_direto/2` - Expansão de Dependências
```prolog
% ============================================
% DEPENDE_DIRETO/2
% ============================================
% Descrição: Expande dependências compostas (listas) em dependências diretas
%            individuais. Normaliza a representação de dependências.
%
% Parâmetros:
%   - A: átomo identificando o módulo dependente
%   - B: átomo identificando o módulo do qual A depende
%
% Comportamento:
%   - Caso 1: Dependência de lista
%     * depende(A, Bs) onde Bs é lista
%     * Expande para múltiplas dependências diretas (A depende de cada B em Bs)
%   - Caso 2: Dependência simples
%     * depende(A, B) onde B não é lista
%     * Mantém dependência direta
%
% Uso:
%   - Normalização de dependências
%   - Facilita processamento de grafos
%   - Base para ordenamento topológico
%
% Exemplos de uso:
%   ?- depende_direto(painel_solar, B).
%   B = estrutura_base ;
%   B = sistema_eletrico.  % expande lista de dependências
%
depende_direto(A, B).
```

### 2. Fecho Transitivo de Precedência

#### 2.1. `anterior/2` - Relação de Precedência Transitiva
```prolog
% ============================================
% ANTERIOR/2
% ============================================
% Descrição: Implementa o fecho transitivo da relação de precedência entre
%            módulos. A é anterior a B se B depende de A (direta ou transitivamente).
%
% Parâmetros:
%   - A: átomo identificando o módulo anterior (precedente)
%   - B: átomo identificando o módulo posterior (dependente)
%
% Comportamento:
%   - Caso base: B depende diretamente de A
%     * A deve ser montado antes de B
%   - Caso recursivo: B depende de A, B é anterior a C
%     * A deve ser montado antes de C (transitividade)
%
% Interpretação:
%   - anterior(A, B) significa "A deve vir antes de B na sequência"
%   - Permite navegar por toda a cadeia de dependências
%
% Exemplos de uso:
%   ?- anterior(estrutura_base, painel_solar).
%   true.  % precedência direta
%
%   ?- anterior(estrutura_base, sistema_comunicacao).
%   true.  % precedência transitiva
%
anterior(A, B).
```

### 3. Detecção de Ciclos

#### 3.1. `ciclo_existe/0` - Detecção de Dependências Circulares
```prolog
% ============================================
% CICLO_EXISTE/0
% ============================================
% Descrição: Detecta se existe um ciclo no grafo de dependências. Um ciclo
%            ocorre quando há dependência circular entre módulos.
%
% Parâmetros:
%   - Nenhum (predicado sem argumentos)
%
% Comportamento:
%   - Procura dois módulos X e Y onde:
%     * X é anterior a Y
%     * Y é anterior a X
%   - Usa cut (!) para parar na primeira ocorrência
%   - Sucede se há ciclo, falha se não há
%
% Uso:
%   - Validação de dependências
%   - Pré-condição para ordenamento topológico
%   - Detecção de erros de especificação
%
% Exemplos de uso:
%   ?- ciclo_existe.
%   false.  % grafo acíclico (válido)
%
%   % Se houvesse: depende(a, b), depende(b, a)
%   ?- ciclo_existe.
%   true.  % ciclo detectado (inválido)
%
ciclo_existe.
```

### 4. Ordenamento Topológico (Sequência Válida)

#### 4.1. `modulos/1` - Lista de Todos os Módulos
```prolog
% ============================================
% MODULOS/1
% ============================================
% Descrição: Coleta todos os módulos definidos na base de conhecimento.
%
% Parâmetros:
%   - L: lista de átomos representando módulos (saída)
%
modulos(L).
```

#### 4.2. `sem_precedencia/2` - Verificação de Módulo Sem Dependências
```prolog
% ============================================
% SEM_PRECEDENCIA/2
% ============================================
% Descrição: Verifica se um módulo não tem precedências pendentes em um
%            conjunto de dependências.
%
% Parâmetros:
%   - M: átomo identificando o módulo
%   - Deps: lista de dependências no formato d(A, B)
%
sem_precedencia(M, Deps).
```

#### 4.3. `arestas/1` - Coleta de Arestas do Grafo
```prolog
% ============================================
% ARESTAS/1
% ============================================
% Descrição: Coleta todas as arestas do grafo de dependências no formato
%            d(A, B) onde A depende de B.
%
% Parâmetros:
%   - Deps: lista de dependências no formato d(A, B) (saída)
%
arestas(Deps).
```

#### 4.4. `topologica/1` - Ordenamento Topológico Principal
```prolog
% ============================================
% TOPOLOGICA/1
% ============================================
% Descrição: Gera um ordenamento topológico válido dos módulos usando o
%            algoritmo de Kahn. Retorna sequência que respeita todas as dependências.
%
% Parâmetros:
%   - Ordem: lista ordenada de módulos (saída)
%
% Comportamento:
%   - Verifica que não há ciclos
%   - Coleta todos os módulos e arestas
%   - Aplica algoritmo de ordenamento
%   - Reverte resultado para ordem correta
%
% Algoritmo de Kahn:
%   1. Encontra módulos sem dependências pendentes
%   2. Remove módulo e suas arestas
%   3. Repete até processar todos
%
% Exemplos de uso:
%   ?- topologica(O).
%   O = [estrutura_base, sistema_eletrico, painel_solar, antena, sistema_comunicacao].
%
topologica(Ordem).
```

#### 4.5. `ordena/4` - Algoritmo de Ordenamento Recursivo
```prolog
% ============================================
% ORDENA/4
% ============================================
% Descrição: Implementa o algoritmo de Kahn recursivamente para ordenamento
%            topológico.
%
% Parâmetros:
%   - Mods: lista de módulos restantes a processar
%   - Deps: lista de dependências restantes
%   - Acc: acumulador com ordem parcial (reversa)
%   - Ordem: ordem final (saída)
%
% Comportamento:
%   - Caso base: lista vazia → retorna acumulador
%   - Caso recursivo:
%     * Encontra módulos sem entrada (sem dependências pendentes)
%     * Escolhe primeiro (ordenado alfabeticamente para determinismo)
%     * Remove módulo e suas arestas
%     * Continua recursivamente
%
ordena(Mods, Deps, Acc, Ordem).
```

### 5. Verificação de Sequência Válida

#### 5.1. `sequencia_valida/1` - Validação de Sequência Proposta
```prolog
% ============================================
% SEQUENCIA_VALIDA/1
% ============================================
% Descrição: Verifica se uma sequência proposta de montagem é válida, ou seja,
%            contém todos os módulos e respeita todas as dependências.
%
% Parâmetros:
%   - Seq: lista de módulos representando a sequência proposta
%
% Comportamento:
%   - Verificação 1: Completude
%     * Verifica que Seq contém todos os módulos (sem duplicatas)
%     * Usa msort para ordenar e comparar
%   - Verificação 2: Respeito às dependências
%     * Para cada dependência depende_direto(B, A):
%       - A deve aparecer antes de B na sequência
%       - Usa nth1 para obter posições
%       - Verifica PA < PB
%     * Usa negação como falha (\+) para garantir que não há violações
%
% Exemplos de uso:
%   ?- sequencia_valida([estrutura_base, sistema_eletrico, painel_solar]).
%   true.  % sequência válida
%
%   ?- sequencia_valida([painel_solar, estrutura_base]).
%   false.  % viola dependência
%
sequencia_valida(Seq).
```

### 6. Cálculo do Tempo Total

#### 6.1. `tempo_total/2` - Cálculo de Tempo de Montagem em Série
```prolog
% ============================================
% TEMPO_TOTAL/2
% ============================================
% Descrição: Calcula o tempo total de montagem de uma sequência em série
%            (um módulo por vez).
%
% Parâmetros:
%   - Seq: lista de módulos representando a sequência
%   - T: número representando o tempo total em horas (saída)
%
% Comportamento:
%   - Coleta durações de todos os módulos na sequência
%   - Soma todas as durações
%   - Retorna tempo total
%
% Uso:
%   - Estimativa de tempo de projeto
%   - Comparação de sequências
%   - Planejamento de recursos
%
% Exemplos de uso:
%   ?- tempo_total([estrutura_base, painel_solar, antena], T).
%   T = 18.  % soma das durações
%
tempo_total(Seq, T).
```

### 7. Compatibilidade com Estação

#### 7.1. `compat_estacao/2` - Verificação de Compatibilidade
```prolog
% ============================================
% COMPAT_ESTACAO/2
% ============================================
% Descrição: Verifica se um módulo pode ser montado em uma estação específica,
%            baseado nos equipamentos requeridos e disponíveis.
%
% Parâmetros:
%   - Mod: átomo identificando o módulo
%   - Est: átomo identificando a estação
%
% Comportamento:
%   - Obtém equipamento requerido pelo módulo
%   - Verifica se estação possui o equipamento
%   - Sucede se há compatibilidade
%
% Uso:
%   - Alocação de recursos
%   - Planejamento paralelo
%   - Verificação de viabilidade
%
% Exemplos de uso:
%   ?- compat_estacao(painel_solar, estacao_a).
%   true.  % estacao_a tem equipamento necessário
%
compat_estacao(Mod, Est).
```

### 8. Planejamento Paralelo

#### 8.1. `planejar_paralelo/1` - Planejamento com Múltiplas Estações
```prolog
% ============================================
% PLANEJAR_PARALELO/1
% ============================================
% Descrição: Gera um plano de montagem paralela alocando módulos em múltiplas
%            estações, respeitando dependências e recursos.
%
% Parâmetros:
%   - Plano: lista de tuplas (Modulo, Estacao, Inicio, Fim) (saída)
%
% Comportamento:
%   - Obtém ordenamento topológico válido
%   - Aloca módulos sequencialmente usando planejar_lista/3
%   - Retorna plano completo com alocações e tempos
%
% Estratégia:
%   - Respeita ordem topológica (dependências)
%   - Aloca em estação que termina mais cedo
%   - Minimiza tempo total (makespan)
%
% Exemplos de uso:
%   ?- planejar_paralelo(P).
%   P = [(estrutura_base, estacao_a, 0, 8),
%        (sistema_eletrico, estacao_b, 0, 6),
%        (painel_solar, estacao_a, 8, 13), ...].
%
planejar_paralelo(Plano).
```

#### 8.2. `planejar_lista/3` - Alocação Recursiva de Módulos
```prolog
% ============================================
% PLANEJAR_LISTA/3
% ============================================
% Descrição: Aloca módulos recursivamente em estações, construindo o plano
%            de montagem paralela.
%
% Parâmetros:
%   - Mods: lista de módulos restantes a alocar
%   - Acc: acumulador com plano parcial
%   - PlanoOut: plano completo (saída)
%
% Comportamento:
%   - Caso base: lista vazia → retorna acumulador
%   - Caso recursivo:
%     * Obtém duração do módulo
%     * Encontra estações compatíveis
%     * Calcula tempo de início em cada estação
%     * Escolhe estação que termina mais cedo
%     * Adiciona alocação ao plano
%     * Continua com próximos módulos
%
% Estratégia de alocação:
%   - Earliest Finish Time (EFT)
%   - Minimiza tempo de conclusão
%   - Balanceia carga entre estações
%
planejar_lista(Mods, Acc, PlanoOut).
```

#### 8.3. `ultimo_fim/3` - Cálculo de Tempo de Disponibilidade
```prolog
% ============================================
% ULTIMO_FIM/3
% ============================================
% Descrição: Encontra o último tempo de término de uma estação no plano atual,
%            determinando quando a estação estará disponível.
%
% Parâmetros:
%   - E: átomo identificando a estação
%   - Plano: lista de alocações no formato (Mod, Est, Inicio, Fim)
%   - T: número representando o tempo de disponibilidade (saída)
%
% Comportamento:
%   - Coleta todos os tempos de fim da estação E
%   - Se lista vazia → T = 0 (estação livre desde o início)
%   - Caso contrário → T = máximo dos tempos de fim
%
% Uso:
%   - Cálculo de tempo de início de próxima tarefa
%   - Gerenciamento de recursos
%   - Otimização de makespan
%
ultimo_fim(E, Plano, T).
```

---

## ✨ Extensões (Escolha pelo menos UMA)

| Conceito | Extensão Possível |
|----------|-------------------|
| **Múltiplos Técnicos** | Adicionar `tecnico(Nome, Especialidade)` e `necessita(Mod, Especialidade)`. Alocar técnicos disponíveis. |
| **Janela Temporal** | `restricao_tempo(Mod, InicioMin, InicioMax)` para limitar quando pode começar. Horários de trabalho. |
| **Falhas ou Revisões** | `revisao(Mod, DuracaoExtra)` para inserir retrabalho. Contingências e replanejamento. |
| **Planejamento Ótimo** | Escolher o plano com **menor makespan** (tempo total). Comparar múltiplas alocações. |
| **Análise de Caminho Crítico** | Determinar quais módulos definem o tempo mínimo total. Identificar gargalos. |
| **Recursos Consumíveis** | Modelar materiais que se esgotam (parafusos, solda). Verificar disponibilidade. |
| **Prioridades** | Módulos críticos têm prioridade na alocação. Ordenamento por importância. |

### Exemplo de Extensão: Análise de Caminho Crítico
```prolog
% Calcula o tempo mais cedo de início de cada módulo
tempo_mais_cedo(M, T) :-
    findall(TA,
        (depende_direto(M, A), tempo_mais_cedo(A, TA0),
         duracao(A, DA), TA is TA0 + DA),
        Ts),
    (Ts = [] -> T = 0 ; max_list(Ts, T)).

% Calcula o tempo mais tarde de início sem atrasar o projeto
tempo_mais_tarde(M, Tfinal, T) :-
    findall(TB,
        (depende_direto(B, M), tempo_mais_tarde(B, Tfinal, TB0),
         duracao(M, DM), TB is TB0 - DM),
        Ts),
    (Ts = [] -> T is Tfinal - DM ; min_list(Ts, T)),
    duracao(M, DM).

% Módulo está no caminho crítico se tempo_mais_cedo = tempo_mais_tarde
caminho_critico(M, Tfinal) :-
    tempo_mais_cedo(M, TE),
    tempo_mais_tarde(M, Tfinal, TL),
    TE =:= TL.

% Lista todos os módulos do caminho crítico
modulos_criticos(Tfinal, Criticos) :-
    findall(M, (modulo(M), caminho_critico(M, Tfinal)), Criticos).

% Exemplo de uso:
% ?- topologica(O), tempo_total(O, T), modulos_criticos(T, Crit).
% T = 78,
% Crit = [estrutura_principal, painel_solar, gerador_energia,
%         integracao_final, teste_vibracao].
```

---

## ▶️ Exemplos de Execução

```prolog
% 1) Obter ordem topológica (sequência válida de montagem)
?- topologica(O).
O = [estrutura_principal, tanque_combustivel, painel_solar, gerador_energia,
     computador_bordo, sensores, antena, sistema_propulsao, integracao_final,
     teste_vibracao, teste_comunicacao].

% 2) Verificar se uma sequência proposta é válida
?- sequencia_valida([estrutura_principal, painel_solar, gerador_energia,
                     computador_bordo, sensores, antena, tanque_combustivel,
                     sistema_propulsao, integracao_final, teste_vibracao,
                     teste_comunicacao]).
true.

% 3) Verificar sequência inválida (viola dependência)
?- sequencia_valida([painel_solar, estrutura_principal, gerador_energia,
                     computador_bordo, sensores, antena, tanque_combustivel,
                     sistema_propulsao, integracao_final, teste_vibracao,
                     teste_comunicacao]).
false.  % painel_solar antes de estrutura_principal viola dependência

% 4) Calcular tempo total (em série)
?- topologica(O), tempo_total(O, T).
O = [estrutura_principal, tanque_combustivel, painel_solar, ...],
T = 78.  % 78 horas no total

% 5) Verificar dependências diretas
?- depende_direto(painel_solar, estrutura_principal).
true.

?- depende_direto(gerador_energia, painel_solar).
true.

?- depende_direto(integracao_final, estrutura_principal).
true.

?- depende_direto(integracao_final, gerador_energia).
true.

% 6) Verificar dependências transitivas
?- anterior(estrutura_principal, gerador_energia).
true.  % estrutura → painel → gerador

?- anterior(estrutura_principal, integracao_final).
true.  % estrutura é anterior a integração (transitivo)

% 7) Testar se há ciclos (erro de modelagem)
?- ciclo_existe.
false.  % Não há ciclos no grafo

% 8) Verificar compatibilidade de estações
?- compat_estacao(estrutura_principal, e1).
true.  % e1 tem plataforma_montagem

?- compat_estacao(estrutura_principal, e2).
false.  % e2 não tem plataforma_montagem

?- compat_estacao(antena, e2).
true.  % e2 tem guindaste_leve

?- compat_estacao(painel_solar, E).
E = e1 ;
E = e2.  % ambas têm bancada_eletronica

% 9) Planejar montagem paralela
?- planejar_paralelo(P), last(P, (_, _, _, Fim)),
   format('Tempo total: ~w horas~n', [Fim]).
P = [
  (estrutura_principal, e1, 0, 10),
  (tanque_combustivel, e2, 0, 8),
  (painel_solar, e1, 10, 18),
  (gerador_energia, e1, 18, 23),
  (computador_bordo, e1, 23, 29),
  (sensores, e1, 29, 33),
  (antena, e2, 8, 12),
  (sistema_propulsao, e1, 33, 45),
  (integracao_final, e1, 45, 55),
  (teste_vibracao, e2, 55, 61),
  (teste_comunicacao, e1, 55, 60)
],
Tempo total: 61 horas.

% 10) Analisar alocação de uma estação específica
?- planejar_paralelo(P),
   findall((M, I, F), member((M, e1, I, F), P), Tarefas).
Tarefas = [
  (estrutura_principal, 0, 10),
  (painel_solar, 10, 18),
  (gerador_energia, 18, 23),
  (computador_bordo, 23, 29),
  (sensores, 29, 33),
  (sistema_propulsao, 33, 45),
  (integracao_final, 45, 55),
  (teste_comunicacao, 55, 60)
].

% 11) Listar todos os módulos
?- modulo(M).
M = estrutura_principal ;
M = painel_solar ;
M = gerador_energia ;
... (11 módulos no total)

?- findall(M, modulo(M), Ms), length(Ms, N).
Ms = [estrutura_principal, painel_solar, ...],
N = 11.

% 12) Listar durações de todos os módulos
?- findall((M, D), duracao(M, D), Duracoes).
Duracoes = [
  (estrutura_principal, 10),
  (painel_solar, 8),
  (gerador_energia, 5),
  ...
].

% 13) Calcular duração média
?- findall(D, duracao(_, D), Ds), sum_list(Ds, Total), length(Ds, N),
   Media is Total / N.
Ds = [10, 8, 5, 6, 4, 4, 12, 8, 10, 6, 5],
Total = 78,
N = 11,
Media = 7.09.

% 14) Encontrar módulo mais demorado
?- findall(D, duracao(_, D), Ds), max_list(Ds, Max), duracao(M, Max).
Ds = [10, 8, 5, 6, 4, 4, 12, 8, 10, 6, 5],
Max = 12,
M = sistema_propulsao.

% 15) Listar equipamentos de uma estação
?- equipamento(e1, Eq).
Eq = bancada_eletronica ;
Eq = plataforma_montagem.

?- findall(Eq, equipamento(e1, Eq), Eqs).
Eqs = [bancada_eletronica, plataforma_montagem].

% 16) Listar módulos que requerem um equipamento específico
?- requer(M, bancada_eletronica).
M = painel_solar ;
M = gerador_energia ;
M = computador_bordo ;
M = sensores ;
M = teste_comunicacao.

% 17) Comparar tempo sequencial vs paralelo
?- topologica(O), tempo_total(O, TSeq),
   planejar_paralelo(P), last(P, (_, _, _, TPar)),
   Economia is TSeq - TPar,
   Percentual is (Economia / TSeq) * 100.
TSeq = 78,
TPar = 61,
Economia = 17,
Percentual = 21.79.  % 21.79% de redução no tempo
```

---

## 🧠 Conceitos Aplicados

- **Grafos de Dependências**: Modelagem de relações de precedência entre tarefas
- **Ordenamento Topológico**: Algoritmo de Kahn para gerar sequência válida
- **Detecção de Ciclos**: Verificação de dependências circulares (erros de modelagem)
- **Fecho Transitivo**: Propagação de dependências indiretas
- **Planejamento Temporal**: Cálculo de tempos de início e fim de tarefas
- **Alocação de Recursos**: Distribuição de tarefas entre estações com restrições
- **Paralelização**: Execução simultânea de tarefas independentes
- **Findall e Agregação**: Coleta de durações, módulos e alocações
- **Otimização de Makespan**: Minimização do tempo total do projeto

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

1. A base de dados deve conter **pelo menos 10 módulos** e **8 dependências**
2. Implemente **ordenamento topológico** completo (algoritmo de Kahn)
3. Teste **detecção de ciclos** (adicione dependência circular para testar)
4. Implemente **verificação de sequências** válidas e inválidas
5. Calcule **tempo total** para montagem sequencial
6. Implemente **planejamento paralelo** com alocação de estações
7. Verifique **compatibilidade de equipamentos** para cada módulo
8. Teste **redução de tempo** com paralelização (sequencial vs paralelo)
9. Implemente **pelo menos uma extensão** da tabela de extensões sugeridas
10. Organize o código em **múltiplos arquivos** conforme a estrutura sugerida

---

## 💡 Variações do Problema

Este mesmo modelo pode ser adaptado para outros domínios:

- **Manutenção de Aeronaves**: Substituir módulos por componentes de avião
- **Processamento de Pedidos**: Etapas de fabricação em uma fábrica
- **Pipeline de Software CI/CD**: Estágios de build, test, deploy
- **Construção Civil**: Etapas de construção de um edifício
- **Produção de Filmes**: Pré-produção, filmagem, pós-produção

Basta trocar os módulos e as dependências!

