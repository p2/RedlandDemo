//
//  CHAppDelegate.m
//  RedlandDemo
//
//  Created by Pascal Pfiffner on 12/2/12.
//  Copyright (c) 2012 CHIP. All rights reserved.
//

#import "CHAppDelegate.h"
#import "CHViewController.h"


@implementation CHAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// set our options
	self.defaultURL = [NSURL URLWithString:@"https://raw.github.com/p2/RedlandDemo/master/RedlandDemo/vcard.xml"];
	self.localSQLiteStoragePath = [[self documentsDirectory] stringByAppendingPathComponent:@"database.sqlite"];
	
	// setup the UI
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	self.viewController = [[CHViewController alloc] initWithNibName:@"CHViewController" bundle:nil];
	self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
	
    return YES;
}


- (NSString *)documentsDirectory
{
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
}


@end
