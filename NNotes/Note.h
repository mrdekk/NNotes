//
//  Note.h
//  NNotes
//
//  Created by Ольга Выростко on 12.06.16.
//  Copyright © 2016 Ольга Выростко. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Note : NSObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSNumber * color;

- initWithTitle: (NSString *) title Text: (NSString *) text andColor: (NSNumber *) color;

@end
