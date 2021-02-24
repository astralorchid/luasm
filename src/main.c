#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"

int GLOBAL_ARGC;
char* GLOBAL_ARGV;

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
    void* luaFile = luaL_dofile(L, "lasm.lua");

    if (luaFile != LUA_OK) {
        size_t len;
        char* lua_error = lua_tolstring(L, -1, &len);
        printf("%s", lua_error);
    }

    lua_close(L);

    return 0;

}