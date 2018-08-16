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