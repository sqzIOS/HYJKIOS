//
//  SHNearbyHospitalModel.h
//  SexHealth
//
//  Created by ly1992 on 15/6/30.
//  Copyright (c) 2015年 showm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SHNearbyHospitalInfo : NSObject
//医院 图标
@property (nonatomic,strong) NSString *iconStr;
//医院 名
@property (nonatomic,strong) NSString *nameStr;
//医院 id
@property (nonatomic,strong) NSString *idStr;
//医院 地址
@property (nonatomic,strong) NSString *addressStr;
//医院 简介
@property (nonatomic,strong) NSString *contentStr;

//推荐专家列表
//@property (nonatomic, strong) NSMutableArray *doctorList;

@end


@interface SHNearbyHospitalModel : NSObject
//是否请求成功
@property (nonatomic) BOOL success;
//ADInfo对象集合
@property (nonatomic,strong) NSMutableArray *datasource;
//客户端自用, hadload是否远程加载过数据了
@property(nonatomic) BOOL hadload;

/**
 *  对象构造
 *
 *  @return
 */
+(SHNearbyHospitalModel*)buildModel;
/**
 *  从远程获取数据,异部方式回调
 *
 *  @param model    外部要构造
 *  @param flag     是否重新加载
 *  @param callback 返回的数据
 */
+(void)loadRemoteDataForHospitalModel:(SHNearbyHospitalModel*)model flag:(BOOL)flag cb:(void(^)(BOOL isOK, SHNearbyHospitalModel* model))callback;
/**
 *  本地读取缓存的数据
 *
 *  @return
 */
+(SHNearbyHospitalModel*)loadLocalDataForHospitalModel;
@end