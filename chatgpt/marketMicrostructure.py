import simpy
import random
import matplotlib.pyplot as plt

class Market:
    def __init__(self, env):
        self.env = env
        self.price = 100  # Starting market price
        self.trades = []
        self.earnings = {'RetailTrader': 0, 'InstitutionalTrader': 0, 'MarketMaker': 0}

    def trade(self, participant, order_type, quantity):
        """
        Execute a trade, adjusting the price based on order type and quantity.
        Ensure the market remains a zero-sum game.
        """
        price_impact = quantity * 0.1
        previous_price = self.price

        if order_type == 'buy':
            self.price += price_impact
        elif order_type == 'sell':
            self.price -= price_impact

        # Calculate earnings for the participant and adjust market earnings to maintain zero-sum
        earnings = (self.price - previous_price) * quantity if order_type == 'buy' else (previous_price - self.price) * quantity
        self.earnings[participant] += earnings

        # Adjust other participants to maintain zero-sum
        for p in self.earnings:
            if p != participant:
                self.earnings[p] -= earnings / (len(self.earnings) - 1)

        self.trades.append((self.env.now, participant, order_type, quantity, self.price, self.earnings.copy()))
        print(f"[{self.env.now}] {participant} placed a {order_type} order for {quantity}. New price: {self.price:.2f}, Earnings: {earnings:.2f}")

class RetailTrader:
    def __init__(self, env, market):
        self.env = env
        self.market = market
        self.action = env.process(self.trade())

    def trade(self):
        while True:
            yield self.env.timeout(random.randint(1, 5))  # Random intervals
            order_type = random.choice(['buy', 'sell'])
            quantity = random.randint(1, 5)
            self.market.trade('RetailTrader', order_type, quantity)

class InstitutionalTrader:
    def __init__(self, env, market):
        self.env = env
        self.market = market
        self.action = env.process(self.trade())

    def trade(self):
        while True:
            yield self.env.timeout(random.randint(5, 15))  # Less frequent
            order_type = random.choice(['buy', 'sell'])
            quantity = random.randint(10, 50)
            self.market.trade('InstitutionalTrader', order_type, quantity)

class MarketMaker:
    def __init__(self, env, market):
        self.env = env
        self.market = market
        self.action = env.process(self.trade())

    def trade(self):
        while True:
            yield self.env.timeout(1)  # Constantly active
            order_type = random.choice(['buy', 'sell'])
            quantity = random.randint(1, 10)
            self.market.trade('MarketMaker', order_type, quantity)

# Simulation setup
env = simpy.Environment()
market = Market(env)

# Create participants
retail_trader = RetailTrader(env, market)
institutional_trader = InstitutionalTrader(env, market)
market_maker = MarketMaker(env, market)

# Run the simulation
env.run(until=1000)

# Extract cumulative earnings for plotting
times = [trade[0] for trade in market.trades]
retail_earnings = [trade[5]['RetailTrader'] for trade in market.trades]
institutional_earnings = [trade[5]['InstitutionalTrader'] for trade in market.trades]
market_maker_earnings = [trade[5]['MarketMaker'] for trade in market.trades]

# Plot cumulative earnings
plt.figure(figsize=(10, 6))
plt.plot(times, retail_earnings, label='RetailTrader')
plt.plot(times, institutional_earnings, label='InstitutionalTrader')
plt.plot(times, market_maker_earnings, label='MarketMaker')
plt.xlabel('Time')
plt.ylabel('Cumulative Earnings')
plt.title('Cumulative Earnings of Market Participants (Zero-Sum)')
plt.legend()
plt.grid(True)
plt.show()
