**Tema:** ⚡ Sistema de Gerenciamento Lógico de Energia (Smart Grid)

---

## 🎯 Objetivo

Modelar, em **Prolog**, um sistema lógico que gerencia a **alocação e o fluxo de energia** entre fontes (usinas, baterias, painéis solares) e consumidores (casas, indústrias, hospitais), respeitando:

1. **Restrições de capacidade** e **prioridade de fornecimento**
2. **Herança hierárquica** de regiões (ex.: uma cidade herda energia de seu distrito ou subestação)
3. **Propagação recursiva de energia**: se um nó da rede não tem energia suficiente, pode requisitar de um ancestral
4. **Tipos de energia compatíveis** (solar, eólica, elétrica comum)

Consultas esperadas:

```prolog
pode_fornecer(usina_central, hospital_cidade).
necessita_reforco(bairro_norte).
energia_disponivel_para(casa_101, Quantidade).
causa_falha(centro_dados, Motivo).
consumo_total(subestacao_sul, Total).
```

---

## 🧩 Descrição do Problema

Você é o **engenheiro de sistemas** responsável por implementar um sistema de **planejamento lógico de fornecimento energético** para uma cidade inteligente (smart grid).

A rede elétrica é organizada hierarquicamente: **usinas** fornecem energia para **subestações**, que distribuem para **bairros**, que alimentam **consumidores finais** (casas, hospitais, fábricas). Cada nó da rede tem capacidade limitada e tipos de energia específicos (solar, eólica, elétrica).

O desafio é garantir que todos os consumidores recebam energia suficiente, respeitando:
- **Compatibilidade de tipos**: painéis solares e parques eólicos convertem para energia elétrica
- **Hierarquia de distribuição**: energia flui de cima para baixo (usina → subestação → bairro → consumidor)
- **Propagação recursiva**: se um nó não tem energia suficiente, pode solicitar de seu ancestral
- **Prioridade**: hospitais e escolas têm prioridade sobre outros consumidores

Implemente um sistema lógico que:
- Define uma **rede hierárquica** de nós (usinas → subestações → bairros → consumidores)
- Define a **capacidade** de cada fonte de energia e a **demanda** de cada consumidor
- Considera **tipos de energia compatíveis** (solar, eólica, térmica)
- Propaga energia na hierarquia (nó pode fornecer a descendentes ou solicitar de ancestrais)
- Avalia situações de **déficit energético** e identifica onde há **necessidade de reforço**
- Explica **causas de falhas** (sem fontes conectadas, energia insuficiente)

---

## 🎯 Objetivos de Aprendizagem

- Modelar hierarquias e árvores usando o paradigma lógico
- Implementar propagação recursiva de recursos
- Utilizar findall para agregação de capacidades e demandas
- Criar regras de compatibilidade entre tipos
- Aplicar raciocínio causal para diagnóstico
- Gerar explicações para decisões de alocação
- Organizar o sistema em múltiplos arquivos

---

## ⚡ Base de Fatos (Exemplo Didático)

### Tipos de Energia
```prolog
% =========================
% TIPOS DE ENERGIA
% =========================
tipo_energia(solar).
tipo_energia(eolica).
tipo_energia(eletrica).

% Compatibilidades (solar e eólica convertem para elétrica)
compativel(solar, eletrica).
compativel(eolica, eletrica).
compativel(E, E).  % Tipo é compatível consigo mesmo
```

### Fontes de Energia
```prolog
% =========================
% FONTES DE ENERGIA
% fonte(Nome, Tipo, CapacidadeMW)
% =========================
fonte(usina_central, eletrica, 500).
fonte(parque_solar_norte, solar, 80).
fonte(parque_eolico_sul, eolica, 60).
```

### Consumidores
```prolog
% =========================
% CONSUMIDORES
% consumidor(Nome, TipoEnergia, DemandaMW)
% =========================
consumidor(hospital_cidade, eletrica, 50).
consumidor(fabrica_auto, eletrica, 80).
consumidor(casa_101, eletrica, 5).
consumidor(casa_102, eletrica, 4).
consumidor(escola_municipal, eletrica, 12).
consumidor(centro_dados, eletrica, 100).
```

### Estrutura Hierárquica da Rede
```prolog
% =========================
% ESTRUTURA HIERÁRQUICA DA REDE
% no_pai(Filho, Pai)
% =========================
% Nível 1: Usina central
no_pai(subestacao_norte, usina_central).
no_pai(subestacao_sul, usina_central).

% Nível 2: Subestações
no_pai(bairro_norte, subestacao_norte).
no_pai(bairro_sul, subestacao_sul).

% Nível 3: Consumidores diretos de subestações
no_pai(hospital_cidade, subestacao_norte).
no_pai(fabrica_auto, subestacao_sul).
no_pai(centro_dados, subestacao_sul).

% Nível 4: Consumidores de bairros
no_pai(casa_101, bairro_norte).
no_pai(casa_102, bairro_norte).
no_pai(escola_municipal, bairro_norte).
```

### Fontes Conectadas a Nós
```prolog
% =========================
% FONTES CONECTADAS A NÓS
% conectado(Fonte, No)
% =========================
conectado(usina_central, usina_central).
conectado(parque_solar_norte, subestacao_norte).
conectado(parque_eolico_sul, subestacao_sul).
```

---

## 📂 Estrutura dos Arquivos e Entrada-Saída

### Arquivos de Entrada
- **`entrada.txt`**: Contém os fatos da base de conhecimento (fontes, consumidores, hierarquia, conexões)

### Arquivos Prolog
- **`principal.pl`**: Arquivo principal que carrega os demais módulos e a base de dados
- **`rede.pl`**: Predicados relacionados à hierarquia da rede e propagação
- **`balanceamento.pl`**: Predicados de cálculo de capacidade e demanda
- **`renovaveis.pl`**: Predicados de compatibilidade de tipos de energia
- **`controle.pl`**: Predicados de decisão e diagnóstico

### Arquivo de Saída
- **`saida.txt`**: Resultados de alocação, diagnósticos e recomendações

---

## 🧱 Tarefas Obrigatórias

### 1. Relação Hierárquica Transitiva (Recursiva)

```prolog
% Ancestral direto
ancestral(X, Y) :- no_pai(Y, X).

% Ancestral transitivo (recursivo)
ancestral(X, Y) :-
    no_pai(Y, Z),
    ancestral(X, Z).

% Descendente direto
descendente(X, Y) :- no_pai(Y, X).

% Descendente transitivo (recursivo)
descendente(X, Y) :-
    no_pai(Z, X),
    descendente(Z, Y).
```

### 2. Fontes Diretas ou Herdadas de Energia

```prolog
% Fonte diretamente conectada ao nó
fonte_acessivel(No, Fonte) :-
    conectado(Fonte, No).

% Fonte herdada de ancestral (propagação hierárquica)
fonte_acessivel(No, Fonte) :-
    ancestral(NoPai, No),
    conectado(Fonte, NoPai).
```

### 3. Energia Disponível Total para um Nó

```prolog
% Soma das fontes acessíveis e compatíveis
energia_disponivel_para(No, Total) :-
    findall(Cap,
        (fonte_acessivel(No, F),
         fonte(F, TipoF, Cap),
         consumidor(No, TipoC, _),
         compativel(TipoF, TipoC)
        ),
        Caps),
    sum_list(Caps, Total).

% Se não for consumidor, retorna 0
energia_disponivel_para(No, 0) :-
    \+ consumidor(No, _, _).
```

### 4. Verificação de Fornecimento

```prolog
% Nó pode fornecer energia a outro (compatibilidade + capacidade >= demanda)
pode_fornecer(Origem, Destino) :-
    energia_disponivel_para(Origem, E),
    consumidor(Destino, _, Demanda),
    E >= Demanda.

% Verifica se há déficit energético
necessita_reforco(No) :-
    consumidor(No, _, D),
    energia_disponivel_para(No, E),
    E < D.
```

### 5. Consumo Total Descendente

```prolog
% Total de consumo de todos os descendentes de um nó
consumo_total(No, Total) :-
    findall(D,
        (descendente(No, C), consumidor(C, _, D)),
        Ds),
    sum_list(Ds, Total).

% Se não houver descendentes consumidores, retorna 0
consumo_total(No, 0) :-
    \+ (descendente(No, C), consumidor(C, _, _)).
```

### 6. Diagnóstico de Falhas

```prolog
% Explica a causa de falha ou sucesso
causa_falha(No, Motivo) :-
    (\+ fonte_acessivel(No, _) ->
        Motivo = sem_fontes_conectadas
    ; energia_disponivel_para(No, E),
      consumidor(No, _, D),
      E < D ->
        format(atom(Motivo), 'energia_insuficiente: ~wMW disponivel, ~wMW necessario', [E, D])
    ; Motivo = ok
    ).
```

### 7. Listagem de Recursos

```prolog
% Lista todas as fontes acessíveis para um nó
fontes_disponiveis(No, Fontes) :-
    findall(F, fonte_acessivel(No, F), FontesDup),
    sort(FontesDup, Fontes).

% Lista todos os consumidores descendentes de um nó
consumidores_atendidos(No, Consumidores) :-
    findall(C, (descendente(No, C), consumidor(C, _, _)), ConsDup),
    sort(ConsDup, Consumidores).
```

---

## ✨ Extensões (Escolha pelo menos UMA)

| Conceito | Extensão Possível |
|----------|-------------------|
| **Planejamento Lógico (CSP)** | Criar predicado `planejar_distribuicao/1` que gere um plano ótimo de fornecimento. Alocação automática de fontes. |
| **Tipos Múltiplos** | Consumidores híbridos (solar + elétrica). Múltiplas fontes compatíveis. |
| **Perdas na Transmissão** | Reduzir energia disponível em cada salto hierárquico (ex.: 5% de perda por nível). |
| **Prioridade de Fornecimento** | Hospitais e escolas sempre priorizados (`prioridade/2`). Alocação preferencial. |
| **Diagnóstico Lógico Avançado** | `causa_falha_detalhada/2` explicando o déficit com trilha completa. |
| **Raciocínio Recursivo Inverso** | Permitir que uma subestação solicite reforço da ancestral mais próxima disponível. |
| **Balanceamento Dinâmico** | Redistribuir energia entre nós irmãos quando um está sobrecarregado. |

### Exemplo de Extensão: Prioridade de Fornecimento
```prolog
% Prioridades de consumidores (maior = mais prioritário)
prioridade(hospital_cidade, 10).
prioridade(escola_municipal, 8).
prioridade(fabrica_auto, 5).
prioridade(centro_dados, 5).
prioridade(casa_101, 1).
prioridade(casa_102, 1).

% Consumidores críticos (prioridade >= 8)
consumidor_critico(C) :-
    prioridade(C, P),
    P >= 8.

% Verifica se consumidor crítico tem energia suficiente
critico_atendido(C) :-
    consumidor_critico(C),
    \+ necessita_reforco(C).

% Lista consumidores críticos com déficit
criticos_em_risco(Criticos) :-
    findall(C,
        (consumidor_critico(C), necessita_reforco(C)),
        Criticos).

% Exemplo de uso:
% ?- criticos_em_risco(L).
% L = [].  % Todos os críticos estão atendidos
```

---

## ▶️ Exemplos de Execução

```prolog
% 1) Quem pode fornecer energia ao hospital?
?- pode_fornecer(usina_central, hospital_cidade).
true.

?- pode_fornecer(subestacao_norte, hospital_cidade).
true.

% 2) Fontes acessíveis para o bairro norte
?- fonte_acessivel(bairro_norte, F).
F = parque_solar_norte ;
F = usina_central.

?- fontes_disponiveis(bairro_norte, Fs).
Fs = [parque_solar_norte, usina_central].

% 3) Energia disponível para casa_101
?- energia_disponivel_para(casa_101, E).
E = 580.  % 500 (usina) + 80 (solar)

?- energia_disponivel_para(hospital_cidade, E).
E = 580.

?- energia_disponivel_para(centro_dados, E).
E = 560.  % 500 (usina) + 60 (eólica)

% 4) Há algum nó que precise de reforço?
?- necessita_reforco(X).
false.  % Todos os consumidores têm energia suficiente

% 5) Consumo total de subestacao_sul
?- consumo_total(subestacao_sul, T).
T = 184.  % fabrica_auto(80) + centro_dados(100) + bairro_sul(4)

?- consumo_total(subestacao_norte, T).
T = 71.  % hospital(50) + casa_101(5) + casa_102(4) + escola(12)

?- consumo_total(usina_central, T).
T = 255.  % Todos os consumidores

% 6) Verificar ancestrais e descendentes
?- ancestral(usina_central, casa_101).
true.

?- ancestral(subestacao_norte, casa_101).
true.

?- descendente(usina_central, C).
C = subestacao_norte ;
C = subestacao_sul ;
C = bairro_norte ;
C = bairro_sul ;
C = hospital_cidade ;
C = fabrica_auto ;
C = centro_dados ;
C = casa_101 ;
C = casa_102 ;
C = escola_municipal.

% 7) Listar consumidores atendidos por uma subestação
?- consumidores_atendidos(subestacao_norte, Cs).
Cs = [casa_101, casa_102, escola_municipal, hospital_cidade].

?- consumidores_atendidos(bairro_norte, Cs).
Cs = [casa_101, casa_102, escola_municipal].

% 8) Diagnóstico de falhas
?- causa_falha(hospital_cidade, M).
M = ok.

?- causa_falha(centro_dados, M).
M = ok.

% 9) Adicionando um novo consumidor com alta demanda
?- assertz(consumidor(fabrica_textil, eletrica, 300)),
   assertz(no_pai(fabrica_textil, subestacao_sul)),
   necessita_reforco(fabrica_textil).
true.

?- causa_falha(fabrica_textil, M).
M = 'energia_insuficiente: 560MW disponivel, 300MW necessario'.
false.  % Na verdade, 560 >= 300, então não há déficit

% 10) Simulando déficit real
?- assertz(consumidor(mega_datacenter, eletrica, 600)),
   assertz(no_pai(mega_datacenter, subestacao_sul)),
   necessita_reforco(mega_datacenter).
true.

?- causa_falha(mega_datacenter, M).
M = 'energia_insuficiente: 560MW disponivel, 600MW necessario'.

% 11) Verificar compatibilidade de tipos
?- compativel(solar, eletrica).
true.

?- compativel(eolica, eletrica).
true.

?- compativel(solar, eolica).
false.

% 12) Listar todos os consumidores
?- consumidor(C, _, D).
C = hospital_cidade, D = 50 ;
C = fabrica_auto, D = 80 ;
C = casa_101, D = 5 ;
C = casa_102, D = 4 ;
C = escola_municipal, D = 12 ;
C = centro_dados, D = 100.

% 13) Listar todas as fontes
?- fonte(F, T, C).
F = usina_central, T = eletrica, C = 500 ;
F = parque_solar_norte, T = solar, C = 80 ;
F = parque_eolico_sul, T = eolica, C = 60.

% 14) Capacidade total do sistema
?- findall(C, fonte(_, _, C), Caps), sum_list(Caps, Total).
Caps = [500, 80, 60],
Total = 640.

% 15) Demanda total do sistema
?- findall(D, consumidor(_, _, D), Dems), sum_list(Dems, Total).
Dems = [50, 80, 5, 4, 12, 100],
Total = 251.

% 16) Verificar se o sistema está balanceado
?- findall(C, fonte(_, _, C), Caps), sum_list(Caps, TotalCap),
   findall(D, consumidor(_, _, D), Dems), sum_list(Dems, TotalDem),
   TotalCap >= TotalDem.
TotalCap = 640,
TotalDem = 251.
true.  % Sistema balanceado: 640MW >= 251MW
```

---

## 🧠 Conceitos Aplicados

- **Árvores e Herança Lógica**: Hierarquia de nós com `ancestral/2` e `descendente/2` transitivos
- **Propagação Recursiva**: Recursos fluem de ancestrais para descendentes na hierarquia
- **Modelagem de Restrições**: Capacidade, compatibilidade e dependência entre nós
- **Busca com Somatório**: Agregação de capacidades e demandas usando findall e sum_list
- **Explicabilidade**: Diagnóstico de falhas com motivos detalhados
- **Raciocínio Causal**: Identificação de causas-raiz de déficits energéticos
- **Compatibilidade de Tipos**: Regras de conversão entre tipos de energia
- **Negação como Falha**: Verificação de ausência de fontes ou déficits

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

1. A base de dados deve conter **pelo menos 3 fontes**, **6 consumidores** e **4 níveis hierárquicos**
2. Teste casos de **energia suficiente e insuficiente** (adicione consumidores com alta demanda)
3. Implemente **propagação recursiva** de energia (ancestral → descendente)
4. Considere **compatibilidade de tipos** (solar/eólica → elétrica)
5. Implemente **diagnóstico de falhas** com explicações detalhadas
6. Use **findall** para agregar capacidades e demandas
7. Teste **hierarquias profundas** (usina → subestação → bairro → consumidor)
8. Implemente **pelo menos uma extensão** da tabela de extensões sugeridas
9. Organize o código em **múltiplos arquivos** conforme a estrutura sugerida
10. Teste **balanceamento global** (capacidade total >= demanda total)

