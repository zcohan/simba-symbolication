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

@property (weak) IBOutlet SBFileAcceptingImageView *dSYMImageWell;
@property (weak) IBOutlet SBFileAcceptingImageView *crashFileImageWell;
@property (weak) IBOutlet SBFileAcceptingImageView *executableImagWell;

@property (strong, nonatomic) NSString *dSYMPath;
@property (strong, nonatomic) NSString *crashFilePath;
@property (strong, nonatomic) NSString *executablePath;


@property (nonatomic) BOOL canSymbolicate;
@property (nonatomic) BOOL isProcessing;

- (IBAction)symbolicate:(id)sender;
- (IBAction)fileDraggedIn:(SBFileAcceptingImageView *)sender;

@end
