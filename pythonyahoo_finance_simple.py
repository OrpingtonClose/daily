from datetime import datetime
import yfinance as yf
import matplotlib.pyplot as plt

data = yf.download(['TSLA'], start=datetime(2020, 1, 1), end=datetime(2023, 1, 1), back_adjust=True)
plt.figure(figsize=(9,4))
plt.plot(data['Open'])
plt.plot(data['Open'].rolling(25).mean())
plt.show()
