//
//  TGDrivingAppDelegate.h
//  TGDriving
//
//  Created by Charles Magahern on 10/21/10.
//  Copyright omegaHern 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>

@class RootViewController;

@interface TGDrivingAppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
    
    BOOL playerIsSignedIntoGameCenter;
    NSMutableDictionary *achievements;
	NSMutableArray *unsubmittedScores;
    NSMutableArray *unsubmittedAchievements;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) RootViewController *viewController;

@property (readwrite, assign) BOOL playerIsSignedIntoGameCenter;
@property (nonatomic, retain) NSMutableDictionary *achievements;
@property (nonatomic, retain, readonly) NSMutableArray *unsubmittedScores;
@property (nonatomic, retain, readonly) NSMutableArray *unsubmittedAchievements;

- (void)authenticateLocalPlayer;
- (void)registerForAuthenticationNotification;
- (BOOL)isGameCenterAvailable;
- (void)reportAllAchievements;
- (GKAchievement *)getAchievementForIdentifier:(NSString *)identifier;
- (void)addUnsubmittedGameCenterScore:(GKScore *)score;
- (void)addUnsubmittedGameCenterAchievement:(GKAchievement *)achievement;
- (void)submitAllUnsubmittedGameCenterData;

@end
