'''
Your task is to complete the following functions which are marked by the TODO comment.
You are free to add properties and functions to the class as long as the given signatures remain identical.
Note: Please do not modify any existing function signatures, as it will impact your test results
'''

class Student:
    """Represents a node of a binary tree."""
    """These are the defined properties as described above, feel free to add more if you wish!"""
    """However do not mmodify nor delete the current properties."""
    def __init__(self, student_id, name, GPA) -> None:
        self.left = None
        self.right = None
        self.parent = None
        self.student_id = student_id
        self.name = name
        self.GPA = GPA

class BSTree:
    """
    Implements an unbalanced Binary Search Tree.
    """ 
    def __init__(self, *args) -> None:
        self.Root = None
    
    """-------------------------------PLEASE DO NOT MODIFY THE ABOVE (except you could add more properties in Student class) -------------------------------"""
    def insert(self, student_id, name, GPA) -> None:
        """
        Inserts a new Student into the tree.
        """
        new_student = Student(student_id, name, GPA)
        if self.Root is None:
            self.Root = new_student
        else:
            self.insert_recur(new_student, self.Root)

    def insert_recur(self, new_student, curr) -> None:
        if new_student.student_id < curr.student_id:
            if curr.left is None:
                curr.left = new_student
                new_student.parent = curr
            else:
                self.insert_recur(new_student, curr.left)
        elif new_student.student_id > curr.student_id:
            if curr.right is None:
                curr.right = new_student
                new_student.parent = curr
            else:
                self.insert_recur(new_student, curr.right)

    def search(self, student_id) -> Student:
        """
        Searches for a student by student_id.
        """
        if self.Root == None:
            return None
        curr = self.Root
        while curr:
            if student_id < curr.student_id:
                curr = curr.left
            elif student_id > curr.student_id:
                curr = curr.right
            else:
                return curr
        return None

    def delete(self, student_id) -> None:
        """
        Deletes a student from the tree by student_id.
        """
        if self.Root is None:
            return
        self.Root = self.delete_recur(self.Root, student_id)

    def delete_recur(self, curr, student_id) -> Student:
        if curr is None:
            return None
        if student_id < curr.student_id:
            curr.left = self.delete_recur(curr.left, student_id)
        elif student_id > curr.student_id:
            curr.right = self.delete_recur(curr.right, student_id)
        else:
            # Node with no child
            if curr.left is None and curr.right is None:
                return None
            # Node with one right child
            elif curr.left is None:
                return curr.right
            # Node with one left child
            elif curr.right is None:
                return curr.left
            # Node with two children
            else:
                # Node with 2 children
                delete_node = self.node_with_two_children(curr.right)
                # copy the successor's data to the current node
                curr.student_id = delete_node.student_id
                curr.name = delete_node.name
                curr.GPA = delete_node.GPA
                # delete the successor
                curr.right = self.delete_recur(curr.right, delete_node.student_id)
        return curr

    def node_with_two_children(self, curr) -> Student:
        while curr and curr.left:
            curr = curr.left
        return curr

    def update_gpa(self, student_id, new_gpa) -> None:
        """
        Updates the GPA of a student.
        """
        if self.Root == None:
            return None
        curr = self.Root
        while curr:
            if student_id < curr.student_id:
                curr = curr.left
            elif student_id > curr.student_id:
                curr = curr.right
            else:
                curr.GPA = new_gpa
                break
        return None

    def update_name(self, student_id, new_name) -> None:
        """
        Updates the name of a student.
        """
        if self.Root == None:
            return None
        curr = self.Root
        while curr:
            if student_id < curr.student_id:
                curr = curr.left
            elif student_id > curr.student_id:
                curr = curr.right
            else:
                curr.name = new_name
                break
        return None

    def update_student_id(self, old_id, new_id) -> None:
        """
        Updates the student ID. This requires special handling to maintain tree structure.
        """
        if self.Root == None:
            return None
        find = self.search(old_id)
        if find:
            self.delete(old_id)
            self.insert(new_id, find.name, find.GPA)

    def generate_report(self, student_id) -> str:
        """
        Generates a full report for a student.
        In the format of: Student ID: {student_id}, Name: {student.name}, GPA: {student.GPA}
        Otherwsie, print: No student found with ID {student_id}
        """
        if self.Root == None:
            return f"No student found with ID {curr.student_id}"
        curr = self.Root
        while curr:
            if student_id < curr.student_id:
                curr = curr.left
            elif student_id > curr.student_id:
                curr = curr.right
            else:
                return f"Student ID: {curr.student_id}, Name: {curr.name}, GPA: {curr.GPA}"
        return f"No student found with ID {curr.student_id}"

    def find_max_gpa(self) -> float:
        """
        Finds the maximum GPA in the tree.
        """
        if self.Root == None:
            return None
        return self.max_gpa_recur(self.Root)
    
    def max_gpa_recur(self, curr) -> float:
        if curr is None:
            return float('-inf')
        left_gpa = self.max_gpa_recur(curr.left)
        right_gpa = self.max_gpa_recur(curr.right)
        # find the maximum gpa vlue via current node
        max_gpa = max(curr.GPA, left_gpa, right_gpa)
        return max_gpa
    
    def find_min_gpa(self) -> float:
        """
        Finds the minimum GPA in the tree.
        """
        if self.Root == None:
            return None
        return self.min_gpa_recur(self.Root)
    
    def min_gpa_recur(self, curr) -> float:
        if curr is None:
            return float('inf')
        left_gpa = self.min_gpa_recur(curr.left)
        right_gpa = self.min_gpa_recur(curr.right)
        # find the maximum gpa vlue via current node
        min_gpa = min(curr.GPA, left_gpa, right_gpa)
        return min_gpa

    def levelorder(self, level=None) -> list:
        if self.Root is None:
            return []
        level_order_queue = [(self.Root, 0)]
        result = []
        specific_nodes = [] # To collect nodes at the specific level if one is requested
        while level_order_queue:
            node, curr_lvl = level_order_queue.pop(0)
            if level is None:
                result.append(node)
            elif level == curr_lvl:
                specific_nodes.append(node)
            if node.left:
                level_order_queue.append((node.left, curr_lvl + 1))
            if node.right:
                level_order_queue.append((node.right, curr_lvl + 1))
        if level is None:
            return result
        else:
            return specific_nodes


    def inorder(self) -> list:
        """
        Performs an in-order traversal of the tree.
        """
        in_order_trav = []
        self.inoder_recur(self.Root, in_order_trav)
        return in_order_trav

    def inoder_recur(self, node, result) -> None:
        if node is None:
            return
        self.inoder_recur(node.left, result)
        result.append(node)
        self.inoder_recur(node.right, result)

    def is_valid(self) -> bool:
        """
        Checks if the tree is a valid Binary Search Tree. Return True if it is a valid BST, False or raise Exception otherwise.
        """
        if self.Root is None:
            return True
        return self.valid_recur(self.Root, float('-inf'), float('inf'))
    
    def valid_recur(self, curr, min_value, max_value) -> bool:
        if curr is None:
            return True
        # check if a valid node with valid student id
        if not (min_value < curr.student_id < max_value):
            return False
        if not self.valid_recur(curr.left, min_value, curr.student_id):
            return False
        if not self.valid_recur(curr.right, curr.student_id, max_value):
            return False
        return True

