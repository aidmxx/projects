'''
Write your solution for the class CheeseShop here.
This is your answer for Question 8.3.

Author: Yilin Li
SID: 530536402
Unikey: yili2677
'''

import shop
from hunter import Hunter


class CheeseShop:
    def __init__(self, cheeses={"1": "Cheddar - 10 gold", "2": "Marble - 50 gold", "3": "Swiss - 100 gold"}, menu={"1": "1. Buy cheese", "2": "2. View inventory", "3": "3. Leave shop"}):
        self.cheeses = cheeses
        self.menu = menu

    def get_cheeses(self):
        return f"{self.cheeses['1']}\n{self.cheeses['2']}\n{self.cheeses['3']}"

    def get_menu(self):
        return f"{self.menu['1']}\n{self.menu['2']}\n{self.menu['3']}"

    def greet(self):
        return f'''Welcome to The Cheese Shop!
{self.cheeses['1']}\n{self.cheeses['2']}\n{self.cheeses['3']}'''

    def buy_cheese(self, gold:int):
        bought = list(shop.buy_cheese(gold))
        bought[0] = gold - bought[0]
        bought = tuple(bought)
        return bought

    def move_to(self, player: Hunter):
        while True:
            print(f'''How can I help ye?
{self.get_menu()}''')
            option = input()
            if option.isdigit() is True:
                if int(option) == 1:
                    self.buy_cheese(gold=125)
                    print()
                elif int(option) == 2:
                    print(player.display_inventory())
                    print()
                elif int(option) == 3:
                    exit()
                elif int(option) < 1 or int(option) > 3:
                    raise ValueError
            else:
                print("I did not understand.")
                print()

