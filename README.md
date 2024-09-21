# docker-backup-toolkit

---

- [Installation](#-installation)
- [Usage](#-usage)
  - [backup](#backup)
  - [restore](#restore)
- [Contributing](#-contributing)
- [License](#license)

## 📦 Installation

##### Prerequisites

- [docker](https://docs.docker.com/get-docker/)
- [bash](https://www.gnu.org/software/bash/)

```bash
# Work in progress
```

## 📖 Usage

```text
Usage: toolkit.sh [options] [command]

Docker volume backup and restore utility
Author: @shahradelahi, https://github.com/shahradelahi

Options:
  -V, --version                         output the version number
  -h, --help                            display help for command

Commands:
  backup [options]                      backup from volume or volumes of a container
  restore [options]                     restore backup to volume
  help [command]                        display help for command
```

### backup

This command is used for backup a container or volume to a tar file.

#### Options

```txt
Usage: toolkit.sh backup [options]

backup from volume or volumes of a container

Options:
  -c, --container <container-name>      backup all volumes of a container
  -v, --volume <volume-name>            backup a single volume
  -h, --help                            display help for command
```

###### Examples

```bash
# Backup from all volumes of a container
./toolkit.sh backup --container my-container

# Backup from a single volume
./toolkit.sh backup --volume my-volume
```

### restore

```text
Not implemented yet
```

## 🤝 Contributing

Want to contribute? Awesome! To show your support is to star the project, or to raise issues on [GitHub](https://github.com/shahradelahi/docker-backup-toolkit).

Thanks again for your support, it is much appreciated!

### License

[MIT](LICENSE) © [Shahrad Elahi](https://github.com/shahradelahi)
