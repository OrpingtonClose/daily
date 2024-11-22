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
        """Participant makes an order (buy or sell) and matches it if possible."""
        print(f"Order placed: {order_type} by {participant} for {quantity} at {price}")
        
        if order_type == "buy":
            # Add to buy orders and attempt to match with existing sell orders
            self.buy_offers.append((price, quantity, participant))
            self.buy_offers.sort(reverse=True, key=lambda x: x[0])  # Sort by highest price
            self.match_orders()
        elif order_type == "sell":
            # Add to sell orders and attempt to match with existing buy orders
            self.sell_offers.append((price, quantity, participant))
            self.sell_offers.sort(key=lambda x: x[0])  # Sort by lowest price
            self.match_orders()

    def match_orders(self):
        """Match buy and sell orders."""
        while self.buy_offers and self.sell_offers:
            buy_price, buy_quantity, buy_participant = self.buy_offers[0]
            sell_price, sell_quantity, sell_participant = self.sell_offers[0]

            # Match only if the buy price >= sell price
            if buy_price >= sell_price:
                matched_quantity = min(buy_quantity, sell_quantity)
                trade_price = (buy_price + sell_price) / 2  # Use the midpoint as the trade price

                # Update participants' earnings
                buy_participant.update_earnings("buy", trade_price, matched_quantity)
                sell_participant.update_earnings("sell", trade_price, matched_quantity)

                # Record the trade using participant names
                self.trade_history.append({
                    "time": self.env.now,
                    "buyer": buy_participant.name,
                    "seller": sell_participant.name,
                    "price": trade_price,
                    "quantity": matched_quantity
                })

                # Adjust order quantities
                if buy_quantity > matched_quantity:
                    self.buy_offers[0] = (buy_price, buy_quantity - matched_quantity, buy_participant)
                else:
                    self.buy_offers.pop(0)

                if sell_quantity > matched_quantity:
                    self.sell_offers[0] = (sell_price, sell_quantity - matched_quantity, sell_participant)
                else:
                    self.sell_offers.pop(0)
            else:
                # No match possible, exit the loop
                break


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

    def __init__(self, env, name, initial_capital, initial_assets, strategy=None):
        self.env = env
        self.name = name  # Friendly name for the participant
        self.capital = initial_capital
        self.holdings = initial_assets
        self.earnings = initial_capital
        self.starting_capital = initial_capital
        self.starting_assets = initial_assets
        self.profit_over_time = []
        self.strategy = strategy
        self.market = Market.get_instance(env)
        if strategy:
            self.env.process(self.run_strategy())
        MarketParticipant.instances.append(self)

    def __str__(self):
        return self.name

    def handle_event(self, event_type, data):
        """Handle events from the market."""
        if self.strategy and event_type == "time_tick":
            self.strategy(self, self.market, data)

    def update_earnings(self, order_type, price, quantity):
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
        print(f"Updated earnings for {self}: {self.profit_over_time[-1]}")


    def run_strategy(self):
        """Initiate the participant's strategy."""
        while True:
            yield self.env.timeout(1)  # React to market events


def ico_strategy(participant, market):
    """ICO strategy: Place a single sell order for all assets at the start of the simulation."""
    # Place an order for all assets
    market.make_order(participant, "sell", price=100, quantity=participant.holdings)
    print(f"ICO placed a sell order for all assets: {participant.holdings} at price 100")
    # Yield once to comply with SimPy's process requirements
    yield participant.env.timeout(0)


# Trader Strategies
def institutional_strategy(participant, market, current_time):
    """Institutional trader strategy based on capital and market price."""
    # Fetch the current market price (use the last trade or a default price)
    current_price = market.trade_history[-1]["price"] if market.trade_history else 100

    # Decide whether to buy or sell
    order_type = random.choice(["buy", "sell"])

    if order_type == "buy":
        # Calculate maximum affordable quantity
        max_quantity = int(participant.capital / current_price)
        if max_quantity > 0:
            # Decide quantity to trade as a fraction of max affordable
            quantity = random.randint(1, max_quantity)
            market.make_order(participant, "buy", current_price * random.uniform(0.95, 1.05), quantity)
            print(f"[{current_time}] Institutional trader made buy order: Price {current_price}, Quantity {quantity}")

    elif order_type == "sell" and participant.holdings > 0:
        # Decide quantity to trade as a fraction of holdings
        quantity = random.randint(1, participant.holdings)
        market.make_order(participant, "sell", current_price * random.uniform(0.95, 1.05), quantity)
        print(f"[{current_time}] Institutional trader made sell order: Price {current_price}, Quantity {quantity}")


def retail_strategy(participant, market, current_time):
    """Retail trader strategy based on capital, holdings, and market price."""
    # Fetch the current market price (use the last trade or a default price)
    current_price = market.trade_history[-1]["price"] if market.trade_history else 100

    # Randomly decide whether to buy or sell
    order_type = random.choice(["buy", "sell"])

    if order_type == "buy" and participant.capital > 0:
        # Calculate the maximum affordable quantity for a buy
        max_quantity_buy = int(participant.capital / current_price)
        if max_quantity_buy > 0:
            # Retail traders tend to buy smaller amounts
            quantity_buy = random.randint(1, min(max_quantity_buy, 5))  # Limit to smaller trades
            price = current_price * random.uniform(0.98, 1.02)  # Retail orders near market price
            market.make_order(participant, "buy", price, quantity_buy)
            print(f"[{current_time}] Retail trader placed buy order: Price {price:.2f}, Quantity {quantity_buy}")

    elif order_type == "sell" and participant.holdings > 0:
        # Calculate the maximum quantity the participant can sell
        max_quantity_sell = participant.holdings
        quantity_sell = random.randint(1, min(max_quantity_sell, 5))  # Retail traders sell smaller amounts
        price = current_price * random.uniform(0.98, 1.02)  # Retail orders near market price
        market.make_order(participant, "sell", price, quantity_sell)
        print(f"[{current_time}] Retail trader placed sell order: Price {price:.2f}, Quantity {quantity_sell}")



def market_maker_strategy(participant, market, current_time):
    """Market maker strategy based on capital, holdings, and market price."""
    # Fetch the current market price (use the last trade or a default price)
    current_price = market.trade_history[-1]["price"] if market.trade_history else 100

    # Spread settings for buy/sell orders relative to the market price
    buy_price = current_price * random.uniform(0.97, 0.99)  # Slightly below market price
    sell_price = current_price * random.uniform(1.01, 1.03)  # Slightly above market price

    # Buy orders
    if participant.capital > 0:
        max_quantity_buy = int(participant.capital / buy_price)
        if max_quantity_buy > 0:
            quantity_buy = random.randint(1, max_quantity_buy)
            market.make_order(participant, "buy", buy_price, quantity_buy)
            print(f"[{current_time}] Market maker placed buy order: Price {buy_price:.2f}, Quantity {quantity_buy}")

    # Sell orders
    if participant.holdings > 0:
        max_quantity_sell = participant.holdings
        quantity_sell = random.randint(1, max_quantity_sell)
        market.make_order(participant, "sell", sell_price, quantity_sell)
        print(f"[{current_time}] Market maker placed sell order: Price {sell_price:.2f}, Quantity {quantity_sell}")



# Simulation Setup
env = simpy.Environment()
market = Market.get_instance(env)

# Create participants with friendly names
ico = MarketParticipant(env, name="ICO", initial_capital=0, initial_assets=10000)
env.process(ico_strategy(ico, market))

institutional_trader = MarketParticipant(env, 
                                         name="Institutional Trader", 
                                         initial_capital=50000, initial_assets=0, strategy=institutional_strategy)
retail_trader = MarketParticipant(env, 
                                  name="Retail Trader", 
                                  initial_capital=10000, initial_assets=0, strategy=retail_strategy)
market_maker = MarketParticipant(env, 
                                 name="Market Maker", 
                                 initial_capital=10000, initial_assets=0, strategy=market_maker_strategy)

# Run the simulation
env.run(until=100)

# Debugging: Print profit over time for each participant
for participant in MarketParticipant.instances:
    if participant != ico:  # Skip the ICO participant
        print(f"{participant} profit over time: {participant.profit_over_time}")

# Final Profit Over Time Graph
plt.figure(figsize=(12, 6))

# Iterate over all participants except the ICO
for participant in MarketParticipant.instances:
    if participant != ico:  # Skip the ICO participant
        times = [entry[0] for entry in participant.profit_over_time]
        profits = [entry[1] for entry in participant.profit_over_time]
        participant_type = "Institutional Trader" if participant.strategy == institutional_strategy else \
                           "Retail Trader" if participant.strategy == retail_strategy else \
                           "Market Maker"
        plt.plot(times, profits, label=participant_type)



# Export trade data to a CSV file
def export_trade_data(market):
    """Export trade history to a CSV file."""
    import pandas as pd
    if not market.trade_history:
        print("No trade data to export.")
        return

    # Convert trade history to a DataFrame
    df = pd.DataFrame(market.trade_history)
    filename = "trade_history.csv"
    df.to_csv(filename, index=False)
    print(f"Trade history exported to {filename}.")


# Run after the simulation
export_trade_data(market)

plt.title("Participant Profits Over Time")
plt.xlabel("Time")
plt.ylabel("Profit")
plt.legend()
plt.grid(True)
plt.show()







