//
//  EEProgressView.m
//  yykitTest
//
//  Created by 刘赋山 on 2019/1/15.
//  Copyright © 2019 刘赋山. All rights reserved.
//

#import "EEProgressView.h"
#import "UIView+Gradient.h"

#define EEProgressDuration 1.5

@interface EEProgressView ()

@property (nonatomic, strong) UIView *progressContentView;
@property (nonatomic, strong) UIImageView *frontView;
@property (nonatomic, strong) UIImageView *backView;
@property (nonatomic, strong) UIImageView *progressMaskView;

@property (nonatomic, strong) UIImageView *effectAnimationView;

@property (nonatomic, assign) CGFloat progressValue;
@property (nonatomic, assign) BOOL isFirstUpdateProgress;
@property (nonatomic, strong) NSTimer *effectAnimationTimer;

@end

@implementation EEProgressView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self configData];
        [self configUI];
    }
    return self;
}

- (void)configData {
    _direction = EEProgressRiseDirectionRight;
    _progressValue = 0.5;
    _isFirstUpdateProgress = YES;
}

- (void)dealloc {
    [self _hideEffectView];
}

- (void)_updateProgressWithAnimation:(BOOL)animation {
    
    if (_isFirstUpdateProgress) {
        if (_direction & EEProgressRiseDirectionHorizontal) {
            [self.backView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(@(_contentSize.width));
            }];
            [self.frontView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(@(_contentSize.width));
            }];
            
        } else if (_direction & EEProgressRiseDirectionVertical) {
            [self.frontView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.equalTo(@(_contentSize.height));
            }];
            
            [self.backView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.equalTo(@(_contentSize.height));
            }];
        }
        _isFirstUpdateProgress = NO;
    }

    CGFloat progressLength = _direction & EEProgressRiseDirectionHorizontal ? _contentSize.width * _progressValue : _contentSize.height * _progressValue;
    CGFloat duration = animation ? EEProgressDuration : 0.005;
    
    CGRect progressFrame = CGRectZero;
    if (_direction & EEProgressRiseDirectionHorizontal) {
        CGFloat leftSpaceing = _direction == EEProgressRiseDirectionRight ? 0 : _contentSize.width - progressLength;
        progressFrame = CGRectMake(leftSpaceing, 0, progressLength, _contentSize.height);
    }
    else if (_direction & EEProgressRiseDirectionVertical) {
        CGFloat topSpaceing = _direction == EEProgressRiseDirectionDown ? 0 : _contentSize.height - progressLength;
        progressFrame = CGRectMake(0, topSpaceing, _contentSize.width, progressLength);
    }
    [self showEffectAnimationIfNeed];
    [UIView animateWithDuration:duration
                     animations:^{
                         self.progressMaskView.frame = progressFrame;
                    
                         if (self.effectType > EEProgressEffectTypeNone) {
                             if (_direction & EEProgressRiseDirectionHorizontal) {
                                 CGFloat leftSpaceing = _direction == EEProgressRiseDirectionRight ? progressLength : _contentSize.width - progressLength;
                                 [self.effectAnimationView mas_updateConstraints:^(MASConstraintMaker *make) {
                                     make.centerX.mas_equalTo(self.mas_left).offset(leftSpaceing);
                                 }];
                             }
                             else if (_direction & EEProgressRiseDirectionVertical) {
                                 CGFloat tipSpaceing = _direction == EEProgressRiseDirectionDown ? progressLength : _contentSize.height - progressLength;
                                 [self.effectAnimationView mas_updateConstraints:^(MASConstraintMaker *make) {
                                     make.centerY.mas_equalTo(self.mas_top).offset(tipSpaceing);
                                 }];
                             }
                             [self layoutIfNeeded];
                         }
                     }];
}

- (void)showEffectAnimationIfNeed {
    if (self.effectType == EEProgressEffectTypeNone) return;
    
    if (self.effectType == EEProgressEffectTypeFrameAnimation) {
        [self.effectAnimationView startAnimating];
    }
    
    self.effectAnimationView.hidden = NO;
    
    if (self.effectDuration == EEProgressEffectDurationOnMove) {
        if (_effectAnimationTimer) {
            [_effectAnimationTimer invalidate];
            _effectAnimationTimer = nil;
        }
        
        _effectAnimationTimer = [NSTimer scheduledTimerWithTimeInterval:EEProgressDuration target:self selector:@selector(_hideEffectView) userInfo:nil repeats:YES];
    }
}

- (void)_hideEffectView {
    if (self.effectType == EEProgressEffectTypeNone) return;
    
    if (self.effectType == EEProgressEffectTypeFrameAnimation) {
        [self.effectAnimationView stopAnimating];
    }

    self.effectAnimationView.hidden = YES;
    
    [_effectAnimationTimer invalidate];
    _effectAnimationTimer = nil;
}

- (void)setProgressValue:(CGFloat)progressValue animation:(BOOL)animation {
    _progressValue = progressValue;
    if (_progressValue > 1.0) {
        _progressValue = 1.0;
    }
    if (_progressValue < 0.0) {
        _progressValue = 0.0;
    }
    if (isnan(_progressValue)) {
        _progressValue = 0.0;
    }
    
    [self _updateProgressWithAnimation:animation];
}

- (void)setFrontLength:(CGFloat)fLength backLength:(CGFloat)bLength {
    if (_direction & EEProgressRiseDirectionHorizontal) {
        [self.backView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(bLength));
        }];
        [self.frontView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(fLength));
        }];
         self.progressMaskView.frame = CGRectMake(0, 0, fLength, _contentSize.height);
    } else if (_direction & EEProgressRiseDirectionVertical) {
        [self.frontView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@(fLength));
        }];
        
        [self.backView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@(bLength));
        }];
         self.progressMaskView.frame = CGRectMake(0, 0, _contentSize.width, fLength);
    }
}

- (void)setContentSize:(CGSize)contentSize {
    _contentSize = contentSize;
}

- (void)setEffectViewSize:(CGSize)effectViewSize {
    _effectViewSize = effectViewSize;
    [self.effectAnimationView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(effectViewSize);
    }];
    [self layoutIfNeeded];
}

- (void)setEffectImgs:(NSArray *)effectImgs {
    _effectImgs = effectImgs;
    [self.effectAnimationView setAnimationImages:effectImgs];
}

- (void)setContentCornerRadius:(CGFloat)radius {
    self.progressContentView.layer.cornerRadius = radius;
    self.layer.cornerRadius = radius;
}

- (void)setDirection:(EEProgressRiseDirection)direction {
    EEProgressRiseDirection before = _direction;
    _direction = direction;
    
    if (before != direction) {
        if (direction & EEProgressRiseDirectionHorizontal) {
            [self.frontView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.top.bottom.equalTo(self);
                make.width.equalTo(@0);
            }];
            
            [self.backView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.top.bottom.equalTo(self);
                make.width.equalTo(@0);
            }];
            
            [self.effectAnimationView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerX.mas_equalTo(self.mas_left).offset(0);
                make.centerY.equalTo(self);
                make.size.mas_equalTo(CGSizeZero);
            }];
        }
        else if (direction & EEProgressRiseDirectionVertical) {
            [self.frontView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.left.right.equalTo(self);
                make.height.equalTo(@0);
            }];
            
            [self.backView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.bottom.left.right.equalTo(self);
                make.height.equalTo(@0);
            }];
            
            [self.effectAnimationView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self);
                make.centerY.mas_equalTo(self.mas_top).offset(0);
                make.size.mas_equalTo(CGSizeZero);
            }];
        }
    }
}

#pragma mark - Getter

- (void)configUI {
    self.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.1];
    self.layer.cornerRadius = 1.5f;
    
    
    [self addSubview:self.progressContentView];
    [self addSubview:self.effectAnimationView];
    
    [self.progressContentView addSubview:self.backView];
    [self.progressContentView addSubview:self.frontView];
    
    [self.progressContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self);
    }];
    
    [self.frontView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(self);
        make.width.equalTo(@0);
    }];
    
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.bottom.equalTo(self);
        make.width.equalTo(@0);
    }];
    
    [self.effectAnimationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_left).offset(0);
        make.centerY.equalTo(self);
        make.size.mas_equalTo(CGSizeZero);
    }];
    
    self.frontView.maskView = self.progressMaskView;
    self.progressMaskView.frame = CGRectZero;
}

- (UIView *)progressContentView {
    if (!_progressContentView) {
        _progressContentView = [[UIView alloc] init];
        _progressContentView.layer.cornerRadius = 1.5f;
        _progressContentView.clipsToBounds = YES;
    }
    return _progressContentView;
}

- (UIImageView *)frontView {
    if (!_frontView) {
        _frontView = [[UIImageView alloc] init];
        _frontView.contentMode = UIViewContentModeScaleAspectFill;
        _frontView.clipsToBounds = YES;
    }
    return _frontView;
}

- (UIImageView *)backView {
    if (!_backView) {
        _backView = [[UIImageView alloc] init];
        _backView.contentMode = UIViewContentModeScaleAspectFill;
        _backView.clipsToBounds = YES;
    }
    return _backView;
}

- (UIImageView *)effectAnimationView {
    if (!_effectAnimationView) {
        _effectAnimationView = [[UIImageView alloc] init];
        [_effectAnimationView setAnimationRepeatCount:0];
        [_effectAnimationView setAnimationDuration:1.0f];
        _effectAnimationView.hidden = YES;
    }
    return _effectAnimationView;
}

- (UIImageView *)progressMaskView {
    if (!_progressMaskView) {
        _progressMaskView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 15)];
        _progressMaskView.image = [self imageOfColor:[UIColor whiteColor]];
    }
    return _progressMaskView;
}

- (UIImage *)imageOfColor:(UIColor *)color{
    CGRect rect = CGRectMake(0, 0, 1000, 1000);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

@end
