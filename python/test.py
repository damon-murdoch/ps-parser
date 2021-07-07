# Import the parser python script
import set_parser as parser

# Test string containing a pokemon team
test_set = """
Arahpthos (Salamence-Mega) (M) @ Salamencite  
Ability: Aerilate  
Level: 50  
Shiny: Yes  
EVs: 4 Atk / 252 SpA / 252 Spe  
Naive Nature  
- Double-Edge  
- Hyper Voice  
- Tailwind  
- Protect  

Bob Ross (Smeargle) (M) @ Choice Scarf  
Ability: Own Tempo  
Level: 50  
Shiny: Yes  
EVs: 4 HP / 144 Def / 252 Spe  
Jolly Nature  
IVs: 30 Atk / 30 Def  
- Fake Out  
- Transform  
- Soak  
- Dark Void  

MC Hammer (Shedinja) (M) @ Focus Sash  
Ability: Wonder Guard  
Level: 50  
Shiny: Yes  
EVs: 252 Atk / 4 SpA / 252 Spe  
Adamant Nature  
- Shadow Sneak  
- Phantom Force  
- Toxic  
- Protect  

Boomdude (Xerneas) (M) @ Power Herb  
Ability: Fairy Aura  
Level: 50  
Shiny: Yes  
EVs: 44 HP / 12 Def / 196 SpA / 4 SpD / 252 Spe  
Timid Nature  
IVs: 0 Atk  
- Moonblast  
- Dazzling Gleam  
- Geomancy  
- Protect  

Mastodon (Groudon) (M) @ Red Orb  
Ability: Drought  
Level: 50  
EVs: 4 HP / 4 Def / 244 SpA / 4 SpD / 252 Spe  
Timid Nature  
IVs: 0 Atk / 30 Def  
- Eruption  
- Earth Power  
- Hidden Power [Ice]  
- Protect  

Mogarchu (Amoonguss) @ Mental Herb  
Ability: Regenerator  
Level: 50  
Shiny: Yes  
EVs: 128 HP / 132 Def / 4 SpA / 244 SpD  
Sassy Nature  
IVs: 0 Atk / 0 Spe  
- Protect  
- Rage Powder  
- Spore  
- Clear Smog
"""

# Run the parser on the set
sets = parser.parse_sets(test_set)

# Write the output to the terminal
print(sets)