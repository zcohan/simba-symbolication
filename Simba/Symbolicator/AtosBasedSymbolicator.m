//
//  AtosBasedSymbolicator.m
//  Simba
//
//  Created by Zac Cohan on 30/10/20.
//  Copyright © 2020 Acqualia Software. All rights reserved.
//

#import "AtosBasedSymbolicator.h"

@implementation ExecutableInfo

- (NSString *)executableName {
    return self.executableURL.lastPathComponent;
}

@end

@implementation AtosBasedSymbolicator

- (ExecutableInfo *)verifyExecutable:(NSURL *)executable matchesDSYM:(NSURL *)dsym andCrashReport:(NSURL *)crashReport {
    
    ExecutableInfo * executableInfo = [self UUIDFromExecutableURL:executable];
    executableInfo.executableURL = executable;
    
    ExecutableInfo * dsymInfo = [self UUIDFromExecutableURL:dsym];
    
    if (!executableInfo || !dsymInfo) {
        NSAlert *alert = [NSAlert new];
        alert.alertStyle = NSWarningAlertStyle;
        alert.messageText = @"Error verifying UUIDs";
                
        alert.informativeText = @"Could not parse UUIDs from either the executable or dsym file using Dwarfdump";
        [alert runModal];
        return nil;
    }
    
    if ([executableInfo.UUID isEqualTo: dsymInfo.UUID] == NO) {
        
        NSAlert *alert = [NSAlert new];
        alert.alertStyle = NSCriticalAlertStyle;
        alert.messageText = @"Non-matching UUIDs";
                
        alert.informativeText = [NSString stringWithFormat:@"The executable UUID '%@' does not match the dsym UUID '%@'. You probably have the wrong executable for these symbols. Find the actual executable for these symbols and try again.", executableInfo.UUID, dsymInfo.UUID];
        
        [alert runModal];
        
        return nil;
        
    }

    
    NSError *openCrashReportError;
    NSString * crashReportContents = [NSString stringWithContentsOfURL:crashReport encoding:NSUTF8StringEncoding error:&openCrashReportError];
             
    if (openCrashReportError) {
        [[NSAlert alertWithError:openCrashReportError] runModal];
        return nil;
    }
    
    if (![crashReportContents containsString:executableInfo.UUID]) {
        
        NSAlert *alert = [NSAlert new];
        alert.alertStyle = NSCriticalAlertStyle;
        alert.messageText = @"Crash report is not from this executable";
                
        alert.informativeText = [NSString stringWithFormat:@"The crash report does not reference the executable UUID '%@'. It's probably from a different executable.", executableInfo.UUID];
        
        [alert runModal];
        
        return nil;

    }
    else {
        // Search for load address
     
        NSArray *lines = [crashReportContents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        
        for (NSString * line in lines) {
            
            if ([line containsString:executableInfo.UUID]) {
                
                NSString * trimmedLine = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                
                NSArray *lineComponents = [trimmedLine componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                
                if (lineComponents.count > 1 && [lineComponents[0] hasPrefix:@"0x"]) {
                    executableInfo.loadAddress = lineComponents[0];
                }
                
            }
        }
        
        if (executableInfo.loadAddress == nil) {
            
            NSAlert *alert = [NSAlert new];
            alert.alertStyle = NSCriticalAlertStyle;
            alert.messageText = @"Load address not found";
                    
            alert.informativeText = [NSString stringWithFormat:@"The load address was not found in the crash report."];
            
            [alert runModal];
            
            return nil;

        }

        
    }
    
    return executableInfo;
    
    
    
}

- (ExecutableInfo *)UUIDFromExecutableURL:(NSURL *)executableURL {
    
    NSTask *task = [NSTask new];

    task.launchPath = @"/usr/bin/xcrun";
    task.arguments = @[@"dwarfdump", executableURL.path, @"--uuid"];
        
    NSPipe *readPipe = [NSPipe pipe];
    NSPipe *errorPipe = [NSPipe pipe];
    
    task.standardOutput = readPipe;
    task.standardError = errorPipe;
    
    NSFileHandle *readHandle = readPipe.fileHandleForReading;

    [task launch];

    NSData *data = [readHandle readDataToEndOfFile];
    
    if (!data.length){
        NSLog(@"No UUID detected");
        
        return nil;
    }
    
    
    NSString *UUIDString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    NSArray *components = [UUIDString componentsSeparatedByString:@" "];
    
    if (components.count >= 2) {
        ExecutableInfo *info = [ExecutableInfo new];
        
        info.UUID = components[1];
        info.architecture = [components[2] stringByTrimmingCharactersInSet:[NSCharacterSet punctuationCharacterSet]];
        
        return info;
    }
    
    
    return nil;
    
    
    
}


- (NSString *)symbolicateCrashReport:(NSURL *)crashReport usingExecutableInfo:(ExecutableInfo  *)executableInfo {
    
    NSError *openCrashReportError;
    
    NSString * crashReportContents = [NSString stringWithContentsOfURL:crashReport encoding:NSUTF8StringEncoding error:&openCrashReportError];
    
    if (openCrashReportError) {
        [[NSAlert alertWithError:openCrashReportError] runModal];
        return nil;
    }
    
    if (![crashReportContents containsString:executableInfo.UUID]) {
        
        NSAlert *alert = [NSAlert new];
        alert.alertStyle = NSCriticalAlertStyle;
        alert.messageText = @"Crash report is not from this executable";
        
        alert.informativeText = [NSString stringWithFormat:@"The crash report does not reference the executable UUID '%@'. It's probably from a different executable.", executableInfo.UUID];
        
        [alert runModal];
        
        return nil;
        
    }
    else {
        // Search for load address
        
        NSMutableArray *outputLines = [NSMutableArray new];
        
        [crashReportContents enumerateLinesUsingBlock:^(NSString * _Nonnull line, BOOL * _Nonnull stop) {
            
            if ([line containsString:executableInfo.loadAddress] || [line containsString:executableInfo.executableName]) {
                                
                [outputLines addObject:[self symbolicatedLineForUnsymbolicatedLine:line info:executableInfo]];
                
                
            }
            else {
                // non symbolication line, don't touch
                [outputLines addObject:line];
            }

        }];
                
        return [outputLines componentsJoinedByString:@"\n"];
                
    }
    
}




- (NSString *)symbolicatedLineForUnsymbolicatedLine:(NSString *)unsymbolicatedLine info:(ExecutableInfo *)info {
    
    NSArray *components = [unsymbolicatedLine componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSString *addressToSymbolicate = nil;
    
    for (NSString *component in components) {
        
        if ([component hasPrefix:@"0x"] && ![component isEqualTo:info.loadAddress]) {
            
            addressToSymbolicate = component;
            
            // gotcha
            break;
        }
    }
    
    
    if (addressToSymbolicate) {
        NSString *symbolicatedSymbol = [[self symbolicateWithAtos:addressToSymbolicate info:info] stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        
        if (symbolicatedSymbol) {
            NSString *outputLine = [unsymbolicatedLine stringByReplacingOccurrencesOfString:addressToSymbolicate withString:symbolicatedSymbol];
            
            return outputLine;
        }
        
    }
            
    NSLog(@"Failed to symbolicate this line");
    return unsymbolicatedLine;
    
}

- (NSString *)symbolicateWithAtos:(NSString *)address info:(ExecutableInfo *)info {
    
    NSTask *task = [NSTask new];

    // Example:
//    atos -arch x86_64 -o SoulverCore -l 0x10cd92000 0x000000010ce18bf5
    task.launchPath = @"/usr/bin/xcrun";
    task.arguments = @[@"atos", @"-arch", info.architecture, @"-o", info.executableURL, @"-l", info.loadAddress, address];
        
    NSPipe *readPipe = [NSPipe pipe];
    NSPipe *errorPipe = [NSPipe pipe];
    
    task.standardOutput = readPipe;
    task.standardError = errorPipe;
    
    NSFileHandle *readHandle = readPipe.fileHandleForReading;

    [task launch];

    NSData *data = [readHandle readDataToEndOfFile];
    
    if (!data.length){
        NSLog(@"No UUID detected");
        return nil;
    }
    
    NSString *symbolicatedAddress = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    return symbolicatedAddress;
    
}






@end
