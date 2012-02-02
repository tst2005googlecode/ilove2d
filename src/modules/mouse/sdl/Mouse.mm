/**
* Copyright (c) 2006-2011 LOVE Development Team
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
#include <common/config.h>
#include <common/math.h>
#import "EAGLView.h"
#include "Mouse.h"
#include "loveAppDelegate.h"
// SDL
//#include <SDL.h>

namespace love
{
namespace mouse
{
namespace cocoa
{
    
	const char * Mouse::getName() const
	{
		return "love.mouse.cocoa";
	}

	int Mouse::getX() const
	{
		int x = 0;
		//SDL_GetMouseState(&x, 0);
        loveAppDelegate * del = [[UIApplication sharedApplication] delegate];
		
		// Get the main view.
        EAGLView * view  = [del glView];
        
        x = [view mousex];
		return x;
	}

	int Mouse::getY() const
	{
		int y = 0;
		//SDL_GetMouseState(0, &y);
        loveAppDelegate * del = [[UIApplication sharedApplication] delegate];
		
		// Get the main view.
        EAGLView * view  = [del glView];
        
        y = [view mousey];
		return y;
	}

	void Mouse::getPosition(int & x, int & y) const
	{
		x = this->getX();
        y = this->getY();
	}

	void Mouse::setPosition(int x, int y)
	{
		//SDL_WarpMouse(x, y);
	}

	void Mouse::setVisible(bool visible)
	{
		//SDL_ShowCursor(visible ? SDL_ENABLE : SDL_DISABLE);
	}

	bool Mouse::isDown(Button * buttonlist) const
	{
		/*Uint8 buttonstate = SDL_GetMouseState(0, 0);

		for (Button button = *buttonlist; button != BUTTON_MAX_ENUM; button = *(++buttonlist))
		{
			if (buttonstate & SDL_BUTTON(button))
				return true;
		}*/
        loveAppDelegate * del = [[UIApplication sharedApplication] delegate];
		
		// Get the main view.
        EAGLView * view  = [del glView];
        
        int mouse_state = [view mouse_state];
		return mouse_state == 1;
	}

	bool Mouse::isVisible() const
	{
		return true;
	}

	void Mouse::setGrab(bool grab)
	{
		//SDL_WM_GrabInput(grab ? SDL_GRAB_ON : SDL_GRAB_OFF);
	}

	bool Mouse::isGrabbed() const
	{
		//return (SDL_WM_GrabInput(SDL_GRAB_QUERY) ==  SDL_GRAB_ON ? true : false);
	}

	EnumMap<Mouse::Button, unsigned, Mouse::BUTTON_MAX_ENUM>::Entry Mouse::buttonEntries[] = 
	{
		//{ Mouse::BUTTON_LEFT, SDL_BUTTON_LEFT},
		//{ Mouse::BUTTON_MIDDLE, SDL_BUTTON_MIDDLE},
		//{ Mouse::BUTTON_RIGHT, SDL_BUTTON_RIGHT},
		//{ Mouse::BUTTON_WHEELUP, SDL_BUTTON_WHEELUP},
		///{ Mouse::BUTTON_WHEELDOWN, SDL_BUTTON_WHEELDOWN},
		//{ Mouse::BUTTON_X1, SDL_BUTTON_X1},
		//{ Mouse::BUTTON_X2, SDL_BUTTON_X2},
	};

	EnumMap<Mouse::Button, unsigned, Mouse::BUTTON_MAX_ENUM> Mouse::buttons(Mouse::buttonEntries, sizeof(Mouse::buttonEntries));

} // sdl
} // mouse
} // love
