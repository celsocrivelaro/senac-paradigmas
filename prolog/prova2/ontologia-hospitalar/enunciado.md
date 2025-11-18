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

#### 1.1. `herda_trans/2` - Fecho Transitivo de Herança
```prolog
% ============================================
% HERDA_TRANS/2
% ============================================
% Descrição: Implementa o fecho transitivo da relação de herança entre classes
%            na ontologia hospitalar. Permite navegar por toda a hierarquia.
%
% Parâmetros:
%   - CF: átomo representando a classe filha
%   - CP: átomo representando a classe pai (ancestral)
%
% Comportamento:
%   - Caso base: CF herda diretamente de CP (herda(CF, CP))
%   - Caso recursivo: CF herda de CM, CM herda de CA (transitivo)
%   - Permite navegar por múltiplos níveis de hierarquia
%
% Hierarquia típica:
%   aspirina → analgesico → medicamento → entidade
%
% Exemplos de uso:
%   ?- herda_trans(aspirina, analgesico).
%   true.  % herança direta
%
%   ?- herda_trans(aspirina, medicamento).
%   true.  % herança transitiva
%
herda_trans(CF, CP).
```

#### 1.2. `inferir_classe/2` - Inferência de Classe com Herança
```prolog
% ============================================
% INFERIR_CLASSE/2
% ============================================
% Descrição: Infere todas as classes às quais uma entidade pertence, incluindo
%            classes diretas e classes herdadas via hierarquia.
%
% Parâmetros:
%   - X: átomo identificando a entidade
%   - C: átomo representando a classe (saída)
%
% Comportamento:
%   - Caso 1: X é instância direta de C (instancia(X, C))
%   - Caso 2: X é instância de C1, C1 herda de C (herança transitiva)
%   - Retorna todas as classes aplicáveis
%
% Uso:
%   - Raciocínio ontológico
%   - Classificação automática
%   - Verificação de tipos
%
% Exemplos de uso:
%   ?- inferir_classe(aspirina_100mg, C).
%   C = aspirina ;
%   C = analgesico ;
%   C = medicamento.
%
inferir_classe(X, C).
```

#### 1.3. `classe_de_medicamento/2` - Classificação de Medicamentos
```prolog
% ============================================
% CLASSE_DE_MEDICAMENTO/2
% ============================================
% Descrição: Determina a classe de um medicamento, verificando que a classe
%            herda de 'medicamento' na ontologia.
%
% Parâmetros:
%   - Med: átomo identificando o medicamento
%   - Classe: átomo representando a classe do medicamento (saída)
%
% Comportamento:
%   - Infere classe do medicamento
%   - Verifica que classe herda de 'medicamento'
%   - Filtra apenas classes relevantes para medicamentos
%
% Exemplos de uso:
%   ?- classe_de_medicamento(aspirina_100mg, C).
%   C = aspirina ;
%   C = analgesico.
%
classe_de_medicamento(Med, Classe).
```

#### 1.4. `classe_de_exame/2` - Classificação de Exames
```prolog
% ============================================
% CLASSE_DE_EXAME/2
% ============================================
% Descrição: Determina a classe de um exame, verificando que a classe
%            herda de 'exame' na ontologia.
%
% Parâmetros:
%   - Ex: átomo identificando o exame
%   - Classe: átomo representando a classe do exame (saída)
%
% Comportamento:
%   - Infere classe do exame
%   - Verifica que classe herda de 'exame'
%   - Filtra apenas classes relevantes para exames
%
% Exemplos de uso:
%   ?- classe_de_exame(hemograma_completo, C).
%   C = hemograma ;
%   C = exame_sangue.
%
classe_de_exame(Ex, Classe).
```

#### 1.5. `classe_de_profissional/2` - Classificação de Profissionais
```prolog
% ============================================
% CLASSE_DE_PROFISSIONAL/2
% ============================================
% Descrição: Determina a classe de um profissional de saúde, verificando que
%            a classe herda de 'profissional_saude' na ontologia.
%
% Parâmetros:
%   - Prof: átomo identificando o profissional
%   - Classe: átomo representando a classe do profissional (saída)
%
% Comportamento:
%   - Infere classe do profissional
%   - Verifica que classe herda de 'profissional_saude'
%   - Filtra apenas classes relevantes para profissionais
%
% Exemplos de uso:
%   ?- classe_de_profissional(dr_silva, C).
%   C = medico ;
%   C = cardiologista.
%
classe_de_profissional(Prof, Classe).
```

### 2. Segurança Clínica

#### 2.1. `alergia_paciente_a/2` - Verificação de Alergia
```prolog
% ============================================
% ALERGIA_PACIENTE_A/2
% ============================================
% Descrição: Verifica se um paciente tem alergia a um medicamento específico,
%            baseado no princípio ativo do medicamento.
%
% Parâmetros:
%   - Pac: átomo identificando o paciente
%   - Med: átomo identificando o medicamento
%
% Comportamento:
%   - Obtém princípio ativo do medicamento
%   - Verifica se paciente tem alergia à substância
%   - Sucede se há alergia
%
% Uso:
%   - Segurança clínica
%   - Prevenção de reações alérgicas
%   - Validação de prescrições
%
% Exemplos de uso:
%   ?- alergia_paciente_a(joao, aspirina_100mg).
%   true.  % joao é alérgico ao ácido acetilsalicílico
%
alergia_paciente_a(Pac, Med).
```

#### 2.2. `contraindicada_para/2` - Verificação de Contraindicação
```prolog
% ============================================
% CONTRAINDICADA_PARA/2
% ============================================
% Descrição: Verifica se um medicamento é contraindicado para um paciente
%            baseado nas doenças que o paciente possui.
%
% Parâmetros:
%   - Pac: átomo identificando o paciente
%   - Med: átomo identificando o medicamento
%
% Comportamento:
%   - Obtém doenças do paciente
%   - Verifica se medicamento tem contraindicação para alguma doença
%   - Sucede se há contraindicação
%
% Uso:
%   - Segurança clínica
%   - Prevenção de complicações
%   - Validação de prescrições
%
% Exemplos de uso:
%   ?- contraindicada_para(maria, ibuprofeno).
%   true.  % maria tem úlcera, ibuprofeno é contraindicado
%
contraindicada_para(Pac, Med).
```

#### 2.3. `interage_com_em_uso/2` - Verificação de Interação Medicamentosa
```prolog
% ============================================
% INTERAGE_COM_EM_USO/2
% ============================================
% Descrição: Verifica se um medicamento interage com outros medicamentos que
%            o paciente já está usando.
%
% Parâmetros:
%   - Pac: átomo identificando o paciente
%   - Med: átomo identificando o medicamento a verificar
%
% Comportamento:
%   - Obtém medicamentos em uso pelo paciente
%   - Verifica se há interação entre Med e algum medicamento em uso
%   - Considera interação bidirecional (Med-M2 ou M2-Med)
%   - Sucede se há interação
%
% Uso:
%   - Segurança clínica
%   - Prevenção de interações perigosas
%   - Validação de prescrições
%
% Exemplos de uso:
%   ?- interage_com_em_uso(pedro, warfarina).
%   true.  % pedro usa aspirina, que interage com warfarina
%
interage_com_em_uso(Pac, Med).
```

#### 2.4. `idade_ok/2` e `peso_ok/2` - Verificações Adicionais
```prolog
% ============================================
% IDADE_OK/2, PESO_OK/2
% ============================================
% Descrição: Ganchos para verificações adicionais de segurança baseadas em
%            idade e peso. Implementação padrão sempre retorna true.
%
% Parâmetros:
%   - Pac: átomo identificando o paciente
%   - Med: átomo identificando o medicamento
%
% Comportamento:
%   - Implementação padrão: sempre sucede
%   - Pode ser refinado para regras pediátricas (idade)
%   - Pode ser refinado para doses por peso (peso)
%
% Uso:
%   - Extensibilidade do sistema
%   - Placeholder para regras futuras
%
idade_ok(Pac, Med).
peso_ok(Pac, Med).
```

#### 2.5. `seguro_para/2` - Verificação Completa de Segurança
```prolog
% ============================================
% SEGURO_PARA/2
% ============================================
% Descrição: Predicado principal que verifica se um medicamento é seguro para
%            um paciente, considerando múltiplos critérios de segurança.
%
% Parâmetros:
%   - Pac: átomo identificando o paciente
%   - Med: átomo identificando o medicamento
%
% Comportamento:
%   - Verifica 5 critérios de segurança (todos devem ser satisfeitos):
%     1. NÃO há alergia ao medicamento
%     2. NÃO há contraindicação
%     3. NÃO há interação com medicamentos em uso
%     4. Idade é adequada
%     5. Peso é adequado
%   - Usa negação como falha (\+) para critérios 1-3
%   - Sucede apenas se todos os critérios são satisfeitos
%
% Política de segurança:
%   - Abordagem conservadora (todos os critérios devem passar)
%   - Qualquer falha de segurança impede prescrição
%   - Prioriza segurança do paciente
%
% Exemplos de uso:
%   ?- seguro_para(joao, paracetamol).
%   true.  % paracetamol é seguro para joao
%
%   ?- seguro_para(maria, ibuprofeno).
%   false.  % maria tem contraindicação
%
seguro_para(Pac, Med).
```

### 3. Autorizações Clínicas

#### 3.1. `pode_prescrever_papel/1` - Verificação de Papel
```prolog
% ============================================
% PODE_PRESCREVER_PAPEL/1
% ============================================
% Descrição: Verifica se um profissional tem o papel adequado para prescrever
%            medicamentos (deve ser médico).
%
% Parâmetros:
%   - Medico: átomo identificando o profissional
%
% Comportamento:
%   - Infere classe do profissional
%   - Verifica se é médico (via ontologia)
%   - Sucede se profissional é médico
%
% Exemplos de uso:
%   ?- pode_prescrever_papel(dr_silva).
%   true.  % dr_silva é médico
%
pode_prescrever_papel(Medico).
```

#### 3.2. `permite_especialidade/3` - Verificação de Especialidade
```prolog
% ============================================
% PERMITE_ESPECIALIDADE/3
% ============================================
% Descrição: Verifica se um médico tem especialidade adequada para prescrever
%            um medicamento específico para um paciente. Implementa regras
%            específicas por classe de medicamento.
%
% Parâmetros:
%   - Medico: átomo identificando o médico
%   - Med: átomo identificando o medicamento
%   - Pac: átomo identificando o paciente
%
% Comportamento:
%   - **Regra 1: Beta-bloqueadores**
%     * Requer cardiologista OU
%     * Médico geral com paciente tendo condição cardíaca (hipertensão/angina)
%   - **Regra 2: Antibióticos**
%     * Qualquer médico pode prescrever
%     * Se houver doença infecciosa que o medicamento trata
%   - **Regra 3: Fallback geral**
%     * Médico pode prescrever se medicamento trata doença do paciente
%
% Política:
%   - Medicamentos especializados requerem especialista
%   - Medicamentos comuns podem ser prescritos por qualquer médico
%   - Sempre verifica indicação clínica
%
% Exemplos de uso:
%   ?- permite_especialidade(dr_cardio, propranolol, joao).
%   true.  % cardiologista pode prescrever beta-bloqueador
%
permite_especialidade(Medico, Med, Pac).
```

#### 3.3. `pode_prescrever/4` - Autorização Completa de Prescrição
```prolog
% ============================================
% PODE_PRESCREVER/4
% ============================================
% Descrição: Predicado principal que verifica se um médico pode prescrever um
%            medicamento para um paciente para tratar uma doença específica.
%            Combina verificações de papel, especialidade e segurança.
%
% Parâmetros:
%   - Medico: átomo identificando o médico
%   - Med: átomo identificando o medicamento
%   - Pac: átomo identificando o paciente
%   - Doenca: átomo identificando a doença a tratar
%
% Comportamento:
%   - Verifica 4 critérios (todos devem ser satisfeitos):
%     1. Médico tem papel adequado (é médico)
%     2. Médico tem especialidade adequada
%     3. Medicamento trata a doença
%     4. Medicamento é seguro para o paciente
%   - Sucede apenas se todos os critérios são satisfeitos
%
% Política de autorização:
%   - Abordagem conservadora (todos os critérios devem passar)
%   - Prioriza segurança e adequação clínica
%   - Respeita limites de especialidade
%
% Exemplos de uso:
%   ?- pode_prescrever(dr_silva, amoxicilina, joao, pneumonia).
%   true.  % prescrição autorizada
%
%   ?- pode_prescrever(enf_maria, amoxicilina, joao, pneumonia).
%   false.  % enfermeiro não pode prescrever
%
pode_prescrever(Medico, Med, Pac, Doenca).
```

### 4. Validação de Farmácia e Administração

#### 4.1. `farmacia_deve_validar/1` - Verificação de Validação Necessária
```prolog
% ============================================
% FARMACIA_DEVE_VALIDAR/1
% ============================================
% Descrição: Determina se um medicamento requer validação da farmácia antes
%            de ser administrado (medicamentos controlados ou de alto custo).
%
% Parâmetros:
%   - Med: átomo identificando o medicamento
%
% Comportamento:
%   - Verifica se medicamento é controlado ou de alto custo
%   - Sucede se validação é necessária
%
farmacia_deve_validar(Med).
```

#### 4.2. Predicados Dinâmicos
```prolog
% ============================================
% PRESCRITO_POR/3, VALIDADO_POR/3
% ============================================
% Descrição: Predicados dinâmicos para rastrear prescrições e validações.
%            Permitem adicionar/remover fatos em tempo de execução.
%
% Parâmetros:
%   - prescrito_por(Medico, Med, Pac): registra prescrição
%   - validado_por(Farmaceutico, Med, Pac): registra validação
%
:- dynamic prescrito_por/3.
:- dynamic validado_por/3.
```

#### 4.3. `enfermeiro_pode_administrar/4` - Autorização de Administração
```prolog
% ============================================
% ENFERMEIRO_PODE_ADMINISTRAR/4
% ============================================
% Descrição: Verifica se um enfermeiro pode administrar um medicamento a um
%            paciente, considerando prescrição e validação quando necessária.
%
% Parâmetros:
%   - Enf: átomo identificando o enfermeiro
%   - Medico: átomo identificando o médico prescritor
%   - Med: átomo identificando o medicamento
%   - Pac: átomo identificando o paciente
%
% Comportamento:
%   - Verifica que Enf é enfermeiro
%   - Verifica que há prescrição válida (prescrito_por)
%   - Se medicamento requer validação, verifica que foi validado
%   - Sucede se todas as condições são satisfeitas
%
% Exemplos de uso:
%   ?- enfermeiro_pode_administrar(enf_maria, dr_silva, paracetamol, joao).
%   true.  % prescrição válida, não requer validação
%
enfermeiro_pode_administrar(Enf, Medico, Med, Pac).
```

### 5. Exames e Protocolos

#### 5.1. `pode_solicitar_exame/2` - Autorização de Solicitação de Exame
```prolog
% ============================================
% PODE_SOLICITAR_EXAME/2
% ============================================
% Descrição: Verifica se um profissional pode solicitar um exame específico.
%            Médicos podem solicitar qualquer exame, enfermeiros apenas laboratoriais.
%
% Parâmetros:
%   - Prof: átomo identificando o profissional
%   - Ex: átomo identificando o exame
%
% Comportamento:
%   - Regra 1: Médico pode solicitar qualquer exame
%   - Regra 2: Enfermeiro pode solicitar apenas exames laboratoriais
%
% Exemplos de uso:
%   ?- pode_solicitar_exame(dr_silva, hemograma).
%   true.  % médico pode solicitar
%
%   ?- pode_solicitar_exame(enf_maria, ressonancia).
%   false.  % enfermeiro não pode solicitar exame de imagem
%
pode_solicitar_exame(Prof, Ex).
```

#### 5.2. `precisa_exame/2` - Necessidade de Exame
```prolog
% ============================================
% PRECISA_EXAME/2
% ============================================
% Descrição: Determina se um paciente precisa de um exame específico baseado
%            nas doenças que possui.
%
% Parâmetros:
%   - Pac: átomo identificando o paciente
%   - Ex: átomo identificando o exame
%
% Comportamento:
%   - Obtém doenças do paciente
%   - Verifica se exame é recomendado para alguma doença
%   - Sucede se exame é necessário
%
% Exemplos de uso:
%   ?- precisa_exame(joao, hemograma).
%   true.  % joao tem doença que requer hemograma
%
precisa_exame(Pac, Ex).
```

### 6. Alocação de Leitos

#### 6.1. `pode_alocar_leito/3` - Alocação de Leito por Condição
```prolog
% ============================================
% PODE_ALOCAR_LEITO/3
% ============================================
% Descrição: Verifica se um profissional pode alocar um leito específico para
%            um paciente, baseado na condição do paciente.
%
% Parâmetros:
%   - Prof: átomo identificando o profissional
%   - Pac: átomo identificando o paciente
%   - Leito: átomo identificando o leito
%
% Comportamento:
%   - Verifica que Prof é médico
%   - Se paciente tem doença que requer UTI → leito deve ser UTI
%   - Caso contrário → leito deve ser enfermaria
%   - Usa if-then-else (->)
%
% Exemplos de uso:
%   ?- pode_alocar_leito(dr_silva, joao, leito_uti_1).
%   true.  % joao tem condição crítica
%
pode_alocar_leito(Prof, Pac, Leito).
```

### 7. Plano Terapêutico Dedutivo

#### 7.1. `plano_terapeutico/3` - Geração de Plano de Tratamento
```prolog
% ============================================
% PLANO_TERAPEUTICO/3
% ============================================
% Descrição: Gera um plano terapêutico completo para um paciente com uma doença,
%            combinando exames recomendados e medicamentos seguros.
%
% Parâmetros:
%   - Pac: átomo identificando o paciente
%   - Doenca: átomo identificando a doença
%   - Plano: lista ordenada de itens do plano (saída)
%
% Comportamento:
%   - Coleta todos os exames recomendados para a doença
%   - Coleta todos os medicamentos que tratam a doença E são seguros
%   - Concatena exames e medicamentos
%   - Remove duplicatas e ordena
%   - Retorna plano completo
%
% Uso:
%   - Suporte à decisão clínica
%   - Geração automática de protocolos
%   - Planejamento de tratamento
%
% Exemplos de uso:
%   ?- plano_terapeutico(joao, pneumonia, P).
%   P = [hemograma, raio_x_torax, amoxicilina, azitromicina].
%
plano_terapeutico(Pac, Doenca, Plano).
```

### 8. Explicabilidade (Por que permitiu/negou?)

#### 8.1. `justifica_prescricao/5` - Justificativa Estruturada
```prolog
% ============================================
% JUSTIFICA_PRESCRICAO/5
% ============================================
% Descrição: Coleta todos os motivos de autorização ou negação de uma prescrição,
%            retornando lista de tags estruturadas.
%
% Parâmetros:
%   - Medico: átomo identificando o médico
%   - Med: átomo identificando o medicamento
%   - Pac: átomo identificando o paciente
%   - Doenca: átomo identificando a doença
%   - Motivos: lista ordenada de átomos representando motivos (saída)
%
% Comportamento:
%   - Verifica sequencialmente múltiplos critérios
%   - Coleta tags de falha ou 'ok'
%   - Remove duplicatas e ordena
%
% Motivos possíveis:
%   - ok: prescrição autorizada
%   - nao_e_medico: profissional não é médico
%   - nao_trata_doenca: medicamento não trata a doença
%   - especialidade_inadequada: especialidade não adequada
%   - alergia: paciente tem alergia
%   - contraindicado: medicamento contraindicado
%   - interacao: interação medicamentosa
%   - idade_inadequada: idade não apropriada
%   - peso_inadequado: peso não apropriado
%
justifica_prescricao(Medico, Med, Pac, Doenca, Motivos).
```

#### 8.2. `motivo_humano/2` - Mapeamento para Texto Legível
```prolog
% ============================================
% MOTIVO_HUMANO/2
% ============================================
% Descrição: Mapeia tags de motivos para mensagens legíveis em português.
%
% Parâmetros:
%   - Tag: átomo representando o motivo
%   - Texto: string contendo a mensagem legível
%
motivo_humano(Tag, Texto).
```

#### 8.3. `justifica_prescricao_texto/5` - Justificativa Textual
```prolog
% ============================================
% JUSTIFICA_PRESCRICAO_TEXTO/5
% ============================================
% Descrição: Gera justificativa em texto legível para uma prescrição,
%            traduzindo tags para mensagens humanizadas.
%
% Parâmetros:
%   - Medico: átomo identificando o médico
%   - Med: átomo identificando o medicamento
%   - Pac: átomo identificando o paciente
%   - Doenca: átomo identificando a doença
%   - Textos: lista de strings com mensagens legíveis (saída)
%
% Comportamento:
%   - Obtém motivos estruturados via justifica_prescricao/5
%   - Traduz cada tag para texto via motivo_humano/2
%   - Retorna lista de mensagens
%
% Exemplos de uso:
%   ?- justifica_prescricao_texto(dr_silva, aspirina, joao, dor, T).
%   T = ['alergia ao princípio ativo'].
%
justifica_prescricao_texto(Medico, Med, Pac, Doenca, Textos).
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

