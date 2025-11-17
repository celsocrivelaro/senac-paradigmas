**Tema:** 🏥 Ontologia e Raciocínio Clínico Hospitalar

## 🧩 Descrição
Sistema de raciocínio clínico que modela pacientes, sintomas, doenças, exames e tratamentos, inferindo diagnósticos possíveis e sugerindo condutas.

## 🎯 Objetivos: Modelar ontologia médica, inferir diagnósticos, considerar comorbidades, sugerir exames/tratamentos, explicar raciocínio

## 📂 Estrutura
**Entrada:** `entrada.txt` - Pacientes, sintomas, doenças, regras
**Prolog:** `principal.pl`, `ontologia.pl`, `sintomas.pl`, `diagnostico.pl`, `tratamento.pl`
**Saída:** `saida.txt` - Diagnósticos e condutas

## 🧱 Tarefas
```prolog
sintoma_paciente(Paciente, Sintoma).
doenca_possivel(Paciente, Doenca, Probabilidade).
exame_recomendado(Paciente, Exame).
tratamento_sugerido(Doenca, Tratamento).
diagnostico_diferencial(Paciente, ListaDoencas).
```

## ✨ Extensões: Diagnóstico probabilístico, Interações medicamentosas, Contraindicações, Urgência/triagem, Histórico familiar

## ▶️ Exemplos
```prolog
?- diagnostico_diferencial(paciente1, D).
?- exame_recomendado(paciente1, E).
```

## 📊 Critérios de Avaliação

- **Corretude das regras** (30%): Implementação correta das restrições
- **Derivação lógica** (15%): Uso adequado de backtracking e busca
- **Explicabilidade** (20%): Justificativas claras e completas
- **Extensão implementada** (15%): Implementação correta de pelo menos uma extensão
- **Organização do código** (10%): Modularização e clareza
- **Documentação** (10%): Comentários e exemplos

## 📝 Observações: Base com 5+ pacientes, 15+ sintomas, 8+ doenças

