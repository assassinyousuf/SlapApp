import urllib.request
import os

new_sounds = {
    'moan_augh2.mp3': 'https://www.myinstants.com/media/sounds/augh_1.mp3',
    'moan_augh3.mp3': 'https://www.myinstants.com/media/sounds/augh_2.mp3',
    'moan_ah_meme.mp3': 'https://www.myinstants.com/media/sounds/ahhh-meme.mp3',
    'moan_aaaah.mp3': 'https://www.myinstants.com/media/sounds/aaaah.mp3',
    'moan_turtle2.mp3': 'https://www.myinstants.com/media/sounds/turtle-mating-sound.mp3',
    'moan_turtle3.mp3': 'https://www.myinstants.com/media/sounds/turtle-mating-moan.mp3',
    'moan_meme1.mp3': 'https://www.myinstants.com/media/sounds/moaning-meme_1.mp3',
    'moan_loud2.mp3': 'https://www.myinstants.com/media/sounds/loud-moan_1.mp3',
    'moan_ah8.mp3': 'https://www.myinstants.com/media/sounds/ah_8.mp3',
    'moan_gachi.mp3': 'https://www.myinstants.com/media/sounds/gachigasm.mp3',
    'moan_scream.mp3': 'https://www.myinstants.com/media/sounds/loud-scream-moan.mp3',
    'moan_sus.mp3': 'https://www.myinstants.com/media/sounds/sus-moan.mp3',
    'moan_ohh.mp3': 'https://www.myinstants.com/media/sounds/ohhhh-meme.mp3',
    'moan_9.mp3': 'https://www.myinstants.com/media/sounds/moan_9.mp3',
}

os.makedirs('assets/sounds', exist_ok=True)

found_count = 0
for name, url in new_sounds.items():
    try:
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req) as response:
            data = response.read()
            if len(data) > 1000:
                with open(f'assets/sounds/{name}', 'wb') as out_file:
                    out_file.write(data)
                print(f"Success: {name}")
                found_count += 1
    except Exception as e:
        print(f"Failed: {name} - {e}")
        pass

print(f"Done! Downloaded {found_count} new moans.")
