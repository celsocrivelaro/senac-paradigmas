# Concorrente: Event Loop

Tema: Concorrente

# **🧠 Notas de Aula: O Event Loop no JavaScript**

## **1. Contexto: JavaScript é Single-Threaded**

O JavaScript roda em uma **única thread** — ou seja, apenas **um comando é executado por vez**.

Mas como ele lida com tarefas demoradas (como requisições HTTP, timers, I/O etc.) sem travar a execução?

👉 A resposta está no **Event Loop**, que permite ao JavaScript **parecer assíncrono** mesmo sendo single-threaded.

Ele é essencial para **concorrência cooperativa** e **I/O não bloqueante**

---

## **2. Componentes Principais**

### **🧩 Call Stack (Pilha de Chamadas)**

- Onde as funções são executadas.
- Funciona no estilo **LIFO** (Last In, First Out).
- Exemplo:

```
function a() { console.log('A'); }
function b() { a(); console.log('B'); }
b();
// Ordem: b() entra → a() entra → a() sai → b() sai
```

### **⚙️ Web APIs / Node APIs**

- Fornecidas pelo **navegador** ou **Node.js**.
- Executam tarefas assíncronas fora da thread principal.
- Exemplos: setTimeout, fetch, DOM events, File System, HTTP.

### **📬 Callback Queue (ou Task Queue)**

- Armazena **funções de callback** prontas para execução.
- O **Event Loop** verifica periodicamente se a Call Stack está vazia e, se estiver, move uma função da fila para execução.

### **🚀 Microtask Queue**

- Contém **promises resolvidas** e **mutations observers**.
- Tem **prioridade mais alta** que a Callback Queue.
- Ou seja, **as microtasks sempre rodam antes das tasks normais**.

---

## **3. Ciclo do Event Loop**

O ciclo pode ser resumido em:

1. **Executar tudo na Call Stack.**
2. Quando a stack esvazia:
    - O Event Loop verifica a **Microtask Queue** → executa todas as microtasks.
    - Depois, pega a **próxima task** da Callback Queue.
3. Repete infinitamente enquanto o programa estiver rodando.

---

## **4. Exemplo Clássico**

```
console.log('Início');

setTimeout(() => console.log('Timeout'), 0);

Promise.resolve().then(() => console.log('Promise'));

console.log('Fim');
```

**Saída:**

```
Início
Fim
Promise
Timeout
```

**Explicação:**

1. console.log('Início') e console.log('Fim') rodam na Call Stack.
2. setTimeout é enviado à Web API e depois à Callback Queue.
3. Promise vai para a Microtask Queue.
4. O Event Loop executa:
    - Microtasks (Promise) antes das tasks (Timeout).

---

## **5. Visualizando o Fluxo**

```
┌────────────────────────────┐
│        Call Stack          │
│ (executa funções JS)       │
└────────────┬───────────────┘
             │
             ▼
┌────────────────────────────┐
│         Event Loop         │
│  (coordena execução)       │
└────────────┬───────────────┘
             │
   ┌─────────┴───────────┐
   ▼                     ▼
Callback Queue     Microtask Queue
(setTimeout)       (Promises)
```

---

## **6. Tipos de Tasks**

| **Tipo** | **Exemplo** | **Fila** | **Prioridade** |
| --- | --- | --- | --- |
| **Macro Task (ou Task)** | setTimeout, setInterval, setImmediate, I/O | Callback Queue | ⬇️ Menor |
| **Micro Task** | Promise.then, queueMicrotask, process.nextTick (Node) | Microtask Queue | ⬆️ Maior |

---

## **7. Em Node.js (Diferenças sutis)**

- O Node tem um **Event Loop** similar, mas com **fases específicas**:
    1. **Timers** (setTimeout, setInterval)
    2. **Pending Callbacks**
    3. **Idle / Prepare**
    4. **Poll** (aguarda novas I/O)
    5. **Check** (setImmediate)
    6. **Close Callbacks**
- As **microtasks** (process.nextTick, Promises) são executadas **entre as fases**.

---

## **8. Dicas Didáticas**

- Compare com uma **fila de restaurante**:
    - O cozinheiro (Call Stack) faz um prato por vez.
    - O garçom (Web APIs) pega pedidos e traz quando prontos.
    - A recepcionista (Event Loop) chama o próximo pedido da fila.
- Use ferramentas como [Loupe](http://latentflip.com/loupe) para visualizar o fluxo.

---

## **9. Resumo Visual**

| **Ordem de execução** | **Tipo de tarefa** | **Exemplo** |
| --- | --- | --- |
| 1️⃣ | Código síncrono | console.log |
| 2️⃣ | Microtasks | Promise.then() |
| 3️⃣ | Macrotasks | setTimeout() |

---

## **10. Exercício para a Aula**

```
console.log('1');

setTimeout(() => console.log('2'), 0);

Promise.resolve().then(() => console.log('3'));

console.log('4');
```

**Qual a saída?**

👉 1, 4, 3, 2

---

# Parte 2: Outras linguagens

---

## **⚙️ 1. Linguagens que implementam**

## **Event Loop**

### **🟦 JavaScript / Node.js**

- O caso mais conhecido.
- Event Loop é parte central do **runtime** (tanto nos navegadores quanto no Node.js).
- Node usa a biblioteca **libuv**, que implementa o loop de eventos, filas de callbacks, microtasks e timers.

---

### **🐍 Python (com asyncio)**

- A partir do Python 3.4, com o módulo **asyncio**, a linguagem passou a oferecer um event loop nativo.
- Exemplo:

```
import asyncio

async def main():
    print("Antes")
    await asyncio.sleep(1)
    print("Depois")

asyncio.run(main())
```

- O asyncio usa um **event loop cooperativo**, que gerencia *coroutines* (async def) e *futures*.

---

### **🦀 Rust (com Tokio ou async-std)**

- O Rust não tem um event loop embutido na linguagem, mas frameworks como **Tokio** e **async-std** implementam loops de eventos altamente eficientes.
- Baseados em **futures** e **polling** (semelhante a promessas do JS).
- O compilador transforma async em *state machines* que o event loop executa.

---

### **🐘 PHP (com ReactPHP ou Swoole)**

- PHP originalmente é síncrono, mas frameworks modernos introduziram loops de eventos.
- **ReactPHP** e **Swoole** trazem um loop semelhante ao Node.js, permitindo:

```
$loop = React\EventLoop\Factory::create();
$loop->addTimer(1, function () { echo "Olá!"; });
$loop->run();
```

---

### **🐹 Go (Goroutines e runtime interno)**

- Go **não expõe** diretamente um event loop, mas o runtime da linguagem **usa um internamente** para agendar goroutines.
- A diferença é que Go faz isso de forma **pré-emptiva** (com agendamento leve), não cooperativa.

---

### **☕ Java (com NIO e frameworks reativos)**

- O Java tradicional é bloqueante, mas a partir do **NIO (New I/O)** e frameworks como **Netty** ou **Vert.x**, há event loops para I/O assíncrono.
- Exemplo: o Netty usa um **EventLoopGroup** para multiplexar eventos de rede.

---

### **🧬 C++ (com Boost.Asio, libuv, ou frameworks customizados)**

- **Boost.Asio** implementa um event loop genérico para operações assíncronas.
- **libuv** (usada pelo Node.js) é escrita em C/C++ e pode ser usada em outras aplicações.

---

### **🦸 Outras linguagens com mecanismos similares**

| **Linguagem** | **Biblioteca / Runtime** | **Observações** |
| --- | --- | --- |
| **Dart** | Event loop embutido no runtime do Flutter e Dart VM. | Usa “microtasks” e “event queue” como no JS. |
| **Elixir / Erlang** | BEAM VM | Processos leves e agendador interno baseado em eventos. |
| **C# / .NET** | Task-based async pattern (async/await) | Usa event loops internos no *thread pool* e no *SynchronizationContext*. |

---

## **📊 2. Comparação rápida**

| **Linguagem** | **Tipo de Loop** | **Exemplo de uso** | **Base** |
| --- | --- | --- | --- |
| JavaScript | Único loop global | setTimeout, fetch | libuv |
| Python | asyncio loop | await asyncio.sleep() | Select/Epoll |
| Rust | Tokio event loop | tokio::spawn(...) | Epoll/Kqueue |
| Java | Netty/Vert.x loop | channel.pipeline() | Selector |
| Dart | Flutter runtime | Future e Stream | Microtask queue |
| PHP | ReactPHP loop | addTimer | Stream Select |
| C# | TaskScheduler | await | ThreadPool |

---

## **💡 Conclusão**

O **Event Loop** não é exclusivo do JavaScript — é um **padrão de arquitetura** para lidar com **concorrência não bloqueante** e **I/O assíncrono**.

A maioria das linguagens modernas implementa alguma variação dele, seja exposta (como em JS ou Python) ou interna (como em Go ou C#).

---

Fontes:

https://www.alura.com.br/artigos/arquitetura-node-js-entenda-loop-de-eventos?srsltid=AfmBOoqqwt_xsam680fr9NEjP6Tv24hwkSWonm2m6-Gamld5WsyI2lB-

https://www.rocketseat.com.br/blog/artigos/post/node-js-event-loop