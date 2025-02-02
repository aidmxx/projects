'''
Write your solution for the class Hunter here.
This is your answer for Question 8.2.

Author: Yilin Li
SID: 530536402
Unikey: yili2677
'''
from trap import Trap
from name import is_valid_name


class Hunter:
    def __init__(self, name='Bob', cheese=[['Cheddar', 0], ['Marble', 0], ['Swiss', 0]], trap=Trap(), gold=125, points=0):
        self.name = name
        self.cheese = cheese
        self.trap = trap
        self.gold = gold
        self.points = points

    def set_name(self, player_name):
        if is_valid_name(player_name) is True:
            self.name = player_name

    def set_cheese(self, cheese):
        if isinstance(cheese, tuple):
            j = 0
            while j < len(cheese):
                self.cheese[j][1] = cheese[j]
                j += 1

    def set_gold(self, gold):
        if isinstance(gold, int):
            self.gold = gold

    def set_points(self, points):
        if isinstance(points, int):
            self.points = points

    def get_name(self) -> str:
        return self.name

    def get_cheese(self) -> str:
        cheese_quantity = ""
        i = 0
        while i < len(self.cheese):
            if i != 2:
                cheese_quantity += f"{self.cheese[i][0]} - {self.cheese[i][1]}\n"
                i += 1
            else:
                cheese_quantity += f"{self.cheese[i][0]} - {self.cheese[i][1]}"
                break
        return cheese_quantity

    def get_gold(self) -> int:
        return self.gold

    def get_points(self) -> int:
        return self.points

    def update_cheese(self, cheese_num):
        if isinstance(cheese_num, tuple):
            k = 0
            while k < len(self.cheese):
                self.cheese[k][1] += cheese_num[k]
                k += 1

    def consume_cheese(self, cheese_type):
        x = 0
        while x < len(self.cheese):
            if cheese_type == self.cheese[x][0]:
                self.cheese[x][1] -= 1
            x += 1

    def have_cheese(self, cheese_type='Cheddar'):
        if isinstance(cheese_type, str):
            y = 0
            while y < len(self.cheese):
                if cheese_type == self.cheese[y][0]:
                    return self.cheese[y][1]
                y += 1
        return 0

    def display_inventory(self):
        cheese_quantity = ""
        t = 0
        while t < len(self.cheese):
            if t != 2:
                cheese_quantity += f"{self.cheese[t][0]} - {self.cheese[t][1]}\n"
                t += 1
            else:
                cheese_quantity += f"{self.cheese[t][0]} - {self.cheese[t][1]}"
                break
        return f'''Gold - {self.gold}
{cheese_quantity}
Trap - {self.trap}'''

    def arm_trap(self, cheese_type):
        if self.have_cheese(cheese_type) != 0:
            self.trap.set_trap_cheese(cheese_type)
        else:
            self.trap.trap_cheese = None
        self.trap.set_arm_status()
        
    def update_gold(self, gold):
        if isinstance(gold, int):
            self.gold += gold

    def update_points(self, points):
        if isinstance(points, int):
            self.points += points

    def __str__(self) -> str:
        return f'''Hunter {self.name}
Gold - {self.gold}
{self.cheese[0][0]} - {self.cheese[0][1]}
{self.cheese[1][0]} - {self.cheese[1][1]}
{self.cheese[2][0]} - {self.cheese[2][1]}
Trap - {self.trap}'''

