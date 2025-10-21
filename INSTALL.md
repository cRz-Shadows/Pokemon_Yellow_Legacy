# Instructions

These instructions explain how to set up the tools required to build **pokeyellow**, including [**rgbds**](https://github.com/gbdev/rgbds), which assembles the source files into a ROM.

If you run into trouble, ask for help on IRC or Discord (see [README.md](README.md)).

> [!NOTE]
> The latest release from RGBDS is **incompatible with this repository**. You will want to use **specifically version 0.6.1**. Each environment below contains a link to instructions on installing RGBDS for that system, or check out the [github release](https://github.com/gbdev/rgbds/releases/tag/v0.6.1) to install on your own.


## Windows 10

Download and install [**Windows Subsystem for Linux**](https://docs.microsoft.com/en-us/windows/wsl/install-win10). Then open the **WSL terminal**.

Update WSL's software before continuing. If you chose Debian, Ubuntu, or another distribution that uses `apt-get`, then enter this command:

```bash
apt-get update && apt-get upgrade
```

WSL has its own file system that's not accessible from Windows, but Windows files *are* accessible from WSL. So you're going to want to install pokeyellow within Windows. You'll have to change the **current working directory** every time you open WSL.

For example, if you want to store pokeyellow in **C:\Users\\*\<user>*\Desktop**, enter this command:

```bash
cd /mnt/c/Users/<user>/Desktop
```

(The Windows `C:\` drive is called `/mnt/c/` in WSL. Replace *\<user>* in the example path with your username.)

If this works, then follow [the instructions for **Linux**](#linux) below for whatever distribution you installed for WSL.

Otherwise, continue reading below for [the older Windows instructions](#windows).


## Windows

Download [**Cygwin**](http://cygwin.com/install.html): **setup-x86_64.exe** for 64-bit Windows, **setup-x86.exe** for 32-bit.

Run setup and leave the default settings. At the "**Select Packages**" step, choose to install the following, all of which are in the "**Devel**" category:

- `make`
- `git`
- `gcc-core`

Double click on the text that says "**Skip**" next to each package to select the most recent version to install.

Then follow the [**rgbds** install instructions](https://rgbds.gbdev.io/install/windows) for Windows with Cygwin to install **rgbds 0.6.1**.

**Note:** If you already have an installed rgbds older than 0.6.0, you will need to update to 0.6.0 or 0.6.1. Ignore this if you have never installed rgbds before. If a version newer than 0.6.1 does not work, try downloading 0.6.1.

Now open the **Cygwin terminal** and enter the following commands.

Cygwin has its own file system that's within Windows, at **C:\cygwin64\home\\*\<user>***. If you don't want to store pokeyellow there, you'll have to change the **current working directory** every time you open Cygwin.

For example, if you want to store pokeyellow in **C:\Users\\*\<user>*\Desktop**:

```bash
cd /cygdrive/c/Users/<user>/Desktop
```

(The Windows `C:\` drive is called `/cygdrive/c/` in Cygwin. Replace *\<user>* in the example path with your username.)

Now you're ready to [build **pokeyellow**](#build-pokeyellow).


## macOS

Install [**Homebrew**](https://brew.sh/). Follow the official instructions.

Open **Terminal** and enter this command:

```bash
brew install make git gcc
```

Then follow the [**rgbds** instructions](https://rgbds.gbdev.io/install/macos) for macOS to install **rgbds 0.6.1 from prebuilt binaries**.

> [!WARNING]
> Brew [has rgbds](ttps://formulae.brew.sh/formula/rgbds), but it is _a much higher version_ and throws an error when building this repository. You must use the prebuilt binaries for **0.6.1** instead


Now you're ready to [build **pokeyellow**](#build-pokeyellow).


## Linux

Open **Terminal** and enter the following commands, depending on which distro you're using.

### Debian or Ubuntu

To install the software required for **pokeyellow**:

```bash
sudo apt-get install make gcc git
```

Then follow the [**rgbds** instructions](https://rgbds.gbdev.io/install/source) to build **rgbds 0.6.1** from source.

### OpenSUSE

To install the software required for **pokeyellow**:

```bash
sudo zypper install make gcc git
```

Then follow the [**rgbds** instructions](https://rgbds.gbdev.io/install/source) to build **rgbds 0.6.1** from source.

### Arch Linux

To install the software required for **pokeyellow**:

```bash
sudo pacman -S make gcc git
```

Then follow the [**rgbds** instructions](https://rgbds.gbdev.io/install/source) to build **rgbds 0.6.1** from source.

> [!WARNING]
> Arch has a [package for rgbds](https://archlinux.org/packages/extra/x86_64/rgbds/), but it is _a much higher version_ and throws an error when building this repository.

### Termux

To install the software required for **pokeyellow**:

```bash
sudo apt install make clang git sed
```

To install **rgbds**:

```bash
sudo apt install rgbds
```

If you want to compile and install **rgbds** yourself instead, then follow the [**rgbds** instructions](https://rgbds.gbdev.io/install/source) to build **rgbds 0.6.1** from source.

### Other distros

If your distro is not listed here, try to find the required software in its repositories:

- `make`
- `gcc` (or `clang`)
- `git`
- `rgbds`

If `rgbds` is not available, you'll need to follow the [**rgbds** instructions](https://rgbds.gbdev.io/install/source) to build **rgbds 0.6.1** from source.

Now you're ready to [build **pokeyellow**](#build-pokeyellow).


## Build pokeyellow

To download the **pokeyellow** source files:

```bash
git clone https://github.com/cRz-Shadows/Pokemon_Yellow_Legacy.git
cd Pokemon_Yellow_Legacy
```

To build **pokeyellow.gbc**:

```bash
make
```

### Build with a local rgbds version

If you have different projects that require different versions of `rgbds`, it might not be convenient to install rgbds 0.6.1 globally. Instead, you can put its files in a directory within pokeyellow, such as `pokeyellow/rgbds-0.6.1/`. Then specify it when you run `make`:

```bash
make RGBDS=rgbds-0.6.1/
```
