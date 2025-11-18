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

#### 1.1. `renda_familiar/2` - Soma de Rendas
```prolog
% ============================================
% RENDA_FAMILIAR/2
% ============================================
% Descrição: Calcula a renda total de uma família somando as rendas individuais
%            de todos os seus membros.
%
% Parâmetros:
%   - F: átomo identificando a família
%   - R: número representando a renda total (saída)
%
% Comportamento:
%   - Coleta todas as rendas individuais dos membros da família
%   - Usa findall/3 para agregar valores
%   - Soma todos os valores com sum_list/2
%   - Retorna renda total
%
% Exemplos de uso:
%   ?- renda_familiar(fam1, R).
%   R = 2500.0.  % soma das rendas de todos os membros
%
renda_familiar(F, R).
```

#### 1.2. `tamanho_familia/2` - Contagem de Membros
```prolog
% ============================================
% TAMANHO_FAMILIA/2
% ============================================
% Descrição: Conta o número total de membros de uma família.
%
% Parâmetros:
%   - F: átomo identificando a família
%   - N: número inteiro representando o tamanho (saída)
%
% Comportamento:
%   - Coleta todos os membros da família
%   - Usa findall/3 para agregar membros
%   - Conta com length/2
%   - Retorna número de membros
%
% Exemplos de uso:
%   ?- tamanho_familia(fam1, N).
%   N = 4.  % família com 4 membros
%
tamanho_familia(F, N).
```

#### 1.3. `num_dependentes/2` - Contagem de Dependentes com Limite
```prolog
% ============================================
% NUM_DEPENDENTES/2
% ============================================
% Descrição: Conta o número de dependentes em uma família, com limite máximo de 5
%            para fins de desconto. Dependentes são membros que atendem ao
%            predicado dependente/1.
%
% Parâmetros:
%   - F: átomo identificando a família
%   - N: número inteiro representando o número de dependentes (saída)
%
% Comportamento:
%   - Coleta todos os membros que são dependentes
%   - Conta o número total (N0)
%   - Aplica limite máximo de 5: N = min(5, N0)
%   - Limite evita descontos excessivos
%
% Política:
%   - Máximo de 5 dependentes contam para desconto
%   - Famílias com mais de 5 dependentes têm desconto limitado
%
% Exemplos de uso:
%   ?- num_dependentes(fam1, N).
%   N = 2.  % família com 2 dependentes
%
%   ?- num_dependentes(fam2, N).
%   N = 5.  % família com 7 dependentes, mas limite é 5
%
num_dependentes(F, N).
```

#### 1.4. `renda_per_capita/2` - Renda Per Capita Bruta
```prolog
% ============================================
% RENDA_PER_CAPITA/2
% ============================================
% Descrição: Calcula a renda per capita bruta da família (renda total dividida
%            pelo número de membros). Não considera ajustes por dependentes.
%
% Parâmetros:
%   - F: átomo identificando a família
%   - RPC: número representando a renda per capita (saída)
%
% Comportamento:
%   - Obtém renda total da família
%   - Obtém tamanho da família
%   - Verifica que família não está vazia (N > 0)
%   - Calcula RPC = R / N
%   - Retorna renda per capita bruta
%
% Uso:
%   - Base para cálculos de elegibilidade
%   - Usado em benefícios que não consideram ajustes
%
% Exemplos de uso:
%   ?- renda_per_capita(fam1, RPC).
%   RPC = 625.0.  % 2500 / 4 = 625
%
renda_per_capita(F, RPC).
```

#### 1.5. `renda_per_capita_ajustada/2` - Renda Per Capita Ajustada
```prolog
% ============================================
% RENDA_PER_CAPITA_AJUSTADA/2
% ============================================
% Descrição: Calcula a renda per capita ajustada, aplicando desconto por
%            dependentes. Usada para benefícios mais sensíveis à composição familiar.
%
% Parâmetros:
%   - F: átomo identificando a família
%   - RPCA: número representando a renda per capita ajustada (saída)
%
% Comportamento:
%   - Obtém renda per capita bruta
%   - Obtém número de dependentes (limitado a 5)
%   - Obtém taxa de desconto por dependente
%   - Obtém salário mínimo
%   - Calcula desconto: ND * Disc * SM
%   - Calcula RPCA = max(0, RPC - desconto)
%   - Garante que RPCA não seja negativa
%
% Fórmula:
%   RPCA = max(0, RPC - num_dependentes * desconto_dependente * salario_minimo)
%
% Política:
%   - Cada dependente reduz a renda per capita ajustada
%   - Reconhece custo adicional de dependentes
%   - Torna elegibilidade mais inclusiva para famílias grandes
%
% Exemplos de uso:
%   ?- renda_per_capita_ajustada(fam1, RPCA).
%   RPCA = 425.0.  % RPC 625 - 2 dependentes * 0.1 * 1000 = 425
%
renda_per_capita_ajustada(F, RPCA).
```

### 2. Ontologia de Categorias e Prioridade

#### 2.1. `categoria/1` - Base de Conhecimento de Categorias
```prolog
% ============================================
% CATEGORIA/1
% ============================================
% Descrição: Define as categorias sociais reconhecidas pelo sistema. Fatos puros
%            que enumeram as categorias disponíveis.
%
% Parâmetros:
%   - Cat: átomo representando uma categoria social
%
% Categorias:
%   - idoso: pessoas com 65+ anos
%   - desempregado: pessoas sem ocupação formal/informal
%   - ativo: pessoas com ocupação formal ou informal
%   - estudante: pessoas em formação (categoria complementar)
%
% Observação:
%   - Categorias podem coexistir (ex: idoso e estudante)
%   - Prioridade é usada para desambiguação
%
categoria(Cat).
```

#### 2.2. Predicados de Classificação
```prolog
% ============================================
% E_IDOSO/1, E_DESEMPREGADO/1, E_ATIVO/1, E_ESTUDANTE/1
% ============================================
% Descrição: Predicados auxiliares que verificam se uma pessoa pertence a cada
%            categoria social baseado em seus atributos.
%
% Parâmetros:
%   - P: átomo identificando a pessoa
%
% Comportamento:
%   - e_idoso(P): idade >= 65 anos
%   - e_desempregado(P): ocupacao = desempregado OU fato desempregado(P)
%   - e_ativo(P): ocupacao = formal OU informal
%   - e_estudante(P): ocupacao = estudante
%
% Exemplos de uso:
%   ?- e_idoso(joao).
%   true.  % joao tem 70 anos
%
%   ?- e_desempregado(maria).
%   true.  % maria está desempregada
%
e_idoso(P).
e_desempregado(P).
e_ativo(P).
e_estudante(P).
```

#### 2.3. `categoria_de/2` - Mapeamento Pessoa-Categoria
```prolog
% ============================================
% CATEGORIA_DE/2
% ============================================
% Descrição: Mapeia uma pessoa para suas categorias aplicáveis, com regras de
%            precedência para evitar sobreposição indesejada.
%
% Parâmetros:
%   - P: átomo identificando a pessoa
%   - Cat: átomo representando a categoria (saída)
%
% Comportamento:
%   - idoso: se e_idoso(P) (sem restrições)
%   - desempregado: se e_desempregado(P) E NÃO e_idoso(P)
%   - ativo: se e_ativo(P) E NÃO e_idoso(P) E NÃO e_desempregado(P)
%   - estudante: se e_estudante(P) (sem restrições, complementar)
%
% Regras de precedência:
%   1. Idoso tem precedência sobre desempregado e ativo
%   2. Desempregado tem precedência sobre ativo
%   3. Estudante é complementar (pode coexistir)
%
% Exemplos de uso:
%   ?- categoria_de(joao, C).
%   C = idoso.  % joao é idoso (mesmo se desempregado)
%
%   ?- categoria_de(maria, C).
%   C = desempregado ;  % maria é desempregada
%   C = estudante.      % maria também é estudante
%
categoria_de(P, Cat).
```

#### 2.4. `prioridade/2` - Níveis de Prioridade
```prolog
% ============================================
% PRIORIDADE/2
% ============================================
% Descrição: Define o nível de prioridade de cada categoria para desambiguação.
%            Maior valor = maior prioridade.
%
% Parâmetros:
%   - Cat: átomo representando a categoria
%   - Nivel: número inteiro representando o nível de prioridade
%
% Níveis:
%   - idoso: 3 (maior prioridade)
%   - desempregado: 2
%   - ativo: 1
%   - estudante: 0 (complementar, não prioritário)
%
% Uso:
%   - Desambiguação quando pessoa tem múltiplas categorias
%   - Escolha de benefício principal
%
prioridade(Cat, Nivel).
```

#### 2.5. `categoria_mais_alta/2` - Categoria Prioritária
```prolog
% ============================================
% CATEGORIA_MAIS_ALTA/2
% ============================================
% Descrição: Determina a categoria de maior prioridade aplicável a uma pessoa.
%            Usado para desambiguação quando pessoa tem múltiplas categorias.
%
% Parâmetros:
%   - P: átomo identificando a pessoa
%   - Cat: átomo representando a categoria de maior prioridade (saída)
%
% Comportamento:
%   - Coleta todas as categorias aplicáveis à pessoa
%   - Verifica que há pelo menos uma categoria
%   - Mapeia cada categoria para seu nível de prioridade
%   - Encontra o nível máximo
%   - Retorna categoria com nível máximo
%
% Lógica:
%   - Usa findall/3 para coletar categorias
%   - Usa maplist/3 para obter prioridades
%   - Usa max_member/2 para encontrar máximo
%   - Usa member/2 e prioridade/2 para encontrar categoria
%
% Exemplos de uso:
%   ?- categoria_mais_alta(joao, C).
%   C = idoso.  % joao é idoso e desempregado, mas idoso tem prioridade 3
%
%   ?- categoria_mais_alta(maria, C).
%   C = desempregado.  % maria é desempregada (prioridade 2) e estudante (prioridade 0)
%
categoria_mais_alta(P, Cat).
```

### 3. Benefícios e Regras de Elegibilidade

#### 3.1. `familia_de/2` - Helper para Obter Família
```prolog
% ============================================
% FAMILIA_DE/2
% ============================================
% Descrição: Predicado auxiliar que obtém a família de uma pessoa. Inverte a
%            relação membro/2 para facilitar consultas.
%
% Parâmetros:
%   - P: átomo identificando a pessoa
%   - F: átomo identificando a família (saída)
%
% Comportamento:
%   - Inverte membro(F, P) para familia_de(P, F)
%   - Facilita leitura e uso em regras de elegibilidade
%
% Exemplos de uso:
%   ?- familia_de(joao, F).
%   F = fam1.
%
familia_de(P, F).
```

#### 3.2. `tem_direito/2` - Verificação de Elegibilidade
```prolog
% ============================================
% TEM_DIREITO/2
% ============================================
% Descrição: Verifica se uma pessoa tem direito a um benefício social específico.
%            Implementa regras de elegibilidade para 5 benefícios diferentes.
%
% Parâmetros:
%   - P: átomo identificando a pessoa
%   - Beneficio: átomo representando o benefício
%
% Benefícios e Regras:
%
%   1. **bolsa_basica**: RPCA <= 50% SM
%      - Usa renda per capita ajustada (considera dependentes)
%      - Critério mais restritivo
%      - Benefício universal para extrema pobreza
%
%   2. **bolsa_idoso**: idoso (65+) E RPC <= 100% SM
%      - Usa renda per capita bruta (não ajustada)
%      - Critério menos restritivo que bolsa básica
%      - Específico para idosos
%
%   3. **auxilio_desemprego**: desempregado E RPC <= 120% SM
%      - Usa renda per capita bruta
%      - Critério mais flexível
%      - Suporte temporário para desempregados
%
%   4. **auxilio_creche**: família com criança pequena E RPC <= 120% SM
%      - Verifica presença de criança pequena na família
%      - Usa renda per capita bruta
%      - Suporte para famílias com crianças
%
%   5. **bonus_monoparental**: família monoparental
%      - Independe de renda
%      - Reconhece desafio adicional de famílias monoparentais
%
% Observações:
%   - Pessoa pode ter direito a múltiplos benefícios
%   - Cada benefício tem critérios independentes
%   - Limiares são configuráveis via fatos
%
% Exemplos de uso:
%   ?- tem_direito(joao, bolsa_idoso).
%   true.  % joao é idoso e RPC <= 1.0 * SM
%
%   ?- tem_direito(maria, B).
%   B = bolsa_basica ;
%   B = auxilio_desemprego ;
%   B = bonus_monoparental.
%
tem_direito(P, Beneficio).
```

### 4. Explicabilidade

#### 4.1. `motivo/3` - Justificativa Técnica por Benefício
```prolog
% ============================================
% MOTIVO/3
% ============================================
% Descrição: Gera justificativa técnica formatada explicando por que uma pessoa
%            tem direito a um benefício específico. Inclui valores calculados.
%
% Parâmetros:
%   - P: átomo identificando a pessoa
%   - Beneficio: átomo representando o benefício
%   - Motivo: átomo contendo a justificativa formatada (saída)
%
% Comportamento:
%   - Cada benefício tem sua própria cláusula
%   - Calcula valores relevantes (RPC, RPCA, SM)
%   - Formata mensagem com format/2
%   - Inclui valores numéricos para transparência
%
% Formatos de mensagem:
%   - bolsa_basica: "RPCA=X <= 0.5*SM (Y)"
%   - bolsa_idoso: "idoso e RPC=X <= 1.0*SM (Y)"
%   - auxilio_desemprego: "desempregado e RPC=X <= 1.2*SM (Y)"
%   - auxilio_creche: "familia com crianca pequena e RPC=X <= 1.2*SM (Y)"
%   - bonus_monoparental: "familia monoparental"
%
% Uso:
%   - Transparência para beneficiários
%   - Auditoria de decisões
%   - Debugging de elegibilidade
%
% Exemplos de uso:
%   ?- motivo(joao, bolsa_idoso, M).
%   M = 'idoso e RPC=800.00 <= 1.0*SM (1000.00)'.
%
motivo(P, Beneficio, Motivo).
```

#### 4.2. `elegibilidade/3` - Relatório Completo de Elegibilidade
```prolog
% ============================================
% ELEGIBILIDADE/3
% ============================================
% Descrição: Gera relatório completo de elegibilidade de uma pessoa, incluindo
%            todos os benefícios aos quais tem direito e fundamentação detalhada.
%
% Parâmetros:
%   - P: átomo identificando a pessoa
%   - Beneficios: lista ordenada de benefícios (saída)
%   - Fundamentacao: lista de justificativas (saída)
%
% Comportamento:
%   - Coleta todos os benefícios aos quais pessoa tem direito
%   - Remove duplicatas e ordena (sort/2)
%   - Para cada benefício, obtém motivo técnico
%   - Obtém categoria prioritária da pessoa
%   - Formata fundamentação: [categoria_prioritaria | motivos]
%   - Retorna benefícios e fundamentação
%
% Estrutura da fundamentação:
%   - Primeiro elemento: categoria prioritária
%   - Demais elementos: motivos técnicos de cada benefício
%
% Uso:
%   - Relatório completo para beneficiário
%   - Documentação de decisão
%   - Interface com sistema de pagamentos
%
% Exemplos de uso:
%   ?- elegibilidade(joao, B, F).
%   B = [bolsa_idoso, bonus_monoparental],
%   F = ['categoria_prioritaria=idoso',
%        'idoso e RPC=800.00 <= 1.0*SM (1000.00)',
%        'familia monoparental'].
%
elegibilidade(P, Beneficios, Fundamentacao).
```

#### 4.3. `motivos/2` - Lista Simplificada
```prolog
% ============================================
% MOTIVOS/2
% ============================================
% Descrição: Gera lista simplificada combinando benefícios e fundamentação em
%            uma única lista. Versão mais compacta de elegibilidade/3.
%
% Parâmetros:
%   - P: átomo identificando a pessoa
%   - Lista: lista combinada de benefícios e fundamentação (saída)
%
% Comportamento:
%   - Obtém benefícios e fundamentação via elegibilidade/3
%   - Concatena ambas as listas com append/3
%   - Retorna lista unificada
%
% Uso:
%   - Visualização rápida
%   - Logging simplificado
%   - Interface textual
%
% Exemplos de uso:
%   ?- motivos(joao, L).
%   L = [bolsa_idoso, bonus_monoparental,
%        'categoria_prioritaria=idoso',
%        'idoso e RPC=800.00 <= 1.0*SM (1000.00)',
%        'familia monoparental'].
%
motivos(P, Lista).
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

