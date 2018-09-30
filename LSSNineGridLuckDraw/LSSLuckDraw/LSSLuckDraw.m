//
//  LSSLuckDraw.m
//  LSSNineGridLuckDraw
//
//  Created by 连帅帅 on 2018/9/26.
//  Copyright © 2018年 连帅帅. All rights reserved.
//

#import "LSSLuckDraw.h"
static int const kBtnSpace          = 50;
static int const kRowAndColumNumber = 3;
@interface LSSLuckDraw ()
{
    NSTimer    *_startTimer;
    CGFloat    _intervalTime;
    NSInteger  _currentRunCount;
    NSInteger  _stopRunCount;
}
@property (nonatomic, strong) NSArray
*imagesArray;//图片的数组
@property (nonatomic, strong) NSMutableArray
*btnMutableArray;//按钮的数组
@property (nonatomic, strong) UIButton
*startBtn;//中间的开始按钮
@property (nonatomic, strong) UIButton
*runBtn;//正在跑的按钮
@property(nonatomic,strong)UIButton
*endBtn;//最终停止的按钮
@end
@implementation LSSLuckDraw

-(id)initWithFrame:(CGRect)frame imagesArray:(NSArray *)array{
    
    if (self = [super initWithFrame:frame]) {
        _stopRunCount = 0;
        self.imagesArray = array;
        [self setUpChildView];
    }
    return self;
}

//创建控件
-(void)setUpChildView{
   
    CGFloat viewWidth  = self.frame.size.width;
    CGFloat viewHeight = self.frame.size.height;
    CGFloat btnWidth   = (viewWidth-(kRowAndColumNumber-1)*kBtnSpace)/kRowAndColumNumber;
    CGFloat btnHeight = (viewHeight-(kRowAndColumNumber-1)*kBtnSpace)/kRowAndColumNumber;
    // 初始化九宫格
    for (int i = 0; i < _imagesArray.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat btnx = (i%kRowAndColumNumber)*btnWidth + kBtnSpace;
        CGFloat btny = (i/kRowAndColumNumber)*btnHeight+kBtnSpace;
        btn.frame = CGRectMake(btnx,btny, btnWidth, btnHeight);
        btn.backgroundColor = [UIColor clearColor];
        btn.tag=i;
        [self addSubview:btn];
        if (i==4) {
            [btn setTitle:@"抽奖" forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            [btn setBackgroundColor:[UIColor yellowColor]];
            [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
            self.startBtn = btn;
            continue;
        }
        UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(8,8, btnWidth - 16, btnHeight - 16)];
        imageV.image = [UIImage imageNamed:[_imagesArray objectAtIndex: i>4 ? i-1 : i]];
        [btn addSubview:imageV];
        [self.btnMutableArray addObject:btn];
    }
    
    // 交换按钮位置（顺时针做动画 所以要交换位置）
    [self exchangeFrameWithBtn:self.btnMutableArray[3] otherBtn:self.btnMutableArray[4]];
    [self exchangeFrameWithBtn:self.btnMutableArray[4] otherBtn:self.btnMutableArray[7]];
    [self exchangeFrameWithBtn:self.btnMutableArray[5] otherBtn:self.btnMutableArray[6]];
}

- (void)exchangeFrameWithBtn:(UIButton *)firstBtn otherBtn:(UIButton *)secondBtn {
    CGRect frame = firstBtn.frame;
    firstBtn.frame = secondBtn.frame;
    secondBtn.frame = frame;
}

#pragma mark --- 抽奖按钮点击事件
- (void)btnClick:(UIButton *)btn {
    
    _intervalTime = 0.5;
    _stopRunCount = _stopRunCount + self.endCount + 8*self.cycleCount;
    [self.startBtn setEnabled:NO];
    _startTimer = [NSTimer scheduledTimerWithTimeInterval:_intervalTime target:self selector:@selector(start:) userInfo:nil repeats:NO];
    
    NSTimer *netRequestTimer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(netAction) userInfo:nil repeats:NO];
    [netRequestTimer setFireDate:[NSDate dateWithTimeIntervalSince1970:([[NSDate date] timeIntervalSince1970]+7) ]];
}

//动起来
- (void)start:(NSTimer *)timer {
   
//    [self.runBtn.layer removeAnimationForKey:nil];
    //设置按钮颜色
    [self setUpBtnBackgroundColor];
    
    //加速
    [self startmerAdd:timer];
    
}

//设置按钮颜色
-(void)setUpBtnBackgroundColor {
   
    if (self.runBtn) {
        //清除上一个按钮的背景颜色
        self.runBtn.backgroundColor = [UIColor clearColor];
    }
    
    //取出后一个按钮的颜色
    UIButton * oldBtn = self.btnMutableArray[_currentRunCount % self.btnMutableArray.count];
    oldBtn.backgroundColor = [UIColor orangeColor];
    self.runBtn = oldBtn;
    _currentRunCount++;
}

//加速开始
-(void)startmerAdd:(NSTimer *)timer{
  
    if (_intervalTime > 0.2) {
        _intervalTime = _intervalTime - 0.1;
    }
    [timer invalidate];
    _startTimer = [NSTimer scheduledTimerWithTimeInterval:_intervalTime target:self selector:@selector(start:) userInfo:nil repeats:NO];
}

-(void)netAction{
    
    //停到某个按钮
    self.endBtn = self.btnMutableArray[self.endCount];

    [self stopAccelerate];
}

//减速止停止
-(void)stopAccelerate{
    //开始减速
    
    //设置按钮颜色
    [self setUpBtnBackgroundColor];
    
    if (_intervalTime < self.endCount / 10.0) {

        _intervalTime += 0.1;
    }
    
    [_startTimer invalidate];
    _startTimer = [NSTimer scheduledTimerWithTimeInterval:_intervalTime target:self selector:@selector(stopAccelerate) userInfo:nil repeats:NO];
    
    //请求后台数据回来这时候可能还没有转够我们预定的个数所以继续转动
    if (_currentRunCount > _stopRunCount && [self.runBtn isEqual:self.endBtn] && _intervalTime == self.endCount / 10.0) {
        
        [_startTimer invalidate];
        [self.startBtn setEnabled:NO];
        [self setStopBtnAnimation:self.runBtn];
        [self stopWithCount:_currentRunCount % self.btnMutableArray.count];

    }
}

//暂停的按钮继续做动画
- (void)setStopBtnAnimation:(UIButton *)button{
    
    CABasicAnimation * basicBackGroundColorAnnimation =  [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
    basicBackGroundColorAnnimation.fromValue = [UIColor orangeColor];
    basicBackGroundColorAnnimation.toValue   = [UIColor orangeColor];
    basicBackGroundColorAnnimation.duration  = 0.1;
    basicBackGroundColorAnnimation.autoreverses = true;
    basicBackGroundColorAnnimation.removedOnCompletion = false;
    basicBackGroundColorAnnimation.fillMode = kCAFillModeForwards;
    basicBackGroundColorAnnimation.repeatCount = MAXFLOAT;
    [self.runBtn.layer addAnimation:basicBackGroundColorAnnimation forKey:nil];
}

- (void)stopWithCount:(NSInteger)count {
   
    NSLog(@"%ld",count);
}
#pragma mark--getters and setters
-(NSMutableArray *)btnMutableArray{
    
    if (!_btnMutableArray) {
        
        _btnMutableArray = [NSMutableArray new];
    }
    return _btnMutableArray;
}
@end
