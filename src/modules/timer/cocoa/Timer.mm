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

#include <common/config.h>

#include "Timer.h"

namespace love
{
namespace timer
{
namespace cocoa
{
	Timer::Timer()
		: time_init(0), currTime(0), prevFpsUpdate(0), fps(0), fpsUpdateFrequency(1),
		frames(0), dt(0)
	{
		timer = [NSDate date];
	}

	Timer::~Timer()
	{
		[timer release];
	}

	const char * Timer::getName() const
	{
		return "love.timer.cocoa";
	}

	void Timer::step()
	{
		// Frames rendered
		frames++;

		// "Current" time is previous time by now.
		prevTime = currTime;

		// Get ticks from Cocoa
		currTime = -[timer timeIntervalSinceNow];

		// Convert to number of seconds
		dt = (currTime - prevTime);

		// Update FPS?
		if((currTime - prevFpsUpdate) > fpsUpdateFrequency)
		{
			fps = frames/fpsUpdateFrequency;
			prevFpsUpdate = currTime;
			frames = 0;
		}
	}

	void Timer::sleep(int ms)
	{
		if(ms > 0)
			[NSThread sleepForTimeInterval:(ms/1000.0f)];
	}

	float Timer::getDelta() const
	{
		return dt;
	}

	float Timer::getFPS() const
	{
		return fps;
	}

	float Timer::getTime() const
	{
		return (currTime - time_init);
	}

	double Timer::getMicroTime() const
	{
        NSString *nowTimestamp = [NSString stringWithFormat:@"%f", 
                                  [[NSDate date] timeIntervalSince1970]];
        
        double mt = [[NSDate date] timeIntervalSince1970];
		return mt;//*1000000.0f;
	}

} // cocoa
} // timer
} // love
