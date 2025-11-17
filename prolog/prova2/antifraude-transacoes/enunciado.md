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
```prolog
% Hierarquia de classes (já definida na base de fatos)
% herda(Filho, Pai).

% Herança transitiva
herda_trans(F, P) :- herda(F, P).
herda_trans(F, Avo) :- herda(F, P), herda_trans(P, Avo).

% Verificação de instância com herança
instancia_de(Entidade, Classe) :-
    instancia(Entidade, ClasseDireta),
    (ClasseDireta = Classe ; herda_trans(ClasseDireta, Classe)).
```

### 2. Sinais de Risco

#### Utilitários
```prolog
% Diferença absoluta
absdiff(A, B, D) :- (A >= B -> D is A - B ; D is B - A).

% Conta transações em intervalo de tempo
conta_transacoes_intervalo(Cliente, TAtual, JanelaMin, N) :-
    findall(T,
        (trans_hist(Cliente, _, _, _, T, _, _, _),
         minutos_entre(TAtual, T, Delta),
         Delta =< JanelaMin, Delta >= 0),
        Lista),
    length(Lista, N).

% Cálculo simplificado de minutos entre timestamps
minutos_entre(t(Y1,M1,D1,H1,Min1), t(Y2,M2,D2,H2,Min2), Delta) :-
    % Simplificação: considera só H e Min do mesmo dia
    (Y1=Y2, M1=M2, D1=D2 ->
        Delta is abs((H1*60+Min1)-(H2*60+Min2))
    ;   Delta = 9999).
```

#### Sinais Positivos (Aumentam Risco)
```prolog
% 1️⃣ Valor muito acima do perfil do cliente
sinal(ID, valor_acima_perfil, 25) :-
    transacao(ID, Cliente, _, Valor, _, _, _, _, _, _, _),
    gasto_medio(Cliente, Med),
    Valor >= Med * 3.

% 2️⃣ País de alto risco
sinal(ID, pais_alto_risco, 20) :-
    transacao(ID, _, _, _, _, Pais, _, _, _, _, _),
    pais_de_alto_risco(Pais).

% 3️⃣ MCC sensível
sinal(ID, mcc_sensivel, 10) :-
    transacao(ID, _, _, _, _, _, MCC, _, _, _, _),
    mcc_sensivel(MCC).

% 4️⃣ Geovelocidade impossível (mudança brusca de país em < 2h)
sinal(ID, geovelocidade_improvavel, 25) :-
    transacao(ID, Cliente, _, _, _, PaisTx, _, t(Y,M,D,H,Min), _, _, _),
    ultima_localizacao(Cliente, PaisUlt, t(Yu,Mu,Du,Hu,Minu)),
    PaisTx \= PaisUlt,
    minutos_entre(t(Y,M,D,H,Min), t(Yu,Mu,Du,Hu,Minu), Delta),
    Delta =< 120.

% 5️⃣ IP em blacklist
sinal(ID, ip_blacklist, 30) :-
    transacao(ID, _, _, _, _, _, _, _, _, IP, _),
    blacklist_ip(IP).

% 6️⃣ Dispositivo em blacklist
sinal(ID, dispositivo_blacklist, 30) :-
    transacao(ID, Cliente, _, _, _, _, _, _, Dispositivo, _, _),
    blacklist_dispositivo(Dispositivo),
    \+ usa_dispositivo(Cliente, Dispositivo). % se não é o device habitual, pior

% 7️⃣ Cartão em blacklist
sinal(ID, cartao_blacklist, 40) :-
    transacao(ID, _, _, _, _, _, _, _, _, _, Cartao),
    blacklist_cartao(Cartao).

% 8️⃣ Velocidade: muitas transações do mesmo cliente em 30 min (>=3)
sinal(ID, alta_velocidade_cliente, 15) :-
    transacao(ID, Cliente, _, _, _, _, _, TAtual, _, _, _),
    conta_transacoes_intervalo(Cliente, TAtual, 30, N),
    N >= 3.

% 9️⃣ Horário sensível
sinal(ID, horario_sensivel, 5) :-
    transacao(ID, _, _, _, _, _, _, t(_,_,_,H,_), _, _, _),
    horario_sensivel(H).

% 🔟 Chargeback prévio do cliente
sinal(ID, risco_chargeback_previo, 20) :-
    transacao(ID, Cliente, _, _, _, _, _, _, _, _, _),
    teve_chargeback(Cliente).

% 1️⃣1️⃣ KYC insuficiente para valor alto (>= 1000 BRL e KYC < 2)
sinal(ID, kyc_insuficiente_para_valor, 15) :-
    transacao(ID, Cliente, _, Valor, brl, _, _, _, _, _, _),
    Valor >= 1000,
    kyc_nivel(Cliente, N), N < 2.
```

#### Sinais Negativos (Reduzem Risco)
```prolog
% 1️⃣2️⃣ Dispositivo habitual + país consistente com histórico recente
sinal_neg(ID, dispositivo_e_pais_habituais, -10) :-
    transacao(ID, Cliente, _, _, _, Pais, _, _, Dispositivo, _, _),
    usa_dispositivo(Cliente, Dispositivo),
    ultima_localizacao(Cliente, Pais, _).

% 1️⃣3️⃣ Valor dentro de 20% do perfil médio
sinal_neg(ID, valor_dentro_perfil, -5) :-
    transacao(ID, Cliente, _, Valor, _, _, _, _, _, _, _),
    gasto_medio(Cliente, Med),
    absdiff(Valor, Med, D),
    D =< Med * 0.2.
```

### 3. Pontuação e Decisão

```prolog
% Agrega todos os sinais positivos e negativos
sinais_ativos(ID, Sinais) :-
    findall((Lbl, P), sinal(ID, Lbl, P), Pos),
    findall((Lbl, P), sinal_neg(ID, Lbl, P), Neg),
    append(Pos, Neg, Sinais).

% Calcula pontuação total (soma dos pesos)
pontuacao_transacao(ID, Score, Evidencias) :-
    sinais_ativos(ID, Sinais),
    findall(P, member((_, P), Sinais), Ps),
    sum_list(Ps, Score),
    Evidencias = Sinais).

% Limiares de decisão (ajustáveis)
limiar_aprovar(0).         % qualquer Score < 30 aprova
limiar_revisar(30).        % 30 <= Score < 60 revisa
limiar_recusar(60).        % Score >= 60 recusa

% Decisão baseada em limiares
decisao(ID, aprovar) :-
    pontuacao_transacao(ID, S, _),
    limiar_revisar(Lr),
    S < Lr.

decisao(ID, revisar) :-
    pontuacao_transacao(ID, S, _),
    limiar_revisar(Lr), limiar_recusar(Ld),
    S >= Lr, S < Ld.

decisao(ID, recusar) :-
    pontuacao_transacao(ID, S, _),
    limiar_recusar(Ld),
    S >= Ld.
```

### 4. Explicabilidade

```prolog
% Rótulos legíveis para sinais
rotulo(valor_acima_perfil,           'valor muito acima do perfil do cliente').
rotulo(pais_alto_risco,              'país de alto risco').
rotulo(mcc_sensivel,                 'MCC sensível').
rotulo(geovelocidade_improvavel,     'geovelocidade improvável (<2h entre países)').
rotulo(ip_blacklist,                 'IP em blacklist').
rotulo(dispositivo_blacklist,        'dispositivo em blacklist').
rotulo(cartao_blacklist,             'cartão em blacklist').
rotulo(alta_velocidade_cliente,      'muitas transações em curta janela').
rotulo(horario_sensivel,             'horário sensível').
rotulo(risco_chargeback_previo,      'cliente com chargeback prévio').
rotulo(kyc_insuficiente_para_valor,  'KYC insuficiente para o valor').
rotulo(dispositivo_e_pais_habituais, 'dispositivo e país habituais').
rotulo(valor_dentro_perfil,          'valor dentro do perfil médio').

% Gera lista de motivos humanizados
motivo(ID, ListaHuman) :-
    sinais_ativos(ID, Sinais),
    findall(Texto,
        (member((Lbl, _), Sinais),
         rotulo(Lbl, R),
         atom_string(R, Texto)),
        ListaHuman).
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

