//
//  loveAppDelegate.m
//  love
//
//  Created by Bill Meltsner on 7/17/10.
//  Copyright Bill Meltsner 2010. All rights reserved.
//

#import "loveAppDelegate.h"
#import "EAGLView.h"
#include "love.h"

@implementation loveAppDelegate

@synthesize glView;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	glView = [[EAGLView alloc] initWithFrame:[window frame]];
	[window addSubview:glView];
	[window makeKeyAndVisible];
	launched = NO;
	dispatch_queue_t queue = dispatch_queue_create("org.love2d.mainQueue", NULL);
	dispatch_async(queue, ^{
		love_main();
	});
	return YES;
}

- (void)dealloc
{
    [window release];
    [glView release];

    [super dealloc];
}

@end
