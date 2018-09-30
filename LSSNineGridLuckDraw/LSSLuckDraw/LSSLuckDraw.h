//
//  LSSLuckDraw.h
//  LSSNineGridLuckDraw
//
//  Created by 连帅帅 on 2018/9/26.
//  Copyright © 2018年 连帅帅. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSSLuckDraw : UIView

/**
 圈数
 */
@property(nonatomic,assign)NSInteger cycleCount;

/**
 最后停的位置 数组中 位置
 */
@property(nonatomic,assign)NSInteger endCount;

/**
 frame 九宫格大小
 array 图片数组
 */
- (id)initWithFrame:(CGRect)frame imagesArray:(NSArray *)array;
@end
