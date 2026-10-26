# Concorrência: Promises

Tema: Concorrente

## **🧩 O que é uma Promise**

Uma **Promise** (ou *promessa*) é um **objeto que representa o resultado eventual de uma operação assíncrona** — ou seja, uma tarefa que pode levar algum tempo para ser concluída (como uma requisição HTTP, leitura de arquivo, ou consulta a banco de dados), mas que será resolvida no futuro com sucesso ou falha.

Em termos simples:

> Uma *Promise* representa um valor que ainda não existe, mas vai existir, e permite encadear o que fazer com ele sem cair no *callback hell*.

---

## **🔄 Estados de uma Promise**

Uma Promise pode estar em **três estados principais**:

1. **Pending (pendente)** — o estado inicial, ainda aguardando o resultado da operação.
2. **Fulfilled (resolvida)** — a operação foi concluída com sucesso, e o valor está disponível.
3. **Rejected (rejeitada)** — a operação falhou, e o erro está disponível.

Uma vez que uma Promise sai do estado *pending*, ela se torna **imutável** — ou seja, não pode mudar de *fulfilled* para *rejected* depois.

---

## **💡 Estrutura básica**

Exemplo em **JavaScript**:

```
const minhaPromise = new Promise((resolve, reject) => {
  const sucesso = true;

  if (sucesso) {
    resolve("Operação concluída com sucesso!");
  } else {
    reject("Houve um erro na operação.");
  }
});

minhaPromise
  .then(resultado => console.log(resultado))   // executado se der certo
  .catch(erro => console.error(erro))         // executado se der erro
  .finally(() => console.log("Finalizado"));  // sempre executado
```

Explicando:

- resolve() indica sucesso e passa o valor resultante.
- reject() indica falha e passa o erro.
- .then() trata o sucesso.
- .catch() trata o erro.
- .finally() roda sempre, independentemente do resultado.

---

## **🧠 Motivação e benefícios**

Antes das *Promises*, o código assíncrono em JavaScript era tratado com funções de callback, o que frequentemente resultava em **código difícil de ler e manter**:

```jsx
// Exemplo com callback hell
buscarDados(url, function(resultado) {
  processarDados(resultado, function(processado) {
    salvar(processado, function(resposta) {
      console.log("Concluído!");
    });
  });
});
```

Com *Promises*, isso se torna muito mais legível:

```
buscarDados(url)
  .then(processarDados)
  .then(salvar)
  .then(() => console.log("Concluído!"))
  .catch(console.error);
```

---

## **⚙️ Encadeamento e composição**

Promises podem ser **encadeadas**, permitindo que você execute várias operações assíncronas em sequência.

Também é possível executar múltiplas Promises em paralelo com métodos utilitários:

- Promise.all() — espera todas as Promises serem resolvidas.
- Promise.race() — retorna o resultado da primeira que terminar.
- Promise.allSettled() — retorna o estado de todas, independentemente de sucesso ou falha.
- Promise.any() — retorna a primeira que resolver com sucesso.

Exemplo:

```jsx
Promise.all([buscarUsuarios(), buscarPosts()])
  .then(([usuarios, posts]) => {
    console.log(usuarios, posts);
  })
  .catch(console.error);
```

---

## **🧵 Promises e async/await**

As palavras-chave async e await são uma **sintaxe moderna** que simplifica o uso de Promises:

```jsx
async function exemplo() {
  try {
    const dados = await buscarDados();
    console.log(dados);
  } catch (erro) {
    console.error(erro);
  }
}
```

Aqui, await pausa a execução da função até a Promise ser resolvida, tornando o código assíncrono muito mais parecido com o síncrono.

---

## **🚀 Conclusão**

**Promise** é um dos conceitos fundamentais da programação moderna, especialmente em linguagens que lidam com operações assíncronas — como **JavaScript**, **TypeScript**, **Python (asyncio)** e outras.

Ela:

- Simplifica o fluxo assíncrono.
- Melhora a legibilidade e manutenção do código.
- Evita aninhamentos complexos de callbacks.
- É base para recursos como async/await.

---

O conceito de **Promise** é tão útil que várias linguagens o adotaram, embora com nomes ou implementações diferentes.
---

## **⚡ 1. JavaScript / TypeScript**

### **🌐 Contexto**

A **Promise** surgiu oficialmente no **ECMAScript 2015 (ES6)** como uma forma padrão de lidar com operações assíncronas.

Ela é hoje **parte central** da linguagem, usada em conjunto com async e await.

### **💻 Exemplo:**

```jsx
fetch('https://api.exemplo.com/dados')
  .then(res => res.json())
  .then(data => console.log(data))
  .catch(err => console.error(err));
```

> Aqui, fetch() retorna uma Promise que será resolvida com a resposta HTTP.
> 

---

## **🐍 2. Python (asyncio e Futures)**

Em **Python 3.5+**, o conceito é implementado com **Futures** e **coroutines** no módulo asyncio.

A semântica é parecida com a das Promises — uma operação que será concluída no futuro.

### **💻 Exemplo:**

```python
import asyncio

async def tarefa():
    await asyncio.sleep(1)
    return "Concluído!"

async def main():
    resultado = await tarefa()
    print(resultado)

asyncio.run(main())
```

> Aqui, async def e await são o equivalente das Promises, e asyncio.Future é o objeto subjacente que representa o valor futuro.
> 

---

## **⚙️ 3. C# (.NET) — Tasks**

Em **C#**, o conceito análogo é a **classe Task** (ou Task<T>), usada desde o .NET Framework 4.0 com o *Task Parallel Library (TPL)*.

O comportamento é muito similar às Promises de JavaScript.

### **💻 Exemplo:**

```csharp
async Task<string> ObterDadosAsync()
{
    await Task.Delay(1000);
    return "Dados recebidos!";
}

var resultado = await ObterDadosAsync();
Console.WriteLine(resultado);
```

> Task representa uma operação assíncrona, e await aguarda sua conclusão.
> 

---

## **☕️ 4. Java — CompletableFuture**

A partir do **Java 8**, a linguagem introduziu o CompletableFuture, que traz uma API funcional parecida com Promises.

### **💻 Exemplo:**

```java
import java.util.concurrent.CompletableFuture;

public class Exemplo {
    public static void main(String[] args) {
        CompletableFuture.supplyAsync(() -> "Processando...")
            .thenApply(resultado -> resultado + " concluído!")
            .thenAccept(System.out::println);
    }
}
```

> Assim como em JavaScript, thenApply e thenAccept permitem encadear ações após a resolução da operação.
> 

---

## **🦀 5. Rust — Futures**

Em **Rust**, o conceito é implementado com **Future**, parte do sistema assíncrono da linguagem (async/await desde 1.39).

### **💻 Exemplo:**

```rust
async fn exemplo() -> String {
    "Olá, mundo!".to_string()
}

#[tokio::main]
async fn main() {
    let resultado = exemplo().await;
    println!("{}", resultado);
}
```

> async fn define uma função que retorna um Future, resolvido quando você usa .await.
> 

---

## **💬 6. Outras linguagens**

| **Linguagem** | **Implementação** | **Descrição resumida** |
| --- | --- | --- |
| **Kotlin** | Deferred (coroutines) | Similar ao Future de Java, mas integrado ao sistema de *coroutines*. |
| **Swift** | async/await e Task | Desde Swift 5.5, usa Task e Continuation para modelar operações assíncronas. |
| **Dart** | Future | Usado em Flutter e no Dart nativo, muito similar à Promise do JS. |
| **Scala** | Future / Promise | Ambas existem: Promise é o objeto controlável, Future é o resultado assíncrono. |
| **C++20** | std::future / std::promise | Padrão na biblioteca STL desde C++11, com evolução no C++20. |

---

## **🧭 Conclusão**

Quase toda linguagem moderna possui algum equivalente a **Promise**, embora o nome varie:

- **Promise** (JS, Dart, Scala)
- **Future** (Python, Rust, Java, Dart)
- **Task** (C#, Swift)
- **CompletableFuture** (Java)
- **Deferred** (Kotlin)
- **std::promise / std::future** (C++)

Todas compartilham a mesma **ideia central**:

> Representar um valor que ainda não está disponível, mas estará no futuro — permitindo que o código seja mais limpo, legível e não bloqueie a execução principal.
> 

