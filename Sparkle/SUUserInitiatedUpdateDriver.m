//
//  SUUserInitiatedUpdateDriver.m
//  Sparkle
//
//  Created by Andy Matuschak on 5/30/08.
//  Copyright 2008 Andy Matuschak. All rights reserved.
//

#import "SUUserInitiatedUpdateDriver.h"
#import "SUUpdater.h"
#import "SUHost.h"

@interface SUUserInitiatedUpdateDriver ()

@property (assign, getter=isCanceled) BOOL canceled;

@end

@implementation SUUserInitiatedUpdateDriver

@synthesize canceled;

- (void)closeCheckingWindow
{
    [self.updater.userUpdaterDriver dismissUserInitiatedUpdateCheck];
}

- (void)cancelCheckForUpdates:(id)__unused sender
{
    [self closeCheckingWindow];
    self.canceled = YES;
}

- (void)checkForUpdatesAtURL:(NSURL *)URL host:(SUHost *)aHost
{
    [self.updater.userUpdaterDriver showUserInitiatedUpdateCheckWithCancelCallback:^{
        [self cancelCheckForUpdates:nil];
    }];
    
    [super checkForUpdatesAtURL:URL host:aHost];

#warning Figure out how to deal with this scenario
    // For background applications, obtain focus.
    // Useful if the update check is requested from another app like System Preferences.
	if ([aHost isBackgroundApplication])
	{
        [NSApp activateIgnoringOtherApps:YES];
    }
}

- (void)appcastDidFinishLoading:(SUAppcast *)ac
{
	if (self.isCanceled)
	{
        [self abortUpdate];
        return;
    }
    [self closeCheckingWindow];
    [super appcastDidFinishLoading:ac];
}

- (void)abortUpdateWithError:(NSError *)error
{
    [self closeCheckingWindow];
    [super abortUpdateWithError:error];
}

- (void)abortUpdate
{
    [self closeCheckingWindow];
    [super abortUpdate];
}

- (BOOL)itemContainsValidUpdate:(SUAppcastItem *)ui
{
    // We don't check to see if this update's been skipped, because the user explicitly *asked* if he had the latest version.
    return [self hostSupportsItem:ui] && [self isItemNewer:ui];
}

@end
