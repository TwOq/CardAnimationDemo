//
//  ViewController.m
//  demo
//
//  Created by lizq on 16/5/5.
//  Copyright © 2016年 w jf. All rights reserved.
//

#import "ViewController.h"
#import <POP/POP.h>

#define ANIMATIONTIME 0.0001f
#define REMOVETIME 0.2f
#define FRAMETIME 0.5f
#define VIEWWIDTH 150
#define VIEWHEIGHT 200

@interface ViewController ()
//缓存视图
@property (strong, nonatomic) NSMutableArray *viewArray;
@property (assign, nonatomic) BOOL isFromLeft;
@property (assign, nonatomic) CGPoint beganPoint;

@end

@implementation ViewController


- (NSMutableArray *)viewArray {
    if (_viewArray == nil) {
        _viewArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _viewArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(superPanHandle:)];
    [self.view addGestureRecognizer:panGesture];

}

/**
 *  初始化多个视图
 */
- (void)initView{
    for (int i = 0; i<4; i++) {
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, VIEWWIDTH+i*15, VIEWHEIGHT)];
        view.center = CGPointMake(self.view.center.x, self.view.center.y+i*10);
        view.backgroundColor = [self randomColor];
        [self.view addSubview:view];
        [self.viewArray addObject:view];
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(viewPanHandle:)];
        [view addGestureRecognizer:panGesture];
    }
}

/**
 *  初始化一个视图
 */
- (void)initSingeViewFromBack:(BOOL)isFromBack{
    
    if (isFromBack) {
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, VIEWWIDTH, VIEWHEIGHT)];
        view.center = self.view.center;
        view.backgroundColor = [self randomColor];
        [self.view addSubview:view];
        [self.view insertSubview:view belowSubview:(UIView*)[self.viewArray firstObject]];
        [self.viewArray insertObject:view atIndex:0];
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(viewPanHandle:)];
        [view addGestureRecognizer:panGesture];
    }else{
    
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, VIEWWIDTH+(self.viewArray.count - 1) *15, VIEWHEIGHT)];
        view.center = CGPointMake(self.isFromLeft?0:self.view.bounds.size.width, self.beganPoint.y);
        view.backgroundColor = [self randomColor];
        view.alpha = 0;
        [self.view addSubview:view];
        [self.view insertSubview:view aboveSubview:(UIView*)[self.viewArray lastObject]];
        [self.viewArray addObject:view];
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(viewPanHandle:)];
        [view addGestureRecognizer:panGesture];
    }

}


/**
 *  随机颜色
 */
- (UIColor *)randomColor
{
    CGFloat hue = ( arc4random() % 256 / 256.0 ); //0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5; // 0.5 to 1.0,away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5; //0.5 to 1.0,away from black
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}

/**
 *  父视图手势处理
 */
- (void)superPanHandle:(UIPanGestureRecognizer*)panGesture{
  __block  UIView *view = nil;
    __weak typeof (ViewController *)bself = self;

    if (panGesture.state == UIGestureRecognizerStateBegan) {
        self.beganPoint = [panGesture locationInView:self.view];
        if (self.beganPoint.y < self.view.center.y) {
            return;
        }
        self.isFromLeft = self.beganPoint.x < self.view.center.x?YES:NO;
        [self initSingeViewFromBack:NO];
        view = [self.viewArray lastObject];
        float angle = (view.center.x - self.view.center.x)/self.view.center.x;
        float scale = 1 - fabsf(angle)/2;
        [self setRotation:angle view:view duration:ANIMATIONTIME];
        [self setScale:scale view:view CompletionBlock:^{
            view.alpha = 1;
        } duration:ANIMATIONTIME];
        
    }
    if (self.beganPoint.y < self.view.center.y) {
        return;
    }
    view = [self.viewArray lastObject];

    CGPoint point = [panGesture translationInView:self.view];
    [panGesture setTranslation:CGPointZero inView:self.view];
    
    view.center = CGPointMake(view.center.x + point.x, view.center.y + point.y);
    float angle = (view.center.x - self.view.center.x)/self.view.center.x;
    float scale = 1 - fabsf(angle)/2;
    [self setRotation:angle view:view duration:ANIMATIONTIME];
    [self setScale:scale view:view CompletionBlock:^{
        view.alpha = 1;
    } duration:ANIMATIONTIME];

    
    if (panGesture.state == UIGestureRecognizerStateEnded) {
        
        if (fabs(view.center.x - self.view.center.x)>self.view.center.x/2) {
            float positionX;
            if (view.center.x >self.view.center.x) {
                positionX = self.view.bounds.size.width + view.bounds.size.width/2;
                angle = M_PI*1/3;
            }else{
                positionX = -view.bounds.size.width/2;;
                angle = -M_PI*1/3;
            }

            [self setRotation:angle view:view duration:REMOVETIME];
            [self setScale:0.4 view:view CompletionBlock:^{
                [view removeFromSuperview];
                [bself.viewArray removeLastObject];
            } duration:REMOVETIME];
            [self setPosition:CGPointMake(positionX, view.center.y) view:view duration:REMOVETIME];
        }else{
        
            [self changeViewFrameForward:NO];
            [self.viewArray removeObjectAtIndex:0];
            [self setRotation:0 view:view duration:ANIMATIONTIME];
            [self setScale:1 view:view CompletionBlock:nil duration:ANIMATIONTIME];
            [self setPosition:CGPointMake(self.view.center.x, self.view.center.y+(self.viewArray.count - 1)*10) view:view duration:ANIMATIONTIME];
        }
    }
}



/**
 *  视图手势处理
 */
- (void)viewPanHandle:(UIPanGestureRecognizer *)panGesture{

    CGPoint point = [panGesture translationInView:self.view];
    [panGesture setTranslation:CGPointZero inView:self.view];
    UIView *view = (UIView *)[self.viewArray lastObject];
    __weak typeof (ViewController *)bself = self;
    
    view.center = CGPointMake(view.center.x + point.x, view.center.y + point.y);
    float angle = (view.center.x - self.view.center.x)/self.view.center.x;
    float scale = 1 - fabsf(angle)/2;

    if (panGesture.state == UIGestureRecognizerStateBegan) {
        
        [self initSingeViewFromBack:YES];
        [self changeViewFrameForward:YES];
    }else if (panGesture.state == UIGestureRecognizerStateChanged) {
        
        [self setRotation:angle view:view duration:ANIMATIONTIME];
        [self setScale:scale view:view CompletionBlock:nil duration:ANIMATIONTIME];
    }else if (panGesture.state == UIGestureRecognizerStateEnded) {
        
        if (fabs(view.center.x - self.view.center.x)>self.view.center.x/2) {
            
            float positionX;
            if (view.center.x >self.view.center.x) {
                positionX = self.view.bounds.size.width + view.bounds.size.width/2;
                angle = M_PI*1/3;
            }else{
                positionX = -view.bounds.size.width/2;;
                angle = -M_PI*1/3;
            }
            [self setPosition:CGPointMake(positionX, view.center.y) view:view duration:REMOVETIME];
            [self setScale:0.4 view:view CompletionBlock:^{
                [view removeFromSuperview];
                [bself.viewArray removeLastObject];
            } duration:REMOVETIME];
            [self setRotation:angle view:view duration:REMOVETIME];
        }else{
            
            [self changeViewFrameForward:NO];
            [self.viewArray removeObjectAtIndex:0];
            [self setRotation:0 view:view duration:ANIMATIONTIME];
            [self setScale:1 view:view CompletionBlock:nil duration:ANIMATIONTIME];
            [self setPosition:CGPointMake(self.view.center.x, self.view.center.y+(self.viewArray.count - 1)*10) view:view duration:ANIMATIONTIME];
        }
    }
}

/**
 *  改变所有视图位置和大小
 */
- (void)changeViewFrameForward:(BOOL)isForward{
    if (isForward) {
        for (int i = 1; i< (self.viewArray.count -1); i++) {
            UIView *view = self.viewArray[i];
            CGRect frame = CGRectMake(0, 0, VIEWWIDTH + i*15, VIEWHEIGHT);
            CGPoint center = CGPointMake(self.view.center.x, self.view.center.y + i*10);
            [self setFrame:frame view:view duration:FRAMETIME];
            [self setPosition:center view:view duration:FRAMETIME];
        }
    }else{
        for (int i = 0; i< (self.viewArray.count -2); i++) {
            UIView *view = self.viewArray[i+1];
            CGRect frame = CGRectMake(0, 0, VIEWWIDTH + i*15, VIEWHEIGHT);
            CGPoint center = CGPointMake(self.view.center.x, self.view.center.y + i*10);
            [self setFrame:frame view:view duration:FRAMETIME];
            [self setPosition:center view:view duration:FRAMETIME];
        }
    }
}


/**
 *  动画改变大小
 */
- (void)setFrame:(CGRect)frame view:(UIView*)view duration:(float)time{
    
    POPBasicAnimation *animation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewBounds];
    animation.toValue = [NSValue valueWithCGRect:frame];
    animation.duration = time;
    [view.layer pop_addAnimation:animation forKey:@"bounds"];
}

/**
 *  动画改变中心
 */
- (void)setPosition:(CGPoint)position view:(UIView*)view duration:(float)time{

    POPBasicAnimation *animation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerPosition];
    animation.toValue = [NSValue valueWithCGPoint:position];
    animation.duration = time;
    [view.layer pop_addAnimation:animation forKey:@"position"];
}


/**
 *  旋转动画
 */
- (void)setRotation:(float)xOffset view:(UIView*)view duration:(float)time{
    
    POPBasicAnimation *animation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerRotation];
    animation.toValue = @(xOffset);
    animation.duration = time;
    [view.layer pop_addAnimation:animation forKey:@"rotation"];
}


/**
 *  缩放动画
 */
- (void)setScale:(float)scale view:(UIView*)view CompletionBlock:(void(^)())block duration:(float)time{
    
    POPBasicAnimation *animation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    animation.toValue = [NSValue valueWithCGSize:CGSizeMake(scale, scale)];
    animation.duration = time;
    if (block) {
        [animation setCompletionBlock:^(POPAnimation *animation, BOOL isFinish) {
            if (isFinish) {
                block();
            }
        }];
    }
    [view.layer pop_addAnimation:animation forKey:@"scale"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
