//
//  GameLayer.h
//  TGDriving
//
//  Created by Charles Magahern on 10/21/10.
//  Copyright 2010 omegaHern. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "TGTruck.h"
#import "TGCommon.h"
#import "TGBackgroundLayer.h"
#import "TGLineLayer.h"
#import "TGHUDLayer.h"
#import "TGLevel.h"
#import "TGTask.h"
#import "Congratulations.h"
#import "GameOverDialog.h"
#import "TGScoringConfig.h"
#import "TGGameTypes.h"
#import "TGGameOverType.h"

#define TGGameSpeedMultiplierChangedNotification @"TGGameSpeedMultiplierChangedNotification"

@interface GameLayer : CCLayer {
	TGBackgroundLayer *background;
	TGLineLayer *rawLineLayer;
	TGLineLayer *drivingLineLayer;
	TGHUDLayer *hudLayer;
	
	TGLevel *currentLevel;
	CCLayer *lineLayer;
    
    TGGameType gameType;
	
	BOOL gameIsOver;
	BOOL paused;
	
	int speedMultiplier;
	int trucksRemaining;
	int score;
    
    BOOL debug_showAnchorPoints;
    BOOL debug_showCollisionRects;
}

@property (nonatomic, retain) TGLevel *currentLevel;
@property (nonatomic, retain) TGLineLayer *drivingLineLayer;
@property (nonatomic, retain) TGLineLayer *rawLineLayer;
@property (nonatomic, retain) TGHUDLayer *hudLayer;

@property (nonatomic, assign) TGGameType gameType;

@property (assign) BOOL gameIsOver;
@property (assign) BOOL paused;

@property (assign, setter=setSpeedMultiplier:) int speedMultiplier;
@property (readwrite) int trucksRemaining;
@property (readwrite, setter=setScore:) int score;

@property (assign) BOOL debug_showAnchorPoints;
@property (assign) BOOL debug_showCollisionRects;

+ (id)sharedGame;

- (void)setLevelClass:(Class)levelClass;

- (void)startGame __attribute__((deprecated));
- (void)startLevel:(TGLevel *)level;
- (void)startNextLevel;

- (void)gameOverWithTitle:(NSString *)title message:(NSString *)message type:(NSUInteger)type;
- (void)restartLevel;
- (void)quitToMainMenu;
- (void)truckFinished:(TGTruck*)truck;

@end
