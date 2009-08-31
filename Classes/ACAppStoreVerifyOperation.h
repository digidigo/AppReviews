//
//  PSAppStoreVerifyOperation.h
//  AppCritics
//
//  Created by Charles Gamble on 21/08/2009.
//  Copyright 2009 Charles Gamble. All rights reserved.
//

#import <Foundation/Foundation.h>


@class PSAppStoreApplicationDetailsImporter;
@class PSProgressHUD;


@interface PSAppStoreVerifyOperation : NSOperation
{
	NSString *appIdentifier;
	NSString *storeIdentifier;
	PSAppStoreApplicationDetailsImporter *detailsImporter;
	PSProgressHUD *progressHUD;
}

@property (nonatomic, copy) NSString *appIdentifier;
@property (nonatomic, copy) NSString *storeIdentifier;
@property (nonatomic, readonly) PSAppStoreApplicationDetailsImporter *detailsImporter;
@property (nonatomic, retain) PSProgressHUD *progressHUD;

- (id)initWithAppIdentifier:(NSString *)appId storeIdentifier:(NSString *)storeId;

@end
