//
//  InboxRefreshControl.h
//
//
//  Created by Bobo Shone on 15/6/5.
//  Copyright (c) 2015年 . All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InboxRefreshControl : UIView

@property(nonatomic, readonly) BOOL refreshing;

- (instancetype)initWithSize:(CGFloat)size;
- (void)beginRefreshing;
- (void)endRefreshing;

@end
