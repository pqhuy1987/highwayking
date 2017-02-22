//
//  TGAchievementNotification.h
//  HighwayKing
//
//  Created by Charles Magahern on 1/20/11.
//  Copyright 2011 omegaHern LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface TGAchievementNotification : CCSprite {
	NSString *title;
	NSString *message;
	NSString *iconFilePath;
}

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *message;
@property (nonatomic, retain) NSString *iconFilePath;

- (id)initWithAchievementTitle:(NSString *)_title message:(NSString *)_message iconFile:(NSString *)_path;

@end
