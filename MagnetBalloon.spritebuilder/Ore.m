//
//  Ore.m
//  MagnetBalloon
//
//  Created by Luning Pan on 7/7/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Ore.h"

@implementation Ore {
    CCNode *_object;
    CCNode *_obstacle;
}

- (void)didLoadFromCCB {
    _object.physicsBody.collisionType = @"ore";
    _object.physicsBody.sensor = YES;
    
    _obstacle.physicsBody.collisionType = @"ore";
    _obstacle.physicsBody.sensor = YES;
}

@end
