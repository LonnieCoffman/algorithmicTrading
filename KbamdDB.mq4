//+------------------------------------------------------------------+
//|                                                      KbamdDB.mq4 |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

string ArrowDown = "\\Images\\ArrowDown.bmp";
string ArrowUp = "\\Images\\ArrowUp.bmp";
string Neutral = "\\Images\\Neutral.bmp";

int Timeframe = PERIOD_M1;

string NitroChart    = "XAUUSD";
string NitroTemplate = "5nitro28-1min.tpl";
long   NitroChartID;
int    NitroGlobalMin = 50;
double MinMargin  = 30;

double AccountBal,AvailMargin,UsedMargin,RealizedPL;
int NumOpenTrades;

string Command;

struct pairinf {
   string   Pair;
   string   FXtradeName;
   int      Timeframe;
   int      LotSize;

   int      OpenLotsize;
   string   TradeDirection;
   double   AveragePrice;
   double   Profit;
   double   MinPrice;
   double   MaxPrice;
   int      LockLevel;
   double   LockProfit;
   string   Strategy;
   datetime TradeTime;
   double   TradePrice;
   
   string   ManualAuto;
   
   int      NitroGlobal;
   string   NitroGlobalDirection;
   int      NitroTitan;
   string   NitroTitanDirection;
   int      NitroSS1;
   int      NitroSS2;
   string   NitroRVI;
   string   NitroOsMA;
   string   NitroMACD;
   string   NitroAO;
   int      NitroADX1; // for ADX 0 = neutral, 2 = overbought/oversold
   int      NitroADX2;
   int      NitroCCI1; // for others 0 = neutral, 1 = overbought, -1 = oversold
   int      NitroCCI2;
   int      NitroMFI1;
   int      NitroMFI2;
   int      NitroRSI1;
   int      NitroRSI2;
   int      NitroSTOCH1;
   int      NitroSTOCH2;
   int      NitroWPR1;
   int      NitroWPR2;
   double   NitroOBPercentage; // overbought oversold Percentage
   double   NitroOSPercentage;
   
   string   M15Trend;
   string   H1Trend;
   string   H4Trend;
   string   D1Trend;

}; pairinf PairInfo[];

string TradePairs[] =   {"AUDCAD", "AUDCHF", "AUDJPY", "AUDNZD", "AUDUSD", "CADCHF", "CADJPY", "CHFJPY", "EURAUD", "EURCAD", "EURCHF", "EURGBP", "EURJPY", "EURNZD", "EURUSD", "GBPAUD", "GBPCAD", "GBPCHF", "GBPJPY", "GBPNZD", "GBPUSD", "NZDCAD", "NZDCHF", "NZDJPY", "NZDUSD", "USDCAD", "USDCHF", "USDJPY" };
string FXtradeNames[] = {"AUD_CAD","AUD_CHF","AUD_JPY","AUD_NZD","AUD_USD","CAD_CHF","CAD_JPY","CHF_JPY","EUR_AUD","EUR_CAD","EUR_CHF","EUR_GBP","EUR_JPY","EUR_NZD","EUR_USD","GBP_AUD","GBP_CAD","GBP_CHF","GBP_JPY","GBP_NZD","GBP_USD","NZD_CAD","NZD_CHF","NZD_JPY","NZD_USD","USD_CAD","USD_CHF","USD_JPY"};
string Strategy[] =     {"quantum","quantum","quantum","quantum","quantum","quantum","quantum","quantum","quantum","quantum","quantum","quantum","quantum","quantum","quantum","quantum","quantum","quantum","quantum","quantum","quantum","quantum","quantum","quantum","quantum","quantum","quantum","quantum"};

color LineColor=clrBlack;
int labelcolor;
int   x_axis = 30;
int   y_axis = 70;

#include <Strategy-Nitro50.mqh>
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){
   
   EventSetTimer(1);
   
   ArrayResize(PairInfo,ArraySize(TradePairs));
   for(int i=0;i<ArraySize(TradePairs);i++){
      PairInfo[i].Pair           = TradePairs[i];
      PairInfo[i].FXtradeName    = FXtradeNames[i];
      PairInfo[i].Strategy       = Strategy[i];
      PairInfo[i].LotSize        = 100;
      PairInfo[i].Timeframe      = PERIOD_M15; // must change template also
      PairInfo[i].ManualAuto     = "manual";
      PairInfo[i].LockLevel      = -1;
      PairInfo[i].LockProfit     = -1;
      PairInfo[i].TradePrice     = 0;
   }
   
   // ensure that all pairs are loaded in market watch window.
   for(int i=0;i<ArraySize(PairInfo);i++){
      SymbolSelect(PairInfo[i].Pair, true);
   }
   
   NitroChartID = GetNitroChartID();

   // load dashboard framework
   SetPanel("BP",0,x_axis-1,y_axis-55,1415,475,clrBlack,clrBlack,1);
   SetPanel("AccountBar",0,x_axis-2,y_axis-55,1415,26,C'34,34,34',LineColor,1);
   
   SetPanel("HeaderBar",0,x_axis-2,y_axis-29,1415,26,C'136,136,136',LineColor,1);
   
   SetText("AccountBalance","Account Balance: $000.00",x_axis+71,y_axis-50,C'136,136,136',7);
   SetText("AccountEquity","Equity: $000.00",x_axis+305,y_axis-50,C'136,136,136',7);
   SetText("AccountMargin","Margin Used / Avail: $000.00 / $000.00",x_axis+530,y_axis-50,C'136,136,136',7);
   SetText("AccountRealPL","Realized P/L: $000.00",x_axis+815,y_axis-50,C'136,136,136',7);
   SetText("AccountUnrealPL","Unrealized P/L: $000.00",x_axis+1000,y_axis-50,C'136,136,136',7);
   
   SetPanel("ExpertActive",0,x_axis+9,y_axis-18,8,8,C'53,53,38',C'85,85,85',1);
   SetPanel("LiveTrading",0,x_axis+22,y_axis-18,8,8,C'53,53,38',C'85,85,85',1);
   SetPanel("AutoTrading",0,x_axis+34,y_axis-18,8,8,C'53,53,38',C'85,85,85',1);
   
   SetText ("SpreadLabel","Spread",x_axis+71,y_axis-22,C'68,68,68',7);
   SetText ("GlobalLabel","Global %",x_axis+120,y_axis-22,C'68,68,68',7);
   SetText ("TitanLabel","Titan %",x_axis+175,y_axis-22,C'68,68,68',7);
   SetText ("StrengthLabel","Strength",x_axis+223,y_axis-22,C'68,68,68',7);
   SetText ("RVILabel","RVI",x_axis+273,y_axis-22,C'68,68,68',7);
   SetText ("MALabel","MA",x_axis+305,y_axis-22,C'68,68,68',7);
   SetText ("MACDLabel","MCD",x_axis+331,y_axis-22,C'68,68,68',7);
   SetText ("AOLabel","AO",x_axis+366,y_axis-22,C'68,68,68',7);
   SetText ("KeltnerLabel","Kelt",x_axis+396,y_axis-22,C'68,68,68',7);
   SetText ("ADXLabel","ADX",x_axis+430,y_axis-22,C'68,68,68',7);
   SetText ("OvsLabel","OvS%",x_axis+463,y_axis-22,C'68,68,68',7);
   SetText ("OvbLabel","OvB%",x_axis+501,y_axis-22,C'68,68,68',7);
   SetText ("HTFTrendLabel","HTF Trend",x_axis+554,y_axis-22,C'68,68,68',7);
   
   SetText ("LotsLabel","Units",x_axis+832,y_axis-29,C'68,68,68',7);
   SetText ("LotsBuyLabel","Buy",x_axis+815,y_axis-18,C'68,68,68',7);
   SetText ("LotsSellLabel","Sell",x_axis+853,y_axis-18,C'68,68,68',7);
   SetText ("OrdersLabel","Orders",x_axis+898,y_axis-29,C'68,68,68',7);
   SetText ("OrdersBuyLabel","Buy",x_axis+894,y_axis-18,C'68,68,68',7);
   SetText ("OrdersSellLabel","Sell",x_axis+921,y_axis-18,C'68,68,68',7);
   SetText ("BuyPriceLabel","Buy",x_axis+962,y_axis-18,C'68,68,68',7);
   SetText ("SellPriceLabel","Sell",x_axis+1010,y_axis-18,C'68,68,68',7);
   
   SetPanel("PandLBox",0,x_axis+1063,y_axis-27,54,22,clrBlack,clrNONE,1);
   SetText ("PandLText","0.00",x_axis+1069,y_axis-24,C'68,68,68',8);
   SetPanel("LockBox",0,x_axis+1127,y_axis-27,54,22,clrBlack,clrNONE,1);
   SetText ("LockText","0.00",x_axis+1132,y_axis-24,C'68,68,68',8);
   
   SetText ("LockProfitsLabel","Lock Profits",x_axis+1217,y_axis-22,C'68,68,68',7);
   ButtonCreate("Btn_Manual"," M",x_axis+1363,y_axis-23,22,16,C'136,136,136',C'53,53,38',C'85,85,85',7);
   ButtonCreate("Btn_Auto"," A",x_axis+1388,y_axis-23,22,16,C'136,136,136',C'53,53,38',C'85,85,85',7);
   
   for(int i=0;i<ArraySize(PairInfo);i++){
      SetPanel(PairInfo[i].Pair+"_BG",0,x_axis-2,(i*26)+y_axis-5,1415,25,clrBlack,LineColor,1);
      
      SetText(PairInfo[i].Pair+"_Label",PairInfo[i].Pair,x_axis,(i*26)+y_axis+2,clrBlanchedAlmond,8);
      SetText(PairInfo[i].Pair+"_Spread","0.0",x_axis+80,(i*26)+y_axis+2,C'68,68,68',8);
      SetText(PairInfo[i].Pair+"_Global","000",x_axis+126,(i*26)+y_axis+2,C'68,68,68',8);
      BitmapCreate(PairInfo[i].Pair+"_GlobalArrow",Neutral,x_axis+148,(i*26)+y_axis+3);
      SetText(PairInfo[i].Pair+"_Titan","000",x_axis+180,(i*26)+y_axis+2,C'68,68,68',8);
      BitmapCreate(PairInfo[i].Pair+"_TitanArrow",Neutral,x_axis+202,(i*26)+y_axis+3);
      SetText(PairInfo[i].Pair+"_Strength","0 0",x_axis+238,(i*26)+y_axis+2,C'68,68,68',8);
      BitmapCreate(PairInfo[i].Pair+"_RVIArrow",Neutral,x_axis+277,(i*26)+y_axis+3);
      BitmapCreate(PairInfo[i].Pair+"_MAArrow",Neutral,x_axis+310,(i*26)+y_axis+3);
      BitmapCreate(PairInfo[i].Pair+"_MACDArrow",Neutral,x_axis+339,(i*26)+y_axis+3);
      BitmapCreate(PairInfo[i].Pair+"_AOArrow",Neutral,x_axis+368,(i*26)+y_axis+3);
      BitmapCreate(PairInfo[i].Pair+"_Keltner",Neutral,x_axis+402,(i*26)+y_axis+3);
      SetPanel(PairInfo[i].Pair+"_ADX1",0,x_axis+432,(i*26)+y_axis+5,8,8,clrNONE,C'85,85,85',1);
      SetPanel(PairInfo[i].Pair+"_ADX2",0,x_axis+442,(i*26)+y_axis+5,8,8,clrNONE,C'85,85,85',1);
      SetText(PairInfo[i].Pair+"_Oversold","0",x_axis+471,(i*26)+y_axis+2,C'68,68,68',8);
      SetText(PairInfo[i].Pair+"_Overbought","0",x_axis+512,(i*26)+y_axis+2,C'68,68,68',8);

      BitmapCreate(PairInfo[i].Pair+"_M15Arrow",Neutral,x_axis+550,(i*26)+y_axis+3);
      BitmapCreate(PairInfo[i].Pair+"_H1Arrow",Neutral,x_axis+568,(i*26)+y_axis+3);
      BitmapCreate(PairInfo[i].Pair+"_H4Arrow",Neutral,x_axis+586,(i*26)+y_axis+3);
      BitmapCreate(PairInfo[i].Pair+"_D1Arrow",Neutral,x_axis+604,(i*26)+y_axis+3);
      
      ButtonCreate("Btn_Chart_"+PairInfo[i].Pair,"CH",x_axis+627,(i*26)+y_axis-1,25,18,C'155,155,140',C'45,83,121',clrBlack,8);
      SetText(PairInfo[i].Pair+"_Label2",PairInfo[i].Pair,x_axis+657,(i*26)+y_axis+2,C'85,85,85',8);
      ButtonCreate("Btn_Buy_"+PairInfo[i].Pair,"BUY",x_axis+715,(i*26)+y_axis-1,43,18,C'155,155,140',C'0,98,24',clrBlack,8);
      ButtonCreate("Btn_Sell_"+PairInfo[i].Pair,"SELL",x_axis+760,(i*26)+y_axis-1,43,18,C'155,155,140',C'111,0,0',clrBlack,8);
      
      SetText(PairInfo[i].Pair+"_LotsBuy","0000",x_axis+812,(i*26)+y_axis+2,C'68,68,68',8);
      SetText(PairInfo[i].Pair+"_LotsSell","0000",x_axis+852,(i*26)+y_axis+2,C'68,68,68',8);
      SetText(PairInfo[i].Pair+"_OrdersBuy","0",x_axis+899,(i*26)+y_axis+2,C'68,68,68',8);
      SetText(PairInfo[i].Pair+"_OrdersSell","0",x_axis+927,(i*26)+y_axis+2,C'68,68,68',8);
      SetText(PairInfo[i].Pair+"_BuyPrice","0.00",x_axis+958,(i*26)+y_axis+2,C'68,68,68',8);
      SetText(PairInfo[i].Pair+"_SellPrice","0.00",x_axis+1007,(i*26)+y_axis+2,C'68,68,68',8);
      SetText(PairInfo[i].Pair+"_ProfitLoss","0.00",x_axis+1069,(i*26)+y_axis+2,C'68,68,68',8);
      SetText(PairInfo[i].Pair+"_Locked","0.00",x_axis+1132,(i*26)+y_axis+2,C'68,68,68',8);
      
      ButtonCreate("Btn_Lock00_"+PairInfo[i].Pair,"00",x_axis+1198,(i*26)+y_axis-1,25,18,C'155,155,140',C'85,85,85',clrBlack,8);
      ButtonCreate("Btn_Lock25_"+PairInfo[i].Pair,"25",x_axis+1223,(i*26)+y_axis-1,25,18,C'155,155,140',C'85,85,85',clrBlack,8);
      ButtonCreate("Btn_Lock50_"+PairInfo[i].Pair,"50",x_axis+1248,(i*26)+y_axis-1,25,18,C'155,155,140',C'85,85,85',clrBlack,8);
      ButtonCreate("Btn_Lock75_"+PairInfo[i].Pair,"75",x_axis+1273,(i*26)+y_axis-1,25,18,C'155,155,140',C'85,85,85',clrBlack,8);
      ButtonCreate("Btn_Close_"+PairInfo[i].Pair,"CLOSE",x_axis+1304,(i*26)+y_axis-1,53,18,C'155,155,140',C'0,81,162',clrBlack,8);
      
      ButtonCreate("Btn_Manual_"+PairInfo[i].Pair," M",x_axis+1363,(i*26)+y_axis-1,22,18,C'136,136,136',C'53,53,38',clrBlack,7);
      ButtonCreate("Btn_Auto_"+PairInfo[i].Pair," A",x_axis+1388,(i*26)+y_axis-1,22,18,C'136,136,136',C'53,53,38',clrBlack,7);
      
      SetPanel(PairInfo[i].Pair+"_Divider",0,x_axis,(i*26)+y_axis+20,1413,1,C'73,73,73',clrNONE,1);
   }
   
   LoadValues();
   
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason){

   EventKillTimer();
   SaveValues();
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
   ObjectDelete(0,"GlobalLabel");
   ObjectDelete(0,"TitanLabel");
   ObjectDelete(0,"StrengthLabel");
   ObjectDelete(0,"RVILabel");
   ObjectDelete(0,"MALabel");
   ObjectDelete(0,"MACDLabel");
   ObjectDelete(0,"AOLabel");
   ObjectDelete(0,"KeltnerLabel");
   ObjectDelete(0,"ADXLabel");
   ObjectDelete(0,"OvsLabel");
   ObjectDelete(0,"OvbLabel");
   ObjectDelete(0,"HTFTrendLabel");
   
   ObjectDelete(0,"LotsLabel");
   ObjectDelete(0,"LotsBuyLabel");
   ObjectDelete(0,"LotsSellLabel");
   ObjectDelete(0,"OrdersLabel");
   ObjectDelete(0,"OrdersBuyLabel");
   ObjectDelete(0,"OrdersSellLabel");
   ObjectDelete(0,"BuyPriceLabel");
   ObjectDelete(0,"SellPriceLabel");
   
   ObjectDelete(0,"PandLBox");
   ObjectDelete(0,"PandLText");
   ObjectDelete(0,"LockBox");
   ObjectDelete(0,"LockText");
   
   ObjectDelete(0,"LockProfitsLabel");
   ObjectDelete(0,"Btn_Manual");
   ObjectDelete(0,"Btn_Auto");
   
   for(int i=0;i<ArraySize(PairInfo);i++){
      ObjectDelete(0,PairInfo[i].Pair+"_BG");
      ObjectDelete(0,PairInfo[i].Pair+"_Label");
      ObjectDelete(0,PairInfo[i].Pair+"_Spread");
      ObjectDelete(0,PairInfo[i].Pair+"_Global");
      ObjectDelete(0,PairInfo[i].Pair+"_GlobalArrow");
      ObjectDelete(0,PairInfo[i].Pair+"_Titan");
      ObjectDelete(0,PairInfo[i].Pair+"_TitanArrow");
      ObjectDelete(0,PairInfo[i].Pair+"_Strength");
      ObjectDelete(0,PairInfo[i].Pair+"_RVIArrow");
      ObjectDelete(0,PairInfo[i].Pair+"_MAArrow");
      ObjectDelete(0,PairInfo[i].Pair+"_MACDArrow");
      ObjectDelete(0,PairInfo[i].Pair+"_AOArrow");
      ObjectDelete(0,PairInfo[i].Pair+"_Keltner");
      ObjectDelete(0,PairInfo[i].Pair+"_ADX1");
      ObjectDelete(0,PairInfo[i].Pair+"_ADX2");
      ObjectDelete(0,PairInfo[i].Pair+"_Overbought");
      ObjectDelete(0,PairInfo[i].Pair+"_Oversold");
      ObjectDelete(0,PairInfo[i].Pair+"_M15Arrow");
      ObjectDelete(0,PairInfo[i].Pair+"_H1Arrow");
      ObjectDelete(0,PairInfo[i].Pair+"_H4Arrow");
      ObjectDelete(0,PairInfo[i].Pair+"_D1Arrow");
      ObjectDelete(0,"Btn_Chart_"+PairInfo[i].Pair);
      ObjectDelete(0,PairInfo[i].Pair+"_Label2");
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
      
      ObjectDelete(0,"Btn_Lock00_"+PairInfo[i].Pair);
      ObjectDelete(0,"Btn_Lock25_"+PairInfo[i].Pair);
      ObjectDelete(0,"Btn_Lock50_"+PairInfo[i].Pair);
      ObjectDelete(0,"Btn_Lock75_"+PairInfo[i].Pair);
      ObjectDelete(0,"Btn_Close_"+PairInfo[i].Pair);
      
      ObjectDelete(0,"Btn_Manual_"+PairInfo[i].Pair);
      ObjectDelete(0,"Btn_Auto_"+PairInfo[i].Pair);
      
      ObjectDelete(0,PairInfo[i].Pair+"_Divider");
   }
}  
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer(){
   
   // update Nitro values
   UpdateNitro();
   
   // update Info
   UpdateInfo();
   
   // update Dashboard
   UpdateDashboard();
   
   // handle Locked Profits
   CloseLocked();
   
   // run Strategy if set to Auto
   //for(int i=0;i<ArraySize(PairInfo);i++){
   //   Command = "none";
   //   if (PairInfo[i].ManualAuto == "auto"){
   //      Command = RunStrategy(PairInfo[i].Pair,i,PairInfo[i].Strategy);
   //      if(Command != "none") RunStrategyCommand(PairInfo[i].Pair,i,Command);
   //   }
   //}

}
//+------------------------------------------------------------------+
//|||||||||||||||||||||||||| FUNCTIONS||||||||||||||||||||||||||||||||
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Load Saved Values                                                |
//+------------------------------------------------------------------+
void LoadValues(){
   int fuFilehandle;
   string fuFilename;

   for(int i=0;i<ArraySize(PairInfo);i++){
      fuFilename = "SavedVars\\"+PairInfo[i].Pair+".txt";
      
      if (FileIsExist(fuFilename)){
         fuFilehandle=FileOpen(fuFilename,FILE_READ|FILE_CSV);
         
         PairInfo[i].OpenLotsize = int(FileReadString(fuFilehandle));
         PairInfo[i].TradeDirection = FileReadString(fuFilehandle);
         PairInfo[i].AveragePrice = StringToDouble(FileReadString(fuFilehandle));
         PairInfo[i].Profit = StringToDouble(FileReadString(fuFilehandle));
         PairInfo[i].MinPrice = StringToDouble(FileReadString(fuFilehandle));
         PairInfo[i].MaxPrice = StringToDouble(FileReadString(fuFilehandle));
         PairInfo[i].LockLevel = int(FileReadString(fuFilehandle));
         PairInfo[i].LockProfit = StringToDouble(FileReadString(fuFilehandle));
         PairInfo[i].TradeTime = StringToTime(FileReadString(fuFilehandle));
         PairInfo[i].TradePrice = StringToDouble(FileReadString(fuFilehandle));
         PairInfo[i].ManualAuto = FileReadString(fuFilehandle);
         
         FileClose(fuFilehandle);
      }
   }
   
   return;
}

//+------------------------------------------------------------------+
//| Save Values on Deinit                                            |
//+------------------------------------------------------------------+
void SaveValues(){
   int fuFilehandle;
   string fuFilename;

   for(int i=0;i<ArraySize(PairInfo);i++){
      fuFilename = "SavedVars\\"+PairInfo[i].Pair+".txt";
      fuFilehandle=FileOpen(fuFilename,FILE_WRITE|FILE_CSV);
      if(fuFilehandle!=INVALID_HANDLE){
         FileWrite(fuFilehandle,
                   IntegerToString(PairInfo[i].OpenLotsize),
                   PairInfo[i].TradeDirection,
                   DoubleToStr(PairInfo[i].AveragePrice),
                   DoubleToStr(PairInfo[i].Profit),
                   DoubleToStr(PairInfo[i].MinPrice),
                   DoubleToStr(PairInfo[i].MaxPrice),
                   IntegerToString(PairInfo[i].LockLevel),
                   DoubleToString(PairInfo[i].LockProfit),
                   TimeToStr(PairInfo[i].TradeTime),
                   DoubleToString(PairInfo[i].TradePrice),
                   PairInfo[i].ManualAuto);
         FileClose(fuFilehandle);
      }
   }
   
   return;
}

//+------------------------------------------------------------------+
//| Keep Nitro chart open.                                           |
//+------------------------------------------------------------------+
void NitroOpen(){
   if (ChartGetInteger(NitroChartID,CHART_HEIGHT_IN_PIXELS,0) == 0) NitroChartID = GetNitroChartID();
}

//+------------------------------------------------------------------+
//| Update Nitro Values                                              |
//+------------------------------------------------------------------+
void UpdateNitro(){
   string fuGlobalText,fuGlobalDirection,fuTitanText,fuTitanDirection,fuSignalStrength;
   string fuRVI,fuOsMA,fuMACD,fuAO;
   int fuADX1,fuADX2,fuCCI1,fuCCI2,fuMFI1,fuMFI2,fuRSI1,fuRSI2,fuSTOCH1,fuSTOCH2,fuWPR1,fuWPR2;
   
   NitroOpen(); // make sure that Nitro is open
   
   for(int i=0;i<ArraySize(PairInfo);i++){ // loop through pairs
      
      PairInfo[i].NitroOBPercentage = 0;
      PairInfo[i].NitroOSPercentage = 0;
      
      // set global percentage
      fuGlobalText = ObjectGetString(NitroChartID,"[WYFX.co][GLOBAL.Percentage.2]"+PairInfo[i].Pair,OBJPROP_TEXT);
      if (fuGlobalText == NULL){
         fuGlobalText = ObjectGetString(NitroChartID,"[WYFX.co][GLOBAL.Percentage.1]"+PairInfo[i].Pair,OBJPROP_TEXT);
         if (fuGlobalText == NULL) fuGlobalText = ObjectGetString(NitroChartID,"[WYFX.co][GLOBAL.Percentage.3]"+PairInfo[i].Pair,OBJPROP_TEXT);
      }
      fuGlobalText = StringSubstr(fuGlobalText,0,StringLen(fuGlobalText)-1);
      PairInfo[i].NitroGlobal = StringToInteger(fuGlobalText);
      
      // set global direction
      fuGlobalDirection = ObjectGetString(NitroChartID,"[WYFX.co][Trend.Direction]"+PairInfo[i].Pair,OBJPROP_TEXT);
      if (fuGlobalDirection == "5") PairInfo[i].NitroGlobalDirection = "up";
         else if (fuGlobalDirection == "6") PairInfo[i].NitroGlobalDirection = "down";
         else PairInfo[i].NitroGlobalDirection = "none";
      
      // set Titan
      fuTitanText = ObjectGetString(NitroChartID,"[WYFX.co][T3.Score.2]"+PairInfo[i].Pair,OBJPROP_TEXT);
      if (fuTitanText == NULL){
         fuTitanText = ObjectGetString(NitroChartID,"[WYFX.co][T3.Score.1]"+PairInfo[i].Pair,OBJPROP_TEXT);
         if (fuTitanText == NULL) fuTitanText = ObjectGetString(NitroChartID,"[WYFX.co][T3.Score.3]"+PairInfo[i].Pair,OBJPROP_TEXT);
      }
      PairInfo[i].NitroTitan = StringToInteger(fuTitanText);
      
      // set Titan Direction
      fuTitanDirection = ObjectGetString(NitroChartID,"[WYFX.co][T3.Arrow]"+PairInfo[i].Pair,OBJPROP_TEXT);
      if (fuTitanDirection == "5") PairInfo[i].NitroTitanDirection = "up";
         else if (fuTitanDirection == "6") PairInfo[i].NitroTitanDirection = "down";
         else PairInfo[i].NitroTitanDirection = "none";
      
      // set Signal Strength 1 and 2
      fuSignalStrength = ObjectGetString(NitroChartID,"[WYFX.co][SS.Score]"+PairInfo[i].Pair,OBJPROP_TEXT);
      if (fuSignalStrength == NULL){
         PairInfo[i].NitroSS1 = -1;
         PairInfo[i].NitroSS2 = -1;
      } else {
         PairInfo[i].NitroSS1 = StringToInteger(StringSubstr(fuSignalStrength,0,1));
         PairInfo[i].NitroSS2 = StringToInteger(StringSubstr(fuSignalStrength,2,1));
      }
      
      // set RVI;
      fuRVI = ObjectGetString(NitroChartID,"[WYFX.co][RVI.Score]"+PairInfo[i].Pair,OBJPROP_TEXT);
      if (fuRVI == "55") PairInfo[i].NitroRVI = "up";
         else if (fuRVI == "66") PairInfo[i].NitroRVI = "down";
         else  PairInfo[i].NitroRVI = "none";
      
      // set OsMA;
      fuOsMA = ObjectGetString(NitroChartID,"[WYFX.co][OsMA.Score]"+PairInfo[i].Pair,OBJPROP_TEXT);
      if (fuOsMA == "55") PairInfo[i].NitroOsMA = "up";
         else if (fuOsMA == "66") PairInfo[i].NitroOsMA = "down";
         else  PairInfo[i].NitroOsMA = "none";
         
      // set MACD;
      fuMACD = ObjectGetString(NitroChartID,"[WYFX.co][MACD.Score]"+PairInfo[i].Pair,OBJPROP_TEXT);
      if (fuMACD == "55") PairInfo[i].NitroMACD = "up";
         else if (fuMACD == "66") PairInfo[i].NitroMACD = "down";
         else  PairInfo[i].NitroMACD = "none";
      
      // set AO;
      fuAO = ObjectGetString(NitroChartID,"[WYFX.co][AO.Score]"+PairInfo[i].Pair,OBJPROP_TEXT);
      if (fuAO == "55") PairInfo[i].NitroAO = "up";
         else if (fuAO == "66") PairInfo[i].NitroAO = "down";
         else  PairInfo[i].NitroAO = "none";

      // set ADX1
      fuADX1 = ObjectGetInteger(NitroChartID,"[WYFX.co][1:ADX::matriXx]"+PairInfo[i].Pair,OBJPROP_COLOR);
      if (fuADX1 == 7561050){
         PairInfo[i].NitroADX1 = 2;
         PairInfo[i].NitroOBPercentage += 8.33;
         PairInfo[i].NitroOSPercentage += 8.33;
      } else PairInfo[i].NitroADX1 = 0;
            
      // set ADX2
      fuADX2 = ObjectGetInteger(NitroChartID,"[WYFX.co][2:ADX::matriXx]"+PairInfo[i].Pair,OBJPROP_COLOR);
      if (fuADX2 == 7561050){
         PairInfo[i].NitroADX2 = 2;
         PairInfo[i].NitroOBPercentage += 8.33;
         PairInfo[i].NitroOSPercentage += 8.33;
      }else PairInfo[i].NitroADX2 = 0;
            
      // set CCI1
      fuCCI1 = ObjectGetInteger(NitroChartID,"[WYFX.co][1:CCI::matriXx]"+PairInfo[i].Pair,OBJPROP_COLOR);
      if (fuCCI1 == 1442032){
         PairInfo[i].NitroCCI1 = 1;
         PairInfo[i].NitroOBPercentage += 8.33;
      } else if (fuCCI1 == 15081020) {
         PairInfo[i].NitroCCI1 = -1;
         PairInfo[i].NitroOSPercentage += 8.33;
      } else PairInfo[i].NitroCCI1 = 0;
      
      // set CCI2
      fuCCI2 = ObjectGetInteger(NitroChartID,"[WYFX.co][2:CCI::matriXx]"+PairInfo[i].Pair,OBJPROP_COLOR);
      if (fuCCI2 == 1442032){
         PairInfo[i].NitroCCI2 = 1;
         PairInfo[i].NitroOBPercentage += 8.33;
      } else if (fuCCI2 == 15081020) {
         PairInfo[i].NitroCCI2 = -1;
         PairInfo[i].NitroOSPercentage += 8.33;
      } else PairInfo[i].NitroCCI2 = 0;
         
      // set MFI1
      fuMFI1 = ObjectGetInteger(NitroChartID,"[WYFX.co][1:MFI::matriXx]"+PairInfo[i].Pair,OBJPROP_COLOR);
      if (fuMFI1 == 1442032){
         PairInfo[i].NitroMFI1 = 1;
         PairInfo[i].NitroOBPercentage += 8.33;
      } else if (fuMFI1 == 15081020) {
         PairInfo[i].NitroMFI1 = -1;
         PairInfo[i].NitroOSPercentage += 8.33;
      } else PairInfo[i].NitroMFI1 = 0;
      
      // set MFI2
      fuMFI2 = ObjectGetInteger(NitroChartID,"[WYFX.co][2:MFI::matriXx]"+PairInfo[i].Pair,OBJPROP_COLOR);
      if (fuMFI2 == 1442032){ 
         PairInfo[i].NitroMFI2 = 1;
         PairInfo[i].NitroOBPercentage += 8.33;
      } else if (fuMFI2 == 15081020) {
         PairInfo[i].NitroMFI2 = -1;
         PairInfo[i].NitroOSPercentage += 8.33;
      } else PairInfo[i].NitroMFI2 = 0;
      
      // set RSI1
      fuRSI1 = ObjectGetInteger(NitroChartID,"[WYFX.co][1:RSI::matriXx]"+PairInfo[i].Pair,OBJPROP_COLOR);
      if (fuRSI1 == 1442032){
         PairInfo[i].NitroRSI1 = 1;
         PairInfo[i].NitroOBPercentage += 8.33;
      } else if (fuRSI1 == 15081020) {
         PairInfo[i].NitroRSI1 = -1;
         PairInfo[i].NitroOSPercentage += 8.33;
      } else PairInfo[i].NitroRSI1 = 0;
      
      // set RSI2
      fuRSI2 = ObjectGetInteger(NitroChartID,"[WYFX.co][2:RSI::matriXx]"+PairInfo[i].Pair,OBJPROP_COLOR);
      if (fuRSI2 == 1442032){
         PairInfo[i].NitroRSI2 = 1;
         PairInfo[i].NitroOBPercentage += 8.33;
      } else if (fuRSI2 == 15081020) {
         PairInfo[i].NitroRSI2 = -1;
         PairInfo[i].NitroOSPercentage += 8.33;
      } else PairInfo[i].NitroRSI2 = 0;
         
      // set STOCH1
      fuSTOCH1 = ObjectGetInteger(NitroChartID,"[WYFX.co][1:STOCH::matriXx]"+PairInfo[i].Pair,OBJPROP_COLOR);
      if (fuSTOCH1 == 1442032){ 
         PairInfo[i].NitroSTOCH1 = 1;
         PairInfo[i].NitroOBPercentage += 8.33;
      } else if (fuSTOCH1 == 15081020) {
         PairInfo[i].NitroSTOCH1 = -1;
         PairInfo[i].NitroOSPercentage += 8.33;
      } else PairInfo[i].NitroSTOCH1 = 0;
      
      // set STOCH2
      fuSTOCH2 = ObjectGetInteger(NitroChartID,"[WYFX.co][2:STOCH::matriXx]"+PairInfo[i].Pair,OBJPROP_COLOR);
      if (fuSTOCH2 == 1442032){
         PairInfo[i].NitroSTOCH2 = 1;
         PairInfo[i].NitroOBPercentage += 8.33;
      } else if (fuSTOCH2 == 15081020) {
         PairInfo[i].NitroSTOCH2 = -1;
         PairInfo[i].NitroOSPercentage += 8.33;
      } else PairInfo[i].NitroSTOCH2 = 0;
         
      // set WPR1
      fuWPR1 = ObjectGetInteger(NitroChartID,"[WYFX.co][1:WPR::matriXx]"+PairInfo[i].Pair,OBJPROP_COLOR);
      if (fuWPR1 == 1442032){
         PairInfo[i].NitroWPR1 = 1;
         PairInfo[i].NitroOBPercentage += 8.33;
      } else if (fuWPR1 == 15081020) {
         PairInfo[i].NitroWPR1 = -1;
         PairInfo[i].NitroOSPercentage += 8.33;
      } else PairInfo[i].NitroWPR1 = 0;
      
      // set WPR2
      fuWPR2 = ObjectGetInteger(NitroChartID,"[WYFX.co][2:WPR::matriXx]"+PairInfo[i].Pair,OBJPROP_COLOR);
      if (fuWPR2 == 1442032){
         PairInfo[i].NitroWPR2 = 1;
         PairInfo[i].NitroOBPercentage += 8.33;
      } else if (fuWPR2 == 15081020) {
         PairInfo[i].NitroWPR2 = -1;
         PairInfo[i].NitroOSPercentage += 8.33;
      } else PairInfo[i].NitroWPR2 = 0;
      
      PairInfo[i].NitroOSPercentage = MathRound(PairInfo[i].NitroOSPercentage / 10) * 10;
      PairInfo[i].NitroOBPercentage = MathRound(PairInfo[i].NitroOBPercentage / 10) * 10;
      
   }

   return;
}

//+------------------------------------------------------------------+
//| Get Chart ID for Nitro Chart.  If not found open it and get ID   |
//+------------------------------------------------------------------+
long GetNitroChartID(){
   long fuCurrChart;
   long fuNitroChart = 0;
   long fuPrevChart = ChartFirst();
   int fuI = 0;
   int fuLimit = 100;
   
   if (ChartSymbol(fuPrevChart) == NitroChart){ // first chart found is nitro chart
      fuNitroChart = fuPrevChart;
   } else {
      while(fuI < fuLimit){
         fuCurrChart = ChartNext(fuPrevChart);
         if (ChartSymbol(fuCurrChart) == NitroChart){ // nitro chart found
            fuNitroChart = fuCurrChart;
            break;
         }
         if(fuCurrChart < 0) break; // no more charts to cycle through
         fuPrevChart = fuCurrChart;
         fuI++;
      }
   }
   
   // nitro chart not found.  open new chart and apply template.
   if (fuNitroChart == 0){
      fuNitroChart = ChartOpen(NitroChart,Timeframe);
   }
   
   // apply template to Nitro Chart
   ChartApplyTemplate(fuNitroChart,NitroTemplate);
   
   return fuNitroChart;
}

//+------------------------------------------------------------------+
//| Get Open trades and direction                                    |
//+------------------------------------------------------------------+
string GetOpenTradesDirection(string fuInstrument, int fuArrayId){
   int fuFilehandle;
   string fuFilename = "FXtrade\\position-"+fuInstrument+".txt";
   string fuDirection;
   double fuAvgPrice = 0;
   
   if (FileIsExist(fuFilename)){
      
      fuFilehandle=FileOpen(fuFilename,FILE_READ|FILE_CSV,",");
      fuDirection = FileReadString(fuFilehandle);
      PairInfo[fuArrayId].OpenLotsize = int(FileReadString(fuFilehandle));
      fuAvgPrice = StringToDouble(FileReadString(fuFilehandle));
      FileClose(fuFilehandle);
      
      PairInfo[fuArrayId].TradeDirection = fuDirection;
      PairInfo[fuArrayId].AveragePrice = fuAvgPrice;
      
      if (fuDirection == "buy"){
         ObjectSetInteger(0,PairInfo[fuArrayId].Pair+"_Label2",OBJPROP_COLOR,clrBlanchedAlmond);
      } else if (fuDirection == "sell"){
         ObjectSetInteger(0,PairInfo[fuArrayId].Pair+"_Label2",OBJPROP_COLOR,clrBlanchedAlmond);
      } else {
         ObjectSetInteger(0,PairInfo[fuArrayId].Pair+"_Label2",OBJPROP_COLOR,C'85,85,85');
      }
      
      return fuDirection;
   } else {
      ObjectSetInteger(0,IntegerToString(fuArrayId)+"Pair1",OBJPROP_BGCOLOR,clrBlack);
      ObjectSetInteger(0,IntegerToString(fuArrayId)+"Pair1",OBJPROP_COLOR,clrDarkSlateGray);

      PairInfo[fuArrayId].OpenLotsize = 0;
      PairInfo[fuArrayId].Profit = 0;
      PairInfo[fuArrayId].LockLevel = -1;
      PairInfo[fuArrayId].LockProfit = -1;
      
      PairInfo[fuArrayId].TradeDirection = "none";
      return "none";
   } 
}

//+------------------------------------------------------------------+
//| Update Info                                                      |
//+------------------------------------------------------------------+
void UpdateInfo(){
   
   int fuFilehandle;
   string fuFilename;
   double fuRawLots;
   double fuPrice,fuM15Avg,fuH1Avg,fuH4Avg,fuD1Avg;
   
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
   
   // update minmax values
   for(int i=0;i<ArraySize(PairInfo);i++){
      fuFilename = "FXtrade\\minmax-"+PairInfo[i].FXtradeName+".txt";
      if (FileIsExist(fuFilename)){
         fuFilehandle=FileOpen(fuFilename,FILE_READ|FILE_CSV,",");
         
         PairInfo[i].MinPrice = StrToDouble(FileReadString(fuFilehandle));
         PairInfo[i].MaxPrice = StrToDouble(FileReadString(fuFilehandle));
         
         FileClose(fuFilehandle);
      } else {
         PairInfo[i].OpenLotsize = 0;
         PairInfo[i].MinPrice = 0;
         PairInfo[i].MaxPrice = 0;
      }
      GetOpenTradesDirection(PairInfo[i].FXtradeName,i);
      
      fuRawLots = NormalizeDouble(AccountBal / 3,0);

   }
   
   // update trend directions
   for(int i=0;i<ArraySize(PairInfo);i++){
      PairInfo[i].M15Trend = "none";
      PairInfo[i].H1Trend = "none";
      PairInfo[i].H4Trend = "none";
      PairInfo[i].D1Trend = "none";
      fuPrice = MarketInfo(PairInfo[i].Pair,MODE_BID);
      fuM15Avg = iMA(PairInfo[i].Pair,PERIOD_M15,12,0,MODE_SMA,PRICE_CLOSE,0);
      fuH1Avg =  iMA(PairInfo[i].Pair,PERIOD_H1,12,0,MODE_SMA,PRICE_CLOSE,0);
      fuH4Avg =  iMA(PairInfo[i].Pair,PERIOD_H4,12,0,MODE_SMA,PRICE_CLOSE,0);
      fuD1Avg =  iMA(PairInfo[i].Pair,PERIOD_D1,12,0,MODE_SMA,PRICE_CLOSE,0);
      if(fuPrice > fuM15Avg) PairInfo[i].M15Trend = "up";
         else if (fuPrice < fuM15Avg) PairInfo[i].M15Trend = "down";
      if(fuPrice > fuH1Avg) PairInfo[i].H1Trend = "up";
         else if (fuPrice < fuH1Avg) PairInfo[i].H1Trend = "down";
      if(fuPrice > fuH4Avg) PairInfo[i].H4Trend = "up";
         else if (fuPrice < fuH4Avg) PairInfo[i].H4Trend = "down";
      if(fuPrice > fuD1Avg) PairInfo[i].D1Trend = "up";
         else if (fuPrice < fuD1Avg) PairInfo[i].D1Trend = "down";
   }
   
   return;
}

//+------------------------------------------------------------------+
//| Update Dashboard                                                 |
//+------------------------------------------------------------------+
void UpdateDashboard(){
   
   double fuProfit;
   double fuTotalProfit = 0;
   double fuTotalLocked = 0;
   bool  fuLocked = false;
   int fuOrderCount = 0;
   string StrLots;
   
   ObjectSetText("AccountBalance","Account Balance: $"+DoubleToStr(AccountBal,2),7,NULL,C'136,136,136');
   ObjectSetText("AccountMargin","Margin Used / Avail: $"+DoubleToStr(UsedMargin,2)+" / $"+DoubleToStr(AvailMargin,2),7,NULL,C'136,136,136');
   ObjectSetText("AccountRealPL","Realized P/L: $"+DoubleToStr(RealizedPL,2),7,NULL,C'136,136,136');
   
   if (IsConnected() == true) ObjectSetInteger(0,"ExpertActive",OBJPROP_BGCOLOR,C'147,255,38');
      else ObjectSetInteger(0,"ExpertActive",OBJPROP_BGCOLOR,C'255,0,0');
   if (IsExpertEnabled() == true) ObjectSetInteger(0,"LiveTrading",OBJPROP_BGCOLOR,C'147,255,38');
      else ObjectSetInteger(0,"LiveTrading",OBJPROP_BGCOLOR,C'255,0,0');
   if (IsTradeAllowed() == true) ObjectSetInteger(0,"AutoTrading",OBJPROP_BGCOLOR,C'147,255,38');
      else ObjectSetInteger(0,"AutoTrading",OBJPROP_BGCOLOR,C'255,0,0');
   
   for(int i=0;i<ArraySize(PairInfo);i++){
      
      // Background
      if ((PairInfo[i].NitroGlobalDirection == "up")&&
         (PairInfo[i].NitroTitanDirection == "up")&&
         (PairInfo[i].NitroRVI == "up")&&
         (PairInfo[i].NitroOsMA == "up")&&
         (PairInfo[i].NitroMACD == "up")&&
         (PairInfo[i].NitroAO == "up")&&
         (PairInfo[i].NitroGlobal >= NitroGlobalMin)){
         ObjectSetInteger(0,PairInfo[i].Pair+"_BG",OBJPROP_BGCOLOR,C'0,64,32'); // green
      } else if ((PairInfo[i].NitroGlobalDirection == "down")&&
         (PairInfo[i].NitroTitanDirection == "down")&&
         (PairInfo[i].NitroRVI == "down")&&
         (PairInfo[i].NitroOsMA == "down")&&
         (PairInfo[i].NitroMACD == "down")&&
         (PairInfo[i].NitroAO == "down")&&
         (PairInfo[i].NitroGlobal >= NitroGlobalMin)){
         ObjectSetInteger(0,PairInfo[i].Pair+"_BG",OBJPROP_BGCOLOR,C'66,0,0'); // red
      } else {
         ObjectSetInteger(0,PairInfo[i].Pair+"_BG",OBJPROP_BGCOLOR,clrBlack); // black
      }
      
      // Spread
      ObjectSetText(PairInfo[i].Pair+"_Spread",DoubleToStr(MarketInfo(PairInfo[i].Pair,MODE_SPREAD)/10,1),9,NULL,clrOrange);
      
      // Global
      if (PairInfo[i].NitroGlobalDirection == "up"){
         ObjectSetString(0,PairInfo[i].Pair+"_GlobalArrow",OBJPROP_BMPFILE,0,ArrowUp);
         ObjectSetText(PairInfo[i].Pair+"_Global",IntegerToString(PairInfo[i].NitroGlobal),9,NULL,C'147,255,38');
      } else if (PairInfo[i].NitroGlobalDirection == "down"){
         ObjectSetString(0,PairInfo[i].Pair+"_GlobalArrow",OBJPROP_BMPFILE,0,ArrowDown);
         ObjectSetText(PairInfo[i].Pair+"_Global",IntegerToString(PairInfo[i].NitroGlobal),9,NULL,C'255,0,0');
      } else {
         ObjectSetString(0,PairInfo[i].Pair+"_GlobalArrow",OBJPROP_BMPFILE,0,Neutral);
         ObjectSetText(PairInfo[i].Pair+"_Global",IntegerToString(PairInfo[i].NitroGlobal),9,NULL,C'68,68,68');
      }
      
      // Titan
      if (PairInfo[i].NitroTitanDirection == "up"){
         ObjectSetString(0,PairInfo[i].Pair+"_TitanArrow",OBJPROP_BMPFILE,0,ArrowUp);
         ObjectSetText(PairInfo[i].Pair+"_Titan",IntegerToString(PairInfo[i].NitroTitan),9,NULL,C'147,255,38');
      } else if (PairInfo[i].NitroTitanDirection == "down"){
         ObjectSetString(0,PairInfo[i].Pair+"_TitanArrow",OBJPROP_BMPFILE,0,ArrowDown);
         ObjectSetText(PairInfo[i].Pair+"_Titan",IntegerToString(PairInfo[i].NitroTitan),9,NULL,C'255,0,0');
      } else {
         ObjectSetString(0,PairInfo[i].Pair+"_TitanArrow",OBJPROP_BMPFILE,0,Neutral);
         ObjectSetText(PairInfo[i].Pair+"_Titan",IntegerToString(PairInfo[i].NitroTitan),9,NULL,C'68,68,68');
      }
      
      // Strength
      ObjectSetText(PairInfo[i].Pair+"_Strength",IntegerToString(PairInfo[i].NitroSS1)+" "+IntegerToString(PairInfo[i].NitroSS2),9,NULL,C'147,255,38');
      
      // RVI
      if (PairInfo[i].NitroRVI == "up") ObjectSetString(0,PairInfo[i].Pair+"_RVIArrow",OBJPROP_BMPFILE,0,ArrowUp);
         else if (PairInfo[i].NitroRVI == "down") ObjectSetString(0,PairInfo[i].Pair+"_RVIArrow",OBJPROP_BMPFILE,0,ArrowDown);
         else  ObjectSetString(0,PairInfo[i].Pair+"_RVIArrow",OBJPROP_BMPFILE,0,Neutral);
      
      // MA
      if (PairInfo[i].NitroOsMA == "up") ObjectSetString(0,PairInfo[i].Pair+"_MAArrow",OBJPROP_BMPFILE,0,ArrowUp);
         else if (PairInfo[i].NitroOsMA == "down") ObjectSetString(0,PairInfo[i].Pair+"_MAArrow",OBJPROP_BMPFILE,0,ArrowDown);
         else  ObjectSetString(0,PairInfo[i].Pair+"_MAArrow",OBJPROP_BMPFILE,0,Neutral);
      
      // MA
      if (PairInfo[i].NitroMACD == "up") ObjectSetString(0,PairInfo[i].Pair+"_MACDArrow",OBJPROP_BMPFILE,0,ArrowUp);
         else if (PairInfo[i].NitroMACD == "down") ObjectSetString(0,PairInfo[i].Pair+"_MACDArrow",OBJPROP_BMPFILE,0,ArrowDown);
         else  ObjectSetString(0,PairInfo[i].Pair+"_MACDArrow",OBJPROP_BMPFILE,0,Neutral);
      
      // AO
      if (PairInfo[i].NitroAO == "up") ObjectSetString(0,PairInfo[i].Pair+"_AOArrow",OBJPROP_BMPFILE,0,ArrowUp);
         else if (PairInfo[i].NitroAO == "down") ObjectSetString(0,PairInfo[i].Pair+"_AOArrow",OBJPROP_BMPFILE,0,ArrowDown);
         else  ObjectSetString(0,PairInfo[i].Pair+"_AOArrow",OBJPROP_BMPFILE,0,Neutral);
         
      // ADX
      if (PairInfo[i].NitroADX1 == 2) ObjectSetInteger(0,PairInfo[i].Pair+"_ADX1",OBJPROP_BGCOLOR,C'38,201,255');
         else ObjectSetInteger(0,PairInfo[i].Pair+"_ADX1",OBJPROP_BGCOLOR,clrNONE);
      if (PairInfo[i].NitroADX2 == 2) ObjectSetInteger(0,PairInfo[i].Pair+"_ADX2",OBJPROP_BGCOLOR,C'38,201,255');
         else ObjectSetInteger(0,PairInfo[i].Pair+"_ADX2",OBJPROP_BGCOLOR,clrNONE);
      
      // Oversold
      if (PairInfo[i].NitroOSPercentage >= 50) ObjectSetText(PairInfo[i].Pair+"_Oversold",IntegerToString(PairInfo[i].NitroOSPercentage),9,NULL,C'38,201,255');
         else if (PairInfo[i].NitroOSPercentage > 10) ObjectSetText(PairInfo[i].Pair+"_Oversold",IntegerToString(PairInfo[i].NitroOSPercentage),9,NULL,C'100,100,255');
         else ObjectSetText(PairInfo[i].Pair+"_Oversold"," 0",9,NULL,C'68,68,68');
      // Overbought
      if (PairInfo[i].NitroOBPercentage >= 50) ObjectSetText(PairInfo[i].Pair+"_Overbought",IntegerToString(PairInfo[i].NitroOBPercentage),9,NULL,C'38,201,255');
         else if (PairInfo[i].NitroOBPercentage > 10) ObjectSetText(PairInfo[i].Pair+"_Overbought",IntegerToString(PairInfo[i].NitroOBPercentage),9,NULL,C'100,100,255');
         else ObjectSetText(PairInfo[i].Pair+"_Overbought"," 0",9,NULL,C'68,68,68');
      
      // HTF Trends
      if (PairInfo[i].M15Trend == "up") ObjectSetString(0,PairInfo[i].Pair+"_M15Arrow",OBJPROP_BMPFILE,0,ArrowUp);
         else if (PairInfo[i].M15Trend == "down") ObjectSetString(0,PairInfo[i].Pair+"_M15Arrow",OBJPROP_BMPFILE,0,ArrowDown);
         else ObjectSetString(0,PairInfo[i].Pair+"_M15Arrow",OBJPROP_BMPFILE,0,Neutral);
      if (PairInfo[i].H1Trend == "up") ObjectSetString(0,PairInfo[i].Pair+"_H1Arrow",OBJPROP_BMPFILE,0,ArrowUp);
         else if (PairInfo[i].H1Trend == "down") ObjectSetString(0,PairInfo[i].Pair+"_H1Arrow",OBJPROP_BMPFILE,0,ArrowDown);
         else ObjectSetString(0,PairInfo[i].Pair+"_H1Arrow",OBJPROP_BMPFILE,0,Neutral);
      if (PairInfo[i].H4Trend == "up") ObjectSetString(0,PairInfo[i].Pair+"_H4Arrow",OBJPROP_BMPFILE,0,ArrowUp);
         else if (PairInfo[i].H4Trend == "down") ObjectSetString(0,PairInfo[i].Pair+"_H4Arrow",OBJPROP_BMPFILE,0,ArrowDown);
         else ObjectSetString(0,PairInfo[i].Pair+"_H4Arrow",OBJPROP_BMPFILE,0,Neutral);
      if (PairInfo[i].D1Trend == "up") ObjectSetString(0,PairInfo[i].Pair+"_D1Arrow",OBJPROP_BMPFILE,0,ArrowUp);
         else if (PairInfo[i].D1Trend == "down") ObjectSetString(0,PairInfo[i].Pair+"_D1Arrow",OBJPROP_BMPFILE,0,ArrowDown);
         else ObjectSetString(0,PairInfo[i].Pair+"_D1Arrow",OBJPROP_BMPFILE,0,Neutral);
      
      // Manual Auto
      if (PairInfo[i].ManualAuto == "auto"){
         ObjectSetInteger(0,"Btn_Auto_"+PairInfo[i].Pair,OBJPROP_BGCOLOR,C'0,98,24');
         ObjectSetInteger(0,"Btn_Manual_"+PairInfo[i].Pair,OBJPROP_BGCOLOR,C'53,53,38');
      } else if (PairInfo[i].ManualAuto == "manual"){
         ObjectSetInteger(0,"Btn_Auto_"+PairInfo[i].Pair,OBJPROP_BGCOLOR,C'53,53,38');
         ObjectSetInteger(0,"Btn_Manual_"+PairInfo[i].Pair,OBJPROP_BGCOLOR,C'0,98,24');
      } else {
         PairInfo[i].ManualAuto = "manual";
         ObjectSetInteger(0,"Btn_Auto_"+PairInfo[i].Pair,OBJPROP_BGCOLOR,C'53,53,38');
         ObjectSetInteger(0,"Btn_Manual_"+PairInfo[i].Pair,OBJPROP_BGCOLOR,C'0,98,24');
      }
      
      fuProfit = 0;
      
      // Profit and Loss
      if(PairInfo[i].TradeDirection == "buy"){
         fuProfit = MarketInfo(PairInfo[i].Pair, MODE_TICKVALUE) * PairInfo[i].OpenLotsize * (MarketInfo(PairInfo[i].Pair,MODE_BID) - PairInfo[i].AveragePrice);
      } else if(PairInfo[i].TradeDirection == "sell"){
         fuProfit = MarketInfo(PairInfo[i].Pair, MODE_TICKVALUE) * PairInfo[i].OpenLotsize * (PairInfo[i].AveragePrice - MarketInfo(PairInfo[i].Pair,MODE_ASK));
      }
      if (StringFind(PairInfo[i].Pair,"JPY") >= 0){
         fuProfit = fuProfit / 100;
      }
      
      fuTotalProfit += fuProfit;
      PairInfo[i].Profit = fuProfit;
      
      // Units
      if (PairInfo[i].OpenLotsize > 0){
         fuOrderCount++;
         if (PairInfo[i].OpenLotsize >= 1000) StrLots = IntegerToString(PairInfo[i].OpenLotsize);
            else if ((PairInfo[i].OpenLotsize >= 100) && (PairInfo[i].OpenLotsize <= 999)) StrLots = "0"+IntegerToString(PairInfo[i].OpenLotsize);
            else if ((PairInfo[i].OpenLotsize >= 10) && (PairInfo[i].OpenLotsize <= 99)) StrLots = "00"+IntegerToString(PairInfo[i].OpenLotsize);
            else  StrLots = "000"+IntegerToString(PairInfo[i].OpenLotsize);
         if (PairInfo[i].TradeDirection == "buy"){
            ObjectSetText(PairInfo[i].Pair+"_LotsSell","0000",8,NULL,C'68,68,68');
            ObjectSetText(PairInfo[i].Pair+"_LotsBuy",StrLots,8,NULL,clrBlanchedAlmond);
            ObjectSetText(PairInfo[i].Pair+"_OrdersBuy",DoubleToStr(PairInfo[i].OpenLotsize/PairInfo[i].LotSize,0),8,NULL,clrBlanchedAlmond);
            ObjectSetText(PairInfo[i].Pair+"_OrdersSell","0",8,NULL,C'68,68,68');
            if (fuProfit > 0) ObjectSetText(PairInfo[i].Pair+"_BuyPrice",DoubleToStr(MathAbs(fuProfit),2),8,NULL,C'147,255,38');
               else if (fuProfit == 0) ObjectSetText(PairInfo[i].Pair+"_BuyPrice","0.00",8,NULL,C'147,255,38');
               else ObjectSetText(PairInfo[i].Pair+"_BuyPrice",DoubleToStr(MathAbs(fuProfit),2),8,NULL,C'255,0,0');
            ObjectSetText(PairInfo[i].Pair+"_SellPrice","0.00",8,NULL,C'68,68,68');
         } else if (PairInfo[i].TradeDirection == "sell"){
            ObjectSetText(PairInfo[i].Pair+"_LotsSell",StrLots,8,NULL,clrBlanchedAlmond);
            ObjectSetText(PairInfo[i].Pair+"_LotsBuy","0000",8,NULL,C'68,68,68');
            ObjectSetText(PairInfo[i].Pair+"_OrdersSell",DoubleToStr(PairInfo[i].OpenLotsize/PairInfo[i].LotSize,0),8,NULL,clrBlanchedAlmond);
            ObjectSetText(PairInfo[i].Pair+"_OrdersBuy","0",8,NULL,C'68,68,68');
            if (fuProfit > 0) ObjectSetText(PairInfo[i].Pair+"_SellPrice",DoubleToStr(MathAbs(fuProfit),2),8,NULL,C'147,255,38');
               else if (fuProfit == 0) ObjectSetText(PairInfo[i].Pair+"_SellPrice","0.00",8,NULL,C'147,255,38');
               else  ObjectSetText(PairInfo[i].Pair+"_SellPrice",DoubleToStr(MathAbs(fuProfit),2),8,NULL,C'255,0,0');
            ObjectSetText(PairInfo[i].Pair+"_BuyPrice","0.00",8,NULL,C'68,68,68');
         }
         if (fuProfit > 0) ObjectSetText(PairInfo[i].Pair+"_ProfitLoss",DoubleToStr(MathAbs(fuProfit),2),8,NULL,C'147,255,38');
               else if (fuProfit == 0) ObjectSetText(PairInfo[i].Pair+"_ProfitLoss","0.00",8,NULL,C'147,255,38');
               else  ObjectSetText(PairInfo[i].Pair+"_ProfitLoss",DoubleToStr(MathAbs(fuProfit),2),8,NULL,C'255,0,0');
         
         // lock level price
         if ((PairInfo[i].LockLevel > -1)&&(PairInfo[i].LockProfit != -1)){
            ObjectSetText(PairInfo[i].Pair+"_Locked",DoubleToStr(PairInfo[i].LockProfit,2),8,NULL,C'147,255,38');
            fuTotalLocked += PairInfo[i].LockProfit;
            fuLocked = true;
         } else {
            ObjectSetText(PairInfo[i].Pair+"_Locked","0,00",8,NULL,C'68,68,68');
         }
         
         // lock level buttons
            ObjectSetInteger(0,"Btn_Lock00_"+PairInfo[i].Pair,OBJPROP_BGCOLOR,C'85,85,85');
            ObjectSetInteger(0,"Btn_Lock25_"+PairInfo[i].Pair,OBJPROP_BGCOLOR,C'85,85,85');
            ObjectSetInteger(0,"Btn_Lock50_"+PairInfo[i].Pair,OBJPROP_BGCOLOR,C'85,85,85');
            ObjectSetInteger(0,"Btn_Lock75_"+PairInfo[i].Pair,OBJPROP_BGCOLOR,C'85,85,85');
         if (PairInfo[i].LockLevel == 0){
            ObjectSetInteger(0,"Btn_Lock00_"+PairInfo[i].Pair,OBJPROP_BGCOLOR,C'0,81,162');
         } else if (PairInfo[i].LockLevel == 25){
            ObjectSetInteger(0,"Btn_Lock25_"+PairInfo[i].Pair,OBJPROP_BGCOLOR,C'0,81,162');
         } else if (PairInfo[i].LockLevel == 50){
            ObjectSetInteger(0,"Btn_Lock50_"+PairInfo[i].Pair,OBJPROP_BGCOLOR,C'0,81,162');
         } else if (PairInfo[i].LockLevel == 75){
            ObjectSetInteger(0,"Btn_Lock75_"+PairInfo[i].Pair,OBJPROP_BGCOLOR,C'0,81,162');
         }
         
      } else {
         ObjectSetText(PairInfo[i].Pair+"_LotsSell","0000",8,NULL,C'68,68,68');
         ObjectSetText(PairInfo[i].Pair+"_LotsBuy","0000",8,NULL,C'68,68,68');
         ObjectSetText(PairInfo[i].Pair+"_OrdersSell","0",8,NULL,C'68,68,68');
         ObjectSetText(PairInfo[i].Pair+"_OrdersBuy","0",8,NULL,C'68,68,68');
         ObjectSetText(PairInfo[i].Pair+"_SellPrice","0.00",8,NULL,C'68,68,68');
         ObjectSetText(PairInfo[i].Pair+"_BuyPrice","0.00",8,NULL,C'68,68,68');
         ObjectSetText(PairInfo[i].Pair+"_ProfitLoss","0.00",8,NULL,C'68,68,68');
         ObjectSetText(PairInfo[i].Pair+"_Locked","0.00",8,NULL,C'68,68,68');
         ObjectSetInteger(0,PairInfo[i].Pair+"_Label2",OBJPROP_COLOR,C'85,85,85');
         ObjectSetInteger(0,"Btn_Lock00_"+PairInfo[i].Pair,OBJPROP_BGCOLOR,C'85,85,85');
         ObjectSetInteger(0,"Btn_Lock25_"+PairInfo[i].Pair,OBJPROP_BGCOLOR,C'85,85,85');
         ObjectSetInteger(0,"Btn_Lock50_"+PairInfo[i].Pair,OBJPROP_BGCOLOR,C'85,85,85');
         ObjectSetInteger(0,"Btn_Lock75_"+PairInfo[i].Pair,OBJPROP_BGCOLOR,C'85,85,85');
      }
      
   }
   if (fuOrderCount > 0){
      if (fuTotalProfit > 0) ObjectSetText("PandLText",DoubleToStr(fuTotalProfit,2),8,NULL,C'147,255,38');
         else if (fuTotalProfit == 0) ObjectSetText("PandLText","0.00",8,NULL,C'147,255,38');
         else ObjectSetText("PandLText",DoubleToStr(MathAbs(fuTotalProfit),2),8,NULL,C'255,0,0');
      if ((fuTotalLocked >= 0)&&(fuLocked)) ObjectSetText("LockText",DoubleToStr(fuTotalLocked,2),8,NULL,C'147,255,38');
         else ObjectSetText("LockText","0.00",8,NULL,C'68,68,68');
   } else {
      ObjectSetText("PandLText","0.00",8,NULL,C'68,68,68');
      ObjectSetText("LockText","0.00",8,NULL,C'68,68,68');
   }
   
   ObjectSetText("AccountEquity","Equity: $"+DoubleToStr(AccountBal+fuTotalProfit,2),7,NULL,C'136,136,136');
   
   return;
}

//================================================//
// Open a Chart for the given pair/timeframe      //
//================================================//
void OpenChart(string fuPair,int fuTimeframe){
   long fuChartID;
   
   fuChartID = ChartOpen(fuPair,fuTimeframe);
   if (fuChartID > 0){
      ChartApplyTemplate(fuChartID, "Candles.tpl");
   }
   
   return;
}

//================================================//
// Manual / Auto Buttons                          //
//================================================//
void SetManualAuto(string fuPair, string fuValue, int fuArrayID = NULL){
   if ((fuValue == "manual")&&(fuArrayID >= 0)){
      PairInfo[fuArrayID].ManualAuto = "manual";
   }
   if ((fuValue == "auto")&&(fuArrayID >= 0)){
      PairInfo[fuArrayID].ManualAuto = "auto";
   }
   if (fuValue == "manual-all"){
      for(int i=0;i<ArraySize(PairInfo);i++){
         PairInfo[i].ManualAuto = "manual";
      }
   }
   if (fuValue == "auto-all"){
      for(int i=0;i<ArraySize(PairInfo);i++){
         PairInfo[i].ManualAuto = "auto";
      }
   }
   return;
}

//================================================//
// Set Lock Price                                 //
//================================================//
bool SetLockPrice(string fuPair, int fuArrayID, int fuLockLevel){
   double fuLockPrice = (fuLockLevel * 0.01);
   // set break even price
   if (fuLockLevel == 0){
      if (PairInfo[fuArrayID].Profit > 0){
         PairInfo[fuArrayID].LockProfit = 0.00;
         return true;
      }
   } else if (fuLockLevel == 25){
      if (PairInfo[fuArrayID].Profit > 0){
         PairInfo[fuArrayID].LockProfit = NormalizeDouble(PairInfo[fuArrayID].Profit*0.25,2);
         return true;
      }
   } else if (fuLockLevel == 50){
      if (PairInfo[fuArrayID].Profit > 0){
         PairInfo[fuArrayID].LockProfit = NormalizeDouble(PairInfo[fuArrayID].Profit*0.50,2);
         return true;
      }
   } else if (fuLockLevel == 75){
      if (PairInfo[fuArrayID].Profit > 0){
         PairInfo[fuArrayID].LockProfit = NormalizeDouble(PairInfo[fuArrayID].Profit*0.75,2);
         return true;
      }
   } else {
      if (fuLockLevel > 0){
         if (PairInfo[fuArrayID].Profit > fuLockPrice){
            PairInfo[fuArrayID].LockProfit = fuLockPrice;
            return true;
         }
      }
   }
   return false;
}

//================================================//
// Close Locked Positions                         //
//================================================//
void CloseLocked(){
   for(int i=0;i<ArraySize(PairInfo);i++){
      if ((PairInfo[i].LockLevel > -1)&&(PairInfo[i].LockProfit != -1)){
         if (PairInfo[i].Profit <= PairInfo[i].LockProfit){
            ClosePosition(PairInfo[i].FXtradeName);
         }
      }
   }
}

//================================================//
// Execute Strategy Commands                      //
//================================================//
void RunStrategyCommand(string fuPair, int fuArrayID, string fuCommand){
   int fuUnits = 0;
   double fuProfits = 0.0;
   
   // close entire position
   if (fuCommand == "ClosePosition"){
      SendNotification(PairInfo[fuArrayID].Pair+" "+PairInfo[fuArrayID].TradeDirection+" closed: $"+DoubleToStr(PairInfo[fuArrayID].Profit,2));
      PairInfo[fuArrayID].TradePrice = 0;
      ClosePosition(PairInfo[fuArrayID].FXtradeName);
   }
   
   // partial close
   if (StringSubstr(fuCommand,0,12) == "PartialClose"){ // ex. PartialClose-500 (500 units)
      fuUnits = StringToInteger(StringSubstr(fuCommand,13,StringLen(fuCommand)));
      if (fuUnits > 0){
         if (fuUnits < PairInfo[fuArrayID].OpenLotsize){ // if trying to partial close more than available, just close.
            if (PairInfo[fuArrayID].TradeDirection == "buy"){
               OpenMarketOrder(PairInfo[fuArrayID].FXtradeName, "sell", fuUnits);
            } else if (PairInfo[fuArrayID].TradeDirection == "sell"){
               OpenMarketOrder(PairInfo[fuArrayID].FXtradeName, "buy", fuUnits);
            }
         } else {
            ClosePosition(PairInfo[fuArrayID].FXtradeName);
         }
      }
   }
   
   // reverse position
   if (StringSubstr(fuCommand,0,15) == "ReversePosition"){ // ReversePosition-200 (200 units)
      fuUnits = StringToInteger(StringSubstr(fuCommand,16,StringLen(fuCommand)));
      if (fuUnits > 0){
         SendNotification(PairInfo[fuArrayID].Pair+" "+PairInfo[fuArrayID].TradeDirection+" closed: $"+DoubleToStr(PairInfo[fuArrayID].Profit,2));
         if (PairInfo[fuArrayID].TradeDirection == "buy"){
            ClosePosition(PairInfo[fuArrayID].FXtradeName);
            Sleep(1000);
            OpenMarketOrder(PairInfo[fuArrayID].FXtradeName, "sell", fuUnits);
         } else if (PairInfo[fuArrayID].TradeDirection == "sell"){
            ClosePosition(PairInfo[fuArrayID].FXtradeName);
            Sleep(1000);
            OpenMarketOrder(PairInfo[fuArrayID].FXtradeName, "buy", fuUnits);
         }
      }                 
   }
   
   // set to break even
   if (fuCommand == "SetToBreakeven"){
      if (SetLockPrice(fuPair,fuArrayID,0)) PairInfo[fuArrayID].LockLevel = 999;
   }
   
   // lock in profits
   if (StringSubstr(fuCommand,0,10) == "LockProfit"){ // ex. LockProfit-200 (2.00)
      fuProfits = StringToDouble(StringSubstr(fuCommand,11,StringLen(fuCommand)));
      if (SetLockPrice(fuPair,fuArrayID,fuProfits)) PairInfo[fuArrayID].LockLevel = 999;
   }
   
   // buy
   if (StringSubstr(fuCommand,0,3) == "Buy"){ // ex. Buy-200 (200 Units)
      fuUnits = StringToInteger(StringSubstr(fuCommand,4,StringLen(fuCommand)));
      if (fuUnits > 0){
         if(AvailMargin > MinMargin){
            OpenMarketOrder(PairInfo[fuArrayID].FXtradeName, "buy", fuUnits);
         }
      }
   }
   
   // sell
   if (StringSubstr(fuCommand,0,4) == "Sell"){ // ex. Sell-200 (200 Units)
      fuUnits = StringToInteger(StringSubstr(fuCommand,5,StringLen(fuCommand)));
      if (fuUnits > 0){
         if(AvailMargin > MinMargin){
            OpenMarketOrder(PairInfo[fuArrayID].FXtradeName, "sell", fuUnits);
         }
      }
   }
}

//================================================//
// FXtrade Bridge Functions                       //
//================================================//
// create order file
bool OpenMarketOrder(string fuInstrument, string fuSide, int fuUnits){
   int fuFilehandle;
   bool fuOrder;
   string fuCommand = "openmarket-"+fuInstrument+"-"+fuSide+"-"+IntegerToString(fuUnits);
   LockDirectory();
   fuFilehandle=FileOpen("FXtrade\\"+fuCommand,FILE_WRITE|FILE_TXT);
   if(fuFilehandle!=INVALID_HANDLE){
      FileClose(fuFilehandle);
      fuOrder = True;
   } else fuOrder = False;
   UnlockDirectory();
   return fuOrder;
}

// create close file
bool CloseTrade(int fuNumber){
   int fuFilehandle;
   bool fuOrder;
   fuFilehandle=FileOpen("FXtrade\\close-"+IntegerToString(fuNumber),FILE_WRITE|FILE_TXT);
   LockDirectory();
   if(fuFilehandle!=INVALID_HANDLE){
      FileClose(fuFilehandle);
      fuOrder = True;
   } else fuOrder = False;
   UnlockDirectory();
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
                  OpenChart(PairInfo[i].Pair,PairInfo[i].Timeframe);
               }
            }
            ObjectSetInteger(0,sparam,OBJPROP_STATE,false);
            ChartRedraw();
         }
         // Pair Manual button
         if (StringSubstr(sparam,0,10) == "Btn_Manual") {
            fuPair = StringSubstr(sparam,11,6);
            for(int i=0;i<ArraySize(PairInfo);i++){
               if (PairInfo[i].Pair == fuPair){
                  SetManualAuto(fuPair, "manual", i);
               }
            }
            ObjectSetInteger(0,sparam,OBJPROP_STATE,false);
            ChartRedraw();
         }
         // Pair Auto button
         if (StringSubstr(sparam,0,8) == "Btn_Auto") {
            fuPair = StringSubstr(sparam,9,6);
            for(int i=0;i<ArraySize(PairInfo);i++){
               if (PairInfo[i].Pair == fuPair){
                  SetManualAuto(fuPair, "auto", i);
               }
            }
            ObjectSetInteger(0,sparam,OBJPROP_STATE,false);
            ChartRedraw();
         }
         // Manual All button
         if (StringSubstr(sparam,0,10) == "Btn_Manual") {
            if (StringLen(sparam) == 10){
               SetManualAuto("", "manual-all");
            }
            ObjectSetInteger(0,sparam,OBJPROP_STATE,false);
            ChartRedraw();
         }
         // Auto All button
         if (StringSubstr(sparam,0,8) == "Btn_Auto") {
            if (StringLen(sparam) == 8){
               SetManualAuto("", "auto-all");
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
      } else { // this is not a button
         ObjectSetInteger(0,sparam,OBJPROP_STATE,false);
         ChartRedraw();
      }
      
   }
}