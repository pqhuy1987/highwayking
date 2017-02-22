//
//  TGCreditsViewController.h
//  TGDriving
//
//  Created by Charles Magahern on 1/3/11.
//  Copyright 2011 omegaHern. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TGCreditsViewController : UIViewController<UIActionSheetDelegate> {
    IBOutlet UILabel *versionLabel;
}

@property (nonatomic, retain) IBOutlet UILabel *versionLabel;


- (IBAction)dismissAction:(id)sender;

- (IBAction)objectiveCodersAction:(id)sender;
- (IBAction)omegaHernAction:(id)sender;

- (IBAction)omhrn:(id)sender;

@end
