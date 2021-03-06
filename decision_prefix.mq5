//+------------------------------------------------------------------+
//|                                                  My_First_EA.mq5 |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
#include <Trade\SymbolInfo.mqh>
#include <Arrays\ArrayObj.mqh>
//--- input parameters



input int      StopLoss=50;      // Stop Loss
input int      TakeProfit=100;   // Take Profit
input int      ADX_Period=8;     // ADX Period
input int      MA_Period=8;      // Moving Average Period
input int      MA_Period1 = 10;
input int      MA_Period2 = 30;
input int      EA_Magic=12345;   // EA Magic Number
input double   Adx_Min=22.0;     // Minimum ADX Value
input double   Lot=1.0;          // Lots to Trade
//--- Other parameters
int adxHandle; // handle for our ADX indicator
int maHandle;  // handle for our Moving Average indicator
double plsDI[],minDI[],adxVal[]; // Dynamic arrays to hold the values of +DI, -DI and ADX values for each bars
double maVal[]; // Dynamic array to hold the values of Moving Average for each bars
double p_close; // Variable to store the close value of a bar
int STP, TKP;   // To be used for Stop Loss & Take Profit values

class MySymbol : public CSymbolInfo
{
protected:
   ENUM_TIMEFRAMES   m_period;
   MqlRates          m_rates[];
   datetime          m_bartime;
public:
   MySymbol(const string symbol,ENUM_TIMEFRAMES period):m_period(period)
   {
      m_name = symbol;
      ArraySetAsSeries(m_rates,true);
   }
   int BarsTotal() const { return ArraySize(m_rates);}
   bool RefreshRates()
   {
      datetime btime = (datetime)SeriesInfoInteger(m_name,m_period,SERIES_LASTBAR_DATE);
      if(m_bartime != btime || BarsTotal() < 300)
      {
         if(CopyRates(m_name,m_period,0,Bars(m_name,m_period),m_rates)<300)
            return false;
         m_bartime = btime;
      }
      return CSymbolInfo::RefreshRates();
   }
   double   Open  (const int i) const { return m_rates[i].open; }
   double   High  (const int i) const { return m_rates[i].high; }
   double   Low   (const int i) const { return m_rates[i].low ; }
   double   Close (const int i) const { return m_rates[i].close;}
   datetime Time  (const int i) const { return m_rates[i].time; }
};

class MySymbolCollection : public CArrayObj
{
public:
   MySymbol* operator[](const int index)const{return(MySymbol*)At(index);}
   bool  Init(string &syms[])
   {
      Clear();
      for(int i=0;i<ArraySize(syms);i++)
      {
         for(int j=0;j<SymbolsTotal(false);j++)
         {
            if(StringFind(SymbolName(j,false),syms[i])>=0)
            {
               Add(new MySymbol(SymbolName(j,false),Period()));
               break;
            }
         }
      }
      EventSetTimer(1);
      return true;
   }
   bool RefreshRates()
   {
      bool res = true;
      for(int i=0;i<Total();i++)
         if(!this[i].RefreshRates())  
            res = false;
      return res;
   }
};

string sym[]={    "GBPCAD","GBPCHF","GBPNZD", "GBPJPY","GBPUSD"};
MySymbolCollection symbols;

struct  Paris {
	string symbol;
	int strength;
};

int TakeProfit1 = 15;
int StopLoss1 = 50;
int Gradient(string symb){
      long id = ChartOpen(symb,PERIOD_H1);
      int MA_1_t = 0, MA_2_t = 0;
      int i;
      int      MA_Period1 = 21;
      int      MA_Period2 = 60;
      double sumMA = 0, sumMB = 0;
      double samples2 = SymbolInfoDouble(symb, SYMBOL_POINT)*50;
      double ma1[],ma2[];
      MqlTick wow[];
      if (SymbolSelect(symb,1) && ChartOpen(symb,PERIOD_H1)){
      MA_1_t = iMA(symb,PERIOD_H1,MA_Period1,0,MODE_EMA,PRICE_CLOSE); // МА_1
		MA_2_t = iMA(symb,PERIOD_H1,MA_Period2,0,MODE_EMA,PRICE_CLOSE); // МА_2
		}
	  CopyBuffer(MA_1_t,0,0,4,ma1);
	  CopyBuffer(MA_2_t,0,0,4,ma2);
	  for (i = 0; i <= 3; i++){
	     sumMA += ma1[i];
	     sumMB += ma2[i];
	  }
	  
		sumMA /= 4;
		sumMB /= 4;
	if ((sumMA > sumMB) && (sumMA - sumMB >= samples2))         // If difference between
     {                                          // ..MA 1 and 2 is large
      return 1;
     }else if ((sumMA < sumMB) && (sumMB - sumMA >= samples2)){
		return -1;
	 }else{
		return 0;
	 }
}

int ValidityChecking(Paris &P[],int d){
   int i;
   int temp = 0;
   int temp1 = 0;
   
   for (i = 1; i <= d; i++){
      if (P[i].strength == 1){
         temp++;
      }else if (P[i].strength == -1){
         temp1++;
      }
      }
      
   if (temp > temp1){
      return 1;
   }else if (temp < temp1){
      return 2;
   }else{
      return 3;
   }
}

string FindMin(Paris &P[], int d){
   int i = 1;
   bool found = false;
   string teymp;
   while (!found && i <= d){
      if (P[i].strength == -1){
         teymp = P[i].symbol;
         found = true;
      }else{
         i++;
      }
   }
   if (!found){
      return "NULL";
   }else{
      return teymp;
   }
}

string FindMax(Paris &P[], int d){
   int i = 1;
   bool found = false;
   string teymp;
   while (!found && i <= d){
      if (P[i].strength == 1){
         teymp = P[i].symbol;
         found = true;
      }else{
         i++;
      }
   }
   if (!found){
      return "NULL";
   }else{
      return teymp;
   }
}
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
	symbols.Init(sym);
	symbols.RefreshRates();
	for(int i=0;i<symbols.Total();i++){
         Print("My Symbol is ",symbols[i].Name()," and I have copied ",symbols[i].BarsTotal()," bars to rates.");
         }
//--- Get handle for ADX indicator
   adxHandle=iADX(NULL,0,ADX_Period);
//--- Get the handle for Moving Average indicator
   maHandle=iMA(_Symbol,_Period,MA_Period,0,MODE_EMA,PRICE_CLOSE);
//--- What if handle returns Invalid Handle
   if(adxHandle<0 || maHandle<0)
     {
      Alert("Error Creating Handles for indicators - error: ",GetLastError(),"!!");
      return(-1);
     }

//--- Let us handle currency pairs with 5 or 3 digit prices instead of 4
   STP = StopLoss1;
   TKP = TakeProfit1;
   if(_Digits==5 || _Digits==3)
     {
      STP = STP*10;
      TKP = TKP*10;
     }else{
      STP *= 10;
      TKP *= 10;
     }
   return(0);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- Release our indicator handles
   IndicatorRelease(adxHandle);
   IndicatorRelease(maHandle);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- Do we have enough bars to work with
   if(Bars(_Symbol,_Period)<60) // if total bars is less than 60 bars
     {
      Alert("We have less than 60 bars, EA will now exit!!");
      return;
     }  

// We will use the static Old_Time variable to serve the bar time.
// At each OnTick execution we will check the current bar time with the saved one.
// If the bar time isn't equal to the saved time, it indicates that we have a new tick.

   static datetime Old_Time;
   datetime New_Time[1];
   bool IsNewBar=false;

// copying the last bar time to the element New_Time[0]
   int copied=CopyTime(_Symbol,_Period,0,1,New_Time);
   if(copied>0) // ok, the data has been copied successfully
     {
      if(Old_Time!=New_Time[0]) // if old time isn't equal to new bar time
        {
         IsNewBar=true;   // if it isn't a first call, the new bar has appeared
         if(MQL5InfoInteger(MQL5_DEBUGGING)) Print("We have new bar here ",New_Time[0]," old time was ",Old_Time);
         Old_Time=New_Time[0];            // saving bar time
        }
     }
   else
     {
      Alert("Error in copying historical times data, error =",GetLastError());
      ResetLastError();
      return;
     }

//--- EA should only check for new trade if we have a new bar
   if(IsNewBar==false)
     {
      return;
     }
 
//--- Do we have enough bars to work with
   int Mybars=Bars(_Symbol,_Period);
   if(Mybars<60) // if total bars is less than 60 bars
     {
      Alert("We have less than 60 bars, EA will now exit!!");
      return;
     }

//--- Define some MQL5 Structures we will use for our trade
   MqlTick latest_price;      // To be used for getting recent/latest price quotes
   MqlTradeRequest mrequest;  // To be used for sending our trade requests
   MqlTradeResult mresult;    // To be used to get our trade results
   MqlRates mrate[];          // To be used to store the prices, volumes and spread of each bar
   ZeroMemory(mrequest);      // Initialization of mrequest structure
/*
     Let's make sure our arrays values for the Rates, ADX Values and MA values 
     is store serially similar to the timeseries array
*/
// the rates arrays
   ArraySetAsSeries(mrate,true);
// the ADX DI+values array
   ArraySetAsSeries(plsDI,true);
// the ADX DI-values array
   ArraySetAsSeries(minDI,true);
// the ADX values arrays
   ArraySetAsSeries(adxVal,true);
// the MA-8 values arrays
   ArraySetAsSeries(maVal,true);


//--- Get the last price quote using the MQL5 MqlTick Structure
   if(!SymbolInfoTick(_Symbol,latest_price))
     {
      Alert("Error getting the latest price quote - error:",GetLastError(),"!!");
      return;
     }

//--- Get the details of the latest 3 bars
   if(CopyRates(_Symbol,_Period,0,3,mrate)<0)
     {
      Alert("Error copying rates/history data - error:",GetLastError(),"!!");
      ResetLastError();
      return;
     }

//--- Copy the new values of our indicators to buffers (arrays) using the handle
   if(CopyBuffer(adxHandle,0,0,3,adxVal)<0 || CopyBuffer(adxHandle,1,0,3,plsDI)<0
      || CopyBuffer(adxHandle,2,0,3,minDI)<0)
     {
      Alert("Error copying ADX indicator Buffers - error:",GetLastError(),"!!");
      ResetLastError();
      return;
     }
   if(CopyBuffer(maHandle,0,0,3,maVal)<0)
     {
      Alert("Error copying Moving Average indicator buffer - error:",GetLastError());
      ResetLastError();
      return;
     }
//--- we have no errors, so continue
//--- Do we have positions opened already?
   

// Copy the bar close price for the previous bar prior to the current bar, that is Bar 1
   p_close=mrate[1].close;  // bar 1 close price

/*
    1. Check for a long/Buy Setup : MA-8 increasing upwards, 
    previous price close above it, ADX > 22, +DI > -DI

*/
string Symb = Symbol();   //The name of current opened symbol
int numsym = SymbolsTotal(1); //The number of available symbol
int CurGrad = Gradient(Symb); //The gradient of current symbol
char prefix[4];   //The front name of the currency
char Word[7];     //Array to store the name string as char array
char Temp[4];     //Temporary character storage
Paris GradList[]; //Array to store custom datatype which contained strengths and names
string SymbList[]; //Array to contain the list of all symbols
string SymbSaring[]; //Array to filter the symbols being used
string finals; //Variable to store a string to be placed an order to

int i,j,k,count; //Counting variables

/*Storing the current chart into array*/
StringToCharArray(Symb,Word,1,WHOLE_ARRAY,CP_ACP);


for (i = 1; i <= numsym; i++){
   ArrayResize(SymbList,i+1,0);
	SymbList[i] = SymbolName(i,true);
   
   }
   
for (i = 1; i <= 3; i++){
	   prefix[i] = Word[i];
   }
 /* Matching the front name of the currency with the rest*/  
  k = 0;
  count = 0;
 for (i =1; i <= numsym; i++){
	for (j =1; j <= 3; j++){
	   StringToCharArray(SymbList[i],Temp,1,WHOLE_ARRAY,CP_ACP);
		if (prefix[j] == Temp[j]){
			count++;
		}
	}
		if (count == 3){
			k++;
			ArrayResize(SymbSaring,k+1,0);
			SymbSaring[k] = SymbList[i];
		}
		count = 0;
   }
/*Collecting the gradient and its corresponding names*/   
 for (i = 1; i <= k; i++){
   ArrayResize(GradList,i+1,0);
   GradList[i].symbol = SymbSaring[i];
   GradList[i].strength = Gradient(SymbList[i]);
 }
bool Buy_Condition_1 = false; //Variable to store the confirmation of long position
bool Sell_Condition_1 = false; //Variable to store the confirmation of short position

/*Validity checking and the main algorithm to check if there is a minor and major currency strenghts and the program will find the one who is still late*/
 if (ValidityChecking(GradList,k) == 1){
   finals = FindMin(GradList,k);
   if (finals != "NULL"){
   Buy_Condition_1 = true;
   }
 }else if (ValidityChecking(GradList,k)== 2){
   finals = FindMax(GradList,k);
   if (finals != "NULL"){
   Sell_Condition_1 = true;
 }
 }

bool Buy_opened=false;  // variable to hold the result of Buy opened position
bool Sell_opened=false; // variables to hold the result of Sell opened position

   /*if(PositionSelect(finals)==true) // we have an opened position
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
*/

//--- Declare bool type variables to hold our Buy Conditions
   /*bool Buy_Condition_1=(maVal[0]>maVal[1]) && (maVal[1]>maVal[2]); // MA-8 Increasing upwards
   bool Buy_Condition_2 = (p_close > maVal[1]);         // previuos price closed above MA-8
   bool Buy_Condition_3 = (adxVal[0]>Adx_Min);          // Current ADX value greater than minimum value (22)
   bool Buy_Condition_4 = (plsDI[0]>minDI[0]);          // +DI greater than -DI
*/
//--- Putting all together   
   MqlTick tic;
   double lot2 = 1.0;
   if(Buy_Condition_1)
     {        
         // any opened Buy position?
         if(Buy_opened)
           {
            Alert("We already have a Buy Position!!!");
            return;    // Don't open a new Buy Position
           }
         if (SymbolInfoTick(finals,tic)){
         ZeroMemory(mrequest);
         double samples = SymbolInfoInteger(finals, SYMBOL_DIGITS);
         double samples1 = SymbolInfoDouble(finals, SYMBOL_POINT);
         mrequest.action = TRADE_ACTION_DEAL;                                  // immediate order execution
         mrequest.price = NormalizeDouble(tic.ask,samples);           // latest ask price
         mrequest.sl = NormalizeDouble(tic.ask - STP*samples1,samples); // Stop Loss
         mrequest.tp = NormalizeDouble(tic.ask + TKP*samples1,samples); // Take Profit
         mrequest.symbol = finals;                                            // currency pair
         mrequest.volume = lot2;                                                 // number of lots to trade
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
/*
    2. Check for a Short/Sell Setup : MA-8 decreasing downwards, 
    previous price close below it, ADX > 22, -DI > +DI
*/
//--- Declare bool type variables to hold our Sell Conditions
  /* bool Sell_Condition_1 = (maVal[0]<maVal[1]) && (maVal[1]<maVal[2]);  // MA-8 decreasing downwards
   bool Sell_Condition_2 = (p_close <maVal[1]);                         // Previous price closed below MA-8
   bool Sell_Condition_3 = (adxVal[0]>Adx_Min);                         // Current ADX value greater than minimum (22)
   bool Sell_Condition_4 = (plsDI[0]<minDI[0]);                         // -DI greater than +DI
*/
//--- Putting all together
   
 if(Sell_Condition_1)
     {
         if(Sell_opened)
           {
            Alert("We already have a Sell position!!!");
            return;    // Don't open a new Sell Position
           }
         if (SymbolInfoTick(finals,tic)){  
         ZeroMemory(mrequest);
         double samples = SymbolInfoInteger(finals, SYMBOL_DIGITS);
         double samples1 = SymbolInfoDouble(finals, SYMBOL_POINT);
         mrequest.action=TRADE_ACTION_DEAL;                                // immediate order execution
         mrequest.price = NormalizeDouble(latest_price.bid,samples);           // latest Bid price
         mrequest.sl = NormalizeDouble(latest_price.bid + STP*samples1,samples); // Stop Loss
         mrequest.tp = NormalizeDouble(latest_price.bid - TKP*samples1,samples); // Take Profit
         mrequest.symbol = finals;                                          // currency pair
         mrequest.volume = lot2;                                              // number of lots to trade
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
           }
        }
   return;
  }
//+------------------------------------------------------------------+