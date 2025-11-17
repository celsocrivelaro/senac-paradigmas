**Tema:** 🔐 Sistema de Controle de Acesso Baseado em Papéis (RBAC)

---

## 🧩 Descrição do Problema

Você deve implementar um sistema de **controle de acesso baseado em papéis (RBAC - Role-Based Access Control)** em Prolog. O sistema gerencia permissões de usuários em uma organização, onde:

- **Usuários** recebem **papéis** (roles) como `admin`, `gerente`, `usuario`, `analista`
- **Papéis** podem **herdar** de outros papéis, formando uma hierarquia (ex.: `admin` > `gerente` > `usuario`)
- **Permissões** são associadas a papéis e podem ser:
  - **Gerais**: `permite(Papel, Acao)` - ex.: `permite(gerente, aprovar_despesa)`
  - **Com escopo**: `permite_no(Papel, Acao, Recurso)` - ex.: `permite_no(gerente, editar, classe(relatorio))`
- **Exceções** (negações) podem **sobrepor** permissões herdadas (política **deny-overrides**)
- **Recursos** podem ser organizados em **classes** (ex.: `relatorio/*`) ou **instâncias** específicas (ex.: `relatorio_q1`)

O sistema deve determinar se um usuário tem permissão para executar uma ação, considerando herança de papéis e exceções explícitas.

---

## 🎯 Objetivos de Aprendizagem

- Modelar hierarquias e herança usando o paradigma lógico
- Utilizar fatos e regras para expressar políticas de acesso
- Implementar recursão para fecho transitivo de herança
- Criar predicados explicativos para decisões de acesso
- Aplicar negação como falha para exceções
- Organizar o sistema em múltiplos arquivos

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

Implemente os seguintes predicados principais:

### 1. Herança de Papéis
```prolog
% Fecho transitivo de herança
tem_superpapel(Papel, SuperPapel).
```

### 2. Verificação de Permissões
```prolog
% Permissão geral (sem escopo de recurso)
tem_permissao(Usuario, Acao).

% Permissão com escopo de recurso
tem_permissao_no_recurso(Usuario, Acao, Recurso).
```

### 3. Verificação de Exceções
```prolog
% Verifica se há negação ativa
negacao_ativa(Usuario, Acao).
negacao_ativa_no(Usuario, Acao, Recurso).
```

### 4. Predicados Explicativos
```prolog
% Explica por que foi permitido ou negado
motivo(Usuario, Acao, Recurso, Motivo).

% Lista todos os papéis herdados
papeis_efetivos(Usuario, ListaPapeis).
```

---

## ✨ Extensões (Escolha pelo menos UMA)

1. **Grupos e Times**: Implementar `membro_de(Usuario, Grupo)` e `grupo_tem_papel(Grupo, Papel)` com propagação de papéis via grupo

2. **Janelas Temporais**: Adicionar `permite_durante(Papel, Acao, Janela)` e verificação de tempo de acesso

3. **Delegação Temporária**: Implementar `delegado(Proprietario, Delegado, Acao, Recurso, DataExpiracao)` para concessões temporárias

4. **Auditoria Completa**: Criar `justifica(Usuario, Acao, Recurso, TrilhaCompleta)` que retorna toda a cadeia de raciocínio

5. **ABAC Leve**: Adicionar atributos do usuário (departamento, localização) e regras condicionais baseadas em atributos

---

## ▶️ Exemplos de Execução

```prolog
% Verificar herança de papéis
?- tem_superpapel(admin, usuario).
true.

% Verificar permissão geral
?- tem_permissao(joao, aprovar_despesa).
true.

% Verificar permissão com escopo
?- tem_permissao_no_recurso(joao, editar, relatorio_q1).
true.

% Listar todos os usuários que podem executar uma ação
?- tem_permissao(Usuario, criar_usuario).

% Verificar por que foi negado
?- motivo(joao, deletar, relatorio_x, Motivo).
Motivo = negado_por_excecao.
```

---

## 🧾 Explicabilidade das Decisões

### Formato de Explicação (Lista):
```prolog
[
    papel_direto(gerente),
    herda_de(admin),
    permissao_herdada(editar, classe(relatorio)),
    sem_negacao_ativa
].
```

### Formato de Explicação (Estrutura):
```prolog
decisao_acesso(
    usuario(joao),
    acao(editar),
    recurso(relatorio_q1),
    resultado(permitido),
    motivos([
        papel_direto(gerente),
        permissao_por_classe(relatorio)
    ])
).
```

### Motivos de Negação:
```prolog
motivo_negacao(joao, deletar, relatorio_x, [
    negacao_explicita,
    nega_no(joao, deletar, recurso(relatorio_x))
]).
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

1. A base de dados deve conter **pelo menos 5 usuários**, **4 papéis**, **10 permissões** e **3 exceções**
2. Teste casos de **herança múltipla** (papéis que herdam de vários ancestrais)
3. Teste casos de **conflito** (permissão herdada vs. negação explícita)
4. Documente claramente a **política de resolução** (deny-overrides)
5. Todas as decisões devem ser **explicáveis** no arquivo de saída

