//
//  CardCollectionViewCell.h
//  WebBrowser
//
//  Created by 钟武 on 2016/12/20.
//  Copyright © 2016年 钟武. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CardMainView;

typedef void(^closeBlock)();

@interface CardCollectionViewCell : UICollectionViewCell

@property (nonatomic, copy) closeBlock closeBlock;
@property (nonatomic, weak) UICollectionView *collectionView;

- (void)updateModelWithImage:(UIImage *)image title:(NSString *)title;

@end