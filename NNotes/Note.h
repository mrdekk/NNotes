//
//  Note.h
//  NNotes
//
//  Created by Ольга Выростко on 12.06.16.
//  Copyright © 2016 Ольга Выростко. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Note : NSObject

@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSString * text;
@property (nonatomic, strong) NSNumber * colorR;
@property (nonatomic, strong) NSNumber * colorG;
@property (nonatomic, strong) NSNumber * colorB;

- initWithTitle: (NSString *) title Text: (NSString *) text ColorR: (NSNumber *) colorR ColorG: (NSNumber *) colorG andColorB: (NSNumber *) colorB;

@end
