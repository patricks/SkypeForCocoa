//
//  main.m
//  Skype For Cocoa
//
//  Created by Sushant Verma on 7/9/11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SkypeController.h"

int main (int argc, const char * argv[])
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
	NSFileHandle *inputStream = [NSFileHandle fileHandleWithStandardInput];
    
	SkypeController *skypeController = [[SkypeController alloc] init];
    
    if (argc > 1) {
        if(strcmp(argv[1],"away") == 0) {
            [skypeController sendSkypeMessage:@"set userstatus away"];
            return 0;
        } else if(strcmp(argv[1],"online") == 0) {
            [skypeController sendSkypeMessage:@"set userstatus online"];
            return 0;
        } else if(strcmp(argv[1],"offline") == 0) {
            [skypeController sendSkypeMessage:@"set userstatus offline"];
            return 0;
        } else {
            [skypeController readCommandsAsyncFromFileHandle:inputStream];
        }
    } else {
        [skypeController readCommandsAsyncFromFileHandle:inputStream];
    }
    
    [[NSRunLoop currentRunLoop] run];
	
	[skypeController release];
	[pool drain];
    return 0;
}
