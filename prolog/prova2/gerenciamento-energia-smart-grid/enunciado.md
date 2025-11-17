**Tema:** ⚡ Sistema de Gerenciamento Lógico de Energia (Smart Grid)

## 🧩 Descrição
Sistema de gerenciamento inteligente de energia que otimiza distribuição, balanceia carga, integra fontes renováveis e toma decisões de controle baseadas em regras lógicas.

## 🎯 Objetivos: Modelar rede elétrica, balancear carga, integrar renováveis, detectar anomalias, otimizar distribuição

## 📂 Estrutura
**Entrada:** `entrada.txt` - Subestações, consumidores, geradores, regras
**Prolog:** `principal.pl`, `rede.pl`, `balanceamento.pl`, `renovaveis.pl`, `controle.pl`
**Saída:** `saida.txt` - Decisões de controle e otimizações

## 🧱 Tarefas
```prolog
demanda_total(Regiao, Demanda).
capacidade_disponivel(Fonte, Capacidade).
balanceamento_necessario(Regiao, Acao).
fonte_prioritaria(Momento, Fonte).
decisao_controle(Situacao, Acao).
```

## ✨ Extensões: Previsão de demanda, Armazenamento em baterias, Tarifação dinâmica, Detecção de falhas, Otimização multi-objetivo

## ▶️ Exemplos
```prolog
?- balanceamento_necessario(zona_norte, A).
?- fonte_prioritaria(pico, F).
```

## 📊 Critérios de Avaliação

- **Corretude das regras** (30%): Implementação correta das restrições
- **Derivação lógica** (15%): Uso adequado de backtracking e busca
- **Explicabilidade** (20%): Justificativas claras e completas
- **Extensão implementada** (15%): Implementação correta de pelo menos uma extensão
- **Organização do código** (10%): Modularização e clareza
- **Documentação** (10%): Comentários e exemplos

## 📝 Observações: Base com 5+ regiões, 8+ consumidores, 4+ fontes de energia

