/*
 *  TGCommon.h
 *  TGDriving
 *
 *  Created by Charles Magahern on 10/21/10.
 *  Copyright 2010 omegaHern. All rights reserved.
 *
 */

#include "GameConfig.h"

typedef struct _ptnode {
	CGPoint point;
	struct _ptnode *next;
	struct _ptnode *prev;
} PointNode;