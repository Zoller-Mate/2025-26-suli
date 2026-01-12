# alapveto tesztek + masodik ora 4. feladat - uj tesztek irasa

import pytest
from datetime import date, timedelta
from pricing import LineItem, Coupon, price_order, InvalidCouponError, round_huf

def test_rounding():
    assert round_huf(12.4) == 12
    assert round_huf(12.5) == 13
    assert round_huf(-12.5) == -13

def test_lineitem():
    li = LineItem(1000, 2, 10)
    assert li.gross() == 1800

def test_lineitem_invalid():
    with pytest.raises(ValueError):
        LineItem(-1, 1).gross()

def test_cart_discount():
    items = [LineItem(1000, 2, 0)]
    rep = price_order(items, vat_rate=27, cart_discount_pct=10)
    assert rep["cart_discount_applied"] == 200

def test_coupon_valid_and_expired():
    today = date(2025, 9, 16)
    items = [LineItem(2000, 1)]
    valid = Coupon("OK10", 10, today)
    expired = Coupon("OLD50", 50, today - timedelta(days=1))

    rep = price_order(items, vat_rate=27, coupon=valid, today=today)
    assert rep["coupon_applied"] == 200

    with pytest.raises(InvalidCouponError):
        price_order(items, vat_rate=27, coupon=expired, today=today)

def test_free_shipping():
    items = [LineItem(1500, 1)]
    rep = price_order(items, vat_rate=27, free_shipping_threshold_huf=1500, shipping_fee_huf=990)
    assert rep["shipping_fee"] == 0

def test_negative_shipping_fee():
    items = [LineItem(1000, 1)]
    with pytest.raises(ValueError, match="Negatív szállítási díj"):
        price_order(items, vat_rate=27, shipping_fee_huf=-500)

def test_multiple_items():
    kenyer = LineItem(500, 2, 0)
    tej = LineItem(400, 1, 0)
    vaj = LineItem(800, 1, 10)
    
    items = [kenyer, tej, vaj]
    rep = price_order(items, vat_rate=27)
    
    assert rep["items_gross"] == 2120

def test_50_percent_cart_discount():
    items = [LineItem(2000, 1, 0)]
    rep = price_order(items, vat_rate=27, cart_discount_pct=50)
    
    assert rep["cart_discount_applied"] == 1000
    assert rep["gross_total"] == 1000

def test_coupon_and_cart_discount_together():
    items = [LineItem(2000, 1, 0)]
    coupon = Coupon("MEGA20", 20, date(2025, 12, 31))
    
    rep = price_order(
        items, 
        vat_rate=27, 
        cart_discount_pct=10,
        coupon=coupon,
        today=date(2025, 9, 16)
    )
    
    assert rep["cart_discount_applied"] == 200
    assert rep["coupon_applied"] == 360
    assert rep["gross_total"] == 1440
