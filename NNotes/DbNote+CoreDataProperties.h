//
//  DbNote+CoreDataProperties.h
//  NNotes
//
//  Created by Ольга Выростко on 13.06.16.
//  Copyright © 2016 Ольга Выростко. All rights reserved.

#import "DbNote.h"

NS_ASSUME_NONNULL_BEGIN

@interface DbNote (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *color;
@property (nullable, nonatomic, retain) NSString *text;
@property (nullable, nonatomic, retain) NSString *title;

@end

NS_ASSUME_NONNULL_END
