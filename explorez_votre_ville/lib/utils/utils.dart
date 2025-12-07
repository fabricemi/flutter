Future<Map<String, String>> getCategories() async {
  const Map<String, String> categories = {
    "tourism.sights": "Lieux touristiques",
    "entertainment.museum": "Musées",
    "entertainment.gallery": "Galeries d'art",
    "entertainment.park": "Parcs",
    "leisure.park": "Parcs",
    "entertainment.theme_park": "Parcs d'attractions",
    "entertainment.zoo": "Zoos",
    "heritage": "Patrimoine",

    "natural": "Sites naturels",
    "natural.forest": "Forêts",
    "natural.water": "Lacs & Points d'eau",

    "catering.restaurant": "Restaurants",
    "catering.fast_food": "Fast-foods",
    "catering.cafe": "Cafés",
    "catering.bar": "Bars & Pubs",
    "catering.pub": "Bars & Pubs",

    "commercial.supermarket": "Supermarchés",
    "commercial.shopping_mall": "Centres commerciaux",
    "commercial.marketplace": "Marchés",

    "education.school": "Écoles",
    "education.university": "Universités",

    "healthcare.hospital": "Hôpitaux",
  };

  return categories;
}
