# 5. feladat - apply_coupon implementacio (TDD utan)

def apply_coupon(total, code):
    """
    Kuponkodot alkalmaz a vegosszegre.
    - SAVE10: 10% kedvezmeny
    - Minimum 5000 Ft kell
    - Lejart kuponok hibat dobnak
    """
    
    # ures vagy None kuponkod
    if not code:
        return total
    
    # lejart kupon ellenorzes
    if code == "EXPIRED2024":
        raise ValueError("Lejart kupon")
    
    # ismeretlen kuponkod
    if code != "SAVE10":
        return total
    
    # minimalis osszeg ellenorzes
    if total < 5000:
        return total
    
    # 10% kedvezmeny alkalmazasa
    discounted_total = total * 0.9
    return round(discounted_total, 2)
