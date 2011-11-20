//
//  SBFileAcceptingImageView.h
//  Simba
//
//  Created by Zac Cohan on 10/11/11.
//  Copyright (c) 2011 Acqualia Software. All rights reserved.
//



@interface SBFileAcceptingImageView : NSImageView

@property (nonatomic, assign) IBOutlet SBFileAcceptingImageView *neighbourFileAcceptingImageView;

@property (nonatomic, retain) NSString *preferredFileExtension;
@property (nonatomic, retain) NSString *filePath;

@end
