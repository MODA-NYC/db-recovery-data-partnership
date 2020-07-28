from geosupport import Geosupport, GeosupportError
import usaddress
import re

g = Geosupport()

def get_hnum(address):
    """ 
    Parse address to extract house number using usaddress module

    Parameters: 
    address (str): Full address

    Returns:
    result (str): All portions of the address string
                    tagged by usaddress as a house number
    """
    address = "" if address is None else address
    result = [k for (k, v) in usaddress.parse(address) if re.search("Address", v)]
    result = " ".join(result)
    fraction = re.findall("\d+[\/]\d+", address)
    if not bool(re.search("\d+[\/]\d+", result)) and len(fraction) != 0:
        result = f"{result} {fraction[0]}"
    return result


def get_sname(address):
    """ 
    Parse address to extract street name using usaddress module

    Parameters: 
    address (str): Full address

    Returns:
    result (str): All portions of the address string
                    tagged by usaddress as a street name
    """
    result = (
        [k for (k, v) in usaddress.parse(address) if re.search("Street", v)]
        if address is not None
        else ""
    )
    result = " ".join(result)
    if result == "":
        return address
    else:
        return result


def get_zipcode(address):
    """ 
    Parse address to extract street name using usaddress module

    Parameters: 
    address (str): Full address

    Returns:
    result (str): All portions of the address string
                    tagged by usaddress as a zipcode
    """
    result = (
        [k for (k, v) in usaddress.parse(address) if re.search("ZipCode", v)]
        if address is not None
        else []
    )
    return result[0] if len(result) > 0 else ''

def geocode(input):
    # collect inputs
    hnum = input.pop("hnum")
    sname = input.pop("sname")
    zipcode = input.pop("zipcode")
    try:
        try:
            geo = g["1B"](
                street_name=sname, house_number=hnum, zip_code=zipcode, mode="regular"
            )
            geo = parse_output(geo)

        except GeosupportError as e:
            geo = parse_output(e.result)
    except:
        geo = parse_output({})

    geo.update(input)
    return geo

def parse_output(geo):
    return dict(
        geo_housenum=geo.get("House Number - Display Format", ""),
        geo_streetname=geo.get("First Street Name Normalized", ""),
        geo_borough=geo.get("First Borough Name", ''),
        geo_nta=geo.get('Neighborhood Tabulation Area (NTA)', ''),
        geo_latitude=geo.get("Latitude", ""),
        geo_longitude=geo.get("Longitude", ""),
        geo_grc=geo.get("Geosupport Return Code (GRC)", ""),
        geo_grc2=geo.get("Geosupport Return Code 2 (GRC 2)", "")
    )
