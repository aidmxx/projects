'''
Answer for Question 3 - Function

Name: Yilin Li
SID: 530536402
unikey: yili2677

'''
import os

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
    return is_valid_length(name) and is_one_word(name) and is_valid_start(name) and not is_profanity(name)


def is_profanity(word: str, database='/home/files/list.txt', records='/home/files/history.txt') -> bool:
    try:
        # open file in read mode
        with open(database, 'r') as crude_lst:
            # split each line content and insert to each list index
            check_crude_words = crude_lst.read().splitlines()
            if check_crude_words.count(word) > 0:
                try:
                    with open(records, 'a') as history_lst:
                        history_lst.write(f"{word}\n")
                    return True
                except FileNotFoundError:
                    # create a file if not exists
                    with open(records, 'a') as create_file:
                        create_file.write(word)
                    return True
            else:
                return False
    except FileNotFoundError:
        print("Check directory of database!")
        return False


def count_occurrence(word: str, file_records="/home/files/history.txt", start_flag=True) -> int:
    count = 0
    if not isinstance(word, str):
        print("First argument must be a string object!")
        return count
    elif not word or str(word).isspace() or word == None:
        print("Must have at least one character in the string!")
        return count
    elif word.strip().isalpha() is False:
        h = word.strip()
        if h[0].isalpha is False:
            print("First argument must be a string object!")
            return count
    try:
        with open(file_records, 'r') as record_lst:
            check_record_words = record_lst.read().lower().split()
            if start_flag == False:
                count = check_record_words.count(word.lower())
            else:
                i = 0
                while i < len(check_record_words):
                    check_first_alpha = check_record_words[i][0].lower()
                    h = word.strip()
                    d = check_first_alpha.count(h[0].lower().strip())
                    count += d
                    i += 1
    except FileNotFoundError:
        print("File records not found!")
    return count


def generate_name(word: str, src="/home/files/animals.txt", past="/home/files/names.txt") -> str:
    if not isinstance(word, str):
        print("First argument must be a string object!")
        return "Bob"
    elif not word or str(word).isspace() or word == None:
        print("Must have at least one character in the string!")
        return "Bob"
    elif word.strip().isalpha() is False:
        check_word = word.strip()
        if check_word[0].isalpha is False:
            print("First argument must be a string object!")
            return "Bob"
    if os.path.isfile(src) is False:
        print("Source file is not found!")
        return "Bob"
    while True:
        if os.path.isfile(past) is True:
            word_first_alphabet = word.strip()
            with open(past, "r") as used_name:
                find_used_name = used_name.read().split()
                d = 0
                lst = []
                with open(src, "r") as animal_name:
                    create_name = animal_name.read().split()
                    while d < len(create_name):
                        your_name = create_name[d][0]
                        num_same_alpha = your_name.count(word[0].lower())
                        if num_same_alpha > 0:
                            lst.append(create_name[d])
                        d += 1
                    e = 0
                    find_same_alpha_num = 0
                    while e < len(find_used_name):
                        find_same_alpha_num += find_used_name[e][0].count(
                            word[0].lower())
                        e += 1
                    # the reminder value equal to the list index, then use the index to generate new name
                    # consider in mathematical way, when the names in list are used in a round,
                    # then the reminder represent the index num that the next name should use
                    r = find_same_alpha_num % len(lst)
                    new_name = lst[r]
                    with open(past, 'a') as add_generated_name:
                        add_generated_name.write(f"\n{new_name}")
            return new_name
        else:
            f = 0
            with open(src, "r") as animal_name:
                create_name = animal_name.read().split()
                while f < len(create_name):
                    your_name = create_name[f][0]
                    num_same_alpha = your_name.count(word[0].lower())
                    if num_same_alpha == word_first_alphabet[0]:
                        new_name = num_same_alpha
                    f += 1
                with open(past, 'a') as create_past:
                    create_past.write(new_name)
            continue


def main():
    while True:
        name_input = input("Check name: ")
        if name_input == 's':
            break
        else:
            if is_valid_name(name_input) is True:
                print(f"{name_input} is a valid name!")
            else:
                exist_name = generate_name(name_input)
                print(f"Your new name is: {exist_name}")


if __name__ == '__main__':
    main()

