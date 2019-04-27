//+------------------------------------------------------------------+
//|                                                        SeriT.mq5 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
#include <Trade\SymbolInfo.mqh>
#include <Trade\Trade.mqh>
#include <Expert\Expert.mqh>
#include <ChartObjects\ChartObjectsTxtControls.mqh>

bool isNewBar()
  {
//--- memorize the time of opening of the last bar in the static variable
   static datetime last_time=0;
//--- current time
   datetime lastbar_time=SeriesInfoInteger(Symbol(),Period(),SERIES_LASTBAR_DATE);

//--- if it is the first call of the function
   if(last_time==0)
     {
      //--- set the time and exit
      last_time=lastbar_time;
      return(false);
     }

//--- if the time differs
   if(last_time!=lastbar_time)
     {
      //--- memorize the time and return true
      last_time=lastbar_time;
      return(true);
     }
//--- if we passed to this line, then the bar is not new; return false
   return(false);
  }

double highest,lowest;
int counbt = 0;

int OnInit()
  {
//---
   
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
void OnTick()
  {
//---
   if (!isNewBar()){ return;}
   double close[];      
   CopyClose(_Symbol,_Period,0, 36, close);
   
   highest = close[0];
   lowest = close[0];
   for(int i=0; i<35; i++){
      if(close[i] > highest) highest = close[i];
      if(close[i] < lowest) lowest = close[i];
   }

   Alert(counbt);
   if (counbt%15 == 0){
      Alert(counbt);
      counbt = 0;
      double extlow = highest + (highest-lowest)*.618;
      double exthigh = lowest - (highest-lowest)*.618;
      ObjectDelete(0, "highClose");
      ObjectDelete(0, "lowClose");
      ObjectDelete(0, "extHigh");
      ObjectDelete(0, "extLow");
      ObjectCreate(0, "highClose", OBJ_HLINE, 0, 0, highest);
      ObjectCreate(0, "lowClose", OBJ_HLINE, 0, 0, lowest); 
      ObjectCreate(0, "extHigh", OBJ_HLINE, 0, 0, exthigh);
      ObjectCreate(0, "extLow", OBJ_HLINE, 0, 0, extlow);
   }
   counbt++;
  }
//+------------------------------------------------------------------+
