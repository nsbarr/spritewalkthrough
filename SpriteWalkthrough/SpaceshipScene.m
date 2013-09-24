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
@property BOOL isShieldEnabled;
@property BOOL hasShieldBarLoaded;
@end

CGFloat _shieldpercentage = 100.00f;

@implementation SpaceshipScene
- (void)didMoveToView:(SKView *)view
{
    if (!self.contentCreated)
    {
        [self createSceneContents];
        _isShieldEnabled = FALSE;
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

- (SKSpriteNode *)newShield
{
 SKSpriteNode *shield = [SKSpriteNode spriteNodeWithImageNamed:@"Shield.png"];
    shield.name = @"shield""%";
    shield.size = CGSizeMake(264,264);
    //hull.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:hull.size];
    shield.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:shield.size.width/2];
    //hull.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath: (__bridge CGPathRef)(aPath)];
    shield.physicsBody.dynamic = NO;

    return shield;
    
}

- (SKLabelNode *)newScore
{
SKLabelNode *scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Courier-Bold"];
    scoreLabel.name = @"hector";
scoreLabel.fontSize = 200;
scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
scoreLabel.fontColor = [SKColor colorWithHue:0 saturation:0 brightness:1 alpha:0.3];
scoreLabel.text = @"00";
scoreLabel.text = [NSString stringWithFormat:@"%02.0f", _shieldpercentage];


    return scoreLabel;
    
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
    
   // SKSpriteNode *light1 = [self newLight];
   // light1.position = CGPointMake(-28.0, 6.0);
   // [hull addChild:light1];
    
   // SKSpriteNode *light2 = [self newLight];
   // light2.position = CGPointMake(28.0, 6.0);
   // [hull addChild:light2];
    

    
    return hull; }



- (void)touchesBegan:(NSSet *) touches withEvent:(UIEvent *)event
{
    SKNode *spaceship = [self childNodeWithName:@"spaceship"];
    SKNode *space = [self childNodeWithName:@"space"];
//    shield.name = @"shield";

    UITouch *touch = [touches anyObject];
    
    NSArray *nodes = [self nodesAtPoint:[touch locationInNode:self]];
    //for (SKNode *node in nodes) {
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
        else if (_shieldpercentage > 0) {
         //   SKAction *hover = [SKAction sequence:@[
           //                                        [SKAction fadeOutWithDuration:0.25],
           //                                        [SKAction fadeInWithDuration:0.25]]];
           // [spaceship runAction: [SKAction repeatAction: hover count:(1) ]];
            SKNode *shield = [self childNodeWithName:@"shield"];
            shield = [self newShield];
            shield.position = CGPointMake(0, 0);
            [spaceship addChild:shield];
            spaceship.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:132];
            spaceship.physicsBody.dynamic = NO;
            SKAction *fadeOut = [SKAction fadeOutWithDuration: 0.2];
            SKAction *fadeIn = [SKAction fadeInWithDuration: 0.2];
            SKAction *pulse = [SKAction sequence:@[fadeOut,fadeIn]];
            SKAction *pulseForever = [SKAction repeatActionForever:pulse];
            [shield runAction: pulseForever];
            _isShieldEnabled = TRUE;

//   break;

        }
        else{
            return;
        }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    SKNode *spaceship = [self childNodeWithName:@"spaceship"];
    SKNode *space = [self childNodeWithName:@"space"];
    //    shield.name = @"shield";
    
    UITouch *touch = [touches anyObject];
    
//    NSArray *nodes = [self nodesAtPoint:[touch locationInNode:self]];

    CGPoint pointToMove = [touch locationInNode: space];
    
    //  spaceship.position = CGPointMake(pointToMove.x, pointToMove.y);
    SKAction *teleport = [SKAction sequence:@[
                                              [SKAction waitForDuration:0],
                                              [SKAction moveTo:pointToMove duration:1.0]]];
    [spaceship runAction: [SKAction repeatAction: teleport count:(1)]];
    
    if(_shieldpercentage <= 0){
          [spaceship removeAllChildren];
    }
    //NSArray *nodes = [self nodesAtPoint:[touch locationInNode:self]];
    //if ([nodes containsObject:spaceship]) {
    //    _isShieldEnabled = TRUE;

//    }


}

- (void)touchesEnded:(NSSet *) touches withEvent:(UIEvent *)event {
    _isShieldEnabled = FALSE;
    SKNode *spaceship = [self childNodeWithName:@"spaceship"];
     //   SKNode *shield = [self childNodeWithName:@"shield"];
     //   SKAction *removeShield = [SKAction removeFromParent];
      //  [shield runAction: removeShield];
    spaceship.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:32];
    spaceship.physicsBody.dynamic = NO;
    [spaceship removeAllChildren];
    
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    _isShieldEnabled = FALSE;
    SKNode *spaceship = [self childNodeWithName:@"spaceship"];
    //   SKNode *shield = [self childNodeWithName:@"shield"];
    //   SKAction *removeShield = [SKAction removeFromParent];
    //  [shield runAction: removeShield];
    spaceship.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:32];
    spaceship.physicsBody.dynamic = NO;
    [spaceship removeAllChildren];
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
    if (_isShieldEnabled){
        _shieldpercentage = _shieldpercentage - 1;
        if(_shieldpercentage < 0){
            _shieldpercentage = 0;
        }
    }
}




//-(void)calculateShieldHealth
//{
//  }

- (void)didBeginContact:(SKPhysicsContact *)contact {
}

- (void)createSceneContents
{
    self.backgroundColor = [SKColor blackColor];
    self.scaleMode = SKSceneScaleModeAspectFit;
    SKSpriteNode *spaceship = [self newSpaceship];
    SKSpriteNode *space = [self outerSpace];
    SKLabelNode *scoreLabel = [self newScore];

    
  //  SKLabelNode *shieldbar = [self shieldbar];



    spaceship.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-150);
    [self addChild:space];
    [self addChild:spaceship];
    [self addChild:scoreLabel];

//    [self addChild:shieldbar];

    
    SKAction *makeRocks = [SKAction sequence: @[
                                                [SKAction performSelector:@selector(addRock) onTarget:self],
                                                [SKAction waitForDuration:0.10 withRange:0.15]
                                                ]];
    [self runAction: [SKAction repeatActionForever:makeRocks]];
    
    _hasShieldBarLoaded = NO;
    
 //   SKAction *calculateShield = [SKAction performSelector:@selector(calculateShieldHealth) onTarget:self];
 //   [self runAction: [SKAction repeatActionForever:calculateShield]];
}

-(void)update:(CFTimeInterval)currentTime
{
    //SKLabelNode *scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Courier-Bold"];
    //scoreLabel.text = [NSString stringWithFormat:@"%f", _shieldpercentage];
   // SKLabelNode *scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Courier-Bold"];
    [self enumerateChildNodesWithName:@"hector" usingBlock:^(SKNode *node, BOOL *stop) {
            [node removeFromParent];
    }];

}
-(void)didSimulatePhysics
{
    SKLabelNode *scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Courier-Bold"];
    scoreLabel.text = [NSString stringWithFormat:@"%f", _shieldpercentage];
    [self addChild:self.newScore];


    [self enumerateChildNodesWithName:@"rock" usingBlock:^(SKNode *node, BOOL *stop) {
        if (node.position.y < 0)
            [node removeFromParent];
    }];
    [self enumerateChildNodesWithName:@"shieldHealth" usingBlock:^(SKNode *node, BOOL *stop) {
        [node removeFromParent];
    }];
   // SKLabelNode *scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Courier-Bold"];
}
@end