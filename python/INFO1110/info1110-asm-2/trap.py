'''
Write your solution for the class Trap here.
This is your answer for Question 8.1.

Author: Yilin Li
SID: 530536402
Unikey: yili2677
'''


class Trap:
    def __init__(self, trap_name="", trap_cheese=None, arm_status=False, one_time_enchantment=False):
        self.trap_name = trap_name
        self.trap_cheese = trap_cheese
        self.arm_status = arm_status
        self.one_time_enchantment = one_time_enchantment

    def set_trap_name(self, name):
        if name == 'Cardboard and Hook Trap' or name == 'High Strain Steel Trap' or name == 'Hot Tub Trap':
            self.trap_name = name

    def set_trap_cheese(self, cheese):
        if cheese == 'Cheddar' or cheese == 'Marble' or cheese == 'Swiss':
            self.trap_cheese = cheese

    def set_arm_status(self):
        if self.trap_name == "" or self.trap_cheese == None:
            self.arm_status = False
        else:
            self.arm_status = True

    def set_one_time_enchantment(self, one_time_enchantment):
        if self.trap_name != 'Cardboard and Hook Trap':
            self.one_time_enchantment = one_time_enchantment
        else:
            self.one_time_enchantment = False

    def get_trap_name(self) -> str:
        return self.trap_name

    def get_trap_cheese(self) -> str:
        return self.trap_cheese

    def get_arm_status(self) -> bool:
        return self.arm_status

    def get_one_time_enchantment(self) -> bool:
        return self.one_time_enchantment

    def get_benefit(cheese: str):
        if cheese == 'Cheddar':
            benefit = "+25 points drop by next Brown mouse"
        elif cheese == 'Marble':
            benefit = "+25 gold drop by next Brown mouse"
        elif cheese == 'Swiss':
            benefit = "+0.25 attraction to Tiny mouse"
        else:
            benefit = ""
        return benefit

    def __str__(self) -> str:
        if self.one_time_enchantment is not False:
            return f"One-time Enchanted {self.trap_name}"
        else:
            return self.trap_name

