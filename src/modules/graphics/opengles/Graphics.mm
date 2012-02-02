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
#include <common/math.h>

#include "Graphics.h"

#include "loveAppDelegate.h"

namespace love
{
namespace graphics
{
namespace opengles
{

	Graphics::Graphics()
		: currentFont(0)
	{
		loveAppDelegate * del = [[UIApplication sharedApplication] delegate];
		
		// Get the main view.
		view = [del glView];
		
		// Set the new display mode as the current display mode.
		currentMode.width = [view width];
		currentMode.height = [view height];
		currentMode.colorDepth = 32;
		
		[EAGLContext setCurrentContext:[view context]];
	}

	Graphics::~Graphics()
	{
		if(currentFont != 0)
			currentFont->release();
	}

	const char * Graphics::getName() const
	{
		return "love.graphics.opengles";
	}
	
	DisplayState Graphics::saveState()
	{
		DisplayState s;
		//create a table in which to store the color data in float format, before converting it
		float color[4];
		//get the color
		glGetFloatv(GL_CURRENT_COLOR, color);
		s.color.r = (GLubyte)(color[0]*255.0f);
		s.color.g = (GLubyte)(color[1]*255.0f);
		s.color.b = (GLubyte)(color[2]*255.0f);
		s.color.a = (GLubyte)(color[3]*255.0f);
		//get the background color
		glGetFloatv(GL_COLOR_CLEAR_VALUE, color);
		s.backgroundColor.r = (GLubyte)(color[0]*255.0f);
		s.backgroundColor.g = (GLubyte)(color[1]*255.0f);
		s.backgroundColor.b = (GLubyte)(color[2]*255.0f);
		s.backgroundColor.a = (GLubyte)(color[3]*255.0f);
		//store modes here
		GLint mode;
		//get blend mode
		glGetIntegerv(GL_BLEND_DST, &mode);
		//following syntax seems better than if-else every time
		s.blendMode = (mode == GL_ONE) ? Graphics::BLEND_ADDITIVE : Graphics::BLEND_ALPHA;
		//get color mode
		glGetTexEnviv(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, &mode);
		s.colorMode = (mode == GL_MODULATE) ? Graphics::COLOR_MODULATE : Graphics::COLOR_REPLACE;
		//get the line width (directly to corresponding variable)
		glGetFloatv(GL_LINE_WIDTH, &s.lineWidth);
		//get line style
		s.lineStyle = (glIsEnabled(GL_LINE_SMOOTH) == GL_TRUE) ? Graphics::LINE_SMOOTH : Graphics::LINE_ROUGH;
		//get the point size
		glGetFloatv(GL_POINT_SIZE, &s.pointSize);
		//get point style
		s.pointStyle = (glIsEnabled(GL_POINT_SMOOTH) == GL_TRUE) ? Graphics::POINT_SMOOTH : Graphics::POINT_ROUGH;
		//get scissor status
		s.scissor = (glIsEnabled(GL_SCISSOR_TEST) == GL_TRUE);
		//do we have scissor, if so, store the box
		if (s.scissor)
			glGetIntegerv(GL_SCISSOR_BOX, s.scissorBox);
		return s;
	}

	void Graphics::restoreState(const DisplayState & s)
	{
		setColor(s.color);
		setBackgroundColor(s.backgroundColor);
		setBlendMode(s.blendMode);
		setColorMode(s.colorMode);
		setLine(s.lineWidth, s.lineStyle);
		setPoint(s.pointSize, s.pointStyle);
		if (s.scissor)
			setScissor(s.scissorBox[0], s.scissorBox[1], s.scissorBox[2], s.scissorBox[3]);
		else
			setScissor();
	}

	void Graphics::reset()
	{
		DisplayState s;
		restoreState(s);
	}

	void Graphics::clear()
	{
		glClear(GL_COLOR_BUFFER_BIT);
		glLoadIdentity();
	}

	void Graphics::present()
	{
		[view drawView];
	}

	int Graphics::getWidth()
	{
		return currentMode.width;
	}

	int Graphics::getHeight()
	{
		return currentMode.height;
	}

	bool Graphics::isCreated()
	{
		return (currentMode.width > 0) || (currentMode.height > 0);
	}

	void Graphics::setScissor(int x, int y, int width, int height)
	{
		glEnable(GL_SCISSOR_TEST);
		glScissor(x, getHeight() - (y + height), width, height); // Compensates for the fact that our y-coordinate is reverse of OpenGLs.
	}

	void Graphics::setScissor()
	{
		glDisable(GL_SCISSOR_TEST);
	}

	int Graphics::getScissor(lua_State * L)
	{
		if(glIsEnabled(GL_SCISSOR_TEST) == GL_FALSE)
			return 0;

		GLint scissor[4];
		glGetIntegerv(GL_SCISSOR_BOX, scissor);

		lua_pushnumber(L, scissor[0]);
		lua_pushnumber(L, getHeight() - (scissor[1] + scissor[3])); // Compensates for the fact that our y-coordinate is reverse of OpenGLs.
		lua_pushnumber(L, scissor[2]);
		lua_pushnumber(L, scissor[3]);

		return 4;
	}

	Image * Graphics::newImage(love::image::ImageData * data)
	{
		// Create the image.
		Image * image = new Image(data);
		bool success;
		try {
			success = image->load();
		} catch (love::Exception & e) {
			image->release();
			throw love::Exception(e.what());
		}
		if (!success) {
			image->release();
			return 0;
		}

		return image;
	}

	Quad * Graphics::newQuad(int x, int y, int w, int h, int sw, int sh)
	{
		Quad::Viewport v;
		v.x = x;
		v.y = y;
		v.w = w;
		v.h = h;
		return new Quad(v, sw, sh);
	}

	Font * Graphics::newFont(love::font::FontData * data)
	{
		Font * font = new Font(data);

		// Load it and check for errors.
		if(!font)
		{
			delete font;
			return 0;
		}

		return font;
	}

	SpriteBatch * Graphics::newSpriteBatch(Image * image, int size, int usage)
	{
		return new SpriteBatch(image, size, usage);
	}

	ParticleSystem * Graphics::newParticleSystem(Image * image, int size)
	{
		return new ParticleSystem(image, size);
	}

	void Graphics::setColor(Color c)
	{
		glColor4ub(c.r, c.g, c.b, c.a);
	}

	Color Graphics::getColor()
	{
		float c[4];
		glGetFloatv(GL_CURRENT_COLOR, c);

		Color t;
		t.r = (unsigned char)(255.0f*c[0]);
		t.g = (unsigned char)(255.0f*c[1]);
		t.b = (unsigned char)(255.0f*c[2]);
		t.a = (unsigned char)(255.0f*c[3]);

		return t;
	}

	void Graphics::setBackgroundColor(Color c)
	{
		glClearColor((float)c.r/255.0f, (float)c.g/255.0f, (float)c.b/255.0f, 1.0f);
	}

	Color Graphics::getBackgroundColor()
	{
		float c[4];
		glGetFloatv(GL_COLOR_CLEAR_VALUE, c);

		Color t;
		t.r = (unsigned char)(255.0f*c[0]);
		t.g = (unsigned char)(255.0f*c[1]);
		t.b = (unsigned char)(255.0f*c[2]);
		t.a = (unsigned char)(255.0f*c[3]);

		return t;
	}

	void Graphics::setFont( Font * font )
	{
		if(currentFont != 0)
			currentFont->release();

		currentFont = font;

		if(font != 0)
			currentFont->retain();
	}

	Font * Graphics::getFont()
	{
		return currentFont;
	}

	void Graphics::setBlendMode( Graphics::BlendMode mode )
	{
		if(mode == BLEND_ADDITIVE)
			glBlendFunc(GL_SRC_ALPHA, GL_ONE);
		else // mode == BLEND_ALPHA
			glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	}

	void Graphics::setColorMode ( Graphics::ColorMode mode )
	{
		if(mode == COLOR_MODULATE)
			glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
		else // mode = COLOR_REPLACE
			glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
	}

	Graphics::BlendMode Graphics::getBlendMode()
	{
		GLint dst, src;
		glGetIntegerv(GL_BLEND_DST, &dst);
		glGetIntegerv(GL_BLEND_SRC, &src);

		if(src == GL_SRC_ALPHA && dst == GL_ONE)
			return BLEND_ADDITIVE;
		else // src == GL_SRC_ALPHA && dst == GL_ONE_MINUS_SRC_ALPHA
			return BLEND_ALPHA;
	}

	Graphics::ColorMode Graphics::getColorMode()
	{
		GLint mode;
		glGetTexEnviv(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, &mode);

		if(mode == GL_MODULATE)
			return COLOR_MODULATE;
		else // mode == GL_REPLACE
			return COLOR_REPLACE;
	}

	void Graphics::setLineWidth( float width )
	{
		glLineWidth(width);
	}

	void Graphics::setLineStyle(Graphics::LineStyle style )
	{
		if(style == LINE_ROUGH)
			glDisable (GL_LINE_SMOOTH);
		else // type == LINE_SMOOTH
		{
			glEnable (GL_LINE_SMOOTH);
			glHint (GL_LINE_SMOOTH_HINT, GL_NICEST);
		}
	}

	void Graphics::setLine( float width, Graphics::LineStyle style )
	{
		glLineWidth(width);

		if(style == 0)
			return;

		if(style == LINE_ROUGH)
			glDisable (GL_LINE_SMOOTH);
		else // type == LINE_SMOOTH
		{
			glEnable (GL_LINE_SMOOTH);
			glHint (GL_LINE_SMOOTH_HINT, GL_NICEST);
		}
	}

	float Graphics::getLineWidth()
	{
		float w;
		glGetFloatv(GL_LINE_WIDTH, &w);
		return w;
	}

	Graphics::LineStyle Graphics::getLineStyle()
	{
		if(glIsEnabled(GL_LINE_SMOOTH) == GL_TRUE)
			return LINE_SMOOTH;
		else
			return LINE_ROUGH;
	}
	
	void Graphics::setPointSize( float size )
	{
		glPointSize((GLfloat)size);
	}

	void Graphics::setPointStyle( Graphics::PointStyle style )
	{
		if( style == POINT_SMOOTH )
			glEnable(GL_POINT_SMOOTH);
		else // love::POINT_ROUGH
			glDisable(GL_POINT_SMOOTH);
	}

	void Graphics::setPoint( float size, Graphics::PointStyle style )
	{
		if( style == POINT_SMOOTH )
			glEnable(GL_POINT_SMOOTH);
		else // POINT_ROUGH
			glDisable(GL_POINT_SMOOTH);

		glPointSize((GLfloat)size);
	}

	float Graphics::getPointSize()
	{
		GLfloat size;
		glGetFloatv(GL_POINT_SIZE, &size);
		return (float)size;
	}

	Graphics::PointStyle Graphics::getPointStyle()
	{
		if(glIsEnabled(GL_POINT_SMOOTH) == GL_TRUE)
			return POINT_SMOOTH;
		else
			return POINT_ROUGH;
	}

	int Graphics::getMaxPointSize()
	{
		GLint max;
		glGetIntegerv(GL_POINT_SIZE_MAX, &max);
		return (int)max;
	}

	void Graphics::print( const char * str, float x, float y )
	{
		if(currentFont != 0)
		{
			std::string text(str);

			if(text.find("\n") == std::string::npos)
				currentFont->print(text, x, y);
			else
			{
				int lines = 0;
				text = "";

				for(unsigned int i = 0; i < strlen(str); i++)
				{
					if(str[i] == '\n')
					{
						currentFont->print(text, x, y + (lines * currentFont->getHeight() * currentFont->getLineHeight()));
						text = "";
						lines++;
					}
					else
						text += str[i];
				}

				if(text != "") // Print the last text (if applicable).
					currentFont->print(text, x, y + (lines * currentFont->getHeight() * currentFont->getLineHeight()));
			}
		}
	}

	void Graphics::print( const char * str, float x, float y , float angle)
	{
		if(currentFont != 0)
		{
			std::string text(str);
			currentFont->print(text, x, y, angle, 1, 1);
		}
	}

	void Graphics::print( const char * str, float x, float y , float angle, float s)
	{
		if(currentFont != 0)
		{
			std::string text(str);
			currentFont->print(text, x, y, angle, s, s);
		}
	}

	void Graphics::print( const char * str, float x, float y , float angle, float sx, float sy)
	{
		if(currentFont != 0)
		{
			std::string text(str);
			currentFont->print(text, x, y, angle, sx, sy);
		}
	}

	void Graphics::printf( const char * str, float x, float y, float wrap, AlignMode align)
	{
		if(currentFont != 0)
		{
			std::string text = "";
			float width = 0;
			float lines = 0;

			for(unsigned int i = 0; i < strlen(str); i++)
			{
				if(str[i] == '\n')
				{
					switch(align)
					{
						case ALIGN_LEFT:
							currentFont->print(text, x, y + (lines * currentFont->getHeight() * currentFont->getLineHeight()) );
							break;

						case ALIGN_RIGHT:
							currentFont->print(text, (x + (wrap - currentFont->getWidth(text))), y + (lines * currentFont->getHeight() * currentFont->getLineHeight()) );
							break;

						case ALIGN_CENTER:
							currentFont->print(text, ceil(x + ((wrap - currentFont->getWidth(text)) / 2)), ceil(y + (lines * currentFont->getHeight() * currentFont->getLineHeight())) );
							break;

						default: // A copy of the left align code. Kept separate in case an error message is wanted.
							currentFont->print(text, x, y + (lines * currentFont->getHeight() * currentFont->getLineHeight()) );
							break;
					}

					text = "";
					width = 0;
					lines++;
				}
				else
				{
					width += currentFont->getWidth(str[i]);

					if(width > wrap && text.find(" ") != std::string::npos) // If there doesn't exist a space, then ignore the wrap limit.
					{
						// Seek back to the nearest space and print that.
						unsigned int space = (unsigned int)text.find_last_of(' ');
						std::string temp = text.substr(0, space);

						switch(align)
						{
							case ALIGN_LEFT:
								currentFont->print(temp, x, y + (lines * currentFont->getHeight() * currentFont->getLineHeight()) );
								break;

							case ALIGN_RIGHT:
								currentFont->print(temp, (x + (wrap - currentFont->getWidth(temp))), y + (lines * currentFont->getHeight() * currentFont->getLineHeight()) );
								break;

							case ALIGN_CENTER:
								currentFont->print(temp, ceil(x + ((wrap - currentFont->getWidth(temp)) / 2)), ceil(y + (lines * currentFont->getHeight() * currentFont->getLineHeight())) );
								break;

							default: // A copy of the left align code. Kept separate in case an error message is wanted.
								currentFont->print(temp, x, y + (lines * currentFont->getHeight() * currentFont->getLineHeight()) );
								break;
						}

						text = text.substr(space + 1);
						width = currentFont->getWidth(text);
						lines++;
					}

					text += str[i];
				}
			} // for

			if(text != "") // Print the last text (if applicable).
			{
				switch(align)
				{
					case ALIGN_LEFT:
						currentFont->print(text, x, y + (lines * currentFont->getHeight() * currentFont->getLineHeight()) );
						break;

					case ALIGN_RIGHT:
						currentFont->print(text, (x + (wrap - currentFont->getWidth(text))), y + (lines * currentFont->getHeight() * currentFont->getLineHeight()) );
						break;

					case ALIGN_CENTER:
						currentFont->print(text, ceil(x + ((wrap - currentFont->getWidth(text)) / 2)), ceil(y + (lines * currentFont->getHeight() * currentFont->getLineHeight())) );
						break;

					default: // A copy of the left align code. Kept separate in case an error message is wanted.
						currentFont->print(text, x, y + (lines * currentFont->getHeight() * currentFont->getLineHeight()));
						break;
				}
			}
		}
	}

	/**
	* Primitives
	**/

	void Graphics::point( float x, float y )
	{
		glDisable(GL_TEXTURE_2D);
		glEnableClientState(GL_VERTEX_ARRAY);
		
		GLfloat verts[] = {x, y};
		
		glVertexPointer(2, GL_FLOAT, 0, verts);
		
		glDrawArrays(GL_POINTS, 0, 1);
		
		glDisableClientState(GL_VERTEX_ARRAY);
		glEnable(GL_TEXTURE_2D);
	}

	void Graphics::line( float x1, float y1, float x2, float y2 )
	{
		glDisable(GL_TEXTURE_2D);
		glPushMatrix();
		glEnableClientState(GL_VERTEX_ARRAY);
		
		GLfloat verts[] = {x1, y1, x2, y2};
		
		glVertexPointer(2, GL_FLOAT, 0, verts);
		
		glDrawArrays(GL_LINES, 0, 2);
		
		glDisableClientState(GL_VERTEX_ARRAY);
		glPopMatrix();
		glEnable(GL_TEXTURE_2D);
	}

	int Graphics::polyline( lua_State * L)
	{
		// Get number of params.
		int args = lua_gettop(L);
		bool table = false;

		if (args == 1) { // we've got a table, hopefully
			int type = lua_type(L, 1);
			if (type != LUA_TTABLE)
				return luaL_error(L, "Function requires a table or series of numbers");
			table = true;
			args = lua_objlen(L, 1);
		}

		if (args % 2) // an odd number of arguments, no good for a polyline
			return luaL_error(L, "Number of vertices must be a multiple of two");

		// right, let's draw this polyline, then
		glDisable(GL_TEXTURE_2D);
		glEnableClientState(GL_VERTEX_ARRAY);
		
		GLfloat verts[args];
		
		if (table) {
			lua_pushnil(L);
			int i = 0;
			while (true) {
				if(lua_next(L, 1) == 0) break;
				GLfloat x = (GLfloat)lua_tonumber(L, -1);
				lua_pop(L, 1); // pop value
				if(lua_next(L, 1) == 0) break;
				GLfloat y = (GLfloat)lua_tonumber(L, -1);
				lua_pop(L, 1); // pop value
				verts[i] = x;
				verts[i+1] = y;
				i+=2;
			}
		} else {
			for (int i = 1; i < args; i+=2) {
				verts[i-1] = (GLfloat)lua_tonumber(L, i);
				verts[i] = (GLfloat)lua_tonumber(L, i+1);
			}
		}
		
		glVertexPointer(2, GL_FLOAT, 0, verts);
		
		glDrawArrays(GL_LINE_STRIP, 0, args/2);
		
		glDisableClientState(GL_VERTEX_ARRAY);
		glEnable(GL_TEXTURE_2D);
		return 0;
	}

	void Graphics::triangle(DrawMode mode, float x1, float y1, float x2, float y2, float x3, float y3 )
	{
		glDisable(GL_TEXTURE_2D);
		glPushMatrix();

		glEnableClientState(GL_VERTEX_ARRAY);
		
		GLfloat verts[] = {x1, y1, x2, y2, x3, y3};
		
		glVertexPointer(2, GL_FLOAT, 0, verts);
		
		glDrawArrays((mode == DRAW_LINE ? GL_LINE_LOOP : GL_TRIANGLES), 0, 3);
		
		glDisableClientState(GL_VERTEX_ARRAY);

		glPopMatrix();
		glEnable(GL_TEXTURE_2D);
	}

	void Graphics::rectangle(DrawMode mode, float x, float y, float w, float h)
	{
		glDisable(GL_TEXTURE_2D);
		glPushMatrix();
		
		glEnableClientState(GL_VERTEX_ARRAY);
		
		GLfloat verts[] = {x, y, x, y+h, x+w, y+h, x+w, y};
		
		glVertexPointer(2, GL_FLOAT, 0, verts);

		switch(mode)
		{
		case DRAW_LINE:
			// drop a pixel so that everything lines up properly
			verts[3]--;
			verts[4]--;
			verts[5]--;
			verts[6]--;
			glDrawArrays(GL_LINE_LOOP, 0, 4);
			break;
		default:
		case DRAW_FILL:
			verts[5] = y;
			verts[7] = y+h;
			glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
			break;
		}
		
		glDisableClientState(GL_VERTEX_ARRAY);

		glPopMatrix();
		glEnable(GL_TEXTURE_2D);
	}

	void Graphics::quad(DrawMode mode, float x1, float y1, float x2, float y2, float x3, float y3, float x4, float y4 )
	{
		glDisable(GL_TEXTURE_2D);
		glPushMatrix();
		
		glEnableClientState(GL_VERTEX_ARRAY);
		
		GLfloat verts[] = {x1, y1, x2, y2, x3, y3, x4, y4};
		
		glVertexPointer(2, GL_FLOAT, 0, verts);
		
		glDrawArrays((mode == DRAW_LINE ? GL_LINE_LOOP : GL_TRIANGLE_STRIP), 0, 4);
		
		glDisableClientState(GL_VERTEX_ARRAY);
		
		glPopMatrix();
		glEnable(GL_TEXTURE_2D);
	}

	void Graphics::circle(DrawMode mode, float x, float y, float radius, int points )
	{
		float two_pi = LOVE_M_PI * 2;
		if(points <= 0) points = 1;
		float angle_shift = (two_pi / points);

		glDisable(GL_TEXTURE_2D);
		glPushMatrix();

		glTranslatef(x, y, 0.0f);
		
		GLfloat verts[points*2];
		
		int p = 0;
		
		for(float i = 0; i < two_pi; i+= angle_shift) {
			verts[p] = radius * sin(i);
			verts[p+1] = radius * cos(i);
			p+=2;
		}
		
		glEnableClientState(GL_VERTEX_ARRAY);
		glVertexPointer(2, GL_FLOAT, 0, verts);
		
		glDrawArrays((mode == DRAW_LINE ? GL_LINE_LOOP : GL_TRIANGLE_FAN), 0, points);
		
		glDisableClientState(GL_VERTEX_ARRAY);

		glPopMatrix();
		glEnable(GL_TEXTURE_2D);
	}

	int Graphics::polygon( lua_State * L )
	{
		// Get number of params.
		int n = lua_gettop(L);

		// Need at least two params.
		if( n < 2 )
			return luaL_error(L, "Error: function needs at least two parameters.");

		DrawMode mode;

		const char * str = luaL_checkstring(L, 1);
		if(!getConstant(str, mode))
			return luaL_error(L, "Invalid draw mode: %s", str);

		// Get the type of the second argument.
		int luatype = lua_type(L, 2);

		// Perform additional type checking.
		switch(luatype)
		{
		case LUA_TNUMBER:
			if( n-1 < 6 ) return luaL_error(L, "Error: function requires at least 3 vertices.");
			if( ((n-1)%2) != 0 ) return luaL_error(L, "Error: number of vertices must be a multiple of two.");
			break;
		case LUA_TTABLE:
			if( (lua_objlen(L, 2)%2) != 0 ) return luaL_error(L, "Error: number of vertices must be a multiple of two.");
			break;
		default:
			return luaL_error(L, "Error: number type or table expected.");
		}

		glDisable(GL_TEXTURE_2D);
		
		glEnableClientState(GL_VERTEX_ARRAY);
		
		GLfloat * verts;

		switch(luatype)
		{
		case LUA_TNUMBER:
			n-=2;
			verts = new GLfloat[n];
			for(int i = 2; i<n; i+=2) {
				verts[i-2] = (GLfloat)lua_tonumber(L, i);
				verts[i-1] = (GLfloat)lua_tonumber(L, i+1);
			}
			break;
		case LUA_TTABLE:
			n = lua_objlen(L, 2);
			verts = new GLfloat[n];
			int i = 0;
			lua_pushnil(L);
			while (true)
			{
				if(lua_next(L, 2) == 0) break;
				GLfloat x = (GLfloat)lua_tonumber(L, -1);
				lua_pop(L, 1); // pop value
				if(lua_next(L, 2) == 0) break;
				GLfloat y = (GLfloat)lua_tonumber(L, -1);
				lua_pop(L, 1); // pop value
				verts[i] = x;
				verts[i+1] = y;
				i+=2;
			}
			break;
		}
		
		glVertexPointer(2, GL_FLOAT, 0, verts);

		glDrawArrays((mode==DRAW_LINE ? GL_LINE_LOOP : GL_TRIANGLE_FAN), 0, n/2);
		
		delete[] verts;
		
		glDisableClientState(GL_VERTEX_ARRAY);
		
		glEnable(GL_TEXTURE_2D);

		return 0;
	}
	
	void Graphics::push()
	{
		glPushMatrix();
	}

	void Graphics::pop()
	{
		glPopMatrix();
	}

	void Graphics::rotate(float r)
	{
		glRotatef(LOVE_TODEG(r), 0, 0, 1);
	}

	void Graphics::scale(float x, float y)
	{
		glScalef(x, y, 1);
	}

	void Graphics::translate(float x, float y)
	{
		glTranslatef(x, y, 0);
	}

	void Graphics::drawTest(Image * image, float x, float y, float a, float sx, float sy, float ox, float oy)
	{
		image->bind();

		// Buffer for transforming the image.
		vertex buf[4];

		Matrix t;
		t.translate(x, y);
		t.rotate(a);
		t.scale(sx, sy);
		t.translate(ox, oy);
		t.transform(buf, image->getVertices(), 4);

		const vertex * vertices = image->getVertices();

		glEnableClientState(GL_VERTEX_ARRAY);
		glEnableClientState(GL_TEXTURE_COORD_ARRAY);
		glVertexPointer(2, GL_FLOAT, sizeof(vertex), (GLvoid*)&buf[0].x);
		glTexCoordPointer(2, GL_FLOAT, sizeof(vertex), (GLvoid*)&vertices[0].s);
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
		glDisableClientState(GL_TEXTURE_COORD_ARRAY);
		glDisableClientState(GL_VERTEX_ARRAY);
	}

} // opengl
} // graphics
} // love
