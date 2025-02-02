'''
Answer for Question 6 - PIAT: The Cheese Shop
Name: Yilin Li
SID: 530536402
unikey: yili2677
'''

# output the menu options
def selection():
    menu = "\nHow can I help ye?"
    menu1 = "1. Buy cheese"
    menu2 = "2. View inventory"
    menu3 = "3. Leave shop"
    print(menu, menu1, menu2, menu3, sep="\n")
    menu_input = int(input())
    return menu_input

# purchase the number of cheese
def buy_cheese(gold) -> tuple:
    print(f"You have {gold} gold to spend.", sep="\n")
    cheese = input("State [cheese quantity]: ")
    # split a string into a list seprated by space
    a = cheese.split()
    # if statement to check the input is correct or not and purchase the cheese
    if len(a) == 2:
        # casefold() method returns a string with all characters are lowercases
        cheese_name = a[0].casefold()
        num = int(a[1])
        if cheese_name == 'cheddar' and 0 < num * 10 <= gold:
            print(f"Successfully purchase {num} cheddar.")
            cheese_bought = num
            gold_spent = num * 10
            return gold_spent, cheese_bought
        elif cheese_name == 'cheddar' and num <= 0:
            print("Must purchase a positive amount of cheese.")
            return (0, 0)
        elif cheese_name == 'cheddar' and num * 10 >= gold:
            print("Insufficient gold.")
            return (0, 0)
        elif cheese_name != 'cheddar':
            print("Sorry, did not understand.")
            return (0, 0)
    elif cheese == "back":
        return (0, 0)
    elif len(a) >= 0:
        print("Sorry, did not understand.")
        return (0, 0)

# show out the number of gold, cheese and selected trap type
def display_inventory(gold, cheese, trap = "Cardboard and Hook Trap") -> None:
    print(f'Gold - {gold}', f'Cheddar - {cheese}', f'Trap - {trap}', sep='\n')


def menu_choose(gold, cheese_bought,trap):
    status = True
    while status:
        # call the function runs in a loop as the statement is true
        x = selection()
        if x == 1:
            buy = buy_cheese(gold)
            gold = gold - buy[0]
            cheese_bought = buy[1] + cheese_bought
        elif x == 2:
            display_inventory(gold, cheese_bought, trap)
        elif x == 3:
            status = False
    return gold, cheese_bought,trap


def main():
    print("Welcome to The Cheese Shop!",
          "Cheddar - 10 gold", sep="\n", end="\n")
    # set up the inital variable values
    gold = 125
    cheese_bought = 0
    trap = "Cardboard and Hook Trap"
    gold_cheese_bought = menu_choose(gold, cheese_bought,trap)
    return gold_cheese_bought[0],gold_cheese_bought[1],gold_cheese_bought[2]


if __name__ == '__main__':
    main()
