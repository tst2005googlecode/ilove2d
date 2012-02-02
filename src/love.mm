/**
* Copyright (c) 2006-2010 LOVE Development Team
*
* This software is provided 'as-is', without any express or implied
* warranty.  In no event will the authors be held liable for any damages
* arising from the use of this software.
*
* Permission is granted to anyone to use this software for any purpose,
* including commercial applications, and to alter it and redistribute it
* freely, subject to the following restrictions:
*
* 1. The origin of this software must not be misrepresented; you must not
*    claim that you wrote the original software. If you use this software
*    in a product, an acknowledgment in the product documentation would be
*    appreciated but is not required.
* 2. Altered source versions must be plainly marked as such, and must not be
*    misrepresented as being the original software.
* 3. This notice may not be removed or altered from any source distribution.
**/

// LOVE
#include "love.h"
#include <common/config.h>
#include <common/version.h>
#include <common/runtime.h>
#include <common/MemoryData.h>

#ifdef LOVE_BUILD_EXE

// Modules
#include <audio/wrap_Audio.h>
#include <event/sdl/wrap_Event.h>
#include <filesystem/physfs/wrap_Filesystem.h>
#include <font/freetype/wrap_Font.h>
#include <graphics/opengles/wrap_Graphics.h>
#include <image/wrap_Image.h>
//#include <joystick/sdl/wrap_Joystick.h>
//#include <keyboard/sdl/wrap_Keyboard.h>
#include <mouse/sdl/wrap_Mouse.h>
#include <physics/box2d/wrap_Physics.h>
#include <sound/wrap_Sound.h>
#include <timer/cocoa/wrap_Timer.h>
//#include <thread/sdl/wrap_Thread.h>

// Libraries.
#include "libraries/luasocket/luasocket.h"

// Scripts
#include "scripts/boot.lua.h"

#endif // LOVE_BUILD_EXE

// Resources
#include "resources/resources.h"

#ifdef LOVE_BUILD_STANDALONE

static const luaL_Reg modules[] = {
	{ "love.audio", love::audio::luaopen_love_audio },
	{ "love.event", love::event::sdl::luaopen_love_event },
	{ "love.filesystem", love::filesystem::physfs::luaopen_love_filesystem },
	{ "love.font", love::font::freetype::luaopen_love_font },
	{ "love.graphics", love::graphics::opengles::luaopen_love_graphics },
	{ "love.image", love::image::luaopen_love_image },
//	{ "love.joystick", love::joystick::sdl::luaopen_love_joystick },
//	{ "love.keyboard", love::keyboard::sdl::luaopen_love_keyboard },
	{ "love.mouse", love::mouse::cocoa::luaopen_love_mouse },
	{ "love.physics", love::physics::box2d::luaopen_love_physics },
	{ "love.sound", love::sound::luaopen_love_sound },
	{ "love.timer", love::timer::cocoa::luaopen_love_timer },
//	{ "love.thread", love::thread::sdl::luaopen_love_thread },
	{ 0, 0 }
};

#endif // LOVE_BUILD_STANDALONE

extern "C" LOVE_EXPORT int luaopen_love(lua_State * L)
{
	love::luax_insistglobal(L, "love");

	// Set version information.
	lua_pushinteger(L, love::VERSION);
	lua_setfield(L, -2, "_version");

	lua_pushstring(L, love::VERSION_STR);
	lua_setfield(L, -2, "_version_string");

	lua_pushstring(L, love::VERSION_CODENAME);
	lua_setfield(L, -2, "_version_codename");

	lua_newtable(L);

	for(int i = 0; love::VERSION_COMPATIBILITY[i] != 0; ++i)
	{
		lua_pushinteger(L, love::VERSION_COMPATIBILITY[i]);
		lua_rawseti(L, -2, i+1);
	}

	lua_setfield(L, -2, "_version_compat");


	// Resources.
	for(const love::Resource * r = love::resources; r->name != 0; r++)
	{
		love::luax_newtype(L, "Data", love::DATA_T, new love::MemoryData((void*)r->data, r->size));
		lua_setfield(L, -2, r->name);
	}

	lua_pop(L, 1); // love

#ifdef LOVE_BUILD_STANDALONE

	// Preload module loaders.
	for(int i = 0; modules[i].name != 0; i++)
	{
		love::luax_preload(L, modules[i].func, modules[i].name);
	}

	love::luasocket::__open(L);

#endif // LOVE_BUILD_STANDALONE

	return 0;
}

#ifdef LOVE_BUILD_EXE
int love_main()
{
	
	// Create the virtual machine.
	lua_State * L = lua_open();
	luaL_openlibs(L);

	love::luax_preload(L, luaopen_love, "love");

	luaopen_love(L);

	// Add command line arguments to global arg (like stand-alone Lua).
	{
		lua_newtable(L);
		
		NSArray * args = [[NSProcessInfo processInfo] arguments];
		int argc = [args count];
		
		char ** argv = new char *[argc+1];
		
		for (int n = 0; n < argc; n++) {
			NSString * str = (NSString *)[args objectAtIndex:n];
			argv[n] = new char[ [str length] + 1];
			strcpy(argv[n], [str UTF8String]);
		}
        NSString *gamePath = [NSHomeDirectory() stringByAppendingPathComponent:@"/love.app/towerstrap/"];
        NSLog(gamePath);        
        
        argv[argc] = new char[ [gamePath length] + 1];
        strcpy(argv[argc], [gamePath UTF8String]);
        
        argc = argc + 1;
		if(argc > 0)
		{
			lua_pushstring(L, argv[0]);
			lua_rawseti(L, -2, -2);
		}

		lua_pushstring(L, "embedded boot.lua");
		lua_rawseti(L, -2, -1);
	
		for(int i = 1; i<argc; i++)
		{
			lua_pushstring(L, argv[i]);
			lua_rawseti(L, -2, i);
		}
	
		lua_setglobal(L, "arg");
		
		delete[] argv;
		
	}

	// Add love.__exe = true.
	// This indicates that we're running the
	// standalone version of love, and not the
	// DLL version.
	{
		lua_getglobal(L, "love");
		lua_pushboolean(L, 1);
		lua_setfield(L, -2, "_exe");
		lua_pop(L, 1);
	}

	// Boot
	if (luaL_loadbuffer(L, (const char *)love::boot_lua, sizeof(love::boot_lua), "boot.lua") == 0)
		lua_call(L, 0, 0);

	lua_close(L);

	return 0;
}

#endif // LOVE_BUILD_EXE
