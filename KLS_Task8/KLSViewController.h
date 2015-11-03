//
//  KLSViewController.h
//  KLS_Task8
//
//  Created by fpmi on 31.10.15.
//  Copyright (c) 2015 fpmi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface KLSViewController : NSObject <NSURLConnectionDelegate>
{
    NSMutableData *_responseData;
    NSMutableString *_code;
    NSMutableString *_rate;
    NSString *_parsingElement;
}

@end
