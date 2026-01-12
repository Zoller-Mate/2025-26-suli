# onallo feladat 1. - fix osszegu kupon implementacioja

from dataclasses import dataclass
from datetime import date
from typing import Optional, List
from decimal import Decimal, ROUND_HALF_UP
from enum import Enum

class InvalidCouponError(Exception):
    pass

class CouponType(Enum):
    PERCENT = "percent"
    FIXED = "fixed"

_ALLOWED_VAT = {0, 5, 18, 27}

def round_huf(x: float) -> int:
    d = Decimal(str(x))
    return int(d.quantize(Decimal("0"), rounding=ROUND_HALF_UP))

@dataclass(frozen=True)
class LineItem:
    unit_price: int
    qty: int
    item_discount_pct: float = 0.0

    def gross(self) -> int:
        if self.unit_price < 0:
            raise ValueError("Negatív ár nem megengedett")
        if self.qty <= 0:
            raise ValueError("Mennyiség legalább 1")
        if not (0 <= self.item_discount_pct <= 100):
            raise ValueError("Kedvezmény 0–100% között lehet")
        raw = self.unit_price * self.qty
        return round_huf(raw * (1 - self.item_discount_pct / 100))

@dataclass(frozen=True)
class Coupon:
    code: str
    discount_value: float
    coupon_type: CouponType
    expires_at: date

def price_order(
    items: List[LineItem],
    vat_rate: int,
    cart_discount_pct: float = 0.0,
    coupon: Optional[Coupon] = None,
    shipping_fee_huf: int = 0,
    free_shipping_threshold_huf: Optional[int] = None,
    today: Optional[date] = None
) -> dict:
    if vat_rate not in _ALLOWED_VAT:
        raise ValueError("Érvénytelen ÁFA kulcs")
    if not (0 <= cart_discount_pct <= 100):
        raise ValueError("Kedvezmény 0–100% között lehet")
    if shipping_fee_huf < 0:
        raise ValueError("Negatív szállítási díj")
    if today is None:
        today = date.today()

    items_gross = sum(i.gross() for i in items)

    after_cart = round_huf(items_gross * (1 - cart_discount_pct / 100))
    cart_discount_applied = items_gross - after_cart

    coupon_applied = 0
    after_coupon = after_cart
    if coupon:
        if today > coupon.expires_at:
            raise InvalidCouponError("Kupon lejárt")
        
        if coupon.coupon_type == CouponType.PERCENT:
            new_total = round_huf(after_cart * (1 - coupon.discount_value / 100))
        elif coupon.coupon_type == CouponType.FIXED:
            new_total = max(0, after_cart - int(coupon.discount_value))
        else:
            raise ValueError("Ismeretlen kupon típus")
        
        coupon_applied = after_cart - new_total
        after_coupon = new_total

    if free_shipping_threshold_huf and after_coupon >= free_shipping_threshold_huf:
        shipping_fee = 0
    else:
        shipping_fee = shipping_fee_huf

    gross_total = after_coupon + shipping_fee
    denom = 1 + vat_rate / 100
    net_total = round_huf(gross_total / denom)
    vat_component = gross_total - net_total

    return {
        "items_gross": items_gross,
        "cart_discount_applied": cart_discount_applied,
        "coupon_applied": coupon_applied,
        "shipping_fee": shipping_fee,
        "gross_total": gross_total,
        "net_total": net_total,
        "vat_component": vat_component,
    }
