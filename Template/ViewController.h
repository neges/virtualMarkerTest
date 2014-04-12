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

@interface ViewController : MetaioSDKViewController
{

    __weak IBOutlet UISwitch *logSwitch;
    
    NSString *markerPattern;
    
}

@end
