# :art: Photoshop & Lightroom CC for Linux

<p align="center">
  <img src="./images/Screenshot.png" alt="Photoshop CC running on Linux" width="800"/>
</p>

<p align="center">
  <img src="./images/lightroom.png" alt="Lightroom CC" width="128"/>
</p>

<div align="center">

[![Wine](https://img.shields.io/badge/Wine-11.5--staging-red?style=for-the-badge)](https://winehq.org)
[![Platform](https://img.shields.io/badge/Platform-Linux-brightgreen?style=for-the-badge)
[![License](https://img.shields.io/badge/License-Free-yellowgreen?style=for-the-badge)
[![Bash](https://img.shields.io/badge/Bash-5.0+-yellowgreen?style=for-the-badge)
[![GitHub Stars](https://img.shields.io/github/stars/bpawnzZ/photoshopCClinux-lightroom?style=for-the-badge)](https://github.com/bpawnzZ/photoshopCClinux-lightroom/stargazers)

**Run Adobe Photoshop CC & Lightroom CC on Linux using Wine** :penguin:

</div>

---

## :sparkles: Features

| Feature | Description |
|:--------|:------------|
| :package: **Bundled Files** | All installers included - no downloads needed |
| :wine_glass: **Wine Integration** | Runs Photoshop using Wine staging |
| :gear: **Auto-Setup** | Installs vcrun, atmlib, msxml automatically |
| :art: **Dark Mode** | Wine prefix configured with dark theme |
| :desktop_computer: **Launcher** | Desktop entry + command line shortcut |
| :camera: **Camera Raw** | Optional installer included |
| :free: **Free** | No license key required |

---

## :computer: Installation

### Prerequisites

**Highly Recommended:** Follow [GloriousEggroll's Wine Dependency Guide](https://www.gloriouseggroll.tv/how-to-get-out-of-wine-dependency-hell/) to properly set up Wine before running this installer!

```bash
# Arch Linux (recommended)
sudo pacman -Sy
sudo pacman -S wine-staging winetricks
sudo pacman -S giflib lib32-giflib libpng lib32-libpng libldap lib32-libldap gnutls lib32-gnutls mpg123 lib32-mpg123 openal lib32-openal v4l-utils lib32-v4l-utils libpulse lib32-libpulse alsa-plugins lib32-alsa-plugins alsa-lib lib32-alsa-lib libjpeg-turbo lib32-libjpeg-turbo libxcomposite lib32-libxcomposite libxinerama lib32-libxinerama ncurses lib32-ncurses opencl-icd-loader lib32-opencl-icd-loader libxslt lib32-libxslt libva lib32-libva gtk3 lib32-gtk3 gst-plugins-base-libs lib32-gst-plugins-base-libs vulkan-icd-loader lib32-vulkan-icd-loader cups samba dosbox

# Debian/Ubuntu
sudo dpkg --add-architecture i386
wget -nc https://dl.winehq.org/wine-builds/winehq.key
sudo apt-key add winehq.key
sudo apt-add-repository 'https://dl.winehq.org/wine-builds/ubuntu/'
sudo apt update
sudo apt install --install-recommends winehq-staging winetricks

# Fedora
sudo dnf groupinstall "Development Tools"
sudo dnf install wine winetricks
```

> **Pro Tip:** Run `./setup.sh` as the user who will use Photoshop, not as root!
>
> **Note:** The only additional step from GloriousEggroll's guide not covered above is creating a symlink:
> ```bash
> sudo ln -sf /usr/bin/wine64 /usr/bin/wine
> ```

### Quick Start

```bash
# Clone this repository
git clone https://github.com/bpawnzZ/photoshopCClinux-lightroom.git
cd photoshopCClinux-lightroom

# Install git LFS (required for large files)
git lfs install
git lfs pull

# Run the installer
chmod +x setup.sh
./setup.sh
```

### Custom Paths

```bash
# Custom installation directory
./setup.sh -d /path/to/install

# With custom cache
./setup.sh -d /path/to/install -c /path/to/cache
```

---

## :floppy_disk: Included Files

| File | Size | Description |
|:-----|:-----|:------------|
| `photoshopCC-V19.1.6-2018x64.tgz` | ~1 GB | Photoshop CC v19 installer |
| `replacement.tgz` | ~15 MB | Resource replacement files |
| `CameraRaw_12_2_1.exe` | ~400 MB | Adobe Camera Raw (optional) |
| `lightroomCC-V7.5-2018x64.tgz` | ~1 GB | Lightroom CC installer |

All components are installed via `./setup.sh`:
- Option 1: Photoshop CC
- Option 2: Adobe Camera Raw
- Option 3: Winecfg
- Option 4: Uninstall
- Option 5: Lightroom CC
- Option 6: Exit

---

## :camera: Adobe Camera Raw (Optional)

Install via `./setup.sh` (option 2), then restart Photoshop and go to `Edit → Preferences → Camera Raw`

---

## :sparkles: Adobe Lightroom CC (Optional)

> **Important:** Install Photoshop first so the prefix is already setup!

> Originally requested here: [Gictorbit/photoshopCClinux#221](https://github.com/Gictorbit/photoshopCClinux/issues/221)

Install via `./setup.sh` (option 5), or run from command line:
```bash
~/photoshopCClinux/lightroom
```

Or find Lightroom in your desktop applications menu.

---

## :wine_glass: Wine Configuration

```bash
chmod +x winecfg.sh
./winecfg.sh
```

> **Note:** Set Windows version to **Windows 7** in winecfg. Windows 10 may fail to start the applications.

### Troubleshooting GPU / Liquify

If Liquify or GPU features don't work:
1. **Edit → Preferences → Performance**
2. **Uncheck** "Use Graphics Processor"
3. Restart Photoshop

---

## :arrow_down: Uninstallation

```bash
chmod +x uninstaller.sh
./uninstaller.sh
```

---

## :heart: Credits & Acknowledgments

<div align="center">

### Original Project
**[Gictorbit/photoshopCClinux](https://github.com/Gictorbit/photoshopCClinux)**  
*The original project that made this possible*

### Why This Fork Exists
The upstream project's download links went dead. This fork keeps the project alive by including all required files locally.

</div>

---

## :book: License

This project is provided as-is for educational purposes. You must own a legitimate copy of Adobe Photoshop to use this software legally.

---

<div align="center">

**Made with :heart: for the Linux community** :penguin:

[![GitHub forks](https://img.shields.io/github/forks/bpawnzZ/photoshopCClinux-lightroom?style=flat)](https://github.com/bpawnzZ/photoshopCClinux-lightroom/network)
[![GitHub stars](https://img.shields.io/github/stars/bpawnzZ/photoshopCClinux-lightroom?style=flat)](https://github.com/bpawnzZ/photoshopCClinux-lightroom/stargazers)

</div>
