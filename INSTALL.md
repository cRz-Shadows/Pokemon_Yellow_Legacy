# Instructions

These instructions explain how to set up the tools required to build **pokemon_yellow_legacy**, including [**rgbds**](https://github.com/gbdev/rgbds), which assembles the source files into a ROM.

If you run into trouble, ask for help on IRC or Discord (see [README.md](README.md)).


## Windows 10 or 11

Download and install [**Windows Subsystem for Linux**](https://learn.microsoft.com/en-us/windows/wsl/install). Then open the **WSL terminal**.

Update WSL's software before continuing. If you chose Debian, Ubuntu, or another distribution that uses `apt-get`, then enter this command:

```bash
apt-get update && apt-get upgrade
```

WSL has its own file system that's not accessible from Windows, but Windows files *are* accessible from WSL. So you're going to want to install pokemon_yellow_legacy within Windows. You'll have to change the **current working directory** every time you open WSL.

For example, if you want to store pokemon_yellow_legacy in **C:\Users\\*\<user>*\Desktop**, enter this command:

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

Then follow the [**rgbds** install instructions](https://rgbds.gbdev.io/install#pre-built) for Windows with Cygwin to install **rgbds 1.0.4**.

**Note:** If you already have an installed rgbds older than 1.0.0, you will need to update to 1.0.0 or newer. Ignore this if you have never installed rgbds before.

Now open the **Cygwin terminal** and enter the following commands.

Cygwin has its own file system that's within Windows, at **C:\cygwin64\home\\*\<user>***. If you don't want to store pokemon_yellow_legacy there, you'll have to change the **current working directory** every time you open Cygwin.

For example, if you want to store pokemon_yellow_legacy in **C:\Users\\*\<user>*\Desktop**:

```bash
cd /cygdrive/c/Users/<user>/Desktop
```

(The Windows `C:\` drive is called `/cygdrive/c/` in Cygwin. Replace *\<user>* in the example path with your username.)

Now you're ready to [build **pokemon_yellow_legacy**](#build-pokemon_yellow_legacy).


## macOS

Install [**Homebrew**](https://brew.sh/). Follow the official instructions.

Open **Terminal** and prepare to enter commands.

Then follow the [**rgbds** instructions](https://rgbds.gbdev.io/install#pre-built) for macOS to install **rgbds 1.0.4**.

Now you're ready to [build **pokemon_yellow_legacy**](#build-pokemon_yellow_legacy).


## Linux

Open **Terminal** and enter the following commands, depending on which distro you're using.

### Debian or Ubuntu

To install the software required for **pokemon_yellow_legacy**:

```bash
sudo apt-get install make gcc git
```

Then follow the [**rgbds** instructions](https://rgbds.gbdev.io/install#building-from-source) to build **rgbds 1.0.4** from source.

### OpenSUSE

To install the software required for **pokemon_yellow_legacy**:

```bash
sudo zypper install make gcc git
```

Then follow the [**rgbds** instructions](https://rgbds.gbdev.io/install#building-from-source) to build **rgbds 1.0.4** from source.

### Arch Linux

To install the software required for **pokemon_yellow_legacy**:

```bash
sudo pacman -S make gcc git rgbds
```

If you want to compile and install **rgbds** yourself instead, then follow the [**rgbds** instructions](https://rgbds.gbdev.io/install#building-from-source) to build **rgbds 1.0.4** from source.

### Termux

To install the software required for **pokemon_yellow_legacy**:

```bash
sudo apt install make clang git sed
```

To install **rgbds**:

```bash
sudo apt install rgbds
```

If you want to compile and install **rgbds** yourself instead, then follow the [**rgbds** instructions](https://rgbds.gbdev.io/install#building-from-source) to build **rgbds 1.0.4** from source.

### Other distros

If your distro is not listed here, try to find the required software in its repositories:

- `make`
- `gcc` (or `clang`)
- `git`
- `rgbds`

If `rgbds` is not available, you'll need to follow the [**rgbds** instructions](https://rgbds.gbdev.io/install#building-from-source) to build **rgbds 1.0.4** from source.

Now you're ready to [build **pokemon_yellow_legacy**](#build-pokemon_yellow_legacy).


## Build pokemon_yellow_legacy

To download the **pokemon_yellow_legacy** source files:

```bash
git clone https://github.com/technicks89/Pokemon_Yellow_Legacy.git
cd Pokemon_Yellow_Legacy
```

This is the fork with Pick Starter mode, its CI and release tooling. The original Yellow Legacy is [cRz-Shadows/Pokemon_Yellow_Legacy](https://github.com/cRz-Shadows/Pokemon_Yellow_Legacy).

To build **pokemon_yellow_legacy.gbc**:

```bash
make
```

### Build with a local rgbds version

If you have different projects that require different versions of `rgbds`, it might not be convenient to install rgbds 1.0.4 globally. Instead, you can put its files in a directory within pokemon_yellow_legacy, such as `pokemon_yellow_legacy/rgbds-1.0.4/`. Then specify it when you run `make`:

```bash
make RGBDS=rgbds-1.0.4/
```
