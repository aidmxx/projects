'''
Write your solution to 1. Upgraded Cheese Shop here.
It should borrow code from Assignment 1.

Author: Yilin Li
SID: 530536402
Unikey: yili2677
'''

CHEESE_MENU = (("Cheddar", 10), ("Marble", 50), ("Swiss", 100))


def intro():
    print(f'''Welcome to The Cheese Shop!
{CHEESE_MENU[0][0]} - {CHEESE_MENU[0][1]} gold
{CHEESE_MENU[1][0]} - {CHEESE_MENU[1][1]} gold
{CHEESE_MENU[2][0]} - {CHEESE_MENU[2][1]} gold''')


def menu():
    menu1 = "1. Buy cheese"
    menu2 = "2. View inventory"
    menu3 = "3. Leave shop"
    print("\nHow can I help ye?", menu1, menu2, menu3, sep="\n")


def buy_cheese(gold: int) -> tuple:
    gold_spent = 0
    cheese_bought = [0, 0, 0]
    while True:
        print(f"You have {gold} gold to spend.", sep="\n")
        cheese_input = input("State [cheese quantity]: ")
        check_cheese = cheese_input.split()
        if cheese_input.casefold() == "back":
            break
        i = 0
        if len(cheese_input) > 0:
            while i < len(CHEESE_MENU):
                if check_cheese[0].capitalize() == CHEESE_MENU[i][0]:
                    find_cheddar_name = True
                    break
                else:
                    find_cheddar_name = False
                    i += 1
            if find_cheddar_name:
                try:
                    num = int(check_cheese[1])
                except:
                    if len(check_cheese) == 2:
                        print("Invalid quantity.")
                        continue
                    else:
                        print("Missing quantity.")
                        continue
                if CHEESE_MENU[i][1] * num <= 0:
                    print("Must purchase positive amount of cheese.")
                elif 0 < CHEESE_MENU[i][1] * num <= gold:
                    print(f"Successfully purchase {num} {check_cheese[0].casefold()}.")
                    only_spent = CHEESE_MENU[i][1] * num
                    cheese_bought[i] += num
                    gold -= only_spent
                    gold_spent += only_spent
                elif 0 < CHEESE_MENU[i][1] * num and CHEESE_MENU[i][1] * num > gold:
                    print("Insufficient gold.")
            else:
                print(f"We don't sell {check_cheese[0].casefold()}!")
            continue
        else:
            print(f"We don't sell {cheese_input}!")
            continue
    return gold_spent, tuple(cheese_bought)


def display_inventory(gold: int, cheese: list, trap: str, e_flag = False) -> None:
    print(f'''Gold - {gold}
Cheddar - {cheese[0][1]}
Marble - {cheese[1][1]}
Swiss - {cheese[2][1]}''')
    if e_flag == False:
        print(f"Trap - {trap}")
    else:
        print(f"Trap - One-time Enchanted {trap}")


def option():
    selection = input()
    return selection


def loop(gold, cheese, trap, e_flag = False):
    status = True
    while status:
        menu()
        selection = option()
        # call the function runs in a loop as the statement is true
        if selection.isdigit() and 1 <= int(selection) <= 3:
            if int(selection) == 1:
                buy = buy_cheese(gold)
                gold -= buy[0]
                cheese_bought = buy[1]
                i = 0
                while i < len(cheese):
                    cheese[i][1] += cheese_bought[i]
                    i += 1
            elif int(selection) == 2:
                display_inventory(gold, cheese, trap, e_flag)
            elif int(selection) == 3:
                status = False
        else:
            print("I did not understand.")
    return gold, cheese, trap


def main():
    gold = 125
    cheese = [["Cheddar", 0], ["Marble", 0], ["Swiss", 0]]
    trap = 'Cardboard and Hook Trap'
    intro()
    gold_cheddar = loop(gold, cheese, trap)
    return gold_cheddar[0], gold_cheddar[1], gold_cheddar[2]

if __name__ == "__main__":
    main()

