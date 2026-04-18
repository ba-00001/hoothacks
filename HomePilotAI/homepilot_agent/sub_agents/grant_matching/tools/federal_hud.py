import requests
import math

# HUD service codes relevant to the 4 program types
SERVICE_CODES = {
    "first_time_buyer":  "DFC",  # Pre-purchase / homebuying counseling
    "state_grants":      "DFC",  # Same agencies handle down payment / grant programs
    "rental_assistance": "DRC",  # Rental housing counseling
    "student_housing":   "DRC",  # Closest match — rental/housing support
}

def calculate_distance(lat1, lon1, lat2, lon2):
    R = 3958.8
    lat1, lon1, lat2, lon2 = map(math.radians, [float(lat1), float(lon1), float(lat2), float(lon2)])
    dlat, dlon = lat2 - lat1, lon2 - lon1
    a = math.sin(dlat/2)**2 + math.cos(lat1) * math.cos(lat2) * math.sin(dlon/2)**2
    return R * 2 * math.asin(math.sqrt(a))

def geocode_zip(zip_code: str) -> dict | None:
    """Returns {lat, lng, city, state} for a US zip code."""
    try:
        resp = requests.get(f"https://api.zippopotam.us/us/{zip_code}", timeout=5)
        resp.raise_for_status()
        data = resp.json()
        place = data["places"][0]
        return {
            "lat": float(place["latitude"]),
            "lng": float(place["longitude"]),
            "city": place["place name"],
            "state": place["state abbreviation"].upper(),
        }
    except Exception as e:
        print(f"Geocoding error for zip {zip_code}: {e}")
        return None

def _fetch_agencies(geo: dict, radius: int, program_types: list | None, max_results: int) -> list:
    """Inner fetch using the correct HUD searchByLocation API."""
    url = "https://data.hud.gov/Housing_Counselor/searchByLocation"
    params = {
        "Lat": geo["lat"],
        "Long": geo["lng"],
        "Distance": radius,
    }

    try:
        resp = requests.get(url, params=params, timeout=15)
        resp.raise_for_status()
        raw = resp.json()
    except Exception as e:
        print(f"HUD API error: {e}")
        return []

    # Determine service codes to filter on (if program_types specified)
    wanted_codes = set()
    if program_types:
        for pt in program_types:
            code = SERVICE_CODES.get(pt)
            if code:
                wanted_codes.add(code)

    agencies = []
    for item in raw:
        services_raw = item.get("services", "") or ""
        service_list = [s.strip() for s in services_raw.split(",") if s.strip()]

        # Filter by service code if requested
        if wanted_codes and not wanted_codes.intersection(service_list):
            continue

        lat = item.get("lat") or item.get("agc_lat")
        lng = item.get("lng") or item.get("agc_long")

        dist = None
        if lat is not None and lng is not None:
            try:
                dist = round(calculate_distance(geo["lat"], geo["lng"], float(lat), float(lng)), 1)
            except (ValueError, TypeError):
                pass

        # Build address string
        addr_parts = [
            item.get("adr1", ""),
            item.get("adr2", ""),
            item.get("city", ""),
            item.get("statecd", ""),
            item.get("zipcd", ""),
        ]
        address = ", ".join(p for p in addr_parts if p)

        agencies.append({
            "name":           item.get("nme", "Unknown Agency"),
            "phone":          item.get("phone1", ""),
            "email":          item.get("email", ""),
            "website":        item.get("weburl", ""),
            "address":        address,
            "distance_miles": dist,
            "services":       service_list,
            "languages":      [l.strip() for l in (item.get("languages") or "").split(",") if l.strip()],
        })

    # Sort by distance (None last), cap results
    agencies.sort(key=lambda x: x["distance_miles"] if x["distance_miles"] is not None else 9999)
    return agencies[:max_results]


def find_housing_agencies(
    zip_code: str,
    first_time_buyer: bool = False,
    rental_assistance: bool = False,
    state_grants: bool = False,
    student_housing: bool = False,
    radius_miles: int = 50,
    max_results: int = 5,
) -> dict:
    """
    Find HUD-approved housing agencies near a zip code.

    Args:
        zip_code (str): US zip code to search near.
        first_time_buyer (bool): Include agencies offering pre-purchase and
            homebuying counseling for first-time buyers. Defaults to False.
        rental_assistance (bool): Include agencies offering rental housing
            counseling and tenant support. Defaults to False.
        state_grants (bool): Include agencies offering down payment assistance
            and state housing grant programs. Defaults to False.
        student_housing (bool): Include agencies offering housing support
            for students and young adults. Defaults to False.
        radius_miles (int): Search radius in miles. Auto-expands by 50-mile
            increments up to 200 miles if no results found. Defaults to 50.
        max_results (int): Maximum number of agencies to return. Defaults to 5.

    Returns:
        dict: Keys: zip_code, location, radius_miles, agencies (list), error.
            Each agency has: name, phone, email, website, address,
            distance_miles, services, languages.
    """
    geo = geocode_zip(zip_code)
    if not geo:
        return {"zip_code": zip_code, "error": "Could not geocode zip code.", "agencies": []}

    # Build program list from flags
    flag_map = {
        "first_time_buyer": first_time_buyer,
        "rental_assistance": rental_assistance,
        "state_grants":      state_grants,
        "student_housing":   student_housing,
    }
    program_list = [name for name, enabled in flag_map.items() if enabled]

    for search_radius in range(radius_miles, 201, 50):
        agencies = _fetch_agencies(geo, search_radius, program_list, max_results)
        if agencies:
            return {
                "zip_code":     zip_code,
                "location":     f"{geo['city']}, {geo['state']}",
                "radius_miles": search_radius,
                "agencies":     agencies,
                "error":        None,
            }
        print(f"No agencies within {search_radius} miles, expanding...")

    return {
        "zip_code":     zip_code,
        "location":     f"{geo['city']}, {geo['state']}",
        "radius_miles": 200,
        "agencies":     [],
        "error":        "No HUD-approved agencies found within 200 miles.",
    }

# ── Test ────────────────────────────────────────────────────────────────────
if __name__ == "__main__":
    import json

    tests = [
        {"zip": "33431", "label": "Boca Raton, FL",  "types": ["first_time_buyer", "rental_assistance"]},
        {"zip": "75201", "label": "Dallas, TX",       "types": ["state_grants"]},
        {"zip": "33431", "label": "Boca Raton (all)", "types": None},
    ]

    for t in tests:
        print(f"\n{'─'*55}")
        print(f"  {t['label']} | zip={t['zip']} | programs={t['types']}")
        print(f"{'─'*55}")
        result = find_housing_agencies(t["zip"], program_types=t["types"])
        print(json.dumps(result, indent=2))