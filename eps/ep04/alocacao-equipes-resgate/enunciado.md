**Tema:** 🚨 Sistema de Alocação de Equipes de Resgate

---

## 🎯 Objetivo

Modelar um sistema lógico para **planejar a alocação de equipes e veículos de resgate** para atender ocorrências, respeitando restrições de:

- **Tipo de emergência** (incêndio, acidente médico, enchente etc.)
- **Disponibilidade e localização** das equipes
- **Equipamentos compatíveis** (ambulância, caminhão, barco, helicóptero)
- **Nível de prioridade** (urgente, normal)
- **Tempo de deslocamento** e alcance dos veículos

O sistema deve determinar **combinações válidas** de:

```prolog
(Ocorrência, Equipe, Veículo, Região)
```

e permitir perguntas como:

> "Quais equipes podem atender a ocorrência #O4 na Zona Leste?"
>
> "Qual é a melhor alocação para todas as emergências do turno atual?"

---

## 🧩 Descrição do Problema

Você é o **coordenador de uma central de emergências**.

Diferentes equipes estão disponíveis em regiões específicas, com veículos e equipamentos distintos. As ocorrências chegam com um tipo, prioridade e região, e devem ser atendidas por uma equipe adequada e disponível.

Implemente um sistema lógico que encontre **todas as alocações viáveis** e, opcionalmente, as **melhores** (menor tempo de resposta ou maior prioridade).

---

## 🚨 Base de Fatos

A base de conhecimento deve conter:

### Equipes
```prolog
% equipe(Nome, Tipo, Regiao, Recursos)
% Tipo = bombeiro | medico | defesa_civil
equipe(eq1, bombeiro, centro, [caminhao, escada, mangueira]).
equipe(eq2, bombeiro, norte, [caminhao, mangueira]).
equipe(eq3, medico, leste, [ambulancia, desfibrilador]).
equipe(eq4, medico, centro, [ambulancia]).
equipe(eq5, defesa_civil, sul, [barco, gerador]).
equipe(eq6, defesa_civil, norte, [barco]).
```

### Veículos
```prolog
% veiculo(Id, Tipo, AutonomiaKm)
veiculo(v1, caminhao, 100).
veiculo(v2, ambulancia, 150).
veiculo(v3, barco, 60).
veiculo(v4, helicoptero, 300).
```

### Ocorrências
```prolog
% ocorrencia(Id, Tipo, Regiao, Prioridade, DistanciaKm)
% Tipo = incendio | acidente | enchente
% Prioridade = urgente | normal
ocorrencia(o1, incendio, norte, urgente, 40).
ocorrencia(o2, acidente, centro, normal, 20).
ocorrencia(o3, enchente, sul, urgente, 50).
ocorrencia(o4, acidente, leste, urgente, 30).
ocorrencia(o5, incendio, centro, normal, 15).
```

### Ocupações Existentes
```prolog
% ocupada(Equipe, Turno).
% ocupada(Veiculo, Turno).
ocupada(eq1, manha).
ocupada(v1, manha).
```

---

## 🎯 Objetivos de Aprendizagem

- Modelar problemas de alocação de recursos usando o paradigma lógico
- Utilizar fatos e regras para expressar restrições complexas
- Explorar backtracking para geração de múltiplas soluções
- Criar predicados explicativos para justificar decisões
- Implementar otimização simples (menor tempo de resposta)
- Organizar o sistema em múltiplos arquivos

---

## 📂 Estrutura dos Arquivos e Entrada-Saída

### Arquivos de Entrada
- **`entrada.txt`**: Contém os fatos da base de conhecimento (equipes, veículos, ocorrências, ocupações)

### Arquivos Prolog
- **`principal.pl`**: Arquivo principal que carrega os demais módulos
- **`equipes.pl`**: Predicados relacionados a equipes e compatibilidade
- **`veiculos.pl`**: Predicados de veículos e alcance
- **`alocacao.pl`**: Predicados principais de alocação
- **`explicacao.pl`**: Predicados explicativos e motivos de falha

### Arquivo de Saída
- **`saida.txt`**: Resultados das alocações e explicações

---

## 🧱 Tarefas Obrigatórias

Implemente os seguintes predicados principais:

### 1. Compatibilidade de Equipes

#### 1.1. `equipe_compativel/2` - Compatibilidade de Tipo
```prolog
% ============================================
% EQUIPE_COMPATIVEL/2
% ============================================
% Descrição: Verifica se uma equipe é compatível com o tipo de ocorrência,
%            baseando-se na especialização da equipe. Cada tipo de emergência
%            requer um tipo específico de equipe especializada.
%
% Parâmetros:
%   - Equipe: átomo identificando a equipe (eq1, eq2, eq3, etc.)
%   - Ocorrencia: átomo identificando a ocorrência (oc1, oc2, oc3, etc.)
%
% Comportamento:
%   - Obtém o tipo da equipe (bombeiro, medico, defesa_civil)
%   - Obtém o tipo da ocorrência (incendio, acidente, enchente)
%   - Verifica correspondência:
%     * incendio → bombeiro
%     * acidente → medico
%     * enchente → defesa_civil
%   - Sucede se houver correspondência
%   - Falha se os tipos forem incompatíveis
%
% Regras de compatibilidade:
%   - Bombeiros atendem incêndios
%   - Médicos atendem acidentes
%   - Defesa civil atende enchentes
%
% Exemplos de uso:
%   ?- equipe_compativel(eq1, oc1).
%   true.  % eq1 é bombeiro, oc1 é incêndio
%
%   ?- equipe_compativel(eq2, oc2).
%   true.  % eq2 é médico, oc2 é acidente
%
%   ?- equipe_compativel(eq1, oc2).
%   false.  % bombeiro não atende acidente
%
equipe_compativel(Equipe, Ocorrencia).
```

#### 1.2. `recursos_adequados/2` - Verificação de Recursos
```prolog
% ============================================
% RECURSOS_ADEQUADOS/2
% ============================================
% Descrição: Verifica se uma equipe possui os recursos (equipamentos e veículos)
%            necessários para atender uma ocorrência específica. Cada tipo de
%            emergência requer equipamentos especializados.
%
% Parâmetros:
%   - Equipe: átomo identificando a equipe
%   - Ocorrencia: átomo identificando a ocorrência
%
% Comportamento:
%   - Obtém a lista de recursos da equipe
%   - Obtém o tipo da ocorrência
%   - Verifica se a equipe possui o recurso necessário:
%     * incendio → caminhao (com água e mangueiras)
%     * acidente → ambulancia (com equipamentos médicos)
%     * enchente → barco (para resgate em áreas alagadas)
%   - Usa member/2 para verificar presença do recurso na lista
%   - Sucede se o recurso necessário estiver disponível
%   - Falha se o recurso estiver ausente
%
% Recursos por tipo de ocorrência:
%   - Incêndio: caminhao (caminhão de bombeiros)
%   - Acidente: ambulancia (ambulância equipada)
%   - Enchente: barco (embarcação de resgate)
%
% Exemplos de uso:
%   ?- recursos_adequados(eq1, oc1).
%   true.  % eq1 tem caminhão, oc1 é incêndio
%
%   ?- recursos_adequados(eq2, oc2).
%   true.  % eq2 tem ambulância, oc2 é acidente
%
%   ?- recursos_adequados(eq1, oc3).
%   false.  % eq1 não tem barco para enchente
%
recursos_adequados(Equipe, Ocorrencia).
```

### 2. Compatibilidade de Veículos

#### 2.1. `veiculo_alcance/2` - Verificação de Alcance
```prolog
% ============================================
% VEICULO_ALCANCE/2
% ============================================
% Descrição: Verifica se um veículo possui autonomia suficiente para chegar
%            até o local da ocorrência, considerando a distância e o alcance
%            máximo do veículo (combustível, bateria, etc.).
%
% Parâmetros:
%   - Veiculo: átomo identificando o veículo (v1, v2, v3, etc.)
%   - Ocorrencia: átomo identificando a ocorrência
%
% Comportamento:
%   - Obtém o alcance máximo do veículo (em km)
%   - Obtém a distância até a ocorrência (em km)
%   - Verifica se Alcance >= Distancia
%   - Sucede se o veículo puder chegar ao local
%   - Falha se a distância exceder o alcance
%
% Considerações:
%   - Alcance considera ida e volta (autonomia total)
%   - Distância é medida em linha reta ou por rota
%   - Veículos diferentes têm alcances diferentes:
%     * Caminhões: geralmente 100-150 km
%     * Ambulâncias: geralmente 80-120 km
%     * Helicópteros: geralmente 200-300 km
%     * Barcos: geralmente 50-100 km
%
% Exemplos de uso:
%   ?- veiculo_alcance(v1, oc1).
%   true.  % v1 tem alcance 100km, oc1 está a 15km
%
%   ?- veiculo_alcance(v3, oc4).
%   false.  % v3 tem alcance 50km, oc4 está a 80km
%
%   ?- veiculo_alcance(V, oc1).
%   V = v1 ;
%   V = v2 ;
%   V = v5.  % todos com alcance suficiente
%
veiculo_alcance(Veiculo, Ocorrencia).
```

#### 2.2. `veiculo_compativel/2` - Compatibilidade de Tipo de Veículo
```prolog
% ============================================
% VEICULO_COMPATIVEL/2
% ============================================
% Descrição: Verifica se o tipo de veículo é adequado para o tipo de ocorrência,
%            considerando as características do terreno e da emergência.
%
% Parâmetros:
%   - Veiculo: átomo identificando o veículo
%   - Ocorrencia: átomo identificando a ocorrência
%
% Comportamento:
%   - Obtém o tipo do veículo (caminhao, ambulancia, helicoptero, barco)
%   - Obtém o tipo da ocorrência (incendio, acidente, enchente)
%   - Verifica correspondência:
%     * incendio → caminhao (caminhão de bombeiros)
%     * acidente → ambulancia OU helicoptero (transporte médico)
%     * enchente → barco (navegação em áreas alagadas)
%   - Sucede se houver correspondência
%   - Falha se o veículo for inadequado
%
% Regras de compatibilidade:
%   - Incêndios requerem caminhões de bombeiros (água, escadas)
%   - Acidentes podem usar ambulâncias (terrestre) ou helicópteros (aéreo)
%   - Enchentes requerem barcos (navegação em água)
%   - Helicópteros são versáteis mas limitados a acidentes
%
% Observações:
%   - Acidentes têm duas opções de veículo (ambulância ou helicóptero)
%   - Helicópteros são preferidos para locais de difícil acesso
%   - Barcos são exclusivos para enchentes
%
% Exemplos de uso:
%   ?- veiculo_compativel(v1, oc1).
%   true.  % v1 é caminhão, oc1 é incêndio
%
%   ?- veiculo_compativel(v2, oc2).
%   true.  % v2 é ambulância, oc2 é acidente
%
%   ?- veiculo_compativel(v5, oc2).
%   true.  % v5 é helicóptero, oc2 é acidente
%
%   ?- veiculo_compativel(v1, oc3).
%   false.  % caminhão não serve para enchente
%
veiculo_compativel(Veiculo, Ocorrencia).
```

### 3. Disponibilidade e Proximidade

#### 3.1. `disponivel/2` - Verificação de Disponibilidade
```prolog
% ============================================
% DISPONIVEL/2
% ============================================
% Descrição: Verifica se uma entidade (equipe ou veículo) está disponível em um
%            determinado turno. Usa negação como falha: uma entidade está disponível
%            se NÃO estiver ocupada.
%
% Parâmetros:
%   - Entidade: átomo identificando a equipe ou veículo (eq1, v1, etc.)
%   - Turno: átomo representando o turno (manha, tarde, noite)
%
% Comportamento:
%   - Verifica se a entidade NÃO está na base de fatos ocupada/2
%   - Usa negação como falha (\+)
%   - Sucede se não houver fato ocupada(Entidade, Turno)
%   - Falha se houver fato ocupada(Entidade, Turno)
%
% Lógica de negação como falha:
%   - Mundo fechado: o que não está explicitamente ocupado está disponível
%   - Permite raciocínio sobre ausência de informação
%   - Simplifica modelagem (não precisa listar todos os disponíveis)
%
% Turnos:
%   - manha: 06:00 - 14:00
%   - tarde: 14:00 - 22:00
%   - noite: 22:00 - 06:00
%
% Exemplos de uso:
%   ?- disponivel(eq1, manha).
%   true.  % eq1 não está ocupada de manhã
%
%   ?- disponivel(eq2, tarde).
%   false.  % eq2 está ocupada à tarde
%
%   ?- disponivel(E, manha).
%   E = eq1 ;
%   E = eq3 ;
%   E = v1 ;
%   ...  % todas as entidades não ocupadas de manhã
%
disponivel(Entidade, Turno).
```

#### 3.2. `proxima/2` - Verificação de Proximidade Geográfica
```prolog
% ============================================
% PROXIMA/2
% ============================================
% Descrição: Verifica se duas regiões são próximas o suficiente para permitir
%            deslocamento rápido. Usa heurística simples onde o centro é um
%            ponto de conexão que liga todas as regiões.
%
% Parâmetros:
%   - RegiaoEquipe: átomo representando a região da equipe (norte, sul, leste, oeste, centro)
%   - RegiaoOcorrencia: átomo representando a região da ocorrência
%
% Comportamento:
%   - Caso 1: Regiões são idênticas → sempre próximas
%   - Caso 2: Uma das regiões é centro → sempre próximas
%     * Centro conecta todas as outras regiões
%     * Permite deslocamento rápido via centro
%   - Falha se regiões são diferentes e nenhuma é centro
%
% Topologia da cidade:
%   ```
%        norte
%          |
%   oeste-centro-leste
%          |
%        sul
%   ```
%   - Centro é hub central
%   - Regiões periféricas conectam via centro
%   - Regiões opostas (norte-sul, leste-oeste) não são próximas diretamente
%
% Exemplos de uso:
%   ?- proxima(norte, norte).
%   true.  % mesma região
%
%   ?- proxima(centro, sul).
%   true.  % centro conecta todas
%
%   ?- proxima(norte, centro).
%   true.  % centro conecta todas
%
%   ?- proxima(norte, sul).
%   false.  % regiões opostas, sem centro
%
%   ?- proxima(leste, oeste).
%   false.  % regiões opostas, sem centro
%
proxima(RegiaoEquipe, RegiaoOcorrencia).
```

### 4. Alocação Principal

#### 4.1. `alocacao_valida/4` - Alocação Completa e Válida
```prolog
% ============================================
% ALOCACAO_VALIDA/4
% ============================================
% Descrição: Determina uma alocação completa e válida de equipe e veículo para
%            uma ocorrência em um turno específico, agregando todas as restrições
%            e verificações necessárias. Este é o predicado principal do sistema.
%
% Parâmetros:
%   - Ocorrencia: átomo identificando a ocorrência
%   - Equipe: átomo identificando a equipe alocada (saída)
%   - Veiculo: átomo identificando o veículo alocado (saída)
%   - Turno: átomo representando o turno (saída ou entrada)
%
% Comportamento:
%   - Verifica todas as restrições em sequência:
%     1. Equipe compatível com tipo de ocorrência
%     2. Equipe possui recursos adequados
%     3. Veículo compatível com tipo de ocorrência
%     4. Veículo tem alcance suficiente
%     5. Equipe disponível no turno
%     6. Veículo disponível no turno
%     7. Equipe próxima da ocorrência
%     8. Prioridade urgente → turno manhã (restrição especial)
%   - Todas as restrições devem ser satisfeitas
%   - Falha se qualquer restrição não for atendida
%   - Pode gerar múltiplas soluções via backtracking
%
% Restrições especiais:
%   - Ocorrências urgentes DEVEM ser atendidas no turno da manhã
%   - Ocorrências normais podem ser atendidas em qualquer turno
%   - Proximidade geográfica é obrigatória
%   - Disponibilidade de equipe E veículo é obrigatória
%
% Ordem de verificação (otimização):
%   1. Compatibilidades (filtros rápidos)
%   2. Recursos e alcance (verificações médias)
%   3. Disponibilidade (consulta a fatos)
%   4. Proximidade (heurística)
%   5. Prioridade (restrição final)
%
% Exemplos de uso:
%   ?- alocacao_valida(oc1, E, V, T).
%   E = eq1, V = v1, T = manha ;
%   E = eq1, V = v1, T = tarde ;
%   ...  % múltiplas soluções possíveis
%
%   ?- alocacao_valida(oc2, eq2, v2, manha).
%   true.  % verifica se alocação específica é válida
%
%   ?- alocacao_valida(oc_urgente, E, V, T).
%   E = eq1, V = v1, T = manha.  % urgente só de manhã
%
alocacao_valida(Ocorrencia, Equipe, Veiculo, Turno).
```

### 5. Predicados Explicativos

#### 5.1. `motivo_falha/2` - Diagnóstico de Falha
```prolog
% ============================================
% MOTIVO_FALHA/2
% ============================================
% Descrição: Identifica e explica por que uma alocação não é possível para uma
%            ocorrência, diagnosticando o primeiro motivo de falha encontrado.
%            Essencial para explicabilidade e debugging do sistema.
%
% Parâmetros:
%   - Ocorrencia: átomo identificando a ocorrência
%   - Motivo: átomo representando o motivo da falha (saída)
%
% Comportamento:
%   - Testa cada restrição em sequência usando negação como falha
%   - Retorna o primeiro motivo de falha encontrado
%   - Ordem de verificação (do mais específico ao mais geral):
%     1. sem_equipe_compativel: nenhuma equipe do tipo adequado
%     2. recursos_insuficientes: equipes não têm equipamentos necessários
%     3. sem_veiculo_compativel: nenhum veículo do tipo adequado
%     4. fora_de_alcance: todos os veículos estão fora do alcance
%     5. conflito_turno: equipes/veículos ocupados em todos os turnos
%   - Usa estrutura if-then-else encadeada (;)
%   - Sempre retorna um motivo (último é catch-all)
%
% Motivos possíveis:
%   - sem_equipe_compativel: tipo de equipe não disponível
%   - recursos_insuficientes: equipamentos inadequados
%   - sem_veiculo_compativel: tipo de veículo não disponível
%   - fora_de_alcance: distância excede alcance de todos os veículos
%   - conflito_turno: todas as combinações estão ocupadas
%
% Uso para explicabilidade:
%   - Permite informar ao usuário por que não há solução
%   - Ajuda a identificar gargalos no sistema
%   - Facilita planejamento de recursos
%
% Exemplos de uso:
%   ?- motivo_falha(oc5, M).
%   M = sem_equipe_compativel.  % nenhum bombeiro disponível
%
%   ?- motivo_falha(oc6, M).
%   M = fora_de_alcance.  % ocorrência muito distante
%
%   ?- motivo_falha(oc7, M).
%   M = conflito_turno.  % todos ocupados
%
motivo_falha(Ocorrencia, Motivo).
```

#### 5.2. `justifica_alocacao/5` - Justificativa de Alocação Válida
```prolog
% ============================================
% JUSTIFICA_ALOCACAO/5
% ============================================
% Descrição: Gera uma justificativa completa para uma alocação válida, coletando
%            todas as validações que foram satisfeitas. Essencial para auditoria,
%            explicabilidade e documentação das decisões do sistema.
%
% Parâmetros:
%   - Ocorrencia: átomo identificando a ocorrência
%   - Equipe: átomo identificando a equipe alocada
%   - Veiculo: átomo identificando o veículo alocado
%   - Turno: átomo representando o turno
%   - Justificativa: lista de termos estruturados explicando as validações (saída)
%
% Comportamento:
%   - Primeiro verifica se a alocação é válida
%   - Coleta informações detalhadas de equipe, veículo e ocorrência
%   - Constrói lista estruturada com todas as validações:
%     1. equipe_compativel(TipoEquipe, TipoOcorrencia)
%     2. recursos_adequados(ListaRecursos)
%     3. veiculo_compativel(TipoVeiculo, TipoOcorrencia)
%     4. veiculo_alcance(AlcanceVeiculo, DistanciaOcorrencia)
%     5. disponivel(Equipe, Turno)
%     6. disponivel(Veiculo, Turno)
%     7. regiao_proxima(RegiaoEquipe, RegiaoOcorrencia)
%     8. prioridade(NivelPrioridade)
%   - Retorna lista ordenada de justificativas
%   - Falha se a alocação não for válida
%
% Estrutura da justificativa:
%   - Cada item é um termo estruturado
%   - Contém informações específicas (tipos, valores, regiões)
%   - Permite rastreamento completo da decisão
%   - Facilita auditoria e contestação
%
% Usos:
%   - Documentação de decisões
%   - Auditoria de alocações
%   - Explicação para usuários
%   - Análise de desempenho do sistema
%   - Treinamento de operadores
%
% Exemplos de uso:
%   ?- justifica_alocacao(oc1, eq1, v1, manha, J).
%   J = [equipe_compativel(bombeiro, incendio),
%        recursos_adequados([caminhao, mangueira]),
%        veiculo_compativel(caminhao, incendio),
%        veiculo_alcance(100, 15),
%        disponivel(eq1, manha),
%        disponivel(v1, manha),
%        regiao_proxima(norte, norte),
%        prioridade(urgente)].
%
%   ?- justifica_alocacao(oc2, eq2, v2, tarde, J).
%   J = [equipe_compativel(medico, acidente),
%        recursos_adequados([ambulancia, desfibrilador]),
%        veiculo_compativel(ambulancia, acidente),
%        veiculo_alcance(80, 25),
%        disponivel(eq2, tarde),
%        disponivel(v2, tarde),
%        regiao_proxima(centro, sul),
%        prioridade(normal)].
%
justifica_alocacao(Ocorrencia, Equipe, Veiculo, Turno, Justificativa).
```

---

## ✨ Extensões (Escolha pelo menos UMA)

| Tema Lógico | Extensão Possível |
|-------------|-------------------|
| **Otimização** | Escolher a alocação com menor distância total ou que atenda mais ocorrências urgentes primeiro. Implementar predicado `melhor_alocacao/4` que ordena soluções por critério de qualidade. |
| **Múltiplas Ocorrências** | Impor limite de quantas ocorrências uma equipe pode atender por turno (ex: máximo 3). Adicionar contador de alocações por equipe. |
| **Reforço Cooperativo** | Exigir 2 ou mais equipes para grandes emergências (`Prioridade=urgente` + tipo específico como incêndio). Implementar `alocacao_multipla/5`. |
| **Hierarquia de Regiões** | Implementar malha de vizinhança mais realista: `centro ↔ norte ↔ sul ↔ leste ↔ oeste`. Adicionar predicado `vizinha/2` e calcular distância por saltos. |
| **Raciocínio Explicativo Rico** | Mostrar cadeia completa de raciocínio: por que cada restrição foi satisfeita ou violada. Implementar `explicacao_completa/2` que retorna lista de validações com status. |

### Exemplo de Extensão: Otimização
```prolog
% Encontra a melhor alocação (menor distância)
melhor_alocacao(Ocorrencia, Equipe, Veiculo, Turno) :-
    findall((Dist, E, V, T),
            (alocacao_valida(Ocorrencia, E, V, T),
             ocorrencia(Ocorrencia, _, _, _, Dist)),
            Lista),
    sort(Lista, [(_, Equipe, Veiculo, Turno)|_]).

% Prioriza ocorrências urgentes
priorizar_urgentes(ListaAlocacoes, ListaPrioritaria) :-
    findall((Prio, O, E, V, T),
            (member((O, E, V, T), ListaAlocacoes),
             ocorrencia(O, _, _, Prio, _)),
            Temp),
    sort(Temp, Ordenada),
    findall((O, E, V, T), member((_, O, E, V, T), Ordenada), ListaPrioritaria).
```

---

## ▶️ Exemplos de Execução

```prolog
% 1) Todas as combinações possíveis para um turno
?- alocacao_valida(O, E, V, manha).
O = o2, E = eq3, V = v2, manha ;
O = o2, E = eq4, V = v2, manha ;
O = o5, E = eq2, V = v1, manha ;
...

% 2) Quem pode atender a ocorrência o4 na leste?
?- alocacao_valida(o4, E, V, T).
E = eq3, V = v2, T = manha ;
E = eq3, V = v4, T = manha ;
false.

% 3) Verificar se uma equipe específica pode atender
?- alocacao_valida(o1, eq2, V, T).
V = v1, T = tarde ;  % eq2 está ocupada na manhã
false.

% 4) Quais ocorrências ainda não têm solução possível
?- ocorrencia(O,_,_,_,_), \+ alocacao_valida(O,_,_,_).
O = o3.  % enchente no sul, mas barcos têm alcance insuficiente

% 5) Gerar o plano completo de alocações
?- findall((O,E,V,T), alocacao_valida(O,E,V,T), Plano).
Plano = [(o1,eq2,v1,tarde), (o2,eq3,v2,manha), (o2,eq4,v2,manha), ...].

% 6) Por que a ocorrência o3 não pode ser atendida?
?- motivo_falha(o3, Motivo).
Motivo = fora_de_alcance.  % barcos têm alcance de 60km, mas distância é 50km

% 7) Justificar uma alocação específica
?- justifica_alocacao(o4, eq3, v2, manha, J).
J = [equipe_compativel(medico, acidente),
     recursos_adequados([ambulancia, desfibrilador]),
     veiculo_compativel(ambulancia, acidente),
     veiculo_alcance(150, 30),
     disponivel(eq3, manha),
     disponivel(v2, manha),
     regiao_proxima(leste, leste),
     prioridade(urgente)].

% 8) Listar todas as equipes disponíveis em um turno
?- equipe(E, _, _, _), disponivel(E, manha).
E = eq2 ;
E = eq3 ;
E = eq4 ;
E = eq5 ;
E = eq6.

% 9) Verificar compatibilidade sem considerar disponibilidade
?- equipe_compativel(E, o1), recursos_adequados(E, o1).
E = eq1 ;
E = eq2.

% 10) Encontrar melhor alocação (menor distância)
?- findall((Dist,O,E,V,T),
           (alocacao_valida(O,E,V,T),
            ocorrencia(O,_,_,_,Dist)),
           Lista),
   sort(Lista, Ordenada).
```

---

## 🧾 Explicabilidade das Decisões

### Formato de Justificativa (Lista):
```prolog
[
    equipe_compativel(eq3, o4, medico),
    recursos_adequados(eq3, ambulancia),
    veiculo_alcance(v2, 30km),
    disponivel(eq3, tarde),
    disponivel(v2, tarde),
    regiao_proxima(leste, leste)
].
```

### Formato de Justificativa (Estrutura):
```prolog
alocacao(
    ocorrencia(o4, acidente, leste, urgente),
    equipe(eq3, medico, leste, [ambulancia, desfibrilador]),
    veiculo(v2, ambulancia, 150km),
    turno(tarde),
    validacoes([
        tipo_compativel,
        recursos_ok,
        alcance_suficiente,
        disponibilidade_confirmada
    ])
).
```

### Motivos de Falha:
```prolog
motivo_falha(o5, [
    sem_equipe_compativel,
    tipo_incendio_requer_bombeiro,
    todas_equipes_bombeiro_ocupadas_no_turno
]).
```

---

## 🧠 Conceitos Aplicados

Este trabalho exercita os seguintes conceitos de Programação Lógica:

- **Busca com múltiplas variáveis interdependentes**
  - `(Ocorrência ↔ Equipe ↔ Veículo ↔ Turno)`
  - Backtracking automático para explorar todas as combinações

- **Restrições compostas**
  - Compatibilidade de tipos (equipe/veículo com ocorrência)
  - Geografia (proximidade de regiões)
  - Disponibilidade (turnos e ocupações)
  - Alcance (distância vs. autonomia)

- **Raciocínio condicional**
  - Urgências → turno antecipado (manhã)
  - Centro → região neutra (conecta todas)

- **Negação como falha**
  - `disponivel(E, T) :- \+ ocupada(E, T)`
  - Verificação de ausência de conflitos

- **Explicações e justificativas lógicas**
  - Motivos de falha (por que não é possível)
  - Justificativas de sucesso (por que é válido)

- **Planejamento lógico e constraint satisfaction**
  - Encontrar todas as soluções viáveis
  - Otimizar soluções por critérios (distância, prioridade)

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

1. A base de dados deve conter **pelo menos 6 equipes**, **5 veículos** e **8 ocorrências**
2. Teste casos de **urgência** (prioridade alta deve ter preferência)
3. Teste casos de **conflito** (recursos insuficientes, todos ocupados)
4. Implemente verificação de **proximidade geográfica**
5. Todas as decisões devem ser **explicáveis** no arquivo de saída
6. Considere casos onde **nenhuma alocação é possível**

