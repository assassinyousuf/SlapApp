import urllib.request
import os

new_sounds = {
    'punch_heavy.mp3': 'https://www.myinstants.com/media/sounds/strong-punch.mp3',
    'punch_mc.mp3': 'https://www.myinstants.com/media/sounds/minecraft-hit_1.mp3',
    'punch_anime.mp3': 'https://www.myinstants.com/media/sounds/anime-punch.mp3',
    'punch_boxing.mp3': 'https://www.myinstants.com/media/sounds/boxing-punch.mp3',
    'moan_augh.mp3': 'https://www.myinstants.com/media/sounds/aughhhhh.mp3',
    'moan_loud.mp3': 'https://www.myinstants.com/media/sounds/loud-moan.mp3',
    'moan_turtle.mp3': 'https://www.myinstants.com/media/sounds/turtle-moan.mp3',
    'moan_anime.mp3': 'https://www.myinstants.com/media/sounds/anime-girl-ahhhh.mp3',
    'moan_yamete.mp3': 'https://www.myinstants.com/media/sounds/yamete-kudasai_1.mp3',
    'moan_gachi.mp3': 'https://www.myinstants.com/media/sounds/gachi-gasm.mp3'
}

os.makedirs('assets/sounds', exist_ok=True)

for name, url in new_sounds.items():
    try:
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req) as response:
            data = response.read()
            if len(data) > 1000:
                with open(f'assets/sounds/{name}', 'wb') as out_file:
                    out_file.write(data)
                print(f"Success: {name}")
    except Exception as e:
        print(f"Failed: {name} - {e}")
