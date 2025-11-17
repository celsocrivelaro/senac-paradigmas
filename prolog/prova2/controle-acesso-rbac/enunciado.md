**Tema:** 🔐 Sistema de Controle de Acesso Baseado em Papéis (RBAC)

---

## 🎯 Objetivo

Modelar em **Prolog** um sistema de controle de acesso com:

1. **Papéis hierárquicos** (ex.: `admin` > `gerente` > `usuario`)
2. **Permissões** por ação e **escopo de recurso**:
   - Permissões gerais: `permite(Papel, Acao)`
   - Permissões com escopo: `permite_no(Papel, Acao, RecursoOuClasse)`
3. **Herança de papéis** e **herança de permissões** (fecho transitivo)
4. **Exceções/negações** que podem **sobrepor** permissões herdadas (política **deny-overrides**)
5. **Escopos de recurso**: classes (ex.: `relatorio/*`) e instâncias (ex.: `relatorio_q1`)

O sistema deve responder consultas como:

```prolog
tem_permissao(joao, editar_relatorio).
tem_permissao_no_recurso(joao, editar, relatorio_q1).
motivo(joao, editar, relatorio_q2, Motivo).
```

---

## 🧩 Descrição do Problema

Você é o **arquiteto de segurança** responsável por implementar o controle de acesso de uma organização.

A organização possui uma hierarquia de papéis (admin, gerente, usuário, analista) onde papéis superiores herdam permissões de papéis inferiores. Cada papel tem permissões gerais (ex.: aprovar despesas) e permissões específicas por recurso (ex.: editar relatórios).

Implemente um sistema lógico que:
- Modele a hierarquia de papéis com herança transitiva
- Atribua papéis a usuários
- Defina permissões gerais e com escopo de recurso
- Implemente exceções (negações) que sobrepõem permissões herdadas
- Resolva consultas de acesso considerando toda a cadeia de herança
- Explique as decisões de acesso (por que foi permitido ou negado)

---

## 🎯 Objetivos de Aprendizagem

- Modelar hierarquias e herança usando o paradigma lógico
- Utilizar fatos e regras para expressar políticas de acesso
- Implementar recursão para fecho transitivo de herança
- Criar predicados explicativos para decisões de acesso
- Aplicar negação como falha para exceções
- Organizar o sistema em múltiplos arquivos

---

## 🧩 Base de Fatos (Exemplo Didático)

### Papéis e Herança
```prolog
% =========================
% PAPÉIS E HERANÇA
% =========================
papel(admin).
papel(gerente).
papel(usuario).
papel(analista).

% Hierarquia: admin > gerente > usuario ; analista é paralelo
herda_papel(admin, gerente).
herda_papel(gerente, usuario).
```

### Usuários
```prolog
% =========================
% USUÁRIOS
% =========================
tem_papel(joao, gerente).
tem_papel(maria, admin).
tem_papel(carla, analista).
tem_papel(pedro, usuario).
```

### Permissões Gerais
```prolog
% =========================
% PERMISSÕES GERAIS (sem escopo)
% permite(Papel, Acao)
% =========================
permite(usuario, ler_dashboard).
permite(gerente, aprovar_despesa).
permite(admin, criar_usuario).

% Analista tem leitura/edição de relatórios por função
permite(analista, ler_relatorio).
permite(analista, editar_relatorio).
```

### Permissões com Escopo
```prolog
% =========================
% PERMISSÕES COM ESCOPO
% permite_no(Papel, Acao, RecursoOuClasse)
% classe de recurso: relatorio/* ; instância: relatorio_q1
% =========================
permite_no(usuario, ler, classe(relatorio)).
permite_no(gerente, editar, classe(relatorio)).
permite_no(admin, deletar, classe(relatorio)).
permite_no(gerente, exportar, recurso(relatorio_q1)).   % exceção positiva pontual
```

### Recursos e Classes
```prolog
% =========================
% RECURSOS E SUAS CLASSES
% =========================
pertence_a(relatorio_q1, relatorio).
pertence_a(relatorio_q2, relatorio).
pertence_a(planilha_financeira, planilha).
```

### Exceções e Negações
```prolog
% =========================
% EXCEÇÕES / NEGAÇÕES
% negam permissões (deny-overrides)
% =========================
nega(joao, criar_usuario).                         % joao não pode, mesmo que herde
nega_no(joao, editar, recurso(relatorio_q2)).     % joao não pode editar o q2
nega_papel(analista, deletar_relatorio).          % ninguém com analista pode deletar_relatorio
```

### Sinônimos de Ações (Opcional)
```prolog
% =========================
% SINÔNIMOS DE AÇÕES (opcional)
% =========================
acao_equivalente(editar_relatorio, editar).
acao_equivalente(ler_relatorio, ler).
acao_equivalente(deletar_relatorio, deletar).
```

---

## 📂 Estrutura dos Arquivos e Entrada-Saída

### Arquivos de Entrada
- **`entrada.txt`**: Contém os fatos da base de conhecimento (papéis, usuários, permissões, exceções, recursos)

### Arquivos Prolog
- **`principal.pl`**: Arquivo principal que carrega os demais módulos e a base de dados
- **`heranca.pl`**: Predicados relacionados à herança de papéis
- **`permissoes.pl`**: Predicados de verificação de permissões
- **`excecoes.pl`**: Predicados de negação e deny-overrides
- **`explicacao.pl`**: Predicados explicativos

### Arquivo de Saída
- **`saida.txt`**: Resultados das consultas e explicações das decisões

---

## 🧱 Tarefas Obrigatórias

### 1. Herança de Papéis

```prolog
% Fecho transitivo de herança (reflexivo e transitivo)
% Um papel é superpapel de si mesmo
tem_superpapel(P, P).

% Um papel herda de seus ancestrais recursivamente
tem_superpapel(P, S) :-
    herda_papel(P, Pai),
    tem_superpapel(Pai, S).
```

### 2. Normalização de Ações

```prolog
% Normaliza ações para sua forma base (trata sinônimos)
acao_base(Acao, Base) :-
    (acao_equivalente(Acao, B) -> Base = B ; Base = Acao).
```

### 3. Verificação de Exceções (Deny-Overrides)

```prolog
% Verifica se há negação ativa para ação geral
negacao_ativa(User, AcaoBase) :-
    % Negação direta no usuário
    (nega(User, AcaoBase)
    % OU negação no papel do usuário
    ; tem_papel(User, P), nega_papel(P, AcaoBase)
    ).

% Verifica se há negação ativa para ação em recurso específico
negacao_ativa_no(User, AcaoBase, Recurso) :-
    % Negação direta no recurso específico
    (nega_no(User, AcaoBase, recurso(Recurso))
    % OU negação na classe do recurso
    ; (pertence_a(Recurso, Classe),
       nega_no(User, AcaoBase, classe(Classe)))
    % OU negação no papel (vale globalmente)
    ; tem_papel(User, P), nega_papel(P, AcaoBase)
    ).
```

### 4. Permissão Geral (Sem Escopo)

```prolog
% Verifica se usuário tem permissão para ação geral
tem_permissao(User, Acao) :-
    % Normaliza a ação
    acao_base(Acao, A),
    % Verifica que não há negação (deny-overrides)
    \+ negacao_ativa(User, A),
    % Usuário tem algum papel
    tem_papel(User, P),
    % Papel permite a ação (diretamente ou por herança)
    (permite(P, A)
    ; (tem_superpapel(P, S), permite(S, A))
    ).
```

### 5. Permissão com Escopo de Recurso

```prolog
% Verifica se usuário tem permissão para ação em recurso específico
tem_permissao_no_recurso(User, Acao, Recurso) :-
    % Normaliza a ação
    acao_base(Acao, A),
    % Verifica que não há negação geral
    \+ negacao_ativa(User, A),
    % Verifica que não há negação específica no recurso
    \+ negacao_ativa_no(User, A, Recurso),
    % Usuário tem algum papel
    tem_papel(User, P),
    (
        % Permissão específica para o recurso
        permite_no(P, A, recurso(Recurso))
    ;
        % Permissão por classe do recurso
        (pertence_a(Recurso, Classe),
         (permite_no(P, A, classe(Classe))
         ; (tem_superpapel(P, S), permite_no(S, A, classe(Classe)))
         )
        )
    ;
        % Fallback: permissão geral equivalente
        (permite(P, A)
        ; (tem_superpapel(P, S), permite(S, A))
        )
    ).
```

### 6. Predicados Explicativos

```prolog
% Explica por que foi permitido ou negado
motivo(User, Acao, Recurso, Motivo) :-
    acao_base(Acao, A),
    (Recurso == none ->
        % Sem recurso específico
        (negacao_ativa(User, A) ->
            Motivo = negado_por_excecao
        ; (tem_permissao(User, A) ->
            Motivo = permitido_por_papel
          ; Motivo = ausente_de_permissao)
        )
    ;
        % Com recurso específico
        (negacao_ativa_no(User, A, Recurso) ->
            Motivo = negado_no_recurso
        ; (tem_permissao_no_recurso(User, A, Recurso) ->
            Motivo = permitido_por_classe_ou_instancia
          ; Motivo = ausente_de_permissao_no_escopo)
        )
    ).

% Lista todos os papéis efetivos (diretos + herdados)
papeis_efetivos(Usuario, ListaPapeis) :-
    findall(P,
        (tem_papel(Usuario, PapelDireto),
         tem_superpapel(PapelDireto, P)),
        ListaComDuplicatas),
    sort(ListaComDuplicatas, ListaPapeis).
```

---

## ✨ Extensões (Escolha pelo menos UMA)

| Conceito | Extensão |
|----------|----------|
| **Grupos/Times** | Implementar `membro_de(User, Grupo)` + `grupo_tem_papel(Grupo, Papel)` + propagação de papéis via grupo. Usuários herdam papéis de seus grupos. |
| **Conflitos e Precedências** | Estratégias de resolução: *deny-overrides*, *permit-overrides*, *first-applicable*. Implementar `estrategia_resolucao/1` configurável. |
| **ABAC Leve** | Atributos do usuário/recurso (ex.: `departamento(User, D)`, `dono(Recurso, User)`), e regras do tipo "`gerente` do mesmo departamento pode `editar`". |
| **Janela Temporal** | `permite_durante(Papel, Acao, Janela)` e checagem de tempo. Permissões válidas apenas em horários específicos. |
| **Auditoria/Explicação** | `justifica(User, Acao, Recurso, ListaDeMotivos)` com trilha completa de por que permitiu/negou, incluindo papéis e regras acionadas. |
| **Delegação** | `delegado(Owner, Delegate, Acao, Recurso, Ate)` criando concessões temporárias. Proprietário pode delegar permissões a outros usuários. |

### Exemplo de Extensão: Grupos e Times
```prolog
% Grupos e membros
grupo(ti).
grupo(financeiro).
grupo(rh).

membro_de(joao, ti).
membro_de(maria, ti).
membro_de(carla, financeiro).
membro_de(pedro, rh).

% Papéis atribuídos a grupos
grupo_tem_papel(ti, gerente).
grupo_tem_papel(financeiro, analista).
grupo_tem_papel(rh, usuario).

% Usuário herda papéis de seus grupos
tem_papel(User, Papel) :-
    membro_de(User, Grupo),
    grupo_tem_papel(Grupo, Papel).

% Exemplo de uso:
% ?- tem_papel(joao, gerente).
% true.  % joao herda gerente do grupo ti
```

---

## ▶️ Exemplos de Execução

```prolog
% 1) Herança de papéis
?- tem_superpapel(gerente, usuario).
true.

?- tem_superpapel(admin, usuario).
true.

% 2) Permissões gerais
?- tem_permissao(maria, criar_usuario).    % maria é admin
true.

?- tem_permissao(joao, criar_usuario).     % negado explicitamente
false.

?- tem_permissao(joao, aprovar_despesa).   % joao é gerente
true.

% 3) Escopo por classe (relatorio/*)
?- tem_permissao_no_recurso(joao, editar, relatorio_q1).
true.   % gerente pode editar classe(relatorio), sem negação específica

?- tem_permissao_no_recurso(joao, editar, relatorio_q2).
false.  % nega_no para q2

% 4) Permissão específica de instância
?- tem_permissao_no_recurso(joao, exportar, relatorio_q1).
true.   % gerente tem permite_no(gerente, exportar, recurso(relatorio_q1))

% 5) Permissões do analista (e negação no papel)
?- tem_permissao(carla, editar_relatorio).
true.

?- tem_permissao(carla, deletar_relatorio).
false.  % nega_papel(analista, deletar_relatorio)

% 6) Usuário básico herdando leitura de classe
?- tem_permissao_no_recurso(pedro, ler, relatorio_q2).
true.  % usuario pode ler classe(relatorio)

% 7) Listar todos os usuários que podem criar usuário
?- tem_permissao(Usuario, criar_usuario).
Usuario = maria.  % apenas maria (admin) pode

% 8) Verificar motivos
?- motivo(joao, criar_usuario, none, Motivo).
Motivo = negado_por_excecao.

?- motivo(joao, editar, relatorio_q2, Motivo).
Motivo = negado_no_recurso.

?- motivo(maria, deletar, relatorio_q1, Motivo).
Motivo = permitido_por_classe_ou_instancia.

% 9) Listar papéis efetivos de um usuário
?- papeis_efetivos(joao, Papeis).
Papeis = [gerente, usuario].  % joao tem gerente e herda usuario

?- papeis_efetivos(maria, Papeis).
Papeis = [admin, gerente, usuario].  % maria tem admin e herda gerente e usuario

% 10) Verificar normalização de ações
?- acao_base(editar_relatorio, Base).
Base = editar.

?- acao_base(ler_relatorio, Base).
Base = ler.

% 11) Listar todas as permissões de um usuário em um recurso
?- tem_permissao_no_recurso(joao, Acao, relatorio_q1).
Acao = ler ;
Acao = editar ;
Acao = exportar.

% 12) Verificar herança transitiva
?- tem_superpapel(admin, P).
P = admin ;
P = gerente ;
P = usuario.
```

---

## � Conceitos Aplicados

- **Recursão**: Fecho transitivo de herança de papéis (`tem_superpapel/2`)
- **Modelagem Hierárquica**: Papéis organizados em hierarquia com herança de permissões
- **Combinação de Fatos**: Busca por permissões diretas e herdadas através de múltiplos papéis
- **Negação como Falha**: Verificação de ausência de negações (`\+ negacao_ativa/2`)
- **Política Deny-Overrides**: Negações explícitas sobrepõem permissões herdadas
- **Normalização**: Tratamento de sinônimos de ações (`acao_base/2`)
- **Findall e Agregação**: Coleta de todos os papéis efetivos de um usuário
- **Explicabilidade**: Geração automática de motivos para decisões de acesso

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

1. A base de dados deve conter **pelo menos 5 usuários**, **4 papéis**, **10 permissões** e **3 exceções**
2. Teste casos de **herança transitiva** (ex.: admin → gerente → usuario)
3. Teste casos de **conflito** (permissão herdada vs. negação explícita) - negação deve vencer
4. Documente claramente a **política de resolução** (deny-overrides)
5. Todas as decisões devem ser **explicáveis** através do predicado `motivo/4`
6. Implemente **permissões gerais** e **permissões com escopo** (classe e instância)
7. Use **normalização de ações** para tratar sinônimos (ex.: `editar_relatorio` = `editar`)
8. Teste **herança de permissões** (papel filho herda permissões do pai)
9. Implemente **pelo menos uma extensão** da tabela de extensões sugeridas
10. Organize o código em **múltiplos arquivos** conforme a estrutura sugerida

