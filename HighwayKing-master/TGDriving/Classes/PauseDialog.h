//
//  PauseDialog.h
//  TGDriving
//
//  Created by Charles Magahern on 12/22/10.
//  Copyright 2010 omegaHern. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import <MediaPlayer/MediaPlayer.h>

#define PauseDialogRestartButtonTag 1
#define PauseDialogQuitButtonTag    2
#define PauseDialogResumeButtonTag  3

@protocol PauseDialogDelegate<NSObject>

@required
- (void)pauseDialogButtonTapped:(CCMenuItem *)sender;

@end


@interface PauseDialog : CCNode<CCRGBAProtocol, MPMediaPickerControllerDelegate> {
    GLubyte		opacity;
	ccColor3B	color;
    
    id<PauseDialogDelegate> delegate;
}

@property (nonatomic, readwrite, setter=setOpacity:) GLubyte opacity;
@property (nonatomic, readwrite, setter=setColor:) ccColor3B color;

@property (nonatomic, assign) id<PauseDialogDelegate> delegate;

@end
