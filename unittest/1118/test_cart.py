# 2/c feladat - Python unittest tesztosztaly

import unittest
from cart import calculate_cart_total

class TestCalculateCartTotal(unittest.TestCase):
    
    # 1. teszt - ures kosar
    def test_empty_cart_returns_zero(self):
        items = []
        result = calculate_cart_total(items)
        self.assertEqual(0, result)
    
    # 2. teszt - egy termek egy darabbal
    def test_single_item_single_quantity(self):
        items = [
            {"name": "Termek1", "unit_price": 1000, "quantity": 1}
        ]
        result = calculate_cart_total(items)
        self.assertEqual(1000, result)
    
    # 3. teszt - tobb termek kulonbozo mennyisegekkel
    def test_multiple_items(self):
        items = [
            {"name": "Termek1", "unit_price": 100, "quantity": 1},
            {"name": "Termek2", "unit_price": 200, "quantity": 2},
            {"name": "Termek3", "unit_price": 300, "quantity": 3}
        ]
        result = calculate_cart_total(items)
        # 100*1 + 200*2 + 300*3 = 100 + 400 + 900 = 1400
        self.assertEqual(1400, result)
    
    # 4. teszt - negativ mennyiseg hibakezeles
    def test_negative_quantity_raises_error(self):
        items = [
            {"name": "Termek1", "unit_price": 100, "quantity": -5}
        ]
        with self.assertRaises(ValueError):
            calculate_cart_total(items)
    
    # 5. teszt - lebegőpontos arak kerekitese
    def test_float_prices_rounded_correctly(self):
        items = [
            {"name": "Termek1", "unit_price": 99.99, "quantity": 3},
            {"name": "Termek2", "unit_price": 150.50, "quantity": 2}
        ]
        result = calculate_cart_total(items)
        # 99.99*3 + 150.50*2 = 299.97 + 301.00 = 600.97
        self.assertEqual(600.97, result)
    
    # 6. teszt - nagy kosar sok elemmel
    def test_large_cart_many_items(self):
        # 100 termek mindegyik 1 db, ara 10 Ft
        items = [{"name": f"Termek{i}", "unit_price": 10, "quantity": 1} for i in range(100)]
        result = calculate_cart_total(items)
        self.assertEqual(1000, result)


if __name__ == "__main__":
    unittest.main()
