# onallo feladat 2.

import pytest
from hypothesis import given, strategies as st, assume
from datetime import date, timedelta
from pricing import LineItem, Coupon, price_order

@given(
    unit_price=st.integers(min_value=100, max_value=100000),
    qty=st.integers(min_value=1, max_value=100),
    vat_rate=st.sampled_from([0, 5, 18, 27])
)
def test_vat_breakdown_property(unit_price, qty, vat_rate):
    items = [LineItem(unit_price, qty, 0)]
    rep = price_order(items, vat_rate=vat_rate)
    assert rep["net_total"] + rep["vat_component"] == rep["gross_total"]

@given(
    unit_price=st.integers(min_value=100, max_value=50000),
    cart_discount=st.floats(min_value=0, max_value=100),
)
def test_discounts_never_increase_price(unit_price, cart_discount):
    items = [LineItem(unit_price, 1, 0)]
    rep_no_discount = price_order(items, vat_rate=27, cart_discount_pct=0)
    rep_with_discount = price_order(items, vat_rate=27, cart_discount_pct=cart_discount)
    assert rep_with_discount["gross_total"] <= rep_no_discount["gross_total"]

@given(
    unit_price=st.integers(min_value=100, max_value=50000),
    shipping_fee=st.integers(min_value=0, max_value=5000),
)
def test_shipping_fee_adds_to_total(unit_price, shipping_fee):
    items = [LineItem(unit_price, 1, 0)]
    rep = price_order(items, vat_rate=27, shipping_fee_huf=shipping_fee)
    items_gross = rep["items_gross"]
    assert rep["gross_total"] == items_gross + shipping_fee

@given(
    unit_price=st.integers(min_value=10000, max_value=50000),
    threshold=st.integers(min_value=5000, max_value=40000),
    shipping_fee=st.integers(min_value=500, max_value=2000),
)
def test_free_shipping_threshold_property(unit_price, threshold, shipping_fee):
    items = [LineItem(unit_price, 1, 0)]
    rep = price_order(
        items, 
        vat_rate=27,
        shipping_fee_huf=shipping_fee,
        free_shipping_threshold_huf=threshold
    )
    if unit_price >= threshold:
        assert rep["shipping_fee"] == 0
    else:
        assert rep["shipping_fee"] == shipping_fee

@given(
    unit_price=st.integers(min_value=1000, max_value=20000),
    coupon_percent=st.floats(min_value=1, max_value=50),
    days_until_expiry=st.integers(min_value=1, max_value=365),
)
def test_valid_coupon_reduces_price(unit_price, coupon_percent, days_until_expiry):
    items = [LineItem(unit_price, 1, 0)]
    today = date(2025, 9, 16)
    coupon = Coupon("TEST", coupon_percent, today + timedelta(days=days_until_expiry))
    rep_no_coupon = price_order(items, vat_rate=27, today=today)
    rep_with_coupon = price_order(items, vat_rate=27, coupon=coupon, today=today)
    assert rep_with_coupon["gross_total"] < rep_no_coupon["gross_total"]
    assert rep_with_coupon["coupon_applied"] > 0

@given(
    prices=st.lists(
        st.integers(min_value=100, max_value=10000),
        min_size=1,
        max_size=10
    )
)
def test_multiple_items_sum(prices):
    items = [LineItem(price, 1, 0) for price in prices]
    rep = price_order(items, vat_rate=27)
    expected_sum = sum(item.gross() for item in items)
    assert rep["items_gross"] == expected_sum
