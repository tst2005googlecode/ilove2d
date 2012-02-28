//
//  EAGLView.m
//  love
//
//  Created by Bill Meltsner on 7/17/10.
//  Copyright Bill Meltsner 2010. All rights reserved.
//

#include <common/FSDL_Events.h>
#import "EAGLView.h"

@implementation EAGLView

@synthesize context;
@synthesize width;
@synthesize height;
@synthesize mousex;
@synthesize mousey;
@synthesize mouse_state;

// You must implement this method
+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

- (id)initWithFrame:(CGRect)frame
{    
    if ((self = [super initWithFrame:frame]))
    {
        [self setUserInteractionEnabled:YES];
        // Get the layer
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;

        eaglLayer.opaque = TRUE;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
		context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
        if (!context || ![EAGLContext setCurrentContext:context])
        {
            return nil;
        }
		
        // Create default framebuffer object.
        glGenFramebuffersOES(1, &defaultFramebuffer);
        glGenRenderbuffersOES(1, &colorRenderbuffer);
        glBindFramebufferOES(GL_FRAMEBUFFER_OES, defaultFramebuffer);
        glBindRenderbufferOES(GL_RENDERBUFFER_OES, colorRenderbuffer);
		
		// Allocate color buffer backing based on the current layer size
		if (![context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(CAEAGLLayer*)self.layer]) {
			return nil;
		}
        glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, colorRenderbuffer);
		glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &width);
		glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &height);
		
		if (glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES)
		{
			NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
			return nil;
		}
		
		// Enable blending
		glEnable(GL_BLEND);
		
		// "Normal" blending
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		
		// Enable line/point smoothing.
		glEnable(GL_LINE_SMOOTH);
		glHint(GL_LINE_SMOOTH_HINT, GL_NICEST);
		glEnable(GL_POINT_SMOOTH);
		glHint(GL_POINT_SMOOTH_HINT, GL_NICEST);
		
		// Enable textures
		glEnable(GL_TEXTURE_2D);
		
		glViewport(0, 0, width, height);
		
		glMatrixMode(GL_PROJECTION);
		glLoadIdentity();
		glOrthof(0.0f, (GLfloat)width, (GLfloat)height, 0.0f, 0.0f, 1.0f);
		glMatrixMode(GL_MODELVIEW);
		glLoadIdentity();
    }

    return self;
}
- (BOOL)touchesShouldBegin:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view  
{          
    return YES;  
}  
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event  
{          
    /*if (delegatrue)          
    {                  
        [delegate imageTouch:touches withEvent:event whichView:self];          
    }*/
    //NSLog(@"touches begin");
    UITouch *touch = [touches anyObject];
    CGPoint tpoint = [touch locationInView:[touch view]];
    mousex = tpoint.x;
    mousey = tpoint.y;
    mouse_state = 0;
    
    FSDL_Event* s_event = new FSDL_Event;
    //s_event->mouse = new FSDL_MouseEvent;
    s_event->type = FSDL_MOUSEBUTTONUP;
    //s_event->mouse.button = FSDL_BUTTON_LEFT;
    s_event->mouse.x = mousex;
    s_event->mouse.y = mousey;
    msgQ.push(s_event);
    
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    //NSLog(@"touches moved");
    UITouch *touch = [touches anyObject];
    CGPoint tpoint = [touch locationInView:[touch view]];
    mousex = tpoint.x;
    mousey = tpoint.y;
    mouse_state = 1;
    
    FSDL_Event* s_event = new FSDL_Event;
    //s_event->mouse = new FSDL_MouseEvent;
    s_event->type = FSDL_NOEVENT;
    //s_event->mouse.button = FSDL_BUTTON_LEFT;
    s_event->mouse.x = mousex;
    s_event->mouse.y = mousey;
    msgQ.push(s_event);
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    //NSLog(@"touches end");
    UITouch *touch = [touches anyObject];
    CGPoint tpoint = [touch locationInView:[touch view]];
    mousex = tpoint.x;
    mousey = tpoint.y;
    mouse_state = 0;
    
    FSDL_Event* s_event = new FSDL_Event;
    //s_event->mouse = new FSDL_MouseEvent;
    s_event->type = FSDL_MOUSEBUTTONDOWN;
    s_event->mouse.button = FSDL_BUTTON_LEFT;
    s_event->mouse.x = mousex;
    s_event->mouse.y = mousey;
    msgQ.push(s_event);
    
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (void)drawView
{
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, colorRenderbuffer);
	[context presentRenderbuffer:colorRenderbuffer];
}

- (void)dealloc
{
	if (colorRenderbuffer) {
		glDeleteRenderbuffersOES(1, &colorRenderbuffer);
		colorRenderbuffer = 0;
	}
	if (defaultFramebuffer){
		glDeleteFramebuffersOES(1, &defaultFramebuffer);
		defaultFramebuffer = 0;
	}
	if ([EAGLContext currentContext] == context) {
		[EAGLContext setCurrentContext:nil];
	}
	[context release];
    [super dealloc];
}

@end
