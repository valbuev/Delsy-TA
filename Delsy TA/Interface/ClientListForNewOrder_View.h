//
//  ClientListForNewOrder_View.h
//  Delsy TA
//
//  Created by Valeriy Buev on 26.06.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

/* В зависимости от этого свойства выбираем что делать при выборе адреса:
 * Выставить выбранный адрес для заказа и закрыться
 * Открыть окно редактирования заказа и передать туда выбранный адрес
 * Открыть окно списка заказов для выбранного клиента
 */
enum ClientListViewResult {
    ClientListViewResult_SetForOrderAndClose,
    ClientListViewResult_OpenOrderEditView,
    ClientListViewResult_OpenOrderListView,
    ClientListViewResult_Default
};
typedef enum ClientListViewResult ClientListViewResult;

@class Order;

@interface ClientListForNewOrder_View : UITableViewController
<NSFetchedResultsControllerDelegate, UISearchDisplayDelegate, UISearchBarDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic) ClientListViewResult clientListViewResult;
@property (nonatomic,retain) Order *order;

@end
