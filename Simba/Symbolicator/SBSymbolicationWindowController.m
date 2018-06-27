//
//  SBSymbolicationWindow.m
//  Simba
//
//  Created by Zac Cohan on 11/11/11.
//  Copyright (c) 2011 Acqualia Software. All rights reserved.
//

#import "SBSymbolicationWindowController.h"

@implementation SBSymbolicationWindowController
@synthesize fileName;
@synthesize crashReport;
@synthesize textView;

- (instancetype)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)_highlightRange:(NSValue *)aRangeValue{
    
    [textView showFindIndicatorForRange:aRangeValue.rangeValue];
}


- (void)windowDidLoad
{
    [super windowDidLoad];
        
    textView.string = crashReport;
    self.window.title = fileName;
    
    NSString *stringToHoneInOn = @"Crashed::";
    NSRange rangeOfStringToHoneInOn = [crashReport rangeOfString:stringToHoneInOn];
    
    if (rangeOfStringToHoneInOn.location != NSNotFound){
        [textView scrollRangeToVisible:rangeOfStringToHoneInOn];
        
        NSRange rangeToTheEndOfThatLine = [crashReport rangeOfString:@"\n" options:NSCaseInsensitiveSearch range:NSMakeRange(rangeOfStringToHoneInOn.location+rangeOfStringToHoneInOn.length, crashReport.length-(rangeOfStringToHoneInOn.location+rangeOfStringToHoneInOn.length))];
        
        NSRange rangeToTheBeginningOfTheLine = [crashReport rangeOfString:@"\n" options:NSBackwardsSearch range:NSMakeRange(rangeOfStringToHoneInOn.location - 20, 20)];
        
        NSRange finalRangeTohighlight = NSMakeRange(rangeToTheBeginningOfTheLine.location+1, (rangeToTheEndOfThatLine.location-1) - rangeToTheBeginningOfTheLine.location);
            
        
        [self performSelector:@selector(_highlightRange:) withObject:[NSValue valueWithRange:finalRangeTohighlight] afterDelay:0.5];
    }
}

- (IBAction)saveToFile:(id)sender {
    
    NSSavePanel *savePanel = [NSSavePanel savePanel];
        
    savePanel.allowedFileTypes = @[@"crash"];
    savePanel.nameFieldStringValue = fileName;
    [savePanel setExtensionHidden:NO];
    
    [savePanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        
        NSURL *savePanelURL = savePanel.URL;
        
        [crashReport writeToURL:savePanelURL atomically:YES encoding:NSUTF8StringEncoding error:nil];
        
    }];
    
}

@end
