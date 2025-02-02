'''
Answer for Question 4 - The Training

Name: Yilin Li
SID: 530536402
unikey: yili2677

'''


def intro():
    print("Larry: I'm Larry. I'll be your hunting instructor.")
    print("Larry: Let's go to the Meadow to begin your training!")
    travel = input("Press Enter to travel to the Meadow...")
    print("Travelling to the Meadow...",
          "Larry: This is your camp. Here you'll set up your mouse trap.", sep="\n")

# tuple is used to store multiple items in the function
def setup_trap() -> tuple:
    print("Larry: Let's get your first trap...")
    set_trap = input("Press Enter to view traps that Larry is holding...")
    print("Larry is holding...", "Left: High Strain Steel Trap", "Right: Hot Tub Trap", sep="\n")
    select_trap = input("Select a trap by typing \"left\" or \"right\": ")
    # strip() method removes all spaces in the input variable
    x = select_trap.strip()
    left = "High Strain Steel Trap"
    right = "Hot Tub Trap"
    # if statement to determine the trap type set by input
    if x == "left":
        print("Larry: Excellent choice.", f"Your \"{left}\" is now set!", "Larry: You need cheese to attract a mouse.", "Larry places one cheddar on the trap!", sep="\n")
        cheddar = 1
        value = left
    elif x == "right":
        print("Larry: Excellent choice.", f"Your \"{right}\" is now set!", "Larry: You need cheese to attract a mouse.", "Larry places one cheddar on the trap!", sep="\n")
        cheddar = 1
        value = right
    else:
        print("Invalid command! No trap selected.", "Larry: Odds are slim with no trap!", sep="\n")
        value = "Cardboard and Hook Trap"
        cheddar = 0
    # return a tuple value
    return cheddar, value


def sound_horn(cheddar) -> str:
    print("Sound the horn to call for the mouse...")
    cond2 = input("Sound the horn by typing \"yes\": ")
    cond1 = cheddar
    # if statement to determine whether sound the horn and have a cheese
    if cond1 == 1 and cond2 == "yes":
        print("Caught a Brown mouse!")
        hunt_status = True
    elif cond1 == 0 and cond2 == "yes":
        print("Nothing happens.", "To catch a mouse, you need both trap and cheese!", sep="\n")
        hunt_status = False
    elif cond1 == 1 and cond2 != "yes":
        print("Nothing happens.", "To catch a mouse, you need both trap and cheese!", sep="\n")
        hunt_status = False
    else:
        print("Nothing happens.")
        hunt_status = False
    return hunt_status


def end(hunt_status: bool):
    success_hunt = hunt_status
    # if statement to determine whether 'success_hunt' has a valid value
    if success_hunt == True:
        print("Congratulations. Ye have completed the training.", "Good luck~", sep="\n")


def main():
    intro()
    # function return values will be stored in the variable
    cheddar = setup_trap()
    # cite the first value of 'cheddar' in the function to use
    hunt_status = sound_horn(cheddar[0])
    end(hunt_status)
    return cheddar[1]

# call out the functions in main() function
if __name__ == '__main__':
    main()
