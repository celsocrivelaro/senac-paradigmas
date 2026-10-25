**Tema:** 💳 Sistema Antifraude para Transações Financeiras

---

## 🎯 Objetivo

Modelar, em **Prolog**, um motor antifraude que:

1. Representa uma **ontologia de entidades** (cliente, comerciante, dispositivo, IP, país, cartão) e **transações**
2. Gera **sinais de risco** a partir de regras:
   - Blacklists (IP, dispositivo, cartão)
   - País de alto risco
   - Geovelocidade (mudança impossível de localização)
   - Valor fora do perfil do cliente
   - MCC sensível (categoria de comerciante)
   - Velocidade de transações
   - Horário sensível
3. **Pontua** a transação somando pesos dos sinais (positivos e negativos)
4. Emite **decisão** (aprovar, revisar, recusar) segundo limiares configuráveis
5. Produz **explicações** com as evidências acionadas

Consultas esperadas:

```prolog
pontuacao_transacao(tx1001, Score, Evidencias).
decisao(tx1001, Acao).
motivo(tx1001, MotivosHumanos).
sinais_ativos(tx1001, Lista).
```

---

## 🧩 Descrição do Problema

Você é um **analista de risco** responsável por avaliar transações financeiras em tempo real.

Cada transação envolve um cliente, comerciante, valor, país, dispositivo, IP e cartão. O sistema deve identificar padrões suspeitos e decidir se a transação deve ser aprovada, revisada manualmente ou recusada.

Implemente um sistema lógico que:
- Modele entidades e suas relações (ontologia)
- Aplique regras de detecção de fraude
- Agregue sinais de risco com pesos configuráveis
- Tome decisões baseadas em limiares
- Explique de forma clara os motivos da decisão

---

## 🎯 Objetivos de Aprendizagem

- Modelar ontologias e hierarquias de classes em Prolog
- Implementar regras dedutivas para detecção de padrões
- Combinar e agregar evidências para scoring
- Criar sistema de decisão multicritério
- Implementar raciocínio temporal simplificado
- Gerar explicações legíveis automaticamente

---

## 🧩 Base de Fatos (Ontologia + Dados de Exemplo)

### Ontologia
```prolog
% =========================
% ONTOLOGIA
% =========================
classe(entidade).
classe(pessoa).          herda(pessoa, entidade).
classe(empresa).         herda(empresa, entidade).
classe(cliente).         herda(cliente, pessoa).
classe(comerciante).     herda(comerciante, empresa).
classe(dispositivo).     herda(dispositivo, entidade).
classe(ipaddr).          herda(ipaddr, entidade).
classe(pais).            herda(pais, entidade).
classe(cartao).          herda(cartao, entidade).

% Herança transitiva
herda_trans(F, P) :- herda(F, P).
herda_trans(F, Avo) :- herda(F, P), herda_trans(P, Avo).
```

### Entidades
```prolog
% =========================
% ENTIDADES
% =========================
instancia(cli_ana, cliente).
instancia(cli_beto, cliente).
instancia(mer_eletron, comerciante).
instancia(mer_games,  comerciante).

instancia(dev_a1,  dispositivo).
instancia(dev_b1,  dispositivo).
instancia(ip_x,    ipaddr).
instancia(ip_y,    ipaddr).

instancia(brasil,  pais).
instancia(eua,     pais).
instancia(russia,  pais).

instancia(cartao_ana, cartao).
instancia(cartao_beto, cartao).
```

### Atributos e Perfis
```prolog
% =========================
% ATRIBUTOS / PERFIS
% =========================
% Perfil médio de gasto do cliente (em BRL)
gasto_medio(cli_ana, 300).
gasto_medio(cli_beto, 120).

% Nível KYC/AML do cliente (1 baixo, 3 alto)
kyc_nivel(cli_ana, 3).
kyc_nivel(cli_beto, 1).

% MCCs sensíveis (eletrônicos, gift cards, jogos etc.)
mcc_sensivel(eletronicos).
mcc_sensivel(games).

% Países de alto risco
pais_de_alto_risco(russia).

% Chargebacks prévios
teve_chargeback(cli_beto).

% Relacionamento cliente-dispositivo
usa_dispositivo(cli_ana, dev_a1).
usa_dispositivo(cli_beto, dev_b1).

% Último visto do cliente (para geovelocidade)
ultima_localizacao(cli_ana, brasil, t(2025,11,08,20,00)). % ontem 20:00
ultima_localizacao(cli_beto, brasil, t(2025,11,09,01,15)). % hoje 01:15

% Listas negras
blacklist_ip(ip_y).
blacklist_cartao(cartao_beto).
blacklist_dispositivo(dev_b1).

% Janela "horário sensível" (ex.: madrugada)
horario_sensivel(H) :- H < 6 ; H >= 23.
```

### Histórico e Transações
```prolog
% =========================
% HISTÓRICO (para velocidade)
% trans_hist(Cliente, Valor, Pais, MCC, Tempo, Dispositivo, IP, Cartao)
% =========================
trans_hist(cli_ana, 200, brasil, eletronicos, t(2025,11,08,19,50), dev_a1, ip_x, cartao_ana).
trans_hist(cli_ana, 350, brasil, eletronicos, t(2025,11,08,20,10), dev_a1, ip_x, cartao_ana).
trans_hist(cli_beto, 90,  brasil, games,       t(2025,11,09,01,10), dev_b1, ip_y, cartao_beto).

% =========================
% TRANSACOES CORRENTES (a avaliar)
% transacao(ID, Cliente, Comerciante, Valor, Moeda, Pais, MCC, Tempo, Dispositivo, IP, Cartao)
% =========================
transacao(tx1001, cli_ana, mer_eletron, 2500, brl, eua, eletronicos,
          t(2025,11,09,01,30), dev_a1, ip_x, cartao_ana).
transacao(tx2002, cli_beto, mer_games, 400, brl, russia, games,
          t(2025,11,09,01,35), dev_b1, ip_y, cartao_beto).
```

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

#### 1.1. `herda_trans/2` - Herança Transitiva
```prolog
% ============================================
% HERDA_TRANS/2
% ============================================
% Descrição: Implementa herança transitiva na hierarquia de classes, permitindo
%            verificar relações de herança diretas e indiretas.
%
% Parâmetros:
%   - F: átomo representando a classe filha
%   - P: átomo representando a classe pai/ancestral
%
% Comportamento:
%   - Caso base: herança direta (F herda de P)
%   - Caso recursivo: herança transitiva (F herda de P que herda de Avo)
%   - Permite navegar por toda a hierarquia
%   - Usa recursão para subir na árvore de herança
%
% Hierarquia de exemplo:
%   transacao → transacao_online → transacao_internacional
%   transacao → transacao_presencial
%
% Exemplos de uso:
%   ?- herda_trans(transacao_internacional, transacao_online).
%   true.  % herança direta
%
%   ?- herda_trans(transacao_internacional, transacao).
%   true.  % herança transitiva
%
herda_trans(F, P).
```

#### 1.2. `instancia_de/2` - Verificação de Instância com Herança
```prolog
% ============================================
% INSTANCIA_DE/2
% ============================================
% Descrição: Verifica se uma entidade é instância de uma classe, considerando
%            herança. Uma entidade é instância de uma classe se for instância
%            direta ou se sua classe herdar da classe especificada.
%
% Parâmetros:
%   - Entidade: átomo identificando a entidade (ex: tx1, tx2)
%   - Classe: átomo representando a classe
%
% Comportamento:
%   - Obtém a classe direta da entidade
%   - Verifica se:
%     * Classe direta = Classe especificada (instância direta), OU
%     * Classe direta herda da Classe especificada (herança transitiva)
%   - Usa disjunção (;) para ambos os casos
%
% Exemplos de uso:
%   ?- instancia_de(tx1, transacao_internacional).
%   true.  % instância direta
%
%   ?- instancia_de(tx1, transacao_online).
%   true.  % via herança (transacao_internacional herda de transacao_online)
%
%   ?- instancia_de(tx1, transacao).
%   true.  % via herança transitiva
%
instancia_de(Entidade, Classe).
```

### 2. Sinais de Risco

#### 2.1. Predicados Utilitários

##### 2.1.1. `absdiff/3` - Diferença Absoluta
```prolog
% ============================================
% ABSDIFF/3
% ============================================
% Descrição: Calcula a diferença absoluta entre dois números.
%
% Parâmetros:
%   - A: número
%   - B: número
%   - D: diferença absoluta |A - B| (saída)
%
% Comportamento:
%   - Se A >= B: D = A - B
%   - Se A < B: D = B - A
%   - Sempre retorna valor positivo
%
% Exemplos de uso:
%   ?- absdiff(10, 5, D).
%   D = 5.
%
%   ?- absdiff(5, 10, D).
%   D = 5.
%
absdiff(A, B, D).
```

##### 2.1.2. `conta_transacoes_intervalo/4` - Contagem de Transações em Janela Temporal
```prolog
% ============================================
% CONTA_TRANSACOES_INTERVALO/4
% ============================================
% Descrição: Conta quantas transações um cliente realizou em uma janela de tempo
%            específica antes de um timestamp atual. Usado para detectar velocidade
%            anormal de transações.
%
% Parâmetros:
%   - Cliente: átomo identificando o cliente
%   - TAtual: termo t(Y,M,D,H,Min) representando timestamp atual
%   - JanelaMin: número inteiro representando janela em minutos
%   - N: número inteiro com a contagem de transações (saída)
%
% Comportamento:
%   - Busca todas as transações históricas do cliente
%   - Calcula diferença de tempo entre TAtual e cada transação
%   - Filtra transações dentro da janela (Delta <= JanelaMin e Delta >= 0)
%   - Conta quantas transações passaram no filtro
%   - Usa findall/3 e length/2
%
% Uso para detecção de fraude:
%   - Muitas transações em curto período é suspeito
%   - Janelas típicas: 30 min, 60 min, 24h
%
% Exemplos de uso:
%   ?- conta_transacoes_intervalo(c1, t(2024,1,15,14,30), 30, N).
%   N = 3.  % 3 transações nos últimos 30 minutos
%
conta_transacoes_intervalo(Cliente, TAtual, JanelaMin, N).
```

##### 2.1.3. `minutos_entre/3` - Cálculo de Diferença Temporal
```prolog
% ============================================
% MINUTOS_ENTRE/3
% ============================================
% Descrição: Calcula a diferença em minutos entre dois timestamps. Implementação
%            simplificada que funciona apenas para o mesmo dia (didática).
%
% Parâmetros:
%   - T1: termo t(Y1,M1,D1,H1,Min1) representando primeiro timestamp
%   - T2: termo t(Y2,M2,D2,H2,Min2) representando segundo timestamp
%   - Delta: número inteiro representando diferença em minutos (saída)
%
% Comportamento:
%   - Se mesmo dia (Y1=Y2, M1=M2, D1=D2):
%     * Converte ambos para minutos desde meia-noite
%     * Calcula diferença absoluta
%   - Se dias diferentes:
%     * Retorna 9999 (valor sentinela indicando dias diferentes)
%   - Simplificação didática (não calcula diferença real entre dias)
%
% Limitações:
%   - Não funciona corretamente para dias diferentes
%   - Não considera fusos horários
%   - Adequado para detecção de padrões no mesmo dia
%
% Exemplos de uso:
%   ?- minutos_entre(t(2024,1,15,14,30), t(2024,1,15,14,0), D).
%   D = 30.  % 30 minutos de diferença
%
%   ?- minutos_entre(t(2024,1,15,14,0), t(2024,1,16,14,0), D).
%   D = 9999.  % dias diferentes
%
minutos_entre(T1, T2, Delta).
```

#### 2.2. `sinal/3` - Sinais Positivos (Aumentam Risco)
```prolog
% ============================================
% SINAL/3
% ============================================
% Descrição: Identifica sinais de risco (positivos) em uma transação. Cada sinal
%            contribui com um peso positivo para o score de risco. Múltiplos sinais
%            podem ser aplicáveis a uma mesma transação.
%
% Parâmetros:
%   - ID: átomo identificando a transação
%   - Label: átomo identificando o tipo de sinal
%   - Peso: número inteiro representando o impacto no score (positivo = risco)
%
% Comportamento:
%   - Cada cláusula representa um sinal diferente
%   - Sinais são independentes (podem coexistir)
%   - Pesos são somados para calcular score final
%   - Usa backtracking para retornar todos os sinais aplicáveis
%
% Sinais Implementados (11 sinais):
%
%   1. **valor_acima_perfil** (+25): Valor >= 3x gasto médio do cliente
%   2. **pais_alto_risco** (+20): País em lista de alto risco
%   3. **mcc_sensivel** (+10): MCC (categoria de comerciante) sensível
%   4. **geovelocidade_improvavel** (+25): Mudança de país em < 2h
%   5. **ip_blacklist** (+30): IP em lista negra
%   6. **dispositivo_blacklist** (+30): Dispositivo em lista negra (não habitual)
%   7. **cartao_blacklist** (+40): Cartão em lista negra (maior peso)
%   8. **alta_velocidade_cliente** (+15): >= 3 transações em 30 min
%   9. **horario_sensivel** (+5): Horário de madrugada (0h-6h)
%   10. **risco_chargeback_previo** (+20): Cliente com histórico de chargeback
%   11. **kyc_insuficiente_para_valor** (+15): Valor alto (>= 1000 BRL) com KYC < 2
%
% Interpretação dos pesos:
%   - 5-15: Risco baixo/moderado
%   - 20-30: Risco alto
%   - 40+: Risco crítico
%
% Exemplos de uso:
%   ?- sinal(tx1, L, P).
%   L = valor_acima_perfil, P = 25 ;
%   L = pais_alto_risco, P = 20 ;
%   L = alta_velocidade_cliente, P = 15.
%
%   ?- sinal(tx2, cartao_blacklist, P).
%   P = 40.  % verifica se sinal específico se aplica
%
sinal(ID, Label, Peso).
```

#### 2.3. `sinal_neg/3` - Sinais Negativos (Reduzem Risco)
```prolog
% ============================================
% SINAL_NEG/3
% ============================================
% Descrição: Identifica sinais de confiança (negativos) em uma transação. Cada sinal
%            contribui com um peso negativo para o score, reduzindo o risco total.
%
% Parâmetros:
%   - ID: átomo identificando a transação
%   - Label: átomo identificando o tipo de sinal
%   - Peso: número inteiro representando o impacto no score (negativo = confiança)
%
% Comportamento:
%   - Cada cláusula representa um sinal de confiança
%   - Pesos negativos reduzem o score de risco
%   - Podem compensar sinais positivos
%
% Sinais Implementados (2 sinais):
%
%   1. **dispositivo_e_pais_habituais** (-10): Dispositivo conhecido E país consistente
%   2. **valor_dentro_perfil** (-5): Valor dentro de 20% do gasto médio
%
% Uso:
%   - Balanceia sinais de risco
%   - Reconhece comportamento normal do cliente
%   - Reduz falsos positivos
%
% Exemplos de uso:
%   ?- sinal_neg(tx1, L, P).
%   L = dispositivo_e_pais_habituais, P = -10 ;
%   L = valor_dentro_perfil, P = -5.
%
sinal_neg(ID, Label, Peso).
```

### 3. Pontuação e Decisão

#### 3.1. `sinais_ativos/2` - Agregação de Sinais
```prolog
% ============================================
% SINAIS_ATIVOS/2
% ============================================
% Descrição: Agrega todos os sinais (positivos e negativos) aplicáveis a uma
%            transação, retornando uma lista unificada.
%
% Parâmetros:
%   - ID: átomo identificando a transação
%   - Sinais: lista de pares (Label, Peso) com todos os sinais
%
% Comportamento:
%   - Coleta todos os sinais positivos (sinal/3)
%   - Coleta todos os sinais negativos (sinal_neg/3)
%   - Concatena ambas as listas com append/3
%   - Retorna lista unificada
%
% Exemplos de uso:
%   ?- sinais_ativos(tx1, S).
%   S = [(valor_acima_perfil, 25), (pais_alto_risco, 20), (valor_dentro_perfil, -5)].
%
sinais_ativos(ID, Sinais).
```

#### 3.2. `pontuacao_transacao/3` - Cálculo de Score
```prolog
% ============================================
% PONTUACAO_TRANSACAO/3
% ============================================
% Descrição: Calcula o score total de risco de uma transação somando os pesos de
%            todos os sinais aplicáveis. Retorna também as evidências.
%
% Parâmetros:
%   - ID: átomo identificando a transação
%   - Score: número inteiro representando o score total (saída)
%   - Evidencias: lista de pares (Label, Peso) usados no cálculo (saída)
%
% Comportamento:
%   - Coleta todos os sinais ativos
%   - Extrai apenas os pesos
%   - Soma todos os pesos usando sum_list/2
%   - Retorna score e evidências
%
% Interpretação do score:
%   - Score < 30: Baixo risco (aprovar)
%   - Score 30-59: Risco moderado (revisar)
%   - Score >= 60: Alto risco (recusar)
%
% Exemplos de uso:
%   ?- pontuacao_transacao(tx1, S, E).
%   S = 40, E = [(valor_acima_perfil, 25), (pais_alto_risco, 20), (valor_dentro_perfil, -5)].
%
pontuacao_transacao(ID, Score, Evidencias).
```

#### 3.3. Limiares de Decisão
```prolog
% ============================================
% LIMIAR_APROVAR/1, LIMIAR_REVISAR/1, LIMIAR_RECUSAR/1
% ============================================
% Descrição: Define os limiares de score para decisões antifraude.
%            Configuráveis pela instituição financeira.
%
% Parâmetros:
%   - Limiar: número inteiro representando o limiar
%
% Comportamento:
%   - limiar_aprovar(0): não usado diretamente (implícito)
%   - limiar_revisar(30): Score >= 30 requer revisão manual
%   - limiar_recusar(60): Score >= 60 resulta em recusa automática
%
limiar_aprovar(Limiar).
limiar_revisar(Limiar).
limiar_recusar(Limiar).
```

#### 3.4. `decisao/2` - Decisão Final Antifraude
```prolog
% ============================================
% DECISAO/2
% ============================================
% Descrição: Determina a decisão final sobre uma transação baseada no score de risco.
%
% Parâmetros:
%   - ID: átomo identificando a transação
%   - Decisao: átomo representando a decisão (aprovar, revisar, recusar)
%
% Comportamento:
%   - Calcula score da transação
%   - Compara com limiares:
%     * Score < 30 → aprovar (baixo risco)
%     * Score 30-59 → revisar (risco moderado, análise manual)
%     * Score >= 60 → recusar (alto risco)
%
% Exemplos de uso:
%   ?- decisao(tx1, D).
%   D = aprovar.  % score 15
%
%   ?- decisao(tx2, D).
%   D = revisar.  % score 45
%
%   ?- decisao(tx3, D).
%   D = recusar.  % score 70
%
decisao(ID, Decisao).
```

### 4. Explicabilidade

#### 4.1. `rotulo/2` - Rótulos Legíveis
```prolog
% ============================================
% ROTULO/2
% ============================================
% Descrição: Traduz códigos de sinais em mensagens legíveis para humanos.
%            Essencial para explicabilidade do sistema antifraude.
%
% Parâmetros:
%   - Codigo: átomo representando o código do sinal
%   - Mensagem: string contendo a descrição legível
%
% Comportamento:
%   - Cada código tem uma mensagem associada
%   - Usado para gerar explicações humanizadas
%   - Cobre todos os 13 sinais (11 positivos + 2 negativos)
%
% Exemplos de uso:
%   ?- rotulo(valor_acima_perfil, M).
%   M = 'valor muito acima do perfil do cliente'.
%
rotulo(Codigo, Mensagem).
```

#### 4.2. `motivo/2` - Lista de Motivos Humanizados
```prolog
% ============================================
% MOTIVO/2
% ============================================
% Descrição: Gera uma lista de motivos legíveis que explicam o score da transação,
%            traduzindo todos os sinais ativos para mensagens humanizadas.
%
% Parâmetros:
%   - ID: átomo identificando a transação
%   - ListaHuman: lista de strings contendo explicações legíveis
%
% Comportamento:
%   - Coleta todos os sinais ativos
%   - Para cada sinal, obtém o rótulo legível
%   - Converte para strings
%   - Retorna lista de mensagens
%
% Uso para explicabilidade:
%   - Permite justificar decisões para clientes
%   - Facilita auditoria e compliance
%   - Ajuda analistas em revisões manuais
%
% Exemplos de uso:
%   ?- motivo(tx1, M).
%   M = ['valor dentro do perfil médio', 'dispositivo e país habituais'].
%
%   ?- motivo(tx3, M).
%   M = ['cartão em blacklist', 'valor muito acima do perfil do cliente', 'IP em blacklist'].
%
motivo(ID, ListaHuman).
```

---

## ✨ Extensões (Escolha pelo menos UMA)

| Tema Lógico | Extensão Prática |
|-------------|------------------|
| **Ontologia Expandida** | Adicionar `proxy`, `tor`, `bin_cartao/2`, `banco_emissor/2` e regras de *bin-country mismatch* (BIN do cartão não corresponde ao país da transação). |
| **Graph Link Analysis** | Implementar `relacionado(A, B)` por dispositivo/IP/cartão compartilhado e sinal de *fraude em rede* (entidades conectadas a fraudes conhecidas). |
| **Risco Adaptativo** | Pesos diferentes por **MCC**, **país**, **comerciante** (ex.: sensibilidade dinâmica). Implementar `peso_dinamico/3` que ajusta pesos por contexto. |
| **Temporais Avançados** | *Cooldowns* por cliente/cartão, janelas deslizantes múltiplas (5, 30, 120 min). Implementar `velocidade_janela/4` para diferentes períodos. |
| **Layout de Decisão** | Implementar `acao_sugerida/2` com trilha: *bloquear cartão*, *exigir 3DS/KBA*, *contato manual*. Decisões mais granulares que aprovar/revisar/recusar. |
| **Explicabilidade Avançada** | Implementar `justifica/2` que retorna pares `(regra -> fatos_usados)` mostrando exatamente quais fatos acionaram cada regra. |
| **Feedback Loop** | Marcar `fraude_confirmada(ID)` e ajustar pesos/limiares de forma incremental. Implementar `aprender_de_feedback/0`. |

### Exemplo de Extensão: Graph Link Analysis
```prolog
% Entidades relacionadas por compartilhamento
relacionado(E1, E2) :-
    (usa_dispositivo(E1, D), usa_dispositivo(E2, D), E1 \= E2) ;
    (transacao(_, E1, _, _, _, _, _, _, _, IP, _),
     transacao(_, E2, _, _, _, _, _, _, _, IP, _), E1 \= E2) ;
    (transacao(_, E1, _, _, _, _, _, _, _, _, C),
     transacao(_, E2, _, _, _, _, _, _, _, _, C), E1 \= E2).

% Fraude em rede: cliente relacionado a outro com fraude confirmada
sinal(ID, fraude_em_rede, 35) :-
    transacao(ID, Cliente, _, _, _, _, _, _, _, _, _),
    relacionado(Cliente, OutroCliente),
    fraude_confirmada(OutroCliente).

% Exemplo de uso:
% ?- fraude_confirmada(cli_beto).  % marcar fraude conhecida
% ?- sinal(tx1001, fraude_em_rede, P).  % verificar se Ana está relacionada a Beto
```

---

## ▶️ Exemplos de Execução

```prolog
% 1) Ver sinais, pontuação e decisão para tx1001 (Ana - Eletrônicos nos EUA)
?- sinais_ativos(tx1001, S), pontuacao_transacao(tx1001, Score, _), decisao(tx1001, D), motivo(tx1001, M).
S = [(valor_acima_perfil, 25), (mcc_sensivel, 10), (horario_sensivel, 5),
     (dispositivo_e_pais_habituais, -10)],
Score = 30,
D = revisar,
M = ["valor muito acima do perfil do cliente", "MCC sensível", "horário sensível",
     "dispositivo e país habituais"].

% 2) Ver sinais, pontuação e decisão para tx2002 (Beto - Games na Rússia)
?- sinais_ativos(tx2002, S), pontuacao_transacao(tx2002, Score, _), decisao(tx2002, D), motivo(tx2002, M).
S = [(pais_alto_risco, 20), (mcc_sensivel, 10), (ip_blacklist, 30), (cartao_blacklist, 40),
     (alta_velocidade_cliente, 15), (horario_sensivel, 5), (risco_chargeback_previo, 20)],
Score = 140,
D = recusar,
M = ["país de alto risco", "MCC sensível", "IP em blacklist", "cartão em blacklist",
     "muitas transações em curta janela", "horário sensível", "cliente com chargeback prévio"].

% 3) Motivos legíveis isolados
?- motivo(tx1001, M).
M = ["valor muito acima do perfil do cliente", "MCC sensível", "horário sensível",
     "dispositivo e país habituais"].

% 4) Todas as transações recusadas
?- decisao(TX, recusar).
TX = tx2002.

% 5) Todas as transações que precisam revisão
?- decisao(TX, revisar).
TX = tx1001.

% 6) Ajustar limiares e reavaliar
?- retract(limiar_recusar(_)), assertz(limiar_recusar(80)), decisao(tx1001, D1), decisao(tx2002, D2).
D1 = revisar,
D2 = recusar.  % tx2002 continua recusada mesmo com limiar mais alto

% 7) Simular melhora de IP (remove blacklist)
?- retract(blacklist_ip(ip_y)),
   sinais_ativos(tx2002, S),
   pontuacao_transacao(tx2002, Score, _),
   decisao(tx2002, D).
S = [(pais_alto_risco, 20), (mcc_sensivel, 10), (cartao_blacklist, 40),
     (alta_velocidade_cliente, 15), (horario_sensivel, 5), (risco_chargeback_previo, 20)],
Score = 110,
D = recusar.  % ainda recusada por outros motivos

% 8) Verificar apenas sinais positivos (riscos)
?- sinal(tx2002, Lbl, P), P > 0.
Lbl = pais_alto_risco, P = 20 ;
Lbl = mcc_sensivel, P = 10 ;
Lbl = ip_blacklist, P = 30 ;
Lbl = cartao_blacklist, P = 40 ;
Lbl = alta_velocidade_cliente, P = 15 ;
Lbl = horario_sensivel, P = 5 ;
Lbl = risco_chargeback_previo, P = 20.

% 9) Verificar apenas sinais negativos (benefícios)
?- sinal_neg(tx1001, Lbl, P).
Lbl = dispositivo_e_pais_habituais, P = -10.

% 10) Listar todas as transações com suas decisões
?- transacao(ID, Cliente, _, _, _, _, _, _, _, _, _), decisao(ID, D).
ID = tx1001, Cliente = cli_ana, D = revisar ;
ID = tx2002, Cliente = cli_beto, D = recusar.

% 11) Verificar herança da ontologia
?- herda_trans(cliente, entidade).
true.

?- instancia_de(cli_ana, pessoa).
true.

?- instancia_de(cli_ana, entidade).
true.

% 12) Simular ajuste de peso de um sinal
?- retract(sinal(tx1001, valor_acima_perfil, 25)),
   assertz(sinal(tx1001, valor_acima_perfil, 10)),
   pontuacao_transacao(tx1001, Score, _),
   decisao(tx1001, D).
Score = 15,
D = aprovar.  % com peso menor, transação é aprovada
```

---

## 🧠 Conceitos Aplicados

- **Modelagem Ontológica**: Hierarquia de classes (entidade → pessoa → cliente) com herança transitiva
- **Regras Dedutivas**: Construção de sinais de risco a partir de fatos (ex.: `valor >= media * 3 → valor_acima_perfil`)
- **Combinação de Evidências**: Agregação de múltiplos sinais (positivos e negativos) em pontuação única
- **Raciocínio Temporal**: Cálculo de velocidade de transações e geovelocidade (mudança impossível de localização)
- **Negação como Falha**: Verificação de ausência em blacklists e histórico
- **Decisão Multicritério**: Limiares configuráveis para aprovar/revisar/recusar baseados em score agregado
- **Explicabilidade**: Tradução automática de regras técnicas em motivos legíveis para humanos
- **Findall e Agregação**: Coleta de todos os sinais ativos e soma de pesos

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

1. Base deve conter **pelo menos 5 clientes**, **10 transações**, **3 tipos de blacklists**
2. Teste casos de **aprovação**, **revisão** e **recusa** com transações realistas
3. Implemente **pelo menos 8 sinais positivos** e **2 sinais negativos**
4. Limiares devem ser **configuráveis** (use fatos `limiar_aprovar/1`, `limiar_revisar/1`, `limiar_recusar/1`)
5. Explicações devem ser **geradas automaticamente** a partir dos sinais ativos
6. Considere **sinais negativos** (reduzem risco) para evitar falsos positivos
7. Use **pesos realistas** (blacklists devem ter peso alto, sinais menores peso baixo)
8. Implemente **pelo menos uma extensão** da tabela de extensões sugeridas
9. Documente os **pesos e limiares** escolhidos e justifique as escolhas
10. Teste **ajustes dinâmicos** de limiares e pesos para calibrar o sistema

