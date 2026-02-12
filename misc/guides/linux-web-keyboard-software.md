# Guide to use web-based keyboard software (QMK/VIA forks)

Example for nuphy keyboard:

```sh
lsusb | grep -i nuphy
# Bus 003 Device 003: ID 19f5:1030 NuPhy Node 75 LP 
```

Look for the ID after "ID" - it's the first 4 characters (`19f5` in case above).
Then create udev rules:

```sh
ID=19f5
sudo echo 'KERNEL=="hidraw*", ATTRS{idVendor}=="$ID", MODE="0666"' > /etc/udev/rules.d/50-nuphy.rules
```

Then reload udev rules:

```sh
sudo udevadm control --reload-rules
sudo udevadm trigger
```

Then unplug and plug keyboard again - the end. To verify results:

```sh
ls -l /dev/hidraw*
```
