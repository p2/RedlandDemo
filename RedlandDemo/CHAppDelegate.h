//
//  CHAppDelegate.h
//  RedlandDemo
//
//  Created by Pascal Pfiffner on 12/2/12.
//  Copyright (c) 2012 CHIP. All rights reserved.
//

#import <UIKit/UIKit.h>


/**
 *  Simple App Delegate
 */
@class CHViewController;

@interface CHAppDelegate : UIResponder <UIApplicationDelegate>

/** The default URL to fetch RDF+XML from. */
@property (strong, nonatomic) NSURL *defaultURL;

/** If set the example will use local SQLite storage. Don't forget to link sqlite3.dylib if YES (as is the default). */
@property (copy, nonatomic) NSString *localSQLiteStoragePath;

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) CHViewController *viewController;

@end
