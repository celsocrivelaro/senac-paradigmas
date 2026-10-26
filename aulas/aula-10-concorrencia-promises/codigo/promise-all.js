// https://developer.mozilla.org/pt-BR/docs/Web/JavaScript/Reference/Global_Objects/Promise/all

// --------  Promise.all --------
// Cotação do mesmo produto em três fornecedores. Cada consulta demora o
// tempo de resposta do fornecedor.
const fornecedores = [
  { nome: "fornecedor_a", preco: 52.9, tempo: 400 },
  { nome: "fornecedor_b", preco: 49.5, tempo: 700 },
  { nome: "fornecedor_c", preco: 51.0, tempo: 250 },
];

// Devolve uma Promise resolvida com a cotação depois de fornecedor.tempo ms.
// O resolve fica DENTRO do callback do setTimeout: só assim a Promise espera.
function cotar(fornecedor) {
  return new Promise(resolve => {
    setTimeout(() => {
      resolve({ nome: fornecedor.nome, preco: fornecedor.preco });
    }, fornecedor.tempo);
  });
}

// Uma consulta de cada vez: cada await espera a anterior terminar.
async function cotarSequencial() {
  const cotacoes = [];
  for (const fornecedor of fornecedores) {
    const cotacao = await cotar(fornecedor);
    cotacoes.push(cotacao);
  }
  return cotacoes;
}

// As três consultas disparadas de uma vez, sem await; Promise.all espera
// todas e devolve as cotações na ordem do vetor de promises.
async function cotarConcorrente() {
  const promises = [];
  for (const fornecedor of fornecedores) {
    promises.push(cotar(fornecedor));
  }
  const cotacoes = await Promise.all(promises);
  return cotacoes;
}

function maisBarata(cotacoes) {
  let melhor = cotacoes[0];
  for (const cotacao of cotacoes) {
    if (cotacao.preco < melhor.preco) {
      melhor = cotacao;
    }
  }
  return melhor;
}

async function comparar() {
  let inicio = Date.now();
  let cotacoes = await cotarSequencial();
  console.log(`sequencial: ${maisBarata(cotacoes).nome} em ${Date.now() - inicio} ms`);

  inicio = Date.now();
  cotacoes = await cotarConcorrente();
  console.log(`Promise.all: ${maisBarata(cotacoes).nome} em ${Date.now() - inicio} ms`);
}

comparar();