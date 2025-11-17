**Tema:** 💰 Sistema de Concessão de Crédito

---

## 🧩 Descrição do Problema

Implemente um **motor de crédito** em Prolog que avalia solicitações de empréstimo considerando:

- **Ontologia** de solicitantes, produtos, garantias e empregadores
- **Regras de política** (idade mínima, sanções, LTV máximo)
- **Métricas financeiras** (DTI, LTV, parcela estimada)
- **Sinais** positivos e negativos com pesos
- **Decisão** (aprovar/revisar/recusar) baseada em pontuação agregada
- **Explicações** detalhadas das decisões

---

## 🎯 Objetivos de Aprendizagem

- Modelar ontologias com herança em Prolog
- Implementar regras de política (hard stops) vs. scoring ponderado
- Realizar cálculos lógicos (DTI, LTV, parcela)
- Combinar evidências para decisão multicritério
- Gerar explicações automáticas
- Explorar cenários "what-if"

---

## 📂 Estrutura dos Arquivos

**Entrada:** `entrada.txt` - Ontologia, solicitantes, propostas, garantias
**Prolog:** `principal.pl`, `ontologia.pl`, `metricas.pl`, `politicas.pl`, `sinais.pl`, `decisao.pl`, `explicacao.pl`
**Saída:** `saida.txt` - Análise de propostas com decisões e justificativas

---

## 🧱 Tarefas Obrigatórias

### 1. Métricas Financeiras
```prolog
parcela(Valor, TaxaMes, Prazo, Prestacao).
dti(Solicitante, Parcela, DTI).  % Debt-to-Income
ltv(Garantia, Valor, LTV).       % Loan-to-Value
metricas(PropostaID, dti(DTI), ltv(LTV), parcela(P)).
```

### 2. Regras de Política (Hard Stops)
```prolog
hardstop(PropostaID, Motivo).
% Exemplos: idade_minima, sancao, ltv_excedido, renda_invalida
```

### 3. Sinais de Risco/Benefício
```prolog
sinal(PropostaID, TipoSinal, Peso).
% Exemplos: dti_bom(-20), dti_ruim(+30), bureau_excelente(-25),
%           atrasos_rec(+20), emprego_estavel(-10)
```

### 4. Decisão e Explicação
```prolog
pontuacao(PropostaID, Score, Evidencias).
decisao(PropostaID, Acao).  % aprovar | revisar | recusar
motivos(PropostaID, ListaExplicativa).
```

---

## ✨ Extensões (Escolha UMA)

1. **Política por Produto**: DTI/LTV e limiares distintos por tipo de crédito
2. **Risco Setorial**: Pesos por setor do empregador
3. **Garantias Múltiplas**: Soma de garantias
4. **Otimização**: Sugerir contraproposta (reduzir valor/prazo para atingir DTI alvo)
5. **Explicabilidade Avançada**: Rastro completo de decisão

---

## ▶️ Exemplos de Execução

```prolog
?- metricas(loan1, DTI, LTV, Parc).
?- sinais(loan1, S), pontuacao(loan1, Score, _), decisao(loan1, D).
?- motivos(loan1, M).
?- hardstop(loan2, H).
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

## 📝 Observações

- Base: **5+ solicitantes**, **8+ propostas**, **3+ garantias**
- Teste: aprovação, revisão, recusa, hard stops
- Implemente **8+ sinais** diferentes
- Limiares configuráveis
- Explicações automáticas

