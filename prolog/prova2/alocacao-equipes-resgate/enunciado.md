**Tema:** 🚨 Sistema de Alocação de Equipes de Resgate

---

## 🧩 Descrição do Problema

Você deve implementar um sistema lógico para **planejar a alocação de equipes e veículos de resgate** para atender ocorrências de emergência. O sistema deve gerenciar:

- **Ocorrências** de diferentes tipos (incêndio, acidente médico, enchente, etc.)
- **Equipes** especializadas (bombeiros, médicos, defesa civil) com recursos específicos
- **Veículos** com diferentes capacidades e alcances (caminhão, ambulância, barco, helicóptero)
- **Restrições** de disponibilidade, localização geográfica e prioridade
- **Turnos** de trabalho e ocupações existentes

O sistema deve determinar **combinações válidas** de `(Ocorrência, Equipe, Veículo, Turno)` que atendam todas as restrições e permitir consultas como:

> "Quais equipes podem atender a ocorrência #O4 na Zona Leste?"
> "Qual é a melhor alocação para todas as emergências do turno atual?"

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
equipe_compativel(Equipe, Ocorrencia).

% Equipe tem os recursos necessários
recursos_adequados(Equipe, Ocorrencia).
```

### 2. Compatibilidade de Veículos
```prolog
% Veículo pode chegar à ocorrência (alcance)
veiculo_alcance(Veiculo, Ocorrencia).

% Veículo é compatível com o tipo de ocorrência
veiculo_compativel(Veiculo, Ocorrencia).
```

### 3. Disponibilidade
```prolog
% Verifica se equipe/veículo está disponível no turno
disponivel(Entidade, Turno).

% Verifica proximidade geográfica
proxima(RegiaoEquipe, RegiaoOcorrencia).
```

### 4. Alocação Principal
```prolog
% Combinação válida de alocação
alocacao_valida(Ocorrencia, Equipe, Veiculo, Turno).
```

### 5. Predicados Explicativos
```prolog
% Explica por que uma alocação não é possível
motivo_falha(Ocorrencia, Motivo).

% Justifica uma alocação válida
justifica_alocacao(Ocorrencia, Equipe, Veiculo, Turno, Justificativa).
```

---

## ✨ Extensões (Escolha pelo menos UMA)

1. **Otimização**: Escolher a alocação com menor distância total ou que atenda mais ocorrências urgentes

2. **Múltiplas Ocorrências**: Impor limite de quantas ocorrências uma equipe pode atender por turno

3. **Reforço Cooperativo**: Exigir 2 ou mais equipes para grandes emergências (prioridade urgente + tipo específico)

4. **Hierarquia de Regiões**: Implementar malha de vizinhança (centro ↔ norte ↔ sul ↔ leste ↔ oeste)

5. **Raciocínio Explicativo Rico**: Mostrar cadeia completa de raciocínio (por que cada restrição foi satisfeita ou violada)

---

## ▶️ Exemplos de Execução

```prolog
% Todas as combinações possíveis para um turno
?- alocacao_valida(O, E, V, manha).

% Quem pode atender a ocorrência o4?
?- alocacao_valida(o4, E, V, T).

% Quais ocorrências ainda não têm solução possível
?- ocorrencia(O,_,_,_,_), \+ alocacao_valida(O,_,_,_).

% Gerar o plano completo de alocações
?- findall((O,E,V,T), alocacao_valida(O,E,V,T), Plano).

% Por que a ocorrência o5 não pode ser atendida?
?- motivo_falha(o5, Motivo).
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

