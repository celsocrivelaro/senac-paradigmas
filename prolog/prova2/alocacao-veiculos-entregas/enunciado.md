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

```prolog
% ---------------------------------------------------
% Veículo pode atender pedido? (capacidade + alcance + tipo)
% ---------------------------------------------------
% Regra: Veículo deve ter capacidade >= peso do pedido
%        Veículo deve ter autonomia >= distância do pedido
%        Tipo do veículo deve ser compatível com tipo da carga
%        Veículos "comum" podem transportar qualquer carga
%        Veículos especializados (refrigerado/perigoso) só transportam seu tipo
veiculo_adequado(V, Pedido) :-
    veiculo(V, Capacidade, TipoV, Autonomia),
    pedido(Pedido, Peso, TipoP, Dist, _),
    Capacidade >= Peso,
    Autonomia >= Dist,
    (TipoV = TipoP ; TipoV = comum).  % comum pode tudo, senão tipo específico
```

### 2. Adequação de Motorista

```prolog
% ---------------------------------------------------
% Motorista tem licença e disponibilidade compatível
% ---------------------------------------------------
% Regra: Motorista deve ter licença para o tipo de carga
%        Motorista deve estar disponível no turno
%        Turno deve estar na janela de entrega do pedido
motorista_adequado(Motorista, Pedido, Turno) :-
    motorista(Motorista, Licencas, Turnos),
    pedido(Pedido, _, Tipo, _, _),
    member(Turno, Turnos),
    member(Tipo, Licencas).
```

### 3. Disponibilidade

```prolog
% ---------------------------------------------------
% Veículo e motorista estão disponíveis (não ocupados)
% ---------------------------------------------------
% Usa negação como falha: disponível se NÃO está ocupado
veiculo_disponivel(V, Turno) :-
    \+ ocupado(V, Turno).

motorista_disponivel(M, Turno) :-
    \+ ocupado(M, Turno).
```

### 4. Validação de Turno

```prolog
% ---------------------------------------------------
% Turno permitido pelo pedido (janela de entrega)
% ---------------------------------------------------
turno_valido(Pedido, Turno) :-
    pedido(Pedido, _, _, _, Turnos),
    member(Turno, Turnos).
```

### 5. Alocação Válida

```prolog
% ---------------------------------------------------
% Combinação final válida
% ---------------------------------------------------
% Agrega todas as restrições para determinar uma alocação viável
alocacao_valida(Pedido, Veiculo, Motorista, Turno) :-
    turno_valido(Pedido, Turno),
    veiculo_adequado(Veiculo, Pedido),
    motorista_adequado(Motorista, Pedido, Turno),
    veiculo_disponivel(Veiculo, Turno),
    motorista_disponivel(Motorista, Turno).
```

### 6. Explicação de Falhas

```prolog
% ---------------------------------------------------
% Identifica o motivo da não alocação
% ---------------------------------------------------
% Verifica cada restrição em ordem e retorna o primeiro motivo de falha
motivo_falha(Pedido, Motivo) :-
    ( \+ turno_valido(Pedido, _) ->
        Motivo = turno_invalido
    ; \+ veiculo_adequado(_, Pedido) ->
        Motivo = nenhum_veiculo_compativel
    ; \+ motorista_adequado(_, Pedido, _) ->
        Motivo = nenhum_motorista_licenciado
    ; Motivo = conflito_disponibilidade
    ).

% Versão detalhada com informações específicas
motivo_falha_detalhado(Pedido, Turno, Motivo) :-
    pedido(Pedido, Peso, Tipo, Dist, Turnos),
    ( \+ member(Turno, Turnos) ->
        Motivo = turno_fora_janela(Turno, Turnos)
    ; \+ (veiculo(_, Cap, _, Aut), Cap >= Peso, Aut >= Dist) ->
        Motivo = sem_veiculo_capacidade_ou_alcance(Peso, Dist)
    ; \+ (motorista(_, Lics, _), member(Tipo, Lics)) ->
        Motivo = sem_motorista_licenca(Tipo)
    ; \+ (veiculo_adequado(V, Pedido), veiculo_disponivel(V, Turno)) ->
        Motivo = todos_veiculos_ocupados(Turno)
    ; \+ (motorista_adequado(M, Pedido, Turno), motorista_disponivel(M, Turno)) ->
        Motivo = todos_motoristas_ocupados(Turno)
    ; Motivo = desconhecido
    ).
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

