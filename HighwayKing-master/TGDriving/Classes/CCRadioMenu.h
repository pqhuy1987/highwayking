//
//  CCRadioMenu.h
//  MathNinja
//
//  Created by Ray Wenderlich on 2/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"

@interface CCRadioMenu : CCMenu {
    CCMenuItem *_curHighlighted;
}

@property (nonatomic, retain) CCMenuItem *_curHighlighted;
@property (readonly) CCMenuItem *selectedItem;

- (void)setSelectedItem_:(CCMenuItem *)item;

@end
