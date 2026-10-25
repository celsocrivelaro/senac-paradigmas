# Prolog: Corte

Tema: Lógico

---

# **🧮 Notas de Aula: O Corte (!) em Prolog**

---

## **🧠 1. Relembrando: O que é o corte (!)**

O **corte** (!) é um **predicado especial** em Prolog usado para **controlar o retrocesso** (*backtracking*).

Ele **impede que o interpretador volte atrás** para buscar alternativas anteriores, “congelando” as escolhas feitas até aquele ponto da execução.

Em outras palavras:

> O corte faz o Prolog
> 
> 
> **assumir definitivamente**
> 

---

## **⚙️ 2. Funcionamento básico**

```
predicado :- condicao1, !, condicao2.
```

- Antes do corte: o Prolog pode tentar alternativas anteriores se algo falhar.
- Depois do corte: se algo falhar, o Prolog **não volta mais** para tentar outras regras do mesmo predicado.

---

## **💡 3. Exemplo simples:**

## **max/3**

```
max(X, Y, X) :- X >= Y, !.
max(_, Y, Y).
```

- Se X >= Y, o corte é atingido e o Prolog **não tentará** a segunda cláusula.
- Caso contrário, ele segue para a próxima regra.

---

## **🧩 4. Tipos de corte**

| **Tipo** | **Nome** | **Efeito** | **Altera lógica?** |
| --- | --- | --- | --- |
| **Verde** | Corte “inofensivo” | Melhora eficiência | ❌ Não |
| **Vermelho** | Corte “lógico” | Controla o fluxo lógico | ✅ Sim |

---

## **🧮 5. Uso do corte no cálculo de Fibonacci**

### **📘 a) Implementação**

### **sem corte**

```
fib(0, 0).
fib(1, 1).
fib(N, F) :-
    N > 1,
    N1 is N - 1,
    N2 is N - 2,
    fib(N1, F1),
    fib(N2, F2),
    F is F1 + F2.
```

### **Problema:**

Mesmo com as cláusulas base (fib(0,0) e fib(1,1)), o Prolog ainda **verifica todas as cláusulas** em busca de possíveis soluções, mesmo quando já encontrou uma correta.

---

### **📗 b) Implementação**

### **com corte**

```
fib(0, 0) :- !.
fib(1, 1) :- !.
fib(N, F) :-
    N > 1,
    N1 is N - 1,
    N2 is N - 2,
    fib(N1, F1),
    fib(N2, F2),
    F is F1 + F2.
```

### **Explicação:**

- Quando fib(0,0) ou fib(1,1) é verdade, o corte impede o Prolog de tentar as outras regras.
- Assim, evita verificações desnecessárias — **ganho de eficiência**.

### **Exemplo de execução:**

```
?- fib(1, X).
X = 1.       % o corte impede que o Prolog tente a 3ª regra
```

---

### **⚙️ c) Comportamento do backtracking**

Sem o corte:

1. O Prolog testa fib(0, 0) → falha.
2. Testa fib(1, 1) → falha.
3. Finalmente testa a terceira cláusula.

Com o corte:

- Assim que fib(0, 0) ou fib(1, 1) é satisfeita, o corte **impede retrocesso**, tornando a execução mais direta.

---

## **🧠 6. Visualização do fluxo (versão com corte)**

```
fib(2, F)
 ├── N=2 > 1
 ├── fib(1, F1) → usa regra 2 → ! → retorna F1 = 1
 ├── fib(0, F2) → usa regra 1 → ! → retorna F2 = 0
 └── F = 1 + 0 = 1
```

O corte evita que fib(1, _) e fib(0, _) voltem a tentar a regra recursiva, simplificando o caminho.

---

## **📈 7. Benefícios do corte no Fibonacci**

| **Aspecto** | **Sem Corte** | **Com Corte** |
| --- | --- | --- |
| Retrocesso | Ocorre em todos os níveis | Eliminado nos casos base |
| Desempenho | Mais lento | Mais rápido |
| Clareza | Totalmente declarativo | Um pouco mais procedural |
| Uso típico | Ensino e clareza conceitual | Programas otimizados |

---

## **⚠️ 8. Cuidados no uso**

- Não abuse do corte — use-o **apenas** quando tiver certeza de que:
    - Não existem outras soluções válidas após aquele ponto.
    - O corte **não altera** a lógica pretendida.
- Em algoritmos recursivos como Fibonacci, o corte **é verde** — apenas melhora eficiência, sem mudar o resultado.

---

## **🧩 9. Exercício proposto**

1. Implemente uma versão de fib/2 com **contagem de chamadas recursivas**, para observar o ganho de desempenho com o corte.
2. Compare o número de chamadas entre as versões com e sem !.

---

## —

Exemplo em outra situação

---

## **💡 3. Exemplo simples**

```
max(X, Y, X) :- X >= Y, !.
max(_, Y, Y).
```

### **Explicação:**

- Se X >= Y, o corte é alcançado e **as alternativas são descartadas**.
- Caso contrário, a primeira cláusula falha antes do corte e o Prolog tenta a segunda.

### **Exemplo de consulta:**

```
?- max(3, 5, M).
M = 5.

?- max(7, 2, M).
M = 7.
```

Se o corte não existisse, mesmo depois de X >= Y ser verdadeiro, o Prolog tentaria a segunda cláusula — o corte impede isso.

---

## **🧩 4. Tipos de corte**

### **a)**

### **Corte verde (green cut)**

- Usado **apenas para eficiência** — não altera a lógica do programa, só evita buscas desnecessárias.
- Exemplo: o caso do max/3 acima.

### **b)**

### **Corte vermelho (red cut)**

- **Altera a lógica** do programa.
- Serve para **forçar decisões** (por exemplo, simular if-then-else).
- Deve ser usado com cuidado.

### **Exemplo:**

```
classificacao(X, positiva) :- X > 0, !.
classificacao(X, negativa) :- X < 0, !.
classificacao(0, neutra).
```

Sem os cortes, classificacao(0, neutra) poderia ser tentada mesmo depois de X > 0 falhar.

---

## **🧭 5. Comportamento no backtracking**

Considere:

```
teste(a).
teste(b).
teste(c).

exemplo(X) :- teste(X), X = b, !.
```

Consulta:

```
?- exemplo(X).
X = b.
```

O corte evita que o Prolog volte para tentar teste(c) após encontrar X = b.

---

## **⚠️ 6. Cuidados e boas práticas**

- ❌ **Evite cortes vermelhos** sempre que possível: eles dificultam a leitura e a manutenção do código.
- ✅ Prefira **reescrever a lógica** de modo declarativo.
- 📈 Use **cortes verdes** para **otimizar desempenho**, não para controlar a lógica.

---

## **🧩 7. Alternativas ao corte**

Em muitos casos, você pode substituir cortes por **construções mais claras**, como:

```
(Cond -> Then ; Else)
```

Por exemplo:

```
max(X, Y, M) :- (X >= Y -> M = X ; M = Y).
```

Essa forma é mais declarativa e evita o uso explícito de !.

---

## **📚 8. Resumo**

| **Tipo de Corte** | **Função** | **Altera lógica?** | **Exemplo típico** |
| --- | --- | --- | --- |
| **Verde** | Otimização (evita buscas redundantes) | ❌ Não | max/3 |
| **Vermelho** | Controle lógico (if-then-else) | ✅ Sim | classificacao/2 |
| **Nenhum** | Total backtracking | - | busca completa |

---

## **🧪 9. Exercício proposto**

1. Implemente sinal(X, Sinal) que retorna:
    - Sinal = positivo se X > 0
    - Sinal = negativo se X < 0
    - Sinal = zero caso contrário
        
        Usando cortes vermelhos.
        
2. Refaça a mesma lógica sem cortes, usando (-> ; ).

---

Se quiser, posso complementar estas notas com **diagramas de execução passo a passo do corte** ou com **exercícios resolvidos**, mostrando o fluxo de backtracking antes e depois do !.

Quer que eu adicione isso também?