# 3. feladat - Python unittest bovitett tesztosztaly kedvezmennyel

import unittest
from cart_v2 import calculate_cart_total

class TestCalculateCartTotal(unittest.TestCase):
    
    # REGRESSZIOS TESZTEK (korabbi funkciok)
    
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
        items = [{"name": f"Termek{i}", "unit_price": 10, "quantity": 1} for i in range(100)]
        result = calculate_cart_total(items)
        self.assertEqual(1000, result)
    
    # UJ TESZTEK - KEDVEZMENY FUNKCIO
    
    # 7. teszt - nincs kedvezmeny 10000 alatt
    def test_discount_not_applied_below_threshold(self):
        items = [
            {"name": "Termek1", "unit_price": 9500, "quantity": 1}
        ]
        result = calculate_cart_total(items)
        self.assertEqual(9500, result)
    
    # 8. teszt - kedvezmeny pontosan 10000-nel
    def test_discount_at_exact_threshold(self):
        items = [
            {"name": "Termek1", "unit_price": 10000, "quantity": 1}
        ]
        result = calculate_cart_total(items)
        # 10000 * 0.95 = 9500
        self.assertEqual(9500, result)
    
    # 9. teszt - kedvezmeny 10000 felett
    def test_discount_applied_above_threshold(self):
        items = [
            {"name": "Termek1", "unit_price": 20000, "quantity": 1}
        ]
        result = calculate_cart_total(items)
        # 20000 * 0.95 = 19000
        self.assertEqual(19000, result)
    
    # 10. teszt - kedvezmeny kicsit 10000 felett
    def test_discount_just_above_threshold(self):
        items = [
            {"name": "Termek1", "unit_price": 10100, "quantity": 1}
        ]
        result = calculate_cart_total(items)
        # 10100 * 0.95 = 9595
        self.assertEqual(9595, result)


if __name__ == "__main__":
    unittest.main()
