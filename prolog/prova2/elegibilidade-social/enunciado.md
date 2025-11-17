**Tema:** 🏘️ Sistema de Elegibilidade para Benefícios Sociais

## 🧩 Descrição
Sistema que avalia elegibilidade de famílias para benefícios sociais baseado em renda per capita, composição familiar, categorias sociais (idoso, desempregado, estudante) e situações especiais.

## 🎯 Objetivos
- Modelar famílias e composição
- Calcular renda per capita e ajustada
- Inferir categorias sociais
- Avaliar elegibilidade para benefícios
- Gerar explicações

## 📂 Estrutura
**Entrada:** `entrada.txt` - Famílias, membros, rendas, atributos
**Prolog:** `principal.pl`, `familias.pl`, `categorias.pl`, `beneficios.pl`, `explicacao.pl`
**Saída:** `saida.txt` - Elegibilidade e justificativas

## 🧱 Tarefas
```prolog
renda_per_capita(Familia, RPC).
renda_per_capita_ajustada(Familia, RPCA).
categoria_de(Pessoa, Categoria).
categoria_mais_alta(Pessoa, Cat).
tem_direito(Pessoa, Beneficio).
elegibilidade(Pessoa, Beneficios, Fundamentacao).
```

## ✨ Extensões
1. Múltiplos benefícios acumuláveis
2. Priorização por vulnerabilidade
3. Simulação de mudança de renda
4. Benefícios temporários
5. Auditoria de elegibilidade

## ▶️ Exemplos
```prolog
?- renda_per_capita(f1, RPC).
?- tem_direito(ana, bolsa_basica).
?- elegibilidade(joao, B, F).
```

## 📊 Critérios de Avaliação

- **Corretude das regras** (30%): Implementação correta das restrições
- **Derivação lógica** (15%): Uso adequado de backtracking e busca
- **Explicabilidade** (20%): Justificativas claras e completas
- **Extensão implementada** (15%): Implementação correta de pelo menos uma extensão
- **Organização do código** (10%): Modularização e clareza
- **Documentação** (10%): Comentários e exemplos

## 📝 Observações
- Base: 4+ famílias, 12+ pessoas, 3+ benefícios
- Teste: renda baixa/média/alta, categorias, dependentes

