'''
Answer for Question 5 - The Training Again

Name: Yilin Li
SID: 530536402
unikey: yili2677

'''
import q4

def main():
    # get access to functions from file q4
    from q4 import setup_trap,sound_horn,end,main
    trap = main()
    start_training = False
    # while loop executes a set of statements as a condition is true
    while not start_training:  
        training = input("\nPress Enter to continue training and \"no\" to stop training: ")
        # if statement to determine the training equal to 'no' or not
        if training == "no":
            start_training = True
        else:
            cheese = setup_trap()
            hunt_status = sound_horn(cheese[0])
            end(hunt_status)
            trap = cheese[1]
    return trap

        
if __name__ == '__main__':
    main()
