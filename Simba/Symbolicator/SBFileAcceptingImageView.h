//
//  SBFileAcceptingImageView.h
//  Simba
//
//  Created by Zac Cohan on 10/11/11.
//  Copyright (c) 2011 Acqualia Software. All rights reserved.
//



@interface SBFileAcceptingImageView : NSImageView

@property (nonatomic, weak) IBOutlet SBFileAcceptingImageView *neighbourFileAcceptingImageView;

@property (nonatomic, strong) NSString *preferredFileExtension;
@property (nonatomic, strong) NSString *filePath;

@end
