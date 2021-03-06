//
//  LocationSenderItem.m
//  Telegram
//
//  Created by keepcoder on 17.07.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "LocationSenderItem.h"

@implementation LocationSenderItem


-(id)initWithCoordinates:(CLLocationCoordinate2D)coordinates conversation:(TL_conversation *)conversation
{
    if(self = [super init]) {
        
        self.conversation = conversation;
        
        self.message = [MessageSender createOutMessage:@"" media:[TL_messageMediaGeo createWithGeo:[TL_geoPoint createWithN_long:coordinates.longitude lat:coordinates.latitude]] dialog:conversation];
        
        [self.message save:YES];
    }
    
    return self;
}



-(void)performRequest {
    
    TLAPI_messages_sendMedia *request = [TLAPI_messages_sendMedia createWithPeer:[self.conversation inputPeer] media:[TL_inputMediaGeoPoint createWithGeo_point:[TL_inputGeoPoint createWithLat:self.message.media.geo.lat n_long:self.message.media.geo.n_long]] random_id:self.message.randomId];
    
    self.rpc_request = [RPCRequest sendRequest:request successHandler:^(RPCRequest *request, TL_messages_statedMessage * response) {
        
        
        [SharedManager proccessGlobalResponse:response];
        
        ((TL_localMessage *)self.message).n_id = response.message.n_id;
        ((TL_localMessage *)self.message).date = response.message.date;
        ((TL_localMessage *)self.message).dstate = DeliveryStateNormal;
        
        [self.message save:YES];
        
        self.state = MessageSendingStateSent;
        
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        self.state = MessageSendingStateError;
    }];
    
}


@end
