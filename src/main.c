#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"

int GLOBAL_ARGC;
char* GLOBAL_ARGV;
char* OUTPUT_BINARY;
unsigned int OUTPUT_BINARY_SIZE = 0;
unsigned int CURSOR = 0;
int main(int argc, char* argv[])
{

    printf("%i", argc);
    printf("%s", "\n");
    printf("%s", argv[0]);
    printf("%s", "\n");
    printf("%s", argv[1]);
    printf("%s", "\n");
    GLOBAL_ARGC = argc;
    GLOBAL_ARGV = argv[1];

    lua_State* L = luaL_newstate();
    luaL_openlibs(L);
    int luaFile = luaL_dofile(L, "lasm.lua");

    if (luaFile != LUA_OK) {
        size_t len;
        const char* lua_error = lua_tolstring(L, -1, &len);
        printf("%s", lua_error);
    }

    lua_close(L);

    return 0;

}