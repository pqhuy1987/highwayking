//
//  TGCareerSelect.m
//  TGDriving
//
//  Created by James Magahern on 1/2/11.
//  Copyright 2011 omegaHern. All rights reserved.
//

#import "TGMapScene.h"
#import "TGTitleScene.h"

@implementation TGMapLayer
@synthesize gameType;

-(id)init {
	if ( (self = [super init]) ) {
		mapView = [[CCSprite alloc] initWithFile:@"career_map_comingsoon.png"];
		mapView.anchorPoint = ccp(0.5, 0.5);
		mapView.position = ccp(160, 240);
		mapView.scale = 0.5;
		
		[self addChild:mapView];
		
		selectRegion = [CCSprite spriteWithFile:@"select_region_title.png"];
		selectRegion.anchorPoint = ccp(0, 0);
		selectRegion.position = ccp(0, 0);
		selectRegion.opacity = 0;
		[self addChild:selectRegion];
		[selectRegion runAction:[CCFadeIn actionWithDuration:1.5]];
		
		backButton = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithFile:@"back_map.png"]
															   selectedSprite:[CCSprite spriteWithFile:@"back_map_selected.png"] 
																	   target:self selector:@selector(backToTitleScreen:)];
		CCMenu *backMenu = [CCMenu menuWithItems:backButton, nil];
		backButton.position = ccp(36, 409);
		backMenu.position = CGPointZero;
		[self addChild:backMenu];
		
		
		levelSelect = nil;
		showingLevelSelect = NO;
		self.isTouchEnabled = YES;
		
		cityMarkers = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)backToTitleScreen:(id)sender {
	[[CCDirector sharedDirector] replaceScene:[CCTransitionFlipX transitionWithDuration:0.4 scene:[TGTitleScene node]]];
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	if (levelSelect != nil) {
		[levelSelect ccTouchesBegan:touches withEvent:event];
		return;
	}
	
	if (showingLevelSelect)
		return;
	
	UITouch *touch = [touches anyObject];
	CGPoint touchPoint = [touch locationInView:[touch view]];
	
	CGRect poptartia    = CGRectMake(129, 38, 192, 114);
	CGRect picklefornia = CGRectMake(58, 207, 262, 114);
	CGRect loafland     = CGRectMake(129, 366, 191, 114);
	
	id move;
	id scale;
	move = scale = nil;
	ccTime duration = 0.8;
	
	// Picklefornia
	if (CGRectContainsPoint(picklefornia, touchPoint)) {
		move  = [CCMoveTo actionWithDuration:duration position:ccp(100, 240)];
		scale = [CCScaleTo actionWithDuration:duration scale:0.8];
		selectedRegion = REGION_PICKLEFORNIA;
	}
	
	// Poptartia
	if (CGRectContainsPoint(poptartia, touchPoint)) {
		move = [CCMoveTo actionWithDuration:duration position:ccp(140, 60)];
		scale = [CCScaleTo actionWithDuration:duration scale:0.9];
		selectedRegion = REGION_POPTARTIA;
	}
	
	// Loafland
	if (CGRectContainsPoint(loafland, touchPoint)) {
		move = [CCMoveTo actionWithDuration:duration position:ccp(0, 480)];
		scale = [CCScaleTo actionWithDuration:duration scale:1.0];
		selectedRegion = REGION_LOAFLAND;
	}
	
	id delay = [CCDelayTime actionWithDuration:0.1];
	id callFunc = [CCCallFunc actionWithTarget:self selector:@selector(showCityMarkers)];
	
	if (move != nil && scale != nil) {
		showingLevelSelect = YES;
		[backButton setIsEnabled:NO];
		[backButton runAction:[CCFadeOut actionWithDuration:0.3]];
		
		[selectRegion runAction:[CCEaseElasticIn actionWithAction:[CCMoveTo actionWithDuration:0.6 position:ccp(0, -80)] period:1.0]];
		[mapView runAction:[CCEaseExponentialOut actionWithAction:move]];
		[mapView runAction:[CCEaseExponentialOut actionWithAction:scale]];
		[mapView runAction:[CCSequence actions:delay, callFunc, nil]];
	}
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if (levelSelect != nil) {
		[levelSelect ccTouchesEnded:touches withEvent:event];
		return;
	}
}

- (void)showLevelSelector {
	levelSelect = [TGLevelSelect levelSelectWithRegion:selectedRegion gameType:gameType];
	levelSelect.delegate = self;
	[self addChild:levelSelect];
	[levelSelect animateIn];
}

- (void)showCityMarkers {
	int completedLevels = 0;
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSDictionary *levelsPlist = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Levels" ofType:@"plist"]];
	for (NSArray *arr in [levelsPlist allValues]) {
		for (NSDictionary *lvl in arr) {
			if ([[defaults valueForKey:[NSString stringWithFormat:@"%@_unlocked", [lvl valueForKey:@"name"]]] boolValue] == YES) {
				completedLevels++;
			}
		}
	}
	
	switch (selectedRegion) {
		case REGION_LOAFLAND: {
			[cityMarkers addObject:[TGCityMarker markerWithPosition:ccp(500, 100) completed:(completedLevels >= 1)]];
			[cityMarkers addObject:[TGCityMarker markerWithPosition:ccp(600, 80) completed:(completedLevels >= 2)]];
			[cityMarkers addObject:[TGCityMarker markerWithPosition:ccp(420, 200) completed:(completedLevels >= 3)]];
			[cityMarkers addObject:[TGCityMarker markerWithPosition:ccp(600, 180) completed:(completedLevels >= 4)]];
			
			break;
		}
		default:
			break;
	}
	
	for (TGCityMarker *marker in cityMarkers) {
		[mapView addChild:marker];
	}
	
	[self performSelector:@selector(showLevelSelector) withObject:nil afterDelay:0.6];
}

- (void)setGameType:(TGGameType)_t {
    gameType = _t;
    NSString *titleFile = (_t == TGGameTypeCareer ? @"career_title.png" : @"endless_title.png");
    CCSprite *title = [CCSprite spriteWithFile:titleFile];
    title.position = ccp(81, 443);
    
    [self addChild:title];
}

- (void)goBack {
	id move = [CCMoveTo actionWithDuration:0.5 position:ccp(160, 240)];
	id scale = [CCScaleTo actionWithDuration:0.5 scale:0.5f];
	[mapView runAction:move];
	[mapView runAction:scale];
	
	for (TGCityMarker *marker in cityMarkers) {
		[marker performSelector:@selector(disappear) withObject:nil afterDelay:0.3];
	}
	
	[cityMarkers removeAllObjects];
	
	[levelSelect dismiss];
	levelSelect = nil;
	
	showingLevelSelect = NO;
	[backButton setIsEnabled:YES];
	[backButton runAction:[CCFadeIn actionWithDuration:0.3]];
	
	selectRegion.position = ccp(0,0);
	selectRegion.opacity = 0;
	[selectRegion runAction:[CCFadeIn actionWithDuration:1.5]];
}

@end



@implementation TGMapScene

-(id) init {
	if ( (self = [super init]) ) {
		layer = [TGMapLayer node];
		[self addChild:layer];
	}
	return self;
}

- (id)initWithGameType:(TGGameType)_type {
	if ( (self = [super init]) ) {
		layer = [TGMapLayer node];
		[layer setGameType:_type];
		[self addChild:layer];
	}
	return self;
}

+ (id)mapSceneWithGameType:(TGGameType)_type {
	return [[[self alloc] initWithGameType:_type] autorelease];
}

@end
