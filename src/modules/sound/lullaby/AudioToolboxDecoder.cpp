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

#include "AudioToolboxDecoder.h"

#include <common/Exception.h>

#include <iostream>

namespace love
{
namespace sound
{
namespace lullaby
{

	AudioToolboxDecoder::AudioToolboxDecoder(Data * d, const std::string & ext, int bufferSize, int sampleRate)
		: Decoder(d, ext, bufferSize, sampleRate), handle(0), channels(2), buffer_offset(0)
	{
		data = d;
		
		data_size = data->getSize();
		data_offset = 0;

		//Intialize the handle
		OSStatus err = AudioFileStreamOpen(this, &propertyListener, &packets, 0, &handle);
		if (err)
			throw love::Exception("Could not create handle.");

		err = feed(16384);

		if (err)
			throw love::Exception("Could not feed!");
	}

	AudioToolboxDecoder::~AudioToolboxDecoder()
	{
		AudioFileStreamClose(handle);
	}

	bool AudioToolboxDecoder::accepts(const std::string & ext)
	{
		static const std::string supported[] = {
			"mp3", "wav", "wave", "aiff", "aif", "m4a", ""
		};

		for(int i = 0; !(supported[i].empty()); i++)
		{
			if(supported[i].compare(ext) == 0)
				return true;
		}

		return false;
	}

	love::sound::Decoder * AudioToolboxDecoder::clone()
	{
		return new AudioToolboxDecoder(data, ext, bufferSize, sampleRate);
	}

	int AudioToolboxDecoder::decode()
	{
		bool done = false;
		buffer_offset = 0;

		while(buffer_offset < bufferSize && !done && !eof)
		{
			OSStatus r = feed(bufferSize - buffer_offset);
			if (r == kAudioFileStreamError_InvalidPacketOffset) {
				eof = true;
			} else {
				continue;
			}
		}

		return buffer_offset;
	}

	bool AudioToolboxDecoder::seek(float s)
	{
		throw love::Exception("AudioToolboxDecoder is unable to seek at present!");
		return false;
	}

	bool AudioToolboxDecoder::rewind()
	{
		SInt64 odbo;
		OSStatus ret = AudioFileStreamSeek(handle, NULL, &odbo, 0);
		if (ret) return false;
		data_offset = (int)odbo;
		return true;
		
	}

	bool AudioToolboxDecoder::isSeekable()
	{
		return false;
	}

	int AudioToolboxDecoder::getChannels() const
	{
		return channels;
	}

	int AudioToolboxDecoder::getBits() const
	{
		return 16;
	}

	OSStatus AudioToolboxDecoder::feed(int bytes)
	{
		int remaining = data_size - data_offset;

		if(remaining <= 0)
			return 0;

		int feed_bytes = remaining < bytes ? remaining : bytes;

		OSStatus r = AudioFileStreamParseBytes(handle, feed_bytes, (unsigned char *)(data->getData()) + data_offset, 0);

		if(!r)
			data_offset += feed_bytes;

		return r;
	}
	
	void * AudioToolboxDecoder::getBuffer()
	{
		return buffer;
	}
	
	void propertyListener(void *inClientData, AudioFileStreamID inAudioFileStream,
												   AudioFileStreamPropertyID inPropertyID, UInt32 *ioFlags)
	{
		AudioToolboxDecoder * atd = (AudioToolboxDecoder *)inClientData;
		if (*ioFlags != kAudioFileStreamPropertyFlag_PropertyIsCached) {
			if (inPropertyID == kAudioFileStreamProperty_ChannelLayout) {
				UInt32 size;
				AudioFileStreamGetPropertyInfo(inAudioFileStream, inPropertyID, &size, 0);
				void * info = (void *)malloc(size);
				AudioFileStreamGetProperty(inAudioFileStream, inPropertyID, &size, info);
				AudioChannelLayout * layout = (AudioChannelLayout *)info;
				if (layout->mChannelLayoutTag == kAudioChannelLayoutTag_Mono) {
					atd->channels = 1;
				}
				free(layout);
			}
		}
	}
	
	void packets(void *inClientData, UInt32 inNumberBytes, UInt32 inNumberPackets,
										  const void *inInputData, AudioStreamPacketDescription *inPacketDescriptions)
	{
		AudioToolboxDecoder * atd = (AudioToolboxDecoder *)inClientData;
		memcpy((unsigned char *)(atd->getBuffer()) + atd->buffer_offset, inInputData, inNumberBytes);
		atd->buffer_offset += inNumberBytes;
	}

} // lullaby
} // sound
} // love
