import wikipediaapi

wiki_wiki = wikipediaapi.Wikipedia(user_agent='Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36', language='en')
category = wiki_wiki.page("Category:Fridtjof_Nansen-class_frigates")

# Get all pages in the category
cruiser_names = [p.title for p in category.categorymembers.values() if p.ns == 0]

with open("ships.txt", "a", encoding="utf-8") as file:
    for name in cruiser_names:
        file.write(name + "\n")
