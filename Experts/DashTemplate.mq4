//+------------------------------------------------------------------+
//|                                                 DashTemplate.mq4 |
//|                                                   Lonnie Coffman |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Lonnie Coffman"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

string ArrowDown = "\\Images\\ArrowDown.bmp";
string ArrowUp = "\\Images\\ArrowUp.bmp";
string Neutral = "\\Images\\Neutral.bmp";
string EmptyBox = "\\Images\\EmptyBox.bmp";
string GreenBox = "\\Images\\GreenBox.bmp";
string RedBox = "\\Images\\RedBox.bmp";
string OrangeBox = "\\Images\\OrangeBox.bmp";
string MixedBox = "\\Images\\MixedBox.bmp";
string EmptyWideBox = "\\Images\\EmptyWideBox.bmp";
string GreenWideBox = "\\Images\\GreenWideBox.bmp";
string RedWideBox = "\\Images\\RedWideBox.bmp";
string OrangeWideBox = "\\Images\\OrangeWideBox.bmp";
string ChartButton = "\\Images\\ChartButton.bmp";
string BuyButton = "\\Images\\BuyButton.bmp";
string SellButton = "\\Images\\SellButton.bmp";
string CloseButton = "\\Images\\CloseButton.bmp";

struct pairinf {
   string   Pair;
   string   FXtradeName;
   int      Timeframe;
   int      LotSize;
   double   Spread;
   double   MaxSpread;
   double   ADR;
   double   ADRPips;
   double   Profit;
   double   ProfitPips;
   string   QuantDir;
   string   TradeDirection;
   bool     TradeAllowed;
   int      TradeCount;
   int      OpenLotsize;
   double   AveragePrice;
   datetime BarTime;
}; pairinf PairInfo[];

double AccountBal,AvailMargin,UsedMargin,RealizedPL;
int NumOpenTrades;

string TradePairs[] =   {"AUDCAD", "AUDJPY", "AUDUSD", "CADJPY", "EURCAD", "EURGBP", "EURJPY", "EURUSD", "GBPUSD", "NZDJPY", "NZDUSD", "USDCAD", "USDCHF", "USDJPY" };
string FXtradeNames[] = {"AUD_CAD","AUD_JPY","AUD_USD","CAD_JPY","EUR_CAD","EUR_GBP","EUR_JPY","EUR_USD","GBP_USD","NZD_JPY","NZD_USD","USD_CAD","USD_CHF","USD_JPY"};
double MaxSpread[] =    { 3.0,      2.6,      2.0,      2.7,      3.5,      2.0,      2.2,      1.8,     2.2,      3.3,      2.6,      2.5,      2.5,      1.9     };

int   x_axis = 30;
int   y_axis = 70;
int   TextSize = 8;
int   HeaderTextSize = 8;
int   LabelTextSize = 7;
int   DashWidth = 980;

string ChartTemplate = "Candles_dark.tpl";
double PLOffset = 3841.69; // profit and loss offset

int LotSize;
double LotMultiplier;

double CurrentProfit;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(1);
   
   CurrentProfit = 0;

   ArrayResize(PairInfo,ArraySize(TradePairs));
   for(int i=0;i<ArraySize(TradePairs);i++){
      PairInfo[i].Pair           = TradePairs[i];
      PairInfo[i].FXtradeName    = FXtradeNames[i];
      PairInfo[i].MaxSpread      = MaxSpread[i];
      PairInfo[i].LotSize        = 40;
      PairInfo[i].Timeframe      = PERIOD_M15;
      PairInfo[i].TradeAllowed   = true;
      PairInfo[i].BarTime        = iTime(Symbol(), PERIOD_M5, 0);
   }

   // ensure that all pairs are loaded in market watch window.
   for(int i=0;i<ArraySize(PairInfo);i++){
      SymbolSelect(PairInfo[i].Pair, true);
   }

   // create dashboard objects
   SetPanel("BP",0,x_axis-1,y_axis-55,DashWidth,475,clrBlack,clrBlack,1);
   SetPanel("AccountBar",0,x_axis-2,y_axis-55,DashWidth,25,C'34,34,34',clrBlack,1);
   
   SetPanel("HeaderBar",0,x_axis-2,y_axis-30,DashWidth,26,C'136,136,136',clrBlack,1);
   
   SetText("AccountBalance","Account Balance: $000.00",x_axis+71,y_axis-50,C'136,136,136',HeaderTextSize);
   SetText("AccountEquity","Equity: $000.00",x_axis+305,y_axis-50,C'136,136,136',HeaderTextSize);
   SetText("AccountMargin","Margin Used / Avail: $000.00 / $000.00",x_axis+530,y_axis-50,C'136,136,136',HeaderTextSize);
   SetText("AccountRealPL","Realized P/L: $000.00",x_axis+815,y_axis-50,C'136,136,136',HeaderTextSize);
   //SetText("AccountUnrealPL","Unrealized P/L: $000.00",x_axis+1000,y_axis-50,C'136,136,136',HeaderTextSize);
   
   SetPanel("ExpertActive",0,x_axis+9,y_axis-18,8,8,C'53,53,38',C'85,85,85',1);
   SetPanel("LiveTrading",0,x_axis+22,y_axis-18,8,8,C'53,53,38',C'85,85,85',1);
   SetPanel("AutoTrading",0,x_axis+34,y_axis-18,8,8,C'53,53,38',C'85,85,85',1);
   
   SetText ("SpreadLabel","Spread",x_axis+97,y_axis-20,C'68,68,68',LabelTextSize);
   
   SetText ("RangeLabel","Range",x_axis+157,y_axis-20,C'68,68,68',LabelTextSize);
   
   SetText ("LotsLabel","Units",x_axis+553,y_axis-30,C'68,68,68',LabelTextSize);
   SetText ("LotsBuyLabel","Buy",x_axis+536,y_axis-19,C'68,68,68',LabelTextSize);
   SetText ("LotsSellLabel","Sell",x_axis+575,y_axis-19,C'68,68,68',LabelTextSize);
   SetText ("OrdersLabel","Orders",x_axis+617,y_axis-30,C'68,68,68',LabelTextSize);
   SetText ("OrdersBuyLabel","Buy",x_axis+611,y_axis-19,C'68,68,68',LabelTextSize);
   SetText ("OrdersSellLabel","Sell",x_axis+640,y_axis-19,C'68,68,68',LabelTextSize);
   SetText ("BuyPriceLabel","Buy",x_axis+679,y_axis-19,C'68,68,68',LabelTextSize);
   SetText ("SellPriceLabel","Sell",x_axis+731,y_axis-19,C'68,68,68',LabelTextSize);
   
   SetPanel("PandLBox",0,x_axis+775,y_axis-28,54,22,clrBlack,clrNONE,1);
   SetText ("PandLText","0.00",x_axis+780,y_axis-24,C'68,68,68',TextSize);
   
   SetText ("PipsLabel","Pips",x_axis+838,y_axis-19,C'68,68,68',LabelTextSize);

   for(int i=0;i<ArraySize(PairInfo);i++){
      SetPanel(PairInfo[i].Pair+"_BG",0,x_axis-2,(i*26)+y_axis-5,1415,25,clrBlack,clrBlack,1);
      BitmapCreate("Btn_Chart_"+PairInfo[i].Pair,ChartButton,x_axis,(i*26)+y_axis+1);
      SetText(PairInfo[i].Pair+"_Label",PairInfo[i].Pair,x_axis+30,(i*26)+y_axis+1,clrBlanchedAlmond,TextSize);
      SetText(PairInfo[i].Pair+"_Spread","0.0",x_axis+100,(i*26)+y_axis+1,C'68,68,68',TextSize);
      
      SetText(PairInfo[i].Pair+"_Range1","000",x_axis+148,(i*26)+y_axis+1,C'68,68,68',TextSize);
      SetText(PairInfo[i].Pair+"_RangeDiv","/",x_axis+171,(i*26)+y_axis+1,C'128,128,128',TextSize+1);
      SetText(PairInfo[i].Pair+"_Range2","000",x_axis+178,(i*26)+y_axis+1,C'68,68,68',TextSize);
      
      SetPanel(PairInfo[i].Pair+"_VertDivider",0,x_axis+210,(i*26)+y_axis-5,2,26,C'85,85,85',C'45,83,121',3);
      
      
      SetPanel(PairInfo[i].Pair+"_VertDivider2",0,x_axis+460,(i*26)+y_axis-5,2,26,C'85,85,85',C'45,83,121',3);

      SetText(PairInfo[i].Pair+"_Label2",PairInfo[i].Pair,x_axis+468,(i*26)+y_axis+2,C'85,85,85',TextSize);

      //BitmapCreate("Btn_Buy_"+PairInfo[i].Pair,BuyButton,x_axis+365,(i*26)+y_axis-1);
      //BitmapCreate("Btn_Sell_"+PairInfo[i].Pair,SellButton,x_axis+410,(i*26)+y_axis-1);
      
      SetText(PairInfo[i].Pair+"_LotsBuy","0000",x_axis+530,(i*26)+y_axis+1,C'68,68,68',TextSize);
      SetText(PairInfo[i].Pair+"_LotsSell","0000",x_axis+570,(i*26)+y_axis+1,C'68,68,68',TextSize);
      SetText(PairInfo[i].Pair+"_OrdersBuy","0",x_axis+617,(i*26)+y_axis+1,C'68,68,68',TextSize);
      SetText(PairInfo[i].Pair+"_OrdersSell","0",x_axis+645,(i*26)+y_axis+1,C'68,68,68',TextSize);
      SetText(PairInfo[i].Pair+"_BuyPrice","0.00",x_axis+676,(i*26)+y_axis+1,C'68,68,68',TextSize);
      SetText(PairInfo[i].Pair+"_SellPrice","0.00",x_axis+728,(i*26)+y_axis+1,C'68,68,68',TextSize);
      SetText(PairInfo[i].Pair+"_ProfitLoss","0.00",x_axis+780,(i*26)+y_axis+1,C'68,68,68',TextSize);
      SetText(PairInfo[i].Pair+"_Pips","0.0",x_axis+838,(i*26)+y_axis+2,C'68,68,68',TextSize);
      
      SetPanel(PairInfo[i].Pair+"_VertDivider3",0,x_axis+876,(i*26)+y_axis-5,2,26,C'85,85,85',C'45,83,121',3);
      
      //BitmapCreate("Btn_Close_"+PairInfo[i].Pair,CloseButton,x_axis+892,(i*26)+y_axis-1);

      SetPanel(PairInfo[i].Pair+"_Divider",0,x_axis,(i*26)+y_axis+20,DashWidth,1,C'73,73,73',clrNONE,1);
   }

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason){
//--- destroy timer
   EventKillTimer();

   //remove dashboard objects
   ObjectDelete(0,"BP");
   ObjectDelete(0,"AccountBar");
   
   ObjectDelete(0,"HeaderBar");
   
   ObjectDelete(0,"AccountBalance");
   ObjectDelete(0,"AccountEquity");
   ObjectDelete(0,"AccountMargin");
   ObjectDelete(0,"AccountRealPL");
   ObjectDelete(0,"AccountUnrealPL");
   
   ObjectDelete(0,"ExpertActive");
   ObjectDelete(0,"LiveTrading");
   ObjectDelete(0,"AutoTrading");
   
   ObjectDelete(0,"SpreadLabel");
   ObjectDelete(0,"RangeLabel");

   ObjectDelete(0,"LotsLabel");
   ObjectDelete(0,"LotsBuyLabel");
   ObjectDelete(0,"LotsSellLabel");
   ObjectDelete(0,"OrdersLabel");
   ObjectDelete(0,"OrdersBuyLabel");
   ObjectDelete(0,"OrdersSellLabel");
   ObjectDelete(0,"BuyPriceLabel");
   ObjectDelete(0,"SellPriceLabel");
   ObjectDelete(0,"PipsLabel");
   
   ObjectDelete(0,"PandLBox");
   ObjectDelete(0,"PandLText");

   for(int i=0;i<ArraySize(PairInfo);i++){
      ObjectDelete(0,PairInfo[i].Pair+"_BG");
      ObjectDelete(0,"Btn_Chart_"+PairInfo[i].Pair);
      ObjectDelete(0,PairInfo[i].Pair+"_Label");
      ObjectDelete(0,PairInfo[i].Pair+"_Spread");
      
      ObjectDelete(0,PairInfo[i].Pair+"_Range1");
      ObjectDelete(0,PairInfo[i].Pair+"_RangeDiv");
      ObjectDelete(0,PairInfo[i].Pair+"_Range2");
      
      ObjectDelete(0,"Btn_Buy_"+PairInfo[i].Pair);
      ObjectDelete(0,"Btn_Sell_"+PairInfo[i].Pair);
      
      ObjectDelete(0,PairInfo[i].Pair+"_LotsBuy");
      ObjectDelete(0,PairInfo[i].Pair+"_LotsSell");
      ObjectDelete(0,PairInfo[i].Pair+"_OrdersBuy");
      ObjectDelete(0,PairInfo[i].Pair+"_OrdersSell");
      ObjectDelete(0,PairInfo[i].Pair+"_BuyPrice");
      ObjectDelete(0,PairInfo[i].Pair+"_SellPrice");
      ObjectDelete(0,PairInfo[i].Pair+"_ProfitLoss");
      ObjectDelete(0,PairInfo[i].Pair+"_Locked");
      
      ObjectDelete(0,"Btn_Close_"+PairInfo[i].Pair);
      
      ObjectDelete(0,PairInfo[i].Pair+"_VertDivider");
      ObjectDelete(0,PairInfo[i].Pair+"_VertDivider2");
      ObjectDelete(0,PairInfo[i].Pair+"_VertDivider3");
      
      ObjectDelete(0,PairInfo[i].Pair+"_Label2");
      ObjectDelete(0,PairInfo[i].Pair+"_Pips");
      ObjectDelete(0,PairInfo[i].Pair+"_Divider");
   }
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer(){
   string LockFilename = "FXtrade\\bridge_lock";
   long search_handle;
   string filefind;
   
   UpdateInfo();
   UpdateDashboard();
   
   // loop through all pairs
   for(int i=0;i<ArraySize(PairInfo);i++){

      // if bridge_lock file does not exist continue
      if (FileIsExist(LockFilename) != true){
         search_handle = FileFindFirst("FXtrade\\*"+PairInfo[i].FXtradeName+"*",filefind);
         if(search_handle==INVALID_HANDLE){
            
            // look for new trades
            
         } else {
            
            // manage open trades
         }
         FileFindClose(search_handle);
      }
   }
   
}
//+------------------------------------------------------------------+
//================================================//
// Update Information                             //
//================================================//
void UpdateInfo(){
   int fuFilehandle;
   string fuFilename;
   int fuOrderCount = 0;
   
   for(int i=0;i<ArraySize(PairInfo);i++){
      
      PairInfo[i].Spread = MarketInfo(PairInfo[i].Pair,MODE_SPREAD)/10;

   }
   
   // update account information
   fuFilename = "FXtrade\\account.txt";
   if (FileIsExist(fuFilename)){
      fuFilehandle=FileOpen(fuFilename,FILE_READ|FILE_CSV,",");
      
      AccountBal =      StrToDouble(FileReadString(fuFilehandle));
      NumOpenTrades =   StrToInteger(FileReadString(fuFilehandle));
      AvailMargin =     StrToDouble(FileReadString(fuFilehandle));
      UsedMargin =      StrToDouble(FileReadString(fuFilehandle));
      RealizedPL =      StrToDouble(FileReadString(fuFilehandle));
      
      FileClose(fuFilehandle);
   }
   
   // update orders
   for(int i=0;i<ArraySize(PairInfo);i++){
      fuFilename = "FXtrade\\position-"+PairInfo[i].FXtradeName+".txt";
      if (FileIsExist(fuFilename)){
         // assign values
         fuFilehandle=FileOpen(fuFilename,FILE_READ|FILE_CSV,",");
         PairInfo[i].TradeDirection = FileReadString(fuFilehandle);
         PairInfo[i].OpenLotsize = int(FileReadString(fuFilehandle));
         PairInfo[i].AveragePrice = StringToDouble(FileReadString(fuFilehandle));
         PairInfo[i].TradeCount = int(FileReadString(fuFilehandle));
         FileClose(fuFilehandle);
         
      } else {
         // reset values
         PairInfo[i].TradeDirection = "none";
         PairInfo[i].OpenLotsize = 0;
         PairInfo[i].TradeCount = 0;
         PairInfo[i].AveragePrice = 0;
         PairInfo[i].ProfitPips = 0;
         PairInfo[i].TradeCount = 0;
      }
   }

   PlotADR();
   PlotADRpips();
   
   return;
}

//================================================//
// Update Dashboard                               //
//================================================//
void UpdateDashboard(){
   
   double fuProfit,fuTotalProfit;
   string fuSpacer,ADRstring,ADRpipsString,StrLots;
   color  fuSpreadColor,fuADRColor;
   
   fuTotalProfit = 0;
   
   ObjectSetText("AccountBalance","Account Balance: $"+DoubleToStr(AccountBal,2),HeaderTextSize,NULL,C'136,136,136');
   ObjectSetText("AccountMargin","Margin Used / Avail: $"+DoubleToStr(UsedMargin,2)+" / $"+DoubleToStr(AvailMargin,2),HeaderTextSize,NULL,C'136,136,136');
   ObjectSetText("AccountRealPL","Realized P/L: $"+DoubleToStr((RealizedPL + PLOffset),2),HeaderTextSize,NULL,C'136,136,136');
   
   if (IsConnected() == true) ObjectSetInteger(0,"ExpertActive",OBJPROP_BGCOLOR,C'147,255,38');
      else ObjectSetInteger(0,"ExpertActive",OBJPROP_BGCOLOR,C'255,0,0');
   if (IsExpertEnabled() == true) ObjectSetInteger(0,"LiveTrading",OBJPROP_BGCOLOR,C'147,255,38');
      else ObjectSetInteger(0,"LiveTrading",OBJPROP_BGCOLOR,C'255,0,0');
   if (IsTradeAllowed() == true) ObjectSetInteger(0,"AutoTrading",OBJPROP_BGCOLOR,C'147,255,38');
      else ObjectSetInteger(0,"AutoTrading",OBJPROP_BGCOLOR,C'255,0,0');

   for(int i=0;i<ArraySize(PairInfo);i++){
      // Spread
      if (PairInfo[i].Spread < 10) fuSpacer = "  ";
         else fuSpacer = "";
      if ((PairInfo[i].Spread > PairInfo[i].MaxSpread * 0.9) && (PairInfo[i].Spread < PairInfo[i].MaxSpread)) fuSpreadColor = clrOrange;
         else if (PairInfo[i].Spread >= PairInfo[i].MaxSpread) fuSpreadColor = clrRed;
         else fuSpreadColor = clrLimeGreen;
      ObjectSetText(PairInfo[i].Pair+"_Spread",fuSpacer+DoubleToStr(PairInfo[i].Spread,1),TextSize,NULL,fuSpreadColor);

      // ADR Values
      if (PairInfo[i].ADR < 99) fuSpacer = "0";
         else fuSpacer = "";
      ADRstring = fuSpacer+DoubleToStr(PairInfo[i].ADR,0);
      if (PairInfo[i].ADRPips < 10) fuSpacer = "00";
         else if (PairInfo[i].ADRPips < 100) fuSpacer = "0";
         else fuSpacer = "";
      ADRpipsString = fuSpacer+DoubleToStr(PairInfo[i].ADRPips,0);
      if ((PairInfo[i].ADRPips > PairInfo[i].ADR * 0.9) && (PairInfo[i].ADRPips < PairInfo[i].ADR)) fuADRColor = clrOrange;
         else if (PairInfo[i].ADRPips >= PairInfo[i].ADR) fuADRColor = clrOrangeRed;
         else fuADRColor = clrLimeGreen;
      ObjectSetText(PairInfo[i].Pair+"_Range1",ADRpipsString,TextSize,NULL,fuADRColor);
      ObjectSetText(PairInfo[i].Pair+"_Range2",ADRstring,TextSize,NULL,fuADRColor);
      
      fuProfit = 0;
      
      // Profit and Loss
      if(PairInfo[i].TradeDirection == "buy"){
         fuProfit = MarketInfo(PairInfo[i].Pair, MODE_TICKVALUE) * PairInfo[i].OpenLotsize * (MarketInfo(PairInfo[i].Pair,MODE_BID) - PairInfo[i].AveragePrice);
         PairInfo[i].ProfitPips = NormalizeDouble((MarketInfo(PairInfo[i].Pair,MODE_BID) - PairInfo[i].AveragePrice)/MarketInfo(PairInfo[i].Pair,MODE_POINT)/10,1);
      } else if(PairInfo[i].TradeDirection == "sell"){
         fuProfit = MarketInfo(PairInfo[i].Pair, MODE_TICKVALUE) * PairInfo[i].OpenLotsize * (PairInfo[i].AveragePrice - MarketInfo(PairInfo[i].Pair,MODE_ASK));
         PairInfo[i].ProfitPips = NormalizeDouble((PairInfo[i].AveragePrice - MarketInfo(PairInfo[i].Pair,MODE_ASK))/MarketInfo(PairInfo[i].Pair,MODE_POINT)/10,1);
      }
      if (StringFind(PairInfo[i].Pair,"JPY") >= 0){
         fuProfit = fuProfit / 100;
      }
      
      fuTotalProfit += fuProfit;
      PairInfo[i].Profit = fuProfit;

      // Units Open
      if (PairInfo[i].OpenLotsize > 0){
         if (PairInfo[i].OpenLotsize >= 1000) StrLots = IntegerToString(PairInfo[i].OpenLotsize);
            else if ((PairInfo[i].OpenLotsize >= 100) && (PairInfo[i].OpenLotsize <= 999)) StrLots = "0"+IntegerToString(PairInfo[i].OpenLotsize);
            else if ((PairInfo[i].OpenLotsize >= 10) && (PairInfo[i].OpenLotsize <= 99)) StrLots = "00"+IntegerToString(PairInfo[i].OpenLotsize);
            else  StrLots = "000"+IntegerToString(PairInfo[i].OpenLotsize);
         if (PairInfo[i].TradeDirection == "buy"){
            ObjectSetText(PairInfo[i].Pair+"_LotsSell","0000",TextSize,NULL,C'68,68,68');
            ObjectSetText(PairInfo[i].Pair+"_LotsBuy",StrLots,TextSize,NULL,clrBlanchedAlmond);
            ObjectSetText(PairInfo[i].Pair+"_OrdersBuy",IntegerToString(PairInfo[i].TradeCount),TextSize,NULL,clrBlanchedAlmond);
            ObjectSetText(PairInfo[i].Pair+"_OrdersSell","0",TextSize,NULL,C'68,68,68');
            if (fuProfit > 0) ObjectSetText(PairInfo[i].Pair+"_BuyPrice",DoubleToStr(MathAbs(fuProfit),2),TextSize,NULL,C'147,255,38');
               else if (fuProfit == 0) ObjectSetText(PairInfo[i].Pair+"_BuyPrice","0.00",TextSize,NULL,C'147,255,38');
               else ObjectSetText(PairInfo[i].Pair+"_BuyPrice",DoubleToStr(MathAbs(fuProfit),2),TextSize,NULL,clrOrangeRed);
            ObjectSetText(PairInfo[i].Pair+"_SellPrice","0.00",TextSize,NULL,C'68,68,68');
         } else if (PairInfo[i].TradeDirection == "sell"){
            ObjectSetText(PairInfo[i].Pair+"_LotsSell",StrLots,TextSize,NULL,clrBlanchedAlmond);
            ObjectSetText(PairInfo[i].Pair+"_LotsBuy","0000",TextSize,NULL,C'68,68,68');
            ObjectSetText(PairInfo[i].Pair+"_OrdersSell",IntegerToString(PairInfo[i].TradeCount),TextSize,NULL,clrBlanchedAlmond);
            ObjectSetText(PairInfo[i].Pair+"_OrdersBuy","0",TextSize,NULL,C'68,68,68');
            if (fuProfit > 0) ObjectSetText(PairInfo[i].Pair+"_SellPrice",DoubleToStr(MathAbs(fuProfit),2),TextSize,NULL,C'147,255,38');
               else if (fuProfit == 0) ObjectSetText(PairInfo[i].Pair+"_SellPrice","0.00",TextSize,NULL,C'147,255,38');
               else  ObjectSetText(PairInfo[i].Pair+"_SellPrice",DoubleToStr(MathAbs(fuProfit),2),TextSize,NULL,clrOrangeRed);
            ObjectSetText(PairInfo[i].Pair+"_BuyPrice","0.00",TextSize,NULL,C'68,68,68');
         }
         if (fuProfit > 0) ObjectSetText(PairInfo[i].Pair+"_ProfitLoss",DoubleToStr(MathAbs(fuProfit),2),TextSize,NULL,C'147,255,38');
               else if (fuProfit == 0) ObjectSetText(PairInfo[i].Pair+"_ProfitLoss","0.00",TextSize,NULL,C'147,255,38');
               else  ObjectSetText(PairInfo[i].Pair+"_ProfitLoss",DoubleToStr(MathAbs(fuProfit),2),TextSize,NULL,clrOrangeRed);
         if (PairInfo[i].TradeDirection == "buy"){
            ObjectSetInteger(0,PairInfo[i].Pair+"_Label2",OBJPROP_COLOR,clrBlanchedAlmond);
         } else if (PairInfo[i].TradeDirection == "sell"){
            ObjectSetInteger(0,PairInfo[i].Pair+"_Label2",OBJPROP_COLOR,clrBlanchedAlmond);
         } else {
            ObjectSetInteger(0,PairInfo[i].Pair+"_Label2",OBJPROP_COLOR,C'85,85,85');
         }
      } else {
         ObjectSetText(PairInfo[i].Pair+"_LotsSell","0000",TextSize,NULL,C'68,68,68');
         ObjectSetText(PairInfo[i].Pair+"_LotsBuy","0000",TextSize,NULL,C'68,68,68');
         ObjectSetText(PairInfo[i].Pair+"_OrdersSell","0",TextSize,NULL,C'68,68,68');
         ObjectSetText(PairInfo[i].Pair+"_OrdersBuy","0",TextSize,NULL,C'68,68,68');
         ObjectSetText(PairInfo[i].Pair+"_SellPrice","0.00",TextSize,NULL,C'68,68,68');
         ObjectSetText(PairInfo[i].Pair+"_BuyPrice","0.00",TextSize,NULL,C'68,68,68');
         ObjectSetText(PairInfo[i].Pair+"_ProfitLoss","0.00",TextSize,NULL,C'68,68,68');
         ObjectSetText(PairInfo[i].Pair+"_Locked","0.00",TextSize,NULL,C'68,68,68');
         ObjectSetInteger(0,PairInfo[i].Pair+"_Label2",OBJPROP_COLOR,C'85,85,85');
      }
     
      // update pips
      if ((PairInfo[i].ProfitPips >= 0) && (PairInfo[i].TradeDirection != "none")) ObjectSetText(PairInfo[i].Pair+"_Pips",DoubleToStr(PairInfo[i].ProfitPips,1),TextSize,NULL,C'147,255,38');
         else if ((PairInfo[i].ProfitPips < 0) && (PairInfo[i].TradeDirection != "none")) ObjectSetText(PairInfo[i].Pair+"_Pips",DoubleToStr(PairInfo[i].ProfitPips,1),TextSize,NULL,clrOrangeRed);
         else ObjectSetText(PairInfo[i].Pair+"_Pips","0.0",TextSize,NULL,C'68,68,68');
      
   }
   
   CurrentProfit = fuTotalProfit;
   
   if (NumOpenTrades > 0){
      if (fuTotalProfit > 0) ObjectSetText("PandLText",DoubleToStr(fuTotalProfit,2),TextSize,NULL,C'147,255,38');
         else if (fuTotalProfit == 0) ObjectSetText("PandLText","0.00",TextSize,NULL,C'147,255,38');
         else ObjectSetText("PandLText",DoubleToStr(MathAbs(fuTotalProfit),2),TextSize,NULL,clrOrangeRed);
   } else {
      ObjectSetText("PandLText","0.00",TextSize,NULL,C'68,68,68');
      ObjectSetText("LockText","0.00",TextSize,NULL,C'68,68,68');
   }
   
   ObjectSetText("AccountEquity","Equity: $"+DoubleToStr(AccountBal+fuTotalProfit,2),HeaderTextSize,NULL,C'136,136,136');
   
}

//================================================//
// Plot Daily Range                               //
//================================================//
void PlotADR(){
   double adr;
   int b,c,i;
   for (i=0;i<ArraySize(PairInfo);i++) {
      b = 1;
      c = 1;
      adr = 0.0;
      while(b <= 20){
         if (TimeDayOfWeek(iTime(PairInfo[i].Pair,PERIOD_D1,c)) != 0){
            adr = adr + (iHigh(PairInfo[i].Pair,PERIOD_D1,c)-iLow(PairInfo[i].Pair,PERIOD_D1,c))/MarketInfo(PairInfo[i].Pair,MODE_POINT)/10;
            b++;
         }
         c++;
      }
      adr = adr / 20;
      PairInfo[i].ADR = adr;
   }
}

//================================================//
// Plot Pips Towards Today's Range                //
//================================================//
void PlotADRpips(){
   double fuAdrPips;
   for (int i=0;i<ArraySize(PairInfo);i++) {
      fuAdrPips = 0;
      fuAdrPips = NormalizeDouble((iHigh(PairInfo[i].Pair,PERIOD_D1,0)-iLow(PairInfo[i].Pair,PERIOD_D1,0))/MarketInfo(PairInfo[i].Pair,MODE_POINT)/10,0);
      PairInfo[i].ADRPips = fuAdrPips;
   }
}

//================================================//
// Open a Chart for the given pair/timeframe      //
//================================================//
void OpenChart(string fuPair,int fuTimeframe){
   long fuChartID;
   
   fuChartID = ChartOpen(fuPair,fuTimeframe);
   if (fuChartID > 0){
      ChartApplyTemplate(fuChartID, ChartTemplate);
   }
   
   return;
}

//================================================//
// FXtrade Bridge Functions                       //
//================================================//
// create order file
bool OpenMarketOrder(string fuInstrument, string fuSide, int fuUnits, double fuStop=0.0, double fuTarget=0.0){
   int fuFilehandle;
   bool fuOrder;
   string pair = fuInstrument;
   StringReplace(pair,"_","");
   
   string fuCommand = "openmarket-"+fuInstrument+"-"+fuSide+"-"+IntegerToString(fuUnits)+"-"+DoubleToStr(fuStop,int(MarketInfo(pair,MODE_DIGITS)))+"-"+DoubleToStr(fuTarget,int(MarketInfo(pair,MODE_DIGITS)));

   LockDirectory();
   fuFilehandle=FileOpen("FXtrade\\"+fuCommand,FILE_WRITE|FILE_TXT);
   if(fuFilehandle!=INVALID_HANDLE){
      FileClose(fuFilehandle);
      fuOrder = True;
   } else fuOrder = False;
   UnlockDirectory();
   Sleep(5000);
   return fuOrder;
}

// create close position file
bool ClosePosition(string fuInstrument){
   int fuFilehandle;
   fuFilehandle=FileOpen("FXtrade\\closeall-"+fuInstrument,FILE_WRITE|FILE_TXT);
   if(fuFilehandle!=INVALID_HANDLE){
      FileClose(fuFilehandle);
      return True;
   } else return False;
}

// lock directory so python does not access files
bool LockDirectory(){
   int fuFilehandle;
   fuFilehandle=FileOpen("FXtrade\\MT4-Locked",FILE_WRITE|FILE_TXT);
   if(fuFilehandle!=INVALID_HANDLE){
      FileClose(fuFilehandle);
      return True;
   } else return False;
}

// unlock directory so python can access files
bool UnlockDirectory(){
   int fuFilehandle;
   fuFilehandle=FileDelete("FXtrade\\MT4-Locked");
   if (fuFilehandle == False) return False;
      else return True;
}

//================================================//
// Draw Panel on Chart                            //
//================================================//
void SetPanel(string name,int sub_window,int x,int y,int width,int height,color bg_color,color border_clr,int border_width){
   if(ObjectCreate(0,name,OBJ_RECTANGLE_LABEL,sub_window,0,0)){
      ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
      ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
      ObjectSetInteger(0,name,OBJPROP_XSIZE,width);
      ObjectSetInteger(0,name,OBJPROP_YSIZE,height);
      ObjectSetInteger(0,name,OBJPROP_COLOR,border_clr);
      ObjectSetInteger(0,name,OBJPROP_BORDER_TYPE,BORDER_FLAT);
      ObjectSetInteger(0,name,OBJPROP_WIDTH,border_width);
      ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
      ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_SOLID);
      ObjectSetInteger(0,name,OBJPROP_BACK,true);
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,0);
      ObjectSetInteger(0,name,OBJPROP_SELECTED,0);
      ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
      ObjectSetInteger(0,name,OBJPROP_ZORDER,0);
   }
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,bg_color);
  }
void ColorPanel(string name,color bg_color,color border_clr)
  {
   ObjectSetInteger(0,name,OBJPROP_COLOR,border_clr);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,bg_color);
  }
void SetText(string name,string text,int x,int y,color colour,int fontsize=12)
  {
   if (ObjectFind(0,name)<0)
      ObjectCreate(0,name,OBJ_LABEL,0,0,0);

    ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
    ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
    ObjectSetInteger(0,name,OBJPROP_COLOR,colour);
    ObjectSetInteger(0,name,OBJPROP_FONTSIZE,fontsize);
    ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
    ObjectSetString(0,name,OBJPROP_FONT,"arial");
    ObjectSetString(0,name,OBJPROP_TEXT,text);
  }
//+------------------------------------------------------------------+
//| Create bitmap                                                    |
//+------------------------------------------------------------------+
bool BitmapCreate(const string            name,
                  const string            image,
                  const int               x=0,
                  const int               y=0,
                  const long              chart_ID=0)
  {
//--- reset the error value
   ResetLastError();
//--- create the button
   if(!ObjectCreate(chart_ID,name,OBJ_BITMAP_LABEL,0,0,0))
     {
      Print(__FUNCTION__,
            ": failed to create the button! Error code = ",GetLastError());
      return(false);
     }
//--- set button coordinates
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
   ObjectSetString(0,name,OBJPROP_BMPFILE,0,image);
   return(true);
}

//+------------------------------------------------------------------+
//| Create the button                                                |
//+------------------------------------------------------------------+
bool ButtonCreate(const string            name="Button",            // button name
                  const string            text="Button",            // text
                  const int               x=0,                      // X coordinate
                  const int               y=0,                      // Y coordinate
                  const int               width=50,                 // button width
                  const int               height=22,                // button height
                  const color             clr=clrWhite,             // text color
                  const color             back_clr=clrRoyalBlue,    // background color
                  const color             border_clr=clrWhite,      // border color
                  const int               font_size=10,             // font size
                  const ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER, // chart corner for anchoring
                  const string            font="Arial",             // font
                  
                  const bool              back=false,               // in the background
                  const bool              selection=false,          // highlight to move
                  const bool              state=false,              // pressed/released
                  const long              chart_ID=0,               // chart's ID
                  const int               sub_window=0,             // subwindow index
                  const bool              hidden=true,              // hidden in the object list
                  const long              z_order=0)                // priority for mouse click
  {
//--- reset the error value
   ResetLastError();
//--- create the button
   if(!ObjectCreate(chart_ID,name,OBJ_BUTTON,sub_window,0,0))
     {
      Print(__FUNCTION__,
            ": failed to create the button! Error code = ",GetLastError());
      return(false);
     }
//--- set button coordinates
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
//--- set button size
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
//--- set the chart's corner, relative to which point coordinates are defined
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
//--- set the text
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
//--- set text font
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
//--- set font size
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
//--- set text color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set background color
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
//--- set border color
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_COLOR,border_clr);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- set button state
   ObjectSetInteger(chart_ID,name,OBJPROP_STATE,state);
//--- enable (true) or disable (false) the mode of moving the button by mouse
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
}

//+------------------------------------------------------------------+
//| Button Presses                                                   |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,  const long &lparam, const double &dparam,  const string &sparam){
   string fuPair;
   int ret;
   if(id==CHARTEVENT_OBJECT_CLICK)
   {
      if (StringSubstr(sparam,0,3) == "Btn"){ // this is a button, thus has an action associated with it
         // Chart Button
         if (StringSubstr(sparam,0,9) == "Btn_Chart") {
            fuPair = StringSubstr(sparam,10,6);
            for(int i=0;i<ArraySize(PairInfo);i++){
               if (PairInfo[i].Pair == fuPair){
                  OpenChart(PairInfo[i].Pair,PERIOD_M5);
               }
            }
            ObjectSetInteger(0,sparam,OBJPROP_STATE,false);
            ChartRedraw();
         }

         // Buy Button
         if (StringSubstr(sparam,0,7) == "Btn_Buy") {
            fuPair = StringSubstr(sparam,8,6);
            for(int i=0;i<ArraySize(PairInfo);i++){
               if (PairInfo[i].Pair == fuPair){
                  if (PairInfo[i].TradeDirection == "sell"){
                     ret=MessageBox("You have a sell trade open. Do you want to close it and open a buy trade on "+fuPair+"?","      =======      Confirmation Required      =======", MB_YESNO|MB_ICONSTOP); // Message box
                     if(ret ==IDYES){
                        ClosePosition(PairInfo[i].FXtradeName);
                        Sleep(1000);
                        OpenMarketOrder(PairInfo[i].FXtradeName, "buy", PairInfo[i].LotSize);
                     }
                  } else {
                     OpenMarketOrder(PairInfo[i].FXtradeName, "buy", PairInfo[i].LotSize);
                  }
               }
            }
         }
         // Sell Button
         if (StringSubstr(sparam,0,8) == "Btn_Sell") {
            fuPair = StringSubstr(sparam,9,6);
            for(int i=0;i<ArraySize(PairInfo);i++){
               if (PairInfo[i].Pair == fuPair){
                  if (PairInfo[i].TradeDirection == "buy"){
                     ret=MessageBox("You have a buy trade open. Do you want to close it and open a sell trade on "+fuPair+"?","", MB_YESNO|MB_ICONQUESTION); // Message box
                     if(ret ==IDYES){
                        ClosePosition(PairInfo[i].FXtradeName);
                        Sleep(1000);
                        OpenMarketOrder(PairInfo[i].FXtradeName, "sell", PairInfo[i].LotSize);
                     }
                  } else {
                     OpenMarketOrder(PairInfo[i].FXtradeName, "sell", PairInfo[i].LotSize);
                  }
               }
            }
         }
         // Close Button
         if (StringSubstr(sparam,0,9) == "Btn_Close") {
            fuPair = StringSubstr(sparam,10,6);
            for(int i=0;i<ArraySize(PairInfo);i++){
               if (PairInfo[i].Pair == fuPair){
                  ClosePosition(PairInfo[i].FXtradeName);
               }
            }
            ObjectSetInteger(0,sparam,OBJPROP_STATE,false);
            ChartRedraw();
         }
/*
         // 00 Button
         if (StringSubstr(sparam,0,10) == "Btn_Lock00") {
            fuPair = StringSubstr(sparam,11,6);
            for(int i=0;i<ArraySize(PairInfo);i++){
               if (PairInfo[i].Pair == fuPair){
                  if (PairInfo[i].OpenLotsize > 0){
                     if (PairInfo[i].LockLevel == 0){
                        PairInfo[i].LockLevel = -1;
                        PairInfo[i].LockProfit = -1;
                     } else {
                        if (PairInfo[i].Profit > 0){ // only set lock level if there is a profit
                           PairInfo[i].LockLevel = 0;
                           SetLockPrice(fuPair,i,0);
                        } else {
                           MessageBox("Cannot set to Break Even unless there is a profit.","", MB_OK|MB_ICONWARNING); // Message box
                        }
                     }
                  }
               }
            }
            ObjectSetInteger(0,sparam,OBJPROP_STATE,false);
            ChartRedraw();
         }
         // 25 Button
         if (StringSubstr(sparam,0,10) == "Btn_Lock25") {
            fuPair = StringSubstr(sparam,11,6);
            for(int i=0;i<ArraySize(PairInfo);i++){
               if (PairInfo[i].Pair == fuPair){
                  if (PairInfo[i].OpenLotsize > 0){
                     if (PairInfo[i].LockLevel == 25){
                        PairInfo[i].LockLevel = -1;
                        PairInfo[i].LockProfit = -1;
                     } else {
                        if (PairInfo[i].Profit > 0){ // only set lock level if there is a profit
                           PairInfo[i].LockLevel = 25;
                           SetLockPrice(fuPair,i,25);
                        } else {
                           MessageBox("Cannot lock in 25% unless there is a profit.","", MB_OK|MB_ICONWARNING); // Message box
                        }
                     }
                  }
               }
            }
            ObjectSetInteger(0,sparam,OBJPROP_STATE,false);
            ChartRedraw();
         }
         // 50 Button
         if (StringSubstr(sparam,0,10) == "Btn_Lock50") {
            fuPair = StringSubstr(sparam,11,6);
            for(int i=0;i<ArraySize(PairInfo);i++){
               if (PairInfo[i].Pair == fuPair){
                  if (PairInfo[i].OpenLotsize > 0){
                     if (PairInfo[i].LockLevel == 50){
                        PairInfo[i].LockLevel = -1;
                        PairInfo[i].LockProfit = -1;
                     } else {
                        if (PairInfo[i].Profit > 0){ // only set lock level if there is a profit
                           PairInfo[i].LockLevel = 50;
                           SetLockPrice(fuPair,i,50);
                        } else {
                           MessageBox("Cannot lock in 50% unless there is a profit.","", MB_OK|MB_ICONWARNING); // Message box
                        }
                     }
                  }
               }
            }
            ObjectSetInteger(0,sparam,OBJPROP_STATE,false);
            ChartRedraw();
         }
         // 75 Button
         if (StringSubstr(sparam,0,10) == "Btn_Lock75") {
            fuPair = StringSubstr(sparam,11,6);
            for(int i=0;i<ArraySize(PairInfo);i++){
               if (PairInfo[i].Pair == fuPair){
                  if (PairInfo[i].OpenLotsize > 0){
                     if (PairInfo[i].LockLevel == 75){
                        PairInfo[i].LockLevel = -1;
                        PairInfo[i].LockProfit = -1;
                     } else {
                        if (PairInfo[i].Profit > 0){ // only set lock level if there is a profit
                           PairInfo[i].LockLevel = 75;
                           SetLockPrice(fuPair,i,75);
                        } else {
                           MessageBox("Cannot lock in 75% unless there is a profit.","", MB_OK|MB_ICONWARNING); // Message box
                        }
                     }
                  }
               }
            }
            ObjectSetInteger(0,sparam,OBJPROP_STATE,false);
            ChartRedraw();
         }
*/
      } else { // this is not a button
         ObjectSetInteger(0,sparam,OBJPROP_STATE,false);
         ChartRedraw();
      }
      
   }
}