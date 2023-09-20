
import cbpro
from datetime import datetime, timedelta
import pandas as pd
import numpy as np
from math import trunc
import plotly.graph_objects as go
from plotly.subplots import make_subplots

public_client = cbpro.PublicClient()

FIAT_CURRENCIES = ['USD']
MY_BASE_CURRENCY = FIAT_CURRENCIES[0]
MY_CRYPTO_CURRENCIES = ["BTC"]
GRANULARITIES = ['60min']
currency = "BTC"
MY_BASE_CURRENCY = "USD"

from datetime import timedelta

currency_history_rows = []

start_date = (server_time_now - timedelta(days=180)).isoformat()
end_date = server_time_now.isoformat()
data = public_client.get_product_historic_rates(currency+'-'+MY_BASE_CURRENCY, start=start_date, end=end_date, granularity=86400)
df_history = pd.DataFrame(data)
df_history.columns = ['time','low','high','open','close','volume']
df_history['date'] = pd.to_datetime(df_history['time'], unit='s')



df_history_enhanced = df_history_enhanced.sort_values(['date'], ascending=True) #oldest to newest for visualization

df_history_for_chart = df_history_enhanced.query(f'granularity == \'60min\' and currency == \'BTC\'')
fig = go.Figure()
fig.add_trace(go.Candlestick(
    x=df_history['date'],
    open=df_history['open'],
    high=df_history['high'],
    low=df_history['low'],
    close=df_history['close'],
    name='OHLC'))
fig.show()
