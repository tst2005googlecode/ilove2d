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

#include "ImageData.h"

// STD
#include <iostream>

// LOVE
#include <common/Exception.h>

namespace love
{
namespace image
{
namespace imageio
{
	void ImageData::load(Data * d)
	{
		CFDataRef cfd = CFDataCreate(NULL, (UInt8*)(d->getData()), d->getSize());
		CGImageSourceRef s = CGImageSourceCreateWithData(cfd, NULL);
		CGImageRef image = CGImageSourceCreateImageAtIndex(s, 0, NULL);
		
		CFRelease(s);
		CFRelease(cfd);
		
		if(!image)
		{
			throw love::Exception("Could not decode image!");
			return;
		}

		width = CGImageGetWidth(image);
		height = CGImageGetHeight(image);

		// This should always be four.
		bpp = CGImageGetBitsPerPixel(image) / 8;

		if(bpp != 4)
		{
			throw love::Exception("Bytes per pixel != 4");
			return;
		}
		cfd = CGDataProviderCopyData(CGImageGetDataProvider(image));
		data = malloc(CFDataGetLength(cfd));
		CFDataGetBytes(cfd, CFRangeMake(0, CFDataGetLength(cfd)), (UInt8*)data);
		CFRelease(cfd);
		CGImageRelease(image);
	}

	ImageData::ImageData(Data * data)
	{
		load(data);
	}

	ImageData::ImageData(filesystem::File * file)
	{
		Data * data = file->read();
		load(data);
		data->release();
	}

	ImageData::ImageData(int width, int height)
	{
		data = (void*)malloc(width*height*4);
		// Set to black.
		memset(data, 0, width*height*4);
	}
	
	ImageData::ImageData(int width, int height, void *d)
	: width(width), height(height), bpp(4)
	{
		data = (void*)malloc(width*height*bpp);
		memcpy(data, d, width*height*bpp);
	}

	ImageData::~ImageData()
	{
		free(data);
	}

	int ImageData::getWidth() const 
	{
		return width;
	}

	int ImageData::getHeight() const 
	{
		return height;
	}

	void * ImageData::getData() const
	{
		return data;
	}

	int ImageData::getSize() const
	{
		return width*height*bpp;
	}

	void ImageData::setPixel(int x, int y, pixel c)
	{
		//int tx = x > width-1 ? width-1 : x;
		//int ty = y > height-1 ? height-1 : y; // not using these seems to not break anything
		pixel * pixels = (pixel *)getData();
		pixels[y*width+x] = c;
	}

	pixel ImageData::getPixel(int x, int y) const
	{
		//int tx = x > width-1 ? width-1 : x;
		//int ty = y > height-1 ? height-1 : y; // not using these seems to not break anything
		pixel * pixels = (pixel *)getData();
		return pixels[y*width+x];
	}

} // imageio
} // image
} // love
