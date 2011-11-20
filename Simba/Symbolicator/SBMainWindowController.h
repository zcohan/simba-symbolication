//
//  Controller.h
//  Simba
//
//  Created by Zac Cohan on 10/11/11.
//  Copyright (c) 2011 Acqualia Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBFileAcceptingImageView.h"

@interface SBMainWindowController : NSObject

@property (assign) IBOutlet SBFileAcceptingImageView *dSYMImageWell;
@property (assign) IBOutlet SBFileAcceptingImageView *crashFileImageWell;

@property (retain, nonatomic) NSString *dSYMPath;
@property (retain, nonatomic) NSString *crashFilePath;

@property (nonatomic) BOOL canSymbolicate;

- (IBAction)symbolicate:(id)sender;
- (IBAction)fileDraggedIn:(SBFileAcceptingImageView *)sender;

@end
