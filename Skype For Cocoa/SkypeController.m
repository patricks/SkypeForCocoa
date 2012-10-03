//
//  SkypeController.m
//  SkypeCMD
//
//  Created by Sushant Verma on 29/01/11.
//  Copyright 2011 Sushant Verma. All rights reserved.
//

#import "SkypeController.h"
#define SKYPE_EVENT @"SKSkypeAPINotification"
#define SKYPE_RESPONSE @"SKYPE_API_NOTIFICATION_STRING"

#define SKYPE_BUNDLE @"com.skype.skype"

#define SCRIPT_NAME @"Skype For Cocoa"

@interface SkypeController()
- (void) recievedSkypeResponse:(NSNotification *)notification;
- (void) sendSkypeMessages:(NSFileHandle *)input;
@end

@implementation SkypeController

- (id) init
{
	self = [super init];
	if (self != nil) {
		skype = [SBApplication applicationWithBundleIdentifier:SKYPE_BUNDLE];

		NSDistributedNotificationCenter *notifications = [NSDistributedNotificationCenter defaultCenter];

		[notifications addObserver:self
						  selector:@selector(recievedSkypeResponse:)
							  name:SKYPE_EVENT
							object:nil];
	}
	return self;
}

- (void) readCommandsAsyncFromFileHandle:(NSFileHandle *)fileHandle
{    
	[NSThread detachNewThreadSelector:@selector(sendSkypeMessages:)
							 toTarget:self
						   withObject:fileHandle];
    NSArray* runningApplications = [[NSWorkspace sharedWorkspace] runningApplications];
    bool skypeRunning = false;
    for (NSRunningApplication *app in runningApplications)
    {
        if ([app.bundleIdentifier isEqualToString:SKYPE_BUNDLE])
        {
            skypeRunning = true;
            break;
        }
    }
    
    if (skypeRunning)
    {
        [self skypeReady];
    }
    else
    {
        NSNotificationCenter* center = [[NSWorkspace sharedWorkspace] notificationCenter];
        [center addObserver:self
                   selector:@selector(skypeLaunched:)
                       name:NSWorkspaceDidLaunchApplicationNotification
                     object:Nil];  
    }
}

- (void) skypeReady
{
    fflush(stdin);
    
    NSNotificationCenter* center = [[NSWorkspace sharedWorkspace] notificationCenter];
    [center addObserver:self
               selector:@selector(skypeTerminated:)
                   name:NSWorkspaceDidTerminateApplicationNotification
                 object:Nil];
    
    printf("Skype Ready!\n");
    fflush(stdout);
}

- (void)skypeLaunched:(NSNotification *)notification
{
    NSString *appBundle = [[notification userInfo] valueForKey:@"NSApplicationBundleIdentifier"];
    if ([appBundle isEqualToString:SKYPE_BUNDLE])
    {
        NSNotificationCenter* center = [[NSWorkspace sharedWorkspace] notificationCenter];
        [center removeObserver:self];
        [self skypeReady];
    }
}

- (void)skypeTerminated:(NSNotification *)notification
{
    NSString *appBundle = [[notification userInfo] valueForKey:@"NSApplicationBundleIdentifier"];
    if ([appBundle isEqualToString:@"com.skype.skype"])
    {
        printf("Skype closed, exiting skype API too.\n");
        [[NSApplication sharedApplication]terminate:self];
    }
}

- (void) recievedSkypeResponse:(NSNotification *)notification
{
	NSDictionary *userinfo = [notification userInfo];
	NSString *responseMessage = [userinfo valueForKey:SKYPE_RESPONSE];
	printf("%s\n",[responseMessage UTF8String]);
    fflush(stdout);
}

- (void) sendSkypeMessages:(NSFileHandle *)input
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
	NSData *data = [input availableData];
	while (data) {
		NSString *command = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		[skype sendCommand:command
				scriptName:SCRIPT_NAME];
		data = [input availableData];
	}
	[pool drain];
}

- (void) sendSkypeMessage:(NSString *)input
{
    [skype sendCommand:input scriptName:SCRIPT_NAME];
}

- (void) dealloc
{
	NSDistributedNotificationCenter *notifications = [NSDistributedNotificationCenter defaultCenter];
	
	[notifications removeObserver:self
							 name:SKYPE_EVENT
						   object:nil];
	[skype release];
	[super dealloc];
}

@end
