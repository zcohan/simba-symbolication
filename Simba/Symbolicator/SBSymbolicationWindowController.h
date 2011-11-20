//
//  SBSymbolicationWindow.h
//  Simba
//
//  Created by Zac Cohan on 11/11/11.
//  Copyright (c) 2011 Acqualia Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SBSymbolicationWindowController : NSWindowController

@property (retain, nonatomic) NSString *fileName;
@property (retain, nonatomic) NSString *crashReport;
@property (assign) IBOutlet NSTextView *textView;


- (IBAction)saveToFile:(id)sender;

@end
