//
//  CHViewController.h
//  RedlandDemo
//
//  Created by Pascal Pfiffner on 12/2/12.
//  Copyright (c) 2012 CHIP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CHViewController : UIViewController

@property (nonatomic, weak) IBOutlet UITextField *urlField;
@property (nonatomic, weak) IBOutlet UITextView *output;

- (IBAction)download:(id)sender;


@end
