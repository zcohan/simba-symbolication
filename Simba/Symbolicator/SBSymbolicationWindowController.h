//
//  SBSymbolicationWindow.h
//  Simba
//
//  Created by Zac Cohan on 11/11/11.
//  Copyright (c) 2011 Acqualia Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SBSymbolicationWindowController : NSWindowController

@property (strong, nonatomic) NSString *fileName;
@property (strong, nonatomic) NSString *crashReport;
@property (unsafe_unretained) IBOutlet NSTextView *textView;
@property (weak) IBOutlet NSButton *saveToFileButton;


- (IBAction)saveAsFile:(id)sender;

@end
