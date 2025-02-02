'''
This file should borrow code from your Assignment 1.
However, it will require some modifications for this assignment.

Author: Yilin Li
SID: 530536402
Unikey: yili2677
'''


import random


def art_mouse():
    print('''Mousehunt

       ____()()
      /      @@
`~~~~~\_;m__m._>o

Inspired by Mousehunt© Hitgrab
Programmer - An INFO1110/COMP9001 Student
Mice art - Joan Stark
''')


def bob_name():
    from name import is_valid_name
    print("What's ye name, Hunter?")
    enter_name = str(input())
    # if statement to check the input name type is correct or not
    if is_valid_name(enter_name) == True:
        print(f"Welcome to the Kingdom, Hunter {enter_name}!")
    else:
        enter_name = "Bob"
        print(f"Welcome to the Kingdom, Hunter {enter_name}!")
    return enter_name


def train_test():
    print("Before we begin, let's train you up!")
    training = input(
        "Press \"Enter\" to start training or \"skip\" to Start Game: ")
    # if statement to check the input whether equal to 'skip'
    if training != 'skip':
        from train import main
        print()
        trap = main()
    else:
        trap = "Cardboard and Hook Trap"
    return trap


def user_name(hunt_name):
    print(f"\nWhat do ye want to do now, Hunter {hunt_name}?")


def get_game_menu():
    return ('''1. Exit game
2. Join the Hunt
3. The Cheese Shop
4. Change Cheese''')


def select_input():
    selection = int(input())
    return selection


def change_cheese(name: str, trap: str, cheese: list, e_flag=False) -> tuple:
    while True:
        i = 0
        trap_status = False
        trap_cheese = None
        print(f'''Hunter {name}, you currently have:
Cheddar - {cheese[0][1]}
Marble - {cheese[1][1]}
Swiss - {cheese[2][1]}''')
        print()
        arm_cheese = input("Type cheese name to arm trap: ")
        if arm_cheese.casefold() == "back":
            return trap_status, trap_cheese
        while i < len(cheese):
            if arm_cheese.casefold().capitalize().strip() == cheese[i][0]:
                find_cheddar_name = True
                break
                # break from current loop with current values
            else:
                find_cheddar_name = False
                i += 1
        if find_cheddar_name and cheese[i][1] > 0:
            cheese_to_spent = input(
                f"Do you want to arm your trap with {arm_cheese.capitalize()}? ")
            if cheese_to_spent.casefold() == "no":
                print()
                continue
                # skip the next iteration from current loopand back to beginning with current values
            elif cheese_to_spent.casefold() == "yes":
                print(f"{trap} is now armed with {arm_cheese.capitalize()}!")
                trap_status = True
                trap_cheese = arm_cheese.capitalize()
                return trap_status, trap_cheese
            elif cheese_to_spent.casefold() == "back":
                return trap_status, trap_cheese
        elif find_cheddar_name and cheese[i][1] <= 0:
            print("Out of cheese!")
            print()
            continue
        elif not find_cheddar_name:
            print("No such cheese!")
            print()
        continue


def cheese_shop(gold, cheese, trap, e_flag=False):
    from shop import intro, loop
    intro()
    gold, cheese, trap = loop(gold, cheese, trap, e_flag)
    cheese = list(cheese)
    return gold, cheese, trap


def consume_cheese(to_eat: str, cheese: str) -> tuple:
    i = 0
    while i < len(cheese):
        if to_eat == cheese[i][0]:
            num = int(cheese[i][1])
            if num > 0:
                num -= 1
                cheese[i][1] = num
                break
            else:
                cheese[i][1] = 0
                break
        i += 1
    cheese = cheese


def hunt(gold: int, cheese: list, trap_cheese: str | None, points: int) -> tuple:
    t = 0
    statement = True
    while True:
        if 0 <= t < 5:
            statement = False
            print("Sound the horn to call for the mouse...")
            sound_horn = input("Sound the horn by typing \"yes\": ")
            i = 0
            if sound_horn == 'yes':
                while i < len(cheese):
                    if trap_cheese == cheese[i][0]:
                        statement = True
                        break
                    else:
                        i += 1
                        statement = False
                        continue
            # remove all whitespaces in starting or tailing, then find string "stop" and "hunt"
            elif sound_horn.strip().find("stop") != -1 and sound_horn.strip().find("hunt") != -1:
                return gold, points
            elif sound_horn != 'yes':
                print("Do nothing.",
                      f"My gold: {gold}, My points: {points}", sep="\n", end="\n")
                print()
                t += 1
                continue
            if statement:
                if int(cheese[i][1]) > 0:
                    Sueccess_or_not = random.random()
                    if Sueccess_or_not <= 0.5:
                        print("Caught a Brown mouse!")
                        gold += 125
                        points += 115
                        consume_cheese(trap_cheese, cheese)
                        t = 0
                        statement = True
                        print(
                            f"My gold: {gold}, My points: {points}", end="\n\n")
                        continue
                    elif Sueccess_or_not > 0.5:
                        consume_cheese(trap_cheese, cheese)
                        statement = True
                        print(
                            "Nothing happens.", f"My gold: {gold}, My points: {points}", sep="\n", end="\n\n")
                        t += 1
                        continue
                else:
                    print("Nothing happens. You are out of cheese!",
                          f"My gold: {gold}, My points: {points}", sep="\n", end="\n\n")
                    t += 1
                    continue
            elif not statement:
                print("Nothing happens. You are out of cheese!",
                      f"My gold: {gold}, My points: {points}", sep="\n", end="\n\n")
                t += 1
                continue
        elif t == 5:
            statement == False
            check = input("Do you want to continue to hunt? ")
            if check == 'no':
                return gold, points
            else:
                t = 0
                continue
        break


def choice(gold, cheese, trap, points, hunt_name):
    trap_cheese = None
    while True:
        user_name(hunt_name)
        print(get_game_menu())
        opt = select_input()
        if opt == 1:
            break
        elif opt == 2:
            join_hunt = hunt(gold, cheese, trap_cheese, points)
            gold = join_hunt[0]
            points = join_hunt[1]
        elif opt == 3:
            buy = cheese_shop(gold, cheese, trap)
            gold = buy[0]
            cheese = buy[1]
            trap = buy[2]
        elif opt == 4:
            trap_name = change_cheese(hunt_name, trap, cheese)
            trap_cheese = trap_name[1]


def main():
    gold = 125
    cheese = ['Cheddar', 0], ['Marble', 0], ['Swiss', 0]
    points = 0
    art_mouse()
    hunt_name = bob_name()
    trap = train_test()
    choice(gold, cheese, trap, points, hunt_name)


if __name__ == '__main__':
    main()

