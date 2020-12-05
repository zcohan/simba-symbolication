//
//  AtosBasedSymbolicator.h
//  Simba
//
//  Created by Zac Cohan on 30/10/20.
//  Copyright © 2020 Acqualia Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ExecutableInfo : NSObject

@property (strong, nonatomic) NSURL *_Nonnull executableURL;
@property (strong, nonatomic) NSString * _Nonnull UUID;
@property (strong, nonatomic) NSString * _Nonnull architecture;
@property (strong, nonatomic) NSString * _Nonnull loadAddress;

@property (readonly, nonatomic) NSString * _Nonnull executableName;

@end

NS_ASSUME_NONNULL_BEGIN

@interface AtosBasedSymbolicator : NSObject

/// Uses Dwarf dump to compare UUIDs
- (ExecutableInfo *)verifyExecutable:(NSURL *)executable matchesDSYM:(NSURL *)dsym andCrashReport:(NSURL *)crashReport;

// Uses Atos to symbolicate lines in the crash report
- (NSString *)symbolicateCrashReport:(NSURL *)crashReport usingExecutableInfo:(ExecutableInfo *)executableInfo;

@end

NS_ASSUME_NONNULL_END
