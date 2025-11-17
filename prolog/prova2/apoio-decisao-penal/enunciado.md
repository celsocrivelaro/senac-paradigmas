**Tema:** ⚖️ Sistema de Apoio à Decisão Penal

---

## 🧩 Descrição do Problema

Você deve implementar um **sistema de apoio à decisão penal** em Prolog que simula o raciocínio jurídico para análise de casos criminais. O sistema deve:

- **Modelar o domínio penal** com tipos penais (furto, roubo), qualificadoras, situação fática e situação pessoal do réu
- **Aplicar regras jurídicas com exceções**, como:
  - Princípio da insignificância (valor irrisório + ausência de violência → atipicidade)
  - Furto privilegiado (primariedade + pequeno valor + sem violência → redução de pena)
  - Reincidência afasta benefícios (exceção que impede aplicação de institutos favoráveis)
- **Consultar precedentes jurisprudenciais** respeitando hierarquia de tribunais (STF > STJ > TJ) e vinculação
- **Usar negação como falha** (`\+`) para verificar hipóteses não provadas
- **Produzir decisão preliminar** (absolver, reduzir pena, dosimetria) com **fundamentos explicativos**

O sistema deve responder consultas como:
- "Qual a classificação jurídica do caso C1?" (furto, roubo, qualificado)
- "Quais precedentes se aplicam ao caso C2?"
- "Qual a decisão preliminar e seus fundamentos para o caso C3?"
- "Por que o caso C4 não se beneficia da insignificância?"

---

## 🗂️ Modelagem da Base de Conhecimento

A base de dados deve representar:

### Tribunais e Hierarquia
```prolog
tribunal(stf, prioridade(3), vinculante(sim)).
tribunal(stj, prioridade(2), vinculante(nao)).
tribunal(tj,  prioridade(1), vinculante(nao)).
```

### Precedentes Jurisprudenciais
```prolog
precedente(p1, stf, insignificancia,
  'valor irrisorio e ausencia de violencia podem afastar tipicidade',
  vinculante(nao)).

precedente(p2, stj, reincidencia_afasta_insignificancia,
  'reincidencia especifica afasta insignificancia como regra',
  vinculante(nao)).
```

### Casos e Fatos
```prolog
caso(c1, furto).
fatos_caso(c1, valor_bem(100)).
fatos_caso(c1, violencia(nao)).
fatos_caso(c1, primario(sim)).
fatos_caso(c1, reincidente(nao)).
fatos_caso(c1, confissao_espontanea(sim)).
fatos_caso(c1, devolucao_bem(sim)).
```

### Constantes e Limites
```prolog
salario_minimo(1412).
limite_irrisorio(F) :- salario_minimo(SM), F is 0.1*SM.
pequeno_valor(C) :- fatos_caso(C, valor_bem(V)),
                    limite_irrisorio(Lim),
                    V =< Lim * 2.
```

---

## 🎯 Objetivos de Aprendizagem

- Modelar regras jurídicas com exceções
- Implementar hierarquia de precedentes
- Usar negação como falha
- Gerar decisões e fundamentos
- Calcular dosimetria de pena

---

## 📂 Estrutura dos Arquivos

### Arquivos de Entrada
- **`entrada.txt`**: Base de conhecimento com:
  - Tribunais e hierarquia (STF, STJ, TJ com prioridades)
  - Precedentes jurisprudenciais (tema, tese, tribunal, vinculação)
  - Casos (identificador, tipo penal base)
  - Fatos dos casos (valor do bem, violência, primariedade, reincidência, etc.)
  - Constantes (salário mínimo, limites)

### Arquivos Prolog
- **`principal.pl`**: Arquivo principal que carrega os demais módulos
- **`precedentes.pl`**: Hierarquia de tribunais e aplicação de precedentes
- **`regras.pl`**: Regras materiais (insignificância, privilegiado, exceções)
- **`dosimetria.pl`**: Cálculo de pena-base e reduções
- **`decisao.pl`**: Decisão preliminar e fundamentos
- **`explicacao.pl`**: Geração de explicações humanizadas

### Arquivo de Saída
- **`saida.txt`**: Decisões preliminares com fundamentos e explicações

---

## 🧱 Tarefas Obrigatórias

Implemente os seguintes predicados principais:

### 1. Hierarquia de Tribunais e Precedentes
```prolog
% Define tribunais com prioridade e vinculação
tribunal(Nome, prioridade(N), vinculante(Sim/Nao)).

% Seleciona precedente aplicável por tema, respeitando hierarquia
precedente_aplicavel(Tema, Tribunal, Tese).

% Verifica se precedente se aplica ao caso específico
aplica_precedente(Caso, Tema, Tribunal, Tese).
```

### 2. Classificação Jurídica
```prolog
% Classifica o fato como furto, roubo, qualificado, etc.
classificacao_juridica(Caso, TipoPenal).

% Verifica se há qualificadoras aplicáveis
tem_qualificadora(Caso, Qualificadora).
```

### 3. Regras Materiais com Exceções
```prolog
% Verifica se caso atende requisitos da insignificância
% (valor < 10% SM, sem violência)
regra_insignificancia(Caso).

% Verifica exceções que impedem insignificância
% (ex: reincidência específica)
excecao_insignificancia(Caso).

% Verifica requisitos do furto privilegiado
% (primariedade + pequeno valor + sem violência)
regra_furto_privilegiado(Caso).

% Identifica causas de diminuição aplicáveis
causas_caso(Caso, ListaCausas).
```

### 4. Dosimetria e Cálculo de Pena
```prolog
% Define pena-base por tipo penal
pena_base(TipoPenal, Pontos).

% Aplica reduções percentuais
aplica_reducao(PenaInicial, Percentual, PenaFinal).

% Acumula reduções cumulativas
acumula_reducoes(PenaInicial, ListaReducoes, PenaFinal).
```

### 5. Decisão e Fundamentos
```prolog
% Produz decisão preliminar com fundamentos
% Resultado pode ser: absolver_por_insignificancia,
%                     reduzir_pena_por_privilegio,
%                     dosimetria(PenaFinal)
decisao_preliminar(Caso, Resultado, Fundamentos).

% Coleta fundamentos (precedentes + causas + qualificadoras)
fundamentos(Caso, ListaFundamentos).

% Gera explicação humanizada
explicacao(Caso, MensagensLegiveis).
```

---

## ✨ Extensões

1. **Conflito de Precedentes**: Escolher maior prioridade
2. **Vinculação Forte**: Súmula vinculante obrigatória
3. **Arrependimento Posterior**: Redução 1/3 a 2/3
4. **Temporalidade**: Precedente com data
5. **Outros Ramos**: Civil/tributário

---

## ▶️ Exemplos de Execução

```prolog
% 1) Classificação jurídica do fato
?- classificacao_juridica(c1, T).
T = furto.

?- classificacao_juridica(c3, T).
T = roubo.  % caso com violência

% 2) Consulta de precedentes aplicáveis
?- aplica_precedente(c1, insignificancia, Trib, Tese).
Trib = stf,
Tese = 'valor irrisorio e ausencia de violencia podem afastar tipicidade'.

?- aplica_precedente(c2, reincidencia_afasta, Trib, Tese).
Trib = stj,
Tese = 'reincidencia especifica afasta insignificancia como regra'.

% 3) Decisão preliminar com fundamentos
?- decisao_preliminar(c1, R, F).
R = absolver_por_insignificancia,
F = ['valor irrisorio...', confissao_espontanea, devolucao_bem].

?- decisao_preliminar(c2, R, F).
R = dosimetria(180),
F = ['reincidencia especifica afasta insignificancia...'].

?- decisao_preliminar(c4, R, F).
R = reduzir_pena_por_privilegio,
F = ['furto sem violencia...', furto_privilegiado, qualificadora(rompimento_obstaculo)].

% 4) Explicação humanizada
?- explicacao(c1, M).
M = ['classificacao do fato: furto',
     'valor irrisorio e ausencia de violencia podem afastar tipicidade',
     'confissao espontanea justifica diminuicao de pena',
     'devolucao do bem antes da sentenca favorece diminuicao'].

% 5) Verificação de regras e exceções
?- regra_insignificancia(c1).
true.

?- excecao_insignificancia(c1).
false.

?- excecao_insignificancia(c2).
true.  % reincidente

% 6) Listar todos os casos com decisão de absolvição
?- decisao_preliminar(C, absolver_por_insignificancia, _).

% 7) Verificar hierarquia de precedentes
?- precedente_aplicavel(insignificancia, T, Tese).
T = stf,  % maior prioridade
Tese = '...'.
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

1. A base de dados deve conter **pelo menos 5 casos**, **3 precedentes** e **3 tribunais** (STF, STJ, TJ)
2. Teste casos de:
   - **Insignificância** (valor irrisório + sem violência → absolvição)
   - **Furto privilegiado** (primariedade + pequeno valor → redução)
   - **Reincidência** (exceção que afasta benefícios)
   - **Qualificadoras** (rompimento de obstáculo, concurso de pessoas)
   - **Causas de diminuição** (confissão espontânea, devolução do bem)
3. Implemente **hierarquia de precedentes** (STF > STJ > TJ)
4. Use **negação como falha** (`\+`) para verificar exceções
5. Todas as decisões devem ter **fundamentos explicativos**
6. Considere casos onde **regras conflitam com exceções**
7. Implemente **dosimetria simplificada** com pena-base e reduções percentuais
8. Gere **explicações humanizadas** além dos fundamentos técnicos

