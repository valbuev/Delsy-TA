//
//  DeliveryDateView.h
//  Delsy TA
//
//  Created by Valeriy Buev on 10.07.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Order;

@protocol DeliveryDateViewDelegate

// письмо было отправлено
- (void) deliveryDateViewDidSendMail;
// Не удалось отправить письмо
- (void) deliveryDateViewDidFailSendingMail;

// Письмо было сохранено
- (void) deliveryDateViewDidSaveMail;

@end

@interface DeliveryDateView : UIViewController

@property (nonatomic,retain) Order *order;
@property (nonatomic,weak) id <DeliveryDateViewDelegate> delegate;

@end
