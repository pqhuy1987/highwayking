//
//  TGHighScoresController.m
//  TGDriving
//
//  Created by Charles Magahern on 1/3/11.
//  Copyright 2011 omegaHern. All rights reserved.
//

#import "TGHighScoresController.h"
#import "TGDrivingAppDelegate.h"
#import "GameLayer.h"
#import "Level_1.h"
#import "Level_2.h"
#import "Level_3.h"
#import "Level_4.h"

static TGHighScoresController *_sharedInstance = nil;

NSMutableArray *_highScoresCareer;
NSMutableArray *_highScoresEndless;

NSUInteger _trucksParked;
NSUInteger _trucksReachedGoal;
NSUInteger _trucksCrashed;
NSUInteger _secondsPlayed;
NSUInteger _gamesPlayed;

TGDrivingAppDelegate *_appDelegate;

@implementation TGHighScoresController

+ (TGHighScoresController *)sharedHighScoresController {
    @synchronized(self) {
        if (_sharedInstance == nil) {
            _sharedInstance = [[TGHighScoresController alloc] init];
        }
    }
    
    return _sharedInstance;
}

- (id)init {
    if ((self = [super init])) {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

        _highScoresCareer = _highScoresEndless = nil;
		_trucksParked = [defaults integerForKey:@"trucksParked"];
		_trucksReachedGoal = [defaults integerForKey:@"trucksReachedGoal"];
		_trucksCrashed = [defaults integerForKey:@"trucksCrashed"];
        _secondsPlayed = [defaults integerForKey:@"secondsPlayed"];
        _gamesPlayed = [defaults integerForKey:@"gamesPlayed"];
		_appDelegate = (TGDrivingAppDelegate *) [[UIApplication sharedApplication] delegate];
    }
    return self;
}

- (void)initializeArrays {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	if (_highScoresCareer == nil) {
		_highScoresCareer = [[NSMutableArray alloc] initWithArray:[defaults objectForKey:@"highScoresCareer"]];
		[defaults setObject:_highScoresCareer forKey:@"highScoresCareer"];
		[defaults synchronize];
	}
	
	if (_highScoresEndless == nil) {
		_highScoresEndless = [[NSMutableArray alloc] initWithArray:[defaults objectForKey:@"highScoresEndless"]];
		[defaults setObject:_highScoresEndless forKey:@"highScoresEndless"];
		[defaults synchronize]; 
	}
}

#pragma mark -


#pragma mark GameCenter

- (void)reportScoreToGameCenter:(GKScore *)score {
	if ([_appDelegate isGameCenterAvailable]) {
		[score reportScoreWithCompletionHandler:^(NSError *err) {
			if (err != nil) {
				[_appDelegate addUnsubmittedGameCenterScore:score];
			}
		}];
	}
}

- (void)reportAchievementForIdentifier:(NSString *)identifier percentComplete:(float)percent {
    if ([_appDelegate isGameCenterAvailable]) {
        GKAchievement *achievement = [[[GKAchievement alloc] initWithIdentifier:identifier] autorelease];
        if (achievement) {
            achievement.percentComplete = percent;
            [achievement reportAchievementWithCompletionHandler:^(NSError *error) {
                if (error != nil) {
                    [_appDelegate addUnsubmittedGameCenterAchievement:achievement];
                }
            }];
        }
        
        if (percent == 100.0) {
            NSDictionary *achvdict = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Achievements" ofType:@"plist"]];
            NSDictionary *achv = [achvdict objectForKey:identifier];
            if (achv != nil) {
                GameLayer *gm = [GameLayer sharedGame];
                [gm.hudLayer showAchievementNotificationWithTitle:@"Achievement Unlocked!" message:[achv objectForKey:@"title"] iconFile:[achv objectForKey:@"icon"]];
            }
        }
    }
}


- (void)updateAchievementForIdentifier:(NSString *)identifier percentComplete:(float)percent {
    if ([_appDelegate isGameCenterAvailable]) {
        GKAchievement *achv = [_appDelegate getAchievementForIdentifier:identifier];
        NSDictionary *achvdict = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Achievements" ofType:@"plist"]];
        NSDictionary *achvinfo = [achvdict objectForKey:identifier];
        if (achv.percentComplete < 100.0) {
            [achv setPercentComplete:percent];
            if (percent >= 100.0) {
                GameLayer *gm = [GameLayer sharedGame];
                [gm.hudLayer showAchievementNotificationWithTitle:@"Achievement Unlocked!" message:[achvinfo objectForKey:@"title"] iconFile:[achvinfo objectForKey:@"icon"]];
            }
        }
    }
}

- (void)synchronizeScoresWithGameCenter {
    if ([_appDelegate isGameCenterAvailable]) {
        GKScore *score;
        
        score = [[[GKScore alloc] initWithCategory:@"trucks_parked"] autorelease];
        score.value = _trucksParked;
        [self reportScoreToGameCenter:score];
        
        score = [[[GKScore alloc] initWithCategory:@"trucks_completed"] autorelease];
        score.value = _trucksReachedGoal;
        [self reportScoreToGameCenter:score];
    }
}

- (NSArray *)highScoresForGameType:(TGGameType)type {
    NSArray *result;
    
	[self initializeArrays];
	
    if (type == TGGameTypeCareer) {
        result = _highScoresCareer;
    } else if (type == TGGameTypeEndless) {
        result = _highScoresEndless;
    }
    
    NSSortDescriptor *sort = [[[NSSortDescriptor alloc] initWithKey:@"score" ascending:NO selector:@selector(compare:)] autorelease];
    return [result sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
}

#pragma mark -


#pragma mark High Scores

- (void)addHighScore:(NSUInteger)score levelName:(NSString *)level forGameType:(TGGameType)type {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *scoreObj = [NSNumber numberWithInteger:score];
    NSDictionary *listObj = [NSDictionary dictionaryWithObjectsAndKeys:scoreObj, @"score", level, @"level", nil];
	
	[self initializeArrays];
	
    if (type == TGGameTypeCareer) {
        if (![_highScoresCareer containsObject:listObj]) {
            if ([_highScoresCareer count] >= 10) 
                [_highScoresCareer removeLastObject];
            [_highScoresCareer addObject:listObj];
            [defaults setObject:_highScoresCareer forKey:@"highScoresCareer"];
        }
    } else if (type == TGGameTypeEndless) {
        if (![_highScoresEndless containsObject:listObj]) {
            if ([_highScoresEndless count] >= 10) 
                [_highScoresEndless removeLastObject];
            [_highScoresEndless addObject:listObj];
            [defaults setObject:_highScoresEndless forKey:@"highScoresEndless"];
        }
    }
}

- (void)clearHighScoresForGameType:(TGGameType)type {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (type == TGGameTypeCareer) {
        [_highScoresCareer removeAllObjects];
        [defaults setObject:_highScoresCareer forKey:@"highScoresCareer"];
    } else if (type == TGGameTypeEndless) {
        [_highScoresEndless removeAllObjects];
        [defaults setObject:_highScoresEndless forKey:@"highScoresEndless"];
    }
}

#pragma mark -


#pragma mark Progress Management

- (void)truckParked {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setInteger:++_trucksParked forKey:@"trucksParked"];
    [self updateAchievementForIdentifier:@"vallet" percentComplete:((float)_trucksParked / 20) * 100];
    [self updateAchievementForIdentifier:@"like_a_boss" percentComplete:((float)_trucksParked / 200) * 100];
    [self updateAchievementForIdentifier:@"delivery_king" percentComplete:((float)_trucksParked / 1000) * 100];
    [self updateAchievementForIdentifier:@"are_you_kidding" percentComplete:((float)_trucksParked / 2000) * 100];
}

- (void)truckReachedGoal {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setInteger:++_trucksReachedGoal forKey:@"trucksReachedGoal"];
    [self updateAchievementForIdentifier:@"take_a_bow" percentComplete:((float)_trucksReachedGoal / 10) * 100];
    [self updateAchievementForIdentifier:@"oh_you_can_drive" percentComplete:((float)_trucksReachedGoal / 100) * 100];
    [self updateAchievementForIdentifier:@"born_to_drive" percentComplete:((float)_trucksReachedGoal / 500) * 100];
    [self updateAchievementForIdentifier:@"who_needs_gps" percentComplete:((float)_trucksReachedGoal / 1000) * 100];
    
}

- (void)truckCrashed {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setInteger:++_trucksCrashed forKey:@"trucksCrashed"];
    [self updateAchievementForIdentifier:@"twisted_metal" percentComplete:((float)_trucksCrashed / 50) * 100];
}

- (void)finishedLevel:(TGLevel *)lvl withGameOverType:(TGGameOverType)type withScore:(int)score inSeconds:(NSUInteger)secs {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setInteger:++_gamesPlayed forKey:@"gamesPlayed"];
    [self updateAchievementForIdentifier:@"epic" percentComplete:(float)_gamesPlayed];
    [defaults setInteger:(_secondsPlayed += secs) forKey:@"secondsPlayed"];
    [self updateAchievementForIdentifier:@"long_hauler" percentComplete:((float)_secondsPlayed / 36000) * 100];
    
    if (type == TGGameOverLevelComplete || type == TGGameOverGameComplete || type == TGGameOverRegionComplete || [[GameLayer sharedGame] gameType] == TGGameTypeEndless) {
        BOOL isLoafland = YES;
        isLoafland |= [lvl isKindOfClass:[Level_1 class]];
        isLoafland |= [lvl isKindOfClass:[Level_2 class]];
        isLoafland |= [lvl isKindOfClass:[Level_3 class]];
        isLoafland |= [lvl isKindOfClass:[Level_4 class]];
        if (isLoafland) {
            GKScore *gscore = [[[GKScore alloc] initWithCategory:@"loafland_highscores"] autorelease];
            gscore.value = score;
            [self reportScoreToGameCenter:gscore];
        }
    }
}

#pragma mark -


- (void)release { /* Do Nothing */ }

@end
