import pytest
import unittest
from bst import BSTree, Student

def assert_equal(got, expected, msg):
    """
    Simple assert helper
    """
    assert expected == got, "[{}] Expected: {}, got: {}".format(msg, expected, got)

class BSTreeTestCases(unittest.TestCase):
    """
    Test cases for the BSTree and Student classes.
    """

    def setUp(self):
        self.bst = BSTree()
        students = [
            (1, "Alice", 3.5),
            (2, "Bob", 3.7),
            (3, "Charlie", 3.9),
            (4, "Daisy", 3.2)
        ]
        for student_id, name, GPA in students:
            self.bst.insert(student_id, name, GPA)

    def test_insert_search(self):
        # Testing insertion and search functionality
        student = self.bst.search(1)
        assert_equal(student.name == "Alice" and student.GPA == 3.5, True, "Insert and search test failed for Alice.")

        student = self.bst.search(4)
        assert_equal(student.name == "Daisy" and student.GPA == 3.2, True, "Insert and search test failed for Daisy.")

        # Search for a non-existent student
        assert_equal(self.bst.search(5) is None, True, "Search for non-existent student failed.")
    
    """
    complete your own test cases from here
    """

    def test_delete_leaf_node(self):
        student_to_delete = 4
        student = self.bst.search(student_to_delete)
        assert_equal(student is not None, True, f"Student with ID {student_to_delete} should exist before deletion.")

        self.bst.delete(student_to_delete)
        assert_equal(self.bst.search(student_to_delete) is None, True, f"Student with ID {student_to_delete} should not exist after deletion.")

        remaining_students = [1, 2, 3]
        for student_id in remaining_students:
            student = self.bst.search(student_id)
            assert student is not None, f"Student with ID {student_id} should still exist."
            assert_equal(isinstance(student, Student), True, f"Search for student with ID {student_id} should return a Student object.")


