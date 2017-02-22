//
//  HighScoresViewController.h
//  Chain2
//
//  Created by Charles Magahern on 10/1/10.
//  Copyright 2010 omegaHern. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TGHighScoresViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate> {
	IBOutlet UIView		 *noScoresView;
	IBOutlet UITableView *scoresTableView;
    IBOutlet UISegmentedControl *gameTypeSwitcher;
}

@property (nonatomic, retain) UIView *noScoresView;
@property (nonatomic, retain) UITableView *scoresTableView;
@property (nonatomic, retain) UISegmentedControl *gameTypeSwitcher;

- (IBAction)doneButtonTapped:(id)sender;
- (IBAction)clearButtonTapped:(id)sender;
- (IBAction)gameModeSwitched:(id)sender;

@end
