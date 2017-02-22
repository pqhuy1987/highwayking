//
//  TGLevelSelect.m
//  TGDriving
//
//  Created by James Magahern on 1/2/11.
//  Copyright 2011 omegaHern. All rights reserved.
//

#import "TGLevelSelect.h"
#import "CCMenu+CorrectPadding.h"
#import "SimpleAudioEngine.h"

@implementation TGLevelSelectBackButton
@synthesize delegate;

- (id)init {
	if ( (self = [super init]) ) {
		normalTexture   = [[CCTextureCache sharedTextureCache] addImage:@"back_button.png"];
		selectedTexture = [[CCTextureCache sharedTextureCache] addImage:@"back_button_selected.png"];
        
        CGRect rect = CGRectZero;
        rect.size = normalTexture.contentSize;
        
        [self setTexture:normalTexture];
        [self setTextureRect:rect rotated:NO];
	}
	return self;
}

- (void)touch {
	[self setTexture:selectedTexture];
}

- (void)activate {
	[((TGLevelSelect*)delegate) goBack];
	[self untouch];
}

- (void)untouch {
	[self setTexture:normalTexture];
}

@end

@implementation TGLevelOption
@synthesize levelClass, levelName, levelLocked, levelCompleted;

-(id) initWithTarget:(id) rec selector:(SEL) cb string:(NSString*)string class:(Class)_levelClass {
	if( (self = [super initWithTarget:rec selector:cb]) ) {
		bg = [CCColorLayer layerWithColor:ccc4(0, 0, 0, 142) width:257 height:50];
		[bg setColor:LEVEL_OPTION_DESELECTED_COLOR];
		bg.position = ccp(0,0);
		[self addChild:bg];
		
		self.levelName = string;
		self.levelClass = _levelClass;
		
		locked    = [[CCTextureCache sharedTextureCache] addImage:@"levelLocked.png"];
		unlocked  = [[CCTextureCache sharedTextureCache] addImage:@"citymarker.png"];
		completed = [[CCTextureCache sharedTextureCache] addImage:@"citymarker_completed.png"];
		
		levelIndicator = [CCSprite spriteWithFile:@"citymarker.png"];
		levelIndicator.position = ccp(5, 25);
		levelIndicator.anchorPoint = ccp(0, 0.5);
		[levelIndicator setColor:ccc3(155, 155, 155)];
		[self addChild:levelIndicator];
		
		self.levelLocked = NO;
		
		label = [CCLabelTTF labelWithString:string fontName:@"Helvetica-Bold" fontSize:18];
		label.position = ccp(55, 25);
		label.anchorPoint = ccp(0, 0.5);
		[self addChild:label];
	}
	
	return self;
}

- (void)setLevelCompleted:(BOOL)_completed {
	levelCompleted = YES;
	
	if (_completed) {
		[levelIndicator setTexture:completed];
	} else {
		[levelIndicator setTexture:unlocked];
	}
}

- (void)setLevelLocked:(BOOL)b {
	levelLocked = b;
	
	if (b) {
		[levelIndicator setTexture:locked];
		CGSize size = locked.contentSize;
		CGRect rect = CGRectMake(0, 0, size.width, size.height );
		[levelIndicator setTextureRect:rect];
	} else {
		[levelIndicator setTexture:unlocked];
		CGSize size = unlocked.contentSize;
		CGRect rect = CGRectMake(0, 0, size.width, size.height );
		[levelIndicator setTextureRect:rect];
	}
}

+ (id) optionWithTarget:(id)tar selector:(SEL)cb string:(NSString*)string class:(Class)_levelClass {
	return [[[self alloc] initWithTarget:tar selector:cb string:string class:_levelClass] autorelease];
}

-(void) selected {
	ccColor3B selectedColor = LEVEL_OPTION_SELECTED_COLOR;
	[bg runAction:[CCTintTo actionWithDuration:0.2 red:selectedColor.r green:selectedColor.g blue:selectedColor.b]];
	[levelIndicator runAction:[CCTintTo actionWithDuration:0.2 red:255 green:255 blue:255]];
}

-(void)unselected {
	ccColor3B deselectedColor = LEVEL_OPTION_DESELECTED_COLOR;
	[bg runAction:[CCTintTo actionWithDuration:0.2 red:deselectedColor.r green:deselectedColor.g blue:deselectedColor.b]];
	[levelIndicator runAction:[CCTintTo actionWithDuration:0.2 red:155 green:155 blue:155]];
}

- (CGRect) rect {
	return [bg boundingBox];
}

@end



@implementation TGLevelSelect
@synthesize delegate, selectedRegion, gameType;

- (id)init {
	if ( (self = [super init]) ) {
		background = [CCSprite spriteWithFile:@"select_level_bg.png"];
		backButton = [TGLevelSelectBackButton node];
		backButton.position = ccp(-96, 156);
		backButton.delegate = self;
		
		goButton = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithFile:@"goButton.png"]
										   selectedSprite:[CCSprite spriteWithFile:@"goButton_selected.png"]
										   disabledSprite:[CCSprite spriteWithFile:@"goButton_disabled.png"]
												   target:self selector:@selector(loadLevel:)];
		
		[goButton setIsEnabled:NO];
		
		CCMenu *goMenu = [CCMenu menuWithItems:goButton, nil];
		goMenu.position = ccp(0, -145);
		
		[self addChild:background];
		[self addChild:backButton];
		[self addChild:goMenu];
		
		self.position = ccp(1024, 240);
	}
	
	return self;
}

- (id)initWithRegion:(CareerRegion_t)region gameType:(TGGameType)type {
	self = [self init];
	self.selectedRegion = region;
    self.gameType = type;
	
	// Load levels from file
	regions = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Levels" ofType:@"plist"]];
	
	NSString *regionString = [TGLevelSelect stringFromCareerRegion:region];
	
	NSArray *levels = [regions objectForKey:regionString];
	NSMutableArray *regionLevels = [NSMutableArray array];

	int completedLevels = 0;
	for (NSDictionary *level in levels) {
		TGLevelOption *option = [TGLevelOption optionWithTarget:self selector:@selector(levelSelected:) string:[level objectForKey:@"name"] class:NSClassFromString([level objectForKey:@"class"])];
		
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		if ([[level objectForKey:@"locked"] boolValue] == YES && [defaults boolForKey:[NSString stringWithFormat:@"%@_unlocked", [level objectForKey:@"name"]]] != YES) {
			[option setLevelLocked:YES];
		}
		
		if ([defaults boolForKey:[NSString stringWithFormat:@"%@_unlocked", [level objectForKey:@"name"]]] == YES) {
			[option setLevelCompleted:YES];
			completedLevels++;
		}
		
		if ([[level objectForKey:@"hidden"] boolValue] != YES) {
			[regionLevels addObject:option];
		}
	}
	
	// Unlock next level if career mode
	if (type == TGGameTypeCareer && completedLevels > 0) {
		for (TGLevelOption *option in regionLevels) {
			if (option.levelLocked == YES) {
				[option setLevelLocked:NO];
				
				break;
			}
		}
	}
	
	levelMenu = [[[CCRadioMenu alloc] initWithItemsArray:regionLevels] autorelease];
	[levelMenu alignItemsVerticallyWithPadding:51]; 
	levelMenu.position = ccp(-128, 84);
	[self addChild:levelMenu];
	
	
	if ([regionLevels count] == 0) {
		CCSprite *comingSoon = [CCSprite spriteWithFile:@"comingsoon_levels.png"];
		comingSoon.position = ccp(0,20);
		[self addChild:comingSoon];
	}
	
	return self;
}

- (void)levelSelected:(id)sender {
	if (![((TGLevelOption*)sender) levelLocked]) {
		[goButton setIsEnabled:YES];
	} else {
		[goButton setIsEnabled:NO];
	}

}

- (void)loadLevel:(id)sender {
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    
	TGLevelOption *selectedLevel = (TGLevelOption*)[levelMenu selectedItem];
	GameScene *gameScene = [GameScene node];
    [[GameLayer sharedGame] setGameType:gameType];
    [[GameLayer sharedGame] setLevelClass:[selectedLevel levelClass]];
	[[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInR transitionWithDuration:0.3 scene:gameScene]];
}

+ (id)levelSelectWithRegion:(CareerRegion_t)region gameType:(TGGameType)type {
	return [[[self alloc] initWithRegion:region gameType:type] autorelease];
}

+ (NSString*)stringFromCareerRegion:(CareerRegion_t)region {
	switch (region) {
		case REGION_LOAFLAND:
			return @"Loafland";
			break;
		case REGION_POPTARTIA:
			return @"Poptartia";
			break;
		case REGION_PICKLEFORNIA:
			return @"Picklefornia";
			break;
		default:
			break;
	}
	
	return nil;
}

- (void)animateIn {
	id move = [CCMoveTo actionWithDuration:0.6 position:ccp(160, 240)];
	[self runAction:[CCEaseElasticOut actionWithAction:move period:1.2]];
}

- (void)dismiss {
	id move = [CCMoveTo actionWithDuration:0.6 position:ccp(1024, 240)];
	id remove = [CCCallFunc actionWithTarget:self selector:@selector(removeSelf)];
	[self runAction:[CCSequence actions:[CCEaseElasticIn actionWithAction:move period:1.2], remove, nil]];
}

- (void)removeSelf {
	[self removeFromParentAndCleanup:YES];
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	CGPoint touchPoint = [self convertTouchToNodeSpace:touch];
	
	if (CGRectContainsPoint([backButton boundingBox], touchPoint)) {
		[backButton touch];
	}
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	CGPoint touchPoint = [self convertTouchToNodeSpace:touch];
	
	if (CGRectContainsPoint([backButton boundingBox], touchPoint)) {
		[backButton activate];
	} else {
		[backButton untouch];
	}

}

- (void)goBack {
	[delegate goBack];
}

@end
