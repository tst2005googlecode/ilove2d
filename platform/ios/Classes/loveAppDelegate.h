//
//  loveAppDelegate.h
//  love
//
//  Created by Bill Meltsner on 7/17/10.
//  Copyright Bill Meltsner 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EAGLView;

@interface loveAppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow *window;
    EAGLView *glView;
	BOOL launched;
    CGPoint currentTouch;
}

@property (nonatomic, retain) EAGLView *glView;

@end

