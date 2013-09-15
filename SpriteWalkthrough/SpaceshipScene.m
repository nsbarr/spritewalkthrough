//
//  SpaceshipScene.m
//  SpriteWalkthrough
//
//  Created by Nicholas Barr on 9/8/13.
//  Copyright (c) 2013 Nicholas Barr. All rights reserved.
//

#import "SpaceshipScene.h"

@interface SpaceshipScene ()
@property BOOL contentCreated;
@property BOOL amiDone;
@end

@implementation SpaceshipScene
- (void)didMoveToView:(SKView *)view
{
    if (!self.contentCreated)
    {
        [self createSceneContents];
        self.contentCreated = YES;
    }
}

- (SKSpriteNode *)outerSpace
{
    SKSpriteNode *space = [[SKSpriteNode alloc] initWithColor:[SKColor blackColor] size:CGSizeMake(4000,4000)];
    space.name = @"space";
    return space;
}
- (SKSpriteNode *)newLight
{
    SKSpriteNode *light = [[SKSpriteNode alloc] initWithColor:[SKColor yellowColor] size:CGSizeMake(8,8)];
    
    SKAction *blink = [SKAction sequence:@[
                                           [SKAction fadeOutWithDuration:0.25],
                                           [SKAction fadeInWithDuration:0.25]]];
    SKAction *blinkForever = [SKAction repeatActionForever:blink];
    [light runAction: blinkForever];
    
    return light;
}


- (SKSpriteNode *)newSpaceship
{

    SKSpriteNode *hull = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship.png"];
    
    
    //Name it
    hull.name = @"spaceship";
   // SKSpriteNode *hull = [[SKSpriteNode alloc] initWithColor:[SKColor grayColor] size];
    hull.size = CGSizeMake(64,64);
   //hull.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:hull.size];
    hull.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:hull.size.width/2];
    //hull.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath: (__bridge CGPathRef)(aPath)];
    hull.physicsBody.dynamic = NO;
    
    SKSpriteNode *light1 = [self newLight];
    light1.position = CGPointMake(-28.0, 6.0);
    [hull addChild:light1];
    
    SKSpriteNode *light2 = [self newLight];
    light2.position = CGPointMake(28.0, 6.0);
    [hull addChild:light2];
    
    return hull; }

- (void)touchesBegan:(NSSet *) touches withEvent:(UIEvent *)event
{
    SKNode *spaceship = [self childNodeWithName:@"spaceship"];
    SKNode *space = [self childNodeWithName:@"space"];
    UITouch *touch = [touches anyObject];
    
    NSArray *nodes = [self nodesAtPoint:[touch locationInNode:self]];
    for (SKNode *node in nodes) {
        if (![nodes containsObject:spaceship]) {
            //  CGPoint teleportlocation = [touch locationInNode:space];
            CGPoint pointToMove = [touch locationInNode: space];
            
            //  spaceship.position = CGPointMake(pointToMove.x, pointToMove.y);
            SKAction *teleport = [SKAction sequence:@[
                                                      [SKAction waitForDuration:0],
                                                      [SKAction moveTo:pointToMove duration:1.0]]];
            [spaceship runAction: [SKAction repeatAction: teleport count:(1)]];
            //   }

        }
        else {
            SKAction *hover = [SKAction sequence:@[
                                                   [SKAction fadeOutWithDuration:0.25],
                                                   [SKAction fadeInWithDuration:0.25]]];
            [spaceship runAction: [SKAction repeatAction: hover count:(1) ]];
        }
    }
}

static inline CGFloat skRandf() {
    return rand() / (CGFloat) RAND_MAX;
}

static inline CGFloat skRand(CGFloat low, CGFloat high) {
    return skRandf() * (high - low) + low;
}

- (void)addRock
{
    //SKSpriteNode *rock = [[SKSpriteNode alloc] initWithColor:[SKColor brownColor] size:CGSizeMake(8,8)];
    SKSpriteNode *rock = [SKSpriteNode spriteNodeWithImageNamed:@"Asteroid.png"];
    rock.size = CGSizeMake(8,8);
    rock.position = CGPointMake(skRand(0, self.size.width), self.size.height-50);
    rock.name = @"rock";
    rock.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:rock.size];
    rock.physicsBody.usesPreciseCollisionDetection = YES;
    [self addChild:rock];
}


- (void)createSceneContents
{
    self.backgroundColor = [SKColor blackColor];
    self.scaleMode = SKSceneScaleModeAspectFit;
    SKSpriteNode *spaceship = [self newSpaceship];
    SKSpriteNode *space = [self outerSpace];

    spaceship.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-150);
    [self addChild:space];
    [self addChild:spaceship];
    SKAction *makeRocks = [SKAction sequence: @[
                                                [SKAction performSelector:@selector(addRock) onTarget:self],
                                                [SKAction waitForDuration:0.10 withRange:0.15]
                                                ]];
    [self runAction: [SKAction repeatActionForever:makeRocks]];
}
-(void)didSimulatePhysics
{
    [self enumerateChildNodesWithName:@"rock" usingBlock:^(SKNode *node, BOOL *stop) {
        if (node.position.y < 0)
            [node removeFromParent];
    }];
}
@end