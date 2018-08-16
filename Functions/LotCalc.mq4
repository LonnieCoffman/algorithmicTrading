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