'''
Answer for Question 5 - The Training Again from Assignment 1.

Author: Yilin Li
SID: 530536402
unikey: yili2677
'''


def main():
    # get access to functions from file q4
    from q4 import setup_trap, sound_horn, end, main, escape_check
    while True:
        trap = main()
        if trap == True:
            return "Cardboard and Hook Trap"
        else:
            while True:
                training = escape_check(
                    "\nPress Enter to continue training and \"no\" to stop training: ")
                # if statement to determine the training equal to 'no' or not
                if training == "no" or training is True:
                    return trap
                else:
                    cheddar = setup_trap()
                    if cheddar == True:
                        return "Cardboard and Hook Trap"
                    else:
                        # cite the first value of 'cheddar' in the function to use
                        hunt_status = sound_horn(cheddar[0])
                        if hunt_status == True:
                            return cheddar[1]
                        else:
                            end(hunt_status)
                continue


if __name__ == '__main__':
    main()

