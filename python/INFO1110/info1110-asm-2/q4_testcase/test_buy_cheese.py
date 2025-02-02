'''

Author: Yilin Li
SID: 530536402
Unikey: yili2677
'''

import unittest
from shop import buy_cheese
from unittest.mock import patch

class TestBuyCheese (unittest.TestCase):

    def test_buy_cheese_1(self):
        with patch('builtins.input', side_effect=["Marble 2", "back"]) as mock_input:
            gold = 125
            result = buy_cheese(gold)
            expected = (100, (0, 2, 0))
            self.assertEqual(result, expected)
            print()
    
    def test_buy_cheese_2(self):
        with patch('builtins.input', side_effect=["Cheddar 10", "back"]) as mock_input:
            gold = 125
            result = buy_cheese(gold)
            expected = (100, (10, 0, 0))
            self.assertEqual(result, expected)
            print()
    
    def test_buy_cheese_3(self):
        with patch('builtins.input', side_effect=["Swiss", "back"]) as mock_input:
            gold = 125
            result = buy_cheese(gold)
            expected = (0, (0, 0, 0))
            self.assertEqual(result, expected)
            print()
    
    def test_buy_cheese_4(self):
        with patch('builtins.input', side_effect=["Marble 0", "back"]) as mock_input:
            gold = 125
            result = buy_cheese(gold)
            expected = (0, (0, 0, 0))
            self.assertEqual(result, expected)
            print()
    
    def test_buy_cheese_5(self):
        with patch('builtins.input', side_effect=["Cheddar 1", "back"]) as mock_input:
            gold = 125
            result = buy_cheese(gold)
            expected = (10, (1, 0, 0))
            self.assertEqual(result, expected)
            print()

    def test_buy_cheese_6(self):
        with patch('builtins.input', side_effect=["Cheddar 12", "back"]) as mock_input:
            gold = 125
            result = buy_cheese(gold)
            expected = (120, (12, 0, 0))
            self.assertEqual(result, expected)
    
if __name__ == '__main__':
    unittest.main()




