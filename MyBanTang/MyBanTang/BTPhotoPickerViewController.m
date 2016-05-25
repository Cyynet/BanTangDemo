//
//  BTPhotoPickerViewController.m
//  MyBanTang
//
//  Created by zhangjing on 16/5/25.
//  Copyright © 2016年 ZhangJing. All rights reserved.
//

#import "BTPhotoPickerViewController.h"
#import "AJPhotoPickerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "AJPhotoBrowserViewController.h"

@interface BTPhotoPickerViewController () <AJPhotoPickerProtocol,AJPhotoBrowserDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (strong, nonatomic) NSMutableArray *photos;
@end

@implementation BTPhotoPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  AJPhotoPickerViewController *picker = [[AJPhotoPickerViewController alloc] init];
  picker.maximumNumberOfSelection = 15;
  picker.multipleSelection = YES;
  picker.assetsFilter = [ALAssetsFilter allPhotos];
  picker.showEmptyGroups = YES;
  picker.delegate=self;
  picker.selectionFilter = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
    return YES;
  }];
  [self presentViewController:picker animated:YES completion:^{
    self.tabBarController.selectedIndex = 0;
  }];
}

#pragma mark - BoPhotoPickerProtocol
- (void)photoPickerDidCancel:(AJPhotoPickerViewController *)picker {
  [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)photoPicker:(AJPhotoPickerViewController *)picker didSelectAssets:(NSArray *)assets {
  [self.photos addObjectsFromArray:assets];
  [picker dismissViewControllerAnimated:NO completion:nil];
  
  //显示预览
  //    AJPhotoBrowserViewController *photoBrowserViewController = [[AJPhotoBrowserViewController alloc] initWithPhotos:assets];
  //    photoBrowserViewController.delegate = self;
  //    [self presentViewController:photoBrowserViewController animated:YES completion:nil];
  
}

- (void)photoPicker:(AJPhotoPickerViewController *)picker didSelectAsset:(ALAsset *)asset {
  NSLog(@"%s",__func__);
}

- (void)photoPicker:(AJPhotoPickerViewController *)picker didDeselectAsset:(ALAsset *)asset {
  NSLog(@"%s",__func__);
}

//超过最大选择项时
- (void)photoPickerDidMaximum:(AJPhotoPickerViewController *)picker {
  NSLog(@"%s",__func__);
}

//低于最低选择项时
- (void)photoPickerDidMinimum:(AJPhotoPickerViewController *)picker {
  NSLog(@"%s",__func__);
}

- (void)photoPickerTapCameraAction:(AJPhotoPickerViewController *)picker {
  [self checkCameraAvailability:^(BOOL auth) {
    if (!auth) {
      NSLog(@"没有访问相机权限");
      return;
    }
    
    [picker dismissViewControllerAnimated:NO completion:nil];
    UIImagePickerController *cameraUI = [UIImagePickerController new];
    cameraUI.allowsEditing = NO;
    cameraUI.delegate = self;
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    cameraUI.cameraFlashMode=UIImagePickerControllerCameraFlashModeAuto;
    
    [self presentViewController: cameraUI animated: YES completion:nil];
  }];
}

#pragma mark - AJPhotoBrowserDelegate

- (void)photoBrowser:(AJPhotoBrowserViewController *)vc deleteWithIndex:(NSInteger)index {
  NSLog(@"%s",__func__);
}

- (void)photoBrowser:(AJPhotoBrowserViewController *)vc didDonePhotos:(NSArray *)photos {
  
  [vc dismissViewControllerAnimated:YES completion:nil];
}

- (void)showBig:(UITapGestureRecognizer *)sender {
  NSInteger index = sender.view.tag;
  AJPhotoBrowserViewController *photoBrowserViewController = [[AJPhotoBrowserViewController alloc] initWithPhotos:self.photos index:index];
  photoBrowserViewController.delegate = self;
  [self presentViewController:photoBrowserViewController animated:YES completion:nil];}

#pragma mark - UIImagePickerDelegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *) picker {
  [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)image:(UIImage*)image didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo {
  if (!error) {
    NSLog(@"保存到相册成功");
  }else{
    NSLog(@"保存到相册出错%@", error);
  }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
  NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
  UIImage *originalImage;
  if (CFStringCompare((CFStringRef) mediaType,kUTTypeImage, 0)== kCFCompareEqualTo) {
    originalImage = (UIImage *) [info objectForKey:UIImagePickerControllerOriginalImage];
  }
  
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
  [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)checkCameraAvailability:(void (^)(BOOL auth))block {
  BOOL status = NO;
  AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
  if(authStatus == AVAuthorizationStatusAuthorized) {
    status = YES;
  } else if (authStatus == AVAuthorizationStatusDenied) {
    status = NO;
  } else if (authStatus == AVAuthorizationStatusRestricted) {
    status = NO;
  } else if (authStatus == AVAuthorizationStatusNotDetermined) {
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
      if(granted){
        if (block) {
          block(granted);
        }
      } else {
        if (block) {
          block(granted);
        }
      }
    }];
    return;
  }
  if (block) {
    block(status);
  }
}

@end
