# Asahi openSUSE port

Currently I'm working on openSUSE port for Apple Silicon machines.

## Current progress

Look at `dev` branch to see the progress.

## TODO list

- [ ] Boot openSUSE from USB device with pre-built (by hands) image
  - [x] Build image
  - [ ] Test what works or not
- [ ] Prepare installer
  - [ ] Prepare OBS repos (or just repos) with necessary packages (kernel, m1n1, u-boot, asahi-scripts, etc.)
  - [ ] Prepare basic (cli only, DE) rootfs images (and scripts to build them)
  - [ ] Build installer (for use like general Asahi installer, ex. `curl https://ivabus.dev/suse | sh`)
  - [ ] Provide all types of openSUSE (Leap, Tumbleweed, Leap Micro, MicroOS) for installation.
  - [ ] Test every type of installation
  - [ ] Document things
  - [ ] First release
- [ ] Integrate with YaST
  - [ ] Make some scripts to let openSUSE be installed, using USB drive and on-device U-Boot
  - [ ] Somehow tell YaST to not overwrite ESP volume
  - [ ] Second release (with YaST installer)

## Contact me

Email: <ivabus@ivabus.dev>
