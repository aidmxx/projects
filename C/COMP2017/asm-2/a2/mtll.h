#ifndef MTLL_H
#define MTLL_H

struct mtll {
  void *elem;
  char type[12];
  struct mtll *next;
};

// A few suggested function prototypes:
// Feel free to change or improve these as you need.
extern int error_status;

extern struct mtll *mtll_create();

extern void mtll_free(struct mtll **head);

extern void mtll_view(struct mtll **head, int order);

extern void mtll_view_all(struct mtll **head);

extern void mtll_remove(struct mtll **head, int order);

extern void mtll_type(struct mtll **head, int order);

extern void list_add(struct mtll **head, char *elem, int data_type);

extern void print_out(struct mtll **head, int order);

extern void separator_build(struct mtll **head);

extern void valid_list_order(struct mtll **head, int order);

extern void mtll_insert(struct mtll **head, int id, int index, char *value,
                        int data_type);

extern void mtll_delete(struct mtll **head, int id, int index);

extern void nested_list(struct mtll **head, char *elem);

extern void is_list_valid(struct mtll **head);

extern void mtll_view_nested(struct mtll **head, int order);

#endif