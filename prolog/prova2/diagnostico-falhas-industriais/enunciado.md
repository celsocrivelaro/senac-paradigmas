**Tema:** 🏭 Sistema de Diagnóstico de Falhas Industriais

## 🧩 Descrição
Sistema especialista para diagnosticar falhas em equipamentos industriais baseado em sintomas observados, histórico de manutenção, sensores e regras de inferência.

## 🎯 Objetivos
- Modelar equipamentos e componentes
- Inferir falhas a partir de sintomas
- Considerar histórico e contexto
- Sugerir ações corretivas
- Explicar diagnóstico

## 📂 Estrutura
**Entrada:** `entrada.txt` - Equipamentos, sintomas, regras, histórico
**Prolog:** `principal.pl`, `equipamentos.pl`, `sintomas.pl`, `diagnostico.pl`, `acoes.pl`
**Saída:** `saida.txt` - Diagnósticos e recomendações

## 🧱 Tarefas
```prolog
sintoma_presente(Equipamento, Sintoma).
falha_possivel(Equipamento, Falha, Confianca).
diagnostico(Equipamento, Falha, Evidencias).
acao_corretiva(Falha, Acao).
explicacao_diagnostico(Equipamento, Explicacao).
```

## ✨ Extensões
1. Diagnóstico probabilístico
2. Múltiplas falhas simultâneas
3. Priorização por criticidade
4. Histórico de falhas recorrentes
5. Manutenção preditiva

## ▶️ Exemplos
```prolog
?- diagnostico(motor1, F, E).
?- acao_corretiva(superaquecimento, A).
```

## 📊 Critérios de Avaliação

- **Corretude das regras** (30%): Implementação correta das restrições
- **Derivação lógica** (15%): Uso adequado de backtracking e busca
- **Explicabilidade** (20%): Justificativas claras e completas
- **Extensão implementada** (15%): Implementação correta de pelo menos uma extensão
- **Organização do código** (10%): Modularização e clareza
- **Documentação** (10%): Comentários e exemplos

## 📝 Observações
- Base: 5+ equipamentos, 10+ sintomas, 8+ falhas
- Teste: diagnósticos simples e complexos

