**Tema:** 🚛 Sistema de Alocação de Veículos e Entregas

---

## 🎯 Objetivo

Modelar, em **Prolog**, um sistema de **planejamento lógico de entregas**, onde caminhões (ou vans) precisam ser alocados para pedidos, respeitando:

- **Capacidade de carga** (peso em kg)
- **Distância e autonomia** dos veículos
- **Tipo de veículo e carga** (comum, refrigerada, perigosa)
- **Janelas de entrega** (turnos: manhã, tarde, noite)
- **Disponibilidade de motoristas** e suas licenças especiais

O sistema deve determinar **combinações válidas** de:

```prolog
(Pedido, Veículo, Motorista, Turno)
```

e permitir consultas do tipo:

> "Quais motoristas e veículos podem atender o pedido P5 no turno da tarde?"

---

## 🧩 Descrição do Problema

Você é o **responsável pelo planejamento diário de entregas** de uma transportadora.

Os pedidos de entrega variam em **peso, tipo de carga** (comum, refrigerada, perigosa) e **janela de horário**.

A frota é composta por veículos com capacidades e restrições específicas.

Cada motorista só pode operar **um veículo por turno** e alguns possuem **licenças especiais** (refrigerado, perigoso).

Implemente um sistema em Prolog que determine todas as alocações viáveis respeitando as restrições de capacidade, tipo de carga, autonomia, licenças e disponibilidade.

---

## 🎯 Objetivos de Aprendizagem

- Modelar problemas de alocação com múltiplas restrições interdependentes
- Usar backtracking para gerar soluções múltiplas
- Implementar verificação de compatibilidade (capacidade, tipo, licenças)
- Criar explicações de falhas (por que não é possível alocar)
- Organizar código modularmente

---

## 🚛 Base de Fatos

### Frota de Veículos
```prolog
% ==========================
% Frota
% veiculo(Id, CapacidadeKg, Tipo, AutonomiaKm)
% Tipo = comum | refrigerado | perigoso
% ==========================
veiculo(v1, 1000, comum, 300).
veiculo(v2, 800, refrigerado, 200).
veiculo(v3, 2000, comum, 500).
veiculo(v4, 1500, perigoso, 400).
veiculo(v5, 600, comum, 150).
```

### Motoristas
```prolog
% ==========================
% Motoristas
% motorista(Nome, Licencas, TurnosDisponiveis)
% ==========================
motorista(joao, [comum], [manha, tarde]).
motorista(maria, [comum, refrigerado], [manha, tarde]).
motorista(carlos, [comum, perigoso], [noite]).
motorista(ana, [comum], [tarde]).
motorista(ricardo, [comum, refrigerado, perigoso], [manha, tarde, noite]).
```

### Pedidos
```prolog
% ==========================
% Pedidos
% pedido(Id, PesoKg, TipoCarga, DistanciaKm, JanelaTurnos)
% ==========================
pedido(p1, 400, comum, 50, [manha, tarde]).
pedido(p2, 700, refrigerado, 120, [manha]).
pedido(p3, 1500, comum, 350, [tarde]).
pedido(p4, 900, perigoso, 200, [noite]).
pedido(p5, 500, comum, 80, [tarde, noite]).
pedido(p6, 300, refrigerado, 150, [manha, tarde]).
```

### Ocupações Existentes
```prolog
% ==========================
% Ocupações atuais (exemplo)
% ocupado(Veiculo, Turno).
% ocupado(Motorista, Turno).
% ==========================
ocupado(v1, manha).
ocupado(maria, manha).
```

---

## 📂 Estrutura dos Arquivos

**Entrada:** `entrada.txt` - Frota, motoristas, pedidos, ocupações
**Prolog:** `principal.pl`, `veiculos.pl`, `motoristas.pl`, `alocacao.pl`, `explicacao.pl`
**Saída:** `saida.txt` - Alocações e justificativas

---

## 🧱 Tarefas Obrigatórias

### 1. Adequação de Veículo

#### 1.1. `veiculo_adequado/2` - Verificação de Adequação de Veículo
```prolog
% ============================================
% VEICULO_ADEQUADO/2
% ============================================
% Descrição: Verifica se um veículo pode atender um pedido, considerando capacidade
%            de carga, autonomia (alcance) e compatibilidade de tipo de carga.
%
% Parâmetros:
%   - V: átomo identificando o veículo
%   - Pedido: átomo identificando o pedido
%
% Comportamento:
%   - Obtém características do veículo (capacidade, tipo, autonomia)
%   - Obtém requisitos do pedido (peso, tipo, distância)
%   - Verifica três restrições:
%     1. Capacidade >= Peso (veículo suporta a carga)
%     2. Autonomia >= Distância (veículo alcança o destino)
%     3. Compatibilidade de tipo:
%        * Veículos "comum" podem transportar qualquer carga
%        * Veículos especializados (refrigerado, perigoso) só transportam seu tipo
%   - Sucede se todas as restrições forem satisfeitas
%
% Tipos de veículo e compatibilidade:
%   - comum: aceita comum, refrigerado, perigoso (versátil)
%   - refrigerado: aceita apenas refrigerado (alimentos perecíveis)
%   - perigoso: aceita apenas perigoso (materiais perigosos)
%
% Exemplos de uso:
%   ?- veiculo_adequado(v1, p1).
%   true.  % v1 comum pode transportar qualquer carga
%
%   ?- veiculo_adequado(v2, p2).
%   true.  % v2 refrigerado transporta carga refrigerada
%
%   ?- veiculo_adequado(v2, p1).
%   false.  % v2 refrigerado não transporta carga comum
%
veiculo_adequado(V, Pedido).
```

### 2. Adequação de Motorista

#### 2.1. `motorista_adequado/3` - Verificação de Adequação de Motorista
```prolog
% ============================================
% MOTORISTA_ADEQUADO/3
% ============================================
% Descrição: Verifica se um motorista pode atender um pedido em um turno específico,
%            considerando licenças necessárias e disponibilidade de turnos.
%
% Parâmetros:
%   - Motorista: átomo identificando o motorista
%   - Pedido: átomo identificando o pedido
%   - Turno: átomo representando o turno (manha, tarde, noite)
%
% Comportamento:
%   - Obtém licenças e turnos disponíveis do motorista
%   - Obtém tipo de carga do pedido
%   - Verifica duas restrições:
%     1. Motorista trabalha no turno solicitado (member(Turno, Turnos))
%     2. Motorista tem licença para o tipo de carga (member(Tipo, Licencas))
%   - Sucede se ambas as restrições forem satisfeitas
%
% Tipos de licença:
%   - comum: pode transportar cargas comuns
%   - refrigerado: pode transportar cargas refrigeradas
%   - perigoso: pode transportar materiais perigosos (requer habilitação especial)
%
% Turnos:
%   - manha: 06:00 - 14:00
%   - tarde: 14:00 - 22:00
%   - noite: 22:00 - 06:00
%
% Exemplos de uso:
%   ?- motorista_adequado(m1, p1, manha).
%   true.  % m1 tem licença comum e trabalha de manhã
%
%   ?- motorista_adequado(m2, p3, tarde).
%   true.  % m2 tem licença perigoso e trabalha à tarde
%
%   ?- motorista_adequado(m1, p3, manha).
%   false.  % m1 não tem licença perigoso
%
motorista_adequado(Motorista, Pedido, Turno).
```

### 3. Disponibilidade

#### 3.1. `veiculo_disponivel/2` - Verificação de Disponibilidade de Veículo
```prolog
% ============================================
% VEICULO_DISPONIVEL/2
% ============================================
% Descrição: Verifica se um veículo está disponível em um turno específico.
%            Usa negação como falha: disponível se NÃO está ocupado.
%
% Parâmetros:
%   - V: átomo identificando o veículo
%   - Turno: átomo representando o turno
%
% Comportamento:
%   - Verifica se NÃO existe fato ocupado(V, Turno)
%   - Usa negação como falha (\+)
%   - Sucede se veículo não estiver ocupado
%   - Falha se veículo estiver ocupado
%
% Exemplos de uso:
%   ?- veiculo_disponivel(v1, manha).
%   true.  % v1 não está ocupado de manhã
%
%   ?- veiculo_disponivel(v2, tarde).
%   false.  % v2 está ocupado à tarde
%
veiculo_disponivel(V, Turno).
```

#### 3.2. `motorista_disponivel/2` - Verificação de Disponibilidade de Motorista
```prolog
% ============================================
% MOTORISTA_DISPONIVEL/2
% ============================================
% Descrição: Verifica se um motorista está disponível em um turno específico.
%            Usa negação como falha: disponível se NÃO está ocupado.
%
% Parâmetros:
%   - M: átomo identificando o motorista
%   - Turno: átomo representando o turno
%
% Comportamento:
%   - Verifica se NÃO existe fato ocupado(M, Turno)
%   - Usa negação como falha (\+)
%   - Sucede se motorista não estiver ocupado
%   - Falha se motorista estiver ocupado
%
% Exemplos de uso:
%   ?- motorista_disponivel(m1, manha).
%   true.  % m1 não está ocupado de manhã
%
%   ?- motorista_disponivel(m2, tarde).
%   false.  % m2 está ocupado à tarde
%
motorista_disponivel(M, Turno).
```

### 4. Validação de Turno

#### 4.1. `turno_valido/2` - Verificação de Janela de Entrega
```prolog
% ============================================
% TURNO_VALIDO/2
% ============================================
% Descrição: Verifica se um turno está dentro da janela de entrega permitida
%            pelo pedido. Clientes podem especificar em quais turnos aceitam receber.
%
% Parâmetros:
%   - Pedido: átomo identificando o pedido
%   - Turno: átomo representando o turno
%
% Comportamento:
%   - Obtém lista de turnos permitidos do pedido
%   - Verifica se turno solicitado está na lista
%   - Usa member/2 para verificar pertinência
%   - Sucede se turno estiver na janela
%   - Falha se turno estiver fora da janela
%
% Exemplos de uso:
%   ?- turno_valido(p1, manha).
%   true.  % p1 aceita entrega de manhã
%
%   ?- turno_valido(p1, noite).
%   false.  % p1 não aceita entrega à noite
%
turno_valido(Pedido, Turno).
```

### 5. Alocação Válida

#### 5.1. `alocacao_valida/4` - Alocação Completa e Válida
```prolog
% ============================================
% ALOCACAO_VALIDA/4
% ============================================
% Descrição: Determina uma alocação completa e válida de veículo e motorista para
%            um pedido em um turno específico, agregando todas as restrições.
%            Este é o predicado principal do sistema de alocação.
%
% Parâmetros:
%   - Pedido: átomo identificando o pedido
%   - Veiculo: átomo identificando o veículo alocado (saída)
%   - Motorista: átomo identificando o motorista alocado (saída)
%   - Turno: átomo representando o turno (saída)
%
% Comportamento:
%   - Verifica todas as restrições em sequência:
%     1. Turno válido (dentro da janela de entrega)
%     2. Veículo adequado (capacidade, alcance, tipo)
%     3. Motorista adequado (licença, turno de trabalho)
%     4. Veículo disponível (não ocupado)
%     5. Motorista disponível (não ocupado)
%   - Todas as restrições devem ser satisfeitas
%   - Falha se qualquer restrição não for atendida
%   - Pode gerar múltiplas soluções via backtracking
%
% Ordem de verificação (otimização):
%   1. Turno válido (filtro rápido)
%   2. Adequações (verificações médias)
%   3. Disponibilidades (consultas a fatos)
%
% Exemplos de uso:
%   ?- alocacao_valida(p1, V, M, T).
%   V = v1, M = m1, T = manha ;
%   V = v1, M = m2, T = manha ;
%   ...  % múltiplas soluções possíveis
%
%   ?- alocacao_valida(p1, v1, m1, manha).
%   true.  % verifica se alocação específica é válida
%
alocacao_valida(Pedido, Veiculo, Motorista, Turno).
```

### 6. Explicação de Falhas

#### 6.1. `motivo_falha/2` - Diagnóstico Simples de Falha
```prolog
% ============================================
% MOTIVO_FALHA/2
% ============================================
% Descrição: Identifica o primeiro motivo pelo qual não é possível alocar um pedido.
%            Versão simplificada que retorna apenas o tipo de problema.
%
% Parâmetros:
%   - Pedido: átomo identificando o pedido
%   - Motivo: átomo representando o tipo de falha (saída)
%
% Comportamento:
%   - Testa cada restrição em sequência usando negação como falha
%   - Retorna o primeiro motivo de falha encontrado
%   - Ordem de verificação:
%     1. turno_invalido: nenhum turno válido
%     2. nenhum_veiculo_compativel: nenhum veículo adequado
%     3. nenhum_motorista_licenciado: nenhum motorista adequado
%     4. conflito_disponibilidade: todos ocupados
%   - Usa estrutura if-then-else encadeada
%
% Motivos possíveis:
%   - turno_invalido: pedido sem janela de entrega
%   - nenhum_veiculo_compativel: nenhum veículo atende requisitos
%   - nenhum_motorista_licenciado: nenhum motorista tem licença
%   - conflito_disponibilidade: recursos ocupados
%
% Exemplos de uso:
%   ?- motivo_falha(p5, M).
%   M = nenhum_veiculo_compativel.  % carga muito pesada
%
%   ?- motivo_falha(p6, M).
%   M = nenhum_motorista_licenciado.  % ninguém tem licença perigoso
%
motivo_falha(Pedido, Motivo).
```

#### 6.2. `motivo_falha_detalhado/3` - Diagnóstico Detalhado de Falha
```prolog
% ============================================
% MOTIVO_FALHA_DETALHADO/3
% ============================================
% Descrição: Identifica o motivo detalhado pelo qual não é possível alocar um pedido
%            em um turno específico, incluindo informações contextuais.
%
% Parâmetros:
%   - Pedido: átomo identificando o pedido
%   - Turno: átomo representando o turno desejado
%   - Motivo: termo estruturado contendo detalhes da falha (saída)
%
% Comportamento:
%   - Obtém características do pedido (peso, tipo, distância, turnos)
%   - Testa cada restrição em sequência
%   - Retorna termo estruturado com informações específicas
%   - Ordem de verificação:
%     1. turno_fora_janela(Turno, TurnosPermitidos)
%     2. sem_veiculo_capacidade_ou_alcance(Peso, Distancia)
%     3. sem_motorista_licenca(TipoLicenca)
%     4. todos_veiculos_ocupados(Turno)
%     5. todos_motoristas_ocupados(Turno)
%     6. desconhecido (caso não identificado)
%
% Motivos estruturados:
%   - turno_fora_janela(T, Ts): turno T não está em Ts
%   - sem_veiculo_capacidade_ou_alcance(P, D): nenhum veículo suporta P kg ou D km
%   - sem_motorista_licenca(Tipo): nenhum motorista tem licença Tipo
%   - todos_veiculos_ocupados(T): veículos adequados ocupados no turno T
%   - todos_motoristas_ocupados(T): motoristas adequados ocupados no turno T
%   - desconhecido: motivo não identificado
%
% Uso para explicabilidade:
%   - Fornece informações específicas para o usuário
%   - Ajuda a identificar gargalos operacionais
%   - Facilita planejamento de recursos
%
% Exemplos de uso:
%   ?- motivo_falha_detalhado(p1, noite, M).
%   M = turno_fora_janela(noite, [manha, tarde]).
%
%   ?- motivo_falha_detalhado(p5, manha, M).
%   M = sem_veiculo_capacidade_ou_alcance(5000, 200).
%
%   ?- motivo_falha_detalhado(p3, tarde, M).
%   M = todos_motoristas_ocupados(tarde).
%
motivo_falha_detalhado(Pedido, Turno, Motivo).
```

---

## ✨ Extensões (Escolha pelo menos UMA)

| Tema Lógico | Extensão Sugerida |
|-------------|-------------------|
| **Constraints Múltiplas** | Permitir múltiplos pedidos no mesmo veículo até atingir limite de carga. Implementar `alocacao_multipla/4` que agrupa pedidos compatíveis. |
| **Custo / Otimização** | Minimizar total de km percorridos ou uso de frota refrigerada (mais cara). Implementar `melhor_alocacao/4` com critério de otimização. |
| **Regras Temporais** | Introduzir janelas de tempo parciais (ex.: `manha1`, `manha2`, `tarde1`, `tarde2`). Adicionar predicado `horario_compativel/2`. |
| **Hierarquia de Licenças** | Implementar hierarquia: licença "perigoso" também cobre "comum". Adicionar `licenca_cobre/2` e ajustar `motorista_adequado/3`. |
| **Falhas Explicativas** | Expandir `motivo_falha/2` para indicar exatamente qual restrição falhou e com quais valores. Incluir sugestões de solução. |
| **Simulação Dinâmica** | Atualizar `ocupado/2` dinamicamente ao fazer alocação usando `assertz/1`. Implementar `alocar_e_ocupar/4` que registra a alocação. |

### Exemplo de Extensão: Múltiplos Pedidos no Mesmo Veículo
```prolog
% Agrupa pedidos compatíveis no mesmo veículo
alocacao_multipla(ListaPedidos, Veiculo, Motorista, Turno) :-
    veiculo(Veiculo, Capacidade, TipoV, Autonomia),
    motorista_adequado_multiplo(Motorista, ListaPedidos, Turno),
    veiculo_disponivel(Veiculo, Turno),
    motorista_disponivel(Motorista, Turno),
    % Verificar capacidade total
    findall(Peso, (member(P, ListaPedidos), pedido(P, Peso, _, _, _)), Pesos),
    sum_list(Pesos, PesoTotal),
    PesoTotal =< Capacidade,
    % Verificar distância máxima
    findall(Dist, (member(P, ListaPedidos), pedido(P, _, _, Dist, _)), Dists),
    max_list(Dists, DistMax),
    DistMax =< Autonomia,
    % Verificar tipos compatíveis
    forall(member(P, ListaPedidos),
           (pedido(P, _, TipoP, _, _),
            (TipoV = TipoP ; TipoV = comum))).

% Motorista adequado para múltiplos pedidos
motorista_adequado_multiplo(Motorista, ListaPedidos, Turno) :-
    motorista(Motorista, Licencas, Turnos),
    member(Turno, Turnos),
    forall(member(P, ListaPedidos),
           (pedido(P, _, Tipo, _, Janela),
            member(Tipo, Licencas),
            member(Turno, Janela))).

% Exemplo de uso:
% ?- alocacao_multipla([p1, p5], V, M, tarde).
% V = v3, M = joao ;
% V = v3, M = ana ;
% V = v3, M = ricardo.
% (p1: 400kg + p5: 500kg = 900kg <= 2000kg capacidade de v3)
```

### Exemplo de Extensão: Otimização por Distância
```prolog
% Encontra alocação com menor distância total
melhor_alocacao_distancia(Pedido, Veiculo, Motorista, Turno) :-
    findall((Dist, V, M, T),
            (alocacao_valida(Pedido, V, M, T),
             pedido(Pedido, _, _, Dist, _)),
            Lista),
    sort(Lista, [(_, Veiculo, Motorista, Turno)|_]).

% Minimiza uso de veículos especializados (mais caros)
custo_veiculo(V, Custo) :-
    veiculo(V, _, Tipo, _),
    (Tipo = comum -> Custo = 1 ;
     Tipo = refrigerado -> Custo = 2 ;
     Tipo = perigoso -> Custo = 3).

melhor_alocacao_custo(Pedido, Veiculo, Motorista, Turno) :-
    findall((Custo, V, M, T),
            (alocacao_valida(Pedido, V, M, T),
             custo_veiculo(V, Custo)),
            Lista),
    sort(Lista, [(_, Veiculo, Motorista, Turno)|_]).
```

---

## ▶️ Exemplos de Execução

```prolog
% 1) Todas as combinações possíveis
?- alocacao_valida(Pedido, Veiculo, Motorista, Turno).
Pedido = p1, Veiculo = v1, Motorista = joao, Turno = tarde ;
Pedido = p1, Veiculo = v1, Motorista = ana, Turno = tarde ;
Pedido = p1, Veiculo = v3, Motorista = joao, Turno = manha ;
Pedido = p1, Veiculo = v3, Motorista = joao, Turno = tarde ;
...

% 2) Quais motoristas e veículos podem atender o pedido p5 à tarde?
?- alocacao_valida(p5, V, M, tarde).
V = v1, M = joao ;
V = v1, M = ana ;
V = v3, M = joao ;
V = v3, M = ana ;
V = v5, M = joao ;
V = v5, M = ana ;
false.

% 3) Verificar alocação específica
?- alocacao_valida(p2, v2, maria, manha).
false.  % maria está ocupada na manhã

?- alocacao_valida(p2, v2, ricardo, manha).
true.  % ricardo tem licença refrigerado e está disponível

% 4) Pedidos que ainda não têm solução possível
?- pedido(P, _, _, _, _), \+ alocacao_valida(P, _, _, _).
false.  % todos os pedidos têm pelo menos uma solução

% 5) Verificar motivo de falha
?- motivo_falha(p3, Motivo).
Motivo = nenhum_veiculo_compativel.
% p3 tem 1500kg e 350km, apenas v3 tem capacidade e alcance

% 6) Motivo de falha detalhado
?- motivo_falha_detalhado(p2, tarde, Motivo).
Motivo = turno_fora_janela(tarde, [manha]).
% p2 só pode ser entregue na manhã

% 7) Listar todos os veículos adequados para um pedido
?- veiculo_adequado(V, p1).
V = v1 ;
V = v3 ;
V = v5.

% 8) Listar todos os motoristas adequados para um pedido em um turno
?- motorista_adequado(M, p4, noite).
M = carlos ;
M = ricardo.

% 9) Verificar disponibilidade
?- veiculo_disponivel(v1, manha).
false.  % v1 está ocupado na manhã

?- veiculo_disponivel(v1, tarde).
true.

% 10) Encontrar melhor alocação (menor distância)
?- findall((Dist, P, V, M, T),
           (alocacao_valida(P, V, M, T),
            pedido(P, _, _, Dist, _)),
           Lista),
   sort(Lista, Ordenada),
   Ordenada = [(MenorDist, Ped, Veic, Mot, Tur)|_].
MenorDist = 50,
Ped = p1,
Veic = v1,
Mot = joao,
Tur = tarde.

% 11) Contar quantas alocações possíveis para cada pedido
?- pedido(P, _, _, _, _),
   findall((V, M, T), alocacao_valida(P, V, M, T), Solucoes),
   length(Solucoes, N),
   format('Pedido ~w: ~w soluções~n', [P, N]),
   fail.
Pedido p1: 12 soluções
Pedido p2: 2 soluções
Pedido p3: 4 soluções
Pedido p4: 2 soluções
Pedido p5: 12 soluções
Pedido p6: 6 soluções

% 12) Verificar se há conflito de alocação
?- alocacao_valida(p1, v1, joao, manha),
   alocacao_valida(p2, v1, maria, manha).
false.  % v1 não pode ser usado duas vezes no mesmo turno
```

---

## 🧠 Conceitos Aplicados

Este trabalho exercita os seguintes conceitos de Programação Lógica:

- **Domínios Interdependentes**
  - `(Pedido ↔ Veículo ↔ Motorista ↔ Turno)`
  - Múltiplas variáveis que se influenciam mutuamente
  - Backtracking automático para explorar todas as combinações

- **Restrições Compostas**
  - Capacidade de carga (peso do pedido vs. capacidade do veículo)
  - Alcance (distância vs. autonomia)
  - Compatibilidade de tipos (carga vs. veículo)
  - Licenças (tipo de carga vs. habilitação do motorista)
  - Janelas temporais (turnos disponíveis vs. janela de entrega)
  - Disponibilidade (ocupações existentes)

- **Negação como Falha**
  - `veiculo_disponivel(V, T) :- \+ ocupado(V, T)`
  - `motorista_disponivel(M, T) :- \+ ocupado(M, T)`
  - Verificação de ausência de conflitos

- **Backtracking e Geração de Soluções Múltiplas**
  - Exploração sistemática do espaço de busca
  - Geração de todas as alocações viáveis
  - Uso de `findall/3` para coletar soluções

- **Explicações Lógicas**
  - Identificação de motivos de falha
  - Diagnóstico de restrições violadas
  - Justificativas para impossibilidade de alocação

- **Planejamento Lógico**
  - Alocação de recursos escassos
  - Satisfação de múltiplas restrições simultaneamente
  - Otimização de critérios (distância, custo)

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

- Base: 5+ veículos, 4+ motoristas, 6+ pedidos
- Teste: capacidade, tipo, licença, disponibilidade
- Explicações automáticas de falhas

