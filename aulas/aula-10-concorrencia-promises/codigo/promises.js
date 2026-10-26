// https://developer.mozilla.org/pt-BR/docs/Web/JavaScript/Reference/Statements/async_function
// https://eloquentjavascript.net/

// --------  Promise --------
console.log("-----------  Promise que dá certo ----------- ");
let promise = new Promise(resolve => {
    // faço algo super lento
    setTimeout(function(){}, 2000);
    resolve("retorna resultado lento");
});
console.log("Fez algo rápido...")
promise.then(resultado => console.log(`Recebeu ${resultado}`));
console.log("Vou fazendo outras coisas....");

console.log("\n----------- Promise que dá errado... ----------- ");
let promise_ruim = new Promise( (resolve, reject) => {
    //resolve("retorna resultado que não deve ser chamado");

    reject("deu ruim...");
});
promise_ruim.then(resultado => console.log(`Recebeu certo ${resultado}`))
            .catch(erro => console.log(`Recebeu erro: ${erro}`));
console.log("Vou fazendo outras coisas....");



// console.log("\n----------- Função assíncrona ----------- ");

// Async / Await
async function fazLento(valor) {
  // faço algo super lento
  setTimeout(function(){}, 2000);
  return valor;
}

// retorna uma Promise
let promise_async = fazLento(10);
promise_async.then(resultado => {
  console.log(resultado);
});

async function experoOutroResultado(resultado) {
  let valor = await fazLento(resultado)
  return valor*2;
}

// // // await espera processamento
let promise_outro = experoOutroResultado(10);

promise_outro.then(resultado => {
  console.log(resultado);
});
console.log("Vou fazendo outras coisas....");