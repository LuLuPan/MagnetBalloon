//
//  Magnet.m
//  MagnetBalloon
//
//  Created by Luning Pan on 7/6/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Magnet.h"

@implementation Magnet

- (id)init {
    self = [super init];
    if (self) {
        self.pole_n = TRUE;
    }
    
    return self;
}

- (id)initMagnet {
    if (self) {
        self.pole_n = TRUE;
    }
    
    return self;
}

@end
