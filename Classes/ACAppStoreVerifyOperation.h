//
//  ACAppStoreVerifyOperation.h
//  AppCritics
//
//  Created by Charles Gamble on 21/08/2009.
//  Copyright 2009 Charles Gamble. All rights reserved.
//

#import <Foundation/Foundation.h>


@class ACAppStoreApplicationDetailsImporter;
@class PSProgressHUD;


@interface ACAppStoreVerifyOperation : NSOperation
{
	NSString *appIdentifier;
	NSString *storeIdentifier;
	ACAppStoreApplicationDetailsImporter *detailsImporter;
	PSProgressHUD *progressHUD;
}

@property (nonatomic, copy) NSString *appIdentifier;
@property (nonatomic, copy) NSString *storeIdentifier;
@property (nonatomic, readonly) ACAppStoreApplicationDetailsImporter *detailsImporter;
@property (nonatomic, retain) PSProgressHUD *progressHUD;

- (id)initWithAppIdentifier:(NSString *)appId storeIdentifier:(NSString *)storeId;

@end
