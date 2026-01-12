# 3. feladat - calculate_cart_total bovitett verzio kedvezmennyel

def calculate_cart_total(items, apply_discount=True):
    """
    Kiszamolja a kosar teljes erteket.
    Ha az osszeg eleri a 10000 Ft-ot, 5% kedvezmenyt ad.
    """
    
    # ures kosar esete
    if not items:
        return 0
    
    total = 0
    
    for item in items:
        quantity = item.get("quantity", 0)
        unit_price = item.get("unit_price", 0)
        
        # negativ mennyiseg ellenorzes
        if quantity < 0:
            raise ValueError("A mennyiseg nem lehet negativ")
        
        # osszeg szamolas
        total += unit_price * quantity
    
    # kerekites 2 tizedesjegyre
    total = round(total, 2)
    
    # 5% kedvezmeny ha eleri a 10000 Ft-ot
    if apply_discount and total >= 10000:
        total = total * 0.95
        total = round(total, 2)
    
    return total
