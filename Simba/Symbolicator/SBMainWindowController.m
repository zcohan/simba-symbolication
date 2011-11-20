//
//  Controller.m
//  Symbolicator
//
//  Created by Zac Cohan on 10/11/11.
//  Copyright (c) 2011 Acqualia Software. All rights reserved.
//

#import "SBMainWindowController.h"
#import "SBSymbolicationWindowController.h"

@implementation SBMainWindowController
@synthesize dSYMImageWell;
@synthesize crashFileImageWell;
@synthesize dSYMPath, crashFilePath;
@synthesize canSymbolicate;

- (void)awakeFromNib{

    if ([[NSFileManager defaultManager] fileExistsAtPath:[[NSUserDefaults standardUserDefaults] stringForKey:@"SBdSYMPath"]]){
        self.dSYMPath = [[NSUserDefaults standardUserDefaults] stringForKey:@"SBdSYMPath"];        
    }

    if ([[NSFileManager defaultManager] fileExistsAtPath:[[NSUserDefaults standardUserDefaults] stringForKey:@"SBCrashFilePath"]]){
            self.crashFilePath = [[NSUserDefaults standardUserDefaults] stringForKey:@"SBCrashFilePath"];
    }

    
    self.crashFileImageWell.preferredFileExtension = @"crash";
    self.dSYMImageWell.preferredFileExtension = @"dSYM";
    
}

- (IBAction)symbolicate:(id)sender {
    
    NSString *pathToSymbolicator = [[NSBundle mainBundle] pathForResource:@"symbolicatecrash-mac" ofType:@"pl"];
        
    if (!self.crashFilePath || !self.dSYMPath){
        NSLog(@"Warning: No crash file or dsymFile, cannot symbolicate");
        return;
    }
    
    NSTask *task = [NSTask new];

    [task setLaunchPath:pathToSymbolicator];
    [task setArguments:[NSArray arrayWithObjects:self.crashFilePath, self.dSYMPath, nil]];
        
    NSPipe *readPipe = [NSPipe pipe];
    NSPipe *errorPipe = [NSPipe pipe];
    
    [task setStandardOutput:readPipe];
    [task setStandardError:errorPipe];
    
    NSFileHandle *readHandle = [readPipe fileHandleForReading];
    NSFileHandle *errorHandle = [errorPipe fileHandleForReading];

    [task launch];

    NSData *data = [readHandle readDataToEndOfFile];
    
    if (![data length]){
        NSLog(@"Warning no standard data returned");
        
        NSData *errorData = [errorHandle readDataToEndOfFile];
        NSString *errorString = [[[NSString alloc] initWithData:errorData encoding:NSUTF8StringEncoding] autorelease];
        
        //handle the error nik was telling me about
        NSString *standardErrorPrefix = @"Error: Symbol UUID";
        
        if ([errorString rangeOfString:standardErrorPrefix].location != NSNotFound){
            NSAlert *alert = [NSAlert new];
            [alert setAlertStyle:NSWarningAlertStyle];
            [alert setMessageText:@"The crash report does not match the dSYM file and cannot be symbolicated."];
            
            NSString *stringToParseUpTo = @"at /";
            NSRange rangeOfStringToParseUpTo = [errorString rangeOfString:stringToParseUpTo];
            
            [alert setInformativeText:[errorString substringToIndex:rangeOfStringToParseUpTo.location]];
            [alert runModal];
        }
        
        return;
    }
    
    
    NSString *symbolicatedCrashReport = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    
    if (![symbolicatedCrashReport length]){
        NSLog(@"Error interpreting data");
        return;
    }
    
    SBSymbolicationWindowController *symbolicatorWindowController = [[SBSymbolicationWindowController alloc] initWithWindowNibName:@"SymbolicationWindow"];
    symbolicatorWindowController.crashReport = symbolicatedCrashReport;
    symbolicatorWindowController.fileName = [self.crashFilePath lastPathComponent];
    
    [symbolicatorWindowController showWindow:nil];
    [task release];
    
    
}

- (IBAction)fileDraggedIn:(SBFileAcceptingImageView *)sender{
    
    if (sender == dSYMImageWell){
        self.dSYMPath = sender.filePath;
    }
    else if (sender == crashFileImageWell){
        self.crashFilePath = sender.filePath;
    }
    
}

#pragma mark -
#pragma mark Setters

- (void)setDSYMPath:(NSString *)aDSYMPath
{
    if (dSYMPath != aDSYMPath) {
        [aDSYMPath retain];
        [dSYMPath release];
        dSYMPath = aDSYMPath;
        dSYMImageWell.filePath = self.dSYMPath;
        [[NSUserDefaults standardUserDefaults] setObject:self.dSYMPath forKey:@"SBdSYMPath"];

        if (self.crashFilePath && self.dSYMPath){
            self.canSymbolicate = YES;        
        }
        else{
            self.canSymbolicate = NO;
        }

    }
}

- (void)setCrashFilePath:(NSString *)aCrashFilePath
{
    if (crashFilePath != aCrashFilePath) {
        [aCrashFilePath retain];
        [crashFilePath release];
        crashFilePath = aCrashFilePath;
        [[NSUserDefaults standardUserDefaults] setObject:self.crashFilePath forKey:@"SBCrashFilePath"];

        crashFileImageWell.filePath = crashFilePath;

        if (self.crashFilePath && self.dSYMPath){
            self.canSymbolicate = YES;        
        }
        else{
            self.canSymbolicate = NO;
        }
        
    }
}




@end
