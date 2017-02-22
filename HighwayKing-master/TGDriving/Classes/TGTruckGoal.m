//
//  TGTruckGoal.m
//  TGDriving
//
//  Created by Charles Magahern on 12/21/10.
//  Copyright 2010 omegaHern. All rights reserved.
//

#import "TGTruckGoal.h"
#import "GameLayer.h"


@implementation TGTruckGoal
@synthesize goalType, roadWidth, direction;

- (id)initWithTruckGoalType:(TGTruckGoalType)_type roadWidth:(CGFloat)_width {
    if ((self = [super init])) {
        NSString *textureImgFile;
        if (_type == TGTruckGoalTypeBlue) {
            textureImgFile = @"blue_glow.png";
        } else if (_type == TGTruckGoalTypeOrange) {
            textureImgFile = @"orange_glow.png";
        }
        
        CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage:textureImgFile];
		if (texture) {
			CGRect rect = CGRectZero;
			rect.size = texture.contentSize;
			self.texture = texture;
			self.textureRect = rect;
            self.roadWidth = _width + 10.0; // Give a little bit of extra padding.
            
            _width = _width + 10.0; 
		}
        
        self.goalType = _type;
    }
    
    return self;
}

- (CGRect)collidingRect {
    CGRect rect = [self boundingBox];
    CGRect coll;
    if (self.rotation == 90.0) {
        coll = CGRectMake(rect.origin.x, rect.origin.y + rect.size.height / 2.0 - self.roadWidth / 2, kGoalHeight, self.roadWidth);
    } else if (self.rotation == 180.0) {
        coll = CGRectMake(rect.origin.x + rect.size.width / 2.0 - self.roadWidth / 2, rect.origin.y + rect.size.height - kGoalHeight, self.roadWidth, kGoalHeight);
    } else if (self.rotation == 270.0) {
        coll = CGRectMake(rect.origin.x + rect.size.width - kGoalHeight, rect.origin.y + rect.size.height / 2.0 - self.roadWidth / 2, kGoalHeight, self.roadWidth);
    } else {
        coll = CGRectMake(rect.origin.x + rect.size.width / 2.0 - self.roadWidth / 2, rect.origin.y, self.roadWidth, kGoalHeight);
    }
    
    return coll;
}

- (CGRect)touchRect {
    CGRect rect = [self boundingBox];
    CGRect coll;
    if (self.rotation == 90.0) {
        coll = CGRectMake(rect.origin.x, rect.origin.y + rect.size.height / 2.0 - self.roadWidth / 2, kTouchHeight, self.roadWidth);
    } else if (self.rotation == 180.0) {
        coll = CGRectMake(rect.origin.x + rect.size.width / 2.0 - self.roadWidth / 2, rect.origin.y + rect.size.height - kTouchHeight, self.roadWidth, kTouchHeight);
    } else if (self.rotation == 270.0) {
        coll = CGRectMake(rect.origin.x + rect.size.width - kTouchHeight, rect.origin.y + rect.size.height / 2.0 - self.roadWidth / 2, kTouchHeight, self.roadWidth);
    } else {
        coll = CGRectMake(rect.origin.x + rect.size.width / 2.0 - self.roadWidth / 2, rect.origin.y, self.roadWidth, kTouchHeight);
    }
    
    return coll;
}

- (void)draw {
    [super draw];

    if ([[GameLayer sharedGame] debug_showCollisionRects]) {
        glColor4ub(0, 255, 0, 255);
        CGRect trect = [self collidingRect];
        CGPoint tpts[] = {
            [self convertToNodeSpace:trect.origin],
            [self convertToNodeSpace:ccp(trect.origin.x + trect.size.width, trect.origin.y)],
            [self convertToNodeSpace:ccp(trect.origin.x + trect.size.width, trect.origin.y + trect.size.height)],
            [self convertToNodeSpace:ccp(trect.origin.x, trect.origin.y + trect.size.height)]
        };
        
        for (int i = 0; i < 4; i++)
            ccDrawLine(tpts[i], tpts[(i != 3 ? i + 1 : 0)]);
    }
}

@end
