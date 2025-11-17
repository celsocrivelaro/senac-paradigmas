**Tema:** 🚦 Sistema de Análise de Violações de Trânsito

---

## 🎯 Objetivo

Em **Prolog (padrão)**, construir um sistema que:

1. Modela **veículos**, **categorias**, **sinalizações** e **segmentos viários** (inclusive horários)
2. Deduz **infrações** a partir de **tipo de veículo + sinalização + horário**
3. Implementa **exceções** para **veículos de emergência em atendimento** (com limites de segurança)
4. Usa **negação como falha** (\+) para assumir "sem restrição" quando não há sinalização aplicável
5. Gera **explicações** (motivos) por violação ou não violação

Consultas esperadas:

```prolog
violacao(EventoID, TipoInfracao, Motivos).
nao_violacao(EventoID, Motivos).
limite_efetivo(Segmento, Tempo, Limite).
violacoes_evento(EventoID, Lista).
explicacao((Tipo, Motivos), Texto).
```

---

## 🧩 Descrição do Problema

### 🚦 Contexto e Motivação

Você é o **engenheiro de sistemas** responsável por implementar um **sistema inteligente de fiscalização de trânsito** para uma cidade inteligente (smart city).

**O Problema Real:**

Sistemas modernos de fiscalização de trânsito capturam milhares de eventos diariamente através de câmeras, radares e sensores. Cada evento precisa ser analisado para determinar se constitui uma infração, considerando:

1. **Contexto Temporal**: Uma zona escolar tem limite de 40 km/h das 7h às 19h, mas 60 km/h fora desse horário. Faixas exclusivas de ônibus são ativas apenas no horário de pico (17h-20h). Estacionamento pode ser proibido apenas em horário comercial.

2. **Categorias de Veículos**: Carros particulares, motos, ônibus, táxis, caminhões de frete e veículos de emergência têm regras diferentes. Um ônibus pode usar a faixa exclusiva, mas um carro não. Um táxi pode ter permissão especial dependendo da política municipal.

3. **Exceções com Limites de Segurança**: Veículos de emergência (ambulâncias, bombeiros, polícia) em atendimento podem:
   - Exceder o limite de velocidade em até 30%
   - Cruzar sinais vermelhos, mas apenas a velocidades seguras (≤ 40 km/h)
   - Usar faixas exclusivas
   - Estacionar em locais proibidos

   **MAS** essas exceções só valem se a sirene estiver ligada e a emergência declarada.

4. **Regras Compostas**: Uma infração depende de múltiplos fatores:
   - **Excesso de velocidade**: velocidade medida > limite efetivo no horário
   - **Faixa exclusiva**: veículo não autorizado + faixa ativa no horário
   - **Estacionamento irregular**: veículo parado + proibição ativa no horário
   - **Sinal vermelho**: cruzamento com sinal vermelho + sem exceção válida

5. **Explicabilidade**: O sistema deve explicar **por que** houve ou não houve infração, para fins de auditoria, contestação e aprendizado.

**Exemplo Concreto:**

```
Evento e1: Carro v1 a 72 km/h no segmento s1 às 08:30
- Segmento s1: limite básico 60 km/h
- Zona escolar ativa (7h-19h): limite reduzido para 40 km/h
- Velocidade medida: 72 km/h > 40 km/h
- Resultado: VIOLAÇÃO (excesso de velocidade)
- Motivos: [leitura_velocidade(72), limite(40), segmento(s1), horario(t(8,30))]

Evento e3: Ambulância v4 cruza sinal vermelho às 02:10 a 32 km/h
- Sinal vermelho no segmento s4
- Veículo: ambulância com sirene ligada e emergência declarada
- Velocidade de cruzamento: 32 km/h ≤ 40 km/h (seguro)
- Resultado: NÃO VIOLAÇÃO (exceção de emergência)
- Motivos: [emergencia_em_atendimento]
```

**O Desafio:**

Implementar um sistema lógico que:
- Modela **hierarquia de veículos** (herança de categorias)
- Calcula **limites efetivos** considerando horários e zonas especiais
- Detecta **infrações** com regras compostas
- Implementa **exceções** com limites de segurança
- Usa **negação como falha** para ausência de restrições
- Gera **explicações** textuais legíveis

### 🎯 Objetivos de Aprendizagem

- Modelar hierarquias de categorias com herança
- Implementar regras com exceções usando negação como falha
- Aplicar raciocínio temporal (janelas de horário)
- Compor condições complexas (veículo + sinalização + horário)
- Gerar explicações automáticas de decisões
- Organizar conhecimento regulatório em múltiplos arquivos

---

## 🚦 Base de Fatos (Domínio de Trânsito)

### Categorias de Veículos e Herança
```prolog
% =========================
% CATEGORIAS DE VEÍCULOS
% =========================
categoria(veiculo).
categoria(privado).           herda(privado, veiculo).
categoria(frete).             herda(frete, veiculo).
categoria(transporte_publico). herda(transporte_publico, veiculo).
categoria(emergencia).        herda(emergencia, veiculo).
categoria(taxi).              herda(taxi, veiculo).

% Herança transitiva
herda_trans(Cf, Cp) :- herda(Cf, Cp).
herda_trans(Cf, Cg) :- herda(Cf, Cx), herda_trans(Cx, Cg).
```

### Veículos e Estados Operacionais
```prolog
% =========================
% VEÍCULOS
% =========================
veiculo(v1, carro, privado).
veiculo(v2, moto, privado).
veiculo(v3, onibus, transporte_publico).
veiculo(v4, ambulancia, emergencia).
veiculo(v5, caminhonete, frete).
veiculo(v6, sedan, taxi).

% Estados operacionais
estado(v4, sirene_ligada(sim)).
estado(v4, emergencia_declarada(sim)).
estado(v1, sirene_ligada(nao)).
estado(v1, emergencia_declarada(nao)).
estado(v6, taximetro_ligado(sim)).
```

### Segmentos Viários e Sinalizações
```prolog
% =========================
% SEGMENTOS VIÁRIOS
% =========================
segmento(s1). segmento(s2). segmento(s3). segmento(s4).

% Limites básicos de velocidade (km/h)
limite_basico(s1, 60).
limite_basico(s2, 60).
limite_basico(s3, 50).
limite_basico(s4, 40).

% Zona escolar (redução de limite por horário)
zona_escolar(s1, hora(7, 0), hora(19, 0), limite(40)).

% Faixa exclusiva de ônibus
faixa_onibus(s2, hora(17, 0), hora(20, 0), politica(permissao_taxi, nao)).

% Proibição de estacionamento
proibido_estacionar(s3, hora(8, 0), hora(18, 0)).

% Sinal vermelho com fiscalização
sinal_vermelho(s4).
```

### Parâmetros de Segurança
```prolog
% =========================
% PARÂMETROS DE SEGURANÇA PARA EXCEÇÕES
% =========================
% Emergência pode exceder até 30% do limite
margem_emergencia_velocidade(0.30).

% Velocidade máxima segura para cruzar sinal vermelho
velocidade_cruzamento_segura(40).

% Autorização especial de carga/descarga
autorizacao_carga_descarga(v5, s3, hora(9, 0), hora(11, 0)).
```

### Eventos Capturados
```prolog
% =========================
% EVENTOS (medidos/observados)
% evento(Id, Veiculo, Local, Tempo(hh:mm), TipoLeitura)
% =========================
evento(e1, v1, s1, t(8, 30),  velocidade(72)).           % carro 72 km/h em zona escolar
evento(e2, v2, s2, t(17, 30), faixa_onibus).             % moto em faixa de ônibus
evento(e3, v4, s4, t(2, 10),  cruzamento(vermelho, 32)). % ambulância cruza sinal
evento(e4, v5, s3, t(10, 0),  estacionado).              % frete estacionado
evento(e5, v6, s2, t(18, 15), faixa_onibus).             % táxi em faixa de ônibus
evento(e6, v1, s1, t(21, 10), velocidade(58)).           % carro dentro do limite
evento(e7, v1, s1, t(6, 40),  velocidade(52)).           % antes do horário escolar
```

---

## 📂 Estrutura dos Arquivos

### Arquivos de Entrada
- **`entrada.txt`**: Contém os fatos da base de conhecimento (veículos, segmentos, sinalizações, eventos)

### Arquivos Prolog
- **`principal.pl`**: Arquivo principal que carrega os demais módulos
- **`veiculos.pl`**: Categorias, herança e estados de veículos
- **`sinalizacao.pl`**: Segmentos, limites, zonas especiais e horários
- **`deteccao.pl`**: Regras de detecção de infrações
- **`excecoes.pl`**: Regras de exceções para veículos de emergência
- **`explicabilidade.pl`**: Geração de explicações textuais

### Arquivo de Saída
- **`saida.txt`**: Relatório de violações e não violações com motivos

---

## 🧱 Tarefas Obrigatórias

### 1. Regras de Apoio (Tempo e Janelas)

```prolog
% Verifica se tempo está dentro de uma janela horária
em_janela(t(H, M), hora(H1, M1), hora(H2, M2)) :-
    (H > H1 ; (H =:= H1, M >= M1)),
    (H < H2 ; (H =:= H2, M < M2)).

% Calcula limite efetivo (mais restritivo aplicável)
limite_efetivo(Seg, t(H, M), Lim) :-
    limite_basico(Seg, Lb),
    ( zona_escolar(Seg, I, F, limite(Le)),
      em_janela(t(H, M), I, F) ->
        Lim is min(Lb, Le)
    ; Lim = Lb ).

% Verifica se faixa de ônibus está ativa
faixa_onibus_ativa(Seg, Tempo, Politica) :-
    faixa_onibus(Seg, I, F, politica(permissao_taxi, PT)),
    em_janela(Tempo, I, F),
    Politica = politica(permissao_taxi, PT).

% Verifica se estacionamento está proibido
estacionamento_proibido_ativo(Seg, Tempo) :-
    proibido_estacionar(Seg, I, F),
    em_janela(Tempo, I, F).
```

### 2. Detecção de Excesso de Velocidade

```prolog
% Violação base de velocidade
base_violacao_velocidade(EID, Motivos) :-
    evento(EID, Veic, Seg, T, velocidade(V)),
    limite_efetivo(Seg, T, Lim),
    V > Lim,
    Motivos = [leitura_velocidade(V), limite(Lim), segmento(Seg), horario(T)].

% Exceção: emergência pode exceder até margem permitida
excecao_emergencia_vel(EID) :-
    evento(EID, Veic, Seg, T, velocidade(V)),
    veiculo(Veic, _, emergencia),
    estado(Veic, emergencia_declarada(sim)),
    estado(Veic, sirene_ligada(sim)),
    limite_efetivo(Seg, T, Lim),
    margem_emergencia_velocidade(M),
    V =< Lim * (1.0 + M).

% Violação efetiva (base sem exceção)
violacao(EID, excesso_velocidade, Motivos) :-
    base_violacao_velocidade(EID, Motivos),
    \+ excecao_emergencia_vel(EID).
```

### 3. Detecção de Uso Indevido de Faixa de Ônibus

```prolog
% Violação base de faixa de ônibus
base_violacao_faixa_onibus(EID, Motivos) :-
    evento(EID, Veic, Seg, T, faixa_onibus),
    faixa_onibus_ativa(Seg, T, Politica),
    \+ veiculo(Veic, _, transporte_publico),
    Motivos = [faixa_onibus_ativa(Seg, T), politica(Politica), veiculo(Veic)].

% Exceções: ônibus, emergência em atendimento, táxi com permissão
excecao_faixa_onibus(EID) :-
    evento(EID, Veic, Seg, T, faixa_onibus),
    ( veiculo(Veic, _, transporte_publico)
    ; ( veiculo(Veic, _, emergencia),
        estado(Veic, emergencia_declarada(sim)),
        estado(Veic, sirene_ligada(sim)) )
    ; ( veiculo(Veic, _, taxi),
        faixa_onibus_ativa(Seg, T, politica(permissao_taxi, sim)),
        estado(Veic, taximetro_ligado(sim)) )
    ).

% Violação efetiva
violacao(EID, faixa_onibus_indebida, Motivos) :-
    base_violacao_faixa_onibus(EID, Motivos),
    \+ excecao_faixa_onibus(EID).
```

### 4. Detecção de Estacionamento Irregular

```prolog
% Violação base de estacionamento
base_violacao_estacionamento(EID, Motivos) :-
    evento(EID, Veic, Seg, T, estacionado),
    estacionamento_proibido_ativo(Seg, T),
    Motivos = [estacionamento_proibido(Seg), horario(T), veiculo(Veic)].

% Exceções: emergência em atendimento, autorização de carga/descarga
excecao_estacionamento(EID) :-
    evento(EID, Veic, Seg, T, estacionado),
    ( ( veiculo(Veic, _, emergencia),
        estado(Veic, emergencia_declarada(sim)),
        estado(Veic, sirene_ligada(sim)) )
    ; ( autorizacao_carga_descarga(Veic, Seg, I, F),
        em_janela(T, I, F) )
    ).

% Violação efetiva
violacao(EID, estacionamento_irregular, Motivos) :-
    base_violacao_estacionamento(EID, Motivos),
    \+ excecao_estacionamento(EID).
```

### 5. Detecção de Avanço de Sinal Vermelho

```prolog
% Violação base de sinal vermelho
base_violacao_sinal(EID, Motivos) :-
    evento(EID, Veic, Seg, _T, cruzamento(vermelho, Vc)),
    sinal_vermelho(Seg),
    Motivos = [sinal_vermelho(Seg), velocidade_cruzamento(Vc)].

% Exceção: emergência com velocidade de cruzamento segura
excecao_sinal(EID) :-
    evento(EID, Veic, _Seg, _T, cruzamento(vermelho, Vc)),
    veiculo(Veic, _, emergencia),
    estado(Veic, emergencia_declarada(sim)),
    estado(Veic, sirene_ligada(sim)),
    velocidade_cruzamento_segura(Vs),
    Vc =< Vs.

% Violação efetiva
violacao(EID, avancar_sinal_vermelho, Motivos) :-
    base_violacao_sinal(EID, Motivos),
    \+ excecao_sinal(EID).
```

### 6. Explicabilidade e Não Violação

```prolog
% Rótulos textuais para tipos de infração
rotulo(excesso_velocidade,      'Excesso de velocidade').
rotulo(faixa_onibus_indebida,   'Uso indevido de faixa de ônibus').
rotulo(estacionamento_irregular, 'Estacionamento em local/horário proibido').
rotulo(avancar_sinal_vermelho,  'Avanço de sinal vermelho').

% Lista todas as violações de um evento
violacoes_evento(EID, Lista) :-
    findall((Tipo, Motivos), violacao(EID, Tipo, Motivos), Lista).

% Gera explicação textual amigável
explicacao((Tipo, Motivos), Texto) :-
    rotulo(Tipo, R),
    format(atom(Texto), '~w: ~w', [R, Motivos]).

% Caso de não violação
nao_violacao(EID, Motivos) :-
    evento(EID, Veic, Seg, T, _),
    \+ violacao(EID, _, _),
    findall(M, motivo_nao_violacao(EID, M), Ms),
    ( Ms = [] -> Motivos = [sem_infracao(Seg, T, Veic)]
    ; Motivos = Ms ).

% Motivos de não violação
motivo_nao_violacao(EID, emergencia_em_atendimento) :-
    ( excecao_emergencia_vel(EID)
    ; excecao_sinal(EID)
    ; excecao_faixa_onibus(EID)
    ; excecao_estacionamento(EID) ).

motivo_nao_violacao(EID, dentro_do_limite) :-
    evento(EID, _V, Seg, T, velocidade(V)),
    limite_efetivo(Seg, T, Lim),
    V =< Lim.

motivo_nao_violacao(EID, faixa_onibus_inativa) :-
    evento(EID, _V, Seg, T, faixa_onibus),
    \+ faixa_onibus_ativa(Seg, T, _).

motivo_nao_violacao(EID, estacionamento_permitido) :-
    evento(EID, _V, Seg, T, estacionado),
    \+ estacionamento_proibido_ativo(Seg, T).
```

---

## ✨ Extensões (Escolha pelo menos UMA)

| Conceito | Extensão Possível |
|----------|-------------------|
| **Condições Ambientais** | Reduzir limite em chuva/neblina: `clima(chuva)` → `Limite * 0.8`. |
| **Dias Úteis vs. Fim de Semana** | Ativar/desativar janelas conforme `dia_semana(Dia)`. |
| **Política Municipal** | Permitir táxi em faixa baseada em `municipio(Cidade, Politica)`. |
| **Câmara de Fiscalização** | Penalidade diferenciada quando `sinal_vermelho/1` tem câmera. |
| **Pontuação e Penalidade** | `pontuacao(EID, Pts)` com acúmulo por tipo de infração. |
| **Explicabilidade Avançada** | `trilha(EID, ListaRegras)` com as regras disparadas/exceções. |
| **Reincidência** | Detectar múltiplas infrações do mesmo veículo em período. |

### Exemplo de Extensão: Pontuação e Penalidade
```prolog
% Pontos por tipo de infração
pontos_infracao(excesso_velocidade, 5).
pontos_infracao(faixa_onibus_indebida, 7).
pontos_infracao(estacionamento_irregular, 3).
pontos_infracao(avancar_sinal_vermelho, 7).

% Multa base por tipo
multa_base(excesso_velocidade, 195.23).
multa_base(faixa_onibus_indebida, 293.47).
multa_base(estacionamento_irregular, 130.16).
multa_base(avancar_sinal_vermelho, 293.47).

% Calcula pontuação de um evento
pontuacao(EID, Pts) :-
    violacao(EID, Tipo, _),
    pontos_infracao(Tipo, Pts).

% Calcula multa de um evento
multa(EID, Valor) :-
    violacao(EID, Tipo, _),
    multa_base(Tipo, Valor).

% Pontuação total de um veículo
pontuacao_veiculo(Veic, Total) :-
    findall(Pts,
        (evento(EID, Veic, _, _, _), pontuacao(EID, Pts)),
        ListaPts),
    sum_list(ListaPts, Total).

% Veículos com risco de suspensão (≥ 20 pontos)
veiculo_risco_suspensao(Veic) :-
    pontuacao_veiculo(Veic, Total),
    Total >= 20.

% Exemplo de uso:
% ?- pontuacao(e1, P), multa(e1, M).
% P = 5,
% M = 195.23.
%
% ?- pontuacao_veiculo(v1, Total).
% Total = 5.  % apenas e1 (excesso de velocidade)
```

---

## ▶️ Exemplos de Execução

```prolog
% 1) Limite efetivo com/sem zona escolar
?- limite_efetivo(s1, t(8, 30), L).
L = 40.  % zona escolar ativa (7h-19h)

?- limite_efetivo(s1, t(20, 30), L).
L = 60.  % fora do horário escolar

?- limite_efetivo(s1, t(6, 40), L).
L = 60.  % antes do horário escolar

% 2) Excesso de velocidade (carro v1 a 72 km/h em zona escolar)
?- violacao(e1, Tipo, Mot).
Tipo = excesso_velocidade,
Mot = [leitura_velocidade(72), limite(40), segmento(s1), horario(t(8, 30))].

% 3) Faixa de ônibus ativa (moto v2 às 17:30) → violação
?- violacao(e2, T, M).
T = faixa_onibus_indebida,
M = [faixa_onibus_ativa(s2, t(17, 30)),
     politica(politica(permissao_taxi, nao)),
     veiculo(v2)].

% 4) Emergência cruza sinal vermelho devagar → exceção (não violação)
?- nao_violacao(e3, M).
M = [emergencia_em_atendimento].

?- excecao_sinal(e3).
true.  % ambulância com sirene, velocidade 32 km/h ≤ 40 km/h

% 5) Estacionamento proibido com autorização de carga/descarga
?- excecao_estacionamento(e4).
true.  % v5 tem autorização 9h-11h, evento às 10h

?- nao_violacao(e4, M).
M = [emergencia_em_atendimento].  % capturado pela exceção

% 6) Táxi em faixa de ônibus com política que NÃO permite táxi → violação
?- violacao(e5, T, _).
T = faixa_onibus_indebida.

% 7) Sem violação de velocidade (v1 a 58 km/h com limite 60)
?- nao_violacao(e6, M).
M = [dentro_do_limite].

?- evento(e6, V, Seg, T, velocidade(Vel)), limite_efetivo(Seg, T, Lim).
V = v1,
Seg = s1,
T = t(21, 10),
Vel = 58,
Lim = 60.  % fora do horário escolar

% 8) Antes do horário escolar (redução inativa)
?- limite_efetivo(s1, t(6, 40), L), nao_violacao(e7, M).
L = 60,
M = [dentro_do_limite].

% 9) Listar todas as violações de um evento
?- violacoes_evento(e1, Lista).
Lista = [(excesso_velocidade,
          [leitura_velocidade(72), limite(40), segmento(s1), horario(t(8, 30))])].

?- violacoes_evento(e3, Lista).
Lista = [].  % nenhuma violação (exceção de emergência)

% 10) Gerar explicação textual
?- violacao(e1, Tipo, Mot), explicacao((Tipo, Mot), Texto).
Tipo = excesso_velocidade,
Mot = [leitura_velocidade(72), limite(40), segmento(s1), horario(t(8, 30))],
Texto = 'Excesso de velocidade: [leitura_velocidade(72),limite(40),segmento(s1),horario(t(8,30))]'.

% 11) Verificar se faixa de ônibus está ativa
?- faixa_onibus_ativa(s2, t(17, 30), P).
P = politica(permissao_taxi, nao).

?- faixa_onibus_ativa(s2, t(16, 30), P).
false.  % antes das 17h

?- faixa_onibus_ativa(s2, t(20, 30), P).
false.  % depois das 20h

% 12) Verificar se estacionamento está proibido
?- estacionamento_proibido_ativo(s3, t(10, 0)).
true.  % horário comercial (8h-18h)

?- estacionamento_proibido_ativo(s3, t(19, 0)).
false.  % fora do horário

% 13) Listar todos os eventos de um veículo
?- evento(EID, v1, _, _, _).
EID = e1 ;
EID = e6 ;
EID = e7.

% 14) Listar todos os eventos com violação
?- violacao(EID, _, _).
EID = e1 ;
EID = e2 ;
EID = e5.

% 15) Listar todos os eventos sem violação
?- nao_violacao(EID, _).
EID = e3 ;
EID = e4 ;
EID = e6 ;
EID = e7.

% 16) Contar violações por tipo
?- findall(T, violacao(_, T, _), Tipos),
   msort(Tipos, TiposOrdenados).
Tipos = [excesso_velocidade, faixa_onibus_indebida, faixa_onibus_indebida],
TiposOrdenados = [excesso_velocidade, faixa_onibus_indebida, faixa_onibus_indebida].

% 17) Verificar herança de categorias
?- herda_trans(privado, veiculo).
true.

?- herda_trans(emergencia, veiculo).
true.

% 18) Listar veículos por categoria
?- veiculo(V, _, emergencia).
V = v4.

?- veiculo(V, _, privado).
V = v1 ;
V = v2.

% 19) Verificar estado operacional
?- estado(v4, emergencia_declarada(E)).
E = sim.

?- estado(v4, sirene_ligada(S)).
S = sim.

% 20) Testar janela de horário
?- em_janela(t(8, 30), hora(7, 0), hora(19, 0)).
true.

?- em_janela(t(6, 30), hora(7, 0), hora(19, 0)).
false.

?- em_janela(t(19, 0), hora(7, 0), hora(19, 0)).
false.  % limite superior exclusivo
```

---

## 🧠 Conceitos Aplicados

- **Hierarquia de Categorias**: Modelagem de herança transitiva entre categorias de veículos
- **Regras com Exceções**: Padrão base + exceção usando negação como falha
- **Negação como Falha**: Uso de `\+` para ausência de restrições ou exceções
- **Raciocínio Temporal**: Janelas de horário e limites variáveis por período
- **Composição de Condições**: Infrações dependem de veículo + sinalização + horário
- **Explicabilidade**: Geração automática de motivos e explicações textuais
- **Findall e Agregação**: Coleta de violações, motivos e pontuações
- **Format/Atom**: Geração de texto formatado para explicações
- **Limites de Segurança**: Exceções com restrições (margem de velocidade, velocidade de cruzamento)
- **Modularização**: Organização em múltiplos arquivos por responsabilidade

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

1. A base de dados deve conter **pelo menos 5 veículos** de categorias diferentes
2. Implemente **pelo menos 4 tipos de infrações** (velocidade, faixa, estacionamento, sinal)
3. Teste **exceções de emergência** com limites de segurança
4. Implemente **raciocínio temporal** com janelas de horário
5. Calcule **limites efetivos** considerando zonas especiais
6. Use **negação como falha** para ausência de restrições
7. Gere **explicações textuais** legíveis para todas as decisões
8. Teste **casos de não violação** com motivos claros
9. Implemente **pelo menos uma extensão** da tabela de extensões sugeridas
10. Organize o código em **múltiplos arquivos** conforme a estrutura sugerida

---

## 💡 Observação Didática

**Negação como Falha**: O sistema usa `\+` para verificar a **ausência** de condições:
- `\+ violacao(EID, _, _)` → nenhuma regra de violação foi satisfeita
- `\+ excecao_emergencia_vel(EID)` → não há exceção aplicável
- `\+ faixa_onibus_ativa(Seg, T, _)` → faixa não está ativa no horário

Isso permite assumir "sem restrição" quando não há sinalização aplicável, seguindo o princípio do **mundo fechado** (closed world assumption) do Prolog.

