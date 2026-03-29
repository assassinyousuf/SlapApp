import urllib.request
import os

sounds = {
    'bonk.mp3': 'https://www.myinstants.com/media/sounds/bonk_2.mp3',
    'fart.mp3': 'https://www.myinstants.com/media/sounds/fart-with-extra-reverb.mp3',
    'bruh.mp3': 'https://www.myinstants.com/media/sounds/movie_1.mp3',
    'quack.mp3': 'https://www.myinstants.com/media/sounds/quack_5.mp3',
    'punch.mp3': 'https://www.myinstants.com/media/sounds/punch.mp3',
    'scream.mp3': 'https://www.myinstants.com/media/sounds/wilhelm_scream.mp3',
    'tada.mp3': 'https://www.myinstants.com/media/sounds/tada.mp3',
    'bell.mp3': 'https://www.myinstants.com/media/sounds/taco-bell-bong-sfx.mp3',
}

os.makedirs('assets/sounds', exist_ok=True)

for name, url in sounds.items():
    try:
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req) as response:
            data = response.read()
            if len(data) > 1000: # ensure it's not a tiny 404 page
                with open(f'assets/sounds/{name}', 'wb') as out_file:
                    out_file.write(data)
                print(f"Success: {name}")
            else:
                print(f"Skipped {name} (too small)")
    except Exception as e:
        print(f"Failed: {name} - {e}")
