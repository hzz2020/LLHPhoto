#import "UIVCPhoto.h"
#import "PhotoCell.h"
#import "UIVCPhotoBrowser.h"

static NSString *const cellId = @"cellId";
static NSString *const headerId = @"headerId";
static NSString *const footerId = @"footerId";

@interface UIVCPhoto () <UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout> {
    UICollectionView *collectView;
    UIButton *editButton;
    UIButton *deleteButton;
    UIButton *saveButton;
    
    
    NSMutableArray *allDatas;
    NSMutableArray *sectionTitles;
    NSMutableArray *checkTitles;
    NSMutableArray *deleteArray;
    
    NSMutableArray *reusableHeaderArray;
    BOOL isEdit;
}

@end

@implementation UIVCPhoto

- (void)viewDidLoad {
    [super viewDidLoad];
    /* datas init */
    allDatas = [NSMutableArray array];
    sectionTitles = [NSMutableArray array];
    
    checkTitles = [NSMutableArray array];
    deleteArray = [NSMutableArray array];
    reusableHeaderArray = [NSMutableArray array];
    
    
    self.navigationItem.title = @"自定义相册";
    /* 底部编辑View */
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-40, SCREEN_WIDTH, 40)];
    bottomView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottomView];
    // 分隔线
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SINGLE_LINE_WIDTH)];
    lineView.backgroundColor = [UIColor commonLineColor];
    [bottomView addSubview:lineView];
    // 删除按钮
    deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 5, 80, 30)];
    [deleteButton setImage:[UIImage imageNamed:@"PersonalPhotoDelete"] forState:UIControlStateNormal];
    [deleteButton addTarget:self action:@selector(clickToDelete) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:deleteButton];
    // 保存按钮
    saveButton = [[UIButton alloc] initWithFrame:CGRectMake(bottomView.frame.size.width/2-50, 0, 100, bottomView.frame.size.height)];
    [saveButton setTitle:@"保存" forState:UIControlStateNormal];
    [saveButton setTitleColor:[UIColor commonTextBlueColor] forState:UIControlStateNormal];
    [saveButton.titleLabel setFont:[UIFont systemFontOfSize:17]];
    [saveButton addTarget:self action:@selector(savePhotoToAlumb) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:saveButton];
    // 编辑按钮
    editButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-80, 0, 80, 40)];
    [editButton setTitle:@"选择" forState:UIControlStateNormal];
    [editButton setTitleColor:[UIColor commonTextBlueColor] forState:UIControlStateNormal];
    [editButton.titleLabel setFont: [UIFont systemFontOfSize:17]];
    [editButton addTarget:self action:@selector(clickToEdit) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:editButton];
    
    /* UICollectionView */
    collectView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT-64-40) collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
    collectView.showsHorizontalScrollIndicator = NO;
    collectView.showsVerticalScrollIndicator = NO;
    collectView.backgroundColor = [UIColor whiteColor];
    collectView.decelerationRate = UIScrollViewDecelerationRateFast;
    collectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    collectView.allowsMultipleSelection = YES;
    collectView.dataSource = self;
    collectView.delegate = self;
    [self.view addSubview:collectView];
    // 注册cell、sectionHeader、sectionFooter
    [collectView registerClass:[PhotoCell class] forCellWithReuseIdentifier:cellId];
    [collectView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerId];
    [collectView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:footerId];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self viewComeIn];
}

-(void)viewComeIn {
    dispatch_async(dispatch_get_main_queue(), ^{
        isEdit = NO;
        [deleteButton setImage:nil forState:UIControlStateNormal];
        [saveButton setTitle:@"" forState:UIControlStateNormal];
        
        [editButton setTitle:@"选择" forState:UIControlStateNormal];
        
        [self loadDataFromDataBase];
        
        [collectView reloadData];
        
        if (allDatas.count==0) {
            editButton.hidden = YES;
        } else {
            editButton.hidden = NO;
        }
    });
}

#pragma mark - 加载数据
- (void)loadDataFromDataBase {
    // 初始化数据
    [allDatas removeAllObjects];
    [sectionTitles removeAllObjects];
    // 筛选数据并按要求排序
    NSArray *screenFiles = [self filterSortData:@"screenPrint" withType:@".jpeg"];
    for (int i=0; i<screenFiles.count; i++) {
        NSString *fileName = screenFiles[i];
        NSString *timeStr = [self stringFromStringToYYYYMMDD:fileName];
        if ([sectionTitles containsObject:timeStr] == NO) { // 不存在此数据
            NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:1];
            [sectionTitles addObject:timeStr];
            [tempArray addObject:fileName];
            [allDatas addObject:tempArray];
        }
        else // 存在数据
        {
            NSUInteger atIndex = [sectionTitles indexOfObject:timeStr];
            NSMutableArray *tempArray = [NSMutableArray arrayWithArray:allDatas[atIndex]];
            [tempArray addObject:fileName];
            [allDatas replaceObjectAtIndex:atIndex withObject:tempArray];
        }
    }
    
	[self loadDataDeleteArray];
}

// 过滤数据、排序数据
- (NSArray *)filterSortData:(NSString *)string withType:(NSString *)type {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:10];
    NSString *screenPath = [DOCUMENTPATH stringByAppendingPathComponent:string];
    NSArray *files = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:screenPath error:nil];
    for (int i=0; i < files.count; i++) {
        NSString *name = files[i]; // 格式为 fromxxxx_toxxxx_1234567890.jpeg
        NSArray *components = [name componentsSeparatedByString:@"_"];
        // 过滤数据①
        if (components.count<3) { continue; }
        // 过滤数据② 包含 myIdentifier 并且以.jpeg结尾的文件
        if (([name rangeOfString:myIdentifier].location != NSNotFound) && [name hasSuffix:type]) {
            [result addObject:name];
        }
    }
    // 按 时间戳 降序
    [result sortUsingComparator:^NSComparisonResult(__strong NSString *obj1, __strong NSString *obj2) {
        NSArray *components1 = [obj1 componentsSeparatedByString:@"_"];
        NSArray *components2 = [obj2 componentsSeparatedByString:@"_"];
        return [components1[2] doubleValue] < [components2[2] doubleValue];
    }];
    NSLog(@"result = %@", result);
    return [result copy];
}

// 时间戳转为YYYY-MM-DD
- (NSString *)stringFromStringToYYYYMMDD:(NSString *)name {
    NSArray *components = [name componentsSeparatedByString:@"_"];
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy-MM-dd";
    NSString *timeStr = [fmt stringFromDate:[NSDate dateWithTimeIntervalSince1970:[components[2] doubleValue]]];
    return timeStr;
}


- (void)loadDataDeleteArray {
    [deleteArray removeAllObjects];
    [checkTitles removeAllObjects];
    [reusableHeaderArray removeAllObjects];
    for (int i=0; i<sectionTitles.count; i++) {
        NSString *all = @"全选";
        [checkTitles addObject:all];//全选
        [deleteArray addObject:[NSNull null]];
        [reusableHeaderArray addObject:[NSNull null]];
    }
}


- (void)updateSelectionLabel:(NSInteger)section {
    
    BOOL allEnabledPhotosSelected = [self allEnabledPhotosSelected:section];
    NSString *title = !allEnabledPhotosSelected ? @"全选" : @"全不选";
    [checkTitles replaceObjectAtIndex:section withObject:title];
    
    // 修改headerView的全选文字
    UICollectionReusableView *headerView = (UICollectionReusableView *)[reusableHeaderArray objectAtIndex:section];
    for (UIView *view in headerView.subviews) {
        if ([view isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *)[view viewWithTag:(200+section)];
            label.text = [checkTitles objectAtIndex:section];
        }
    }
    // 判断删除按钮是否可用
    for (NSInteger i=0; i<deleteArray.count; i++) {
        NSMutableIndexSet *selectedIndexSet = deleteArray[i];
        if ((NSNull *)selectedIndexSet != [NSNull null]) {
            if ([selectedIndexSet count])
            {
                [deleteButton setImage:[UIImage imageNamed:@"PersonalPhotoDeleteActive"] forState:UIControlStateNormal];
                deleteButton.enabled = YES;
                saveButton.enabled = YES;
                [saveButton setTitleColor:[UIColor commonTextBlueColor] forState:UIControlStateNormal];
                break;
            }
            else if (i == deleteArray.count-1)
            {
                [deleteButton setImage:[UIImage imageNamed:@"PersonalPhotoDelete"] forState:UIControlStateNormal];
                deleteButton.enabled = NO;
                saveButton.enabled = NO;
                [saveButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            }
            else
            {
                continue;
            }
        }
        else
        {
            [deleteButton setImage:[UIImage imageNamed:@"PersonalPhotoDelete"] forState:UIControlStateNormal];
            deleteButton.enabled = NO;
            saveButton.enabled = NO;
            [saveButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        }
    }
}

- (BOOL)allEnabledPhotosSelected:(NSInteger)section {
    NSIndexSet* enabledIndexSet = [self enabledIndexSetForPhotos:allDatas[section]];
    NSMutableIndexSet *selectedIndexSet = deleteArray[section];
    if ((NSNull *)selectedIndexSet == [NSNull null]) {
        return NO;
    }
    BOOL allEnabledPhotosSelected = [selectedIndexSet containsIndexes:enabledIndexSet];
    return allEnabledPhotosSelected;
}

- (NSIndexSet *)enabledIndexSetForPhotos:(NSArray *)photos {
    NSIndexSet *enabledIndexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [photos count])];
    return enabledIndexSet;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return sectionTitles.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSArray *temp = allDatas[section];
    return temp.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoCell *cell = (PhotoCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    [cell sizeToFit];
    if (!cell) {
         NSLog(@"cell==nil------");
        return nil;
    }
    NSArray *temp = allDatas[indexPath.section];
    NSString *imgSubPath = temp[indexPath.row];
    
    NSString *screenPrintPath = [DOCUMENTPATH stringByAppendingPathComponent:@"screenPrint"];
    NSString *imgName = [NSString stringWithFormat:@"%@%@%@", screenPrintPath, @"/",imgSubPath];
    
    cell.imageView.image = [UIImage imageNamed:imgName];
    cell.checkImage.image = [UIImage imageNamed:@"PersonalPhotoSelect"];
    
    return cell;
}
//UICollectionView的段头段尾
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if([kind isEqualToString:UICollectionElementKindSectionHeader])
    {
        UICollectionReusableView *headerView = [collectView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:headerId forIndexPath:indexPath];
        if(!headerView)
        {
            headerView = [[UICollectionReusableView alloc] initWithFrame:CGRectMake(0, 0, collectionView.frame.size.width, 50)];
        } else {
            for (UIView *subView in headerView.subviews) {
                [subView removeFromSuperview];
            }
        }
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, collectionView.frame.size.width-100, 50)];
        timeLabel.text = [sectionTitles objectAtIndex:indexPath.section];
        timeLabel.font = [UIFont systemFontOfSize:15];
        timeLabel.textColor = [UIColor commonText6Color];
        [headerView addSubview:timeLabel];
        
        UILabel *allLabel = [[UILabel alloc] initWithFrame:CGRectMake(collectionView.frame.size.width-110, 0, 100, 50)];
        allLabel.text = [checkTitles objectAtIndex:indexPath.section];
        allLabel.tag = 200 + indexPath.section;
        allLabel.textAlignment = NSTextAlignmentRight;
        allLabel.font = [UIFont systemFontOfSize:15];
        allLabel.textColor = [UIColor commonText6Color];
        allLabel.hidden = !isEdit;
        allLabel.userInteractionEnabled = YES;
        [allLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickAllSelect:)]];
        [headerView addSubview:allLabel];
        [reusableHeaderArray replaceObjectAtIndex:indexPath.section withObject:headerView];
        return headerView;
    }
    else if([kind isEqualToString:UICollectionElementKindSectionFooter])
    {
        UICollectionReusableView *footerView = [collectView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:footerId forIndexPath:indexPath];
        if(!footerView)
        {
            footerView = [[UICollectionReusableView alloc] init];
        } else {
            for (UIView *subView in footerView.subviews) {
                [subView removeFromSuperview];
            }
        }
        footerView.backgroundColor = [UIColor lightGrayColor];
        return footerView;
    }
    return nil;
}

#pragma mark ---- UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(collectionView.frame.size.width/4 - 10, collectionView.frame.size.width/4 - 10);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(5, 5, 5, 5);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 5.f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 5.f;
}

// HeaderSize
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(collectionView.frame.size.width, 50.0f);;
}

// FooterSize
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeMake(collectionView.frame.size.width, 0.001f);
}

#pragma mark ---- UICollectionViewDelegate
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

// 选中某item执行操作
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"+++++++++++++++++++++++");
    PhotoCell *cell = (PhotoCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (isEdit)  // 选择状态下
    {
        NSMutableIndexSet *selectedIndexSet = [deleteArray objectAtIndex:indexPath.section];
        if ((NSNull *)selectedIndexSet == [NSNull null]) {
            selectedIndexSet = [NSMutableIndexSet indexSet];
        }
        [selectedIndexSet addIndex:indexPath.item];
        [deleteArray replaceObjectAtIndex:indexPath.section withObject:selectedIndexSet];
        [self updateSelectionLabel:indexPath.section];
    }
    else   // 非选择状态下 可以点击查看大图
    {
        NSLog(@"查看大图++++");
        cell.checkImage.hidden = YES;
        [collectionView deselectItemAtIndexPath:indexPath animated:YES];
        
        NSArray *imgArr = allDatas[indexPath.section];
        NSString *imgPath = imgArr[indexPath.row];

        NSInteger currentIndex = 0;
        NSMutableArray *imageArray = [NSMutableArray array];
        for (int i=0; i<allDatas.count; i++) {
            NSArray *secArray = [allDatas objectAtIndex:i];
            for (int j=0; j<secArray.count; j++) {
                NSString *imgSubPath = [secArray objectAtIndex:j];
                if ([imgSubPath hasSuffix:@".jpeg"]){
                    [imageArray addObject:[secArray objectAtIndex:j]];
                }
            }
        }
        currentIndex = [imageArray indexOfObject:imgPath];
        UIVCPhotoBrowser *controller = [[UIVCPhotoBrowser alloc] init];
        controller.imageArray = imageArray;
        controller.currIndex = currentIndex;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"-----------------------");
    PhotoCell *cell = (PhotoCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (isEdit)  // 选择状态下
    {
         NSMutableIndexSet *selectedIndexSet = [deleteArray objectAtIndex:indexPath.section];
        [selectedIndexSet removeIndex:indexPath.item];
        if (selectedIndexSet.count == 0)
        {
            [deleteArray replaceObjectAtIndex:indexPath.section withObject:[NSNull null]];
        }
        else
        {
            [deleteArray replaceObjectAtIndex:indexPath.section withObject:selectedIndexSet];
        }
        [self updateSelectionLabel:indexPath.section];
    }
    else   // 非选择状态下 可以点击查看大图
    {
        NSLog(@"查看大图----");
        cell.checkImage.hidden = YES;
        NSInteger currentIndex = 0;
        if (indexPath.section == 0)
        {
            currentIndex = indexPath.row;
        }
        else
        {
            for (int i=0; i<indexPath.section; i++) {
                NSArray *secArray = [allDatas objectAtIndex:i];
                currentIndex = currentIndex + secArray.count;
            }
            currentIndex = currentIndex + indexPath.row;
        }
        NSMutableArray *imageArray = [NSMutableArray array];
        for (int i=0; i<allDatas.count; i++) {
            NSArray *secArray = [allDatas objectAtIndex:i];
            for (int j=0; j<secArray.count; j++) {
                [imageArray addObject:[secArray objectAtIndex:j]];
            }
        }
        
        UIVCPhotoBrowser *controller = [[UIVCPhotoBrowser alloc] init];
        controller.imageArray = imageArray;
        controller.currIndex = currentIndex;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

#pragma mark - 选择/取消 的处理
-(void) clickToEdit {
    isEdit = !isEdit;
    if (isEdit) {
        [deleteButton setImage:[UIImage imageNamed:@"PersonalPhotoDelete"] forState:UIControlStateNormal];
        deleteButton.enabled = NO;
        
        [saveButton setTitle:@"保存" forState:UIControlStateNormal];
        [saveButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        saveButton.enabled = NO;
        
        [editButton setTitle:@"取消" forState:UIControlStateNormal];
    }
    else
    {
        [deleteButton setImage:nil forState:UIControlStateNormal];
        deleteButton.enabled = YES;
        
        [saveButton setTitle:@"" forState:UIControlStateNormal];
        saveButton.enabled = YES;
        
        [editButton setTitle:@"选择" forState:UIControlStateNormal];
        
        [self loadDataDeleteArray];
    }
    [collectView reloadData];
}

#pragma mark - 全选/全不选 的处理
-(void) clickAllSelect:(UITapGestureRecognizer *) recognizer {
    
    UILabel *allLabel = (UILabel *) recognizer.self.view;
    NSInteger section = allLabel.tag - 200;
    
    NSArray *photos = allDatas[section];
    NSUInteger count = [photos count];
    BOOL allEnabledPhotosSelected = [self allEnabledPhotosSelected:section];
    if (!allEnabledPhotosSelected) {
        [collectView performBatchUpdates:^{
            NSMutableIndexSet *selectedIndexSet = [NSMutableIndexSet indexSet];
            for (NSUInteger index = 0; index < count; ++index) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:section];
                if ([self collectionView:collectView shouldSelectItemAtIndexPath:indexPath]) {
                    [collectView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
                    [selectedIndexSet addIndex:indexPath.item];
                }
            }
            [deleteArray replaceObjectAtIndex:section withObject:selectedIndexSet];
        } completion:^(BOOL finished) {
            [self updateSelectionLabel:section];
        }];
    } else {
        [collectView performBatchUpdates:^{
            NSMutableIndexSet *selectedIndexSet = [deleteArray objectAtIndex:section];
            [selectedIndexSet enumerateIndexesUsingBlock:^(NSUInteger index, BOOL * _Nonnull stop) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:section];
                if ([self collectionView:collectView shouldDeselectItemAtIndexPath:indexPath]) {
                    [collectView deselectItemAtIndexPath:indexPath animated:YES];
                    [selectedIndexSet removeIndex:indexPath.item];
                }
            }];
            [deleteArray replaceObjectAtIndex:section withObject:[NSNull null]];
            
        } completion:^(BOOL finished) {
            [self updateSelectionLabel:section];
        }];
    }
    
    
}

#pragma mark - 保存选中图片
- (void)savePhotoToAlumb {
    if (!isEdit) return;
    
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"保存" message:@"将相册图片保存到系统相册中" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        __block BOOL hadSave = NO;
        for (NSInteger section=0; section<deleteArray.count; section++) {
            NSMutableIndexSet *selectedIndexSet = deleteArray[section];
            
            if (((NSNull *)selectedIndexSet != [NSNull null]) && (selectedIndexSet.count > 0)){
                [selectedIndexSet enumerateIndexesUsingBlock:^(NSUInteger item, BOOL *stop) {
                    NSArray *sections = [allDatas objectAtIndex:section];
                    NSString *imgSubPath = sections[item];
                    NSLog(@"imgSubPath = %@", imgSubPath);
                    NSString *screenPrintPath = [DOCUMENTPATH stringByAppendingPathComponent:@"screenPrint"];
                    NSString *imgName = [NSString stringWithFormat:@"%@%@%@", screenPrintPath, @"/",imgSubPath];
                    hadSave = YES;
                    UIImage *image = [UIImage imageWithContentsOfFile:imgName];
                    UIImageWriteToSavedPhotosAlbum(image, self, nil, nil);//图片保存到相册
                }];
            }
        }
        if (hadSave){
            NSLog(@"保存成功");
        }
    }];
    
    [controller addAction:cancelAction];
    [controller addAction:otherAction];
    [self presentViewController:controller animated:YES completion:nil];
}

#pragma mark - 删除选中图片
-(void) clickToDelete {
    if (isEdit) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"确认删除？" message:nil preferredStyle:UIAlertControllerStyleAlert];
        // 确认
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
            for (NSInteger section=0; section<deleteArray.count; section++) {
                NSMutableIndexSet *selectedIndexSet = deleteArray[section];
                NSLog(@"selectedIndexSet = %@", selectedIndexSet);
                if (((NSNull *)selectedIndexSet != [NSNull null]) && (selectedIndexSet.count > 0)){
                    [selectedIndexSet enumerateIndexesUsingBlock:^(NSUInteger item, BOOL *stop) {
                        NSArray *sections = [allDatas objectAtIndex:section];
                        NSString *imgSubPath = sections[item];
                        NSString *screenPrintPath = [DOCUMENTPATH stringByAppendingPathComponent:@"screenPrint"];
                        NSString *imgName = [NSString stringWithFormat:@"%@%@%@", screenPrintPath, @"/",imgSubPath];
                        [[NSFileManager defaultManager] removeItemAtPath:imgName error:nil];
                    }];
                }
            }
            NSLog(@"删除成功");
            
            // 删除成功后 reloadData
            dispatch_async(dispatch_get_main_queue(), ^{
                [self clickToEdit];
                [self loadDataFromDataBase];
                [collectView reloadData];
                
                if (allDatas.count==0)
                    editButton.enabled=NO;
                else
                    editButton.enabled=YES;
            });
        }];
        [alertController addAction:okAction];
        // 取消
        UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancleAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

@end
