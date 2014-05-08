//
//  ViewController.h
//  Template
//
//  Created by Mac on 30.04.13.
//  Copyright (c) 2013 itm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EAGLView.h"
#import "MetaioSDKViewController.h"

@interface ViewController : MetaioSDKViewController <UITableViewDataSource, UITableViewDelegate>
{

    __weak IBOutlet UISwitch *logSwitch;
    
    NSString *markerPattern;
    
    NSArray *markerArray;
    
    NSString *logFile;
    
}
- (IBAction)newLog:(id)sender;
-(IBAction)getCameraParameters:(id)sender;

@end
