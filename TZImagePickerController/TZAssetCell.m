//
//  TZAssetCell.m
//  TZImagePickerController
//
//  Created by 谭真 on 15/12/24.
//  Copyright © 2015年 谭真. All rights reserved.
//

#import "TZAssetCell.h"
#import "TZAssetModel.h"
#import "UIView+Layout.h"
#import "TZImageManager.h"
#import "TZImagePickerController.h"
#import "TZProgressView.h"

@interface TZAssetCell ()
@property (weak, nonatomic) UIImageView *imageView;       // The photo / 照片
@property (weak, nonatomic) UIImageView *selectImageView;
@property (weak, nonatomic) UIView *bottomView;
@property (weak, nonatomic) UILabel *timeLength;

@property (nonatomic, weak) UIImageView *videoImgView;
@property (nonatomic, strong) TZProgressView *progressView;
@property (nonatomic, assign) PHImageRequestID bigImageRequestID;
@end

@implementation TZAssetCell

- (void)setModel:(TZAssetModel *)model {
    _model = model;
    if (iOS8Later) {
        self.representedAssetIdentifier = [[TZImageManager manager] getAssetIdentifier:model.asset];
    }
    PHImageRequestID imageRequestID = [[TZImageManager manager] getPhotoWithAsset:model.asset photoWidth:self.tz_width completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        if (_progressView) {
            self.progressView.hidden = YES;
            self.imageView.alpha = 1.0;
        }
        // Set the cell's thumbnail image if it's still showing the same asset.
        if (!iOS8Later) {
            self.imageView.image = photo;
            return;
        }
        if ([self.representedAssetIdentifier isEqualToString:[[TZImageManager manager] getAssetIdentifier:model.asset]]) {
            self.imageView.image = photo;
        } else {
            // NSLog(@"this cell is showing other asset");
            [[PHImageManager defaultManager] cancelImageRequest:self.imageRequestID];
        }
        if (!isDegraded) {
            self.imageRequestID = 0;
        }
    } progressHandler:nil networkAccessAllowed:NO];
    if (imageRequestID && self.imageRequestID && imageRequestID != self.imageRequestID) {
        [[PHImageManager defaultManager] cancelImageRequest:self.imageRequestID];
        // NSLog(@"cancelImageRequest %d",self.imageRequestID);
    }
    self.imageRequestID = imageRequestID;
    self.selectPhotoButton.selected = model.isSelected;
    self.selectImageView.image = self.selectPhotoButton.isSelected ? [UIImage imageNamedFromMyBundle:self.photoSelImageName] : [UIImage imageNamedFromMyBundle:self.photoDefImageName];
    self.type = (NSInteger)model.type;
    // 让宽度/高度小于 最小可选照片尺寸 的图片不能选中
    if (![[TZImageManager manager] isPhotoSelectableWithAsset:model.asset]) {
        if (_selectImageView.hidden == NO) {
            self.selectPhotoButton.hidden = YES;
            _selectImageView.hidden = YES;
        }
    }
    // 如果用户选中了该图片，提前获取一下大图
    if (model.isSelected) {
        [self fetchBigImage];
    }
}

- (void)setShowSelectBtn:(BOOL)showSelectBtn {//图片选择按钮是否显示
    _showSelectBtn = showSelectBtn;
    if (!self.selectPhotoButton.hidden) {
        self.selectPhotoButton.hidden = !showSelectBtn;
    }
    if (!self.selectImageView.hidden) {
        self.selectImageView.hidden = !showSelectBtn;
    }
}

- (void)setType:(TZAssetCellType)type { //判断是图片视频还是gif
    _type = type;
    if (type == TZAssetCellTypePhoto || type == TZAssetCellTypeLivePhoto || (type == TZAssetCellTypePhotoGif && !self.allowPickingGif)) {
        _selectImageView.hidden = NO;
        _selectPhotoButton.hidden = NO;
        _bottomView.hidden = YES;
    } else { // Video of Gif
        _selectImageView.hidden = YES;
        _selectPhotoButton.hidden = YES;
        _bottomView.hidden = NO;
        if (type == TZAssetCellTypeVideo) {
            self.timeLength.text = _model.timeLength;
            self.videoImgView.hidden = NO;
            _timeLength.tz_left = self.videoImgView.tz_right;
            _timeLength.textAlignment = NSTextAlignmentRight;
        } else {
            self.timeLength.text = @"GIF";
            self.videoImgView.hidden = YES;
            _timeLength.tz_left = 5;
            _timeLength.textAlignment = NSTextAlignmentLeft;
        }
    }
}

- (void)selectPhotoButtonClick:(UIButton *)sender {//图片选择按钮选择
    if (self.didSelectPhotoBlock) {
        self.didSelectPhotoBlock(sender.isSelected);
    }
    self.selectImageView.image = sender.isSelected ? [UIImage imageNamedFromMyBundle:self.photoSelImageName] : [UIImage imageNamedFromMyBundle:self.photoDefImageName];
    if (sender.isSelected) {
        [UIView showOscillatoryAnimationWithLayer:_selectImageView.layer type:TZOscillatoryAnimationToBigger];//选择时的动画
        // 用户选中了该图片，提前获取一下大图
        [self fetchBigImage];
    } else { // 取消选中，取消大图的获取
        if (_bigImageRequestID && _progressView) {
            [[PHImageManager defaultManager] cancelImageRequest:_bigImageRequestID];
            [self hideProgressView];
        }
    }
}

- (void)hideProgressView {
    self.progressView.hidden = YES;
    self.imageView.alpha = 1.0;
}

- (void)fetchBigImage {
    _bigImageRequestID = [[TZImageManager manager] getPhotoWithAsset:_model.asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        if (_progressView) {
            [self hideProgressView];
        }
    } progressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        if (_model.isSelected) {
            progress = progress > 0.02 ? progress : 0.02;;
            self.progressView.progress = progress;
            self.progressView.hidden = NO;
            self.imageView.alpha = 0.4;
        } else {
            *stop = YES;
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        }
    } networkAccessAllowed:YES];
}

#pragma mark - Lazy load

- (UIButton *)selectPhotoButton {
    if (_selectImageView == nil) {
        UIButton *selectPhotoButton = [[UIButton alloc] init];
        selectPhotoButton.frame = CGRectMake(self.tz_width - 30, 0, 30, 30);
        [selectPhotoButton addTarget:self action:@selector(selectPhotoButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:selectPhotoButton];
        _selectPhotoButton = selectPhotoButton;
    }
    return _selectPhotoButton;
}

- (UIImageView *)imageView {
    if (_imageView == nil) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.frame = CGRectMake(0, 0, self.tz_width, self.tz_height);
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [self.contentView addSubview:imageView];
        _imageView = imageView;
        
        [self.contentView bringSubviewToFront:_selectImageView];
        [self.contentView bringSubviewToFront:_bottomView];
    }
    return _imageView;
}

- (UIImageView *)selectImageView {
    if (_selectImageView == nil) {
        UIImageView *selectImageView = [[UIImageView alloc] init];
        selectImageView.frame = CGRectMake(self.tz_width - 27, 0, 27, 27);
        [self.contentView addSubview:selectImageView];
        _selectImageView = selectImageView;
    }
    return _selectImageView;
}

- (UIView *)bottomView {//如果是视频地下那条
    if (_bottomView == nil) {
        UIView *bottomView = [[UIView alloc] init];
        bottomView.frame = CGRectMake(0, self.tz_height - 17, self.tz_width, 17);
        static NSInteger rgb = 0;
        bottomView.backgroundColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:0.8];
        [self.contentView addSubview:bottomView];
        _bottomView = bottomView;
    }
    return _bottomView;
}

- (UIImageView *)videoImgView {//视频图片
    if (_videoImgView == nil) {
        UIImageView *videoImgView = [[UIImageView alloc] init];
        videoImgView.frame = CGRectMake(8, 0, 17, 17);
        [videoImgView setImage:[UIImage imageNamedFromMyBundle:@"VideoSendIcon.png"]];
        [self.bottomView addSubview:videoImgView];
        _videoImgView = videoImgView;
    }
    return _videoImgView;
}

- (UILabel *)timeLength {//视频时间长度
    if (_timeLength == nil) {
        UILabel *timeLength = [[UILabel alloc] init];
        timeLength.font = [UIFont boldSystemFontOfSize:11];
        timeLength.frame = CGRectMake(self.videoImgView.tz_right, 0, self.tz_width - self.videoImgView.tz_right - 5, 17);
        timeLength.textColor = [UIColor whiteColor];
        timeLength.textAlignment = NSTextAlignmentRight;
        [self.bottomView addSubview:timeLength];
        _timeLength = timeLength;
    }
    return _timeLength;
}

- (TZProgressView *)progressView {
    if (_progressView == nil) {
        _progressView = [[TZProgressView alloc] init];
        static CGFloat progressWH = 20;
        CGFloat progressXY = (self.tz_width - progressWH) / 2;
        _progressView.hidden = YES;
        _progressView.frame = CGRectMake(progressXY, progressXY, progressWH, progressWH);
        [self addSubview:_progressView];
    }
    return _progressView;
}

@end

@interface TZAlbumCell ()
@property (weak, nonatomic) UIImageView *posterImageView;
@property (weak, nonatomic) UILabel *titleLabel;
@property (weak, nonatomic) UIImageView *arrowImageView;
@end

@implementation TZAlbumCell

- (void)setModel:(TZAlbumModel *)model {
    _model = model;
    
    NSMutableAttributedString *nameString = [[NSMutableAttributedString alloc] initWithString:model.name attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16],NSForegroundColorAttributeName:[UIColor blackColor]}];
    NSAttributedString *countString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"  (%zd)",model.count] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16],NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
    [nameString appendAttributedString:countString];
    self.titleLabel.attributedText = nameString;
    NSLog(@"%@",self.titleLabel.text);
    [[TZImageManager manager] getPostImageWithAlbumModel:model completion:^(UIImage *postImage) {
        self.posterImageView.image = postImage;
    }];
    if (model.selectedCount) {
        self.selectedCountButton.hidden = NO;
        [self.selectedCountButton setTitle:[NSString stringWithFormat:@"%zd",model.selectedCount] forState:UIControlStateNormal];
    } else {
        self.selectedCountButton.hidden = YES;
    }
}

/// For fitting iOS6
- (void)layoutSubviews {
    if (iOS7Later) [super layoutSubviews];
    _selectedCountButton.frame = CGRectMake(self.tz_width - 24 - 30, 23, 24, 24);
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {
    if (iOS7Later) [super layoutSublayersOfLayer:layer];
}

#pragma mark - Lazy load

- (UIImageView *)posterImageView {
    if (_posterImageView == nil) {
        UIImageView *posterImageView = [[UIImageView alloc] init];
        posterImageView.contentMode = UIViewContentModeScaleAspectFill;
        posterImageView.clipsToBounds = YES;
        posterImageView.frame = CGRectMake(0, 0, 70, 70);
        [self.contentView addSubview:posterImageView];
        _posterImageView = posterImageView;
    }
    return _posterImageView;
}

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.font = [UIFont boldSystemFontOfSize:17];
        titleLabel.frame = CGRectMake(80, 0, self.tz_width - 80 - 50, self.tz_height);
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:titleLabel];
        _titleLabel = titleLabel;
    }
    return _titleLabel;
}

- (UIImageView *)arrowImageView {
    if (_arrowImageView == nil) {
        UIImageView *arrowImageView = [[UIImageView alloc] init];
        CGFloat arrowWH = 15;
        arrowImageView.frame = CGRectMake(self.tz_width - arrowWH - 12, 28, arrowWH, arrowWH);
        [arrowImageView setImage:[UIImage imageNamedFromMyBundle:@"TableViewArrow.png"]];
        [self.contentView addSubview:arrowImageView];
        _arrowImageView = arrowImageView;
    }
    return _arrowImageView;
}

- (UIButton *)selectedCountButton {
    if (_selectedCountButton == nil) {
        UIButton *selectedCountButton = [[UIButton alloc] init];
        selectedCountButton.layer.cornerRadius = 12;
        selectedCountButton.clipsToBounds = YES;
        selectedCountButton.backgroundColor = [UIColor redColor];
        [selectedCountButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        selectedCountButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:selectedCountButton];
        _selectedCountButton = selectedCountButton;
    }
    return _selectedCountButton;
}

@end



@implementation TZAssetCameraCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        _imageView = [[UIImageView alloc] init];
        _imageView.backgroundColor = [UIColor colorWithWhite:1.000 alpha:0.500];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_imageView];
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _imageView.frame = self.bounds;
}
@end


@implementation TZRightPicCell

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame: frame];
    CGFloat width = (frame.size.width-5)/2;
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        _firstImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, width )];
        _secondImageView = [[UIImageView alloc] initWithFrame:CGRectMake(width + 5, 0, width, width)];
        _thirdImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, width + 5, width, width)];
        _fourtImageView = [[UIImageView alloc] initWithFrame:CGRectMake(width + 5, width+ 5, width, width)];
        _firstImageView.backgroundColor = [UIColor colorWithWhite:1.000 alpha:0.500];
        _secondImageView.backgroundColor = [UIColor colorWithWhite:1.000 alpha:0.500];
        _thirdImageView.backgroundColor = [UIColor colorWithWhite:1.000 alpha:0.500];
        _fourtImageView.backgroundColor = [UIColor colorWithWhite:1.000 alpha:0.500];
        
        
        _firstBtn = [[UIButton alloc] initWithFrame:CGRectMake(width - 30, 0, 30, 30)];
        _secondBtn = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width - 30, 0, 30, 30)];
        _thirdBtn = [[UIButton alloc] initWithFrame:CGRectMake(width - 30, width + 5, 30, 30)];
        _fourtBtn = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width - 30, width + 5, 30, 30)];
        
        [_firstBtn addTarget:self action:@selector(selectedAction:) forControlEvents:UIControlEventTouchDown];
        [_secondBtn addTarget:self action:@selector(selectedAction:) forControlEvents:UIControlEventTouchDown];
        [_thirdBtn addTarget:self action:@selector(selectedAction:) forControlEvents:UIControlEventTouchDown];
        [_fourtBtn addTarget:self action:@selector(selectedAction:) forControlEvents:UIControlEventTouchDown];
        
        _firstSelectedImage = [[UIImageView alloc] initWithFrame:CGRectMake(width - 27, 0, 27, 27)];
        _secondSelectedImage = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width - 27, 0, 27, 27)];
        _thirdSelectedImage = [[UIImageView alloc] initWithFrame:CGRectMake(width - 27, width + 5, 27, 27)];
        _fourtSelectedImage = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width - 27, width + 5, 27, 27)];
        
        _firstImageBtn = [[UIButton alloc] initWithFrame:self.firstImageView.frame];
        _secondImageBtn = [[UIButton alloc] initWithFrame:self.secondImageView.frame];
        _thirdImageBtn = [[UIButton alloc] initWithFrame:self.thirdImageView.frame];
        _fourtImageBtn = [[UIButton alloc] initWithFrame:self.fourtImageView.frame];
        [_firstImageBtn addTarget:self action:@selector(imageSelectedAction:) forControlEvents:UIControlEventTouchDown];
        [_secondImageBtn addTarget:self action:@selector(imageSelectedAction:) forControlEvents:UIControlEventTouchDown];
        [_thirdImageBtn addTarget:self action:@selector(imageSelectedAction:) forControlEvents:UIControlEventTouchDown];
        [_fourtImageBtn addTarget:self action:@selector(imageSelectedAction:) forControlEvents:UIControlEventTouchDown];
        
        
        
        [self addSubview:_firstImageView];
        [self addSubview:_secondImageView];
        [self addSubview:_thirdImageView];
        [self addSubview:_fourtImageView];
        [self addSubview:_firstImageBtn];
        [self addSubview:_secondImageBtn];
        [self addSubview:_thirdImageBtn];
        [self addSubview:_fourtImageBtn];
        [self addSubview:_firstBtn];
        [self addSubview:_secondBtn];
        [self addSubview:_thirdBtn];
        [self addSubview:_fourtBtn];
        [self addSubview:_firstSelectedImage];
        [self addSubview:_secondSelectedImage];
        [self addSubview:_thirdSelectedImage];
        [self addSubview:_fourtSelectedImage];
    }
    return self;
}

-(void)setModelArray:(NSArray *)modelArray{
    _modelArray = modelArray;
    self.representedAssetIdentifierArray = [[NSMutableArray alloc] init];
    self.bigImageRequestIDArray = [[NSMutableArray alloc] init];
    
    for (int k = 0; k < modelArray.count; k++) {
        NSString *representedAssetIdentifier = [[TZImageManager manager] getAssetIdentifier:((TZAssetModel *)[_modelArray objectAtIndex:k]).asset];
        if (iOS8Later) {
            [self.representedAssetIdentifierArray addObject:representedAssetIdentifier];
        }
        PHImageRequestID imageRequestID = [[TZImageManager manager] getPhotoWithAsset:((TZAssetModel *)[_modelArray objectAtIndex:k]).asset photoWidth:self.firstImageView.frame.size.width completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
            if (!iOS8Later) {
                switch (k) {
                    case 0:{
                        self.firstImageView.image = photo;
                    }
                        break;
                    case 1:{
                        self.secondImageView.image = photo;
                    }
                        break;
                    case 2:{
                        self.thirdImageView.image = photo;
                    }
                        break;
                    case 3:{
                        self.fourtImageView.image = photo;
                    }
                        break;
                    default:
                        break;
                }
                
                
//                self.imageView.image = photo;
                return;
            }
            if ([[self.representedAssetIdentifierArray objectAtIndex:k] isEqualToString:[[TZImageManager manager] getAssetIdentifier:((TZAssetModel *)[_modelArray objectAtIndex:k]).asset]]) {
                switch (k) {
                    case 0:{
                        self.firstImageView.image = photo;
                    }
                        break;
                    case 1:{
                        self.secondImageView.image = photo;
                    }
                        break;
                    case 2:{
                        self.thirdImageView.image = photo;
                    }
                        break;
                    case 3:{
                        self.fourtImageView.image = photo;
                    }
                        break;
                    default:
                        break;
                }
            } else {
                // NSLog(@"this cell is showing other asset");
//                [[PHImageManager defaultManager] cancelImageRequest:self.imageRequestID];
            }
            
//            self.selectImageView.image = self.selectPhotoButton.isSelected ? [UIImage imageNamedFromMyBundle:self.photoSelImageName] : [UIImage imageNamedFromMyBundle:self.photoDefImageName];
            switch (k) {
                case 0:{
                    self.firstBtn.selected = ((TZAssetModel *)[_modelArray objectAtIndex:k]).isSelected;
                    self.firstSelectedImage.image = self.firstBtn.selected ? [UIImage imageNamedFromMyBundle:self.photoSelImageName] : [UIImage imageNamedFromMyBundle:self.photoDefImageName];
                    }
                    break;
                case 1:{
                    self.secondBtn.selected = ((TZAssetModel *)[_modelArray objectAtIndex:k]).isSelected;
                    self.secondSelectedImage.image = self.secondBtn.selected ? [UIImage imageNamedFromMyBundle:self.photoSelImageName] : [UIImage imageNamedFromMyBundle:self.photoDefImageName];
                }
                    break;
                case 2:{
                    self.thirdBtn.selected = ((TZAssetModel *)[_modelArray objectAtIndex:k]).isSelected;
                    self.thirdSelectedImage.image = self.thirdBtn.selected ? [UIImage imageNamedFromMyBundle:self.photoSelImageName] : [UIImage imageNamedFromMyBundle:self.photoDefImageName];
                }
                    break;
                case 3:{
                    self.fourtBtn.selected = ((TZAssetModel *)[_modelArray objectAtIndex:k]).isSelected;
                    self.fourtSelectedImage.image = self.fourtBtn.selected ? [UIImage imageNamedFromMyBundle:self.photoSelImageName] : [UIImage imageNamedFromMyBundle:self.photoDefImageName];
                }
                    break;
                default:
                    break;
            }
            
            
            
        } progressHandler:nil networkAccessAllowed:NO];
    }
}

-(void)selectedAction:(UIButton *)sender{
    if (sender == self.firstBtn) {
        [self.delegate didSelectPhoto:sender.selected withTZRightPicCell:self andIndex:0];
        
        
        self.firstSelectedImage.image = sender.isSelected ? [UIImage imageNamedFromMyBundle:self.photoSelImageName] : [UIImage imageNamedFromMyBundle:self.photoDefImageName];
        if (sender.isSelected) {
            [UIView showOscillatoryAnimationWithLayer:_firstSelectedImage.layer type:TZOscillatoryAnimationToBigger];//选择时的动画
            // 用户选中了该图片，提前获取一下大图
//            [self fetchBigImage];
        } else { // 取消选中，取消大图的获取
//            if (_bigImageRequestID && _progressView) {
//                [[PHImageManager defaultManager] cancelImageRequest:_bigImageRequestID];
//                [self hideProgressView];
//            }
        }
    }
    if (sender == self.secondBtn) {
        [self.delegate didSelectPhoto:sender.selected withTZRightPicCell:self andIndex:1];
        self.secondSelectedImage.image = sender.isSelected ? [UIImage imageNamedFromMyBundle:self.photoSelImageName] : [UIImage imageNamedFromMyBundle:self.photoDefImageName];
        if (sender.isSelected) {
            [UIView showOscillatoryAnimationWithLayer:_secondSelectedImage.layer type:TZOscillatoryAnimationToBigger];//选择时的动画
            // 用户选中了该图片，提前获取一下大图
            //            [self fetchBigImage];
        } else { // 取消选中，取消大图的获取
            //            if (_bigImageRequestID && _progressView) {
            //                [[PHImageManager defaultManager] cancelImageRequest:_bigImageRequestID];
            //                [self hideProgressView];
            //            }
        }
    }
    if (sender == self.thirdBtn) {
        [self.delegate didSelectPhoto:sender.selected withTZRightPicCell:self andIndex:2];
        self.thirdSelectedImage.image = sender.isSelected ? [UIImage imageNamedFromMyBundle:self.photoSelImageName] : [UIImage imageNamedFromMyBundle:self.photoDefImageName];
        if (sender.isSelected) {
            [UIView showOscillatoryAnimationWithLayer:_thirdSelectedImage.layer type:TZOscillatoryAnimationToBigger];//选择时的动画
            // 用户选中了该图片，提前获取一下大图
            //            [self fetchBigImage];
        } else { // 取消选中，取消大图的获取
            //            if (_bigImageRequestID && _progressView) {
            //                [[PHImageManager defaultManager] cancelImageRequest:_bigImageRequestID];
            //                [self hideProgressView];
            //            }
        }
    }
    if (sender == self.fourtBtn) {
        [self.delegate didSelectPhoto:sender.selected withTZRightPicCell:self andIndex:3];
        self.fourtSelectedImage.image = sender.isSelected ? [UIImage imageNamedFromMyBundle:self.photoSelImageName] : [UIImage imageNamedFromMyBundle:self.photoDefImageName];
        if (sender.isSelected) {
            [UIView showOscillatoryAnimationWithLayer:_fourtSelectedImage.layer type:TZOscillatoryAnimationToBigger];//选择时的动画
            // 用户选中了该图片，提前获取一下大图
            //            [self fetchBigImage];
        } else { // 取消选中，取消大图的获取
            //            if (_bigImageRequestID && _progressView) {
            //                [[PHImageManager defaultManager] cancelImageRequest:_bigImageRequestID];
            //                [self hideProgressView];
            //            }
        }
    }
}
//点击图片
-(void)imageSelectedAction:(UIButton *)sender{
    if(sender == self.firstImageBtn){
        [self.delegate imageSelectedWithIndex:0];
    }
    if(sender == self.secondImageBtn){
        [self.delegate imageSelectedWithIndex:1];
    }
    if(sender == self.thirdImageBtn){
        [self.delegate imageSelectedWithIndex:2];
    }
    if(sender == self.fourtImageBtn){
        [self.delegate imageSelectedWithIndex:3];
    }
    
}

@end



@interface TZShowCell()

@end

@implementation TZShowCell
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame: frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(8, 8, frame.size.width - 16, frame.size.width - 16)];
        _imageView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_imageView];
        
//        _imageBtn = [[UIButton alloc] initWithFrame:_imageView.frame];
//        [self addSubview:_imageBtn];
        
        _deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
        [_deleteBtn addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchDown];
        _deleteBtn.backgroundColor = [UIColor redColor];
        [self addSubview:_deleteBtn];
    }
    return self;
}

- (void)setModel:(TZAssetModel *)model {
    _model = model;
    if (iOS8Later) {
        self.representedAssetIdentifier = [[TZImageManager manager] getAssetIdentifier:model.asset];
    }
    PHImageRequestID imageRequestID = [[TZImageManager manager] getPhotoWithAsset:model.asset photoWidth:self.tz_width completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        // Set the cell's thumbnail image if it's still showing the same asset.
        if (!iOS8Later) {
            self.imageView.image = photo;
            return;
        }
        if ([self.representedAssetIdentifier isEqualToString:[[TZImageManager manager] getAssetIdentifier:model.asset]]) {
            self.imageView.image = photo;
        } else {
            // NSLog(@"this cell is showing other asset");
            [[PHImageManager defaultManager] cancelImageRequest:self.imageRequestID];
        }
        if (!isDegraded) {
            self.imageRequestID = 0;
        }
    } progressHandler:nil networkAccessAllowed:NO];
    if (imageRequestID && self.imageRequestID && imageRequestID != self.imageRequestID) {
        [[PHImageManager defaultManager] cancelImageRequest:self.imageRequestID];
        // NSLog(@"cancelImageRequest %d",self.imageRequestID);
    }
    self.imageRequestID = imageRequestID;
}



-(void)deleteAction:(UIButton *)sender{
    NSLog(@"shangchu");
    [self.delegate deleteSelectedImage:sender.tag];
}


@end
