'''
Answer for Question 7 - PIAT: The Hunt

Name: Yilin Li
SID: 530536402
unikey: yili2677

'''
# import all used files
import random
import name
import train
import shop


title = 'Mousehunt'
logo = '''       ____()()
      /      @@
`~~~~~\_;m__m._>o'''
author = 'An INFO1110/COMP9001 Student'

credits = f'''Inspired by Mousehunt© Hitgrab
Programmer - {author}
Mice art - Joan Stark'''
print(title, end='\n\n')
print(logo, end='\n\n')
print(credits)
print()


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
    print()
    # if statement to check the input whether equal to 'skip'
    if training != 'skip':
        from train import main
        trap = main()
        print()
    else:
        trap = "Cardboard and Hook Trap"
    return trap


def menu(hunt_name):
    print(f"What do ye want to do now, Hunter {hunt_name}?",
          "1. Exit game", "2. Join the Hunt", "3. The Cheese Shop", sep="\n")
    selection = int(input())
    return selection


def cheese_shop(gold, cheddar,trap):
    from shop import menu_choose
    print("Welcome to The Cheese Shop!",
        "Cheddar - 10 gold", sep="\n", end="\n")
    # function return values stored in the variable
    gold_cheddar= menu_choose(gold, cheddar, trap)
    return gold_cheddar

def join_hunt(gold, cheddar, award_point):
    t = 0
    statement = True
    test = 0
    while t >= 0:
        statement == True
        print("Sound the horn to call for the mouse...")
        sound_horn = input("Sound the horn by typing \"yes\": ")
        # if statement when sound_horn equal to 'yes' and the number of cheddar is great and equal to 1
        if sound_horn == 'yes' and cheddar >= 1:
            # random method return a random floating number between 0 to 1
            Sueccess_or_not = random.random()
            if Sueccess_or_not <= 0.5:
                print("Caught a Brown mouse!")
                gold = gold + 125
                cheddar = cheddar - 1
                award_point = award_point + 115
                test = test
                print(f"My gold: {gold}, My points: {award_point}", sep="\n", end="\n\n")
            elif Sueccess_or_not > 0.5:
                gold = gold
                cheddar = cheddar - 1
                award_point = award_point
                test = test + 1
                print("Nothing happens.", f"My gold: {gold}, My points: {award_point}", sep="\n", end="\n\n")
                t = t + 1
        elif sound_horn == 'yes' and cheddar == 0:           
            gold = gold
            cheddar = cheddar
            award_point = award_point
            test = test + 1
            print("Nothing happens. You are out of cheese!", f"My gold: {gold}, My points: {award_point}", sep="\n", end="\n\n")
            t = t + 1
        elif sound_horn == 'stop hunt':
            gold = gold
            cheddar = cheddar
            award_point = award_point
            test = test + 1
            return cheddar, gold, award_point
        elif sound_horn != 'yes' and cheddar >= 0:
            gold = gold
            cheddar = cheddar
            award_point = award_point
            test = test + 1
            print("Do nothing.", f"My gold: {gold}, My points: {award_point}", sep="\n", end="\n\n")
            t = t + 1
        while t == 5 and test == 5:
            statement == False
            check = input("Do you want to continue to hunt? ")
            if check == 'no':
                gold = gold
                cheddar = cheddar
                award_point = award_point
                test = 0
                return cheddar, gold, award_point
            else:
                t = 0
                gold = gold
                cheddar = cheddar
                award_point = award_point
                test = 0
                
    return gold, cheddar, award_point


def loop(gold, cheddar, hunt_name,trap, award_point):
    status = True
    # while loop runs as status is true
    while status:
        y = menu(hunt_name)
        if y == 3:
            shop = cheese_shop(gold, cheddar,trap)
            gold = shop[0]
            cheddar = shop[1]
            trap = shop[2]
            print()
        elif y == 2:
            hunt = join_hunt(gold, cheddar, award_point)
            cheddar = hunt[0]
            gold = hunt[1]
            award_point = hunt[2]
            print()
        elif y == 1:
            status = False
            return gold, cheddar,trap


def main():
    # set up the initial variable values
    gold = 125
    cheddar = 0
    award_point = 0
    # call out the functions in main() function
    hunt_name = bob_name()
    train = train_test()
    loop(gold, cheddar, hunt_name, train, award_point)


if __name__ == '__main__':
    main()
