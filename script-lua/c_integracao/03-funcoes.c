#include <math.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>

#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

// Declaração de funções do C
double funcao_que_chama_lua (lua_State* L, double x, double y);
void error (lua_State *L, const char *fmt, ...);
static int funcao_c_soma_10 (lua_State *L); // Função em C que será chamada pelo Lua

// Função em C que será chamada pelo Lua
// Função que soma 10 ao valor passado como argumento
static int funcao_c_soma_10 (lua_State *L) {
  // Pega o valor passado como argumento
  // Converte o valor do topo da pilha para double
  double d = lua_tonumber(L, 1);
  printf("Valor no topo da pilha %f\n", d);
  // Coloca o resultado da função no topo da pilha
  lua_pushnumber(L, d+10);

  // Retorna o número de resultados (1 apenas)
  // pois a função em Lua espera apenas um resultado
  // desta função
  return 1;
}

int main(int argc, const char* argv[]){
  // Iniciando o interpretador
  lua_State* L = luaL_newstate();
  luaL_openlibs(L);

  // Registra a função em C no Lua
  lua_pushcfunction(L, funcao_c_soma_10);
  lua_setglobal(L, "funcao_c_soma_10");

  // carrega o arquivo e executa suas as ações
  // 1. Carrega o arquivo 03-funcao.lua
  luaL_dofile(L, "03-funcao.lua");
  // 2. Chama a função calculo do script.lua
  double valor = funcao_que_chama_lua(L, 10,  20);

  printf("Conta feita pela função em Lua: %f\n", valor);

  // Terminando o interpretador
  lua_close(L);
  return 0;
}

// Função em C que chama a função calculo do script.lua
double funcao_que_chama_lua (lua_State* L, double x, double y) {
  double z;

  // Chama a função calculo do script.lua
  lua_getglobal(L, "calculo");
  // Verifica se a função calculo do script.lua existe
  if (!lua_isfunction(L, -1))
    error(L, "`calculo' não é uma função");
  // Empilha os argumentos da função calculo do script.lua
  lua_pushnumber(L, x);
  lua_pushnumber(L, y);

  /* do the call (2 arguments, 1 result) */
  // Chama a função calculo do script.lua
  // com 2 argumentos de entrada e 1 argumento de saída
  // lua_pcall(L, E, S, X) => Z
  // E: número de argumentos de entrada
  // S: número de argumentos de saída
  // X: número de argumentos de erro
  // Z: resultado da função. Se Z for 0, a função foi executada com sucesso
  if (lua_pcall(L, 2, 1, 0) != 0)
    error(L, "erro ao rotar a função `calculo': %s",
              lua_tostring(L, -1));

  // Pega o resultado da função calculo do script.lua
  // Verifica se o resultado é um número (topo da pilha)
  if (!lua_isnumber(L, -1))
    error(L, "função `calculo' precisa retornar um número");
  // Pega o resultado no topo da pilha
  z = lua_tonumber(L, -1);
  // Remove o resultado do topo da pilha
  lua_pop(L, 1);
  return z;
}

// https://www.lua.org/pil/24.1.html#first-ex
// Função para imprimir erros
void error (lua_State *L, const char *fmt, ...) {
  va_list argp;
  va_start(argp, fmt);
  vfprintf(stderr, fmt, argp);
  va_end(argp);
  lua_close(L);
  exit(EXIT_FAILURE);
}
