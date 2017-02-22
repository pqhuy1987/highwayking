//
//  TGCareerSelect.h
//  TGDriving
//
//  Created by James Magahern on 1/2/11.
//  Copyright 2011 omegaHern. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "TGBackgroundLayer.h"
#import "TGCityMarker.h"
#import "TGLevelSelect.h"
#import "TGLevelSelectDelegate.h"
#import "CareerRegions.h"
#import "TGGameTypes.h"

@interface TGMapLayer : CCLayer<TGLevelSelectDelegate> {
	CCSprite *mapView;
	
	CareerRegion_t selectedRegion;
	
	BOOL showingLevelSelect;
	TGLevelSelect *levelSelect;
	
	CCSprite *selectRegion;
	
	NSMutableArray *cityMarkers;
	
	CCMenuItemSprite *backButton;
	
	TGGameType gameType;
}

@property (assign) TGGameType gameType;


@end


@interface TGMapScene : CCScene {
	TGMapLayer *layer;
}

- (id)initWithGameType:(TGGameType)_type;
+ (id)mapSceneWithGameType:(TGGameType)_type;

@end
