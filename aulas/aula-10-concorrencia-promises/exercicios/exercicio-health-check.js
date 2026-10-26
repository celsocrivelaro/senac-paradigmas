// Exercicio: health check de servicos com Promises
//
// Registro da Parte 4 (preencher):
//
//

const servicos = [
  { nome: "autenticacao", latencia: 120 },
  { nome: "pagamentos", latencia: 300 },
  { nome: "estoque", latencia: 80 },
  { nome: "notificacoes", latencia: 200 },
];

// Parte 1: devolve uma Promise que, depois de servico.latencia milissegundos,
// e resolvida com a linha de status "<nome>: ok (<latencia> ms)".
function verificar(servico) {
  // a completar
}

// Parte 2: verifica um servico de cada vez, na ordem da lista, com await.
async function sequencial() {
  // a completar
}

// Parte 3: dispara as quatro verificacoes ao mesmo tempo e espera todas
// com Promise.all.
async function concorrente() {
  // a completar
}

async function main() {
  let inicio = Date.now();
  await sequencial();
  console.log(`sequencial: ${Date.now() - inicio} ms`);

  inicio = Date.now();
  await concorrente();
  console.log(`concorrente: ${Date.now() - inicio} ms`);
}

main();
