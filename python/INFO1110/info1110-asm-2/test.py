'''
Write solutions to 4. New Mouse Release here.

Author: Yilin Li
SID: 530536402
Unikey: yili2677
'''

import unittest
from mouse import generate_mouse


class TestMouse (unittest.TestCase):
    def test_mouse(self):
        mouse_name = generate_mouse()
        state = False
        try:
            # check whether actual and expected value are equal
            self.assertEqual(mouse_name, None)
            state = True
        except AssertionError:
            pass
        try:
            self.assertEqual(mouse_name, "Brown")
            state = True
        except AssertionError:
            pass
        try:
            self.assertEqual(mouse_name, "Field")
            state = True
        except AssertionError:
            pass
        try:
            self.assertEqual(mouse_name, "Grey")
            state = True
        except AssertionError:
            pass
        try:
            self.assertEqual(mouse_name, "White")
            state = True
        except AssertionError:
            pass
        try:
            self.assertEqual(mouse_name, "Tiny")
            state = True
        except AssertionError:
            pass
        return state


if __name__ == '__main__':
    unittest.main()

