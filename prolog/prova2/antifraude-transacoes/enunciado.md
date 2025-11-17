**Tema:** 💳 Sistema Antifraude para Transações Financeiras

---

## 🧩 Descrição do Problema

Você deve implementar um **motor antifraude** em Prolog que analisa transações financeiras e detecta padrões suspeitos. O sistema deve:

- Representar uma **ontologia** de entidades (cliente, comerciante, dispositivo, IP, país, cartão)
- Gerar **sinais de risco** baseados em regras (blacklists, país de alto risco, geovelocidade, valor fora do perfil, MCC sensível)
- **Pontuar** transações somando pesos dos sinais detectados
- Emitir **decisão** (aprovar, revisar, recusar) segundo limiares configuráveis
- Produzir **explicações** detalhadas com as evidências acionadas

O sistema deve responder consultas como:
- "Qual a pontuação de risco da transação TX1001?"
- "Por que a transação TX2002 foi recusada?"
- "Quais sinais de risco foram ativados?"

---

## 🎯 Objetivos de Aprendizagem

- Modelar ontologias e hierarquias de classes em Prolog
- Implementar regras dedutivas para detecção de padrões
- Combinar e agregar evidências para scoring
- Criar sistema de decisão multicritério
- Implementar raciocínio temporal simplificado
- Gerar explicações legíveis automaticamente

---

## 📂 Estrutura dos Arquivos e Entrada-Saída

### Arquivos de Entrada
- **`entrada.txt`**: Ontologia, entidades, transações, histórico, blacklists

### Arquivos Prolog
- **`principal.pl`**: Arquivo principal
- **`ontologia.pl`**: Classes e herança
- **`sinais.pl`**: Regras de detecção de sinais de risco
- **`decisao.pl`**: Pontuação e decisão
- **`explicacao.pl`**: Geração de explicações

### Arquivo de Saída
- **`saida.txt`**: Análise de transações com pontuação e justificativas

---

## 🧱 Tarefas Obrigatórias

### 1. Ontologia e Herança
```prolog
% Hierarquia de classes
herda_trans(Filho, Ancestral).

% Verificação de instância
instancia_de(Entidade, Classe).
```

### 2. Sinais de Risco
```prolog
% Sinais positivos (aumentam risco)
sinal(TransacaoID, TipoSinal, Peso).

% Sinais negativos (reduzem risco)
sinal_neg(TransacaoID, TipoSinal, Peso).

% Exemplos de sinais:
% - valor_acima_perfil
% - pais_alto_risco
% - mcc_sensivel
% - geovelocidade_improvavel
% - ip_blacklist
% - dispositivo_blacklist
% - cartao_blacklist
% - alta_velocidade_cliente
% - horario_sensivel
```

### 3. Pontuação e Decisão
```prolog
% Agrega todos os sinais
sinais_ativos(TransacaoID, ListaSinais).

% Calcula pontuação total
pontuacao_transacao(TransacaoID, Score, Evidencias).

% Emite decisão baseada em limiares
decisao(TransacaoID, Acao).  % aprovar | revisar | recusar
```

### 4. Explicabilidade
```prolog
% Traduz sinais em texto legível
rotulo(TipoSinal, TextoExplicativo).

% Gera lista de motivos humanizados
motivo(TransacaoID, ListaMotivos).
```

---

## ✨ Extensões (Escolha pelo menos UMA)

1. **Ontologia Expandida**: Adicionar proxy, tor, bin_cartao, banco_emissor e regras de bin-country mismatch

2. **Graph Link Analysis**: Implementar relacionamento entre entidades (dispositivo/IP/cartão compartilhado) e sinal de fraude em rede

3. **Risco Adaptativo**: Pesos diferentes por MCC, país, comerciante (sensibilidade dinâmica)

4. **Temporais Avançados**: Cooldowns por cliente/cartão, janelas deslizantes múltiplas (5, 30, 120 min)

5. **Explicabilidade Avançada**: Predicado `justifica/2` que retorna pares `(regra -> fatos usados)`

---

## ▶️ Exemplos de Execução

```prolog
% Ver sinais, pontuação e decisão
?- sinais_ativos(tx1001, S), pontuacao_transacao(tx1001, Score, _), decisao(tx1001, D).

% Motivos legíveis
?- motivo(tx1001, M).

% Todas as transações recusadas
?- decisao(TX, recusar).

% Ajustar limiares e reavaliar
?- retract(limiar_recusar(_)), assertz(limiar_recusar(80)), decisao(tx1001, D).
```

---

## 🧾 Explicabilidade das Decisões

### Formato de Sinais:
```prolog
[
    (valor_acima_perfil, 25),
    (mcc_sensivel, 10),
    (horario_sensivel, 5),
    (dispositivo_e_pais_habituais, -10)
]
```

### Formato de Explicação:
```prolog
decisao_antifraude(
    transacao(tx1001),
    score(30),
    decisao(revisar),
    motivos([
        'valor muito acima do perfil do cliente',
        'MCC sensível',
        'horário sensível',
        'dispositivo e país habituais'
    ])
).
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

1. Base deve conter **pelo menos 5 clientes**, **10 transações**, **3 blacklists**
2. Teste casos de **aprovação**, **revisão** e **recusa**
3. Implemente **pelo menos 8 sinais** diferentes
4. Limiares devem ser **configuráveis**
5. Explicações devem ser **geradas automaticamente**
6. Considere **sinais negativos** (reduzem risco)

