//
//  TGDebugViewController.h
//  TGDriving
//
//  Created by Charles Magahern on 12/20/10.
//  Copyright 2010 omegaHern. All rights reserved.
//

#import <UIKit/UIKit.h>

#define DebugAnchorPointsSwitchTag 0
#define DebugCollisionRectsSwitchTag 1

@interface TGDebugViewController : UIViewController {
    IBOutlet UISwitch *anchorPointsSwitch;
    IBOutlet UISwitch *collisionRectsSwitch;
}

@property (nonatomic, retain) IBOutlet UISwitch *anchorPointsSwitch;
@property (nonatomic, retain) IBOutlet UISwitch *collisionRectsSwitch;

- (IBAction)doneButtonTapped:(id)sender;

- (IBAction)switchValueChanged:(UISwitch *)sender;
- (IBAction)simulateGameOverButtonTapped:(id)sender;
- (IBAction)simulateLevelCompleteTapped:(id)sender;
- (IBAction)startNextLevelButtonTapped:(id)sender;
- (IBAction)insertDummyCareerScoreButtonTapped:(id)sender;
- (IBAction)insertDummyEndlessScoreButtonTapped:(id)sender;
- (IBAction)resetCareerMode:(id)sender;
- (IBAction)unlockAllLevels:(id)sender;
- (IBAction)resetTutorial;
- (IBAction)showAchievementNotificationButtonTapped:(id)sender;

@end
