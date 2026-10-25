# Lógica Dedutiva

Tema: Lógico

## **🧠 1. Teoria Dedutiva e Sistemas Especialistas**

Um **sistema especialista** é um programa que usa lógica dedutiva para tomar decisões baseadas em regras e fatos — uma simulação do raciocínio humano em um domínio específico.

### **Exemplos de sistemas especialistas**

1. **MYCIN (1976):** diagnóstico médico de infecções bacterianas (um dos primeiros sistemas especialistas).
2. **DENDRAL:** identificava estruturas moleculares de compostos químicos.
3. **CLIPS (NASA):** framework baseado em regras para controle de processos espaciais.
4. **Sistema especialista jurídico:** determina sentenças baseadas em regras legais.

Esses sistemas compartilham uma base de conhecimento e um **motor de inferência** que aplica dedução lógica — exatamente o que o Prolog oferece.

---

## **💬 2. Entrada e Saída (I/O) em Prolog**

Prolog também permite **entrada e saída de dados**, embora isso seja menos comum, já que ele é voltado à dedução lógica.

### **Leitura e escrita no console**

```
% Lê um número e escreve o dobro
ler_e_dobrar :-
    write('Digite um número: '),
    read(X),
    Y is X * 2,
    write('O dobro é: '), write(Y), nl.
```

### **Escrita em arquivo**

```
escrever_arquivo :-
    open('resultado.txt', write, Stream),
    write(Stream, 'Prolog é interessante!'),
    close(Stream).
```

### **Leitura de arquivo**

```
ler_arquivo :-
    open('resultado.txt', read, Stream),
    read_line_to_string(Stream, Conteudo),
    write('Conteúdo: '), write(Conteudo), nl,
    close(Stream).
```

---

## **⚙️ 3. Exemplo Avançado: Sistema Especialista Médico Simplificado**

### **Base de Conhecimento**

```
% Fatos
sintoma(ana, febre).
sintoma(ana, dor_de_cabeca).
sintoma(ana, fadiga).

doenca(gripe) :- sintoma(_, febre), sintoma(_, dor_de_cabeca).
doenca(dengue) :- sintoma(_, febre), sintoma(_, fadiga), sintoma(_, manchas_na_pele).

% Regra para diagnóstico
diagnostico(Pessoa, Doenca) :-
    sintoma(Pessoa, febre),
    (
        (sintoma(Pessoa, dor_de_cabeca), Doenca = gripe);
        (sintoma(Pessoa, fadiga), sintoma(Pessoa, manchas_na_pele), Doenca = dengue)
    ).
```

### **Consulta**

```
?- diagnostico(ana, D).
D = gripe.
```

Esse programa demonstra como **a dedução automática** ocorre — sem loops, sem if, apenas com inferência lógica.

---

## **🤖 4. Exemplo Complexo: Sistema de Planejamento de Viagens**

```
% Fatos sobre cidades e conexões
rota(sao_paulo, rio_de_janeiro, 430).
rota(rio_de_janeiro, belo_horizonte, 440).
rota(sao_paulo, curitiba, 410).
rota(curitiba, porto_alegre, 710).

% As rotas são bidirecionais
conectado(X, Y, D) :- rota(X, Y, D).
conectado(X, Y, D) :- rota(Y, X, D).

% Regra recursiva para encontrar caminhos
caminho(Origem, Destino, [Origem, Destino], D) :-
    conectado(Origem, Destino, D).

caminho(Origem, Destino, [Origem|Resto], Distancia) :-
    conectado(Origem, Intermediario, D1),
    caminho(Intermediario, Destino, Resto, D2),
    Distancia is D1 + D2.

% Consulta exemplo:
% ?- caminho(sao_paulo, porto_alegre, C, D).
% C = [sao_paulo, curitiba, porto_alegre], D = 1120.
```

Esse programa implementa **busca recursiva de caminhos** — uma aplicação de **raciocínio dedutivo e busca de soluções**.

---

### **🏥 Exemplos Clássicos de Sistemas Especialistas**

### **1. MYCIN (Stanford, 1976)**

- Domínio: Diagnóstico médico de infecções bacterianas.
- Funcionamento: Utilizava cerca de 450 regras para determinar doenças e recomendar antibióticos.
- Técnica: Raciocínio dedutivo baseado em *encadeamento para trás* (backward chaining).

### **2. DENDRAL (1965)**

- Domínio: Química orgânica.
- Objetivo: Determinar estruturas moleculares a partir de dados de espectrometria.
- Impacto: Um dos primeiros sistemas especialistas científicos bem-sucedidos.

### **3. XCON (DEC, 1980)**

- Domínio: Configuração de computadores VAX.
- Função: Gerava configurações personalizadas de hardware com base nas necessidades do cliente.
- Técnica: Regras de produção com *encadeamento para frente* (forward chaining).
- Resultado: Economizou milhões de dólares em erros de configuração.

### **4. CLIPS (NASA, 1985)**

- Domínio: Ferramenta genérica para criar sistemas especialistas.
- Implementado em C, ainda é utilizado em controle de processos e sistemas embarcados.
- É um sistema de *inferência baseada em regras* semelhante ao Prolog.

---

### **💡 Exemplos Contemporâneos**

### **5. Sistema Jurídico Baseado em Regras**

- Domínio: Direito.
- Exemplo: Determinar se uma ação judicial é cabível com base em leis e precedentes.
- Fatos: tipo de crime, tempo decorrido, provas disponíveis.
- Regras: “Se o crime for doloso e o prazo prescricional não expirou, então a ação é cabível.”

### **6. Sistemas de Diagnóstico Automotivo**

- Domínio: Mecânica automotiva.
- Exemplo: Detectar falhas em sensores de veículos.
- Implementação comum: sistemas embarcados com lógica fuzzy e regras dedutivas.

### **7. Sistemas de Recomendação Baseados em Regras**

- Domínio: Marketing e e-commerce.
- Exemplo: “Se o cliente comprou um celular, recomendar capinhas compatíveis.”
- Combina inferência lógica com dados estatísticos.

### **8. Sistemas Agropecuários**

- Domínio: Agricultura de precisão.
- Exemplo: Diagnóstico de pragas ou doenças em plantações.
- Regra: “Se as folhas apresentarem manchas e o solo estiver úmido, então há risco de fungos.”