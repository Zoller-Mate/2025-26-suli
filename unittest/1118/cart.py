# 2. feladat - calculate_cart_total implementacio

def calculate_cart_total(items):
    """Kiszamolja a kosar teljes erteket."""
    
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
    return round(total, 2)
