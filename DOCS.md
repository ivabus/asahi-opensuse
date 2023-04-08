# Docs

## Repository

Use `scripts/00_build_repo.sh` to completely build rpm-md repo and packages for it (spec files from `specs/` and kernel). Repo will be saved at `repo`.


## Image building

Change domain for rpm-md asahi repo in `kiwi/config.xml` and then run (from `kiwi` dir)

```
# kiwi-ng --type=oem --profile=$distro-$edition --color-output system build --description ./ --target-dir ./outdir-$distro-$edition
# ./make-installer.sh outdir-$distro-$edition/asahi-opensuse.aarch64-0.0.1.raw $distro-$edition.zip
```

Where `$distro` is `Leap` or `Tumbleweed`, and `$edition` if `JeOS` or `KDE` or `GNOME` or `XFCE`

Usage `kiwi/build-all.sh` to create all the images (listed below) for the installer.

### All possible images (for now)

- Tumbleweed-JeOS
- Tumbleweed-KDE
- Tumbleweed-GNOME
- Tumbleweed-XFCE
- Leap-JeOS
- Leap-KDE
- Leap-GNOME
- Leap-XFCE