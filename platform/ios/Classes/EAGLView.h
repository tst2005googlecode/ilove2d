//
//  EAGLView.h
//  love
//
//  Created by Bill Meltsner on 7/17/10.
//  Copyright Bill Meltsner 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

// This class wraps the CAEAGLLayer from CoreAnimation into a convenient UIView subclass.
// The view content is basically an EAGL surface you render your OpenGL scene into.
// Note that setting the view non-opaque will only work if the EAGL surface has an alpha channel.
@interface EAGLView : UIView
{    
	// The OpenGL ES context.
	EAGLContext * context;
	
	// The OpenGL ES names for the framebuffer and renderbuffer used to render graphics
	GLuint defaultFramebuffer, colorRenderbuffer;
	
	GLint width, height;
}
@property (readonly) EAGLContext * context;
@property (readonly) int width;
@property (readonly) int height;
@property (readonly) int mousex;
@property (readonly) int mousey;
@property (readonly) int mouse_state;

- (void)drawView;

@end
