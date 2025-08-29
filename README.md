# YTMusicUltimate
<p align="center">
<img src=https://user-images.githubusercontent.com/38832025/235781424-06d81647-b3db-4d9b-94dc-cd65cdf09145.png?raw=true) />
</p>    

<p align="center">
<img src=https://user-images.githubusercontent.com/38832025/235781207-6d1ad44e-0c32-4aec-9c75-cb928ca8a0d3.png?raw=true) />
</p>

<p align="center">
The best tweak for the YouTube Music on iOS.
</p>

## Download Links

* **Jailbreak:**
Add __[https://ginsu.dev/repo](https://ginsu.dev/repo)__ to your favorite installer and download latest version from there, or from __[Releases](https://github.com/ginsudev/YTMusicUltimate/releases)__ page.

(arm.deb version for Rootful and arm64.deb version for Rootless devices)

* **Sideloading:**
  We no longer provide a sideloading IPA but you can build one yourself, keep reading:

## How to build a YTMusicUltimate IPA by yourself using Github actions

If this is your first time here, start from step 1. If you built a YTMU IPA before, skip steps 1 and 2. Instead, click on the "Sync fork" button to get the latest version of the tweak and continue through step 3.

1. Fork this repository using the fork button on the top right.
2. On your forked repository, go to Repository Settings > Actions, enable Read and Write permissions.
3. Go to the Actions tab on your forked repo, click on "Build and Release YTMusicUltimate" located on the left side. Click "Run workflow" button located on the right side.
4. Find a decrypted YTMusic .ipa file (we cannot provide you this due to legal reasons) and upload it to a file provider(filebin.net or Dropbox is recommended). Paste the url to the necessary field and click "Run workflow".
5. Wait for the build to finish. You can download the tweaked IPA from the releases section of your forked repo. (If you can't find the releases section, go to your forked repo and add /releases to the url. i.e github.com/user/YTMusicUltimate/releases)

## IPA building troubleshooting(I can't build the IPA/Github action fails/I can't find the releases section etc.)

99.9% of the time, the culprit is the IPA URL you provided. You HAVE TO provide a decryped IPA. It cannot be any other extension, it has to be a **.ipa** file. Find a decrypted YTMusic IPA(we can't help you with that), upload it to filebin.net or Dropbox, give the direct link to the GitHub action. If you find a working ipa and upload it properly, everything will start working perfectly, pinky promise.

If the github action works and you cannot find where you can download the result, you need to add /releases to the url of your forked repository. It'll probably look like this: https://github.com/YOURUSERNAME/YTMusicUltimate/releases, don't forget to replace the YOURUSERNAME part with your username. It may seem invisible but if the github action is successful, IPA will be there.


## How to build the package by yourself on your device
1. Install __[Theos](https://theos.dev/docs/installation)__
2. Clone this repo __[using git](https://docs.github.com/en/repositories/creating-and-managing-repositories/cloning-a-repository)__
3. Cd your YTMusicUltimate folder and run:

   • '**make clean package**' to build deb for rootful device
   
   • '**make clean package ROOTLESS=1**' to build deb for rootless device
   
   • '**make clean package SIDELOADING=1**' to build deb for injecting in to ipa
   
   

   • To learn how to inject tweaks in to ipa visit __[here (Azule)](https://github.com/Al4ise/Azule)__

## How to build the IPA locally (Recommended Method)

If you want to build the IPA directly on your machine instead of using GitHub Actions, follow these steps:

### Prerequisites
1. Install __[Theos](https://theos.dev/docs/installation)__
2. Install __[cyan](https://github.com/chariz/cyan)__: `pip3 install cyan`
3. Get a decrypted YouTube Music IPA file (place it in `IPA/` folder)

### Build Commands

```bash
# 1. Build the tweak
make

# 2. Build the package with sideloading support
make package SIDELOADING=1

# 3. Create the IPA using cyan (direct command)
export PATH="$HOME/Library/Python/3.9/bin:$HOME/.local/bin:$PATH"
cyan -i IPA/com.google.ios.youtubemusic-8.32-Decrypted.ipa \
     -o IPA/YTMusicUltimate-v2.3.1.ipa \
     -uwsf packages/com.ginsu.ytmusicultimate_2.3.1_iphoneos-arm.deb \
     -n "YouTube Music" \
     -b com.google.ios.youtubemusic
```

### File Placeholders
- **Source IPA**: `IPA/com.google.ios.youtubemusic-8.32-Decrypted.ipa` (replace with your decrypted IPA)
- **Output IPA**: `IPA/YTMusicUltimate-v2.3.1.ipa` (will be created)
- **Package**: `packages/com.ginsu.ytmusicultimate_2.3.1_iphoneos-arm.deb` (will be created)

### Important Notes
- **Keep the original Makefile** from the fork - don't modify compiler flags
- **Only add `-Wno-vla`** if needed for VLA code compilation
- **Use direct cyan commands** instead of complex make targets
- **The app will work** with the original fork configuration

Made with ❤ by Ginsu and Dayanch96
