//+------------------------------------------------------------------+
//|                                           ReverseQuantumDash.mq4 |
//|                                                   Lonnie Coffman |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Lonnie Coffman"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

string ArrowDown = "\\Images\\RedDot.bmp";
string ArrowUp = "\\Images\\GreenDot.bmp";
string ArrowBoth = "\\Images\\BlueDot.bmp";
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
string CloseButton = "\\Images\\CloseXButton.bmp";

struct pairinf {
   string   Pair;
   string   FXtradeName;
   int      Timeframe;
   int      LotSize;
   double   Spread;
   double   MaxSpread;
   double   MarginRequired;
   int      QuantumPeriod;
   double   ATRCoeficient;
   double   Risk;
   double   AdjustedRisk;
   int      OncePerQuant;
   bool     DirectionAdjusted;
   bool     UseATRTrail;
   bool     UseBBTrail;
   bool     Use3BarTrail;
   bool     UseParabolicTrail;
   double   ParabolicStep;
   double   ParabolicMax;
   bool     UsePortionClose;
   int      PortionClosePercent;
   int      PortionCloseDistance;
   bool     UseMartyTarget;
   bool     ExitOnClose;
   double   MartyTargetAdjust;
   bool     UseMartyLoss;
   double   MartyLossAdjust;
   bool     MartyLossIncrease;
   bool     UseTarget;
   bool     UseStop;
   int      PercentOfTarget;
   int      StopPercentOfTarget;
   int      HistoryLevels;
   bool     PairActive;
   int      LowQuant;
   int      HighQuant;
   
   double   StopLoss;
   double   InitialStop;
   double   InitialStopPips;
   double   Target;
   
   int      PrevNews;
   int      NextNews;
   
   int      WinningStreak;
   int      LosingStreak;
   
   string   Quantum1;
   string   Quantum2;
   
   double   ADR;
   double   ADRPips;
   double   Profit;
   double   Locked;
   double   ProfitPips;
   double   StopPips;
   string   QuantDir;
   string   TradeDirection;
   bool     TradeAllowed;
   int      TradeCount;
   int      OpenLotsize;
   double   AveragePrice;
   double   LowestTrade;
   double   HighestTrade;
   datetime BarTime;
   datetime NotificationTimer;
   bool     BackupExists;
   bool     PartialClose;
}; pairinf PairInfo[];

double AccountBal,AvailMargin,UsedMargin,RealizedPL;
int NumOpenTrades;
/*
string   TradePairs[] =          {"EURUSD", "GBPJPY", "EURAUD"  };
string   FXtradeNames[] =        {"EUR_USD","GBP_JPY","EUR_AUD" };
double   MaxSpread[] =           { 1.8,      3.8,      4.0      };
int      Timeframe[] =           { PERIOD_M5,PERIOD_M5,PERIOD_M5};
int      QuantumPeriod[] =       { 25,       24,       46       };
double   ATRCoeficient[] =       { 1.1,      2.2,      2.7      };
double   Risk[] =                { 3.0,      2.0,      2.0      };
bool     OncePerQuant[] =        { true,     true,     true     };
bool     UseATRTrail[] =         { true,     true,     true     };
bool     UseBBTrail[] =          { false,    false,    false    };
bool     UseMartyTarget[] =      { false,    false,    false    };
double   MartyTargetAdjust[] =   { 0.5,      0.5,      0.5      };
bool     UseMartyLoss[] =        { true,     false,    true     };
double   MartyLossAdjust[] =     { 0.7,      0.5,      0.5      };
bool     MartyLossIncrease[] =   { true,     false,    false    };
bool     UseTarget[] =           { false,    false,    false    };
bool     UseStop[] =             { false,    false,    false    };
int      PercentOfTarget[] =     { 50,       50,       50       };
int      StopPercentOfTarget[] = { 50,       50,       50       };
int      HistoryLevels[] =       { 20,       20,       20       };
bool     PairActive[] =          { true,     false,    false    };
*/
string   TradePairs[] =          {"EURUSD",  "USDJPY",   "GBPJPY",   "USDCAD",   "EURJPY" };
string   FXtradeNames[] =        {"EUR_USD", "USD_JPY",  "GBP_JPY",  "USD_CAD",  "EUR_JPY"};
double   MaxSpread[] =           { 1.8,      1.8,        1.8,        1.8,        1.8      };
double   MarginRequired[] =      { 2.0,      4.0,        5.0,        2.0,        4.0      }; // 7.7
int      Timeframe[] =           { PERIOD_H4,PERIOD_H4,  PERIOD_H4,  PERIOD_H4,  PERIOD_H4};
int      QuantumPeriod[] =       { 17,       11,         17,         16,         17       };
double   ATRCoeficient[] =       { 1.0,      1.0,        1.0,        1.0,        1.0      };
double   Risk[] =                { 5,        5,          10.0,       5.0,        5.0      };
int      OncePerQuant[] =        { 2,        1,          1,          1,          1        }; // 0 = any direction, 1 = once per quant, 2 = reset on NRTR flip
bool     UseATRTrail[] =         { true,     false,      false,      true,       false    };
bool     UseBBTrail[] =          { false,    false,      false,      false,      false    };
bool     Use3BarTrail[] =        { true,     true,       true,       false,      true     };
bool     UseParabolicTrail[] =   { true,     true,       true,       false,      true     };
double   ParabolicStep[] =       { 0.15,     0.15,       0.15,       0.15,       0.15     };
double   ParabolicMax[] =        { 0.3,      0.3,        0.3,        0.3,        0.3      };
bool     UsePortionClose[] =     { true,     true,       true,       true,       true     };
int      PortionClosePercent[] = { 50,       50,         50,         50,         50       };
int      PortionCloseDistance[] ={ 100,      100,        100,        100,        100      };
bool     ExitOnClose[] =         { false,    false,      false,      false,      false    }; // true = exit on close above/below, false = exit on touch
bool     UseMartyTarget[] =      { false,    false,      false,      false,      false    };
double   MartyTargetAdjust[] =   { 0.5,      0.5,        0.5,        0.5,        0.5      };
bool     UseMartyLoss[] =        { false,    false,      false,      false,      false    };
double   MartyLossAdjust[] =     { 0.7,      0.7,        0.7,        0.7,        0.7      };
bool     MartyLossIncrease[] =   { false,    false,      false,      false,      false    };
bool     UseTarget[] =           { false,    false,       false,      false,      false    };
bool     UseStop[] =             { false,    false,       false,      false,      false    };
int      PercentOfTarget[] =     { 50,       100,        100,        120,        100      };
int      StopPercentOfTarget[] = { 50,       50,         50,         25,         25       };
int      HistoryLevels[] =       { 20,       20,         20,         20,         20       };
bool     PairActive[] =          { true,     true,       true,       true,       true     };

int K = 5;
int D = 3;
int S = 3;
int OS = 20;
int OB = 80;
int qde = 325;

int   x_axis = 30;
int   y_axis = 70;
int   TextSize = 8;
int   HeaderTextSize = 8;
int   LabelTextSize = 7;
int   DashWidth = 1120;

string ChartTemplate = "Candles_dark.tpl";
double PLOffset = 0; // profit and loss offset

double LotMultiplier;

double CurrentProfit;
datetime NewsUpdate,AccountTimer;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(1);
   
   CurrentProfit = 0;
   AccountTimer = iTime(Symbol(),PERIOD_H1,1);

   Print(TimeHour(TimeLocal()));

   ArrayResize(PairInfo,ArraySize(TradePairs));
   for(int i=0;i<ArraySize(TradePairs);i++){
      PairInfo[i].Pair                 = TradePairs[i];
      PairInfo[i].FXtradeName          = FXtradeNames[i];
      PairInfo[i].MaxSpread            = MaxSpread[i];
      PairInfo[i].MarginRequired       = MarginRequired[i];
      PairInfo[i].Timeframe            = Timeframe[i];  
      PairInfo[i].QuantumPeriod        = QuantumPeriod[i];
      PairInfo[i].ATRCoeficient        = ATRCoeficient[i];
      PairInfo[i].Risk                 = Risk[i];
      PairInfo[i].OncePerQuant         = OncePerQuant[i];
      PairInfo[i].ExitOnClose          = ExitOnClose[i];
      PairInfo[i].DirectionAdjusted    = false;
      PairInfo[i].UseATRTrail          = UseATRTrail[i];
      PairInfo[i].UseBBTrail           = UseBBTrail[i];
      PairInfo[i].Use3BarTrail         = Use3BarTrail[i];
      PairInfo[i].UseParabolicTrail    = UseParabolicTrail[i];
      PairInfo[i].ParabolicStep        = ParabolicStep[i];
      PairInfo[i].ParabolicMax         = ParabolicMax[i];
      PairInfo[i].UsePortionClose      = UsePortionClose[i];
      PairInfo[i].PortionClosePercent  = PortionClosePercent[i];
      PairInfo[i].PortionCloseDistance = PortionCloseDistance[i];
      PairInfo[i].UseMartyTarget       = UseMartyTarget[i];
      PairInfo[i].MartyTargetAdjust    = MartyTargetAdjust[i];
      PairInfo[i].UseMartyLoss         = UseMartyLoss[i];
      PairInfo[i].MartyLossAdjust      = MartyLossAdjust[i];
      PairInfo[i].MartyLossIncrease    = MartyLossIncrease[i];
      PairInfo[i].UseTarget            = UseTarget[i];
      PairInfo[i].UseStop              = UseStop[i];
      PairInfo[i].PercentOfTarget      = PercentOfTarget[i];
      PairInfo[i].StopPercentOfTarget  = StopPercentOfTarget[i];
      PairInfo[i].HistoryLevels        = HistoryLevels[i];
      PairInfo[i].PairActive           = PairActive[i];

      PairInfo[i].WinningStreak        = 0;
      PairInfo[i].LosingStreak         = 0;
      
      PairInfo[i].Quantum1             = "none";
      PairInfo[i].Quantum2             = "none";
      
      PairInfo[i].TradeAllowed         = true;
      PairInfo[i].BarTime              = iTime(PairInfo[i].Pair,PairInfo[i].Timeframe,1);
      PairInfo[i].NotificationTimer    = iTime(Symbol(), PERIOD_M15, 0);
      PairInfo[i].BackupExists         = false;
      PairInfo[i].PartialClose         = true;
   }

   NewsUpdate = iTime(Symbol(), PERIOD_M1, 0);

   // ensure that all pairs are loaded in market watch window.
   for(int i=0;i<ArraySize(PairInfo);i++){
      SymbolSelect(PairInfo[i].Pair, true);
   }
   
   // import saved data
   for(int i=0;i<ArraySize(PairInfo);i++){
      ReadDataFile(i);
      ReadTradeFile(i);
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
   
   SetText ("BaseRiskLabel","Risk",x_axis+227,y_axis-20,C'68,68,68',LabelTextSize);
   SetText ("MartyRiskLabel","Marty+",x_axis+260,y_axis-20,C'68,68,68',LabelTextSize);
   SetText ("StreakLabel","Streak",x_axis+297,y_axis-20,C'68,68,68',LabelTextSize);
   SetText ("NextLabel","Next",x_axis+336,y_axis-20,C'68,68,68',LabelTextSize);
   SetText ("StopLabel","Stop Pips",x_axis+366,y_axis-20,C'68,68,68',LabelTextSize);
   SetText ("TargetLabel","Target Pips",x_axis+416,y_axis-20,C'68,68,68',LabelTextSize);
   
   SetText ("NewsLabel","News",x_axis+503,y_axis-30,C'68,68,68',LabelTextSize);
   SetText ("PrevNewsLabel","Prev",x_axis+486,y_axis-19,C'68,68,68',LabelTextSize);
   SetText ("NextNewsLabel","Next",x_axis+526,y_axis-19,C'68,68,68',LabelTextSize);
   
   SetText ("LotsLabel","Units",x_axis+673,y_axis-30,C'68,68,68',LabelTextSize);
   SetText ("LotsBuyLabel","Buy",x_axis+656,y_axis-19,C'68,68,68',LabelTextSize);
   SetText ("LotsSellLabel","Sell",x_axis+695,y_axis-19,C'68,68,68',LabelTextSize);
   SetText ("OrdersLabel","Orders",x_axis+737,y_axis-30,C'68,68,68',LabelTextSize);
   SetText ("OrdersBuyLabel","Buy",x_axis+731,y_axis-19,C'68,68,68',LabelTextSize);
   SetText ("OrdersSellLabel","Sell",x_axis+760,y_axis-19,C'68,68,68',LabelTextSize);
   SetText ("BuyPriceLabel","Buy",x_axis+809,y_axis-19,C'68,68,68',LabelTextSize);
   SetText ("SellPriceLabel","Sell",x_axis+861,y_axis-19,C'68,68,68',LabelTextSize);
   
   SetPanel("PandLBox",0,x_axis+905,y_axis-28,54,22,clrBlack,clrNONE,1);
   SetText ("PandLText","0.00",x_axis+910,y_axis-24,C'68,68,68',TextSize);
   
   SetText ("PipsLabel","Pips",x_axis+968,y_axis-19,C'68,68,68',LabelTextSize);
   
   SetPanel("LockBox",0,x_axis+1014,y_axis-28,47,22,clrBlack,clrNONE,1);
   SetText ("LockText","000.00",x_axis+1018,y_axis-24,C'68,68,68',TextSize);

   SetPanel("PercentBox",0,x_axis+1065,y_axis-28,48,22,clrBlack,clrNONE,1);
   SetText ("PercentText","000.0%",x_axis+1068,y_axis-24,C'68,68,68',TextSize);
   
   //SetText ("LockedLabel","Lock P/L",x_axis+1024,y_axis-19,C'68,68,68',LabelTextSize);
   //SetText ("LockPercentLabel","+/- %",x_axis+1084,y_axis-19,C'68,68,68',LabelTextSize);

   for(int i=0;i<ArraySize(PairInfo);i++){
      SetPanel(PairInfo[i].Pair+"_BG",0,x_axis-2,(i*26)+y_axis-5,1415,25,clrBlack,clrBlack,1);
      BitmapCreate("Btn_Chart_"+PairInfo[i].Pair,ChartButton,x_axis,(i*26)+y_axis+1);
      SetText(PairInfo[i].Pair+"_Label",PairInfo[i].Pair,x_axis+30,(i*26)+y_axis+1,clrBlanchedAlmond,TextSize);
      SetText(PairInfo[i].Pair+"_Spread","0.0",x_axis+100,(i*26)+y_axis+1,C'68,68,68',TextSize);
      
      SetText(PairInfo[i].Pair+"_Range1","000",x_axis+148,(i*26)+y_axis+1,C'68,68,68',TextSize);
      SetText(PairInfo[i].Pair+"_RangeDiv","/",x_axis+171,(i*26)+y_axis+1,C'128,128,128',TextSize+1);
      SetText(PairInfo[i].Pair+"_Range2","000",x_axis+178,(i*26)+y_axis+1,C'68,68,68',TextSize);
      
      SetPanel(PairInfo[i].Pair+"_VertDivider",0,x_axis+210,(i*26)+y_axis-5,2,26,C'85,85,85',C'45,83,121',3);
      
      SetText(PairInfo[i].Pair+"_BaseRisk",DoubleToStr(PairInfo[i].Risk,1),x_axis+230,(i*26)+y_axis+1,C'68,68,68',TextSize);
      SetText(PairInfo[i].Pair+"_MartyRisk","0.0",x_axis+263,(i*26)+y_axis+1,C'68,68,68',TextSize);
      SetText(PairInfo[i].Pair+"_Streak","0",x_axis+306,(i*26)+y_axis+1,C'68,68,68',TextSize);
      BitmapCreate("Img_Direction_"+PairInfo[i].Pair,Neutral,x_axis+342,(i*26)+y_axis+1);
      SetText(PairInfo[i].Pair+"_Stop","000.0",x_axis+375,(i*26)+y_axis+1,C'68,68,68',TextSize);
      SetText(PairInfo[i].Pair+"_Target","000.0",x_axis+425,(i*26)+y_axis+1,C'68,68,68',TextSize);
      
      SetText(PairInfo[i].Pair+"_PrevNews","0000",x_axis+486,(i*26)+y_axis+1,C'68,68,68',8);
      SetText(PairInfo[i].Pair+"_NextNews","0000",x_axis+526,(i*26)+y_axis+1,C'68,68,68',8);
      
      SetPanel(PairInfo[i].Pair+"_VertDivider2",0,x_axis+566,(i*26)+y_axis-5,2,26,C'85,85,85',C'45,83,121',3);

      SetText(PairInfo[i].Pair+"_Label2",PairInfo[i].Pair,x_axis+588,(i*26)+y_axis+2,C'85,85,85',TextSize);

      //BitmapCreate("Btn_Buy_"+PairInfo[i].Pair,BuyButton,x_axis+365,(i*26)+y_axis-1);
      //BitmapCreate("Btn_Sell_"+PairInfo[i].Pair,SellButton,x_axis+410,(i*26)+y_axis-1);
      
      SetText(PairInfo[i].Pair+"_LotsBuy","0000",x_axis+650,(i*26)+y_axis+1,C'68,68,68',TextSize);
      SetText(PairInfo[i].Pair+"_LotsSell","0000",x_axis+690,(i*26)+y_axis+1,C'68,68,68',TextSize);
      SetText(PairInfo[i].Pair+"_OrdersBuy","0",x_axis+737,(i*26)+y_axis+1,C'68,68,68',TextSize);
      SetText(PairInfo[i].Pair+"_OrdersSell","0",x_axis+765,(i*26)+y_axis+1,C'68,68,68',TextSize);
      SetText(PairInfo[i].Pair+"_BuyPrice","0.00",x_axis+806,(i*26)+y_axis+1,C'68,68,68',TextSize);
      SetText(PairInfo[i].Pair+"_SellPrice","0.00",x_axis+858,(i*26)+y_axis+1,C'68,68,68',TextSize);
      SetText(PairInfo[i].Pair+"_ProfitLoss","0.00",x_axis+910,(i*26)+y_axis+1,C'68,68,68',TextSize);
      SetText(PairInfo[i].Pair+"_Pips","0.0",x_axis+968,(i*26)+y_axis+2,C'68,68,68',TextSize);
      
      SetText(PairInfo[i].Pair+"_PLLocked","0.00",x_axis+1019,(i*26)+y_axis+1,C'68,68,68',TextSize);
      SetText(PairInfo[i].Pair+"_PLPercent","+0.0%",x_axis+1069,(i*26)+y_axis+1,C'68,68,68',TextSize);
      
      SetPanel(PairInfo[i].Pair+"_VertDivider3",0,x_axis+1006,(i*26)+y_axis-5,2,26,C'85,85,85',C'45,83,121',3);
      
      BitmapCreate("Btn_Close_"+PairInfo[i].Pair,CloseButton,x_axis+1126,(i*26)+y_axis-1);

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

   ObjectDelete(0,"BaseRiskLabel");
   ObjectDelete(0,"MartyRiskLabel");
   ObjectDelete(0,"StreakLabel");
   ObjectDelete(0,"NextLabel");
   ObjectDelete(0,"StopLabel");
   ObjectDelete(0,"TargetLabel");
   
   ObjectDelete(0,"NewsLabel");
   ObjectDelete(0,"PrevNewsLabel");
   ObjectDelete(0,"NextNewsLabel");

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
   
   ObjectDelete(0,"LockBox");
   ObjectDelete(0,"LockText");
   ObjectDelete(0,"PercentBox");
   ObjectDelete(0,"PercentText");
   
   for(int i=0;i<ArraySize(PairInfo);i++){
      ObjectDelete(0,PairInfo[i].Pair+"_BG");
      ObjectDelete(0,"Btn_Chart_"+PairInfo[i].Pair);
      ObjectDelete(0,PairInfo[i].Pair+"_Label");
      ObjectDelete(0,PairInfo[i].Pair+"_Spread");
      
      ObjectDelete(0,PairInfo[i].Pair+"_Range1");
      ObjectDelete(0,PairInfo[i].Pair+"_RangeDiv");
      ObjectDelete(0,PairInfo[i].Pair+"_Range2");
      
      ObjectDelete(0,PairInfo[i].Pair+"_BaseRisk");
      ObjectDelete(0,PairInfo[i].Pair+"_MartyRisk");
      ObjectDelete(0,PairInfo[i].Pair+"_Streak");
      ObjectDelete(0,"Img_Direction_"+PairInfo[i].Pair);
      ObjectDelete(0,PairInfo[i].Pair+"_Stop");
      ObjectDelete(0,PairInfo[i].Pair+"_Target");
      
      ObjectDelete(0,PairInfo[i].Pair+"_PrevNews");
      ObjectDelete(0,PairInfo[i].Pair+"_NextNews");
      
      ObjectDelete(0,"Btn_Buy_"+PairInfo[i].Pair);
      ObjectDelete(0,"Btn_Sell_"+PairInfo[i].Pair);
      
      ObjectDelete(0,PairInfo[i].Pair+"_LotsBuy");
      ObjectDelete(0,PairInfo[i].Pair+"_LotsSell");
      ObjectDelete(0,PairInfo[i].Pair+"_OrdersBuy");
      ObjectDelete(0,PairInfo[i].Pair+"_OrdersSell");
      ObjectDelete(0,PairInfo[i].Pair+"_BuyPrice");
      ObjectDelete(0,PairInfo[i].Pair+"_SellPrice");
      ObjectDelete(0,PairInfo[i].Pair+"_ProfitLoss");
      ObjectDelete(0,PairInfo[i].Pair+"_PLLocked");
      ObjectDelete(0,PairInfo[i].Pair+"_PLPercent");
      
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
   double ATRStop,BBStop,ATRPips,BBPips,ParabolicPips,StopPips,MinStop,ParabolicStop,TempStop,ThreeBarLevel,currentPSAR,currentPSARDirection,prevPSAR,prevPSARDirection;
   double TempTarget = EMPTY_VALUE;
   string filefind;
   int LotSize,LocalHour,PartialLots;
   
   UpdateInfo();
   UpdateDashboard();

   // loop through all pairs
   for(int i=0;i<ArraySize(PairInfo);i++){
      //Print(GetDownTarget(PairInfo[i].HistoryLevels,i));
      // if bridge_lock file does not exist continue
      if (FileIsExist(LockFilename) != true){

         search_handle = FileFindFirst("FXtrade\\*"+PairInfo[i].FXtradeName+"*",filefind);
         if(search_handle==INVALID_HANDLE){
            
            ReadDataFile(i);
            
            // look for new trades
            if (PairInfo[i].BarTime != iTime(PairInfo[i].Pair,PairInfo[i].Timeframe,0)){
               
               // do not open new trades within an hour before news and 30 minutes after news
               //if ((PairInfo[i].PrevNews > 30) && (PairInfo[i].NextNews > 60)){
               
                  if (!((PairInfo[i].LowQuant == 0) && (PairInfo[i].HighQuant == 0))){
                     
                     // check for ATR switch
                     if ((PairInfo[i].OncePerQuant == 2)&&(PairInfo[i].DirectionAdjusted == false)){
                        if((iCustom(PairInfo[i].Pair,PairInfo[i].Timeframe,"NRTR_ATR_STOP",20,PairInfo[i].ATRCoeficient,0,1) != EMPTY_VALUE)&&
                           (iCustom(PairInfo[i].Pair,PairInfo[i].Timeframe,"NRTR_ATR_STOP",20,PairInfo[i].ATRCoeficient,1,1) != EMPTY_VALUE)) PairInfo[i].DirectionAdjusted = true;
                     }
                     
                     // Open a buy order
                     if (PairInfo[i].HighQuant == 0){
                        PairInfo[i].Quantum2 = PairInfo[i].Quantum1;
                        PairInfo[i].Quantum1 = "buy";
                        WriteDataFile(i);
                        if (PairInfo[i].Quantum2 == ""){
                           PairInfo[i].BarTime = iTime(PairInfo[i].Pair,PairInfo[i].Timeframe,0);
                        
                        // 0 = any direction, 1 = once per quant, 2 = reset on NRTR flip
                        } else if ((PairInfo[i].OncePerQuant == 0)||
                                  ((PairInfo[i].OncePerQuant == 1)&&(PairInfo[i].Quantum1 != PairInfo[i].Quantum2))||
                                  ((PairInfo[i].OncePerQuant == 2)&&(PairInfo[i].DirectionAdjusted))||
                                  (PairInfo[i].BackupExists == false)){
                        //} else if (((PairInfo[i].Quantum1 != PairInfo[i].Quantum2)&&(PairInfo[i].OncePerQuant))||((!PairInfo[i].OncePerQuant)&&(iCustom(PairInfo[i].Pair,PairInfo[i].Timeframe,"Quantum - Stochastic OB_OS",PairInfo[i].QuantumPeriod,K,D,S,OS,OB,1,0)>0))||(PairInfo[i].DirectionAdjusted)){
                           if ((PairInfo[i].UseTarget)||(PairInfo[i].UseStop)) TempTarget = GetUpTarget(PairInfo[i].QuantumPeriod,i);
                           
                           if (PairInfo[i].UseTarget){
                              if (TempTarget == EMPTY_VALUE) PairInfo[i].Target = EMPTY_VALUE;
                                 else PairInfo[i].Target = NormalizeDouble(MarketInfo(PairInfo[i].Pair,MODE_BID) + ((TempTarget * (PairInfo[i].PercentOfTarget * 0.01))*MarketInfo(PairInfo[i].Pair,MODE_POINT)*10),int(MarketInfo(PairInfo[i].Pair,MODE_DIGITS)));
                           }
                           
                           if (PairInfo[i].UseStop){
                              StopPips = NormalizeDouble((TempTarget * (PairInfo[i].StopPercentOfTarget * 0.01)),1);
                              PairInfo[i].StopLoss = NormalizeDouble(MarketInfo(PairInfo[i].Pair,MODE_BID) - (StopPips*MarketInfo(PairInfo[i].Pair,MODE_POINT)*10),int(MarketInfo(PairInfo[i].Pair,MODE_DIGITS)));
                              
                           } else {
                           
                              // set initial StopLoss - ATR > BB > Parabolic
                              MinStop = AverageBar(20,i);
                              if (MinStop < 10) MinStop = 10;
                              ATRStop = iCustom(PairInfo[i].Pair,PairInfo[i].Timeframe,"NRTR_ATR_STOP",20,PairInfo[i].ATRCoeficient,0,1);
                              if (ATRStop == EMPTY_VALUE) ATRPips = 0;
                                 else ATRPips = NormalizeDouble((MarketInfo(PairInfo[i].Pair,MODE_ASK) - ATRStop) / MarketInfo(PairInfo[i].Pair,MODE_POINT) / 10, int(MarketInfo(PairInfo[i].Pair,MODE_DIGITS)));
                                 
                              BBStop = iCustom(PairInfo[i].Pair,PairInfo[i].Timeframe,"BB stops (new format) 1.2",3,1);
                              if (BBStop == EMPTY_VALUE) BBPips = 0;
                                 else BBPips = NormalizeDouble((MarketInfo(PairInfo[i].Pair,MODE_ASK) - BBStop) / MarketInfo(PairInfo[i].Pair,MODE_POINT) / 10, int(MarketInfo(PairInfo[i].Pair,MODE_DIGITS)));
                              
                              if (iCustom(PairInfo[i].Pair,PairInfo[i].Timeframe,"Parabolic",1,1) == 1.0) ParabolicStop = iCustom(PairInfo[i].Pair,PairInfo[i].Timeframe,"Parabolic",0,1);
                                 else ParabolicStop = EMPTY_VALUE;
                              if (ParabolicStop == EMPTY_VALUE) ParabolicPips = 0;
                                 else ParabolicPips = NormalizeDouble((MarketInfo(PairInfo[i].Pair,MODE_ASK) - ParabolicStop) / MarketInfo(PairInfo[i].Pair,MODE_POINT) / 10, int(MarketInfo(PairInfo[i].Pair,MODE_DIGITS)));
                              
                              if (ATRPips > MinStop){
                                 StopPips = ATRPips;
                                 PairInfo[i].StopLoss = NormalizeDouble(ATRStop,int(MarketInfo(PairInfo[i].Pair,MODE_DIGITS)));
                              } else if (BBPips > MinStop){
                                 StopPips = BBPips;
                                 PairInfo[i].StopLoss = NormalizeDouble(BBStop,int(MarketInfo(PairInfo[i].Pair,MODE_DIGITS)));
                              } else if (ParabolicPips > MinStop){
                                 StopPips = ParabolicPips;
                                 PairInfo[i].StopLoss = NormalizeDouble(ParabolicStop,int(MarketInfo(PairInfo[i].Pair,MODE_DIGITS)));
                              } else {
                                 StopPips = MinStop;
                                 PairInfo[i].StopLoss = NormalizeDouble(MarketInfo(PairInfo[i].Pair,MODE_ASK) - (MinStop * MarketInfo(PairInfo[i].Pair,MODE_POINT) * 10),int(MarketInfo(PairInfo[i].Pair,MODE_DIGITS)));
                              }
                           
                           }
   
                           if (PairInfo[i].Target != EMPTY_VALUE){
                              if (PairInfo[i].WinningStreak > 4) PairInfo[i].WinningStreak = 4;
                              if ((PairInfo[i].AdjustedRisk + (PairInfo[i].LosingStreak*PairInfo[i].MartyLossAdjust)) > 5) PairInfo[i].LosingStreak--;
                              
                              if ((PairInfo[i].WinningStreak > 0)&&(PairInfo[i].UseMartyTarget)) LotSize = int(GetLotSize(AccountBal, ArraySize(PairInfo), i));
                              else if ((PairInfo[i].LosingStreak > 0)&&(PairInfo[i].UseMartyLoss)&&(PairInfo[i].MartyLossIncrease == false)) LotSize = int(GetLotSize(AccountBal, ArraySize(PairInfo), i));
                              else if ((PairInfo[i].LosingStreak > 0)&&(PairInfo[i].UseMartyLoss)&&(PairInfo[i].MartyLossIncrease))LotSize = int(GetLotSize(AccountBal, ArraySize(PairInfo), i));
                              else LotSize = int(GetLotSize(AccountBal, ArraySize(PairInfo), i));
                              
                              OpenMarketOrder(PairInfo[i].FXtradeName, "buy", LotSize);
                              WriteTradeFile(i);
                              PairInfo[i].DirectionAdjusted = false;
                              PairInfo[i].PartialClose = false;
                              PairInfo[i].InitialStop = PairInfo[i].StopLoss;
                              PairInfo[i].InitialStopPips = NormalizeDouble((MarketInfo(PairInfo[i].Pair,MODE_BID) - PairInfo[i].StopLoss)/MarketInfo(PairInfo[i].Pair,MODE_POINT)/10,1);
                              SendNotification("New Trade: "+PairInfo[i].Pair);
                           }
                           PairInfo[i].BarTime = iTime(PairInfo[i].Pair,PairInfo[i].Timeframe,0);
                        }
                     // Open a sell order
                     } else if (PairInfo[i].LowQuant == 0){
                        PairInfo[i].Quantum2 = PairInfo[i].Quantum1;
                        PairInfo[i].Quantum1 = "sell";
                        WriteDataFile(i);

                        if (PairInfo[i].Quantum2 == ""){
                           PairInfo[i].BarTime = iTime(PairInfo[i].Pair,PairInfo[i].Timeframe,0);
                        // 0 = any direction, 1 = once per quant, 2 = reset on NRTR flip
                        } else if ((PairInfo[i].OncePerQuant == 0)||
                                  ((PairInfo[i].OncePerQuant == 1)&&(PairInfo[i].Quantum1 != PairInfo[i].Quantum2))||
                                  ((PairInfo[i].OncePerQuant == 2)&&(PairInfo[i].DirectionAdjusted))||
                                  (PairInfo[i].BackupExists == false)){
                        //} else if (((PairInfo[i].Quantum1 != PairInfo[i].Quantum2)&&(PairInfo[i].OncePerQuant))||((!PairInfo[i].OncePerQuant)&&(iCustom(PairInfo[i].Pair,PairInfo[i].Timeframe,"Quantum - Stochastic OB_OS",PairInfo[i].QuantumPeriod,K,D,S,OS,OB,0,0)>0))||(PairInfo[i].DirectionAdjusted)){
                           if ((PairInfo[i].UseTarget)||(PairInfo[i].UseStop)) TempTarget = GetDownTarget(PairInfo[i].QuantumPeriod,i);
                           
                           if (PairInfo[i].UseTarget){
                              if (TempTarget == EMPTY_VALUE) PairInfo[i].Target = EMPTY_VALUE;
                                 else PairInfo[i].Target = NormalizeDouble(MarketInfo(PairInfo[i].Pair,MODE_BID) - ((TempTarget * (PairInfo[i].PercentOfTarget * 0.01))*MarketInfo(PairInfo[i].Pair,MODE_POINT)*10),int(MarketInfo(PairInfo[i].Pair,MODE_DIGITS)));
                           }
                           
                           if (PairInfo[i].UseStop){
                              StopPips = NormalizeDouble((TempTarget * (PairInfo[i].StopPercentOfTarget * 0.01)),1);
                              PairInfo[i].StopLoss = NormalizeDouble(MarketInfo(PairInfo[i].Pair,MODE_BID) + (StopPips*MarketInfo(PairInfo[i].Pair,MODE_POINT)*10),int(MarketInfo(PairInfo[i].Pair,MODE_DIGITS)));
                              
                           } else {
                           
                              // set initial StopLoss - ATR > BB > Parabolic
                              MinStop = AverageBar(20,i);
                              if (MinStop < 10) MinStop = 10;
                              ATRStop = iCustom(PairInfo[i].Pair,PairInfo[i].Timeframe,"NRTR_ATR_STOP",20,PairInfo[i].ATRCoeficient,1,1);
                              if (ATRStop == EMPTY_VALUE) ATRPips = 0;
                                 else ATRPips = NormalizeDouble((ATRStop - MarketInfo(PairInfo[i].Pair,MODE_BID)) / MarketInfo(PairInfo[i].Pair,MODE_POINT) / 10, int(MarketInfo(PairInfo[i].Pair,MODE_DIGITS)));
                                 
                              BBStop = iCustom(PairInfo[i].Pair,PairInfo[i].Timeframe,"BB stops (new format) 1.2",4,1);
                              if (BBStop == EMPTY_VALUE) BBPips = 0;
                                 else BBPips = NormalizeDouble((BBStop - MarketInfo(PairInfo[i].Pair,MODE_BID)) / MarketInfo(PairInfo[i].Pair,MODE_POINT) / 10, int(MarketInfo(PairInfo[i].Pair,MODE_DIGITS)));
                              
                              if (iCustom(PairInfo[i].Pair,PairInfo[i].Timeframe,"Parabolic",1,1) == 0.0) ParabolicStop = iCustom(PairInfo[i].Pair,PairInfo[i].Timeframe,"Parabolic",0,1);
                                 else ParabolicStop = EMPTY_VALUE;
                              if (ParabolicStop == EMPTY_VALUE) ParabolicPips = 0;
                                 else ParabolicPips = NormalizeDouble((ParabolicStop - MarketInfo(PairInfo[i].Pair,MODE_BID)) / MarketInfo(PairInfo[i].Pair,MODE_POINT) / 10, int(MarketInfo(PairInfo[i].Pair,MODE_DIGITS)));
                              
                              if (ATRPips > MinStop){
                                 StopPips = ATRPips;
                                 PairInfo[i].StopLoss = NormalizeDouble(ATRStop,int(MarketInfo(PairInfo[i].Pair,MODE_DIGITS)));
                              } else if (BBPips > MinStop){
                                 StopPips = BBPips;
                                 PairInfo[i].StopLoss = NormalizeDouble(BBStop,int(MarketInfo(PairInfo[i].Pair,MODE_DIGITS)));
                              } else if (ParabolicPips > MinStop){
                                 StopPips = ParabolicPips;
                                 PairInfo[i].StopLoss = NormalizeDouble(ParabolicStop,int(MarketInfo(PairInfo[i].Pair,MODE_DIGITS)));
                              } else {
                                 StopPips = MinStop;
                                 PairInfo[i].StopLoss = NormalizeDouble(MarketInfo(PairInfo[i].Pair,MODE_BID) + (MinStop * MarketInfo(PairInfo[i].Pair,MODE_POINT) * 10),int(MarketInfo(PairInfo[i].Pair,MODE_DIGITS)));
                              }
                           
                           }
   
                           if (PairInfo[i].Target != EMPTY_VALUE){
                              if (PairInfo[i].WinningStreak > 4) PairInfo[i].WinningStreak = 4;
                              if ((PairInfo[i].AdjustedRisk + (PairInfo[i].LosingStreak*PairInfo[i].MartyLossAdjust)) > 5) PairInfo[i].LosingStreak--;
                              /*
                              if ((PairInfo[i].WinningStreak > 0)&&(PairInfo[i].UseMartyTarget)) LotSize = int(GetLotSize(PairInfo[i].AdjustedRisk + (PairInfo[i].WinningStreak*PairInfo[i].MartyTargetAdjust), StopPips, AccountBal,i) / ArraySize(PairInfo));
                              else if ((PairInfo[i].LosingStreak > 0)&&(PairInfo[i].UseMartyLoss)&&(PairInfo[i].MartyLossIncrease == false)) LotSize = int(GetLotSize(PairInfo[i].AdjustedRisk - (PairInfo[i].LosingStreak*PairInfo[i].MartyLossAdjust), StopPips, AccountBal,i) / ArraySize(PairInfo));
                              else if ((PairInfo[i].LosingStreak > 0)&&(PairInfo[i].UseMartyLoss)&&(PairInfo[i].MartyLossIncrease))LotSize = int(GetLotSize(PairInfo[i].AdjustedRisk + (PairInfo[i].LosingStreak*PairInfo[i].MartyLossAdjust), StopPips, AccountBal,i) / ArraySize(PairInfo));
                              else LotSize = int(GetLotSize(PairInfo[i].AdjustedRisk, StopPips, AccountBal,i) / ArraySize(PairInfo));
                              */
                              
                              if ((PairInfo[i].WinningStreak > 0)&&(PairInfo[i].UseMartyTarget)) LotSize = int(GetLotSize(AccountBal, ArraySize(PairInfo), i));
                              else if ((PairInfo[i].LosingStreak > 0)&&(PairInfo[i].UseMartyLoss)&&(PairInfo[i].MartyLossIncrease == false)) LotSize = int(GetLotSize(AccountBal, ArraySize(PairInfo), i));
                              else if ((PairInfo[i].LosingStreak > 0)&&(PairInfo[i].UseMartyLoss)&&(PairInfo[i].MartyLossIncrease))LotSize = int(GetLotSize(AccountBal, ArraySize(PairInfo), i));
                              else LotSize = int(GetLotSize(AccountBal, ArraySize(PairInfo), i));
                             
                              OpenMarketOrder(PairInfo[i].FXtradeName, "sell", LotSize);
                              WriteTradeFile(i);
                              PairInfo[i].DirectionAdjusted = false;
                              PairInfo[i].PartialClose = false;
                              PairInfo[i].InitialStop = PairInfo[i].StopLoss;
                              PairInfo[i].InitialStopPips = NormalizeDouble((PairInfo[i].StopLoss - MarketInfo(PairInfo[i].Pair,MODE_BID))/MarketInfo(PairInfo[i].Pair,MODE_POINT)/10,1);
                              SendNotification("New Trade: "+PairInfo[i].Pair);
                           }
                           PairInfo[i].BarTime = iTime(PairInfo[i].Pair,PairInfo[i].Timeframe,0);
                        }
                     }
                  }
               //}
            }
            
         } else {
            
            // Send Notifications
            if ((PairInfo[i].TradeDirection == "buy")||(PairInfo[i].TradeDirection == "sell")){
               LocalHour = TimeHour(TimeLocal());
               if ((LocalHour < 5)||(LocalHour >= 15)){ // only between 8am and 10pm
                  // Account Notifications
                  if (AccountTimer != iTime(Symbol(), PERIOD_M15, 0)){
                     SendNotification("B:$"+DoubleToStr(AccountBal,2)+" | P:$"+DoubleToStr(CurrentProfit,2)+" | "+IntegerToString(NumOpenTrades));
                     //SendNotification("B:$"+DoubleToStr(AccountBal,2)+" | P:$"+DoubleToStr(AccountBal+CurrentProfit,2));
                     AccountTimer = iTime(Symbol(), PERIOD_M15, 0);
                  }
                  // Trade Notifications
                  /*
                  if (PairInfo[i].NotificationTimer != iTime(Symbol(), PERIOD_M15, 0)){
                     if (PairInfo[i].Pair == "EURUSD")shortPair = "EU";
                     else if (PairInfo[i].Pair == "USDJPY")shortPair = "UJ";
                     else if (PairInfo[i].Pair == "GBPJPY")shortPair = "GJ";
                     else if (PairInfo[i].Pair == "USDCAD")shortPair = "UC";
                     else shortPair = "UK";
                     SendNotification(shortPair+":"+DoubleToStr(PairInfo[i].Profit,2)+"|"+DoubleToStr(PairInfo[i].StopPips,1)+"|"+DoubleToStr(PairInfo[i].Locked,2));
                     PairInfo[i].NotificationTimer = iTime(Symbol(), PERIOD_M15, 0);
                  }
                  */
               }
            }
           
            // manage open trades
            if (PairInfo[i].TradeDirection == "buy"){
               
               // Close trades 5 minutes before medium and high impact news regardless of profit or loss.
               //if ((PairInfo[i].NextNews <= 5) && (PairInfo[i].NextNews != EMPTY_VALUE)){
               //   ClosePosition(PairInfo[i].FXtradeName,i,PairInfo[i].TradeDirection);
               //} else {
               
                  TempStop = PairInfo[i].StopLoss;
                  
                  // adjust stop
                  if ((PairInfo[i].UseATRTrail)){
                     ATRStop = iCustom(PairInfo[i].Pair,PairInfo[i].Timeframe,"NRTR_ATR_STOP",20,PairInfo[i].ATRCoeficient,0,1);
                     if ((ATRStop != EMPTY_VALUE)&&(ATRStop > PairInfo[i].StopLoss)) PairInfo[i].StopLoss = ATRStop;
                     //Print(PairInfo[i].StopLoss);
                  }
                  
                  if (PairInfo[i].UseBBTrail){
                     BBStop = iCustom(PairInfo[i].Pair,PairInfo[i].Timeframe,"BB stops (new format) 1.2",3,1);
                        if ((BBStop != EMPTY_VALUE)&&(BBStop > PairInfo[i].StopLoss)) PairInfo[i].StopLoss = BBStop;
                  }
                  
                  if (PairInfo[i].Use3BarTrail){
                     ThreeBarLevel = iLow(PairInfo[i].Pair,PairInfo[i].Timeframe,iLowest(PairInfo[i].Pair,PairInfo[i].Timeframe,MODE_LOW,3,1)) - (1 * MarketInfo(PairInfo[i].Pair, MODE_POINT) * 10);
                     if (ThreeBarLevel > PairInfo[i].StopLoss) PairInfo[i].StopLoss = ThreeBarLevel;
                  }
                  
                  if (PairInfo[i].UseParabolicTrail){
                     currentPSAR = iCustom(PairInfo[i].Pair,PairInfo[i].Timeframe,"Parabolic_Mod",PairInfo[i].ParabolicStep,PairInfo[i].ParabolicMax,0,1);
                     currentPSARDirection = iCustom(PairInfo[i].Pair,PairInfo[i].Timeframe,"Parabolic_Mod",PairInfo[i].ParabolicStep,PairInfo[i].ParabolicMax,1,1);
                     prevPSAR = iCustom(PairInfo[i].Pair,PairInfo[i].Timeframe,"Parabolic_Mod",PairInfo[i].ParabolicStep,PairInfo[i].ParabolicMax,0,2);
                     prevPSARDirection = iCustom(PairInfo[i].Pair,PairInfo[i].Timeframe,"Parabolic_Mod",PairInfo[i].ParabolicStep,PairInfo[i].ParabolicMax,1,2);
                     if ((currentPSARDirection == 1.0) && (prevPSARDirection == 1.0)){
                        if ((currentPSAR < MarketInfo(PairInfo[i].Pair,MODE_BID)) && (currentPSAR > PairInfo[i].StopLoss)){
                           if (currentPSAR > 0) PairInfo[i].StopLoss = currentPSAR;
                        }
                     }
                  }
                  
                  if (PairInfo[i].StopLoss != TempStop) WriteTradeFile(i);
                  
                  // close on opposite signal
                  if (PairInfo[i].LowQuant == 0) ClosePosition(PairInfo[i].FXtradeName,i,PairInfo[i].TradeDirection);
                  /*
                  // half close @ 1:1 of initial stop
                  if ((PairInfo[i].UsePortionClose)&&(PairInfo[i].PartialClose == false)&&((PairInfo[i].InitialStopPips > 0)&&(PairInfo[i].InitialStopPips != EMPTY_VALUE))&&((PairInfo[i].AveragePrice > 0)&&(PairInfo[i].AveragePrice != EMPTY_VALUE))){
                     if (NormalizeDouble((MarketInfo(PairInfo[i].Pair,MODE_BID) - PairInfo[i].AveragePrice) / MarketInfo(PairInfo[i].Pair,MODE_POINT) / 10,1) >= (PairInfo[i].InitialStopPips*(PairInfo[i].PortionCloseDistance*0.01))){
                        PartialLots = int(NormalizeDouble(PairInfo[i].OpenLotsize*(PairInfo[i].PortionClosePercent * 0.01),0));
                        ClosePosition(PairInfo[i].FXtradeName,i,PairInfo[i].TradeDirection,PartialLots);
                        PairInfo[i].PartialClose = true;
                        SendNotification("Partial: "+PairInfo[i].Pair);
                     }
                  }
                  */
                  // stop hit
                  if (PairInfo[i].ExitOnClose){
                     ATRStop = iCustom(PairInfo[i].Pair,PairInfo[i].Timeframe,"NRTR_ATR_STOP",20,PairInfo[i].ATRCoeficient,0,1);
                     if ((ATRStop != EMPTY_VALUE)&&(ATRStop > 0)){
                        if (iClose(PairInfo[i].Pair,PairInfo[i].Timeframe,1) < ATRStop - (1 * MarketInfo(PairInfo[i].Pair, MODE_POINT) * 10)) ClosePosition(PairInfo[i].FXtradeName,i,PairInfo[i].TradeDirection);
                     }
                  } else {
                     if (MarketInfo(PairInfo[i].Pair,MODE_BID) <= PairInfo[i].StopLoss) ClosePosition(PairInfo[i].FXtradeName,i,PairInfo[i].TradeDirection);
                  }
                  
                  // target hit
                  if ((PairInfo[i].UseTarget)&&(PairInfo[i].Target != EMPTY_VALUE)){
                     if (MarketInfo(PairInfo[i].Pair,MODE_BID) >= PairInfo[i].Target) ClosePosition(PairInfo[i].FXtradeName,i,PairInfo[i].TradeDirection);
                  }
               //}
            }
            
            if (PairInfo[i].TradeDirection == "sell"){
               
               // Close trades 5 minutes before medium and high impact news regardless of profit or loss.
               //if ((PairInfo[i].NextNews <= 5) && (PairInfo[i].NextNews != EMPTY_VALUE)){
               //   ClosePosition(PairInfo[i].FXtradeName,i,PairInfo[i].TradeDirection);
               //} else {
               
                  TempStop = PairInfo[i].StopLoss;

                  // adjust stop
                  if ((PairInfo[i].UseATRTrail)){
                     ATRStop = iCustom(PairInfo[i].Pair,PairInfo[i].Timeframe,"NRTR_ATR_STOP",20,PairInfo[i].ATRCoeficient,1,1);
                     if ((ATRStop != EMPTY_VALUE)&&(ATRStop < PairInfo[i].StopLoss)) PairInfo[i].StopLoss = ATRStop;
                  }
                  
                  if (PairInfo[i].UseBBTrail){
                     BBStop = iCustom(PairInfo[i].Pair,PairInfo[i].Timeframe,"BB stops (new format) 1.2",4,1);
                        if ((BBStop != EMPTY_VALUE)&&(BBStop < PairInfo[i].StopLoss)) PairInfo[i].StopLoss = BBStop;
                  }
                  
                  if (PairInfo[i].Use3BarTrail){
                     ThreeBarLevel = iHigh(PairInfo[i].Pair,PairInfo[i].Timeframe,iHighest(PairInfo[i].Pair,PairInfo[i].Timeframe,MODE_HIGH,3,1)) + (1 * MarketInfo(PairInfo[i].Pair, MODE_POINT) * 10);
                     if (ThreeBarLevel < PairInfo[i].StopLoss) PairInfo[i].StopLoss = ThreeBarLevel;
                  }
                  
                  if (PairInfo[i].UseParabolicTrail){
                     currentPSAR = iCustom(PairInfo[i].Pair,PairInfo[i].Timeframe,"Parabolic_Mod",PairInfo[i].ParabolicStep,PairInfo[i].ParabolicMax,0,1);
                     currentPSARDirection = iCustom(PairInfo[i].Pair,PairInfo[i].Timeframe,"Parabolic_Mod",PairInfo[i].ParabolicStep,PairInfo[i].ParabolicMax,1,1);
                     prevPSAR = iCustom(PairInfo[i].Pair,PairInfo[i].Timeframe,"Parabolic_Mod",PairInfo[i].ParabolicStep,PairInfo[i].ParabolicMax,0,2);
                     prevPSARDirection = iCustom(PairInfo[i].Pair,PairInfo[i].Timeframe,"Parabolic_Mod",PairInfo[i].ParabolicStep,PairInfo[i].ParabolicMax,1,2);
                     if ((currentPSARDirection == 0.0) && (prevPSARDirection == 0.0)){
                        if ((currentPSAR > MarketInfo(PairInfo[i].Pair,MODE_BID)) && (currentPSAR < PairInfo[i].StopLoss)){
                           if (currentPSAR > 0) PairInfo[i].StopLoss = currentPSAR;
                        }
                     }
                  }
                  //Print(PairInfo[i].StopLoss);
                  if (PairInfo[i].StopLoss != TempStop) WriteTradeFile(i);
                  
                  // close on opposite signal
                  if (PairInfo[i].HighQuant == 0) ClosePosition(PairInfo[i].FXtradeName,i,PairInfo[i].TradeDirection);
                  
                  // half close @ 1:1 of initial stop
                  /*
                  if ((PairInfo[i].UsePortionClose)&&(PairInfo[i].PartialClose == false)&&((PairInfo[i].InitialStopPips > 0)&&(PairInfo[i].InitialStopPips != EMPTY_VALUE))&&((PairInfo[i].AveragePrice > 0)&&(PairInfo[i].AveragePrice != EMPTY_VALUE))){
                     if (NormalizeDouble((PairInfo[i].AveragePrice - MarketInfo(PairInfo[i].Pair,MODE_BID)) / MarketInfo(PairInfo[i].Pair,MODE_POINT) / 10,1) >= (PairInfo[i].InitialStopPips*(PairInfo[i].PortionCloseDistance*0.01))){
                        PartialLots = int(NormalizeDouble(PairInfo[i].OpenLotsize*(PairInfo[i].PortionClosePercent * 0.01),0));
                        ClosePosition(PairInfo[i].FXtradeName,i,PairInfo[i].TradeDirection,PartialLots);
                        PairInfo[i].PartialClose = true;
                        SendNotification("Partial: "+PairInfo[i].Pair);
                     }
                  }
                  */
                  // stop hit
                  if (PairInfo[i].ExitOnClose){
                     ATRStop = iCustom(PairInfo[i].Pair,PairInfo[i].Timeframe,"NRTR_ATR_STOP",20,PairInfo[i].ATRCoeficient,1,1);
                     if ((ATRStop != EMPTY_VALUE)&&(ATRStop > 0)){
                        if (iClose(PairInfo[i].Pair,PairInfo[i].Timeframe,1) > ATRStop + (1 * MarketInfo(PairInfo[i].Pair, MODE_POINT) * 10)) ClosePosition(PairInfo[i].FXtradeName,i,PairInfo[i].TradeDirection);
                     }
                  } else {
                     if (MarketInfo(PairInfo[i].Pair,MODE_BID) >= PairInfo[i].StopLoss) ClosePosition(PairInfo[i].FXtradeName,i,PairInfo[i].TradeDirection);
                  }
                  
                  // target hit
                  if ((PairInfo[i].UseTarget)&&(PairInfo[i].Target != EMPTY_VALUE)){
                     if (MarketInfo(PairInfo[i].Pair,MODE_ASK) <= PairInfo[i].Target) ClosePosition(PairInfo[i].FXtradeName,i,PairInfo[i].TradeDirection);
                  }
               //}
            }
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
   bool USD, EUR, GBP, NZD, JPY, AUD, CHF, CAD;
   string Pair1, Pair2;
   
   if (NewsUpdate != iTime(Symbol(), PERIOD_M1, 0)){
      for(int i=0;i<ArraySize(PairInfo);i++){
         // next / prev news
         Pair1 = StringSubstr(PairInfo[i].Pair,0,3);
         Pair2 = StringSubstr(PairInfo[i].Pair,3,3);
         
         if((Pair1 == "USD") || (Pair2 == "USD")) USD = true;
            else USD = false;
         if((Pair1 == "EUR") || (Pair2 == "EUR")) EUR = true;
            else EUR = false;
         if((Pair1 == "GBP") || (Pair2 == "GBP")) GBP = true;
            else GBP = false;
         if((Pair1 == "NZD") || (Pair2 == "NZD")) NZD = true;
            else NZD = false;
         if((Pair1 == "JPY") || (Pair2 == "JPY")) JPY = true;
            else JPY = false;
         if((Pair1 == "AUD") || (Pair2 == "AUD")) AUD = true;
            else AUD = false;
         if((Pair1 == "CHF") || (Pair2 == "CHF")) CHF = true;
            else CHF = false;
         if((Pair1 == "CAD") || (Pair2 == "CAD")) CAD = true;
            else CAD = false;
         PairInfo[i].PrevNews = int(iCustom(PairInfo[i].Pair,PERIOD_M15,"ffcal_net",true,false,true,0,USD,EUR,GBP,NZD,JPY,AUD,CHF,CAD,1,0));
         PairInfo[i].NextNews = int(iCustom(PairInfo[i].Pair,PERIOD_M15,"ffcal_net",true,false,true,0,USD,EUR,GBP,NZD,JPY,AUD,CHF,CAD,1,1));
      }
      NewsUpdate = iTime(Symbol(), PERIOD_M1, 0);
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
   
   for(int i=0;i<ArraySize(PairInfo);i++){
      
      PairInfo[i].Spread = MarketInfo(PairInfo[i].Pair,MODE_SPREAD)/10;
      
      // update quant bar
      PairInfo[i].LowQuant  = iLowest(PairInfo[i].Pair,PairInfo[i].Timeframe,MODE_LOW,PairInfo[i].QuantumPeriod,0);
      PairInfo[i].HighQuant = iHighest(PairInfo[i].Pair,PairInfo[i].Timeframe,MODE_HIGH,PairInfo[i].QuantumPeriod,0);
      
      // update adjusted risk
      PairInfo[i].AdjustedRisk = NormalizeDouble(PairInfo[i].Risk - ((AccountBal / ArraySize(PairInfo) / 10000)*0.1),2);
      if (PairInfo[i].AdjustedRisk < 0.5) PairInfo[i].AdjustedRisk = 0.5;
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
   
   double fuProfit,fuTotalProfit,fuStopPips,fuTargetPips,fuLocked,fuPercent,fuTotalLocked,fuTotalPercent;
   string fuSpacer,ADRstring,ADRpipsString,StrLots;
   color  fuSpreadColor,fuADRColor,NextNewsColor,PrevNewsColor;;
   
   fuTotalProfit = 0;
   fuTotalLocked = 0;
   fuTotalPercent = 0;
   fuStopPips = 0;
   
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
      
      // Streak PairInfo[i].Pair+"_Streak"
      if (PairInfo[i].WinningStreak > PairInfo[i].LosingStreak) ObjectSetText(PairInfo[i].Pair+"_Streak",IntegerToString(PairInfo[i].WinningStreak),TextSize,NULL,clrLimeGreen);
      else if (PairInfo[i].WinningStreak < PairInfo[i].LosingStreak) ObjectSetText(PairInfo[i].Pair+"_Streak","-"+IntegerToString(PairInfo[i].LosingStreak),TextSize,NULL,clrRed);
      else  ObjectSetText(PairInfo[i].Pair+"_Streak","00",TextSize,NULL,clrSteelBlue);
      
      // Base Risk
      ObjectSetText(PairInfo[i].Pair+"_BaseRisk",DoubleToStr(PairInfo[i].Risk,1),TextSize,NULL,clrSteelBlue);
      
      // Marty Risk
      if (PairInfo[i].LosingStreak > 1) ObjectSetText(PairInfo[i].Pair+"_MartyRisk","+"+DoubleToStr((PairInfo[i].LosingStreak)*PairInfo[i].MartyLossAdjust,1),TextSize,NULL,clrLimeGreen);
      else ObjectSetText(PairInfo[i].Pair+"_MartyRisk","+0.0",TextSize,NULL,clrSteelBlue);
      
      // Next Direction
      if ((PairInfo[i].OncePerQuant == 1)||((PairInfo[i].OncePerQuant == 2)&&(PairInfo[i].DirectionAdjusted == false))){
         if (PairInfo[i].Quantum2 == "sell") ObjectSetString(0,"Img_Direction_"+PairInfo[i].Pair,OBJPROP_BMPFILE,0,ArrowUp);
         else if (PairInfo[i].Quantum2 == "buy") ObjectSetString(0,"Img_Direction_"+PairInfo[i].Pair,OBJPROP_BMPFILE,0,ArrowDown);
         else ObjectSetString(0,"Img_Direction_"+PairInfo[i].Pair,OBJPROP_BMPFILE,0,ArrowBoth);
      } else if ((PairInfo[i].OncePerQuant == 2)&&(PairInfo[i].DirectionAdjusted)){
         ObjectSetString(0,"Img_Direction_"+PairInfo[i].Pair,OBJPROP_BMPFILE,0,ArrowBoth);
      } else {
         ObjectSetString(0,"Img_Direction_"+PairInfo[i].Pair,OBJPROP_BMPFILE,0,ArrowBoth);
      }
      
      // Stop Pips _Stop
      if (PairInfo[i].TradeDirection == "buy"){
         fuStopPips = NormalizeDouble((MarketInfo(PairInfo[i].Pair,MODE_BID) - PairInfo[i].StopLoss) /MarketInfo(PairInfo[i].Pair,MODE_POINT) /10,1);
         ObjectSetText(PairInfo[i].Pair+"_Stop",DoubleToStr(fuStopPips,1),TextSize,NULL,clrSteelBlue);
         PairInfo[i].StopPips = fuStopPips;
      } else if (PairInfo[i].TradeDirection == "sell"){
         fuStopPips = NormalizeDouble((PairInfo[i].StopLoss - MarketInfo(PairInfo[i].Pair,MODE_BID)) /MarketInfo(PairInfo[i].Pair,MODE_POINT) /10,1);
         ObjectSetText(PairInfo[i].Pair+"_Stop",DoubleToStr(fuStopPips,1),TextSize,NULL,clrSteelBlue);
         PairInfo[i].StopPips = fuStopPips;
      } else {
         ObjectSetText(PairInfo[i].Pair+"_Stop","000.0",TextSize,NULL,C'68,68,68');
         PairInfo[i].StopPips = 0.0;
      }
      
      // Target Pips _Target
      if ((PairInfo[i].UseTarget)&&(PairInfo[i].Target != EMPTY_VALUE)&&(PairInfo[i].TradeDirection != "none")){
         if (PairInfo[i].TradeDirection == "buy"){
            fuTargetPips = NormalizeDouble((PairInfo[i].Target - MarketInfo(PairInfo[i].Pair,MODE_ASK))/MarketInfo(PairInfo[i].Pair,MODE_POINT)/10,1);
            ObjectSetText(PairInfo[i].Pair+"_Target",DoubleToStr(fuTargetPips,1),TextSize,NULL,clrSteelBlue);
         } else if (PairInfo[i].TradeDirection == "sell"){
            fuTargetPips = NormalizeDouble((MarketInfo(PairInfo[i].Pair,MODE_ASK) - PairInfo[i].Target)/MarketInfo(PairInfo[i].Pair,MODE_POINT)/10,1);
            ObjectSetText(PairInfo[i].Pair+"_Target",DoubleToStr(fuTargetPips,1),TextSize,NULL,clrSteelBlue);
         }
      } else ObjectSetText(PairInfo[i].Pair+"_Target","000.0",TextSize,NULL,C'68,68,68');
      
      // Prev / Next News
      if (PairInfo[i].PrevNews <= 30) PrevNewsColor = clrOrangeRed;
         else PrevNewsColor = clrSteelBlue;
      if (PairInfo[i].NextNews <= 5) NextNewsColor = clrOrangeRed;
         else NextNewsColor = clrSteelBlue;
      if(PairInfo[i].PrevNews == 99999) ObjectSetText(PairInfo[i].Pair+"_PrevNews","----",8,NULL,PrevNewsColor);
         else ObjectSetText(PairInfo[i].Pair+"_PrevNews",IntegerToString(PairInfo[i].PrevNews),8,NULL,PrevNewsColor);
      if(PairInfo[i].NextNews == 99999) ObjectSetText(PairInfo[i].Pair+"_NextNews","----",8,NULL,NextNewsColor);
         else ObjectSetText(PairInfo[i].Pair+"_NextNews",IntegerToString(PairInfo[i].NextNews),8,NULL,NextNewsColor);
      
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
         if (PairInfo[i].ProfitPips == 0) fuLocked = 0;
            else fuLocked = NormalizeDouble((fuProfit / PairInfo[i].ProfitPips) * (PairInfo[i].ProfitPips - fuStopPips),2);
         if (fuLocked > 0){
            ObjectSetText(PairInfo[i].Pair+"_PLLocked",DoubleToStr(MathAbs(fuLocked),2),TextSize,NULL,C'147,255,38');
         } else if (fuLocked == 0){
            ObjectSetText(PairInfo[i].Pair+"_PLLocked","0.00",TextSize,NULL,C'147,255,38');
         } else {
            ObjectSetText(PairInfo[i].Pair+"_PLLocked","-"+DoubleToStr(MathAbs(fuLocked),2),TextSize,NULL,clrOrangeRed);
         }
         
         PairInfo[i].Locked = fuLocked;
         fuTotalLocked += fuLocked;
         
         fuPercent = NormalizeDouble(fuLocked / AccountBal,3);
         if (fuPercent >= 0) ObjectSetText(PairInfo[i].Pair+"_PLPercent","+"+DoubleToStr(fuPercent*100,1)+"%",TextSize,NULL,C'147,255,38');
            else  ObjectSetText(PairInfo[i].Pair+"_PLPercent",DoubleToStr(fuPercent*100,1)+"%",TextSize,NULL,clrOrangeRed);
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
         ObjectSetText(PairInfo[i].Pair+"_PLLocked","0.00",TextSize,NULL,C'68,68,68');
         ObjectSetText(PairInfo[i].Pair+"_PLPercent","+0.0%",TextSize,NULL,C'68,68,68');
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
   }
   
   ObjectSetText("AccountEquity","Equity: $"+DoubleToStr(AccountBal+fuTotalProfit,2),HeaderTextSize,NULL,C'136,136,136');
   
   if (NumOpenTrades > 0){
      // display total locked
      if (fuTotalLocked > 0){
         ObjectSetText("LockText",DoubleToStr(MathAbs(fuTotalLocked),2),TextSize,NULL,C'147,255,38');
      } else if (fuTotalLocked == 0){
         ObjectSetText("LockText","0.00",TextSize,NULL,C'147,255,38');
      } else {
         ObjectSetText("LockText","-"+DoubleToStr(MathAbs(fuTotalLocked),2),TextSize,NULL,clrOrangeRed);
      }
      
      fuTotalPercent = NormalizeDouble(fuTotalLocked / AccountBal,3);
      if (fuTotalPercent >= 0) ObjectSetText("PercentText","+"+DoubleToStr(fuTotalPercent*100,1)+"%",TextSize,NULL,C'147,255,38');
         else ObjectSetText("PercentText",DoubleToStr(fuTotalPercent*100,1)+"%",TextSize,NULL,clrOrangeRed);
   } else {
      ObjectSetText("LockText","000.00",TextSize,NULL,C'68,68,68');
      ObjectSetText("PercentText","00.0%",TextSize,NULL,C'68,68,68');
   }
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
// Get average bar size                           //
//================================================//
double AverageBar(int bars, int arrID){
   double totalBars = 0;
   int bar = 1;
   while (bar <= bars){
      totalBars += (iHigh(PairInfo[arrID].Pair,PairInfo[arrID].Timeframe,bar) - iLow(PairInfo[arrID].Pair,PairInfo[arrID].Timeframe,bar))/MarketInfo(PairInfo[arrID].Pair,MODE_POINT)/10;
      bar++;
   }
   return NormalizeDouble((totalBars / bars) * 1.5,1);
}

//================================================//
// Calculate Historical Target                    //
//================================================//
double GetUpTarget(int qPeriod, int arrID){
   double highest,lowest,total;
   int currentHigh,currentLow,bar,counter,endBar,finalBar;
   string prevBar,currBar;
   
   bar = 0;
   counter = 0;
   total = 0;
   endBar = 0;
   finalBar = 0;
   currBar = "none";
   
   while (bar < iBars(PairInfo[arrID].Pair,PairInfo[arrID].Timeframe)-1){
      
      currentHigh = iHighest(PairInfo[arrID].Pair,PairInfo[arrID].Timeframe,MODE_HIGH,qPeriod,bar);
      currentLow = iLowest(PairInfo[arrID].Pair,PairInfo[arrID].Timeframe,MODE_LOW,qPeriod,bar);
      
      if (currBar == "none"){
         if (bar == currentLow) currBar = "down";
      } else {
         
         if (bar == currentHigh){
            finalBar = bar;
            prevBar = currBar;
            currBar = "up";
         }
         if (bar == currentLow){
            prevBar = currBar;
            currBar = "down";
         }
         
         // end up move
         if ((prevBar == "down")&&(currBar == "up")){
            endBar = bar;
            if (endBar != 0) prevBar = "up";
         }
         
         // begin up move
         if ((prevBar == "up")&&(currBar == "down")){
            //highest = High[iHighest(PairInfo[arrID].Pair,PairInfo[arrID].Timeframe,MODE_HIGH,bar-endBar,endBar)];
            highest = iHigh(PairInfo[arrID].Pair,PairInfo[arrID].Timeframe,iHighest(PairInfo[arrID].Pair,PairInfo[arrID].Timeframe,MODE_HIGH,bar-endBar,endBar));
            //lowest = High[iHighest(PairInfo[arrID].Pair,PairInfo[arrID].Timeframe,MODE_HIGH,qPeriod,finalBar+1)];
            lowest = iHigh(PairInfo[arrID].Pair,PairInfo[arrID].Timeframe,iHighest(PairInfo[arrID].Pair,PairInfo[arrID].Timeframe,MODE_HIGH,qPeriod,finalBar+1));
            total = total + MathAbs(highest-lowest)/MarketInfo(PairInfo[arrID].Pair,MODE_POINT)/10;
            prevBar = "down";
            counter++;
         }
         
      }

      if (counter == PairInfo[arrID].HistoryLevels) break;
      bar++;
   }
   if (counter == PairInfo[arrID].HistoryLevels) return NormalizeDouble(total/counter,1);
   else return EMPTY_VALUE;
}

double GetDownTarget(int qPeriod, int arrID){
   double highest,lowest,total;
   int currentHigh,currentLow,bar,counter,endBar,finalBar;
   string prevBar,currBar;
   
   bar = 0;
   counter = 0;
   total = 0;
   endBar = 0;
   finalBar = 0;
   currBar = "none";
   
   while (bar < iBars(PairInfo[arrID].Pair,PairInfo[arrID].Timeframe)-1){
      
      currentHigh = iHighest(PairInfo[arrID].Pair,PairInfo[arrID].Timeframe,MODE_HIGH,qPeriod,bar);
      currentLow = iLowest(PairInfo[arrID].Pair,PairInfo[arrID].Timeframe,MODE_LOW,qPeriod,bar);
      
      if (currBar == "none"){
         if (bar == currentHigh) currBar = "up";
      } else {
         
         if (bar == currentLow){
            finalBar = bar;
            prevBar = currBar;
            currBar = "down";
         }
         if (bar == currentHigh){
            prevBar = currBar;
            currBar = "up";
         }
         
         // end down move
         if ((prevBar == "up")&&(currBar == "down")){
            endBar = bar;
            prevBar = "down";
         }
         
         // begin up move
         if ((prevBar == "down")&&(currBar == "up")){
            //lowest = Low[iLowest(PairInfo[arrID].Pair,PairInfo[arrID].Timeframe,MODE_LOW,bar-endBar,endBar)];
            lowest = iLow(PairInfo[arrID].Pair,PairInfo[arrID].Timeframe,iLowest(PairInfo[arrID].Pair,PairInfo[arrID].Timeframe,MODE_LOW,bar-endBar,endBar));
            //highest = Low[iLowest(PairInfo[arrID].Pair,PairInfo[arrID].Timeframe,MODE_LOW,qPeriod,finalBar+1)];
            highest = iLow(PairInfo[arrID].Pair,PairInfo[arrID].Timeframe,iLowest(PairInfo[arrID].Pair,PairInfo[arrID].Timeframe,MODE_LOW,qPeriod,finalBar+1));
            total = total + MathAbs(highest-lowest)/MarketInfo(PairInfo[arrID].Pair,MODE_POINT)/10;
            prevBar = "up";
            counter++;
         }
         
      }

      if (counter == PairInfo[arrID].HistoryLevels) break;
      bar++;
   }
   if (counter == PairInfo[arrID].HistoryLevels) return NormalizeDouble(total/counter,1);
   else return EMPTY_VALUE;
}
//================================================//
// Read and Write Trade File                      //
//================================================//
void WriteTradeFile(int arrID){
   int filehandle;
   string filename = "entry-"+PairInfo[arrID].FXtradeName+".txt";
   string stop,target;
   
   // stop,target,win,lose
   if ((PairInfo[arrID].StopLoss == 0)||(PairInfo[arrID].StopLoss == EMPTY_VALUE)||(PairInfo[arrID].StopLoss == NULL)) stop = DoubleToStr(0.0,int(MarketInfo(PairInfo[arrID].Pair,MODE_DIGITS)));
   else stop = DoubleToStr(PairInfo[arrID].StopLoss,int(MarketInfo(PairInfo[arrID].Pair,MODE_DIGITS)));
   
   if ((PairInfo[arrID].Target == 0)||(PairInfo[arrID].Target == EMPTY_VALUE)||(PairInfo[arrID].Target == NULL)) target = DoubleToStr(0.0,int(MarketInfo(PairInfo[arrID].Pair,MODE_DIGITS)));
   else target = DoubleToStr(PairInfo[arrID].Target,int(MarketInfo(PairInfo[arrID].Pair,MODE_DIGITS)));
   
   // write file
   filehandle=FileOpen("FXtrade\\"+filename,FILE_READ|FILE_WRITE|FILE_CSV,",");
   if(filehandle==INVALID_HANDLE){
      filehandle=FileOpen("FXtrade\\"+filename,FILE_READ|FILE_WRITE|FILE_CSV,",");
   }
   if(filehandle!=INVALID_HANDLE){
      FileWrite(filehandle,stop,target);
   }
   FileClose(filehandle);
}

void ReadTradeFile(int arrID){
   int filehandle;
   string filename = "FXtrade\\entry-"+PairInfo[arrID].FXtradeName+".txt";
   string stop,target;

   if (FileIsExist(filename)){
      filehandle=FileOpen(filename,FILE_READ|FILE_CSV,",");
      stop = FileReadString(filehandle);
      target = FileReadString(filehandle);
      FileClose(filehandle);
   
      PairInfo[arrID].StopLoss = NormalizeDouble(StringToDouble(stop),int(MarketInfo(PairInfo[arrID].Pair,MODE_DIGITS)));
      PairInfo[arrID].Target = NormalizeDouble(StringToDouble(target),int(MarketInfo(PairInfo[arrID].Pair,MODE_DIGITS)));
   
   }
}

//================================================//
// Read and Write Data File                       //
//================================================//
void WriteDataFile(int arrID){
   int filehandle;
   string filename = "data-"+PairInfo[arrID].Pair+".txt";
   string q1,q2,win,lose;
   
   if (PairInfo[arrID].Quantum1 == "buy") q1 = "1";
   else if (PairInfo[arrID].Quantum1 == "sell") q1 = "2";
   else q1 = "0";
   
   if (PairInfo[arrID].Quantum2 == "buy") q2 = "1";
   else if (PairInfo[arrID].Quantum2 == "sell") q2 = "2";
   else q2 = "0";
   
   win =  IntegerToString(PairInfo[arrID].WinningStreak,2,'0');
   lose = IntegerToString(PairInfo[arrID].LosingStreak, 2,'0');

   // write file
   filehandle=FileOpen("FXtrade\\"+filename,FILE_READ|FILE_WRITE|FILE_CSV,",");
   if(filehandle==INVALID_HANDLE){
      filehandle=FileOpen("FXtrade\\"+filename,FILE_READ|FILE_WRITE|FILE_CSV,",");
   }
   if(filehandle!=INVALID_HANDLE){
      FileWrite(filehandle,q1,q2,win,lose);
   }
   FileClose(filehandle);
}

void ReadDataFile(int arrID){
   int filehandle;
   string filename = "FXtrade\\data-"+PairInfo[arrID].Pair+".txt";
   string q1,q2,win,lose;

   if (FileIsExist(filename)){
      filehandle=FileOpen(filename,FILE_READ|FILE_CSV,",");
      q1 = FileReadString(filehandle);
      q2 = FileReadString(filehandle);
      win = FileReadString(filehandle);
      lose = FileReadString(filehandle);
      FileClose(filehandle);
      
      if (q1 == "1") PairInfo[arrID].Quantum1 = "buy";
         else if (q1 == "2") PairInfo[arrID].Quantum1 = "sell";
         else PairInfo[arrID].Quantum1 = "none";
      
      if (q2 == "1") PairInfo[arrID].Quantum2 = "buy";
         else if (q2 == "2") PairInfo[arrID].Quantum2 = "sell";
         else PairInfo[arrID].Quantum2 = "none";
      
      PairInfo[arrID].WinningStreak = int(StringToInteger(win));
      PairInfo[arrID].LosingStreak = int(StringToInteger(lose));
      PairInfo[arrID].BackupExists = true;
   } else PairInfo[arrID].BackupExists = false;
}

//================================================//
// Calculate Lot Size                             //
//================================================//
/*
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

int GetLotSize(double riskPercent, double pips, double balance, int arrID){
   
   // using balance rather than avail margin for use with multiple pairs.
   double TickValue = MarketInfo(PairInfo[arrID].Pair,MODE_TICKVALUE);
   double LotStep=MarketInfo(PairInfo[arrID].Pair,MODE_LOTSTEP);
   
   double SLPts=pips*MarketInfo(PairInfo[arrID].Pair,MODE_POINT)*10;
   SLPts = int(SLPts * GetPipFactor(PairInfo[arrID].Pair) * 10);

   double Exposure=SLPts*TickValue; // Exposure based on 1 full lot

   double AllowedExposure=(balance*riskPercent)/100;

   double TotalSteps = (AllowedExposure / Exposure) / LotStep;
   double LotSize = TotalSteps * LotStep;

   double MinLots = MarketInfo(PairInfo[arrID].Pair,MODE_MINLOT);
   double MaxLots = MarketInfo(PairInfo[arrID].Pair,MODE_MAXLOT);

   if(LotSize < MinLots) LotSize = MinLots;
   if(LotSize > MaxLots) LotSize = MaxLots;
   return(int(NormalizeDouble(LotSize*100000,0)));
}
*/
int GetLotSize(double balance, int numTrades, int arrID){
   double Multiplier = .059; // total of MarginRequired / 100
   
   double leverage = 100 / PairInfo[arrID].MarginRequired;
   //double margin = (balance * 0.9) / numTrades;
   double margin = (balance * 0.9) * (PairInfo[arrID].MarginRequired * Multiplier);
   
   // do not use more margin than is available
   // if (margin > AvailMargin) margin = AvailMargin * 0.95;
   //if (margin > AvailMargin) margin = (AvailMargin * 0.95) / numTrades;
   if (margin > AvailMargin) margin = (AvailMargin * 0.95)  * (PairInfo[arrID].MarginRequired * Multiplier);
   
   double basePrice;
   int volume;
   
   string base =  StringSubstr(PairInfo[arrID].Pair,0,3);
   string home = "USD";
   
   if (base == "USD") basePrice = 1;
   else basePrice = NormalizeDouble(MarketInfo(base+"USD",MODE_BID),int(MarketInfo(base+"USD",MODE_DIGITS)));
   
   if (basePrice == 0) basePrice = NormalizeDouble(1 / MarketInfo("USD"+base,MODE_BID),int(MarketInfo(base+"USD",MODE_DIGITS)));
   if (basePrice == 0) return -1;
   
   volume = int((margin * leverage) / basePrice);
   return volume;
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
bool ClosePosition(string fuInstrument, int arrID, string fuSide, int fuUnits=0){
   if (PairInfo[arrID].Profit > 0){
      PairInfo[arrID].WinningStreak++;
      PairInfo[arrID].LosingStreak = 0;
   } else {
      PairInfo[arrID].LosingStreak++;
      PairInfo[arrID].WinningStreak = 0;
   }
   WriteDataFile(arrID);
   int fuFilehandle;
   fuFilehandle=FileOpen("FXtrade\\close-"+fuInstrument+"-"+fuSide+"-"+IntegerToString(fuUnits),FILE_WRITE|FILE_TXT);
   if(fuFilehandle!=INVALID_HANDLE){
      FileClose(fuFilehandle);
      if (fuUnits == 0) SendNotification("Closed: "+PairInfo[arrID].Pair);
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
                        ClosePosition(PairInfo[i].FXtradeName,i,PairInfo[i].TradeDirection);
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
                        ClosePosition(PairInfo[i].FXtradeName,i,PairInfo[i].TradeDirection);
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
                  ret=MessageBox("Do you want to close trade on "+fuPair+"?","", MB_YESNO|MB_ICONQUESTION); // Message box
                  if(ret ==IDYES) ClosePosition(PairInfo[i].FXtradeName,i,PairInfo[i].TradeDirection);
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