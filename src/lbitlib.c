#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"

#define ARG1_INVALID "Bit shift: argument 1 must be an integer and greater than 0"
#define NOT_ENOUGH_ARGS "Bit shift requires 2 arguments"

static int bit_shl(lua_State* L) {
	int args = lua_gettop(L);
	if (args == 2) {
		unsigned int n = lua_tointeger(L, 1);
		unsigned int shift = lua_tointeger(L, 2);
		unsigned int shifted = n << shift;
		/*if (n == 0) {
			char* arg1_err = ARG1_INVALID;
			lua_pushstring(L, arg1_err);
			lua_error(L);
			return 0;
		}*/
		lua_pushinteger(L, shifted);
		return 1;
	}
	else {
		char* argamt_err = NOT_ENOUGH_ARGS;
		lua_pushstring(L, argamt_err);
		lua_error(L);
		return 0;
	}
}

static int bit_shr(lua_State* L) {
	int args = lua_gettop(L);
	if (args == 2) {
		unsigned int n = lua_tointeger(L, 1);
		unsigned int shift = lua_tointeger(L, 2);
		unsigned int shifted = n >> shift;
		/*if (n == 0) {
			char* arg1_err = ARG1_INVALID;
			lua_pushstring(L, arg1_err);
			lua_error(L);
			return 0;
		}*/
		lua_pushinteger(L, shifted);
		return 1;
	}
	else {
		char* argamt_err = NOT_ENOUGH_ARGS;
		lua_pushstring(L, argamt_err);
		lua_error(L);
		return 0;
	}
}

static int bit_or(lua_State* L) {
	int args = lua_gettop(L);
	if (args == 2) {
		unsigned int n = lua_tointeger(L, 1);
		unsigned int or = lua_tointeger(L, 2);
		unsigned int ord = n | or;

		lua_pushinteger(L, ord);
		return 1;
	}
	else {
		char* argamt_err = NOT_ENOUGH_ARGS;
		lua_pushstring(L, argamt_err);
		lua_error(L);
		return 0;
	}
}

static const luaL_Reg bitlib[] = {
	{"shl", bit_shl},
	{"shr", bit_shr},
	{"OR", bit_or},
	{NULL, NULL}
};

LUAMOD_API int luaopen_bit(lua_State* L) {
	luaL_newlib(L, bitlib);
	return 1;
}