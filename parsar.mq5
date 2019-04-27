//+------------------------------------------------------------------+
//|                                          PasswordProtectedEA.mq5 |
//|                                      Copyright 2012, Investeo.pl |
//|                                           http://www.investeo.pl |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, Investeo.pl"
#property link      "http://www.investeo.pl"
#property version   "1.00"

#include <ChartObjects/ChartObjectsTxtControls.mqh>

CChartObjectEdit password_edit;

const string allowed_passwords[] = { "863H-6738725-JG76364",
                             "145G-8927523-JG76364",
                             "263H-7663233-JG76364" };
                             
int    password_status = 1;
string password_message[] = { "WRONG PASSWORD. Trading not allowed.",
                         "EA PASSWORD verified." };
                         
int wow;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   password_edit.Create(0, "password_edit", 0, 10, 10, 260, 25);
   password_edit.BackColor(White);
   password_edit.BorderColor(Black);
   password_edit.SetInteger(OBJPROP_SELECTED, 0, true);
   wow = iSAR(_Symbol,_Period,0.02,0.2);
//---
   return(0);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   password_edit.Delete();
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
int STP = 300;
int TKP = 500;
int EA_Magic;
bool Sell_condition = false;
bool Buy_condition = false;
void OnTick()
  {
//---
  if (password_status>0) 
  {
    double marlon[];
    double tes1[];
    double tes2[];
    CopyBuffer(wow,0,0,2,marlon);
    
    
    int a = CopyHigh(_Symbol, _Period, 0,1,tes1);
    int b = CopyLow(_Symbol, _Period, 0, 1,tes2);
    Comment("\n\nmarlon[0] = ", marlon[0], "marlon[1] = ", marlon[1], "tes1[0] = ", tes1[0], "tes2[0] = ", tes2[0]);
    Buy_condition = false;
    Sell_condition = false;
    if (marlon[1] > tes1[0] && marlon[0] < tes2[0]){
         Sell_condition = true;
         Alert("wow");
    }else if (marlon[1] < tes2[0] && marlon[0] > tes1[0]){
         Buy_condition = true;
         Alert("wow1");
    }
      EA_Magic=12345;
    bool Buy_opened=false;  // variable to hold the result of Buy opened position
   bool Sell_opened=false; // variables to hold the result of Sell opened position

   int r = 0;
   int counter = 0;
   int w = OrderGetTicket(r);
   if (OrderSelect(w)){
   while (!Buy_opened && r < OrdersTotal()){
        w = OrderGetTicket(r);
        if (OrderSelect(w)){
         if (OrderGetInteger(ORDER_TYPE) == ORDER_TYPE_BUY_LIMIT && (OrderGetString(ORDER_SYMBOL) == _Symbol)){
            Buy_opened = true;
            Sell_opened = true;
         }else {
            r++;
         }
         }
         
     }
     /*if (counter == 3){
            Buy_opened = true;
         }*/
     r = 0;
     counter = 0;
     

     
   while (!Sell_opened && r < OrdersTotal()){
        w = OrderGetTicket(r);
        if (OrderSelect(w)){
         if (OrderGetInteger(ORDER_TYPE) == ORDER_TYPE_SELL_LIMIT && (OrderGetString(ORDER_SYMBOL) == _Symbol)){
            Sell_opened = true;
            Buy_opened = true;
         }else {
            r++;
         }
         }
         /*if (counter == 3){
            Sell_opened = true;
         }*/
     }  
     
      
   }  
   if(PositionSelect(_Symbol)==true) // we have an opened position
     {
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
        {
         Buy_opened=true;  //It is a Buy
        }
      else if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
        {
         Sell_opened=true; // It is a Sell
        }
     }
    MqlTradeRequest mrequest; 
    MqlTradeResult mresult;
    MqlTick latest_price;
    SymbolInfoTick(_Symbol,latest_price);
    if (!Buy_opened && !Sell_opened){
    if (Sell_condition){
         //double samples = SymbolInfoInteger(finals, SYMBOL_DIGITS);
         //double samples1 = SymbolInfoDouble(finals, SYMBOL_POINT);
         ZeroMemory(mrequest);
         mrequest.action=TRADE_ACTION_DEAL;                                // immediate order execution
         mrequest.price = NormalizeDouble(latest_price.ask,_Digits);           // latest Bid price
         mrequest.sl = NormalizeDouble(latest_price.ask - STP*_Point,_Digits); // Stop Loss
         mrequest.tp = NormalizeDouble(latest_price.ask + TKP*_Point,_Digits); // Take Profit
         mrequest.symbol = _Symbol;                                          // currency pair
         mrequest.volume = 0.1;                                              // number of lots to trade
         mrequest.magic = EA_Magic;                                          // Order Magic Number
         mrequest.type= ORDER_TYPE_BUY;                                     // Sell Order
         mrequest.type_filling = ORDER_FILLING_FOK;                          // Order execution type
         mrequest.deviation=100;                                             // Deviation from current price
         //--- send order
         OrderSend(mrequest,mresult);
         GetLastError();
    }else if (Buy_condition){
    ZeroMemory(mrequest);
      mrequest.action=TRADE_ACTION_DEAL;                                // immediate order execution
         mrequest.price = NormalizeDouble(latest_price.bid,_Digits);           // latest Bid price
         mrequest.sl = NormalizeDouble(latest_price.bid + STP*_Point,_Digits); // Stop Loss
         mrequest.tp = NormalizeDouble(latest_price.bid - TKP*_Point,_Digits); // Take Profit
         mrequest.symbol = _Symbol;                                          // currency pair
         mrequest.volume = 0.1;                                              // number of lots to trade
         mrequest.magic = EA_Magic;                                          // Order Magic Number
         mrequest.type= ORDER_TYPE_SELL;                                     // Sell Order
         mrequest.type_filling = ORDER_FILLING_FOK;                          // Order execution type
         mrequest.deviation=100;  
         OrderSend(mrequest,mresult);
         GetLastError();                   
    }
    }
  } 
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   if (id == CHARTEVENT_OBJECT_ENDEDIT && sparam == "password_edit" )
      {
         password_status = 1;
         
         for (int i=0; i<ArraySize(allowed_passwords); i++)
            if (password_edit.GetString(OBJPROP_TEXT) == allowed_passwords[i]) 
            {
               password_status = i;
               break;
            }
            
         if (password_status == -1) 
            password_edit.SetString(OBJPROP_TEXT, 0, password_message[0]);
         else 
            password_edit.SetString(OBJPROP_TEXT, 0, password_message[1]); 
      }
  }
//+------------------------------------------------------------------+