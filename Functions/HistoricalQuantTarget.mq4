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
            highest = iHigh(PairInfo[arrID].Pair,PairInfo[arrID].Timeframe,iHighest(PairInfo[arrID].Pair,PairInfo[arrID].Timeframe,MODE_HIGH,bar-endBar,endBar));
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
            lowest = iLow(PairInfo[arrID].Pair,PairInfo[arrID].Timeframe,iLowest(PairInfo[arrID].Pair,PairInfo[arrID].Timeframe,MODE_LOW,bar-endBar,endBar));
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