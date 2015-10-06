//
//  ETSegmentedView.m
//  Pods
//
//  Created by Ersen Tekin on 30/03/15.
//
//

#import "ETSegmentedView.h"

#define kButtonsViewHeight 40

@implementation ETSegmentedView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    if (self) {

        [self setup];
    }

    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];

    if (self) {

        [self setup];
    }

    return self;
}

- (void)setup
{
    // default values

    _arrayTitleButtons = [NSMutableArray new];
    _arrayTitleLabels = [NSMutableArray new];
    _buttonTabHeight = kButtonsViewHeight;
    _currentIndex = 0;
    selfFrame = self.frame;
    isScrollingAnimationActive = NO;
    lastContentX = 0;

    _selectionFont = [UIFont fontWithName:@"HelveticaNeue" size:14.0f];
    _nonSelectionFont = [UIFont fontWithName:@"HelveticaNeue" size:14.0f];

    CGRect rectViewButtons = CGRectMake(0, 0, self.frame.size.width, kButtonsViewHeight);
    _viewButtons = [[UIView alloc] initWithFrame:rectViewButtons];
    _viewButtons.layer.masksToBounds = YES;

    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:_viewButtons.bounds
                                                   byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight
                                                         cornerRadii:CGSizeMake(4.0f, 4.0f)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = _viewButtons.bounds;
    maskLayer.path = maskPath.CGPath;
    _viewButtons.layer.mask = maskLayer;

    [self addSubview:_viewButtons];

    [self refreshView];
}

- (void)setTitles:(NSArray *)titles
{
    _titles = [titles copy];

    [self refreshView];
}

- (void)setContents:(NSArray *)contents
{
    _contents = [contents copy];

    if (_arrayTitleButtons.count <= 0) {
        [self createSelectionView];
        [self createButtonBar];
        [self createContentScrollView];
    }
    else {
        [self refreshView];
    }
}

- (void)setSelectionColor:(UIColor *)selectionColor
{
    _selectionColor = selectionColor;
    [_selectionColor getRed:&selRed green:&selGreen blue:&selBlue alpha:&selAlpha];

    [self refreshView];
}

- (void)setNonSelectionColor:(UIColor *)nonSelectionColor
{
    _nonSelectionColor = nonSelectionColor;
    [_nonSelectionColor getRed:&nonRed green:&nonGreen blue:&nonBlue alpha:&nonAlpha];

    [_viewButtons setBackgroundColor:_nonSelectionColor];

    [self refreshView];
}

- (void)setSelectionTextColor:(UIColor *)selectionTextColor
{
    _selectionTextColor = selectionTextColor;
    [_selectionTextColor getRed:&textSelRed green:&textSelGreen blue:&textSelBlue alpha:&textSelAlpha];

    [self refreshView];
}

- (void)setNonSelectionTextColor:(UIColor *)nonSelectionTextColor
{
    _nonSelectionTextColor = nonSelectionTextColor;
    [_nonSelectionTextColor getRed:&textNonSelRed green:&textNonSelGreen blue:&textNonSelBlue alpha:&textNonSelAlpha];

    [self refreshView];
}

- (void)createButtonBar
{
    // remove buttons if exists on view

    if (_arrayTitleButtons.count > 0) {
        for (UIButton* btn in _arrayTitleButtons) {
            if ([btn.superview isEqual:_viewButtons]) {
                [btn removeFromSuperview];
            }
        }

        [_arrayTitleButtons removeAllObjects];
    }

    // create new buttons

    for (int i = 0; i < _titles.count; i++) {
        CGRect rectBtnTitle = CGRectMake(i * (selfFrame.size.width / _titles.count), 0, (selfFrame.size.width / _titles.count), _buttonTabHeight);

        UIButton* btnTitle = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnTitle setFrame:rectBtnTitle];
        [btnTitle setTitle:@"" forState:UIControlStateNormal];
        [btnTitle addTarget:self action:@selector(btnTapped:) forControlEvents:UIControlEventTouchUpInside];

        UILabel* lblTitle = [[UILabel alloc] initWithFrame:rectBtnTitle];
        [lblTitle setTextAlignment:NSTextAlignmentCenter];
        [lblTitle setText:[_titles objectAtIndex:i]];

        if (i == 0) {
            [lblTitle setFont:_selectionFont];
            [lblTitle setTextColor:_selectionTextColor];
        }
        else {
            [lblTitle setFont:_nonSelectionFont];
            [lblTitle setTextColor:_nonSelectionTextColor];
        }

        [_viewButtons addSubview:btnTitle];
        [_viewButtons addSubview:lblTitle];
        [_arrayTitleButtons addObject:btnTitle];
        [_arrayTitleLabels addObject:lblTitle];
    }
}

- (void)createSelectionView
{
    _viewSelection = [[UIView alloc] initWithFrame:CGRectMake(0, 0, selfFrame.size.width / _titles.count, _buttonTabHeight)];

    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:_viewSelection.bounds
                                                   byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight
                                                         cornerRadii:CGSizeMake(4.0f, 4.0f)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = _viewSelection.bounds;
    maskLayer.path = maskPath.CGPath;
    _viewSelection.layer.mask = maskLayer;

    [_viewSelection setBackgroundColor:_selectionColor];

    [_viewButtons addSubview:_viewSelection];
}

- (void)updateScrollViewData
{
    if (_contents.count > 0) {
        for (id subview in _scrollViewContent.subviews) {
            if ([subview isKindOfClass:[_contents.firstObject class]]) {
                [subview removeFromSuperview];
            }
        }
    }

    for (int i = 0; i < _contents.count; i++) {
        UIView* content = [_contents objectAtIndex:i];

        CGRect rectContent = content.frame;
        rectContent.origin.x = (i * _scrollViewContent.frame.size.width) + (_scrollViewContent.frame.size.width / 2 - rectContent.size.width / 2);

        [content setFrame:rectContent];

        [_scrollViewContent addSubview:content];
    }
}

- (void)createContentScrollView
{
    CGRect rectScrollViewContent = CGRectMake(0, _buttonTabHeight, selfFrame.size.width, selfFrame.size.height - _buttonTabHeight);

    _scrollViewContent = [[UIScrollView alloc] initWithFrame:rectScrollViewContent];
    [_scrollViewContent setDelegate:self];
    [_scrollViewContent setBounces:YES];
    [_scrollViewContent setPagingEnabled:YES];
    [_scrollViewContent setScrollEnabled:NO];
    _scrollViewContent.clipsToBounds = YES;

    [self updateScrollViewData];

    [_scrollViewContent setContentSize:CGSizeMake(selfFrame.size.width * _contents.count, selfFrame.size.height - _buttonTabHeight)];

    [self addSubview:_scrollViewContent];
}

- (void)btnTapped:(UIButton*)sender
{
    NSUInteger indexOfButton = [_arrayTitleButtons indexOfObject:sender];

    if (indexOfButton == _currentIndex) {
        return;
    }

    if (_viewSelection.pop_animationKeys.count > 0) {
        [_viewSelection pop_removeAllAnimations];
    }

    [self animateSelectionViewToIndex:indexOfButton];

    [_scrollViewContent setContentOffset:CGPointMake(indexOfButton * _scrollViewContent.frame.size.width, 0) animated:YES];
    isScrollingAnimationActive = YES;

    if ([_delegate respondsToSelector:@selector(ETSegmentedViewButtonTappedWithIndex:)]) {
        [_delegate ETSegmentedViewButtonTappedWithIndex:indexOfButton];
    }
}

- (void)animateSelectionViewToIndex:(NSUInteger)index
{
    float btnWidth = (selfFrame.size.width / _titles.count);
    float animateToLocation = (int)index * btnWidth;

    UILabel* lblCurrent = [_arrayTitleLabels objectAtIndex:_currentIndex];
    UILabel* lblNext = [_arrayTitleLabels objectAtIndex:index];

    // location change animation

    POPSpringAnimation *locAnimation = [POPSpringAnimation animation];
    locAnimation.property = [POPAnimatableProperty propertyWithName: kPOPLayerPositionX];
    locAnimation.toValue = @(animateToLocation + btnWidth / 2);
    locAnimation.springBounciness = 5.0f;
    locAnimation.springSpeed = 6.0f;
    locAnimation.name = @"GotoLocation";
    locAnimation.delegate = self;

    // current label color change animation

    POPBasicAnimation* nextColorAnimation = [POPBasicAnimation animation];
    nextColorAnimation.property = [POPAnimatableProperty propertyWithName: kPOPLabelTextColor];
    nextColorAnimation.toValue = _selectionTextColor;
    nextColorAnimation.name = @"nextButtonColorChange";
    nextColorAnimation.delegate = self;

    // next label color change animation

    POPBasicAnimation* currColorAnimation = [POPBasicAnimation animation];
    currColorAnimation.property = [POPAnimatableProperty propertyWithName: kPOPLabelTextColor];
    currColorAnimation.toValue = _nonSelectionTextColor;
    currColorAnimation.name = @"currentButtonColorChange";
    currColorAnimation.delegate = self;

    [_viewSelection pop_addAnimation:locAnimation forKey:locAnimation.name];
    [lblNext setFont:_selectionFont];
    [lblNext pop_addAnimation:nextColorAnimation forKey:nextColorAnimation.name];
    [lblCurrent setFont:_nonSelectionFont];
    [lblCurrent pop_addAnimation:currColorAnimation forKey:currColorAnimation.name];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    isScrollingAnimationActive = NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!isScrollingAnimationActive) {
        CGRect rectViewSelection = _viewSelection.frame;
        rectViewSelection.origin.x = scrollView.contentOffset.x / _titles.count;
        [_viewSelection setFrame:rectViewSelection];

        if (scrollView.contentOffset.x >= 0 && scrollView.contentOffset.x <= scrollView.contentSize.width) {
            [self rearrangeRelatedButtonColor:scrollView.contentOffset.x];
        }

        lastContentX = _scrollViewContent.contentOffset.x;
    }

    _currentIndex = roundf(_scrollViewContent.contentOffset.x / scrollView.frame.size.width);
}

- (void)rearrangeRelatedButtonColor:(float)contentOffsetX
{
    float locationIndex = contentOffsetX / _scrollViewContent.frame.size.width;
    float ratio = fmodf(locationIndex, 1);

    int prevIndex = floor(locationIndex);
    int nextIndex = ceil(locationIndex);

    if (prevIndex == nextIndex) {
        return;
    }

    UILabel* lblPrev;
    UILabel* lblNext;

    if (prevIndex >= 0) {
        lblPrev = [_arrayTitleLabels objectAtIndex:prevIndex];
    }

    if (nextIndex < _arrayTitleLabels.count) {
        lblNext = [_arrayTitleLabels objectAtIndex:nextIndex];
    }

    // TODO: find a better and generic way to set colors

    if (lblPrev) {
        CGFloat pRed, pGreen, pBlue;

        pRed = (textSelRed - textNonSelRed) * ratio + textNonSelRed;
        pGreen = (textSelGreen - textNonSelGreen) * ratio + textNonSelGreen;
        pBlue = (textSelBlue - textNonSelBlue) * ratio + textNonSelBlue;

        [lblPrev setTextColor:[UIColor colorWithRed:pRed green:pGreen blue:pBlue alpha:1]];
        [lblPrev setFont:_nonSelectionFont];
    }

    if (lblNext) {
        float nRed, nGreen, nBlue;

        nRed = (textNonSelRed - textSelRed) * ratio + textSelRed;
        nGreen = (textNonSelGreen - textSelGreen) * ratio + textSelGreen;
        nBlue = (textNonSelBlue - textSelBlue) * ratio + textSelBlue;

        [lblNext setTextColor:[UIColor colorWithRed:nRed green:nGreen blue:nBlue alpha:1]];
        [lblNext setFont:_selectionFont];
    }
}

- (void)refreshView {
    [self updateScrollViewData];
}

@end
