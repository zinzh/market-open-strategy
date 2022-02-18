//+------------------------------------------------------------------+
//|                                           marketOpenStrategy.mq4 |
//|                                                          gilbert |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "gilbert"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

#define     iBarCURRENT   0

const int MAX_ORDERS_PER_DAY = 1;
int dayOrder;
extern double  step      = 0.02;
extern double  maximum   = 0.2;
extern int minTP = 1000;
extern double dLotSize = 0.1; // Position size
extern color clOpenBuy = Blue;
extern color clCloseBuy = Aqua;
extern color clOpenSell = Red;
extern color clCloseSell = Violet;
extern const int SLIPPAGE = 3;
extern int SL = 2000;
extern int CANDLE_FLUCT = 2000;

bool lock = true;
bool ongoingLock = false;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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

extern string marketOpeningTime = "16:30";
extern string marketClosingTime = "23:00";


int indexMarketOpeningTime=0;
int indexMarketClosingTime=0;


string marketState = "closed";
double HHO, LLO;


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void checkTP(int ticket, int orderType,double openPrice, double LL, double HH)
  {


   double highestIncrease = HH - openPrice;
   double currentIncrease = Bid - openPrice;

   double highestDecrease = openPrice - LL;
   double currentDecrease = openPrice - Bid;

   if((OrdersTotal() ==1 && Bid > openPrice+minTP*_Point && orderType == OP_BUY) ||
      (OrdersTotal() ==1 && Bid < openPrice-minTP*_Point && orderType == OP_SELL))
      lock = false;

// if (OrdersTotal() ==1 && Bid < openPrice-2000*_Point && orderType == OP_SELL) selllock = false;

//  if(Bid < openPrice-2000*_Point && orderType == OP_SELL) locked = false;

   if(orderType == OP_BUY)
     {
      if(lock == false)
        {
         if(currentIncrease < highestIncrease - highestIncrease*0.3)
           {
            // Comment("should TP");

            for(int i=0; i<OrdersTotal(); i++)
              {
               if(OrderSelect(i, SELECT_BY_POS))
                 {
                  OrderClose(OrderTicket(),OrderLots(),Bid, SLIPPAGE,clCloseBuy);
                  lock = true;
                 }

              }
           }

        }
     }

   else
      if(orderType == OP_SELL)
        {
         if(lock == false)
           {

            if(currentDecrease < highestDecrease - highestDecrease*0.3)
              {


               for(int i=0; i<OrdersTotal(); i++)
                 {
                  if(OrderSelect(i, SELECT_BY_POS))
                    {
                     //      Comment("should TPSELLLL");
                     OrderClose(OrderTicket(),OrderLots(),Ask, SLIPPAGE, clCloseSell);
                     lock = true;
                    }

                 }
              }

           }


        }


  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double HH()
  {

   if(OrdersTotal() == 1)
     {

      datetime    OOT         = OrderOpenTime();          // Assumes OrderSelect() done already
      int         iOOT        = iBarShift(_Symbol,_Period, OOT);    // Bar of the open.
      int         nSince  = iOOT - iBarCURRENT + 1;       // No. bars since open.
      int         iHi         = iHighest(_Symbol,_Period, MODE_HIGH, nSince, iBarCURRENT);
      double      HH          = High[iHi];                // Highest high.

      return HH;

     }
   return 0;

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double LL()
  {

   if(OrdersTotal() == 1)
     {
      datetime    OOT         = OrderOpenTime();          // Assumes OrderSelect() done already
      int         iOOT        = iBarShift(_Symbol,_Period, OOT);    // Bar of the open.
      int         nSince  = iOOT - iBarCURRENT + 1;       // No. bars since open.
      int         iLi         = iLowest(_Symbol, _Period, MODE_LOW, nSince, iBarCURRENT);
      double      LL          = Low[iLi];                 // Lowest low.
      return LL;

     }

   return 0;

  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {

   int ticket;



   string TimeWithSeconds=TimeToStr(TimeLocal(), TIME_DATE|TIME_SECONDS);

   indexMarketOpeningTime=StringFind(TimeWithSeconds,(marketOpeningTime),0);
   indexMarketClosingTime=StringFind(TimeWithSeconds,(marketClosingTime),0);


   if(indexMarketOpeningTime > 0)
      marketState="open";

   if(indexMarketClosingTime>0)
     {
      marketState="closed";
      if(OrdersTotal() ==0)
        {
         dayOrder = 0;
         HHO = 0;
         LLO=0;
        }
     }






   datetime NewTime=StrToTime("17:0:05");

   if(Time[0] == NewTime /*&& marketState == "open"*/)
     {


      if(High[1] > High[2])
         HHO = High[1];
      else
         HHO = High[2];


      if(Low[1] < Low[2])
         LLO = Low[1];

      else
         LLO = Low[2];

     }

   if(Bid > HHO   && OrdersTotal() == 0 && dayOrder == 0 && HHO != 0 /*&& Bid > Close[1]*/)
     {
      OrderSend(_Symbol, OP_BUY, dLotSize, Ask, SLIPPAGE, Ask-SL*_Point,0, NULL, 0,0, clOpenBuy);
      dayOrder=1;
     }

   if(Bid < LLO && OrdersTotal() == 0 &&  dayOrder == 0 && LLO!=0)
     {
      OrderSend(_Symbol, OP_SELL,dLotSize, Bid, SLIPPAGE, Bid+SL*_Point,0, NULL, 0,0, clOpenSell);
      dayOrder=1;
     }

  


   checkTP(ticket, OrderType(), OrderOpenPrice(), LL(), HH());




//  Comment("Time :", TimeWithSeconds, " Market is ", marketState, "tiiiiiime : ", Time[1]);

   Comment("HHO :",HHO);
//---

  }
//+------------------------------------------------------------------+
