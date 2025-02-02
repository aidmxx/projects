'''
Answer for Question 7 - PIAT: Improved Full Game.

Author: Yilin Li
SID: 530536402
Unikey: yili2677
'''

import setup
from datetime import datetime
import game
import name
import mouse


def run_setup():
    master = "/home/game_master/"
    timestamp = setup.current_time()
    check_verify = setup.verification(master, timestamp)
    # format current date and time
    dt = datetime.strptime(timestamp, "%d %b %Y %H:%M:%S")
    date_str = dt.strftime('%Y-%b-%d')
    time_str = dt.strftime('%H_%M_%S')
    i = 0
    while i < len(check_verify):
        if check_verify[i] == "Abnormalities detected...":
            check = 1
            break
        else:
            check = 0
            i += 1
    if check == 1:
        ask_repair = input("Do you want to repair the game? ")
        if ask_repair.strip() == 'yes':
            flag = True
            setup.logging(setup.installation(
                master, timestamp), date_str, time_str)
            print('''Launching game...
.
.
.''')
        else:
            flag = False
            print("Game may malfunction and personalization will be locked.")
            process_check = input("Are you sure you want to proceed? ")
            if process_check.strip() == 'yes':
                print("You have been warned!!!")
                print('''Launching game...
.
.
.''')
            else:
                exit()
    else:
        flag = True
        setup.logging(setup.installation(
            master, timestamp), date_str, time_str)
        print('''Launching game...
.
.
.''')
    return flag


def mouse_art():
    print('''Mousehunt

       ____()()
      /      @@
`~~~~~\_;m__m._>o

Inspired by Mousehunt© Hitgrab
Programmer - An INFO1110/COMP9001 Student
Mice art - Joan Stark and Hayley Jane Wakenshaw
''')


def personalization(tamper_flag):
    player_name = 'Bob'
    if tamper_flag == False:
        print(f"Welcome to the Kingdom, Hunter {player_name}!")
    else:
        num = 0
        while num <= 3:
            player_name = input("What's ye name, Hunter? ")
            if num == 0:
                if name.is_valid_name(player_name) is False:
                    print('''That's not nice!
I'll give ye 3 attempts to get it right or I'll name ye!
Let's try again...''')
                else:
                    print(f"Welcome to the Kingdom, Hunter {player_name}!")
                    break
            elif 0 < num < 3:
                if name.is_valid_name(player_name) is False:
                    print(f"Nice try. Strike {num}!")
                else:
                    print(f"Welcome to the Kingdom, Hunter {player_name}!")
                    break
            elif num == 3:
                if name.is_valid_name(player_name) is False:
                    player_name = name.generate_name(player_name)
                    print(f'''Nice try. Strike {num}!
I told ye to be nice!!!
Welcome to the Kingdom, Hunter {player_name}!''')
                else:
                    print(f"Welcome to the Kingdom, Hunter {player_name}!")
                    break
            num += 1
    return player_name


def train():
    trap = game.train_test()
    return trap


def game_menu(player_name):
    return f'''\nWhat do ye want to do now, Hunter {player_name}?
{game.get_game_menu()}'''


def get_benefit(cheese):
    if cheese == 'cheddar':
        benefit = "+25 points drop by next Brown mouse"
    elif cheese == 'marble':
        benefit = "+25 gold drop by next Brown mouse"
    elif cheese == 'swiss':
        benefit = "+0.25 attraction to Tiny mouse"
    return benefit


def change_cheese(name: str, trap: str, cheese: list, e_flag) -> tuple:
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
                if e_flag == True:
                    benefit = get_benefit(arm_cheese.casefold().strip())
                    print(
                        f"Your One-time Enchanted {trap} has a one-time enchantment granting {benefit}.")
                break
            else:
                find_cheddar_name = False
                i += 1
        if find_cheddar_name and cheese[i][1] > 0:
            cheese_to_spent = input(
                f"Do you want to arm your trap with {arm_cheese.capitalize()}? ")
            if cheese_to_spent.casefold() == "no":
                print()
                continue
            elif cheese_to_spent.casefold() == "yes":
                if e_flag == True:
                    print(
                        f"One-time Enchanted {trap} is now armed with {arm_cheese.capitalize()}!")
                else:
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


def consume_cheese(to_eat, my_cheese):
    i = 0
    while i < len(my_cheese):
        if to_eat == my_cheese[i][0]:
            num = int(my_cheese[i][1])
            if num > 0:
                num -= 1
                my_cheese[i][1] = num
                break
            else:
                my_cheese[i][1] = 0
                break
        i += 1
    my_cheese = my_cheese


def check_enchant(trap_cheese, gold, points, enchant, caught_mouse):
    gold = gold
    points = points
    if enchant == True:
        if trap_cheese == 'Marble' and caught_mouse == 'Brown':
            gold += 25
        elif trap_cheese == 'Cheddar' and caught_mouse == 'Brown':
            points += 25
    return gold, points


def hunt(gold, cheese, trap_cheese, enchant, points):
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
            elif sound_horn.strip().find("stop") != -1 and sound_horn.strip().find("hunt") != -1:
                enchant = False
                return gold, points
            elif sound_horn != 'yes':
                print(
                    "Do nothing.", f"My gold: {gold}, My points: {points}", sep="\n", end="\n")
                print()
                t += 1
                continue
            if statement:
                if int(cheese[i][1]) > 0:
                    caught_mouse = mouse.generate_mouse(trap_cheese, enchant)
                    if caught_mouse != None:
                        gold, points = check_enchant(
                            trap_cheese, gold, points, enchant, caught_mouse)
                        print(f"Caught a {caught_mouse} mouse!")
                        print(mouse.generate_coat(caught_mouse))
                        earn_gold, earn_points = mouse.loot_lut(caught_mouse)
                        gold += earn_gold
                        points += earn_points
                        consume_cheese(trap_cheese, cheese)
                        t = 0
                        statement = True
                        enchant = False
                        print(
                            f"My gold: {gold}, My points: {points}", end="\n\n")
                        continue
                    else:
                        consume_cheese(trap_cheese, cheese)
                        statement = True
                        enchant = False
                        print(
                            "Nothing happens.", f"My gold: {gold}, My points: {points}", sep="\n", end="\n\n")
                        t += 1
                        continue
                else:
                    print("Nothing happens. You are out of cheese!",
                          f"My gold: {gold}, My points: {points}", sep="\n", end="\n\n")
                    enchant = False
                    t += 1
                    continue
            elif not statement:
                print("Nothing happens. You are out of cheese!",
                      f"My gold: {gold}, My points: {points}", sep="\n", end="\n\n")
                enchant = False
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
    return gold, points


def selection(gold, cheese, points, trap_cheese, name, trap, enchant):
    while True:
        print(game_menu(name))
        while True:
            option_select = input("Enter a number between 1 and 4: ")
            if not option_select.isdigit():
                print("Invalid input.")
            elif option_select.isdigit() and not 1 <= int(option_select) <= 4:
                print("Must be between 1 and 4.")
            elif option_select.isdigit() and 1 <= int(option_select) <= 4:
                if int(option_select) == 1:
                    exit()
                elif int(option_select) == 2:
                    gold, points = hunt(
                        gold, cheese, trap_cheese, enchant, points)
                    enchant = False
                    break
                elif int(option_select) == 3:
                    print()
                    gold, cheese, trap = game.cheese_shop(
                        gold, cheese, trap, enchant)
                    break
                elif int(option_select) == 4:
                    print()
                    change = change_cheese(name, trap, cheese, enchant)
                    trap_cheese = change[1]
                    break


def main():
    gold = 125
    cheese = ['Cheddar', 0], ['Marble', 0], ['Swiss', 0]
    points = 0
    trap_cheese = None
    flag = run_setup()
    mouse_art()
    name = personalization(flag)
    trap = train()
    if trap == 'Cardboard and Hook Trap':
        enchant = False
    else:
        enchant = True
    selection(gold, cheese, points, trap_cheese, name, trap, enchant)


if __name__ == '__main__':
    main()

