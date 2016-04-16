//
//  PatientCaseController.h
//  
//
//  Created by wenzhizheng on 16/1/2.
//
// 就诊人病例 

#import <UIKit/UIKit.h>

@class PatientCaseModel;

@interface PatientCaseController : MyCenterBaseController


+ (instancetype)controllerWithPatientCaseModel:(PatientCaseModel *)model;


@end
