//
//  SkypeController.h
//  SkypeCMD
//
//  Created by Sushant Verma on 29/01/11.
//  Copyright 2011 Sushant Verma. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Skype.h"

@interface SkypeController : NSObject {
	SkypeApplication *skype;
}

- (void) readCommandsAsyncFromFileHandle:(NSFileHandle *)fileHandle;
- (void) sendSkypeMessage:(NSString *)input;

- (void) skypeReady;

@end
