**Tema:** 🚦 Sistema de Análise de Violações de Trânsito

## 🧩 Descrição
Sistema que analisa infrações de trânsito, classifica gravidade, calcula pontos na CNH, determina penalidades e identifica reincidências.

## 🎯 Objetivos: Modelar infrações, classificar gravidade, calcular pontos, determinar penalidades, detectar reincidência

## 📂 Estrutura
**Entrada:** `entrada.txt` - Motoristas, infrações, histórico, regras
**Prolog:** `principal.pl`, `infracoes.pl`, `pontuacao.pl`, `penalidades.pl`, `reincidencia.pl`
**Saída:** `saida.txt` - Análise de infrações e penalidades

## 🧱 Tarefas
```prolog
classificacao_infracao(Infracao, Gravidade).
pontos_infracao(Infracao, Pontos).
total_pontos(Motorista, Total).
penalidade(Motorista, Penalidade).
reincidente(Motorista, TipoInfracao).
situacao_cnh(Motorista, Situacao).
```

## ✨ Extensões: Redução por curso, Agravantes, Prescrição, Recurso, Suspensão progressiva

## ▶️ Exemplos
```prolog
?- total_pontos(motorista1, P).
?- penalidade(motorista1, Pen).
?- situacao_cnh(motorista1, S).
```

## 📊 Critérios de Avaliação

- **Corretude das regras** (30%): Implementação correta das restrições
- **Derivação lógica** (15%): Uso adequado de backtracking e busca
- **Explicabilidade** (20%): Justificativas claras e completas
- **Extensão implementada** (15%): Implementação correta de pelo menos uma extensão
- **Organização do código** (10%): Modularização e clareza
- **Documentação** (10%): Comentários e exemplos

## 📝 Observações: Base com 5+ motoristas, 15+ infrações, 4+ tipos de gravidade

