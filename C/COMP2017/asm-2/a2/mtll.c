#include "mtll.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/*
 * 'separator_elem' and 'separator_type' act as a delimiter element that marks
 * the end of one linked list and the start of another within a unified linked
 * list structure. They facilitie operations like list operation, retrieving and
 * management. Using as a boundary marker, they help in navigating and
 * manipulating multi-type lists efficiently.
 *
 * 'order_type' is a static variable that stands for a valid list number type
 * to store inside the linked list.
 *
 * 'nested_type' is a static variable that stands for a nested list value. And
 * the elem of this list will be the reference list number, utill the nested num
 * is deleted, the elem will change to NULL.
 *
 * Comparing to create a linked list of linked lists, I am trying to create a
 * linked list that store a range of linked lists by such above format: starts
 * with a list order and ends with a separator. So for the following commands, I
 * will find out each required list by checking such format.
 * Example linked list: (0, ListNum) -> (a, CHAR) -> ($@separator, SEPARATOR) ->
 * (1, ListNum) -> (0, REFERENCE) -> (0, NestedNum) -> ($@separator, SEPARATOR)
 */
static const char separator_elem[12] = "$@separator";
static const char separator_type[12] = "SEPARATOR";
static const char order_type[12] = "ListNum";
static const char nested_type[12] = "NestedNum";
int error_status = 0;

struct mtll *mtll_create() {
  struct mtll *Node = malloc(sizeof(struct mtll));
  if (Node == NULL) {
    return NULL;
  }
  Node->elem = NULL;
  strcpy(Node->type, "EMPTY");
  Node->next = NULL;
  return Node;
}

void mtll_free(struct mtll **head) {
    struct mtll *current = *head;
    while (current != NULL) {
        struct mtll *temp = current;
        current = current->next;
        if (temp->elem) {
            free(temp->elem);
        }
        free(temp);
    }
    *head = NULL;
}

// the function to build a separator Node
void separator_build(struct mtll **head) {
    struct mtll *separatorNode = malloc(sizeof(struct mtll));
    if (!separatorNode) {
        return;
    }
    separatorNode->elem = malloc(strlen(separator_elem) + 1);
    if (!separatorNode->elem) {
        free(separatorNode); 
        return;
    }
    strcpy(separatorNode->type, separator_type);
    strcpy(separatorNode->elem, separator_elem);
    separatorNode->next = NULL;
    if (*head == NULL) {
        *head = separatorNode;
    } else {
        struct mtll *current = *head;
        while (current->next != NULL) {
            current = current->next;
        }
        current->next = separatorNode;
    }
}

// the function to build a nested type Node
void nested_list(struct mtll **head, char *elem) {
  if (!head) {
    return;
  }
  struct mtll *nested_node = malloc(sizeof(struct mtll));
  if (!nested_node) {
    return;
  }
  int *orderPtr = malloc(sizeof(int));
  if (!orderPtr) {
    free(nested_node);
    return;
  }
  *orderPtr = atoi(elem);
  nested_node->elem = orderPtr;
  strcpy(nested_node->type, nested_type);
  nested_node->next = NULL;
  if (!*head) {
    *head = nested_node;
  } else {
    struct mtll *current = *head;
    while (current->next) {
      current = current->next;
    }
    current->next = nested_node;
  }
}

// the function to build a starting ListNum Node
void valid_list_order(struct mtll **head, int order) {
  if (!head) {
    return;
  }
  struct mtll *node = malloc(sizeof(struct mtll));
  if (!node) {
    return;
  }
  int *orderPtr = malloc(sizeof(int));
  if (!orderPtr) {
    free(node);
    return;
  }
  *orderPtr = order;
  node->elem = orderPtr;
  strcpy(node->type, order_type);
  node->next = NULL;
  if (!*head) {
    *head = node;
  } else {
    struct mtll *current = *head;
    while (current->next) {
      current = current->next;
    }
    current->next = node;
  }
}

// elements printing
void print_out(struct mtll **head, int order) {
  struct mtll *Node = *head;
  int begin = 1;
  // Node = Node->next;
  while (Node != NULL) {
    if (strcmp(Node->type, "ListNum") == 0 && *(int *)Node->elem == order) {
      Node = Node->next;
      break;
    }
    Node = Node->next;
  }
  while (Node != NULL && strcmp(Node->type, "SEPARATOR") != 0) {
    if (begin != 1 && strcmp(Node->type, "NestedNum") != 0) {
      printf(" -> ");
    } else {
      begin = 0;
    }
    if (strcmp(Node->type, "INT") == 0) {
      printf("%d", *(int *)Node->elem);
    } else if (strcmp(Node->type, "FLOAT") == 0) {
      printf("%.2f", *(float *)Node->elem);
    } else if (strcmp(Node->type, "CHAR") == 0) {
      printf("%c", *(char *)Node->elem);
    } else if (strcmp(Node->type, "STRING") == 0) {
      printf("%s", (char *)Node->elem);
    } else if (strcmp(Node->type, "REFERENCE") == 0) {
      printf("%s", (char *)Node->elem);
    }
    Node = Node->next;
  }
  // if (strcmp(Node->type, "SEPARATOR") != 0 && Node->next != NULL ) {
  //   printf(" -> ");
  // }
  printf("\n");
}

// the function is used to check whether each linked list is complete or not, if
// not then delete all the values stored in it.
void is_list_valid(struct mtll **head) {
  if (head == NULL) {
    return;
  }
  struct mtll *curr = *head, *prev = NULL;
  struct mtll *last_ListNum = NULL, *last_ListNum_prev = NULL;
  while (curr != NULL) {
    if (strcmp(curr->type, "ListNum") == 0) {
      last_ListNum = curr;
      last_ListNum_prev = prev;
    }
    prev = curr;
    curr = curr->next;
  }

  if (last_ListNum != NULL) {
    int valid = 0;
    curr = last_ListNum->next;
    while (curr != NULL) {
      if (strcmp(curr->type, "SEPARATOR") == 0) {
        valid = 1;
        break;
      } else if (strcmp(curr->type, "ListNum") == 0) {
        valid = 0;
        break;
      }
      curr = curr->next;
    }
    if (!valid) {
      curr = (last_ListNum_prev != NULL) ? last_ListNum_prev->next : *head;
      while (curr != NULL) {
        struct mtll *to_remove = curr;
        curr = curr->next;
        if (to_remove->elem) {
          free(to_remove->elem);
        }
        free(to_remove);
      }
      if (last_ListNum_prev != NULL) {
        last_ListNum_prev->next = NULL;
      } else {
        *head = NULL;
      }
    }
  }
}

// the NEW command to adding the valid Nodes
void list_add(struct mtll **head, char *elem, int data_type) {
  int exist = 0;
  // nested = 0
  char reference_list[100];
  if (head == NULL) {
    return;
  }
  struct mtll *Node = malloc(sizeof(struct mtll));
  if (Node == NULL) {
    return;
  }
  struct mtll *current = *head;
  while (current != NULL && data_type == 0) {
    if (strcmp(current->type, "ListNum") == 0 &&
        *(int *)current->elem == atoi(elem)) {
      struct mtll *temp = current;
      while (temp != NULL) {
        if (strcmp(temp->type, "SEPARATOR") == 0) {
          exist = 1;
          break;
        }
        temp = temp->next;
      }
      break;
    }
    current = current->next;
  }
  // while (current != NULL && data_type == 0) {
  //   if (strcmp(current->type, "NestedNum") == 0 && current->next != NULL) {
  //     nested = 1;
  //     break;
  //   }
  //   current = current->next;
  // }
  if ((exist == 0 && data_type == 0)) { //|| nested == 1
    printf("INVALID COMMAND: NEW\n");
    error_status = 1;
    return;
  }
  Node->next = NULL;
  Node->elem = NULL;
  switch (data_type) {
  case 0:
    snprintf(reference_list, sizeof(reference_list), "{List %d}", atoi(elem));
    Node->elem = strdup(reference_list);
    strcpy(Node->type, "REFERENCE");
    break;
  case 1:
    Node->elem = malloc(sizeof(int));
    if (Node->elem) {
      *(int *)Node->elem = atoi(elem);
    }
    strcpy(Node->type, "INT");
    break;
  case 2:
    Node->elem = malloc(sizeof(float));
    if (Node->elem) {
      *(float *)Node->elem = atof(elem);
    }
    strcpy(Node->type, "FLOAT");
    break;
  default:
    Node->elem = strdup(elem);
    if (data_type == 3) {
      strcpy(Node->type, "CHAR");
    } else {
      strcpy(Node->type, "STRING");
    }
    break;
  }
  if (*head == NULL) {
    *head = Node;
  } else {
    struct mtll *current = *head;
    while (current->next != NULL) {
      current = current->next;
    }
    current->next = Node;
  }
}

void mtll_view(struct mtll **head, int order) {
  struct mtll *Node = *head;
  int current = -1;
  int find = 0;
  while (Node != NULL) {
    if (strcmp(Node->type, "ListNum") == 0 && *(int *)Node->elem == order) {
      find++;
      break;
    }
    Node = Node->next;
  }
  if (find == 0) {
    printf("INVALID COMMAND: VIEW");
    return;
  }
  while (Node != NULL) {
    if (strcmp(Node->type, "ListNum") == 0) {
      current = *(int *)Node->elem;
    } else if (strcmp(Node->type, "SEPARATOR") == 0 &&
               strcmp(Node->elem, "$@separator") == 0) {
      if (current == order) {
        break;
      }
    } else if (current == order) {
      if (strcmp(Node->type, "INT") == 0) {
        printf("%d", *(int *)(Node->elem));
      } else if (strcmp(Node->type, "FLOAT") == 0) {
        printf("%.2f", *(float *)(Node->elem));
      } else if (strcmp(Node->type, "CHAR") == 0) {
        printf("%c", *(char *)(Node->elem));
      } else if (strcmp(Node->type, "STRING") == 0) {
        printf("%s", (char *)(Node->elem));
      } else if (strcmp(Node->type, "REFERENCE") == 0) {
        printf("%s", (char *)(Node->elem));
      }
      if (Node->next != NULL && strcmp(Node->next->type, "SEPARATOR") != 0 &&
          strcmp(Node->next->type, "NestedNum") != 0) {
        printf(" -> ");
      }
    }
    Node = Node->next;
  }
}

void mtll_view_all(struct mtll **head) {
  int separatorCount = 0;
  int validList[1000] = {0};
  int nestedList[1000] = {0};
  int i = 0, j = 0;
  struct mtll *Node = *head;
  while (Node != NULL) {
    if (strcmp(Node->type, "SEPARATOR") == 0 &&
        strcmp(Node->elem, "$@separator") == 0) {
      i++;
      separatorCount++;
    }
    if (strcmp(Node->type, "ListNum") == 0) {
      validList[i] = *(int *)Node->elem;
    }
    if (strcmp(Node->type, "NestedNum") == 0) {
      nestedList[j] = validList[i];
      j++;
    }
    Node = Node->next;
  }
  printf("Number of lists: %d\n", separatorCount);
  if (j > 0) {
    for (int a = 0; a < i; a++){
      int is_nest = 0;
      for (int c = 0; c < j; c++){
        if (validList[a] == nestedList[c]){
          is_nest = 1;
        }
      }
      if (is_nest == 1){
        printf("Nested %d\n", validList[a]);
      }else{
        printf("List %d\n", validList[a]);
      }
    }
    // for (int k = 0; k < j; k++) {
    //   for (int a = 0; a < i; a++) {
    //     if (nestedList[k] == validList[a]) {
    //       printf("Nested %d\n", nestedList[k]);
    //     } else {
    //       printf("List %d\n", validList[a]);
    //     }
    //   }
    // }
  } else {
    for (int b = 0; b < i; b++) {
      printf("List %d\n", validList[b]);
    }
  }
}

void mtll_remove(struct mtll **head, int order) {
  if (head == NULL) {
    printf("INVALID COMMAND: REMOVE\n");
    return;
  }
  int found = 0, nested_to = 0;
  struct mtll *curr = *head, *prev = NULL;
  while (curr != NULL) {
    if (strcmp(curr->type, "ListNum") == 0 && *(int *)curr->elem == order) {
      found = 1;
    }
    if (strcmp(curr->type, "NestedNum") == 0 && *(int *)curr->elem == order) {
      nested_to = 1;
    }
    prev = curr;
    curr = curr->next;
  }
  if (found == 0 || nested_to == 1) {
    printf("INVALID COMMAND: REMOVE\n");
    return;
  }
  curr = *head, prev = NULL;
  while (curr != NULL) {
    if (strcmp(curr->type, "ListNum") == 0 && *(int *)curr->elem == order) {
      while (curr != NULL && strcmp(curr->type, "SEPARATOR") != 0) {
        // go through the exactly list to free all Nodes
        struct mtll *to_remove = curr;
        curr = curr->next;
        if (to_remove->elem) {
          free(to_remove->elem);
        }
        free(to_remove);
      }
      if (curr != NULL && strcmp(curr->type, "SEPARATOR") == 0) {
        struct mtll *to_remove = curr;
        curr = curr->next;
        free(to_remove);
      }
      if (prev != NULL) {
        prev->next = curr;
      } else {
        *head = curr;
      }
      break;
    }
    prev = curr;
    curr = curr->next;
  }
  printf("List %d has been removed.\n", order);
  printf("\n");
  mtll_view_all(head);
}

void mtll_type(struct mtll **head, int order) {
  struct mtll *Node = *head;
  int current = -1;
  int find = 0;
  while (Node != NULL) {
    if (strcmp(Node->type, "ListNum") == 0) {
      find++;
      break;
    }
    Node = Node->next;
  }
  if (find == 0) {
    printf("INVALID COMMAND: TYPE\n");
    return;
  }
  while (Node != NULL) {
    if (strcmp(Node->type, "ListNum") == 0) {
      current = *(int *)Node->elem;
    } else if (strcmp(Node->type, "SEPARATOR") == 0 &&
               strcmp(Node->elem, "$@separator") == 0) {
      if (current == order) {
        break;
      }
    } else if (current == order) {
      if (strcmp(Node->type, "INT") == 0) {
        printf("int");
      } else if (strcmp(Node->type, "FLOAT") == 0) {
        printf("float");
      } else if (strcmp(Node->type, "CHAR") == 0) {
        printf("char");
      } else if (strcmp(Node->type, "STRING") == 0) {
        printf("string");
      } else if (strcmp(Node->type, "REFERENCE") == 0) {
        printf("reference");
      }
      if (Node->next != NULL && strcmp(Node->next->type, "SEPARATOR") != 0 &&
          strcmp(Node->next->type, "NestedNum") != 0) {
        printf(" -> ");
      }
    }
    Node = Node->next;
  }
  printf("\n");
}

void mtll_insert(struct mtll **head, int id, int index, char *value,
                 int data_type) {
  if (head == NULL) {
    printf("INVALID COMMAND: INSERT\n");
    return;
  }
  int len = 0, found = 0, exist = 0, nested = 0;
  char reference_list[100];
  struct mtll *Node = *head, *prev = NULL;
  while (Node != NULL) {
    if (strcmp(Node->type, "ListNum") == 0 && *(int *)Node->elem == id) {
      found = 1;
      Node = Node->next;
      while (Node != NULL && strcmp(Node->type, "SEPARATOR") != 0 &&
             strcmp(Node->type, "NestedNum") != 0) {
        len++;
        Node = Node->next;
      }
      break;
    }
    Node = Node->next;
  }
  struct mtll *current = *head;
  while (current != NULL && data_type == 0) {
    if (strcmp(current->type, "ListNum") == 0 &&
        *(int *)current->elem == atoi(value)) {
      exist = 1;
      break;
    }
    current = current->next;
  }
  current = *head;
  int where = 0;
  int now = -1;
  // determine whether the linked list already became a nested list or inserted value is a nested list. If it is,
  // then return.
  while (current != NULL && data_type == 0) {
    if (strcmp(current->type, "ListNum") == 0){
        where = 1;
        now = *(int *)current->elem;
    }
    if ((strcmp(current->type, "NestedNum") == 0 && where == 1 && now == atoi(value)) || (strcmp(current->type, "NestedNum") == 0 && where == 1 && *(int *)current->elem == id)) {
      nested = 1;
      break;
    }
    if (strcmp(current->type, "SEPARATOR") == 0){
      where = 0;
      now = -1;
    }
    current = current->next;
  }
  if ((exist == 0 && data_type == 0) || nested == 1) {
    printf("INVALID COMMAND: INSERT\n");
    return;
  }
  if (found == 0) {
    printf("INVALID COMMAND: INSERT\n");
    return;
  }
  int target = 0;
  if (index < 0) {
    target = (len + 1) + index; // where consider the new list size
  } else {
    target = index;
  }
  if (target < 0 || target > len) {
    printf("INVALID COMMAND: INSERT\n");
    return;
  }
  struct mtll *new = malloc(sizeof(struct mtll));
  switch (data_type) {
  case 0:
    snprintf(reference_list, sizeof(reference_list), "{List %d}", atoi(value));
    new->elem = strdup(reference_list);
    strcpy(new->type, "REFERENCE");
    break;
  case 1:
    new->elem = malloc(sizeof(int));
    if (new->elem)
      *(int *)new->elem = atoi(value);
    strcpy(new->type, "INT");
    break;
  case 2:
    new->elem = malloc(sizeof(float));
    if (new->elem)
      *(float *)new->elem = atof(value);
    strcpy(new->type, "FLOAT");
    break;
  default:
    new->elem = strdup(value);
    if (data_type == 3)
      strcpy(new->type, "CHAR");
    else
      strcpy(new->type, "STRING");
    break;
  }
  //restart at the beginning
  Node = *head;
  int the_list = 0;
  int curr_index = 0;
  struct mtll* nestedNode = NULL;
  if (data_type == 0) {
    //for a nested list, needs to add a nested type after the REFERENCE type Node value
    nested_list(&nestedNode, value);
  }
  while (Node != NULL) {
    if (strcmp(Node->type, "ListNum") == 0 && *(int *)Node->elem == id) {
      the_list = 1;
    } else if (the_list && curr_index == target) {
      if (prev) {
        prev->next = new;
      } else {
        *head = new;
      }
      if (nestedNode) {
        new->next = nestedNode;
        nestedNode->next = Node;
      } else {
        new->next = Node;
      }
      break;
    } else if (the_list && strcmp(Node->type, "ListNum") != 0 &&
               strcmp(Node->type, "NestedNum") != 0) {
      curr_index++;
    }
    prev = Node;
    Node = Node->next;
  }
  if (exist == 1) {
    printf("Nested %d: ", id);
  } else {
    printf("List %d: ", id);
  }
  Node = *head;
  found = 0;
  while (Node != NULL) {
    if (strcmp(Node->type, "ListNum") == 0 && *(int *)Node->elem == id) {
      found = 1;
    }
    if (found == 1 && strcmp(Node->type, "ListNum") != 0) {
      if (strcmp(Node->type, "SEPARATOR") == 0 &&
          strcmp(Node->elem, "$@separator") == 0) {
        break;
      }
      if (strcmp(Node->type, "INT") == 0) {
        printf("%d", *(int *)(Node->elem));
      } else if (strcmp(Node->type, "FLOAT") == 0) {
        printf("%.2f", *(float *)(Node->elem));
      } else if (strcmp(Node->type, "CHAR") == 0) {
        printf("%c", *(char *)(Node->elem));
      } else if (strcmp(Node->type, "STRING") == 0) {
        printf("%s", (char *)(Node->elem));
      } else if (strcmp(Node->type, "REFERENCE") == 0) {
        printf("%s", (char *)(Node->elem));
      }
      if (Node->next != NULL && strcmp(Node->next->type, "SEPARATOR") != 0 &&
          strcmp(Node->next->type, "NestedNum") != 0) {
        printf(" -> ");
      }
    }
    Node = Node->next;
  }
  printf("\n");
}

void mtll_delete(struct mtll **head, int id, int index) {
  if (head == NULL) {
    printf("INVALID COMMAND: DELETE\n");
    return;
  }
  struct mtll *Node = *head, *prev = NULL;
  int len = 0, found = 0;
  while (Node != NULL) {
    if (strcmp(Node->type, "ListNum") == 0 && *(int *)Node->elem == id) {
      found = 1;
      Node = Node->next;
      while (Node != NULL && strcmp(Node->type, "SEPARATOR") != 0) {
        if (strcmp(Node->type, "NestedNum") != 0) {
          len++;
        }
        Node = Node->next;
      }
      break;
    }
    Node = Node->next;
  }
  if (found == 0 || len == 0) {
    printf("INVALID COMMAND: DELETE\n");
    return;
  }
  int target = 0;
  if (index < 0) {
    target = len + index;
  } else {
    target = index;
  }
  if (target < 0 || target > len) {
    printf("INVALID COMMAND: DELETE\n");
    return;
  }
  Node = *head; // restart from the beginning
  int the_list = 0;
  int curr_index = 0;
  while (Node != NULL) {
    struct mtll *temp = NULL;
    if (strcmp(Node->type, "ListNum") == 0 && *(int *)Node->elem == id) {
      the_list = 1;
    } else if (the_list && strcmp(Node->type, "SEPARATOR") == 0) {
      break;
    } else if (the_list && curr_index == target &&
               strcmp(Node->type, "NestedNum") != 0) {
      temp = Node;
      if (Node->next != NULL && strcmp(Node->next->type, "NestedNum") == 0 &&
          strcmp(Node->type, "REFERENCE") == 0) {
        struct mtll *nested = Node->next;
        temp->next = nested->next;
        free(nested->elem);
        free(nested);
      }
      if (prev != NULL) {
        prev->next = temp->next;
      } else {
        *head = temp->next;
      }
      // go through the exact element index to delete it
      free(temp->elem);
      free(temp);
      break;
    } else if (the_list && strcmp(Node->type, "ListNum") != 0) {
      curr_index++;
    }
    if (temp == NULL) {
      prev = Node;
      Node = Node->next;
    } else {
      Node = temp->next;
    }
  }
  Node = *head;
  int exist = 0;
  the_list = 0;
  while (Node != NULL) {
    if (strcmp(Node->type, "ListNum") == 0 && *(int *)Node->elem == id) {
      the_list = 1;
    }
    if (strcmp(Node->type, "NestedNum") == 0 && the_list == 1) {
      exist = 1;
      break;
    }
    if (strcmp(Node->type, "SEPARATOR") == 0) {
      the_list = 0;
    }
    Node = Node->next;
  }
  if (exist == 0) {
    printf("List %d: ", id);
  } else {
    printf("Nested %d: ", id);
  }
  Node = *head;
  found = 0;
  while (Node != NULL) {
    if (strcmp(Node->type, "ListNum") == 0 && *(int *)Node->elem == id) {
      found = 1;
    }
    if (found == 1 && strcmp(Node->type, "ListNum") != 0) {
      if (strcmp(Node->type, "SEPARATOR") == 0 &&
          strcmp(Node->elem, "$@separator") == 0) {
        break;
      }
      if (strcmp(Node->type, "INT") == 0) {
        printf("%d", *(int *)(Node->elem));
      } else if (strcmp(Node->type, "FLOAT") == 0) {
        printf("%.2f", *(float *)(Node->elem));
      } else if (strcmp(Node->type, "CHAR") == 0) {
        printf("%c", *(char *)(Node->elem));
      } else if (strcmp(Node->type, "STRING") == 0) {
        printf("%s", (char *)(Node->elem));
      } else if (strcmp(Node->type, "REFERENCE") == 0) {
        printf("%s", (char *)(Node->elem));
      }
      if (Node->next != NULL && strcmp(Node->next->type, "SEPARATOR") != 0 &&
          strcmp(Node->next->type, "NestedNum") != 0) {
        printf(" -> ");
      }
    }
    Node = Node->next;
  }
  printf("\n");
}

void mtll_view_nested(struct mtll **head, int order) {
  if (head == NULL) {
    return;
  }
  int exist = 0, find = 0;
  struct mtll *Node = *head;
  while (Node != NULL) {
    if (strcmp(Node->type, "ListNum") == 0 && *(int *)Node->elem == order) {
      find = 1;
    } else if (find && strcmp(Node->type, "NestedNum") == 0) {
      exist = 1;
      break;
    } else if (find && strcmp(Node->type, "SEPARATOR") == 0) {
      break; 
    }
    Node = Node->next;
  }
  if (find == 0) {
    printf("INVALID COMMAND: VIEW\n");
    return;
  }
  if (exist == 0) {
    // if not a nested list, then do the same work as VIEW command
    mtll_view(head, order);
    printf("\n");
    return;
  }
  int current = -1;
  Node = *head;
  while (Node != NULL) {
    if (strcmp(Node->type, "ListNum") == 0) {
      current = *(int *)Node->elem;
    } else if (strcmp(Node->type, "SEPARATOR") == 0 &&
               strcmp(Node->elem, "$@separator") == 0) {
      if (current == order) {
        break;
      }
    } else if (current == order) {
      if (strcmp(Node->type, "NestedNum") == 0 &&
          strcmp(Node->elem, "NULL") != 0) {
        printf("{");
        mtll_view(head, *(int *)(Node->elem));
        printf("}");
        if (strcmp(Node->next->type, "SEPARATOR") != 0){
          // ensure the arrow will print in a nested list that includes the consecutive REFERENCE elements
          printf(" -> ");
        }
      } else {
        if (strcmp(Node->type, "INT") == 0) {
          printf("%d", *(int *)(Node->elem));
        } else if (strcmp(Node->type, "FLOAT") == 0) {
          printf("%.2f", *(float *)(Node->elem));
        } else if (strcmp(Node->type, "CHAR") == 0) {
          printf("%c", *(char *)(Node->elem));
        } else if (strcmp(Node->type, "STRING") == 0) {
          printf("%s", (char *)(Node->elem));
        }
        if (Node->next != NULL && strcmp(Node->next->type, "SEPARATOR") != 0 &&
            strcmp(Node->next->type, "NestedNum") != 0 &&
            strcmp(Node->type, "REFERENCE") != 0) {
          printf(" -> ");
        }
      }
    }
    Node = Node->next;
  }
  printf("\n");
}