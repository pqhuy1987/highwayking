//
//  TGHighScoresController.h
//  TGDriving
//
//  Created by Charles Magahern on 1/3/11.
//  Copyright 2011 omegaHern. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TGGameTypes.h"
#import "TGLevel.h"
#import <GameKit/GameKit.h>

@interface TGHighScoresController : NSObject {

}

+ (TGHighScoresController *)sharedHighScoresController;
- (NSArray *)highScoresForGameType:(TGGameType)type;
- (void)addHighScore:(NSUInteger)score levelName:(NSString *)level forGameType:(TGGameType)type;
- (void)clearHighScoresForGameType:(TGGameType)type;

- (void)reportScoreToGameCenter:(GKScore *)score;
- (void)reportAchievementForIdentifier:(NSString *)identifier percentComplete:(float)percent;
- (void)updateAchievementForIdentifier:(NSString *)identifier percentComplete:(float)percent;
- (void)synchronizeScoresWithGameCenter;

- (void)truckParked;
- (void)truckReachedGoal;
- (void)truckCrashed;
- (void)finishedLevel:(TGLevel *)lvl withGameOverType:(TGGameOverType)type withScore:(int)score inSeconds:(NSUInteger)secs;

@end
