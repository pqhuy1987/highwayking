//
//  TGDrivingAppDelegate.m
//  TGDriving
//
//  Created by Charles Magahern on 10/21/10.
//  Copyright omegaHern 2010. All rights reserved.
//

#import "cocos2d.h"

#import "TGDrivingAppDelegate.h"
#import "GameConfig.h"
#import "RootViewController.h"
#import "GameScene.h"
#import "GameLayer.h"
#import "TGTitleScene.h"

BOOL _deviceSupportsGC;

@implementation TGDrivingAppDelegate
@synthesize window, viewController;
@synthesize playerIsSignedIntoGameCenter, achievements, unsubmittedScores, unsubmittedAchievements;

- (void)activateAllAchievements {
	NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:19];
	[arr addObject:[[[GKAchievement alloc] initWithIdentifier:@"vallet"] autorelease]];
	[arr addObject:[[[GKAchievement alloc] initWithIdentifier:@"like_a_boss"] autorelease]];
	[arr addObject:[[[GKAchievement alloc] initWithIdentifier:@"delivery_king"] autorelease]];
	[arr addObject:[[[GKAchievement alloc] initWithIdentifier:@"are_you_kidding"] autorelease]];
	[arr addObject:[[[GKAchievement alloc] initWithIdentifier:@"take_a_bow"] autorelease]];
	[arr addObject:[[[GKAchievement alloc] initWithIdentifier:@"oh_you_can_drive"] autorelease]];
	[arr addObject:[[[GKAchievement alloc] initWithIdentifier:@"born_to_drive"] autorelease]];
	[arr addObject:[[[GKAchievement alloc] initWithIdentifier:@"who_needs_gps"] autorelease]];
	[arr addObject:[[[GKAchievement alloc] initWithIdentifier:@"you_suck"] autorelease]];
	[arr addObject:[[[GKAchievement alloc] initWithIdentifier:@"twisted_metal"] autorelease]];
	[arr addObject:[[[GKAchievement alloc] initWithIdentifier:@"speed_demon"] autorelease]];
	[arr addObject:[[[GKAchievement alloc] initWithIdentifier:@"ha_ha_too_easy"] autorelease]];
	[arr addObject:[[[GKAchievement alloc] initWithIdentifier:@"every_second_counts"] autorelease]];
	[arr addObject:[[[GKAchievement alloc] initWithIdentifier:@"running_with_nos"] autorelease]];
	[arr addObject:[[[GKAchievement alloc] initWithIdentifier:@"make_the_deadline"] autorelease]];
	[arr addObject:[[[GKAchievement alloc] initWithIdentifier:@"long_hauler"] autorelease]];
	[arr addObject:[[[GKAchievement alloc] initWithIdentifier:@"bookworm"] autorelease]];
	[arr addObject:[[[GKAchievement alloc] initWithIdentifier:@"motorhead"] autorelease]];
	[arr addObject:[[[GKAchievement alloc] initWithIdentifier:@"the_impossible"] autorelease]];
	[arr addObject:[[[GKAchievement alloc] initWithIdentifier:@"epic"] autorelease]];
	
	for (GKAchievement *a in arr) {
		a.percentComplete = 100.0;
		[a reportAchievementWithCompletionHandler:NULL];
	}
}

- (void)resetAchievements {
    // Clear all progress saved on Game Center
    [GKAchievement resetAchievementsWithCompletionHandler:NULL];
}

- (void)loadAchievements {
    [GKAchievement loadAchievementsWithCompletionHandler:^(NSArray *_achievements, NSError *_err) {
        if (_err == nil) {
            for (GKAchievement *achv in _achievements) {
                [achievements setObject:achv forKey:achv.identifier];
            }
        }
    }];
}

- (void) applicationDidFinishLaunching:(UIApplication*)application {
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	if( ! [CCDirector setDirectorType:kCCDirectorTypeDisplayLink] )
		[CCDirector setDirectorType:kCCDirectorTypeDefault];
	
	
	CCDirector *director = [CCDirector sharedDirector];
	
	self.viewController = [[RootViewController alloc] initWithNibName:nil bundle:nil];
	self.viewController.wantsFullScreenLayout = YES;
	
	EAGLView *glView = [EAGLView viewWithFrame:[window bounds]
								   pixelFormat:kEAGLColorFormatRGBA8	// kEAGLColorFormatRGBA8
								   depthFormat:0						// GL_DEPTH_COMPONENT16_OES
							preserveBackbuffer:NO];
	
	[director setOpenGLView:glView];
	
	// To enable Hi-Res mode (iPhone4)
	//	[director setContentScaleFactor:2];
	
#if GAME_AUTOROTATION == kGameAutorotationUIViewController
	[director setDeviceOrientation:kCCDeviceOrientationPortrait];
#else
	[director setDeviceOrientation:kCCDeviceOrientationLandscapeLeft];
#endif
	
	[director setAnimationInterval:1.0/60];
	[director setDisplayFPS:NO];
	
	
	[self.viewController setView:glView];
    [window setRootViewController:viewController];
	//[window addSubview:self.viewController.view];
	[window makeKeyAndVisible];
    
#ifdef GAME_CENTER_ENABLED
    // Game Center
	NSArray *unsub = [[NSUserDefaults standardUserDefaults] arrayForKey:@"unsubmittedScores"];
	if (unsub == nil) {
		unsubmittedScores = [[NSMutableArray alloc] init];
	} else {
		unsubmittedScores = [[NSMutableArray alloc] initWithArray:unsub];
		[unsub release];
	}
    unsub = [[NSUserDefaults standardUserDefaults] arrayForKey:@"unsubmittedAchievements"];
    if (unsub == nil) {
		unsubmittedAchievements = [[NSMutableArray alloc] init];
	} else {
		unsubmittedAchievements = [[NSMutableArray alloc] initWithArray:unsub];
		[unsub release];
	}
	
    self.achievements = [[NSMutableDictionary alloc] init];
    _deviceSupportsGC = YES;
    playerIsSignedIntoGameCenter = NO;
    if ([self isGameCenterAvailable])
        [self authenticateLocalPlayer];

#endif
	
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
	[[CCDirector sharedDirector] runWithScene:[TGTitleScene node]];
}

- (void)applicationWillResignActive:(UIApplication *)application {
	[[CCDirector sharedDirector] pause];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self reportAllAchievements];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	if (![[GameLayer sharedGame] paused]) {
		[[CCDirector sharedDirector] resume];
	}
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[CCDirector sharedDirector] purgeCachedData];
}

-(void) applicationDidEnterBackground:(UIApplication*)application {
	[[CCDirector sharedDirector] stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application {
	[[CCDirector sharedDirector] startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[NSUserDefaults standardUserDefaults] synchronize];
    
	CCDirector *director = [CCDirector sharedDirector];
	[[director openGLView] removeFromSuperview];
	
	[viewController release];
	[window release];
	
	[director end];	
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

#pragma mark -


#pragma mark Game Center

- (void)authenticateLocalPlayer {
    [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:^(NSError *error) {
        if (error != nil) {
            _deviceSupportsGC = (error.code == GKErrorNotSupported);
        } else {
            playerIsSignedIntoGameCenter = YES;
			[self submitAllUnsubmittedGameCenterData];
            [self loadAchievements];
        }
    }];
}

- (void)registerForAuthenticationNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(authenticationChanged)
												 name:GKPlayerAuthenticationDidChangeNotificationName
											   object:nil];
}

- (void)authenticaticationChanged {
	if ([GKLocalPlayer localPlayer].isAuthenticated) {
		self.playerIsSignedIntoGameCenter = YES;
	} else {
		self.playerIsSignedIntoGameCenter = NO;
	}
}

- (BOOL)isGameCenterAvailable {
    Class gcClass = NSClassFromString(@"GKLocalPlayer");
    
    NSString *reqSysVer = @"4.1";
    NSString *curSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([curSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
    
#ifdef GAME_CENTER_ENABLED
    return (gcClass && osVersionSupported && _deviceSupportsGC);
#else
    return NO;
#endif
}

- (void)reportAllAchievements {
    if ([self isGameCenterAvailable]) {
        for (GKAchievement *achv in [self.achievements objectEnumerator]) {
            [achv reportAchievementWithCompletionHandler:NULL];
        }
    }
}

- (GKAchievement *)getAchievementForIdentifier:(NSString *)identifier {
    if ([self isGameCenterAvailable]) {
        GKAchievement *achievement = [achievements objectForKey:identifier];
        if (achievement == nil) {
            achievement = [[[GKAchievement alloc] initWithIdentifier:identifier] autorelease];
            [achievements setObject:achievement forKey:achievement.identifier];
        }
        return [[achievement retain] autorelease];
    }
    
    return nil;
}

- (void)addUnsubmittedGameCenterScore:(GKScore *)score {
	[self.unsubmittedScores addObject:score];
	[[NSUserDefaults standardUserDefaults] setObject:self.unsubmittedScores forKey:@"unsubmittedScores"];
}

- (void)addUnsubmittedGameCenterAchievement:(GKAchievement *)achievement {
    [self.unsubmittedAchievements addObject:achievement];
	[[NSUserDefaults standardUserDefaults] setObject:self.unsubmittedAchievements forKey:@"unsubmittedAchievements"];
}

- (void)submitAllUnsubmittedGameCenterData {
	if ([self isGameCenterAvailable] && ([self.unsubmittedScores count] != 0 || [self.unsubmittedAchievements count] != 0)) {
		for (GKScore *score in self.unsubmittedScores) {
			[score reportScoreWithCompletionHandler:NULL];
		}
		
		for (GKAchievement *achv in self.unsubmittedAchievements) {
			[achv reportAchievementWithCompletionHandler:NULL];
		}
	}
}

#pragma mark -


- (void)dealloc {
	[[CCDirector sharedDirector] release];
	[window release];
	[super dealloc];
}

@end
