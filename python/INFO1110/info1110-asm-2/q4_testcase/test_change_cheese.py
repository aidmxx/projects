'''

Author: Yilin Li
SID: 530536402
Unikey: yili2677
'''

import unittest
from game import change_cheese
from unittest.mock import patch

class TestBuyCheese (unittest.TestCase):

    def test_change_cheese_1(self):
        with patch('builtins.input', side_effect=["cheddar", "yes", "back"]) as mock_input:
            name = 'Bob'
            trap = "Cardboard and Hook Trap"
            cheese = ['Cheddar', 1], ['Marble', 0], ['Swiss', 0]
            result = change_cheese(name, trap, cheese)
            expected = (True, "Cheddar")
            self.assertEqual(result, expected)
            print()
 
    def test_change_cheese_2(self):
        with patch('builtins.input', side_effect=["marble", "yes", "back"]) as mock_input:
            name = 'Bob'
            trap = "Cardboard and Hook Trap"
            cheese = ['Cheddar', 0], ['Marble', 1], ['Swiss', 0]
            result = change_cheese(name, trap, cheese)
            expected = (True, "Marble")
            self.assertEqual(result, expected)
            print()
    
    def test_change_cheese_3(self):
        with patch('builtins.input', side_effect=["brie", "back"]) as mock_input:
            name = 'Bob'
            trap = "Cardboard and Hook Trap"
            cheese = ['Cheddar', 1], ['Marble', 0], ['Swiss', 0]
            result = change_cheese(name, trap, cheese)
            expected = (False, None)
            self.assertEqual(result, expected)
            print()
    
    def test_change_cheese_4(self):
        with patch('builtins.input', side_effect=["marble", "back"]) as mock_input:
            name = 'Bob'
            trap = "Cardboard and Hook Trap"
            cheese = ['Cheddar', 0], ['Marble', 0], ['Swiss', 0]
            result = change_cheese(name, trap, cheese)
            expected = (False, None)
            self.assertEqual(result, expected)
            print()
    
    def test_change_cheese_5(self):
        with patch('builtins.input', side_effect=["back"]) as mock_input:
            name = 'Bob'
            trap = "Cardboard and Hook Trap"
            cheese = ['Cheddar', 1], ['Marble', 2], ['Swiss', 0]
            result = change_cheese(name, trap, cheese)
            expected = (False, None)
            self.assertEqual(result, expected)
            print()

    def test_change_cheese_6(self):
        with patch('builtins.input', side_effect=["CHEDDAR", "stop", "back"]) as mock_input:
            name = 'Bob'
            trap = "Cardboard and Hook Trap"
            cheese = ['Cheddar', 1], ['Marble', 1], ['Swiss', 0]
            result = change_cheese(name, trap, cheese)
            expected = (False, None)
            self.assertEqual(result, expected)
    
if __name__ == '__main__':
    unittest.main()


