//
//  TGTitleScreen.h
//  TGDriving
//
//  Created by James Magahern on 12/1/10.
//  Copyright 2010 omegaHern. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import <GameKit/GameKit.h>
#import "TGBackgroundLayer.h"
#import "TGMapScene.h"

@interface TGTitleLayer : CCLayer<UIActionSheetDelegate, GKLeaderboardViewControllerDelegate, GKAchievementViewControllerDelegate> {
	TGBackgroundLayer *background;
}

- (void)startBackgroundMusic;
- (void)stopBackgroundMusic;
- (void)showLeaderboard;
- (void)showAchievements;

@end


@interface TGTitleScene : CCScene {
	TGTitleLayer *titleLayer;
}

@end
