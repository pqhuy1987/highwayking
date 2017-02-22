//
//  TGHUDLayer.h
//  TGDriving
//
//  Created by James Magahern on 12/1/10.
//  Copyright 2010 omegaHern. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#import "PauseDialog.h"

@interface TGHUDTrucksRemaining : CCSprite {
	int trucksRemaining;
	CCLabelTTF *numberLabel;
}

@property (readwrite) int trucksRemaining;

@end

@interface TGHUDScoreBox : CCSprite {
	CCLabelTTF *scoreLabel;
}

@end


@interface TGHUDLayer : CCLayer<PauseDialogDelegate> {
	CCSprite *fastForward;
    CCSprite *pause;
	TGHUDTrucksRemaining *trucksRemaining;
	TGHUDScoreBox *scoreBox;
    
    PauseDialog *pauseDialog;
    
	BOOL fastForwarding;
}

- (void)setTrucksRemaining:(int) remain;
- (void)updateScore;
- (void)setFastForwarding:(BOOL)ff;
- (void)showAchievementNotificationWithTitle:(NSString *)title message:(NSString *)message iconFile:(NSString *)path;

@end
