# 5/b feladat - TDD tesztek kuponkodhoz (KOD NELKUL!)

import unittest
from discounts import apply_coupon

class TestApplyCoupon(unittest.TestCase):
    
    # 1. teszt - helyes kuponkod 10% kedvezmenyt ad
    def test_valid_coupon_gives_10_percent_discount(self):
        # total = 20000, code = "SAVE10"
        # varunk: 20000 * 0.9 = 18000
        result = apply_coupon(20000, "SAVE10")
        self.assertEqual(18000, result)
    
    # 2. teszt - ismeretlen kuponkod nem valtoztatja az osszeget
    def test_unknown_coupon_does_not_change_total(self):
        # total = 15000, code = "INVALID"
        # varunk: 15000 (valtozatlan)
        result = apply_coupon(15000, "INVALID")
        self.assertEqual(15000, result)
    
    # 3. teszt - lejart kuponkod hibauzenet
    def test_expired_coupon_is_rejected(self):
        # total = 10000, code = "EXPIRED2024"
        # varunk: ValueError kivetel "Lejart kupon" uzenettel
        with self.assertRaises(ValueError) as context:
            apply_coupon(10000, "EXPIRED2024")
        self.assertEqual(str(context.exception), "Lejart kupon")
    
    # 4. teszt - minimalis osszeg alatt nincs kedvezmeny
    def test_coupon_not_applied_below_minimum(self):
        # total = 3000 (5000 alatt), code = "SAVE10"
        # varunk: 3000 (nincs kedvezmeny mert tul kicsi az osszeg)
        result = apply_coupon(3000, "SAVE10")
        self.assertEqual(3000, result)
    
    # 5. teszt - minimalis osszeg felett mukodik a kupon
    def test_coupon_applied_above_minimum(self):
        # total = 5000, code = "SAVE10"
        # varunk: 5000 * 0.9 = 4500
        result = apply_coupon(5000, "SAVE10")
        self.assertEqual(4500, result)
    
    # 6. teszt - ures kuponkod nem valtoztat
    def test_empty_coupon_code_does_nothing(self):
        # total = 10000, code = ""
        # varunk: 10000 (valtozatlan)
        result = apply_coupon(10000, "")
        self.assertEqual(10000, result)
    
    # 7. teszt - None kuponkod nem valtoztat
    def test_none_coupon_code_does_nothing(self):
        # total = 10000, code = None
        # varunk: 10000 (valtozatlan)
        result = apply_coupon(10000, None)
        self.assertEqual(10000, result)


if __name__ == "__main__":
    unittest.main()
