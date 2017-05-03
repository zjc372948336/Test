//
//  IndexViewController.m
//  SelectedImageDemo
//
//  Created by 张金城 on 2017/5/2.
//  Copyright © 2017年 张金城. All rights reserved.
//

#import "IndexViewController.h"
#import "TZImagePickerController.h"






#define MAX_IMAGE_SELECTED_COUNT 9
#define MAX_IMAGE_COLUMNMNUMBER 4


@interface IndexViewController ()<TZImagePickerControllerDelegate>{
    NSMutableArray *_selectedPhotos;
    NSMutableArray *_selectedAssets;
    BOOL _isSelectedOriginalPhoto;//是否选择原图
}

@end

@implementation IndexViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _selectedPhotos = [NSMutableArray array];
    _selectedAssets = [NSMutableArray array];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)buttonAction:(UIButton *)sender {
    [self pushImagePickerController];
}



-(void)pushImagePickerController{
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:MAX_IMAGE_SELECTED_COUNT columnNumber:MAX_IMAGE_COLUMNMNUMBER delegate:self pushPhotoPickerVc:YES];
//    imagePickerVc.isSelectOriginalPhoto = _isSelectOriginalPhoto;//是否选择原始照片
//    imagePickerVc.allowTakePicture = YES;//显示内部拍照按钮
    imagePickerVc.allowPickingVideo = NO;
    imagePickerVc.allowPickingGif = NO;
    
    
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        
    }];
    
    [self presentViewController:imagePickerVc animated:YES completion:nil];
    
    
    
}



#pragma mark - TZImagePickerControllerDelegate
//-(void)
//
@end

