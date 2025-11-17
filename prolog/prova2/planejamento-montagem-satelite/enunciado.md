**Tema:** 🛰️ Planejamento de Montagem de Satélite

## 🧩 Descrição
Sistema de planejamento que determina sequência de montagem de componentes de satélite respeitando dependências, recursos, equipes especializadas e janelas temporais.

## 🎯 Objetivos: Modelar dependências, planejar sequência, alocar recursos, verificar restrições, gerar cronograma

## 📂 Estrutura
**Entrada:** `entrada.txt` - Componentes, dependências, equipes, recursos
**Prolog:** `principal.pl`, `componentes.pl`, `dependencias.pl`, `planejamento.pl`, `recursos.pl`
**Saída:** `saida.txt` - Sequência de montagem e alocações

## 🧱 Tarefas
```prolog
dependencia(Componente, Prerequisito).
pode_montar(Componente, Momento).
sequencia_valida(ListaComponentes).
alocar_equipe(Componente, Equipe).
cronograma(ListaTarefas).
```

## ✨ Extensões: Otimização de tempo, Paralelização, Recursos limitados, Contingências, Caminho crítico

## ▶️ Exemplos
```prolog
?- sequencia_valida(S).
?- cronograma(C).
```

## 📊 Critérios de Avaliação

- **Corretude das regras** (30%): Implementação correta das restrições
- **Derivação lógica** (15%): Uso adequado de backtracking e busca
- **Explicabilidade** (20%): Justificativas claras e completas
- **Extensão implementada** (15%): Implementação correta de pelo menos uma extensão
- **Organização do código** (10%): Modularização e clareza
- **Documentação** (10%): Comentários e exemplos

## 📝 Observações: Base com 10+ componentes, 8+ dependências, 3+ equipes

