//
//  TGLevelSelect.h
//  TGDriving
//
//  Created by James Magahern on 1/2/11.
//  Copyright 2011 omegaHern. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "TGLevelSelectDelegate.h"
#import "CareerRegions.h"
#import "CCRadioMenu.h"
#import "GameScene.h"
#import "TGGameTypes.h"

#define LEVEL_OPTION_DESELECTED_COLOR ccc3(74, 74, 74)
#define LEVEL_OPTION_SELECTED_COLOR ccc3(155, 155, 155)


@interface TGLevelSelectBackButton : CCSprite {
	CCTexture2D *selectedTexture;
	CCTexture2D *normalTexture;
	
	id delegate;
}

@property (assign) id delegate;

- (void)touch;
- (void)activate;
- (void)untouch;

@end



@interface TGLevelOption : CCMenuItem {
	CCSprite *levelIndicator;
	CCColorLayer *bg;
	
	CCLabelTTF *label;
	
	NSString *levelName;
	Class levelClass;
	
	CCTexture2D *locked;
	CCTexture2D *unlocked;
	CCTexture2D *completed;
	
	BOOL levelLocked;
	BOOL levelCompleted;
}

@property (nonatomic, retain) NSString *levelName;
@property (assign) Class levelClass;
@property (assign) BOOL levelLocked;
@property (assign) BOOL levelCompleted;


@end



@interface TGLevelSelect : CCNode {
	CCSprite *background;
	TGLevelSelectBackButton *backButton;
	CCMenuItem *goButton;
	
	id<TGLevelSelectDelegate> delegate;
	
	CareerRegion_t selectedRegion;
    TGGameType gameType;
	
	CCRadioMenu *levelMenu;
	
	NSDictionary *regions;
}
@property (assign) id<TGLevelSelectDelegate> delegate;
@property (assign) CareerRegion_t selectedRegion;
@property (assign) TGGameType gameType;

- (id)initWithRegion:(CareerRegion_t)region gameType:(TGGameType)type;
+ (id)levelSelectWithRegion:(CareerRegion_t)region gameType:(TGGameType)type;
+ (NSString *)stringFromCareerRegion:(CareerRegion_t)region;

- (void)animateIn;

- (void)dismiss;

- (void)goBack;

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;

@end
