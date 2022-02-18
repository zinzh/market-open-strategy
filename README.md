# market-open-strategy

An expert advisor to take long/short positions on the stock market opening only

# Installation

Download file and compile in MetaEditor, then run in MT4

# Features

market-open-strategy EA will monitor the market open time in New York and calculate a range where price fluctuates in the first 30 minutes after the opening
The 30 minutes time will be divided into two 15-minutes candles that will form the range
When the price breaks out after the first 30 minutes the EA will open a position depending on the direction of the price
