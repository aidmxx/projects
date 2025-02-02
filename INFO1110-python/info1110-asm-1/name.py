'''
Answer for Question 3 - Function

Name: Yilin Li
SID: 530536402
unikey: yili2677

'''

# def() function is used to declare a function
def is_valid_length(name: str) -> bool:
    # check whether the length of 'name' is between 1 and 9
    name_length = len(name) >= 1 and len(name) <= 9
    # return variable from the function
    return name_length


def is_valid_start(name: str) -> bool:
    # check whether the 'name' is not empty and the first letter is an alphabetic letter
    word_start = name != "" and name[0].isalpha()
    return word_start


def is_one_word(name: str) -> bool:
    # find() method is used to find first occurrence of the specified value
    # if find() return -1, means the value is not found
    # check the 'name' is not empty and doesn't contain any space
    one_word = name != "" and not (name.find(' ') != -1)
    return one_word


def is_valid_name(name: str) -> bool:
    return is_valid_length(name) and is_one_word(name) and is_valid_start(name)
