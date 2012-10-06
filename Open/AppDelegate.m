//
//  AppDelegate.m
//  Open
//
//  Created by David Holdeman on 10/4/12.
//  Copyright (c) 2012 ChuckWagon Computing. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate


@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [NSApp activateIgnoringOtherApps:YES];
}

-(void)awakeFromNib{
    statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
    [statusItem setMenu:openMenu];
    [statusItem setTitle:@"O"];
    [statusItem setHighlightMode:YES];
}

@end
