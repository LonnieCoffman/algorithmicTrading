//+------------------------------------------------------------------+
//|                                             Test-5PipFractal.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

extern double Risk = 2;

enum moneyMan {
   A=0,     // None
   B=1,     // Consecutive
   C=2      // Cumulative
};
extern string s2 = "===== MONEY MANAGEMENT ==============";
input moneyMan MoneyManagement   = 0;     // Money Management Style
extern int     CycleTarget       = 8;     // Cycle Target
extern double  StartingUnits     = 0.01;  // Starting Units
extern bool    UseMaxUnits       = false; // Auto Calculate Max Units?
extern double  StepUnits         = 0.1;   // Step Units (Max False)
extern int     LossStep          = 1;     // Cumulative Loss Steps
extern bool    StayAtMax         = false; // Stay at Max until Loss?
extern string s3 = "===== TRADE RULES ==============";
extern int     TargetPips        = 100;
extern int     StopPips          = 250;
extern int     MinDistance       = 100;
extern int     MaxDistance       = 200;
extern int     MA1Period         = 1;
extern int     MA2Period         = 2;
extern int     MA3Period         = 117;

int CurrentMMStep;
double AutoStep;

double LastUpFractal;
double LastDownFractal;
datetime BarTime;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   BarTime = iTime(Symbol(),Period(),0);
   CurrentMMStep = 1;
   AutoStep = 0.0;

   LastUpFractal = 0;
   LastDownFractal = 0;
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick(){
//---
   int Ticket;
   int MagicNumber = 1234;
   double LotSize, MA1, MA2, MA3;
   
   if (OrdersTotal() < 1){
      if (BarTime != iTime(Symbol(),Period(),0)){
         
         MA1 = iMA(Symbol(),Period(),MA1Period,0,MODE_SMA,PRICE_CLOSE,1);
         MA2 = iMA(Symbol(),Period(),MA2Period,0,MODE_SMA,PRICE_CLOSE,1);
         MA3 = iMA(Symbol(),Period(),MA3Period,0,MODE_SMA,PRICE_CLOSE,1);
         
         if ((Close[1] >= (MA3 + (MinDistance * Point() * 10)) && Close[1] <= (MA3 + (MaxDistance * Point() * 10)))&& // Trend Strength
            (Close[1] < Open[1]) &&
            (MA1 < MA2)){

            if (CurrentMMStep <= 1){
               if (UseMaxUnits){
                  AutoStep = NormalizeDouble(CalculateMaxStep(),2);
                  if (StartingUnits == 0.0) LotSize = NormalizeDouble(AutoStep,2);
                     else LotSize = StartingUnits;
               } else {
                  if (StartingUnits == 0.0) LotSize = 0.01;
                     else LotSize = StartingUnits;
               }
            } else {
               if (UseMaxUnits){
                  if (StartingUnits == 0.0) LotSize = NormalizeDouble(CurrentMMStep * AutoStep,2);
                  else LotSize = NormalizeDouble(StartingUnits + ((CurrentMMStep - 1) * AutoStep),2);
               } else {
                  LotSize = NormalizeDouble(StartingUnits + ((CurrentMMStep - 1) * StepUnits),2);
               }
            }
            Ticket = OrderSend(Symbol(),OP_BUY,NormalizeDouble(LotSize,2),Ask,30,0,0,NULL,MagicNumber,0,clrGreen);
               if (Ticket < 0){
                  Print("Buy OrderSend for "+DoubleToStr(LotSize,2)+" failed with error #",GetLastError());
                  Print("######### AutoStep: "+AutoStep+" | CurrentStep: "+CurrentMMStep+" | LotSize: "+LotSize);
               }
         } else if ((Close[1] <= (MA3 - (MinDistance * Point() * 10)) && Close[1] >= (MA3 - (MaxDistance * Point() * 10)))&& // Trend Strength
            (Close[1] > Open[1]) &&
            (MA1 > MA2)){
            
            if (CurrentMMStep <= 1){
               if (UseMaxUnits){
                  AutoStep = NormalizeDouble(CalculateMaxStep(),2);
                  if (StartingUnits == 0.0) LotSize = NormalizeDouble(AutoStep,2);
                     else LotSize = StartingUnits;
               } else {
                  if (StartingUnits == 0.0) LotSize = 0.01;
                     else LotSize = StartingUnits;
               }
            } else {
               if (UseMaxUnits){
                  if (StartingUnits == 0.0) LotSize = NormalizeDouble(CurrentMMStep * AutoStep,2);
                  else LotSize = NormalizeDouble(StartingUnits + ((CurrentMMStep - 1) * AutoStep),2);
               } else {
                  LotSize = NormalizeDouble(StartingUnits + ((CurrentMMStep - 1) * StepUnits),2);
               }
            }
            Ticket = OrderSend(Symbol(),OP_SELL,NormalizeDouble(LotSize,2),Bid,30,0,0,NULL,MagicNumber,0,clrGreen);
               if (Ticket < 0) Print("Sell OrderSend for "+DoubleToStr(LotSize,2)+" FAILED with error #",GetLastError());
         }
         BarTime = iTime(Symbol(),Period(),0);
      }
   }
   
   for(int i=0; i<OrdersTotal(); i++){
      if((OrderSelect(i,SELECT_BY_POS) == true)&&(OrderSymbol() == Symbol())&&(OrderMagicNumber() == MagicNumber)){
         if (OrderType() == OP_BUY){
            // if 5 pips profit close trade
            if (((Bid - OrderOpenPrice())/Point()/10) >= TargetPips) ClosePositions(Symbol(), true, true, OrderMagicNumber());
            // if 7 pips loss close trade
            if (((Bid - OrderOpenPrice())/Point()/10) <= (StopPips * -1)) ClosePositions(Symbol(), true, true, OrderMagicNumber());
            //if (Bid < LowerFractal) ClosePositions(Symbol(), true, true, OrderMagicNumber());
         }
         if (OrderType() == OP_SELL){
            // if 5 pips profit close trade
            if (((OrderOpenPrice() - Bid)/Point()/10) >= TargetPips) ClosePositions(Symbol(), true, true, OrderMagicNumber());
            // if 7 pips loss close trade
            if (((OrderOpenPrice() - Bid)/Point()/10) <= (StopPips * -1)) ClosePositions(Symbol(), true, true, OrderMagicNumber());
            //if (Bid > UpperFractal) ClosePositions(Symbol(), true, true, OrderMagicNumber());
         }
      }
   }
}
//+------------------------------------------------------------------+

double CalculateMaxStep(){
   double Step;
   double MaxLots = GetLotSize(Risk,StopPips);
   if (StartingUnits == 0.0) Step = NormalizeDouble(MaxLots / CycleTarget,2);
      else Step = NormalizeDouble((MaxLots - StartingUnits) / (CycleTarget - 1),2);
   if (Step < 0.01) Step = 0.01;
   return Step;
}

//===============================================//
// Get Lot Size functions                        //
//===============================================//
int GetPipFactor(string Xsymbol){
   
   string factor10000[]  = {"SEK","TRY","ZAR","MXN"};
   string factor100[]   = {"JPY","XAG"};
   
   int xFactor=10000;
   if(MarketInfo(Xsymbol,MODE_DIGITS)<=1) xFactor=1;
   else if(MarketInfo(Xsymbol,MODE_DIGITS)==2) xFactor=10;
   else if(MarketInfo(Xsymbol,MODE_DIGITS)==3) xFactor=100;
   else if(MarketInfo(Xsymbol,MODE_DIGITS)==4) xFactor=1000;
   else if(MarketInfo(Xsymbol,MODE_DIGITS)==5) xFactor=10000;
   else if(MarketInfo(Xsymbol,MODE_DIGITS)==6) xFactor=100000;
   else if(MarketInfo(Xsymbol,MODE_DIGITS)==7) xFactor=1000000;
   for(int j=0; j<ArraySize(factor10000); j++){
      if(StringFind(Xsymbol,factor10000[j])!=-1) xFactor=10000;
   }
   for(int j=0; j<ArraySize(factor100); j++){
      if(StringFind(Xsymbol,factor100[j])!=-1) xFactor=100;
   }

   return (xFactor);
}

double GetLotSize(double riskPercent,double pips){
   
   double FreeMargin= AccountFreeMargin();
   double TickValue = MarketInfo(Symbol(),MODE_TICKVALUE);
   double LotStep=MarketInfo(Symbol(),MODE_LOTSTEP);

   double SLPts=pips*Point()*10;
   SLPts = int(SLPts * GetPipFactor(Symbol()) * 10);

   double Exposure=SLPts*TickValue; // Exposure based on 1 full lot

   double AllowedExposure=(AccountFreeMargin()*riskPercent)/100;

   int TotalSteps = int((AllowedExposure / Exposure) / LotStep);
   double lotSize = TotalSteps * LotStep;

   double MinLots = MarketInfo(Symbol(), MODE_MINLOT);
   double MaxLots = MarketInfo(Symbol(), MODE_MAXLOT);

   if(lotSize < MinLots) lotSize = MinLots;
   if(lotSize > MaxLots) lotSize = MaxLots;
   return(lotSize);
}

//===============================================//
// close trades in FIFO order                    //
//===============================================//
int ClosePositions(string fuPair, bool fuCloseBuy, bool fuCloseSell, int fuMagicNumber, string fuReason = "" ){
   
   int orderstotal = OrdersTotal();
   int orders = 0;
   double profit = 0;
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
            profit = OrderProfit();
            order = OrderClose(OrderTicket(),OrderLots(),MarketInfo(fuPair,MODE_BID),3,clrRed);
            if (order == true){
               Print(fuPair+": buy order closed by "+fuReason);
               if (profit >= 0){
                  if (CurrentMMStep >= CycleTarget){
                     if (StayAtMax == false) CurrentMMStep = 1;
                  } else CurrentMMStep++;
               } else {
                  if (MoneyManagement == 2){
                     CurrentMMStep -= LossStep;
                     if (CurrentMMStep < 1) CurrentMMStep = 1;
                  } else {
                     CurrentMMStep = 1;
                  }
               }
            } else Print(fuPair+": buy order close failed with error #",GetLastError());
         }
         // sell order found.  does it need to be closed?
         if ((OrderType() == OP_SELL)&&(fuCloseSell == true)){
            RefreshRates();
            profit = OrderProfit();
            order = OrderClose(OrderTicket(),OrderLots(),MarketInfo(fuPair,MODE_ASK),3,clrRed);
            if (order == true){
               Print(fuPair+": sell order closed by "+fuReason);
               if (profit >= 0){
                  if (CurrentMMStep >= CycleTarget){
                     if (StayAtMax == false) CurrentMMStep = 1;
                  } else CurrentMMStep++;
               } else {
                  if (MoneyManagement == 2){
                     CurrentMMStep -= LossStep;
                     if (CurrentMMStep < 1) CurrentMMStep = 1;
                  } else {
                     CurrentMMStep = 1;
                  }
               }
            } else Print(fuPair+": sell order close failed with error #",GetLastError());
         }
      }
   }
   
   return NULL;
}