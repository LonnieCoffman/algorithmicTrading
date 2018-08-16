//===============================================//
// close trades in FIFO order                    //
//===============================================//
int ClosePositions(string fuPair, bool fuCloseBuy, bool fuCloseSell, int fuMagicNumber, string fuReason = "" ){
   
   int orderstotal = OrdersTotal();
   int orders = 0;
   bool order;
   int ordticket[100][2];
   int i;
   
   // build an array of orders for this pair
   for (i = 0; i < orderstotal; i++){
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
     
      if (OrderMagicNumber() != fuMagicNumber || OrderSymbol() != fuPair)
         continue;
     
      int orderType = OrderType();
      if (orderType != OP_BUY && orderType != OP_SELL)
         continue;
     
      ordticket[orders][0] = OrderOpenTime();
      ordticket[orders][1] = OrderTicket();
      orders++;
   }
    
   ArrayResize(ordticket,orders);
   
   for (i = 0; i < orders; i++){
      if(OrderSelect(ordticket[i][1], SELECT_BY_TICKET)==true){
         // buy order found. does it need to be closed?
         if ((OrderType() == OP_BUY)&&(fuCloseBuy == true)){
            RefreshRates();
            order = OrderClose(OrderTicket(),OrderLots(),MarketInfo(fuPair,MODE_BID),3,clrRed);
            //if (order == true) Print(fuPair+": buy order closed by "+fuReason);
            //   else Print(fuPair+": buy order close failed with error #",GetLastError());
         }
         // sell order found.  does it need to be closed?
         if ((OrderType() == OP_SELL)&&(fuCloseSell == true)){
            RefreshRates();
            order = OrderClose(OrderTicket(),OrderLots(),MarketInfo(fuPair,MODE_ASK),3,clrRed);
            //if (order == true) Print(fuPair+": sell order closed by "+fuReason);
            //   else Print(fuPair+": sell order close failed with error #",GetLastError());
         }
      }
   }
   
   return NULL;
}