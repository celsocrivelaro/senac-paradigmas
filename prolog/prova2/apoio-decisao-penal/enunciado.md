**Tema:** ⚖️ Sistema de Apoio à Decisão Penal

---

## 🧩 Descrição

Sistema que modela domínio penal (tipos penais, qualificadoras, situação fática), aplica regras com exceções, consulta precedentes com hierarquia de tribunais, e produz decisão preliminar com fundamentos.

---

## 🎯 Objetivos

- Modelar regras jurídicas com exceções
- Implementar hierarquia de precedentes
- Usar negação como falha
- Gerar decisões e fundamentos
- Calcular dosimetria de pena

---

## 📂 Estrutura

**Entrada:** `entrada.txt` - Tribunais, precedentes, casos, fatos
**Prolog:** `principal.pl`, `precedentes.pl`, `regras.pl`, `dosimetria.pl`, `decisao.pl`
**Saída:** `saida.txt` - Decisões e fundamentos

---

## 🧱 Tarefas

```prolog
precedente_aplicavel(Tema, Tribunal, Tese).
aplica_precedente(Caso, Tema, Tribunal, Tese).
classificacao_juridica(Caso, TipoPenal).
regra_insignificancia(Caso).
regra_furto_privilegiado(Caso).
decisao_preliminar(Caso, Resultado, Fundamentos).
motivo(Caso, Explicacao).
```

---

## ✨ Extensões

1. **Conflito de Precedentes**: Escolher maior prioridade
2. **Vinculação Forte**: Súmula vinculante obrigatória
3. **Arrependimento Posterior**: Redução 1/3 a 2/3
4. **Temporalidade**: Precedente com data
5. **Outros Ramos**: Civil/tributário

---

## ▶️ Exemplos

```prolog
?- classificacao_juridica(c1, T).
?- aplica_precedente(c1, insignificancia, Trib, Tese).
?- decisao_preliminar(c1, R, F).
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

- Base: 5+ casos, 3+ precedentes, 2+ tribunais
- Teste: insignificância, privilegiado, reincidência
- Explicações automáticas

