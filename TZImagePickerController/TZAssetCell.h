//
//  TZAssetCell.h
//  TZImagePickerController
//
//  Created by 谭真 on 15/12/24.
//  Copyright © 2015年 谭真. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

typedef enum : NSUInteger {
    TZAssetCellTypePhoto = 0,
    TZAssetCellTypeLivePhoto,
    TZAssetCellTypePhotoGif,
    TZAssetCellTypeVideo,
    TZAssetCellTypeAudio,
} TZAssetCellType;

@class TZAssetModel;
@interface TZAssetCell : UICollectionViewCell

@property (weak, nonatomic) UIButton *selectPhotoButton;
@property (nonatomic, strong) TZAssetModel *model;
@property (nonatomic, copy) void (^didSelectPhotoBlock)(BOOL);
@property (nonatomic, assign) TZAssetCellType type;
@property (nonatomic, assign) BOOL allowPickingGif;
@property (nonatomic, copy) NSString *representedAssetIdentifier;
@property (nonatomic, assign) PHImageRequestID imageRequestID;

@property (nonatomic, copy) NSString *photoSelImageName;
@property (nonatomic, copy) NSString *photoDefImageName;

@property (nonatomic, assign) BOOL showSelectBtn;

@end


@class TZAlbumModel;

@interface TZAlbumCell : UITableViewCell

@property (nonatomic, strong) TZAlbumModel *model;
@property (weak, nonatomic) UIButton *selectedCountButton;

@end


@interface TZAssetCameraCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;

@end

@protocol TZRightPicCellDelegate <NSObject>

-(void)didSelectPhoto:(BOOL)isSelected withTZRightPicCell:(UICollectionViewCell *)cell andIndex:(NSInteger)index;
-(void)imageSelectedWithIndex:(NSInteger)index;

@end
@interface TZRightPicCell : UICollectionViewCell

@property (nonatomic, copy) NSString *photoSelImageName;//选中时有颜色的图片
@property (nonatomic, copy) NSString *photoDefImageName;//未来选中时
@property (nonatomic, copy) NSArray *modelArray;//图像数组
@property (nonatomic, assign) BOOL showSelectBtn;//是否显示选择按钮
@property (nonatomic, strong) NSMutableArray *representedAssetIdentifierArray;
@property (nonatomic, strong) NSMutableArray *imageRequestIDArray;
@property (nonatomic, strong) NSMutableArray *bigImageRequestIDArray;

@property (nonatomic, weak) id<TZRightPicCellDelegate> delegate;


@property (nonatomic, strong) UIButton *firstBtn;
@property (nonatomic, strong) UIButton *secondBtn;
@property (nonatomic, strong) UIButton *thirdBtn;
@property (nonatomic, strong) UIButton *fourtBtn;

@property (nonatomic, strong) UIButton *firstImageBtn;
@property (nonatomic, strong) UIButton *secondImageBtn;
@property (nonatomic, strong) UIButton *thirdImageBtn;
@property (nonatomic, strong) UIButton *fourtImageBtn;

@property (nonatomic, strong) UIImageView *firstSelectedImage;
@property (nonatomic, strong) UIImageView *secondSelectedImage;
@property (nonatomic, strong) UIImageView *thirdSelectedImage;
@property (nonatomic, strong) UIImageView *fourtSelectedImage;


@property (nonatomic, strong) UIImageView *firstImageView;
@property (nonatomic, strong) UIImageView *secondImageView;
@property (nonatomic, strong) UIImageView *thirdImageView;
@property (nonatomic, strong) UIImageView *fourtImageView;

@end

@protocol TZShowCellDelegate <NSObject>

-(void)deleteSelectedImage:(NSInteger)index;

@end

@interface TZShowCell : UICollectionViewCell
@property (nonatomic, strong) UIButton *deleteBtn;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) TZAssetModel *model;
@property (nonatomic, copy) NSString *representedAssetIdentifier;
@property (nonatomic, assign) PHImageRequestID imageRequestID;
@property (nonatomic, weak) id<TZShowCellDelegate> delegate;


@end


