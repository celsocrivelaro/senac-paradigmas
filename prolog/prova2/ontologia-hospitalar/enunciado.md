**Tema:** 🏥 Ontologia e Raciocínio Clínico Hospitalar

---

## 🎯 Objetivo

Modelar, em **Prolog (padrão)**, um sistema ontológico hospitalar que:

1. Define **classes** (pessoas, papéis, profissionais, pacientes, medicamentos, exames, unidades, doenças)
2. Implementa **herança** e **inferência de classe** (TBox + ABox)
3. Deduz **autorizações** (quem pode prescrever/solicitar) e **segurança clínica** (alergias, interações, contraindicações, idade/peso)
4. Infere **necessidade de exame**, **alocação de leito**, e **validação de farmácia**
5. Fornece **explicações** ("por que permitiu/negou?")

Consultas esperadas:

```prolog
pode_prescrever(dr_paula, metoprolol, pac_luisa, hipertensao).
seguro_para(pac_luisa, metoprolol).
precisa_exame(pac_pedro, ecocardiograma).
pode_solicitar_exame(dr_paula, troponina).
pode_alocar_leito(dr_paula, pac_luisa, leito_uti1).
farmacia_deve_validar(metoprolol).
plano_terapeutico(pac_luisa, hipertensao, Plano).
justifica_prescricao(dr_paula, metoprolol, pac_luisa, hipertensao, Motivos).
```

---

## 🧩 Descrição do Problema

### 🏥 Contexto e Motivação

Você é o **arquiteto de sistemas de informação hospitalar** responsável por implementar um **sistema de apoio à decisão clínica** para um hospital de médio porte.

**O Problema Real:**

Em ambientes hospitalares, decisões clínicas envolvem múltiplas camadas de conhecimento e restrições:

1. **Hierarquia de Papéis**: Médicos, enfermeiros e farmacêuticos têm diferentes níveis de autorização. Um médico pode prescrever medicamentos, mas um enfermeiro só pode administrá-los após validação. Farmacêuticos devem validar medicamentos controlados ou de alto custo.

2. **Especialização Médica**: Um cardiologista pode prescrever beta-bloqueadores para hipertensão, mas um clínico geral pode precisar de justificativa adicional. Pediatras têm regras específicas para doses por peso e idade.

3. **Segurança do Paciente**: Antes de prescrever qualquer medicamento, o sistema deve verificar:
   - **Alergias**: O paciente é alérgico ao princípio ativo?
   - **Contraindicações**: O medicamento é contraindicado para alguma condição do paciente?
   - **Interações**: O medicamento interage com outros que o paciente já está usando?
   - **Idade/Peso**: A dose é apropriada para a faixa etária e peso do paciente?

4. **Protocolos Clínicos**: Certas doenças exigem exames específicos antes do tratamento. Por exemplo, angina requer troponina e ecocardiograma antes de prescrever antianginosos.

5. **Alocação de Recursos**: Pacientes com condições graves (ex.: angina instável) precisam de leitos de UTI, não de enfermaria comum.

6. **Rastreabilidade e Auditoria**: O sistema deve explicar **por que** uma prescrição foi autorizada ou negada, para fins de auditoria e aprendizado.

**O Desafio:**

Implementar um sistema lógico que:
- Modela a **ontologia hospitalar** (classes, herança, instâncias)
- Infere **autorizações** baseadas em papéis e especializações
- Verifica **segurança clínica** em múltiplas dimensões
- Deduz **necessidades de exames** e **alocação de leitos**
- Gera **planos terapêuticos** automaticamente
- Explica **decisões** de forma auditável

### 🎯 Objetivos de Aprendizagem

- Modelar ontologias usando o paradigma lógico (TBox + ABox)
- Implementar herança transitiva de classes
- Criar regras de autorização baseadas em papéis e especializações
- Aplicar negação como falha para verificar segurança
- Utilizar findall para gerar planos terapêuticos
- Implementar explicabilidade com rastreamento de motivos
- Organizar conhecimento clínico em múltiplos arquivos

---

## 🏥 Base Ontológica (TBox + ABox)

### Classes (TBox - Terminological Box)
```prolog
% =========================
% CLASSES (TBox)
% =========================
% Hierarquia de Pessoas
classe(entidade).
classe(pessoa).                 herda(pessoa, entidade).
classe(profissional_saude).     herda(profissional_saude, pessoa).
classe(medico).                 herda(medico, profissional_saude).
classe(enfermeiro).             herda(enfermeiro, profissional_saude).
classe(farmaceutico).           herda(farmaceutico, profissional_saude).
classe(paciente).               herda(paciente, pessoa).

% Hierarquia de Especialidades
classe(especialidade).
classe(cardiologia).            herda(cardiologia, especialidade).
classe(pediatria).              herda(pediatria, especialidade).
classe(clinica_medica).         herda(clinica_medica, especialidade).

% Hierarquia de Medicamentos
classe(medicamento).
classe(beta_bloqueador).        herda(beta_bloqueador, medicamento).
classe(antibiotico).            herda(antibiotico, medicamento).
classe(controlado).             herda(controlado, medicamento).
classe(alto_custo).             herda(alto_custo, medicamento).

% Hierarquia de Exames
classe(exame).
classe(laboratorial).           herda(laboratorial, exame).
classe(imagem).                 herda(imagem, exame).

% Hierarquia de Unidades
classe(unidade).
classe(uti).                    herda(uti, unidade).
classe(enfermaria).             herda(enfermaria, unidade).

% Hierarquia de Doenças
classe(doenca).
classe(hipertensao).            herda(hipertensao, doenca).
classe(angina).                 herda(angina, doenca).
classe(infeccao_respiratoria).  herda(infeccao_respiratoria, doenca).
```

### Instâncias (ABox - Assertional Box)
```prolog
% =========================
% INSTÂNCIAS (ABox)
% =========================
% Profissionais
instancia(dr_paula, medico).
instancia(dr_joao, medico).
instancia(enf_maria, enfermeiro).
instancia(far_carla, farmaceutico).

% Especialidades dos médicos
especialidade_de(dr_paula, cardiologia).
especialidade_de(dr_joao, clinica_medica).

% Pacientes
instancia(pac_luisa, paciente).
instancia(pac_pedro, paciente).

% Medicamentos e seus pertencimentos de classe
instancia(metoprolol, beta_bloqueador).
instancia(amoxicilina, antibiotico).
instancia(tramadol, controlado).           % analgésico controlado
instancia(oseltamivir, alto_custo).        % antiviral de alto custo

% Princípios ativos (para verificação de alergias)
principio_ativo(metoprolol, metoprolol_pa).
principio_ativo(amoxicilina, amoxicilina_pa).
principio_ativo(tramadol, tramadol_pa).
principio_ativo(oseltamivir, oseltamivir_pa).

% Exames
instancia(troponina, laboratorial).
instancia(ecocardiograma, imagem).
instancia(rx_torax, imagem).

% Unidades e leitos
instancia(leito_uti1, uti).
instancia(leito_enf1, enfermaria).
```

### Dados Clínicos dos Pacientes
```prolog
% =========================
% DADOS CLÍNICOS DOS PACIENTES
% =========================
% Idade e peso
idade_paciente(pac_luisa, 35).
idade_paciente(pac_pedro, 8).

peso_paciente(pac_luisa, 68).
peso_paciente(pac_pedro, 26).

% Doenças diagnosticadas
tem_doenca(pac_luisa, hipertensao).
tem_doenca(pac_luisa, angina).
tem_doenca(pac_pedro, infeccao_respiratoria).

% Condições especiais
gravida(pac_luisa, nao).

% Alergias (por princípio ativo)
alergia_substancia(pac_pedro, amoxicilina_pa).

% Medicamentos em uso (para verificar interações)
em_uso(pac_luisa, tramadol).
```

### Conhecimento Clínico
```prolog
% =========================
% CONHECIMENTO CLÍNICO
% =========================
% Que doença um medicamento trata
trata(metoprolol, hipertensao).
trata(metoprolol, angina).
trata(amoxicilina, infeccao_respiratoria).
trata(oseltamivir, infeccao_respiratoria).

% Contraindicações (medicamento X condição)
contraindicacao(metoprolol, bradicardia).
contraindicacao(tramadol, convulsao).

% Interações medicamentosas (simétricas)
interacao(tramadol, oseltamivir).
interacao(oseltamivir, tramadol).

% Exames recomendados por condição
exame_recomendado(angina, troponina).
exame_recomendado(angina, ecocardiograma).
exame_recomendado(infeccao_respiratoria, rx_torax).

% Requisitos de leito por condição
precisa_uti(angina).  % angina instável requer UTI (exemplo didático)

% Regras administrativas
controlado_ou_alto_custo(M) :- instancia(M, controlado).
controlado_ou_alto_custo(M) :- instancia(M, alto_custo).
```

---

## 📂 Estrutura dos Arquivos e Entrada-Saída

### Arquivos de Entrada
- **`entrada.txt`**: Contém os fatos da base de conhecimento (ontologia, pacientes, conhecimento clínico)

### Arquivos Prolog
- **`principal.pl`**: Arquivo principal que carrega os demais módulos e a base de dados
- **`ontologia.pl`**: Predicados de classes, herança e inferência ontológica
- **`autorizacao.pl`**: Predicados de autorização por papel e especialidade
- **`seguranca.pl`**: Predicados de segurança clínica (alergias, interações, contraindicações)
- **`exames.pl`**: Predicados relacionados a exames e protocolos
- **`leitos.pl`**: Predicados de alocação de leitos
- **`explicacao.pl`**: Predicados de explicação e justificativa

### Arquivo de Saída
- **`saida.txt`**: Resultados de autorizações, planos terapêuticos e justificativas

---

## 🧱 Tarefas Obrigatórias

### 1. Inferência Ontológica e Herança

```prolog
% Herança transitiva de classes
herda_trans(CF, CP) :- herda(CF, CP).
herda_trans(CF, CA) :-
    herda(CF, CM),
    herda_trans(CM, CA).

% Inferência de classe: entidade -> classe (com herança)
inferir_classe(X, C) :-
    instancia(X, C).
inferir_classe(X, C) :-
    instancia(X, C1),
    herda_trans(C1, C).

% Fechos auxiliares para categorias específicas
classe_de_medicamento(Med, Classe) :-
    inferir_classe(Med, Classe),
    herda_trans(Classe, medicamento).

classe_de_exame(Ex, Classe) :-
    inferir_classe(Ex, Classe),
    herda_trans(Classe, exame).

classe_de_profissional(Prof, Classe) :-
    inferir_classe(Prof, Classe),
    herda_trans(Classe, profissional_saude).
```

### 2. Segurança Clínica

```prolog
% Verifica se paciente tem alergia ao medicamento
alergia_paciente_a(Pac, Med) :-
    principio_ativo(Med, PA),
    alergia_substancia(Pac, PA).

% Verifica se medicamento é contraindicado para o paciente
contraindicada_para(Pac, Med) :-
    tem_doenca(Pac, Cond),
    contraindicacao(Med, Cond).

% Verifica se medicamento interage com outros em uso
interage_com_em_uso(Pac, Med) :-
    em_uso(Pac, M2),
    (interacao(Med, M2) ; interacao(M2, Med)).

% Verificações de idade e peso (ganchos para extensões)
idade_ok(_Pac, _Med) :- true.   % Pode ser refinado para regras pediátricas
peso_ok(_Pac, _Med) :- true.    % Pode ser refinado para doses por peso

% Predicado principal de segurança
seguro_para(Pac, Med) :-
    \+ alergia_paciente_a(Pac, Med),
    \+ contraindicada_para(Pac, Med),
    \+ interage_com_em_uso(Pac, Med),
    idade_ok(Pac, Med),
    peso_ok(Pac, Med).
```

### 3. Autorizações Clínicas

```prolog
% Profissionais com permissão de prescrição
pode_prescrever_papel(Medico) :-
    inferir_classe(Medico, medico).

% Restrições por especialidade
% Beta-bloqueador requer cardiologia OU condição cardíaca explícita
permite_especialidade(Medico, Med, Pac) :-
    classe_de_medicamento(Med, beta_bloqueador),
    (especialidade_de(Medico, cardiologia)
    ; (inferir_classe(Medico, medico),
       (tem_doenca(Pac, hipertensao) ; tem_doenca(Pac, angina))
      )
    ).

% Antibiótico: qualquer médico pode prescrever se houver doença infecciosa alvo
permite_especialidade(Medico, Med, Pac) :-
    classe_de_medicamento(Med, antibiotico),
    inferir_classe(Medico, medico),
    tem_doenca(Pac, D),
    trata(Med, D).

% Fallback: médico especialista correspondente à doença alvo
permite_especialidade(Medico, Med, Pac) :-
    inferir_classe(Medico, medico),
    tem_doenca(Pac, D),
    trata(Med, D).

% Regra principal de prescrição
pode_prescrever(Medico, Med, Pac, Doenca) :-
    pode_prescrever_papel(Medico),
    permite_especialidade(Medico, Med, Pac),
    trata(Med, Doenca),
    seguro_para(Pac, Med).
```

### 4. Validação de Farmácia e Administração

```prolog
% Farmácia deve validar medicamentos controlados ou de alto custo
farmacia_deve_validar(Med) :-
    controlado_ou_alto_custo(Med).

% Predicados dinâmicos para rastrear prescrições e validações
:- dynamic prescrito_por/3.
:- dynamic validado_por/3.

% Enfermeiro pode administrar se houver prescrição válida
% e (quando exigido) validação da farmácia
enfermeiro_pode_administrar(Enf, Medico, Med, Pac) :-
    inferir_classe(Enf, enfermeiro),
    prescrito_por(Medico, Med, Pac),
    (\+ farmacia_deve_validar(Med) ; validado_por(_, Med, Pac)).
```

### 5. Exames e Protocolos

```prolog
% Quem pode solicitar exame
pode_solicitar_exame(Prof, Ex) :-
    inferir_classe(Prof, medico),
    classe_de_exame(Ex, _).

pode_solicitar_exame(Prof, Ex) :-
    inferir_classe(Prof, enfermeiro),
    classe_de_exame(Ex, laboratorial).  % Enfermeiro solicita apenas laboratoriais

% Necessidade de exame por doença
precisa_exame(Pac, Ex) :-
    tem_doenca(Pac, D),
    exame_recomendado(D, Ex).
```

### 6. Alocação de Leitos

```prolog
% Alocação de leito por condição
pode_alocar_leito(Prof, Pac, Leito) :-
    inferir_classe(Prof, medico),
    (tem_doenca(Pac, D), precisa_uti(D) ->
        inferir_classe(Leito, uti)
    ;
        inferir_classe(Leito, enfermaria)
    ).
```

### 7. Plano Terapêutico Dedutivo

```prolog
% Retorna um "plano" (lista) combinando exames + medicação-alvo, se seguro
plano_terapeutico(Pac, Doenca, Plano) :-
    findall(Ex, exame_recomendado(Doenca, Ex), Exames),
    findall(M, (trata(M, Doenca), seguro_para(Pac, M)), Meds),
    append(Exames, Meds, Itens),
    sort(Itens, Plano).
```

### 8. Explicabilidade (Por que permitiu/negou?)

```prolog
% Coleta todos os motivos de autorização ou negação
justifica_prescricao(Medico, Med, Pac, Doenca, Motivos) :-
    findall(Mv, (
        (\+ pode_prescrever_papel(Medico) ->
            Mv = nao_e_medico
        ; \+ trata(Med, Doenca) ->
            Mv = nao_trata_doenca
        ; (\+ permite_especialidade(Medico, Med, Pac) ->
              Mv = especialidade_inadequada
          ; true)
        ; (alergia_paciente_a(Pac, Med) ->
              Mv = alergia
          ; contraindicada_para(Pac, Med) ->
              Mv = contraindicado
          ; interage_com_em_uso(Pac, Med) ->
              Mv = interacao
          ; \+ idade_ok(Pac, Med) ->
              Mv = idade_inadequada
          ; \+ peso_ok(Pac, Med) ->
              Mv = peso_inadequado
          ; Mv = ok  % Passou em todas as verificações
          )
        )
    ), L),
    sort(L, Motivos).

% Mapeamento de motivos para texto legível
motivo_humano(ok, 'prescrição autorizada e segura').
motivo_humano(nao_e_medico, 'usuário não é médico').
motivo_humano(nao_trata_doenca, 'medicamento não trata a doença-alvo').
motivo_humano(especialidade_inadequada, 'especialidade não cobre o fármaco/condição').
motivo_humano(alergia, 'alergia ao princípio ativo').
motivo_humano(contraindicado, 'existe contraindicação para a condição do paciente').
motivo_humano(interacao, 'interação com medicamentos em uso').
motivo_humano(idade_inadequada, 'idade não apropriada para o fármaco').
motivo_humano(peso_inadequado, 'peso não apropriado para o fármaco').

% Versão textual da justificativa
justifica_prescricao_texto(Medico, Med, Pac, Doenca, Textos) :-
    justifica_prescricao(Medico, Med, Pac, Doenca, Ms),
    findall(T, (member(Mtag, Ms), motivo_humano(Mtag, T)), Textos).
```

---

## ✨ Extensões (Escolha pelo menos UMA)

| Conceito | Extensão Possível |
|----------|-------------------|
| **Pediatria** | Implementar `idade_ok/2` e `peso_ok/2` com faixas e doses específicas. Permitir que pediatria override certas restrições. |
| **Regras Temporais** | Proibir repetir antibiótico da mesma classe em < 30 dias (`uso_recente/3`). Histórico de prescrições. |
| **Vias de Administração** | `via(Med, oral/iv)` e exigir exame/monitoramento para IV em UTI. Diferentes vias têm diferentes restrições. |
| **Protocolos Clínicos** | Encadear "via de dor torácica": troponina → ECG → eco → antianginoso. Sequência obrigatória de exames. |
| **ABAC Clínico** | Acessos baseados em atributos (plantão, tempo de casa, certificações). Autorização contextual. |
| **Auditoria Completa** | `trilha/5` listando fatos que suportam a decisão final. Rastreamento completo de regras aplicadas. |
| **Diagnóstico Diferencial** | Inferir doenças possíveis a partir de sintomas. Sistema de apoio ao diagnóstico. |

### Exemplo de Extensão: Pediatria com Doses por Peso
```prolog
% Faixas etárias pediátricas
faixa_etaria(Pac, neonato) :-
    idade_paciente(Pac, I), I =< 0.083.  % até 1 mês
faixa_etaria(Pac, lactente) :-
    idade_paciente(Pac, I), I > 0.083, I =< 2.
faixa_etaria(Pac, crianca) :-
    idade_paciente(Pac, I), I > 2, I =< 12.
faixa_etaria(Pac, adolescente) :-
    idade_paciente(Pac, I), I > 12, I < 18.
faixa_etaria(Pac, adulto) :-
    idade_paciente(Pac, I), I >= 18.

% Doses por peso (mg/kg)
dose_por_peso(amoxicilina, crianca, 20, 40).  % 20-40 mg/kg/dia
dose_por_peso(amoxicilina, adulto, 500, 1000). % 500-1000 mg/dose

% Verificação de idade refinada
idade_ok(Pac, Med) :-
    faixa_etaria(Pac, Faixa),
    dose_por_peso(Med, Faixa, _, _).

% Cálculo de dose apropriada
dose_apropriada(Pac, Med, DoseMin, DoseMax) :-
    faixa_etaria(Pac, Faixa),
    peso_paciente(Pac, Peso),
    dose_por_peso(Med, Faixa, DoseMinKg, DoseMaxKg),
    DoseMin is DoseMinKg * Peso,
    DoseMax is DoseMaxKg * Peso.

% Exemplo de uso:
% ?- dose_apropriada(pac_pedro, amoxicilina, Min, Max).
% Min = 520, Max = 1040.  % pac_pedro tem 26kg
```

---

## ▶️ Exemplos de Execução

```prolog
% 1) Ontologia: herança e inferência
?- inferir_classe(dr_paula, profissional_saude).
true.

?- inferir_classe(dr_paula, pessoa).
true.

?- inferir_classe(metoprolol, medicamento).
true.

?- inferir_classe(metoprolol, beta_bloqueador).
true.

% 2) Autorização e segurança - Caso de sucesso
?- pode_prescrever(dr_paula, metoprolol, pac_luisa, hipertensao).
true.

?- seguro_para(pac_luisa, metoprolol).
true.

% 3) Alergia impede antibiótico
?- pode_prescrever(dr_joao, amoxicilina, pac_pedro, infeccao_respiratoria).
false.  % pac_pedro é alérgico a amoxicilina_pa

?- alergia_paciente_a(pac_pedro, amoxicilina).
true.

% 4) Interação bloqueia prescrição
?- pode_prescrever(dr_paula, oseltamivir, pac_luisa, infeccao_respiratoria).
false.  % interage com tramadol em uso

?- interage_com_em_uso(pac_luisa, oseltamivir).
true.

% 5) Farmácia deve validar medicamentos controlados
?- farmacia_deve_validar(tramadol).
true.

?- farmacia_deve_validar(metoprolol).
false.

?- farmacia_deve_validar(oseltamivir).
true.  % alto custo

% 6) Exames recomendados pela ontologia de doença
?- precisa_exame(pac_luisa, troponina).
true.

?- precisa_exame(pac_luisa, ecocardiograma).
true.

?- precisa_exame(pac_pedro, rx_torax).
true.

% 7) Solicitação de exame por perfil profissional
?- pode_solicitar_exame(dr_paula, ecocardiograma).
true.

?- pode_solicitar_exame(enf_maria, ecocardiograma).
false.  % enfermeiro não pode solicitar exame de imagem

?- pode_solicitar_exame(enf_maria, troponina).
true.  % enfermeiro pode solicitar laboratorial

% 8) Alocação de leito dedutiva
?- pode_alocar_leito(dr_paula, pac_luisa, leito_uti1).
true.  % pac_luisa tem angina, que requer UTI

?- pode_alocar_leito(dr_paula, pac_luisa, leito_enf1).
false.  % angina requer UTI, não enfermaria

?- pode_alocar_leito(dr_paula, pac_pedro, leito_enf1).
true.  % infecção respiratória não requer UTI

% 9) Fluxo de administração (dinâmico)
?- assertz(prescrito_por(dr_paula, metoprolol, pac_luisa)),
   enfermeiro_pode_administrar(enf_maria, dr_paula, metoprolol, pac_luisa).
true.  % metoprolol não requer validação de farmácia

?- assertz(prescrito_por(dr_paula, tramadol, pac_luisa)),
   enfermeiro_pode_administrar(enf_maria, dr_paula, tramadol, pac_luisa).
false.  % tramadol é controlado e ainda não foi validado

?- assertz(validado_por(far_carla, tramadol, pac_luisa)),
   enfermeiro_pode_administrar(enf_maria, dr_paula, tramadol, pac_luisa).
true.  % agora foi validado pela farmacêutica

% 10) Plano terapêutico dedutivo
?- plano_terapeutico(pac_luisa, hipertensao, Plano).
Plano = [metoprolol].  % apenas metoprolol (exames são para angina)

?- plano_terapeutico(pac_luisa, angina, Plano).
Plano = [ecocardiograma, metoprolol, troponina].

?- plano_terapeutico(pac_pedro, infeccao_respiratoria, Plano).
Plano = [oseltamivir, rx_torax].  % amoxicilina foi excluída por alergia

% 11) Explicabilidade - Caso de sucesso
?- justifica_prescricao_texto(dr_paula, metoprolol, pac_luisa, hipertensao, J).
J = ['prescrição autorizada e segura'].

?- justifica_prescricao(dr_paula, metoprolol, pac_luisa, hipertensao, M).
M = [ok].

% 12) Explicabilidade - Caso de falha por interação
?- justifica_prescricao_texto(dr_paula, oseltamivir, pac_luisa, infeccao_respiratoria, J).
J = ['interação com medicamentos em uso'].

?- justifica_prescricao(dr_paula, oseltamivir, pac_luisa, infeccao_respiratoria, M).
M = [interacao].

% 13) Explicabilidade - Caso de falha por alergia
?- justifica_prescricao_texto(dr_joao, amoxicilina, pac_pedro, infeccao_respiratoria, J).
J = ['alergia ao princípio ativo'].

% 14) Listar todas as classes de um medicamento
?- findall(C, inferir_classe(metoprolol, C), Classes).
Classes = [beta_bloqueador, medicamento, entidade].

% 15) Listar todos os medicamentos que tratam uma doença
?- trata(M, hipertensao).
M = metoprolol.

?- findall(M, trata(M, infeccao_respiratoria), Meds).
Meds = [amoxicilina, oseltamivir].

% 16) Listar todos os exames de um tipo
?- classe_de_exame(Ex, laboratorial).
Ex = troponina.

?- classe_de_exame(Ex, imagem).
Ex = ecocardiograma ;
Ex = rx_torax.

% 17) Verificar especialidade de médico
?- especialidade_de(dr_paula, Esp).
Esp = cardiologia.

?- especialidade_de(dr_joao, Esp).
Esp = clinica_medica.

% 18) Listar todas as doenças de um paciente
?- tem_doenca(pac_luisa, D).
D = hipertensao ;
D = angina.

?- findall(D, tem_doenca(pac_luisa, D), Doencas).
Doencas = [hipertensao, angina].
```

---

## 🧠 Conceitos Aplicados

- **Ontologias (TBox + ABox)**: Modelagem de classes, herança e instâncias
- **Herança Transitiva**: Propagação de propriedades através da hierarquia de classes
- **Inferência de Classe**: Dedução automática de pertencimento a classes ancestrais
- **Autorização Baseada em Papéis**: Diferentes níveis de permissão por tipo de profissional
- **Regras de Especialização**: Restrições específicas por especialidade médica
- **Segurança Clínica Multi-dimensional**: Alergias, contraindicações, interações, idade, peso
- **Negação como Falha**: Verificação de ausência de condições impeditivas
- **Findall e Agregação**: Coleta de exames, medicamentos e motivos
- **Explicabilidade**: Rastreamento de motivos de autorização ou negação
- **Predicados Dinâmicos**: Rastreamento de prescrições e validações em tempo de execução

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

1. A base de dados deve conter **pelo menos 4 profissionais**, **3 pacientes**, **4 medicamentos** e **3 doenças**
2. Implemente **herança transitiva** completa (classe → superclasse → ... → entidade)
3. Teste casos de **autorização e negação** (especialidade adequada/inadequada)
4. Implemente **segurança clínica** em todas as dimensões (alergias, contraindicações, interações)
5. Teste **fluxo completo** de prescrição → validação → administração
6. Implemente **explicabilidade** com motivos textuais legíveis
7. Use **findall** para gerar planos terapêuticos automaticamente
8. Teste **alocação de leitos** baseada em condições clínicas
9. Implemente **pelo menos uma extensão** da tabela de extensões sugeridas
10. Organize o código em **múltiplos arquivos** conforme a estrutura sugerida

