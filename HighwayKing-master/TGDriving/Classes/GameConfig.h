//
//  GameConfig.h
//  TGDriving
//
//  Created by Charles Magahern on 10/21/10.
//  Copyright omegaHern 2010. All rights reserved.
//

#ifndef __GAME_CONFIG_H
#define __GAME_CONFIG_H

//
// Supported Autorotations:
//		None,
//		UIViewController,
//		CCDirector
//
#define kGameAutorotationNone 0
#define kGameAutorotationCCDirector 1
#define kGameAutorotationUIViewController 2

//
// Define here the type of autorotation that you want for your game
//
#define GAME_AUTOROTATION kGameAutorotationUIViewController

//#warning DEBUG MODE ON!
//#define DEBUG_MODE_ENABLED

//#define GAME_CENTER_ENABLED

#endif // __GAME_CONFIG_H
