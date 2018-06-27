//
//  AppDelegate.m
//  Simba
//
//  Created by Zac Cohan on 10/11/11.
//  Copyright (c) 2011 Acqualia Software. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize mainWindowController;


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender{
    return YES;
}

- (void)application:(NSApplication *)sender openFiles:(NSArray *)filenames{
    NSLog(@"Files are %@", filenames);
    
    for (NSString *path in filenames){
        if ([path.pathExtension isEqualToString:@"dSYM"]){
            mainWindowController.dSYMPath = path;
        }
        else if ([path.pathExtension isEqualToString:@"crash"]){
            mainWindowController.crashFilePath = path;
        }

    }

}


@end
