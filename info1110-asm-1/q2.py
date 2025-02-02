'''
Answer for Question 2 - What's ye called?

Name: Yilin Li
SID: 530536402
unikey: yili2677

'''


print("Larry: What's ye name, Hunter?")
name = input()
# len(object) function returns the number of items in an object
name_length = len(name)
is_valid_length = name_length >= 1 and name_length <= 9
# str[0].isalpha() is focus on the first character of the input value and finds whether it starts with an alphabet
is_valid_start = name != "" and name[0].isalpha()
# str.find(' ') is used to find the space occurance of the input value
is_one_word = name != "" and not (name.find(' ') != -1)
# boolean value
is_valid_name = is_valid_length and is_valid_start and is_one_word
print(f"Larry: Is '{name}' a name I can pronounce?")
print(
    f"It has a length of {name_length} which is between 1 to 9 characters? {is_valid_length}!")
print(f"It starts with an alphabet? {is_valid_start}")
print(f"It is a single word? {is_one_word}")
print(f"Larry: I can pronounce this name --- {is_valid_name}")
