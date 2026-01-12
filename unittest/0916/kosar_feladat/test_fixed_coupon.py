# onallo feladat 1. - fix osszegu kupon tesztjei

import pytest
from datetime import date
from pricing_extended import (
    LineItem, Coupon, CouponType, price_order
)

def test_fixed_amount_coupon():
    items = [LineItem(2000, 1, 0)]
    coupon = Coupon("FIX500", 500, CouponType.FIXED, date(2025, 12, 31))
    
    rep = price_order(
        items,
        vat_rate=27,
        coupon=coupon,
        today=date(2025, 9, 16)
    )
    
    assert rep["coupon_applied"] == 500
    assert rep["gross_total"] == 1500

def test_fixed_coupon_larger_than_total():
    items = [LineItem(300, 1, 0)]
    coupon = Coupon("BIG1000", 1000, CouponType.FIXED, date(2025, 12, 31))
    
    rep = price_order(
        items,
        vat_rate=27,
        coupon=coupon,
        today=date(2025, 9, 16)
    )
    
    assert rep["coupon_applied"] == 300
    assert rep["gross_total"] == 0

def test_percent_and_fixed_comparison():
    items = [LineItem(2000, 1, 0)]
    
    percent_coupon = Coupon("PCT20", 20, CouponType.PERCENT, date(2025, 12, 31))
    rep_pct = price_order(items, vat_rate=27, coupon=percent_coupon, today=date(2025, 9, 16))
    
    fixed_coupon = Coupon("FIX400", 400, CouponType.FIXED, date(2025, 12, 31))
    rep_fix = price_order(items, vat_rate=27, coupon=fixed_coupon, today=date(2025, 9, 16))
    
    assert rep_pct["coupon_applied"] == rep_fix["coupon_applied"] == 400

def test_fixed_coupon_with_cart_discount():
    items = [LineItem(3000, 1, 0)]
    coupon = Coupon("FIX500", 500, CouponType.FIXED, date(2025, 12, 31))
    
    rep = price_order(
        items,
        vat_rate=27,
        cart_discount_pct=10,
        coupon=coupon,
        today=date(2025, 9, 16)
    )
    
    assert rep["cart_discount_applied"] == 300
    assert rep["coupon_applied"] == 500
    assert rep["gross_total"] == 2200
