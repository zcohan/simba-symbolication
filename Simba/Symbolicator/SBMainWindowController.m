//
//  Controller.m
//  Symbolicator
//
//  Created by Zac Cohan on 10/11/11.
//  Copyright (c) 2011 Acqualia Software. All rights reserved.
//

#import "SBMainWindowController.h"
#import "SBSymbolicationWindowController.h"
#import "AtosBasedSymbolicator.h"

@implementation SBMainWindowController
@synthesize dSYMImageWell;
@synthesize crashFileImageWell;
@synthesize executableImagWell;
@synthesize dSYMPath, crashFilePath, executablePath;
@synthesize canSymbolicate;

- (void)awakeFromNib{

    if ([[NSFileManager defaultManager] fileExistsAtPath:[[NSUserDefaults standardUserDefaults] stringForKey:@"SBdSYMPath"]]){
        self.dSYMPath = [[NSUserDefaults standardUserDefaults] stringForKey:@"SBdSYMPath"];        
    }

    if ([[NSFileManager defaultManager] fileExistsAtPath:[[NSUserDefaults standardUserDefaults] stringForKey:@"SBCrashFilePath"]]){
            self.crashFilePath = [[NSUserDefaults standardUserDefaults] stringForKey:@"SBCrashFilePath"];
    }

    if ([[NSFileManager defaultManager] fileExistsAtPath:[[NSUserDefaults standardUserDefaults] stringForKey:@"SEExecutablePath"]]){
            self.executablePath = [[NSUserDefaults standardUserDefaults] stringForKey:@"SEExecutablePath"];
    }


    
    self.crashFileImageWell.preferredFileExtension = @"crash";
    self.dSYMImageWell.preferredFileExtension = @"dSYM";
    
}


- (IBAction)fileDraggedIn:(SBFileAcceptingImageView *)sender{
    
    if (sender == dSYMImageWell){
        self.dSYMPath = sender.filePath;
    }
    else if (sender == crashFileImageWell){
        self.crashFilePath = sender.filePath;
    }
    else if (sender == executableImagWell){
        self.executablePath = sender.filePath;
    }

    
}

#pragma mark -
#pragma mark Setters

- (void)setDSYMPath:(NSString *)aDSYMPath
{
    if (dSYMPath != aDSYMPath) {
        dSYMPath = aDSYMPath;
        dSYMImageWell.filePath = self.dSYMPath;
        [[NSUserDefaults standardUserDefaults] setObject:self.dSYMPath forKey:@"SBdSYMPath"];

        [self updateSymoblicationState];

    }
}

- (void)setCrashFilePath:(NSString *)aCrashFilePath
{
    if (crashFilePath != aCrashFilePath) {
        crashFilePath = aCrashFilePath;
        [[NSUserDefaults standardUserDefaults] setObject:self.crashFilePath forKey:@"SBCrashFilePath"];

        crashFileImageWell.filePath = crashFilePath;

        [self updateSymoblicationState];

    }
}

- (void)updateSymoblicationState {
    
    if (self.crashFilePath && self.dSYMPath && self.executablePath){
        self.canSymbolicate = YES;
    }
    else{
        self.canSymbolicate = NO;
    }

    
}

- (void)setExecutablePath:(NSString *)anExecutablePath
{
    if (executablePath != anExecutablePath) {
        executablePath = anExecutablePath;
        [[NSUserDefaults standardUserDefaults] setObject:self.executablePath forKey:@"SEExecutablePath"];

        executableImagWell.filePath = executablePath;

        [self updateSymoblicationState];
        
    }
}

#pragma mark -
#pragma mark Symbolication


- (IBAction)symbolicate:(id)sender {
    
    if (!self.crashFilePath || !self.dSYMPath || !self.executablePath){
        NSLog(@"Warning: No crash file or dsymFile, cannot symbolicate");
        return;
    }
    
    // Verify the files match
    ExecutableInfo * info = [[AtosBasedSymbolicator new] verifyExecutable:[NSURL fileURLWithPath:self.executablePath] matchesDSYM:[NSURL fileURLWithPath:self.dSYMPath] andCrashReport:[NSURL fileURLWithPath:self.crashFilePath]];
    
    if (info == nil) {
        return;
    }
        
    NSString *symbolicatedCrashReport = [[AtosBasedSymbolicator new] symbolicateCrashReport:[NSURL fileURLWithPath:self.crashFilePath] usingExecutableInfo:info];
    

    if (!symbolicatedCrashReport){
        NSLog(@"Failed to symbolicate");
        return;
    }
    
    SBSymbolicationWindowController *symbolicatorWindowController = [[SBSymbolicationWindowController alloc] initWithWindowNibName:@"SymbolicationWindow"];
    symbolicatorWindowController.crashReport = symbolicatedCrashReport;
    symbolicatorWindowController.fileName = (self.crashFilePath).lastPathComponent;
    [symbolicatorWindowController showWindow:nil];
    
}


@end


//NSString *pathToSymbolicator = [[NSBundle mainBundle] pathForResource:@"symbolicatecrash-mac" ofType:nil];
//
//
//NSTask *task = [NSTask new];
//
//task.launchPath = pathToSymbolicator;
//task.arguments = @[self.crashFilePath, self.dSYMPath];
//
//NSPipe *readPipe = [NSPipe pipe];
//NSPipe *errorPipe = [NSPipe pipe];
//
//task.standardOutput = readPipe;
//task.standardError = errorPipe;
//
//NSFileHandle *readHandle = readPipe.fileHandleForReading;
//NSFileHandle *errorHandle = errorPipe.fileHandleForReading;
//
//[task launch];
//
//NSData *data = [readHandle readDataToEndOfFile];
//
//if (!data.length){
//    NSLog(@"Warning no standard data returned");
//
//    NSData *errorData = [errorHandle readDataToEndOfFile];
//    NSString *errorString = [[NSString alloc] initWithData:errorData encoding:NSUTF8StringEncoding];
//
//    //handle the error nik was telling me about
//    NSString *standardErrorPrefix = @"Error: Symbol UUID";
//
//    if ([errorString rangeOfString:standardErrorPrefix].location != NSNotFound){
//        NSAlert *alert = [NSAlert new];
//        alert.alertStyle = NSWarningAlertStyle;
//        alert.messageText = @"The crash report does not match the dSYM file and cannot be symbolicated.";
//
//        NSString *stringToParseUpTo = @"at /";
//        NSRange rangeOfStringToParseUpTo = [errorString rangeOfString:stringToParseUpTo];
//
//        alert.informativeText = [errorString substringToIndex:rangeOfStringToParseUpTo.location];
//        [alert runModal];
//    }
//
//    return;
//}
