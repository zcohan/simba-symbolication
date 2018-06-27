//
//  AppDelegate.h
//  Simba
//
//  Created by Zac Cohan on 10/11/11.
//  Copyright (c) 2011 Acqualia Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SBMainWindowController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet SBMainWindowController *mainWindowController;
@end
