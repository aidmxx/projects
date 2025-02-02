'''
Write solutions to 3. New Mouse Release here.

Author: Yilin Li
SID: 530536402
Unikey: yili2677
'''
import random
import art

TYPE_OF_MOUSE = (None, "Brown", "Field", "Grey", "White", "Tiny")


def generate_mouse(cheese='Cheddar', enchant=False) -> str | None:
    rand_num = random.random()
    prob = list(generate_probabilities(cheese, enchant))
    i = 1
    while i < len(prob):
        # rounds the sum to 2 decimal places
        prob[i] = round(prob[i-1] + prob[i], 2)
        i += 1
    # insert an integer "0" at 0 index
    prob.insert(0, 0)
    j = 0
    while j < len(prob):
        # check if within the probability, e.g., [0.5, 0.6)
        if prob[j] <= rand_num < prob[j+1]:
            spawn_mouse = TYPE_OF_MOUSE[j]
            break
        else:
            j += 1
    return spawn_mouse


def loot_lut(mouse_type: str | None) -> tuple:
    if mouse_type == None:
        gold = 0
        points = 0
    elif mouse_type == "Brown":
        gold = 125
        points = 115
    elif mouse_type == "Field":
        gold = 200
        points = 200
    elif mouse_type == "Grey":
        gold = 125
        points = 90
    elif mouse_type == "White":
        gold = 100
        points = 70
    elif mouse_type == "Tiny":
        gold = 900
        points = 200
    return gold, points


def generate_probabilities(cheese_type, enchant=False):
    if enchant == False:
        rate = ()
        if cheese_type == 'Cheddar':
            rate = (0.5, 0.1, 0.15, 0.1, 0.1, 0.05)
        elif cheese_type == 'Marble':
            rate = (0.6, 0.05, 0.2, 0.05, 0.02, 0.08)
        elif cheese_type == 'Swiss':
            rate = (0.7, 0.01, 0.05, 0.05, 0.04, 0.15)
    else:
        if cheese_type == 'Swiss':
            rate = (0.45, 0.01, 0.05, 0.05, 0.04, 0.4)
        elif cheese_type == 'Cheddar':
            rate = (0.5, 0.1, 0.15, 0.1, 0.1, 0.05)
        elif cheese_type == 'Marble':
            rate = (0.6, 0.05, 0.2, 0.05, 0.02, 0.08)
    return rate


def generate_coat(mouse_type: str | None):
    if mouse_type == TYPE_OF_MOUSE[1]:
        return art.BROWN
    elif mouse_type == TYPE_OF_MOUSE[2]:
        return art.FIELD
    elif mouse_type == TYPE_OF_MOUSE[3]:
        return art.GREY
    elif mouse_type == TYPE_OF_MOUSE[4]:
        return art.WHITE
    elif mouse_type == TYPE_OF_MOUSE[5]:
        return art.TINY


class Mouse:
    def __init__(self, cheese='Cheddar', enchant=False):
        self.name = generate_mouse(cheese, enchant)
        self.gold, self.points = loot_lut(self.name)
        self.coat = generate_coat(self.name)

    def get_name(self) -> str:
        return self.name

    def get_gold(self) -> int:
        return self.gold

    def get_points(self) -> int:
        return self.points

    def get_coat(self) -> str:
        return self.coat

    def __str__(self) -> str:
        if self.name is None:
            return "None"
        else:
            return self.name

