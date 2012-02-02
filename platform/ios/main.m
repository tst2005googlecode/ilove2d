//
//  main.m
//  love
//
//  Created by Bill Meltsner on 7/17/10.
//  Copyright Bill Meltsner 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

int main(int argc, char *argv[]) {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, nil, @"loveAppDelegate");
    [pool release];
    return retVal;
}
