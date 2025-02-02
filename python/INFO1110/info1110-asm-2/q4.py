
# function to check whether input is escape keyboard
def escape_check(str):
    check = input(str).strip().casefold()
    if check == chr(27):
        return True
    else:
        return check


def intro():
    print("Larry: I'm Larry. I'll be your hunting instructor.")
    print("Larry: Let's go to the Meadow to begin your training!")
    travel = escape_check("Press Enter to travel to the Meadow...")
    if travel == True:
        return True
    print("Travelling to the Meadow...",
          "Larry: This is your camp. Here you'll set up your mouse trap.", sep="\n")


# tuple is used to store multiple items in the function
def setup_trap():
    left = "High Strain Steel Trap"
    right = "Hot Tub Trap"
    print("Larry: Let's get your first trap...")
    set_trap = escape_check(
        "Press Enter to view traps that Larry is holding...")
    if set_trap == True:
        return True
    print("Larry is holding...", "Left: High Strain Steel Trap",
          "Right: Hot Tub Trap", sep="\n")
    select_trap = escape_check(
        "Select a trap by typing \"left\" or \"right\": ")
    if select_trap == True:
        return True
    # if statement to determine the trap type set by input
    elif select_trap == "left":
        print("Larry: Excellent choice.", f"Your \"{left}\" is now set!",
              "Larry: You need cheese to attract a mouse.", "Larry places one cheddar on the trap!", sep="\n")
        cheddar = 1
        value = left
    elif select_trap == "right":
        print("Larry: Excellent choice.", f"Your \"{right}\" is now set!",
              "Larry: You need cheese to attract a mouse.", "Larry places one cheddar on the trap!", sep="\n")
        cheddar = 1
        value = right
    else:
        print("Invalid command! No trap selected.",
              "Larry: Odds are slim with no trap!", sep="\n")
        value = "Cardboard and Hook Trap"
        cheddar = 0
    # return a tuple value
    return cheddar, value


def sound_horn(cheddar) -> str:
    print("Sound the horn to call for the mouse...")
    cond2 = escape_check("Sound the horn by typing \"yes\": ")
    if cond2 == True:
        return True
    cond1 = cheddar
    # if statement to determine whether sound the horn and have a cheese
    if cond1 == 1 and cond2 == "yes":
        print("Caught a Brown mouse!")
        hunt_status = "success"
    elif cond1 == 0 and cond2 == "yes":
        print("Nothing happens.",
              "To catch a mouse, you need both trap and cheese!", sep="\n")
        hunt_status = "unsuccess"
    elif cond1 == 1 and cond2 != "yes":
        print("Nothing happens.",
              "To catch a mouse, you need both trap and cheese!", sep="\n")
        hunt_status = "unsuccess"
    else:
        print("Nothing happens.")
        hunt_status = "unsuccess"
    return hunt_status


def end(hunt_status: bool):
    success_hunt = hunt_status
    # if statement to determine whether 'success_hunt' has a valid value
    if success_hunt == "success":
        print("Congratulations. Ye have completed the training.",
              "Good luck~", sep="\n")


def main():
    travel = intro()
    if travel == True:
        return True
    # function return values will be stored in the variable
    cheddar = setup_trap()
    if cheddar == True:
        return True
    else:
        hunt_status = sound_horn(cheddar[0])
        if hunt_status == True:
            return True
        else:
            end(hunt_status)
            return cheddar[1]


# call out the functions in main() function
if __name__ == '__main__':
    main()

