//+------------------------------------------------------------------+
//|                                                HighLowLevels.mq4 |
//|                                   Copyright 2016, Lonnie Coffman |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Lonnie Coffman"
#property version   "1.00"
#property strict

extern int HLDepth = 100;
extern int HLGap   = 80;
extern int MagicNumber = 5770;
extern double LotSize = 0.1;

datetime BarTime;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){
   EventSetTimer(1);
   FindLevels(Symbol(),Period());
   BarTime =  iTime(Symbol(),Period(),0);
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason){
   int CurrentObject = 0;
   int TotalObjects = ObjectsTotal();
   while (CurrentObject < TotalObjects){
      ObjectDelete(0,"Sup-"+IntegerToString(CurrentObject));
      ObjectDelete(0,"Res-"+IntegerToString(CurrentObject));
      CurrentObject++;
   }
   EventKillTimer();
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick(){
}
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer(){
   int i;
   bool OpenOrder = false;
   // a new bar has formed
   if(BarTime != iTime(Symbol(),Period(),0)){

      if ((Hour() == 22)&&(Minute() > 43)&&(Minute() < 52)){ // open new trades
         // if there is not a trade open....
         for (i = 0; i < OrdersTotal(); i++){
            if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)){
               if (((OrderType() == OP_BUY)||(OrderType() == OP_SELL)) && (Symbol() == OrderSymbol()) && (OrderMagicNumber() == MagicNumber)) OpenOrder = true;
            }
         }
         if (OpenOrder == false) FindLevels(Symbol(),Period(), true);
      } else if ((Hour() == 12)&&(Minute() < 15)){ // close open trades (3 attempts, just in case)
         ClosePositions(Symbol(), true, true, MagicNumber, "12" );
         FindLevels(Symbol(),Period());
      } else {
         FindLevels(Symbol(),Period());
      }

      BarTime = iTime(Symbol(),Period(),0);
   }

}
//+------------------------------------------------------------------+

void FindLevels(string fPair, int fPeriod, bool fTrade = false){
   int BarCount = iBars(fPair, fPeriod);
   int Bar,LowBar,HighBar,End,MinDistance,LowCount,HighCount,TerminatingBar,a;
   double BarLow,BarHigh,BarLevel,LowSup,HighSup,LowRes,HighRes;
   LowCount = 0;
   HighCount = 0;
   LowSup = 0;
   HighSup = 0;
   LowRes = 0;
   HighRes = 0;
   for(Bar = BarCount; Bar >= HLGap; Bar-- ){
      // look for support
      LowBar = iLowest(fPair, fPeriod, MODE_LOW, HLDepth, Bar );
      if (Bar == LowBar){
         if (Bar == iLowest(fPair, fPeriod, MODE_LOW, HLGap, Bar-(HLGap-1)  )){ // does bar meet gap requirement?
            End = Bar - HLGap;
            BarLow = iLow(fPair, fPeriod, Bar);
            MinDistance = 0;
            while (End > HLGap){
               if (iLow(fPair, fPeriod, End) < BarLow){
                  MinDistance = Bar - End;
                  break;
               }
               End--;
            }
            if (MinDistance == 0){ // Bar has never been touched
               DrawRectangle("Sup-"+IntegerToString(LowCount),iTime(fPair,fPeriod,Bar),iLow(fPair,fPeriod,Bar),iTime(fPair,fPeriod,0),iLow(fPair,fPeriod,Bar)+(2*MarketInfo(fPair,MODE_POINT) * 10),clrRoyalBlue);
               if (LowSup == 0) LowSup = BarLow;
                  else if (BarLow < LowSup) LowSup = BarLow;
               if (HighSup == 0) HighSup = BarLow;
                  else if (BarLow > HighSup) HighSup = BarLow;
               LowCount++;
            } else if ((Bar - MinDistance*2) <= 0){
               DrawRectangle("Sup-"+IntegerToString(LowCount),iTime(fPair,fPeriod,Bar),iLow(fPair,fPeriod,Bar),iTime(fPair,fPeriod,0),iLow(fPair,fPeriod,Bar)+(1*MarketInfo(fPair,MODE_POINT) * 10),clrLightSkyBlue);
               LowCount++;
            } else {
               // find terminating bar
               a = (Bar - MinDistance*2);
               TerminatingBar = 0;
               BarLevel = iLow(fPair,fPeriod,Bar);
               while (a >= 0){
                  if ((iHigh(fPair,fPeriod,a) > BarLevel) && (iLow(fPair,fPeriod,a) < BarLevel)){
                     DrawRectangle("Sup-"+IntegerToString(LowCount),iTime(fPair,fPeriod,Bar),iLow(fPair,fPeriod,Bar),iTime(fPair,fPeriod,a),iLow(fPair,fPeriod,Bar)+(1*MarketInfo(fPair,MODE_POINT) * 10),clrLightSkyBlue);
                     LowCount++;
                     break;
                  }
                  a--;
               }
            }
         }
      }
      // look for resistance
      HighBar = iHighest(fPair, fPeriod, MODE_HIGH, HLDepth, Bar );
      if (Bar == HighBar){
         if (Bar == iHighest(fPair, fPeriod, MODE_HIGH, HLGap, Bar-(HLGap-1)  )){ // does bar meet gap requirement?
            End = Bar - HLGap;
            BarHigh = iHigh(fPair, fPeriod, Bar);
            MinDistance = 0;
            while (End > HLGap){
               if (iHigh(fPair, fPeriod, End) > BarHigh){
                  MinDistance = Bar - End;
                  break;
               }
               End--;
            }
            if (MinDistance == 0){ // Bar has never been touched
               DrawRectangle("Res-"+IntegerToString(HighCount),iTime(fPair,fPeriod,Bar),iHigh(fPair,fPeriod,Bar),iTime(fPair,fPeriod,0),iHigh(fPair,fPeriod,Bar)-(2*MarketInfo(fPair,MODE_POINT) * 10),clrCrimson);
               if (LowRes == 0) LowRes = BarHigh;
                  else if (BarHigh < LowRes) LowRes = BarHigh;
               if (HighRes == 0) HighRes = BarHigh;
                  else if (BarHigh > HighRes) HighRes = BarHigh;
               HighCount++;
            } else if ((Bar - MinDistance*2) <= 0){
               DrawRectangle("Res-"+IntegerToString(HighCount),iTime(fPair,fPeriod,Bar),iHigh(fPair,fPeriod,Bar),iTime(fPair,fPeriod,0),iHigh(fPair,fPeriod,Bar)-(1*MarketInfo(fPair,MODE_POINT) * 10),clrLightPink);
               HighCount++;
            } else {
               // find terminating bar
               a = (Bar - MinDistance*2);
               TerminatingBar = 0;
               BarLevel = iHigh(fPair,fPeriod,Bar);
               while (a >= 0){
                  if ((iHigh(fPair,fPeriod,a) > BarLevel) && (iLow(fPair,fPeriod,a) < BarLevel)){
                     DrawRectangle("Sup-"+IntegerToString(LowCount),iTime(fPair,fPeriod,Bar),iHigh(fPair,fPeriod,Bar),iTime(fPair,fPeriod,a),iHigh(fPair,fPeriod,Bar)-(1*MarketInfo(fPair,MODE_POINT) * 10),clrLightPink);
                     LowCount++;
                     break;
                  }
                  a--;
               }
            }
         }
      }
   }

   if (fTrade){
      if ((HighRes - LowRes) > (HighSup - LowSup)){ // go long
         OpenTrade("long");
      } else if ((HighRes - LowRes) < (HighSup - LowSup)){ // go short
         OpenTrade("short");
      }
   }

   return;
}

void OpenTrade(string Direction){
   int ticket;
   if (Direction == "short"){
      // open sell order
      ticket=OrderSend(Symbol(),OP_SELL,LotSize,Bid,30,0,0,"HL Sell",MagicNumber,0,clrGreen);
      if(ticket<0) Print(Symbol()+": sell order failed with error #",GetLastError());
         else Print(Symbol()+": sell order placed successfully");
   } else if (Direction == "long"){
      ticket=OrderSend(Symbol(),OP_BUY,LotSize,Ask,30,0,0,"HL Sell",MagicNumber,0,clrGreen);
      if(ticket<0) Print(Symbol()+": buy order failed with error #",GetLastError());
         else Print(Symbol()+": buy order placed successfully");
   }
   return;
}

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
            order = OrderClose(OrderTicket(),OrderLots(),MarketInfo(fuPair,MODE_BID),30,clrRed);
            if (order == true) Print(fuPair+": buy order closed by "+fuReason);
               else Print(fuPair+": buy order close failed with error #",GetLastError());
         }
         // sell order found.  does it need to be closed?
         if ((OrderType() == OP_SELL)&&(fuCloseSell == true)){
            RefreshRates();
            order = OrderClose(OrderTicket(),OrderLots(),MarketInfo(fuPair,MODE_ASK),30,clrRed);
            if (order == true) Print(fuPair+": sell order closed by "+fuReason);
               else Print(fuPair+": sell order close failed with error #",GetLastError());
         }
      }
   }

   return NULL;
}

void DrawRectangle(string Name, datetime Time1, double Price1, datetime Time2, double Price2, color Clr){
   if (ObjectFind(0,Name)<0){
      ObjectCreate(0,Name,OBJ_RECTANGLE,0,Time1,Price1,Time2,Price2);
      ObjectSetInteger(0,Name,OBJPROP_COLOR,Clr);
   } else { // move rectangle
      ObjectSet(Name,OBJPROP_TIME1,Time1);
      ObjectSet(Name,OBJPROP_PRICE1,Price1);
      ObjectSet(Name,OBJPROP_TIME2,Time2);
      ObjectSet(Name,OBJPROP_PRICE2,Price2);
      ObjectSet(Name,OBJPROP_COLOR,Clr);
   }
}
