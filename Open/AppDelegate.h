//
//  AppDelegate.h
//  Open
//
//  Created by David Holdeman on 10/4/12.
//  Copyright (c) 2012 ChuckWagon Comuputing. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    
    IBOutlet NSMenu *openMenu;
    NSStatusItem *statusItem;
    IBOutlet NSWindow *editWindow;
}

@property (assign) IBOutlet NSWindow *window;

@end
