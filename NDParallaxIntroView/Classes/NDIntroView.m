//
//  NDIntroPageView.m
//  NDParallaxIntroView
//
//  Created by Simon Wicha on 17/04/2016.
//  Copyright © 2016 Simon Wicha. All rights reserved.
//

#import "NDIntroView.h"
#import "NDIntroPageView.h"

@interface NDIntroView () <UIScrollViewDelegate>
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIScrollView *parallaxBackgroundScrollView;

@property (strong, nonatomic) NSMutableArray<UIView *> *pageViews;
@property (strong, nonatomic) NSArray <NSDictionary*> *onboardContentArray;

@end

@implementation NDIntroView

- (id)initWithFrame:(CGRect)frame parallaxImage:(UIImage *)parallaxImage andData:(NSArray *)data {
    self = [super initWithFrame:frame];
    if(self) {
        self.onboardContentArray = data;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(-50, 0, self.scrollView.frame.size.width * self.onboardContentArray.count, self.frame.size.height)];
        [imageView setImage:parallaxImage];
        imageView.contentMode = UIViewContentModeLeft;
        [self.parallaxBackgroundScrollView addSubview:imageView];
        
        [self addSubview:self.parallaxBackgroundScrollView];
        [self addSubview:self.scrollView];
        [self addSubview:self.pageControl];
        
        [self generateIntroPageViews];
    }
    return self;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = CGRectGetWidth(self.bounds);
    CGFloat pageFraction = self.scrollView.contentOffset.x / pageWidth;
    self.pageControl.currentPage = roundf(pageFraction);
    CGFloat backgroundScrollValue = 0.5f;//self.backgroundImage.size.width/self.onboardContentArray.count/self.frame.size.width;
    [self.parallaxBackgroundScrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x  * backgroundScrollValue, self.scrollView.contentOffset.y) animated:NO];
}

- (void)generateIntroPageViews {
    [self.onboardContentArray enumerateObjectsUsingBlock:^(NSDictionary *pageDict, NSUInteger idx, BOOL *stop) {
        NDIntroPageView *pageView = [[[NSBundle bundleForClass:[self class]] loadNibNamed:@"NDIntroPageView" owner:nil options:nil] lastObject];
        pageView.frame = CGRectMake(self.frame.size.width * idx, 0, self.frame.size.width, self.frame.size.height);
        //pageView.titlelabel.text = (pageDict[kNDIntroPageTitle]) ? pageDict[kNDIntroPageTitle] : @"nil";
        if ([pageDict[kNDIntroPageTitle] isKindOfClass:[NSString class]]) {
            pageView.titlelabel.text = pageDict[kNDIntroPageTitle];
        }
        else if ([pageDict[kNDIntroPageTitle] isKindOfClass:[NSAttributedString class]]) {
            pageView.titlelabel.attributedText = pageDict[kNDIntroPageTitle];
        }
        else {
            pageView.titlelabel.text = @"";
        }
        //pageView.descriptionLabel.text = (pageDict[kNDIntroPageDescription]) ? pageDict[kNDIntroPageDescription] : @"";
        if ([pageDict[kNDIntroPageDescription] isKindOfClass:[NSString class]]) {
            pageView.descriptionLabel.text = pageDict[kNDIntroPageDescription];
        }
        else if ([pageDict[kNDIntroPageDescription] isKindOfClass:[NSAttributedString class]]) {
            pageView.descriptionLabel.attributedText = pageDict[kNDIntroPageDescription];
        }
        else {
            pageView.descriptionLabel.text = @"";
        }
        pageView.imageView.image = [[UIImage imageNamed:(pageDict[kNDIntroPageImageName]) ? pageDict[kNDIntroPageImageName] : @""] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        pageView.imageHorizontalConstraint.constant = ([pageDict[kNDIntroPageImageHorizontalConstraintValue] floatValue]) ? [pageDict[kNDIntroPageImageHorizontalConstraintValue] floatValue] : -130.f;
        pageView.titleLabelHeightConstraint.constant = ([pageDict[kNDIntroPageTitleLabelHeightConstraintValue] floatValue]) ? [pageDict[kNDIntroPageTitleLabelHeightConstraintValue] floatValue] : 80.f;
        
        if ([pageDict[kNDIntroPageCustomView] isKindOfClass:[UIView class]]) {
            [pageView.customView addSubview: pageDict[kNDIntroPageCustomView]];
            [pageDict[kNDIntroPageCustomView] setCenter:CGPointMake(pageView.customView.frame.size.width/2, pageView.customView.frame.size.height/2)];
            [pageView.customView setHidden:false];
            [pageView.titlelabel setHidden:true];
            [pageView.descriptionLabel setHidden:true];
        }
        
        if (self.onboardContentArray.count - 1 == idx) [pageView addSubview:self.lastPageButton];
        [self.scrollView addSubview:pageView];
    }];
}

-(UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.frame];
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = YES;
        _scrollView.contentSize = CGSizeMake(self.frame.size.width * self.onboardContentArray.count, self.scrollView.frame.size.height);
        _scrollView.showsHorizontalScrollIndicator = NO;
        [_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
    return _scrollView;
}

-(UIScrollView *)parallaxBackgroundScrollView {
    if (!_parallaxBackgroundScrollView) {
        _parallaxBackgroundScrollView = [[UIScrollView alloc] initWithFrame:self.frame];
        _parallaxBackgroundScrollView.delegate = self;
        _parallaxBackgroundScrollView.pagingEnabled = YES;
        _parallaxBackgroundScrollView.userInteractionEnabled = NO;
        _parallaxBackgroundScrollView.contentSize = CGSizeMake(self.frame.size.width*4, self.scrollView.frame.size.height);
        _parallaxBackgroundScrollView.showsHorizontalScrollIndicator = NO;
        [_parallaxBackgroundScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
    return _parallaxBackgroundScrollView;
}

-(UIPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.frame.size.height-80, self.frame.size.width, 10)];
        _pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
        _pageControl.numberOfPages = self.onboardContentArray.count;
    }
    return _pageControl;
}

-(UIButton *)lastPageButton {
    if (!_lastPageButton) {
        _lastPageButton = [[UIButton alloc] initWithFrame:CGRectMake(20, self.frame.size.height-60, self.frame.size.width - 40, 40)];
        _lastPageButton.layer.cornerRadius = 5.f;
        _lastPageButton.tintColor = [UIColor whiteColor];
        _lastPageButton.backgroundColor = [UIColor colorWithRed:70.f/255.f green:130.f/255.f blue:180.f/255.f alpha:1.f];
        [_lastPageButton setTitle:@"Let's Go!" forState:UIControlStateNormal];
        [_lastPageButton.titleLabel setFont:[UIFont fontWithName:@"TrebuchetMS" size:18.0]];
        [_lastPageButton addTarget:self.delegate action:@selector(launchAppButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    }
    return _lastPageButton;
}

@end
