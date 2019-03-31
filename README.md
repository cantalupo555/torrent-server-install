# torrent-server-install

With this script you will install:
- **ruTorrent**
- **qBittorrent**
- **proFTPd**
- ~~**vnStat**~~

First, update the system:

```bash
sudo apt-get update
sudo apt-get dist-upgrade -y
```

Get the script and make it executable:

```bash
wget https://raw.githubusercontent.com/cantalupo555/torrent-server-install/master/torrent-server-install.sh
chmod +x torrent-server-install.sh
```

Then run it:

`./torrent-server-install.sh`

## Compatibility

The script supports these OS and architectures:

|              | i386 | amd64 | armhf | arm64 |
| ------------ | ---- | ----- | ----- | ----- |
|   Debian 8   |   ❔  |  ❔  |   ❌   |   ❌  |
|   Debian 9   |   ❔  |  ❔  |   ❌   |   ❌  |
| Ubuntu 16.04 |   ✅  |  ✅  |   ❌   |   ❌  |
| Ubuntu 18.04 |   ✅  |  ✅  |   ❌   |   ❌  |

If you have found a problem, [click here](https://github.com/cantalupo555/torrent-server-install/issues/new).