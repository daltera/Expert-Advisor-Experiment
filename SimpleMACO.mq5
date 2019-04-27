//+------------------------------------------------------------------+
//|                                                         elon.mq5 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Trade\Trade.mqh>
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
input int      StopLoss=30;      // Stop Loss
input int      TakeProfit=100;   // Take Profit
input int      ADX_Period=8;     // ADX Period
input int      MA_Period=8;      // Moving Average Period
input int      EA_Magic=12345;   // EA Magic Number
input double   Adx_Min=22.0;     // Minimum ADX Value
input double   Lot=2;          // Lots to Trade

int a, b;
bool flagBuy = true;
bool flagSell = true;
static bool lock = true;
int count = 0;
int age = 0;


int STP, TKP;

int OnInit()
  {
//---
  a = iMA(_Symbol, _Period, 14, 0, MODE_EMA, PRICE_CLOSE);
  b = iMA(_Symbol, _Period, 50, 0, MODE_EMA, PRICE_CLOSE);
  
     STP = StopLoss;
   TKP = TakeProfit;
   if(_Digits==5 || _Digits==3)
     {
      STP = STP*10;
      TKP = TKP*10;
     }
//---
   return(INIT_SUCCEEDED);
  }
  
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  
//---
   IndicatorRelease(a);
   IndicatorRelease(b);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+

void OnTick()
  {
//---
   bool buy_conf = false;
   bool sell_conf = false;
   bool buy_opened = false;
   bool sell_opened = false;
   double c[];
   double d[];
   CopyBuffer(a, 0, 0, 6, c);
   CopyBuffer(b, 0, 0, 6, d);
   if (isN
   
   double cRate = 0;
   double dRate = 0;
   for(int i = 0; i < 5; i++) cRate += c[i];
   for(int i = 0; i < 5; i++) dRate += d[i];
   
   cRate /= 5; dRate /= 5;
   if (lock){
     
      if (cRate > dRate){
         flagBuy = false;
         lock = false;
      }else if (dRate > cRate){
         flagSell = false;
         lock = false;
      }
   }
   cRate = c[4];
   dRate = d[4]; 

  

  //Comment(mrequest.price," ", mrequest.sl, " ", mrequest.tp);
  CTrade p;
   for (int i = 0; i < PositionsTotal(); i++){
          int x = PositionGetTicket(i);
          if (PositionSelectByTicket(x)){
            if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL && PositionGetDouble(POSITION_PROFIT) > 200){
               p.PositionClose(x);
               //flagBuy = false;
            }
          }
          
          //flagSell = true;
         
      }
  for (int i = 0; i < PositionsTotal(); i++){
          int x = PositionGetTicket(i);
          if (PositionSelectByTicket(x)){
            if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY && PositionGetDouble(POSITION_PROFIT) > 200){
               p.PositionClose(x);
               //flagSell = false;
            }
          }
          //flagBuy = true;
          
         
      }
      
  
  if(cRate > dRate && flagBuy){
      flagBuy = false;
      flagSell = true;
      buy_conf = true;
   }else if(cRate < dRate && flagSell){
      flagBuy = true;
      flagSell = false;
      sell_conf = true;
   }
 
     
  if (PositionSelect(_Symbol) == true){
    if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY){
      buy_opened = true;
    }
    
    if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL){
      sell_opened = true;
    }    
  }
  MqlTick latest_price;      // To be used for getting recent/latest price quotes
  MqlTradeRequest mrequest;  // To be used for sending our trade requests
  MqlTradeResult mresult;    // To be used to get our trade results
  MqlRates mrate[];          // To be used to store the prices, volumes and spread of each bar
  ZeroMemory(mrequest);
  count++;
  Alert(count);
  
  if(!SymbolInfoTick(_Symbol,latest_price))
     {
      Alert("Error getting the latest price quote - error:",GetLastError(),"!!");
      return;
     }
     
     double lot = 2;

   if (sell_conf){
      if(sell_opened)
              {
             
               Alert("We already have a Sell position!!!");
               return;    // Don't open a new Sell Position
              }
               Alert("wow");
            ZeroMemory(mrequest);
            mrequest.action=TRADE_ACTION_DEAL;                                // immediate order execution
            mrequest.price = NormalizeDouble(latest_price.bid,_Digits);           // latest Bid price
            mrequest.sl = NormalizeDouble(latest_price.bid + STP*_Point*10,_Digits); // Stop Loss
            mrequest.tp = NormalizeDouble(latest_price.bid - TKP*_Point,_Digits); // Take Profit
            mrequest.symbol = _Symbol;                                          // currency pair
            mrequest.volume = lot;                                              // number of lots to trade
            mrequest.magic = EA_Magic;                                          // Order Magic Number
            mrequest.type= ORDER_TYPE_SELL;                                     // Sell Order
            mrequest.type_filling = ORDER_FILLING_FOK;                          // Order execution type
            mrequest.deviation=100;                                             // Deviation from current price
            //--- send order
            OrderSend(mrequest,mresult);
            // get the result code
            if(mresult.retcode==10009 || mresult.retcode==10008) //Request is completed or order placed
              {
               Alert("A Sell order has been successfully placed with Ticket#:",mresult.order,"!!");
              }
            else
              {
               Alert("The Sell order request could not be completed -error:",GetLastError());
               ResetLastError();
               return;
              }
         return;
         
         }
     if (buy_conf){
       if(buy_opened)
              {
               Alert("We already have a Buy Position!!!");
               return;    // Don't open a new Buy Position
              }
            ZeroMemory(mrequest);
            mrequest.action = TRADE_ACTION_DEAL;                                  // immediate order execution
            mrequest.price = NormalizeDouble(latest_price.ask,_Digits);           // latest ask price
            mrequest.sl = NormalizeDouble(latest_price.ask - STP*_Point*10,_Digits); // Stop Loss
            mrequest.tp = NormalizeDouble(latest_price.ask + TKP*_Point,_Digits); // Take Profit
            mrequest.symbol = _Symbol;                                            // currency pair
            mrequest.volume = lot;                                                 // number of lots to trade
            mrequest.magic = EA_Magic;                                             // Order Magic Number
            mrequest.type = ORDER_TYPE_BUY;                                        // Buy Order
            mrequest.type_filling = ORDER_FILLING_FOK;                             // Order execution type
            mrequest.deviation=100;                                                // Deviation from current price
            //--- send order
            OrderSend(mrequest,mresult);
            // get the result code
            if(mresult.retcode==10009 || mresult.retcode==10008) //Request is completed or order placed
              {
               Alert("A Buy order has been successfully placed with Ticket#:",mresult.order,"!!");
              }
            else
              {
               Alert("The Buy order request could not be completed -error:",GetLastError());
               ResetLastError();           
               return;
              }
              }
 }
//+------------------------------------------------------------------+
