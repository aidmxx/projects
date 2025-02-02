'''
Write your solution for the class Hunter here.
This is your answer for Question 8.2.

Author: Yilin Li
SID: 530536402
Unikey: yili2677
'''

from hunter import Hunter
import game
from cshop import CheeseShop
from trap import Trap

class Interface:
    def __init__(self, menu={"1": "1. Exit game", "2": "2. Join the Hunt", "3": "3. The Cheese Shop", "4": "4. Change Cheese"}, player=Hunter()):
        self.menu = menu
        self.player = player

    def get_menu(self) -> dict:
        return f"{self.menu['1']}\n{self.menu['2']}\n{self.menu['3']}\n{self.menu['4']}"

    def change_cheese(self):
        name = ""
        trap_name = ""
        enchantment = True
        while True:
            self.player.set_name(name)
            print(f"Hunter {self.player.name}, you currently have:")
            print(self.player.get_cheese())
            print()
            arm_cheese = input("Type cheese name to arm trap: ")
            if arm_cheese.strip() == "back":
                break
            else:
                self.player.trap.set_trap_cheese(arm_cheese.strip().capitalize())
                self.player.trap.get_trap_cheese()
                self.player.trap.set_trap_name(trap_name)
                self.player.trap.get_trap_name()
                self.player.trap.set_arm_status()
                self.player.trap.get_arm_status()
                self.player.trap.set_one_time_enchantment(enchantment)
                self.player.trap.get_one_time_enchantment()
                if self.player.trap.get_arm_status() is True:
                    if self.player.have_cheese() != 0:
                        if self.player.trap.get_one_time_enchantment() is True:
                            print(f"Your One-time Enchanted {self.player.trap.trap_name} has a one-time enchantment granting {Trap.get_benefit(arm_cheese.strip().capitalize())}.")
                        arm = input(f"Do you want to arm your trap with {self.player.trap.trap_cheese}? ")
                        if arm == 'yes':
                            if self.player.trap.one_time_enchantment is True:
                                print(f"{self.player.trap} is now armed with {self.player.trap.trap_cheese}!")
                            else:
                                print(f"{self.player.trap.trap_name} is now armed with {self.player.trap.trap_cheese}!")
                            break
                        elif arm == "no":
                            print()
                            continue
                        elif arm == "back":
                            self.player.trap.arm_status = None
                            break
                    else:
                        print("Out of cheese!")
                        print()
                        continue
                else:
                    print("No such cheese!")
                    print()
                    continue

    def cheese_shop(self):
        shop = CheeseShop()
        shop.move_to(self.player)

    def hunt(self):
        game.hunt(self.player.gold, self.player.cheese, self.player.trap.trap_cheese, self.player.points)

    def move_to(self, choice):
        if isinstance(choice, int):
            if 1 <= choice <= 4:
                if choice == 1:
                    exit()
                elif choice == 2:
                    self.hunt()
                elif choice == 3:
                    print(CheeseShop().greet())
                    print()
                    CheeseShop().move_to(self.player)
                elif choice == 4:
                    self.change_cheese()
            else:
                print("Must be within 1 and 4.")
        else:
            print("Invalid input. Try again!")

