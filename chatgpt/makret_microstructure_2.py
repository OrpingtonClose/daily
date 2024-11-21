import simpy
import random
import matplotlib.pyplot as plt
from typing import Callable


class Market:
    """Singleton Market Class"""

    _instance = None

    @staticmethod
    def get_instance(env):
        if Market._instance is None:
            Market._instance = Market(env)
        return Market._instance

    def __init__(self, env):
        if Market._instance is not None:
            raise Exception("Market is a singleton! Use Market.get_instance(env).")
        self.env = env
        self.buy_offers = []  # (price, quantity, participant)
        self.sell_offers = []  # (price, quantity, participant)
        self.trade_history = []  # (time, participant, order_type, price, quantity)
        self.env.process(self.run_time_ticks())

    def make_order(self, participant, order_type, price, quantity):
        """Participant makes an order (buy or sell)."""
        if order_type == 'buy':
            self.buy_offers.append((price, quantity, participant))
            self.buy_offers.sort(reverse=True, key=lambda x: x[0])  # Sort by highest price
        elif order_type == 'sell':
            self.sell_offers.append((price, quantity, participant))
            self.sell_offers.sort(key=lambda x: x[0])  # Sort by lowest price

    def take_order(self, participant, order_type, quantity):
        """Participant takes an order (buy or sell)."""
        offers = self.sell_offers if order_type == 'buy' else self.buy_offers
        remaining_quantity = quantity

        while offers and remaining_quantity > 0:
            best_offer = offers[0]
            offer_price, offer_quantity, offer_participant = best_offer

            if remaining_quantity >= offer_quantity:
                remaining_quantity -= offer_quantity
                self.trade_history.append((self.env.now, participant, order_type, offer_price, offer_quantity))
                participant.update_earnings(order_type, offer_price, offer_quantity)
                offer_participant.update_earnings(
                    "sell" if order_type == "buy" else "buy", offer_price, offer_quantity
                )
                offers.pop(0)
            else:
                self.trade_history.append((self.env.now, participant, order_type, offer_price, remaining_quantity))
                participant.update_earnings(order_type, offer_price, remaining_quantity)
                offer_participant.update_earnings(
                    "sell" if order_type == "buy" else "buy", offer_price, remaining_quantity
                )
                offers[0] = (offer_price, offer_quantity - remaining_quantity, offer_participant)
                remaining_quantity = 0

    def get_order_book(self):
        """Returns current buy and sell offers."""
        return {"buy_offers": self.buy_offers, "sell_offers": self.sell_offers}

    def run_time_ticks(self):
        """Emit time tick events every second."""
        while True:
            self.broadcast_event("time_tick", self.env.now)
            yield self.env.timeout(1)

    def broadcast_event(self, event_type, data):
        """Simulate broadcasting market events."""
        for participant in MarketParticipant.instances:
            participant.handle_event(event_type, data)


class MarketParticipant:
    """Market Participant Class"""
    instances = []  # Track all instances

    def __init__(self, env, initial_capital, initial_assets, strategy: Callable = None):
        self.env = env
        self.capital = initial_capital
        self.holdings = initial_assets  # Quantity of asset held
        self.earnings = initial_capital  # Earnings (initial capital + holdings' value)
        self.starting_capital = initial_capital  # To calculate profit
        self.starting_assets = initial_assets  # To calculate profit
        self.profit_over_time = []  # Track profit for plotting
        self.strategy = strategy
        self.market = Market.get_instance(env)
        if strategy:
            self.env.process(self.run_strategy())
        MarketParticipant.instances.append(self)

    def handle_event(self, event_type, data):
        """Handle events from the market."""
        if self.strategy and event_type == "time_tick":
            self.strategy(self, self.market, data)

    def update_earnings(self, order_type, price, quantity):
        """Update earnings based on trade activity."""
        if order_type == "buy":
            self.capital -= price * quantity
            self.holdings += quantity
        elif order_type == "sell":
            self.capital += price * quantity
            self.holdings -= quantity
        self.earnings = self.capital + self.holdings * price

        # Calculate profit and store for plotting
        current_profit = self.earnings - (self.starting_capital + self.starting_assets * price)
        self.profit_over_time.append((self.market.env.now, current_profit))

    def run_strategy(self):
        """Initiate the participant's strategy."""
        while True:
            yield self.env.timeout(1)  # React to market events


def ico_strategy(participant, market):
    """ICO strategy: Continuously places sell orders."""
    while True:
        market.make_order(participant, "sell", price=100, quantity=10)
        yield participant.env.timeout(1)  # Places a sell order every second


# Trader Strategies
def institutional_strategy(participant, market, current_time):
    if current_time % 10 == 0:
        order_type = random.choice(["buy", "sell"])
        price = random.randint(95, 105)
        quantity = random.randint(50, 100)
        market.make_order(participant, order_type, price, quantity)


def retail_strategy(participant, market, current_time):
    if random.random() < 0.7:
        order_type = random.choice(["buy", "sell"])
        price = random.randint(90, 110)
        quantity = random.randint(1, 5)
        market.make_order(participant, order_type, price, quantity)


def market_maker_strategy(participant, market, current_time):
    if random.random() < 0.5:
        order_type = random.choice(["buy", "sell"])
        quantity = random.randint(1, 10)
        market.take_order(participant, order_type, quantity)
    else:
        price = random.randint(98, 102)
        quantity = random.randint(5, 15)
        market.make_order(participant, "buy", price, quantity)
        market.make_order(participant, "sell", price, quantity)


# Simulation Setup
env = simpy.Environment()
market = Market.get_instance(env)

# Participants
ico = MarketParticipant(env, initial_capital=0, initial_assets=10000)
env.process(ico_strategy(ico, market))

institutional_trader = MarketParticipant(env, initial_capital=50000, initial_assets=0, strategy=institutional_strategy)
retail_trader = MarketParticipant(env, initial_capital=1000, initial_assets=0, strategy=retail_strategy)
market_maker = MarketParticipant(env, initial_capital=20000, initial_assets=0, strategy=market_maker_strategy)

# Run the simulation
env.run(until=1000)

# Final Profit Over Time Graph
plt.figure(figsize=(12, 6))
for participant in MarketParticipant.instances:
    if participant != ico:  # Ignore ICO participant
        times = [entry[0] for entry in participant.profit_over_time]
        profits = [entry[1] for entry in participant.profit_over_time]
        plt.plot(times, profits, label=f"Participant {MarketParticipant.instances.index(participant)}")

plt.title("Participant Profits Over Time")
plt.xlabel("Time")
plt.ylabel("Profit")
plt.legend(["Institutional Trader", "Retail Trader", "Market Maker"])
plt.grid(True)
plt.show()
