//
//  SBFileAcceptingImageView.m
//  Simba
//
//  Created by Zac Cohan on 10/11/11.
//  Copyright (c) 2011 Acqualia Software. All rights reserved.
//

#import "SBFileAcceptingImageView.h"

@implementation SBFileAcceptingImageView
@synthesize filePath;
@synthesize neighbourFileAcceptingImageView;
@synthesize preferredFileExtension;

- (void)awakeFromNib{
    [self registerForDraggedTypes:@[NSFilenamesPboardType]];

}


- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
    if ((NSDragOperationGeneric & [sender draggingSourceOperationMask]) 
        == NSDragOperationGeneric)
    {
        //this means that the sender is offering the type of operation we want
        //return that we want the NSDragOperationGeneric operation that they 
        //are offering

        return NSDragOperationCopy;
    }
    else
    {
        //since they aren't offering the type of operation we want, we have 
        //to tell them we aren't interested
        return NSDragOperationNone;
    }
}



- (void)draggingExited:(id <NSDraggingInfo>)sender
{
    //we aren't particularily interested in this so we will do nothing
    //this is one of the methods that we do not have to implement
//    NSLog(@"%@", sender);
}


- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    NSPasteboard *pboard = [sender draggingPasteboard];
    
    if ( [pboard.types containsObject:NSFilenamesPboardType] ) {
        //  NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
        //NSLog(@"%@", files);
        // Perform operation using the list of files
    }
    
    
    NSPasteboard *paste = [sender draggingPasteboard];
    
    //gets the dragging-specific pasteboard from the sender
    NSArray *types = @[NSFilenamesPboardType];
    //a list of types that we can accept
    NSString *desiredType = [paste availableTypeFromArray:types];
    NSData *carriedData = [paste dataForType:desiredType];
    
    if (nil == carriedData)
    {
        //the operation failed for some reason

        NSAlert *alert = [NSAlert new];
        alert.alertStyle = NSCriticalAlertStyle;
        alert.messageText = @"Paste Error";
                
        alert.informativeText = [NSString stringWithFormat:@"Sorry, but the past operation failed."];
        
        [alert runModal];
        
        return NO;
    }
    else
    {
        if ([desiredType isEqualToString:NSFilenamesPboardType])
        {
            //we have a list of file names in an NSData object
            NSArray *fileArray = 
            [paste propertyListForType:NSFilenamesPboardType];
            //be caseful since this method returns id.  
            //We just happen to know that it will be an array.
                        
            for (NSString *aFilePath in fileArray) {
                
                if (!self.preferredFileExtension){
                    self.filePath = aFilePath;
                    [self sendAction:self.action to:self.target];
                }
                else if (self.preferredFileExtension && [aFilePath.pathExtension isEqualToString:self.preferredFileExtension]){
                    self.filePath = aFilePath;
                    [self sendAction:self.action to:self.target];
                }
                else if (self.neighbourFileAcceptingImageView &&[aFilePath.pathExtension isEqualToString:self.neighbourFileAcceptingImageView.preferredFileExtension]){
                    
                        (self.neighbourFileAcceptingImageView).filePath = aFilePath;
                        [self.neighbourFileAcceptingImageView sendAction:self.neighbourFileAcceptingImageView.action to:self.neighbourFileAcceptingImageView.target];
                }
                else{
                    return NO;
                }
                
            }                
        
        }
        else
        {
            //this can't happen
            NSAssert(NO, @"This can't happen");
            return NO;
        }
    }

    return YES;
}

- (void)setImage:(NSImage *)image{
    super.image = image;
    
    if (!image){
        [self setFilePath:nil];
    }
}

- (void)setFilePath:(NSString *)aFilePath{
    if (filePath != aFilePath){
        filePath = aFilePath;
        if (filePath){
             self.image = [[NSWorkspace sharedWorkspace] iconForFile:filePath];   
        }
    }
}


@end
