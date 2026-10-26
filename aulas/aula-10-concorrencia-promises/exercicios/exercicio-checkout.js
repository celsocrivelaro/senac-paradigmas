// Exercicio: checkout de loja virtual com Promises
//
// Registro da Parte 4 (preencher):
//
//

// ---------------------------------------------------------------------------
// Servicos simulados. NAO alterar: cada um devolve uma Promise que termina
// depois de uma latencia fixa e imprime uma linha quando termina.
// ---------------------------------------------------------------------------

function esperar(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

const clientes = {
  c1: { id: "c1", nome: "Ana", cep: "01310-100" },
  c2: { id: "c2", nome: "Carla", cep: "69900-000" },
};

const fretePorCep = {
  "01310-100": 20,
};

const cupons = {
  DEZ: 0.1,
};

// 100 ms
async function buscarCliente(clienteId) {
  await esperar(100);
  console.log(`  [cliente] ${clienteId} encontrado`);
  return clientes[clienteId];
}

// 300 ms; rejeita se o CEP nao for atendido
async function calcularFrete(cep) {
  await esperar(300);
  if (!(cep in fretePorCep)) {
    console.log(`  [frete] CEP ${cep} nao atendido`);
    throw new Error(`CEP ${cep} nao atendido`);
  }
  console.log(`  [frete] CEP ${cep}: R$ ${fretePorCep[cep]}`);
  return fretePorCep[cep];
}

// 150 ms; devolve a fracao de desconto (0 sem cupom)
async function validarCupom(codigo) {
  await esperar(150);
  const desconto = cupons[codigo] ?? 0;
  console.log(`  [cupom] ${codigo ?? "sem cupom"}: ${desconto * 100}%`);
  return desconto;
}

// ---------------------------------------------------------------------------
// Pedidos
// ---------------------------------------------------------------------------

const pedidos = [
  { id: 1, clienteId: "c1", subtotal: 160, cupom: "DEZ" },
  { id: 2, clienteId: "c2", subtotal: 120, cupom: null },
];

// total = subtotal com o desconto do cupom, mais o frete
function calcularTotal(pedido, frete, desconto) {
  return pedido.subtotal * (1 - desconto) + frete;
}

// ---------------------------------------------------------------------------
// A completar
// ---------------------------------------------------------------------------

// Parte 1: as etapas uma depois da outra, com await em cada uma.
// Devolve { pedido: <id>, status: "confirmado", total: <total> }.
async function finalizarSequencial(pedido) {
  // a completar
}

// Partes 2 e 3: frete e cupom ao mesmo tempo, e o tratamento de erro.
// Devolve { pedido: <id>, status: "confirmado", total: <total> }
// ou { pedido: <id>, status: "cancelado", motivo: <mensagem do erro> }.
async function finalizarConcorrente(pedido) {
  // a completar
}

// ---------------------------------------------------------------------------
// Execucao. NAO alterar.
// ---------------------------------------------------------------------------

async function medir(titulo, funcao) {
  console.log(`\n${titulo}`);
  const inicio = Date.now();
  const resultado = await funcao();
  console.log(`  resultado: ${JSON.stringify(resultado)} em ${Date.now() - inicio} ms`);
}

async function main() {
  await medir("Parte 1 - sequencial, pedido 1", () => finalizarSequencial(pedidos[0]));
  for (const pedido of pedidos) {
    await medir(`Partes 2 e 3 - concorrente, pedido ${pedido.id}`, () => finalizarConcorrente(pedido));
  }
}

main();
