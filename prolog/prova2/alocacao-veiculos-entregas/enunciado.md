**Tema:** 🚛 Sistema de Alocação de Veículos e Entregas

---

## 🧩 Descrição do Problema

Implemente um sistema de **planejamento lógico de entregas** onde veículos (caminhões, vans) são alocados para pedidos, respeitando:

- **Capacidade de carga** (peso em kg)
- **Tipo de veículo** (comum, refrigerado, perigoso)
- **Distância e autonomia**
- **Janelas de entrega** (turnos)
- **Disponibilidade de motorista** (licenças especiais)

O sistema deve determinar combinações válidas de `(Pedido, Veículo, Motorista, Turno)`.

---

## 🎯 Objetivos

- Modelar problemas de alocação com múltiplas restrições
- Usar backtracking para gerar soluções
- Implementar verificação de compatibilidade
- Criar explicações de falhas
- Organizar código modularmente

---

## 📂 Estrutura

**Entrada:** `entrada.txt` - Frota, motoristas, pedidos, ocupações
**Prolog:** `principal.pl`, `veiculos.pl`, `motoristas.pl`, `alocacao.pl`, `explicacao.pl`
**Saída:** `saida.txt` - Alocações e justificativas

---

## 🧱 Tarefas Obrigatórias

```prolog
veiculo_adequado(Veiculo, Pedido).
motorista_adequado(Motorista, Pedido, Turno).
veiculo_disponivel(Veiculo, Turno).
motorista_disponivel(Motorista, Turno).
turno_valido(Pedido, Turno).
alocacao_valida(Pedido, Veiculo, Motorista, Turno).
motivo_falha(Pedido, Motivo).
```

---

## ✨ Extensões (Escolha UMA)

1. **Múltiplos Pedidos**: Permitir vários pedidos no mesmo veículo até limite de carga
2. **Otimização**: Minimizar km percorridos
3. **Janelas Temporais**: Turnos parciais (manha1, manha2)
4. **Hierarquia de Licenças**: Licença superior cobre inferior
5. **Simulação Dinâmica**: Atualizar ocupações com assertz

---

## ▶️ Exemplos

```prolog
?- alocacao_valida(Pedido, Veiculo, Motorista, Turno).
?- alocacao_valida(p5, V, M, tarde).
?- pedido(P,_,_,_,_), \+ alocacao_valida(P,_,_,_).
?- motivo_falha(p3, Motivo).
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

- Base: 5+ veículos, 4+ motoristas, 6+ pedidos
- Teste: capacidade, tipo, licença, disponibilidade
- Explicações automáticas de falhas

