//
//  LegislatorCell.m
//  Created by Gregory Combs on 8/9/10.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "LegislatorCell.h"
#import "LegislatorCellView.h"
#import "SLFAppearance.h"
#import "SLFLegislator.h"
#import "UIImageView+AFNetworking.h"
#import "UIImageView+RoundedCorners.h"
#import "SLFTheme.h"
#import "UIImageView+SLFLegislator.h"

static CGFloat LegImageWidth = 53.f;

@interface LegislatorCell()
@end

@implementation LegislatorCell
@synthesize legislator = _legislator;
@synthesize cellContentView = _cellContentView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.opaque = YES;
        self.backgroundColor = [SLFAppearance cellBackgroundLightColor];
        CGRect tzvFrame = CGRectMake(LegImageWidth, 0, self.contentView.bounds.size.width - LegImageWidth, self.contentView.bounds.size.height);
        _cellContentView = [[LegislatorCellView alloc] initWithFrame:CGRectInset(tzvFrame, 0, 1.0)];
        _cellContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _cellContentView.contentMode = UIViewContentModeRedraw;
        self.imageView.width = LegImageWidth;
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        self.imageView.clipsToBounds = YES;
        self.imageView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:_cellContentView];
    }
    return self;
}

- (void)dealloc
{
    self.legislator = nil;
    self.cellContentView = nil;    
    [super dealloc];
}

- (CGSize)cellSize {
	return _cellContentView.cellSize;
}

- (NSString*)role {
	return _cellContentView.role;
}

- (void)setRole:(NSString *)value {
	_cellContentView.role = value;
}

- (void)setGenericName:(NSString *)genericName {
    _cellContentView.genericName = genericName;
}

- (NSString *)genericName {
    return _cellContentView.genericName;
}

- (void)setHighlighted:(BOOL)val animated:(BOOL)animated {
	[super setHighlighted:val animated:animated];
	_cellContentView.highlighted = val;
}

- (void)setSelected:(BOOL)val animated:(BOOL)animated {
	[super setHighlighted:val animated:animated];
	_cellContentView.highlighted = val;
}

- (void)setLegislator:(SLFLegislator *)value {
    SLFRelease(_legislator);
    _legislator = [value retain]; // shouldn't really retain, we don't need to keep it around except mapping fails.
    [self.imageView setImageWithLegislator:value];
	[_cellContentView setLegislator:value];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.width = LegImageWidth;
    [_cellContentView setNeedsDisplay];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    self.imageView.backgroundColor = backgroundColor;
    [self.imageView setNeedsDisplay];
    if (_cellContentView.highlighted)
        return;
    _cellContentView.backgroundColor = backgroundColor;
    [_cellContentView setNeedsDisplay];
}

- (void)setUseDarkBackground:(BOOL)useDarkBackground {
    _cellContentView.useDarkBackground = useDarkBackground;
}

- (BOOL)useDarkBackground {
    return _cellContentView.useDarkBackground;
}

@end

@implementation LegislatorCellMapping
@synthesize roundImageCorners = _roundImageCorners;
@synthesize useAlternatingRowColors = _useAlternatingRowColors;

+ (id)cellMapping {
    return [self mappingForClass:[LegislatorCell class]];
}

- (id)init {
    self = [super init];
    if (self) {
        self.cellClass = [LegislatorCell class];
        self.rowHeight = 73; 
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.roundImageCorners = NO;
        self.useAlternatingRowColors = YES;
        self.reuseIdentifier = nil; // turns off caching, sucky but we don't want to reuse facial photos
		__block __typeof__(self) bself = self;
        self.onCellWillAppearForObjectAtIndexPath = ^(UITableViewCell* cell, id object, NSIndexPath* indexPath) {
            LegislatorCell *legCell = (LegislatorCell *)cell;
            if (bself.roundImageCorners && indexPath.row == 0)
                [cell.imageView roundTopLeftCorner];
            else
                cell.imageView.layer.mask = nil;
            BOOL useDarkBG = NO;
            if (bself.useAlternatingRowColors) {
                useDarkBG = SLFAlternateCellForIndexPath(cell, indexPath);
            }
            [legCell setUseDarkBackground:useDarkBG];
        };
    }
    return self;
}

- (void)addDefaultMappings {
    [self mapKeyPath:@"self" toAttribute:@"legislator"];
}

@end

@implementation FoundLegislatorCellMapping

- (id)init {
    self = [super init];
    if (self) {
        self.roundImageCorners = YES;
        self.useAlternatingRowColors = NO;
    }
    return self;
}

- (void)addDefaultMappings {
    [self mapKeyPath:@"foundLegislator" toAttribute:@"legislator"];
    [self mapKeyPath:@"type" toAttribute:@"role"];
    [self mapKeyPath:@"name" toAttribute:@"genericName"];
}

@end
