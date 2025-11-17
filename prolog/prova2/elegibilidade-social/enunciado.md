**Tema:** 🏘️ Sistema de Elegibilidade para Benefícios Sociais

---

## 🎯 Objetivo

Modelar, em **Prolog (padrão)**, um motor que:

1. Representa **famílias, pessoas, composição e renda**
2. Infere **categoria social** de cada pessoa (idoso, desempregado, ativo, estudante etc.) e aplica **prioridade** entre categorias
3. Avalia **benefícios** com base em **renda per capita**, **dependentes**, **idade**, **ocupação** e **situações especiais**
4. Emite decisão elegível/benefício + **explicações** (por que foi elegível/inelegível)

Consultas esperadas:

```prolog
elegibilidade(pessoa_x, Beneficios, Fundamentacao).
renda_per_capita(fam_y, RPC).
categoria_mais_alta(pessoa_x, Cat).
tem_direito(pessoa_x, bolsa_basica).
motivos(pessoa_x, Lista).
```

---

## 🧩 Descrição do Problema

Você é o **analista de políticas sociais** responsável por implementar um sistema de avaliação de elegibilidade para benefícios sociais.

O sistema deve avaliar famílias considerando sua composição (membros, dependentes), renda total e per capita, categorias sociais prioritárias (idoso, desempregado, ativo, estudante) e situações especiais (família monoparental, criança pequena).

Implemente um sistema lógico que:
- Modela famílias com membros, rendas individuais e atributos pessoais
- Calcula renda per capita bruta e ajustada (com desconto por dependentes)
- Infere categorias sociais com hierarquia de prioridade
- Avalia elegibilidade para múltiplos benefícios com regras específicas
- Gera explicações detalhadas das decisões (por que foi aprovado ou negado)

---

## 🎯 Objetivos de Aprendizagem

- Modelar domínios sociais complexos usando o paradigma lógico
- Implementar cálculos aritméticos em Prolog (renda per capita, ajustes)
- Criar hierarquias de categorias com priorização
- Utilizar findall para agregação de dados
- Aplicar negação como falha para exceções
- Gerar explicações textuais automáticas
- Organizar o sistema em múltiplos arquivos

---

## 🏘️ Base de Fatos (Domínio Didático)

### Parâmetros Normativos
```prolog
% =========================
% PARÂMETROS NORMATIVOS (didáticos)
% =========================
salario_minimo(1412).                 % BRL
limite_rpc_bolsa_basica(0.5).         % renda per capita <= 50% SM
limite_rpc_bolsa_idoso(1.0).          % renda per capita <= 100% SM
limite_rpc_auxilio_desemprego(1.2).   % renda per capita <= 120% SM
limite_rpc_creche(1.2).               % idem

% descontos por dependente (fator didático, para "renda ajustada")
desconto_dependente(0.03).            % -3% do SM por dependente até 5
```

### Famílias e Membros
```prolog
% =========================
% FAMÍLIAS
% familia(Id).
% membro(Familia, Pessoa).
% renda_pessoa(Pessoa, Valor).
% dependente(Pessoa) — menor de 18 ou incapaz.
% =========================
familia(f1). familia(f2). familia(f3). familia(f4).

% Família 1: Ana (mãe), João (pai), Bia (filha dependente)
membro(f1, ana).    renda_pessoa(ana, 1800).
membro(f1, joao).   renda_pessoa(joao, 0).
membro(f1, bia).    renda_pessoa(bia, 0).  dependente(bia).

% Família 2: Carla (aposentada), Luan (filho trabalhador)
membro(f2, carla).  renda_pessoa(carla, 1400).
membro(f2, luan).   renda_pessoa(luan, 1100).

% Família 3: Dona Lia (idosa), Pedrinho (neto dependente), Marcos (desempregado)
membro(f3, dona_lia). renda_pessoa(dona_lia, 900).
membro(f3, pedrinho). renda_pessoa(pedrinho, 0). dependente(pedrinho).
membro(f3, marcos).   renda_pessoa(marcos, 0).  desempregado(marcos).

% Família 4: Zeca (trabalhador), Rita (desempregada), Vovô (idoso)
membro(f4, zeca).   renda_pessoa(zeca, 2600).
membro(f4, rita).   renda_pessoa(rita, 500).  desempregado(rita).
membro(f4, vovo).   renda_pessoa(vovo, 0).   idade(vovo, 66).
```

### Atributos Pessoais
```prolog
% =========================
% ATRIBUTOS PESSOAIS
% =========================
% Idades
idade(ana, 29).   idade(joao, 31).  idade(bia, 7).
idade(carla, 63). idade(luan, 28).
idade(dona_lia, 70). idade(pedrinho, 5). idade(marcos, 34).
idade(zeca, 40). idade(rita, 38). idade(vovo, 66).

% Ocupações
ocupacao(ana, formal).       % empregado com carteira
ocupacao(joao, informal).
ocupacao(bia, estudante).
ocupacao(carla, aposentada).
ocupacao(luan, formal).
ocupacao(dona_lia, aposentada).
ocupacao(pedrinho, estudante).
ocupacao(marcos, desempregado).
ocupacao(zeca, formal).
ocupacao(rita, desempregado).
ocupacao(vovo, aposentada).
```

### Situações Especiais
```prolog
% =========================
% SITUAÇÃO ESPECIAL (didática)
% =========================
monoparental(f1, ana).     % família 1 chefiada por ana
crianca_pequena(bia).      % até 6 anos
crianca_pequena(pedrinho).
```

---

## 📂 Estrutura dos Arquivos e Entrada-Saída

### Arquivos de Entrada
- **`entrada.txt`**: Contém os fatos da base de conhecimento (famílias, membros, rendas, atributos)

### Arquivos Prolog
- **`principal.pl`**: Arquivo principal que carrega os demais módulos e a base de dados
- **`familias.pl`**: Predicados relacionados a famílias, membros e cálculos de renda
- **`categorias.pl`**: Predicados de categorias sociais e priorização
- **`beneficios.pl`**: Predicados de elegibilidade para benefícios
- **`explicacao.pl`**: Predicados de explicação e justificativa

### Arquivo de Saída
- **`saida.txt`**: Resultados de elegibilidade e justificativas

---

## 🧱 Tarefas Obrigatórias

### 1. Cálculos de Renda e Composição

```prolog
% Soma de rendas da família
renda_familiar(F, R) :-
    findall(V, (membro(F, P), renda_pessoa(P, V)), Vs),
    sum_list(Vs, R).

% Número de membros
tamanho_familia(F, N) :-
    findall(P, membro(F, P), Ps),
    length(Ps, N).

% Número de dependentes (com limite de desconto)
num_dependentes(F, N) :-
    findall(P, (membro(F, P), dependente(P)), Ds),
    length(Ds, N0),
    N is min(5, N0).

% Renda per capita bruta
renda_per_capita(F, RPC) :-
    renda_familiar(F, R),
    tamanho_familia(F, N),
    N > 0,
    RPC is R / N.

% Renda per capita ajustada (desconto por dependentes)
renda_per_capita_ajustada(F, RPCA) :-
    renda_per_capita(F, RPC),
    num_dependentes(F, ND),
    desconto_dependente(Disc),
    salario_minimo(SM),
    RPCA is max(0, RPC - ND * Disc * SM).
```

### 2. Ontologia de Categorias e Prioridade

```prolog
% Categorias-base (podem coexistir, mas aplicamos prioridade para decisão)
categoria(idoso).
categoria(desempregado).
categoria(ativo).
categoria(estudante).  % pode modular benefícios complementares

% Regras para obter categorias
e_idoso(P) :- idade(P, I), I >= 65.
e_desempregado(P) :- ocupacao(P, desempregado) ; desempregado(P).
e_ativo(P) :- ocupacao(P, formal) ; ocupacao(P, informal).
e_estudante(P) :- ocupacao(P, estudante).

% Mapeamento para categoria
categoria_de(P, idoso) :- e_idoso(P).
categoria_de(P, desempregado) :- e_desempregado(P), \+ e_idoso(P).
categoria_de(P, ativo) :- e_ativo(P), \+ e_idoso(P), \+ e_desempregado(P).
categoria_de(P, estudante) :- e_estudante(P).

% Prioridade (maior valor = mais prioritário)
prioridade(idoso, 3).
prioridade(desempregado, 2).
prioridade(ativo, 1).
prioridade(estudante, 0). % complementar

% Escolhe a categoria de maior prioridade entre as aplicáveis
categoria_mais_alta(P, Cat) :-
    findall(C, categoria_de(P, C), Cats),
    Cats \= [],
    maplist(\C^PVal^(prioridade(C, PVal)), Cats, Ps),
    max_member(Max, Ps),
    member(Cat, Cats),
    prioridade(Cat, Max).
```

### 3. Benefícios e Regras de Elegibilidade

```prolog
% Helper: obtém família da pessoa
familia_de(P, F) :- membro(F, P).

% BOLSA BÁSICA: RPCA <= 50% SM
tem_direito(P, bolsa_basica) :-
    familia_de(P, F),
    renda_per_capita_ajustada(F, RPCA),
    salario_minimo(SM),
    limite_rpc_bolsa_basica(L),
    RPCA =< L * SM.

% BOLSA IDOSO: idoso e RPC <= 100% SM (menos restritivo que a básica)
tem_direito(P, bolsa_idoso) :-
    e_idoso(P),
    familia_de(P, F),
    renda_per_capita(F, RPC),
    salario_minimo(SM),
    limite_rpc_bolsa_idoso(L),
    RPC =< L * SM.

% AUXÍLIO-DESEMPREGO: desempregado e RPC <= 120% SM
tem_direito(P, auxilio_desemprego) :-
    e_desempregado(P),
    familia_de(P, F),
    renda_per_capita(F, RPC),
    salario_minimo(SM),
    limite_rpc_auxilio_desemprego(L),
    RPC =< L * SM.

% AUXÍLIO-CRECHE: família com criança pequena e RPC <= 120% SM
tem_direito(P, auxilio_creche) :-
    familia_de(P, F),
    membro(F, X),
    crianca_pequena(X),   % há criança pequena na família
    renda_per_capita(F, RPC),
    salario_minimo(SM),
    limite_rpc_creche(L),
    RPC =< L * SM.

% BÔNUS MONOPARENTAL: família monoparental (independe de RPC)
tem_direito(P, bonus_monoparental) :-
    familia_de(P, F),
    monoparental(F, _).
```

### 4. Explicabilidade

```prolog
% Motivos "técnicos" acionados
motivo(P, bolsa_basica, M) :-
    familia_de(P, F),
    renda_per_capita_ajustada(F, RPCA),
    salario_minimo(SM),
    format(atom(M), 'RPCA=~2f <= 0.5*SM (~2f)', [RPCA, 0.5*SM]).

motivo(P, bolsa_idoso, M) :-
    familia_de(P, F),
    renda_per_capita(F, RPC),
    salario_minimo(SM),
    format(atom(M), 'idoso e RPC=~2f <= 1.0*SM (~2f)', [RPC, 1.0*SM]).

motivo(P, auxilio_desemprego, M) :-
    familia_de(P, F),
    renda_per_capita(F, RPC),
    salario_minimo(SM),
    format(atom(M), 'desempregado e RPC=~2f <= 1.2*SM (~2f)', [RPC, 1.2*SM]).

motivo(P, auxilio_creche, M) :-
    familia_de(P, F),
    renda_per_capita(F, RPC),
    salario_minimo(SM),
    format(atom(M), 'familia com crianca pequena e RPC=~2f <= 1.2*SM (~2f)', [RPC, 1.2*SM]).

motivo(P, bonus_monoparental, 'familia monoparental').

% Agrega benefícios e motivações
elegibilidade(P, Beneficios, Fundamentacao) :-
    findall(B, tem_direito(P, B), Bs0),
    sort(Bs0, Beneficios),
    findall(T, (member(B, Beneficios), motivo(P, B, T)), Ts),
    categoria_mais_alta(P, Cat),
    format(atom(Topo), 'categoria_prioritaria=~w', [Cat]),
    Fundamentacao = [Topo|Ts].

% Lista simples de motivos
motivos(P, Lista) :-
    elegibilidade(P, Bs, F),
    append(Bs, F, Lista).
```

---

## ✨ Extensões (Escolha pelo menos UMA)

| Conceito | Extensão Prática |
|----------|------------------|
| **Temporalidade** | Registrar `data(ano, mes)` para regras que mudam com o tempo (novos limites de SM). Benefícios com validade temporal. |
| **Regra Regional** | Benefícios com parâmetros por município/UF (`limite_rpc/3`). Diferentes políticas por região. |
| **Acumulação Limitada** | Predicado que limita número de benefícios acumuláveis por família. Teto de benefícios. |
| **Prova Negativa** | `\+ crianca_pequena(_)` para negar auxílio-creche quando não houver criança. Explicação de negações. |
| **Critérios de Patrimônio** | Excluir quando `patrimonio_familia > K * SM`. Verificação de bens além de renda. |
| **Elegibilidade Familiar vs. Individual** | Benefícios concedidos à família (1 por núcleo) vs. ao indivíduo. Controle de duplicação. |
| **Explicabilidade Avançada** | `trilha/2` retornando `(regra → fatos)` para auditoria. Rastreamento completo de decisões. |

### Exemplo de Extensão: Regra Regional
```prolog
% Parâmetros por município
limite_rpc_regional(sao_paulo, bolsa_basica, 0.6).  % SP: 60% SM
limite_rpc_regional(rio_janeiro, bolsa_basica, 0.5). % RJ: 50% SM
limite_rpc_regional(recife, bolsa_basica, 0.7).      % Recife: 70% SM

% Município da família
municipio_familia(f1, sao_paulo).
municipio_familia(f2, rio_janeiro).
municipio_familia(f3, recife).
municipio_familia(f4, sao_paulo).

% Bolsa básica com regra regional
tem_direito_regional(P, bolsa_basica) :-
    familia_de(P, F),
    municipio_familia(F, Mun),
    renda_per_capita_ajustada(F, RPCA),
    salario_minimo(SM),
    limite_rpc_regional(Mun, bolsa_basica, L),
    RPCA =< L * SM.

% Exemplo de uso:
% ?- tem_direito_regional(ana, bolsa_basica).
% true.  % ana em SP com RPCA <= 60% SM
```

---

## ▶️ Exemplos de Execução

```prolog
% 1) Renda per capita bruta e ajustada
?- renda_per_capita(f1, RPC), renda_per_capita_ajustada(f1, RPCA).
% f1: ana(1800)+joao(0)+bia(0); N=3; 1 dependente
% RPC = 600, RPCA = 600 - 0.03*1412 ≈ 557.64
RPC = 600.0,
RPCA = 557.64.

?- renda_per_capita(f3, RPC), renda_per_capita_ajustada(f3, RPCA).
% f3: dona_lia(900)+pedrinho(0)+marcos(0); N=3; 1 dependente
RPC = 300.0,
RPCA = 257.64.

% 2) Categoria prioritária
?- categoria_mais_alta(dona_lia, C).
C = idoso.

?- categoria_mais_alta(rita, C).
C = desempregado.

?- categoria_mais_alta(ana, C).
C = ativo.

?- categoria_mais_alta(bia, C).
C = estudante.

% 3) Elegibilidade completa — casos variados
?- elegibilidade(ana, Bs, F).
Bs = [auxilio_creche, bonus_monoparental],
F = ['categoria_prioritaria=ativo',
     'familia com crianca pequena e RPC=600.00 <= 1.2*SM (1694.40)',
     'familia monoparental'].

?- elegibilidade(dona_lia, Bs, F).
Bs = [bolsa_idoso, auxilio_creche],
F = ['categoria_prioritaria=idoso',
     'idoso e RPC=300.00 <= 1.0*SM (1412.00)',
     'familia com crianca pequena e RPC=300.00 <= 1.2*SM (1694.40)'].

?- elegibilidade(marcos, Bs, F).
Bs = [auxilio_desemprego, auxilio_creche],
F = ['categoria_prioritaria=desempregado',
     'desempregado e RPC=300.00 <= 1.2*SM (1694.40)',
     'familia com crianca pequena e RPC=300.00 <= 1.2*SM (1694.40)'].

?- elegibilidade(zeca, Bs, F).
Bs = [],
F = ['categoria_prioritaria=ativo'].

% 4) Checar um benefício específico
?- tem_direito(rita, auxilio_desemprego).
true.

?- tem_direito(luan, bolsa_basica).
false.

?- tem_direito(dona_lia, bolsa_idoso).
true.

?- tem_direito(ana, bonus_monoparental).
true.

% 5) Ver "motivos" reunidos
?- motivos(ana, L).
L = [auxilio_creche, bonus_monoparental,
     'categoria_prioritaria=ativo',
     'familia com crianca pequena e RPC=600.00 <= 1.2*SM (1694.40)',
     'familia monoparental'].

?- motivos(marcos, L).
L = [auxilio_desemprego, auxilio_creche,
     'categoria_prioritaria=desempregado',
     'desempregado e RPC=300.00 <= 1.2*SM (1694.40)',
     'familia com crianca pequena e RPC=300.00 <= 1.2*SM (1694.40)'].

% 6) Listar todas as categorias de uma pessoa
?- categoria_de(dona_lia, C).
C = idoso ;
C = estudante.  % false (não é estudante)

?- findall(C, categoria_de(dona_lia, C), Cats).
Cats = [idoso].

% 7) Listar todos os membros de uma família
?- membro(f1, P).
P = ana ;
P = joao ;
P = bia.

% 8) Calcular renda familiar total
?- renda_familiar(f1, R).
R = 1800.

?- renda_familiar(f3, R).
R = 900.

?- renda_familiar(f4, R).
R = 3100.

% 9) Contar dependentes
?- num_dependentes(f1, N).
N = 1.

?- num_dependentes(f3, N).
N = 1.

% 10) Verificar situações especiais
?- monoparental(f1, Responsavel).
Responsavel = ana.

?- crianca_pequena(P).
P = bia ;
P = pedrinho.

% 11) Listar todas as pessoas elegíveis para um benefício
?- tem_direito(P, bolsa_idoso).
P = dona_lia ;
P = vovo.

?- tem_direito(P, auxilio_desemprego).
P = marcos ;
P = rita.

% 12) Verificar múltiplos benefícios
?- findall(B, tem_direito(dona_lia, B), Bs).
Bs = [bolsa_idoso, auxilio_creche].

?- findall(B, tem_direito(ana, B), Bs).
Bs = [auxilio_creche, bonus_monoparental].

% 13) Comparar rendas per capita
?- renda_per_capita(f1, R1), renda_per_capita(f3, R3), R1 > R3.
R1 = 600.0,
R3 = 300.0.

% 14) Verificar limites normativos
?- salario_minimo(SM), limite_rpc_bolsa_basica(L), Limite is L * SM.
SM = 1412,
L = 0.5,
Limite = 706.0.
```

---

## 🧠 Conceitos Aplicados

- **Modelagem Declarativa**: Famílias, renda, composição e status representados como fatos
- **Cálculo Lógico**: Renda per capita bruta e ajustada com operações aritméticas
- **Regras com Exceções**: Negação como falha para verificar ausência de condições
- **Hierarquia de Categorias**: Priorização de categorias sociais (idoso > desempregado > ativo)
- **Findall e Agregação**: Coleta de rendas, membros, benefícios e categorias
- **Explicabilidade**: Geração automática de justificativas textuais para decisões
- **Format e Atom**: Construção de strings explicativas com valores calculados
- **Maplist e Max_member**: Operações funcionais para encontrar categoria prioritária

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

1. A base de dados deve conter **pelo menos 4 famílias**, **12 pessoas** e **5 benefícios**
2. Teste casos de **renda baixa, média e alta** (abaixo, próximo e acima dos limites)
3. Teste casos de **múltiplas categorias** (pessoa pode ser idoso e desempregado)
4. Implemente **priorização de categorias** (idoso tem prioridade sobre desempregado)
5. Calcule **renda per capita ajustada** com desconto por dependentes (até 5)
6. Implemente **explicações textuais** para todos os benefícios
7. Use **findall** para agregar dados (rendas, membros, benefícios)
8. Teste **situações especiais** (família monoparental, criança pequena)
9. Implemente **pelo menos uma extensão** da tabela de extensões sugeridas
10. Organize o código em **múltiplos arquivos** conforme a estrutura sugerida

