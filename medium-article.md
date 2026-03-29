# Run Adobe Photoshop CC & Lightroom CC on Linux: The Complete Guide

![Adobe Creative Suite on Linux](https://images.unsplash.com/photo-1572044162444-ad60f128bdea?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80)

## 🎨 **The Ultimate Adobe Creative Suite Setup for Linux Enthusiasts**

*Last updated: March 2026*

Are you a Linux user dreaming of running Adobe's professional creative tools? **Photoshop CC and Lightroom CC are now fully functional on Linux** thanks to this community-maintained repository that bundles everything you need.

### 🔥 **What's New: Lightroom CC Support Added!**

This isn't just another Photoshop setup. This repository now includes **complete Lightroom CC support**, giving you the full Adobe Creative Suite workflow on Linux:

- **Photoshop CC v19.1.6** - Industry-standard image editing
- **Lightroom CC v7.5** - Professional photo management and editing  
- **Adobe Camera Raw** - RAW file processing
- **Shared Wine environment** - Both apps optimized together

---

## 🚨 **The Problem: Dead Links and Broken Installs**

The original Adobe Photoshop setup repositories suffered from **broken download links**. Users would clone the repo, try to install, and hit dead ends:

| File | Original Status | Our Solution |
|------|----------------|--------------|
| `photoshopCC-V19.1.6-2018x64.tgz` | ❌ Dead link | ✅ **Bundled locally** |
| `lightroomCC.tgz` | ❌ Not available | ✅ **Added complete support** |
| `replacement.tgz` | ❌ Broken URL | ✅ **Included in repo** |
| `CameraRaw_12_2_1.exe` | ❌ Adobe changes | ✅ **Latest version included** |

**Total size: ~2.3GB - Everything included, no external downloads!**

---

## ✨ **Why This Repository Stands Out**

### 🎯 **Complete Creative Workflow**
- **Photoshop + Lightroom together** - Seamless creative suite experience
- **Professional photo editing** - From capture to final output
- **Industry-standard tools** - Same software used by professionals worldwide

### 🛠️ **Enhanced Features**
- **Smart Wine detection** - Automatically finds the best Wine version (wine-staging > wine64 > wine)
- **Cross-distro compatibility** - Works on Arch, Ubuntu, Debian, Fedora, and more
- **Intelligent dependency management** - No redundant installations
- **User-friendly error handling** - Clear messages with actionable solutions
- **Shared Wine prefix** - Both apps use the same optimized environment

### 📦 **Zero External Dependencies**
- **All files bundled** - No more hunting for downloads
- **Git LFS integration** - Large files handled automatically  
- **Regular updates** - Active maintenance and bug fixes
- **Community-driven** - Fork created to keep the project alive

---

## 🚀 **Installation Guide: 3 Easy Steps**

### **Step 1: Install Wine (Recommended)**

For the best experience, install Wine first. Here's how for different distributions:

**Arch Linux/Manjaro:**
```bash
sudo pacman -Sy
sudo pacman -S wine-staging winetricks
```

**Ubuntu/Debian:**
```bash
sudo dpkg --add-architecture i386
sudo apt update
sudo apt install wine winetricks
```

**Fedora:**
```bash
sudo dnf install wine winetricks
```

### **Step 2: Clone and Setup**

```bash
# Clone the repository
git clone https://github.com/bpawnzZ/photoshopCClinux-lightroom.git
cd photoshopCClinux-lightroom

# Download large files (Git LFS)
git lfs install
git lfs pull

# Make executable and run setup
chmod +x setup.sh
./setup.sh
```

### **Step 3: Choose Your Apps**

The setup menu offers:

1. **🎨 Install Photoshop CC** - Full professional editing suite
2. **📸 🆕 Install Lightroom CC** - Complete photo workflow (NEW!)
3. **📷 Install Adobe Camera Raw** - RAW processing integration
4. **⚙️ Configure Wine Settings** - Optimize performance
5. **🗑️ Uninstall** - Clean removal if needed

**That's it!** Your Adobe Creative Suite is ready in under 10 minutes.

---

## 📸 **Screenshots & Demo**

### **Photoshop CC on Linux**
![Photoshop CC running on Linux](./images/Screenshot.png)

### **Lightroom CC on Linux** 
![Lightroom CC interface](./images/lightroom.png)

### **Desktop Integration**
Both applications integrate seamlessly with your Linux desktop:
- **Desktop shortcuts** created automatically
- **Application menu entries** 
- **File associations** for PSD and XMP files

---

## 🔧 **Advanced Configuration**

### **Performance Optimization**
```bash
# Run Wine configuration
./winecfg.sh

# Set Windows version to Windows 7 for best compatibility
# In winecfg: Applications → Windows Version → Windows 7
```

### **GPU Acceleration Issues**
If Liquify or GPU features don't work:
1. **Edit → Preferences → Performance**
2. **Uncheck** "Use Graphics Processor"
3. Restart Photoshop

### **Custom Installation Paths**
```bash
# Custom installation directory
./setup.sh -d /path/to/custom/install

# With custom cache directory  
./setup.sh -d /path/to/install -c /path/to/cache
```

---

## 🌟 **Community & Support**

### **Why Choose This Repository?**
- **Active maintenance** - Regular updates and bug fixes
- **Community-driven** - Created by Linux users for Linux users
- **Comprehensive documentation** - Step-by-step guides and troubleshooting
- **Cross-platform expertise** - Tested on multiple Linux distributions

### **Get Involved**
- **⭐ Star the repository** - Show your support
- **🐛 Report issues** - Help improve the setup
- **💬 Share experiences** - Join the community discussion
- **🤝 Contribute** - Submit pull requests for improvements

---

## ⚖️ **Legal Notice**

This project provides installation scripts for Adobe Creative Cloud applications on Linux using Wine. 

**Important:** You must own legitimate licenses for Adobe Photoshop and Lightroom to use these applications legally. This setup does not bypass Adobe's licensing requirements.

The project exists to help Linux users access software they already own in a Linux environment.

---

## 🎯 **Ready to Get Creative?**

**Transform your Linux machine into a professional creative workstation!** 🚀

### **Quick Start Links:**
- [**📥 Download Repository**](https://github.com/bpawnzZ/photoshopCClinux-lightroom.git)
- [**📖 Full Documentation**](https://github.com/bpawnzZ/photoshopCClinux-lightroom#readme)  
- [**💬 Community Discussion**](https://github.com/Gictorbit/photoshopCClinux/issues/221)
- [**🐛 Report Issues**](https://github.com/bpawnzZ/photoshopCClinux-lightroom/issues)

### **What You'll Get:**
✅ **Photoshop CC v19.1.6** - Professional image editing  
✅ **Lightroom CC v7.5** - Complete photo workflow  
✅ **Adobe Camera Raw** - RAW file support  
✅ **Cross-distro compatibility** - Works on any Linux distro  
✅ **Zero external downloads** - Everything bundled  
✅ **Active community support** - Regular updates  

---

**🎨 Ready to unleash your creativity on Linux? Clone the repository and start creating!**

*Made with ❤️ for the Linux creative community*

---

*Originally published on [Medium](https://medium.com/@yourusername) • Repository: [bpawnzZ/photoshopCClinux-lightroom](https://github.com/bpawnzZ/photoshopCClinux-lightroom)*

*Tags: Linux, Adobe, Photoshop, Lightroom, Wine, Creative Suite, Open Source, Photography*