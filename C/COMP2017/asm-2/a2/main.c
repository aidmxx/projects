#include "mtll.h"
#include <ctype.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// check the command type
int valid_command(char *command) {
  if (strcmp(command, "NEW") == 0) {
    return 1;
  } else if (strcmp(command, "VIEW") == 0) {
    return 2;
  } else if (strcmp(command, "TYPE") == 0) {
    return 3;
  } else if (strcmp(command, "REMOVE") == 0) {
    return 4;
  } else if (strcmp(command, "REMOVE") == 0) {
    return 4;
  } else if (strcmp(command, "INSERT") == 0) {
    return 5;
  } else if (strcmp(command, "DELETE") == 0) {
    return 6;
  } else if (strcmp(command, "VIEW-NESTED") == 0) {
    return 7;
  } else {
    return -1;
  }
  return 0;
}

// test only for common commands in Part 1
int part1_elem_check(char *elem) {
  // the 2nd command arguement only can be 'ALL' if it's a string
  if (strcmp(elem, "ALL") == 0) {
    return 0;
  }
  errno = 0;
  char *check;
  // check 2nd command arguement is an integer
  long val = strtol(elem, &check, 10);
  if (errno == ERANGE || *check != '\0' || val < 0) {
    return -1;
  }
  if (val < 0) {
    return -1;
  }
  if (strchr(elem, '.') != NULL) {
    return -1;
  }
  return (int)val;
}

// command arguements check for DELETE and INSERT
int delete_insert_elem_check(char *id, char *index) {
  char *check1, *check2;
  errno = 0;
  long val1 = strtol(id, &check1, 10);
  if (check1 == id || *check1 != '\0' || errno == ERANGE || val1 < 0) {
    return -1;
  }
  errno = 0;
  strtol(index, &check2, 10);
  if (check2 == index || *check2 != '\0' || errno == ERANGE) {
    return -1;
  }
  if (val1 < 0) {
    return -1;
  }
  return 0;
}

int elem_format(char *elem) {
  // if a nested element
  for (int i = 0; elem[i] != '\0'; i++) {
    if (elem[i] == '{' || elem[i] == '}') {
      return 0;
    }
  }
  char *int_convert, *float_convert;
  errno = 0;
  strtol(elem, &int_convert, 10);
  if (errno == ERANGE ||
      (errno == 0 && elem != int_convert && *int_convert == '\0')) {
    return 1;
  }
  errno = 0;
  strtof(elem, &float_convert);
  if (errno == 0 && elem != float_convert && *float_convert == '\0') {
    return 2;
  }
  if (int_convert == elem || float_convert == elem) {
    if (strlen(elem) == 1 && isprint((unsigned char)elem[0])) {
      return 3;
    }
  }
  return 4;
}

int main(int argc, char **argv) {
  char buf[256];
  int j, ctr;
  char command[100][256];
  struct mtll *Node = NULL;
  int list_count = 0;
  while (fgets(buf, sizeof(buf), stdin) != NULL) {
    // printf("%s\n", buf);
    if (buf[0] == ' ') {
      printf("INVALID COMMAND: INPUT\n");
      continue;
    }
    j = 0;
    ctr = 0;
    for (int i = 0; i <= strlen(buf); i++) {
      if (buf[i] == ' ' || buf[i] == '\n') {
        command[ctr][j] = '\0';
        ctr++;
        j = 0;
      } else {
        command[ctr][j] = buf[i];
        j++;
      }
    }
    int command_check = valid_command(command[0]);
    if (command_check > 0) {
      // invalid input length
      if (ctr != 2 && command_check >= 1 && command_check <= 4) {
        if (command_check == 1) {
          printf("INVALID COMMAND: NEW\n");
          continue;
        } else if (command_check == 2 || command_check == 7) {
          printf("INVALID COMMAND: VIEW\n");
          continue;
        } else if (command_check == 3) {
          printf("INVALID COMMAND: TYPE\n");
          continue;
        } else if (command_check == 4) {
          printf("INVALID COMMAND: REMOVE\n");
          continue;
        }
      } else if (ctr < 4 && command_check == 5) {
        printf("INVALID COMMAND: INSERT\n");
        continue;
      } else if (ctr != 3 && command_check == 6) {
        printf("INVALID COMMAND: DELETE\n");
        continue;
      }
    } else {
      printf("INVALID COMMAND: INPUT\n");
      continue;
    }
    // invalid command type
    if (command_check <= 0) {
      printf("INVALID COMMAND: INPUT\n");
    }
    int index = 0, check = 0;
    if (ctr == 2) {
      // invalid command argumenets
      index = part1_elem_check(command[1]);
      if (index == -1) {
        if (command_check == 1) {
          printf("INVALID COMMAND: NEW\n");
        } else if (command_check == 2 || command_check == 7) {
          // as "ALL" considered as an argument of "NEW" command
          printf("INVALID COMMAND: VIEW\n");
        } else if (command_check == 3) {
          printf("INVALID COMMAND: TYPE\n");
        } else if (command_check == 4) {
          printf("INVALID COMMAND: REMOVE\n");
        }
        continue;
      }
    } else {
      check = delete_insert_elem_check(command[1], command[2]);
      if (check == -1) {
        if (command_check == 5) {
          printf("INVALID COMMAND: INSERT\n");
        } else if (command_check == 6) {
          printf("INVALID COMMAND: DELETE\n");
        }
        continue;
      }
    }
    if (command_check == 1) {
      int stdin_error = 0;
      int brackets = 0;
      char buf[256];
      error_status = 0;
      is_list_valid(&Node);
      valid_list_order(&Node, list_count);
      for (int i = 0; i < index; i++) {
        if (fgets(buf, sizeof(buf), stdin) != NULL) {
          // remove the newline character
          buf[strcspn(buf, "\n")] = 0;
          if (elem_format(buf) > 0) {
            list_add(&Node, buf, elem_format(buf));
          } else if (elem_format(buf) == 0) {
            char list_num[10];
            int j = 0;
            for (int i = 0; buf[i] != '\0'; i++) {
              if (!(buf[i] == '{' || buf[i] == '}')) {
                list_num[j] = buf[i];
                j++;
              }
            }
            errno = 0;
            char *endptr;
            strtol(list_num, &endptr, 10);
            if (endptr == list_num || errno == ERANGE || errno != 0 ||
                *endptr != '\0') {
              printf("INVALID COMMAND: NEW\n");
              break;
            }
            list_add(&Node, list_num, elem_format(buf));
            nested_list(&Node, list_num);
            brackets = 1;
          }
        } else {
          stdin_error++;
        }
      }
      if (stdin_error == 0 && error_status == 0 && errno == 0) {
        if (brackets == 1) {
          printf("Nested %d: ", list_count);
        } else {
          printf("List %d: ", list_count);
        }
        separator_build(&Node);
        print_out(&Node, list_count);
        list_count++;
      }
    } else if (command_check == 2) {
      // consider the command "VIEW ALL"
      if (strcmp(command[1], "ALL") == 0) {
        mtll_view_all(&Node);
      } else {
        mtll_view(&Node, index);
        printf("\n");
      }
    } else if (command_check == 3) {
      mtll_type(&Node, index);
    } else if (command_check == 4) {
      mtll_remove(&Node, index);
    } else if (command_check == 5) {
      char elem[1024];
      strcpy(elem, command[3]);
      for (int i = 4; i < ctr; i++) {
        strcat(elem, " ");
        strcat(elem, command[i]);
      }
      if (elem_format(elem) == 0) {
        char list_num[10];
        int j = 0;
        for (int i = 0; elem[i] != '\0'; i++) {
          if (!(elem[i] == '{' || elem[i] == '}')) {
            list_num[j] = elem[i];
            j++;
          }
        }
        list_num[j] = '\0';
        errno = 0;
        char *endptr;
        strtol(list_num, &endptr, 10);
        if (endptr == list_num || errno == ERANGE || errno != 0 ||
            *endptr != '\0') {
          printf("INVALID COMMAND: INSERT\n");
          continue;
        }
        mtll_insert(&Node, atoi(command[1]), atoi(command[2]), list_num,
                    elem_format(elem));
      } else {
        mtll_insert(&Node, atoi(command[1]), atoi(command[2]), elem,
                    elem_format(elem));
      }
    } else if (command_check == 6) {
      mtll_delete(&Node, atoi(command[1]), atoi(command[2]));
    } else if (command_check == 7) {
      mtll_view_nested(&Node, index);
    }
  }
  // for (int i = 0; i < ctr; i++) {
  //     printf("%s\n", command[i]);
  // }
  // free memory
  mtll_free(&Node);
  return 0;
}