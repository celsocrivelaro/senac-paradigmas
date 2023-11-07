#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

int main(int argc, const char* argv[]){
  lua_State* L = luaL_newstate();
  luaL_openlibs(L);

  // https://www.lua.org/manual/5.3/manual.html#luaL_dostring
  luaL_dostring(L, "print('Ola Mundo')");

  // carrega o arquivo e executa as ações dele
  luaL_dofile(L, "01-hello.lua");

  lua_close(L);
  return 0;
}