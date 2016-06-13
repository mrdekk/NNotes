//
//  DbNote+CoreDataProperties.h
//  NNotes
//
//  Created by Ольга Выростко on 13.06.16.
//  Copyright © 2016 Ольга Выростко. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "DbNote.h"

NS_ASSUME_NONNULL_BEGIN

@interface DbNote (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *colorR;
@property (nullable, nonatomic, retain) NSString *text;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSNumber *colorG;
@property (nullable, nonatomic, retain) NSNumber *colorB;

@end

NS_ASSUME_NONNULL_END
