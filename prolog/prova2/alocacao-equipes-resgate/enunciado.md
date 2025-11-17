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
```prolog
% Equipe é compatível com o tipo da ocorrência
% Verifica se o tipo da equipe corresponde ao tipo da ocorrência:
% - incendio → bombeiro
% - acidente → medico
% - enchente → defesa_civil
equipe_compativel(Equipe, Ocorrencia) :-
    equipe(Equipe, TipoEquipe, _, _),
    ocorrencia(Ocorrencia, TipoOcorr, _, _, _),
    (
        (TipoOcorr = incendio, TipoEquipe = bombeiro);
        (TipoOcorr = acidente, TipoEquipe = medico);
        (TipoOcorr = enchente, TipoEquipe = defesa_civil)
    ).

% Equipe tem os recursos necessários
% Verifica se a equipe possui os equipamentos adequados:
% - incendio → caminhao
% - acidente → ambulancia
% - enchente → barco
recursos_adequados(Equipe, Ocorrencia) :-
    equipe(Equipe, _, _, Recursos),
    ocorrencia(Ocorrencia, Tipo, _, _, _),
    (
        (Tipo = incendio, member(caminhao, Recursos));
        (Tipo = acidente, member(ambulancia, Recursos));
        (Tipo = enchente, member(barco, Recursos))
    ).
```

### 2. Compatibilidade de Veículos
```prolog
% Veículo pode chegar à ocorrência (alcance)
% Verifica se a autonomia do veículo é suficiente para a distância
veiculo_alcance(Veiculo, Ocorrencia) :-
    veiculo(Veiculo, _, Alcance),
    ocorrencia(Ocorrencia, _, _, _, Distancia),
    Alcance >= Distancia.

% Veículo é compatível com o tipo de ocorrência
% Verifica se o tipo do veículo é adequado para a ocorrência:
% - incendio → caminhao
% - acidente → ambulancia ou helicoptero
% - enchente → barco
veiculo_compativel(Veiculo, Ocorrencia) :-
    veiculo(Veiculo, TipoV, _),
    ocorrencia(Ocorrencia, TipoO, _, _, _),
    (
        (TipoO = incendio, TipoV = caminhao);
        (TipoO = acidente, TipoV = ambulancia);
        (TipoO = enchente, TipoV = barco);
        (TipoO = acidente, TipoV = helicoptero)
    ).
```

### 3. Disponibilidade e Proximidade
```prolog
% Verifica se equipe/veículo está disponível no turno
% Usa negação como falha: disponível se NÃO está ocupado
disponivel(Entidade, Turno) :-
    \+ ocupada(Entidade, Turno).

% Verifica proximidade geográfica (heurística simples)
% Considera que centro é neutro (conecta todas as regiões)
proxima(RegiaoEquipe, RegiaoOcorrencia) :-
    RegiaoEquipe = RegiaoOcorrencia;
    (RegiaoEquipe = centro; RegiaoOcorrencia = centro).
```

### 4. Alocação Principal
```prolog
% Combinação válida de alocação
% Agrega todas as restrições para determinar uma alocação viável
alocacao_valida(Ocorrencia, Equipe, Veiculo, Turno) :-
    equipe_compativel(Equipe, Ocorrencia),
    recursos_adequados(Equipe, Ocorrencia),
    veiculo_compativel(Veiculo, Ocorrencia),
    veiculo_alcance(Veiculo, Ocorrencia),
    disponivel(Equipe, Turno),
    disponivel(Veiculo, Turno),
    equipe(Equipe, _, RegiaoE, _),
    ocorrencia(Ocorrencia, _, RegiaoO, Prioridade, _),
    proxima(RegiaoE, RegiaoO),
    % Ocorrências urgentes devem ser atendidas no turno da manhã
    (Prioridade = urgente -> Turno = manha ; true).
```

### 5. Predicados Explicativos
```prolog
% Explica por que uma alocação não é possível
% Identifica o primeiro motivo de falha encontrado
motivo_falha(Ocorrencia, Motivo) :-
    ( \+ equipe_compativel(_, Ocorrencia) ->
        Motivo = sem_equipe_compativel
    ; \+ recursos_adequados(_, Ocorrencia) ->
        Motivo = recursos_insuficientes
    ; \+ veiculo_compativel(_, Ocorrencia) ->
        Motivo = sem_veiculo_compativel
    ; \+ veiculo_alcance(_, Ocorrencia) ->
        Motivo = fora_de_alcance
    ; Motivo = conflito_turno
    ).

% Justifica uma alocação válida
% Coleta todas as validações que foram satisfeitas
justifica_alocacao(Ocorrencia, Equipe, Veiculo, Turno, Justificativa) :-
    alocacao_valida(Ocorrencia, Equipe, Veiculo, Turno),
    equipe(Equipe, TipoE, RegiaoE, Recursos),
    ocorrencia(Ocorrencia, TipoO, RegiaoO, Prioridade, Distancia),
    veiculo(Veiculo, TipoV, Alcance),
    Justificativa = [
        equipe_compativel(TipoE, TipoO),
        recursos_adequados(Recursos),
        veiculo_compativel(TipoV, TipoO),
        veiculo_alcance(Alcance, Distancia),
        disponivel(Equipe, Turno),
        disponivel(Veiculo, Turno),
        regiao_proxima(RegiaoE, RegiaoO),
        prioridade(Prioridade)
    ].
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

