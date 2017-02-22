//
//  TGAchievementNotification.m
//  HighwayKing
//
//  Created by Charles Magahern on 1/20/11.
//  Copyright 2011 omegaHern LLC. All rights reserved.
//

#import "TGAchievementNotification.h"

static NSString *backgroundImage = @"achievement-bg.png";

@implementation TGAchievementNotification
@synthesize title, message, iconFilePath;

- (id)init {
	if ( (self = [super init]) ) {
		self.title = @"Achievement Unlocked!";
		self.message = @"You have unlocked an achievement.";
		self.iconFilePath = @"achievement_icon_temp.png";
		
		CCTexture2D *txt = [[CCTextureCache sharedTextureCache] addImage:backgroundImage];
		if (txt) {
			CGRect rect = CGRectZero;
			rect.size = txt.contentSize;
			self.texture = txt;
			self.textureRect = rect;
		}
	}
	return self;
}

- (id)initWithAchievementTitle:(NSString *)_title message:(NSString *)_message iconFile:(NSString *)_path {
	TGAchievementNotification *ret = [self init];
	ret.title = _title;
	ret.message = _message;
	ret.iconFilePath = _path;
	
	return ret;
}

- (void)onEnter {
	[super onEnter];
	
	CCSprite *iconSprt = [[CCSprite alloc] initWithFile:self.iconFilePath];
    if (iconSprt == nil)
        iconSprt = [[CCSprite alloc] initWithFile:@"achievement_icon_generic.png"];
	iconSprt.anchorPoint = ccp(0.0, 0.0);
	iconSprt.position = ccp(13.0, 13.0);
	[self addChild:iconSprt];
	[iconSprt release];
	
	CCLabelTTF *titleLbl = [[CCLabelTTF alloc] initWithString:self.title fontName:@"Helvetica-Bold" fontSize:12];
	titleLbl.anchorPoint = ccp(0, 0.5);
	titleLbl.position = ccp(45.0, 35.0);
	[self addChild:titleLbl];
	[titleLbl release];
	
	CCLabelTTF *messageLbl = [[CCLabelTTF alloc] initWithString:self.message fontName:@"Helvetica" fontSize:12];
	messageLbl.anchorPoint = ccp(0, 0.5);
	messageLbl.position = ccp(45.0, 20.0);
	[self addChild:messageLbl];
	[messageLbl release];
}

- (void)setOpacity:(GLubyte)o {
	[super setOpacity:o];
	
	for (CCNode<CCRGBAProtocol> *n in [self children]) {
		[n setOpacity:o];
	}
}

- (void)dealloc {
	[title release];
	[message release];
	[iconFilePath release];
	
	[super dealloc];
}

@end
