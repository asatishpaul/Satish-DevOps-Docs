# Linux Basics and Advanced Topics

## Basics of Navigating the File System
- **`ls`**: Lists the contents of the current directory.
- **`cd`**: Changes the current directory. Example: `cd Documents` moves to the "Documents" directory.
- **`pwd`**: Prints the current working directory, showing your location in the file system.

## File Manipulation Commands
- **`mkdir`**: Creates a new directory. Example: `mkdir my_folder` creates a directory named "my_folder".
- **`touch`**: Creates a new empty file or updates the timestamp of an existing file. Example: `touch my_file.txt` creates a new text file named "my_file.txt".
- **`rm`**: Removes files or directories. Be cautious with this command, as it permanently deletes files. Example: `rm my_file.txt` deletes the file "my_file.txt".
- **`cp`**: Copies files or directories. Example: `cp file1.txt file2.txt` copies "file1.txt" to "file2.txt".
- **`mv`**: Moves or renames files or directories. Example: `mv old_file.txt new_file.txt` renames "old_file.txt" to "new_file.txt".

## Basic Text Editing
- **`nano`**: A simple and user-friendly text editor. Use `nano filename` to open a file in nano for editing. It provides on-screen instructions for basic operations.
- **`vim`**: A powerful and customizable text editor with a steeper learning curve. Use `vim filename` to open a file in vim. Press `i` to enter insert mode for editing, `Esc` to exit insert mode, and `:wq` to save and exit.

## User Management

### Adding Users
- **`useradd`**: Adds a new user account to the system. Syntax: `useradd username`.
- **`adduser`**: A user-friendly interface for adding users, often with additional configuration options.

### Deleting Users
- **`userdel`**: Deletes a user account from the system. Syntax: `userdel username`.
- **`deluser`**: A user-friendly interface for deleting users, often handling additional cleanup tasks.

### Modifying User Attributes
- **`usermod`**: Modifies user account attributes, such as username, home directory, or group membership. Syntax: `usermod options username`.

### Changing User Passwords
- **`passwd`**: Allows users to change their passwords. As an administrator, you can use it to change another user's password by typing `passwd username`.

### Viewing User Information
- **`id`**: Displays user and group IDs, as well as additional information about a specified user. Syntax: `id username`.
- **`finger`**: Provides detailed user information, including login name, real name, terminal, and more. Syntax: `finger username`.

### Switching Users
- **`su`**: Allows you to switch to another user account or execute commands as another user. Syntax: `su username`.

### Listing Users
- **`who`**: Displays information about users who are currently logged in.
- **`w`**: Provides detailed information about currently logged-in users, including what they're doing.

## System Information

### Displaying Basic System Information
- **`uname`**: Displays system information such as kernel name, network node hostname, kernel release, kernel version, machine hardware name, and processor type. Example: `uname -a` displays all available system information.

### Viewing System Hardware Information
- **`lscpu`**: Provides information about the CPU architecture and processor details.
- **`lshw`**: Lists detailed hardware configuration, including memory, processor, disk, and network information. Requires root privileges or sudo access.
- **`lspci`**: Shows information about PCI buses and connected devices.
- **`lsusb`**: Displays information about USB buses and connected devices.
- **`lsblk`**: Lists block devices, such as hard drives and partitions, along with their mount points.

### Monitoring System Performance
- **`top`**: Displays dynamic real-time information about system processes, CPU usage, memory usage, and more.
- **`htop`**: An interactive process viewer that provides an overview of system resources and allows for easy process management.

### Checking System Memory Usage
- **`free`**: Displays the amount of free and used memory in the system, including total, used, and free memory, as well as buffers and cache.
- **`vmstat`**: Reports information about processes, memory, paging, block IO, traps, and CPU activity.

### Checking Disk Usage
- **`df`**: Displays disk space usage for all mounted filesystems.
- **`du`**: Estimates disk usage for directories and files.

### Viewing Network Information
- **`ifconfig` or `ip addr`**: Shows network interface information, including IP addresses, MAC addresses, and network configuration.
- **`netstat`**: Displays network connections, routing tables, interface statistics, masquerade connections, and multicast memberships.
- **`ss`**: Another utility to investigate sockets, displaying more detailed information than `netstat`.

## Package Management

### Debian/Ubuntu-based Systems (using APT)
- **`apt update`**: Updates the local package index to reflect the latest changes made in the repositories.
- **`apt upgrade`**: Upgrades all installed packages to their latest versions.
- **`apt install <package>`**: Installs the specified package.
- **`apt remove <package>`**: Removes the specified package, along with its configuration files.
- **`apt purge <package>`**: Completely removes the specified package, including its configuration files.
- **`apt search <keyword>`**: Searches for packages matching the specified keyword.
- **`apt list --installed`**: Lists all installed packages.

### Red Hat/CentOS-based Systems (using YUM or DNF)
- **`yum update` or `dnf update`**: Updates all installed packages to their latest versions.
- **`yum install <package>` or `dnf install <package>`**: Installs the specified package.
- **`yum remove <package>` or `dnf remove <package>`**: Removes the specified package.
- **`yum search <keyword>` or `dnf search <keyword>`**: Searches for packages matching the specified keyword.
- **`yum list installed` or `dnf list installed`**: Lists all installed packages.

### Common Package Management Commands for All Systems
- **`apt-cache search <keyword>`**: Searches for packages matching the specified keyword in Debian/Ubuntu-based systems.
- **`rpm -qa`**: Lists all installed packages in Red Hat/CentOS-based systems.
- **`dpkg -l`**: Lists all installed packages in Debian/Ubuntu-based systems.

## File Management
- **`find`**: Searches for files and directories in a directory hierarchy based on various criteria such as name, size, or permissions.
- **`grep`**: Searches for patterns in files or standard input. It's commonly used to filter lines containing a specific pattern.
- **`awk`**: A versatile text processing tool that operates on lines of input and can perform actions based on patterns.
- **`sed`**: A stream editor used to perform text transformations on an input stream. It's often used for search and replace operations.
- **`tar`**: Archives files into a single file (often called a "tarball") and optionally compresses them.
- **`gzip`**: Compresses files using the gzip compression algorithm. It replaces the original file with a compressed version.
- **`zip`**: Compresses files into a zip archive, which can include multiple files and directories.

## Networking

### Network Configuration
- **`ifconfig` or `ip addr`**: Displays or configures network interfaces, including IP addresses, MAC addresses, and network configuration.
- **`iwconfig`**: Configures wireless network interfaces.

### Network Connectivity
- **`ping`**: Tests connectivity to a remote host by sending ICMP echo request packets.
- **`traceroute` or `traceroute6`**: Traces the route packets take to reach a destination host.
- **`mtr`**: Combines the functionality of `ping` and `traceroute` to provide real-time network diagnostics.
- **`netcat` or `nc`**: Reads and writes data across network connections, often used for debugging and network exploration.
- **`telnet`**: Allows users to communicate with remote systems using the Telnet protocol.
- **`ssh`**: Securely connects to a remote system using the SSH protocol.

### DNS Configuration and Resolution
- **`dig`**: A versatile DNS lookup utility for querying DNS servers and retrieving DNS records.
- **`nslookup`**: Another DNS lookup utility for querying DNS servers and resolving domain names.

### Network Services and Ports
- **`netstat`**: Displays network connections, routing tables, interface statistics, masquerade connections, and multicast memberships.
- **`ss`**: Another utility to investigate sockets, providing more detailed information than `netstat`.
- **`nmap`**: A powerful network scanning tool for discovering hosts and services on a network.

### Network Diagnostics
- **`arp`**: Displays or manipulates the IP-to-MAC address translation tables.
- **`tcpdump`**: Captures and analyzes network packets in real-time

.

## System Services and Daemons

### Managing Services with Systemd
- **`systemctl`**: The primary command for managing services on a system running the `systemd` init system.
    - **Start a service**: `systemctl start <service>`
    - **Stop a service**: `systemctl stop <service>`
    - **Restart a service**: `systemctl restart <service>`
    - **Enable a service to start at boot**: `systemctl enable <service>`
    - **Disable a service from starting at boot**: `systemctl disable <service>`
    - **Check the status of a service**: `systemctl status <service>`

### Managing Services with SysVinit
- **`service`**: A command for managing services on a system running the `SysVinit` init system.
    - **Start a service**: `service <service> start`
    - **Stop a service**: `service <service> stop`
    - **Restart a service**: `service <service> restart`
    - **Check the status of a service**: `service <service> status`

### Managing Cron Jobs

#### Listing Cron Jobs
- **`crontab -l`**: Lists the cron jobs for the current user.
- **`crontab -u username -l`**: Lists the cron jobs for a specific user.

#### Editing Cron Jobs
- **`crontab -e`**: Edits the cron jobs for the current user.
- **`crontab -u username -e`**: Edits the cron jobs for a specific user.

### Viewing System Logs
- **`journalctl`**: Views and queries system logs managed by `systemd`. It can be used to view logs for specific services or time periods.
- **`dmesg`**: Displays kernel messages, often used to troubleshoot hardware or boot-related issues.

## SSH (Secure Shell)

### Connecting to a Remote Server
- **`ssh`**: Securely connects to a remote server. Syntax: `ssh user@hostname`. 

### Managing SSH Keys
- **`ssh-keygen`**: Generates a new SSH key pair.
- **`ssh-copy-id`**: Copies the public SSH key to a remote server's authorized keys.

### Using SSH Configurations
- **`~/.ssh/config`**: A configuration file where you can define shortcuts and specific settings for SSH connections.

## Disk Management

### Viewing Disk Usage
- **`df`**: Displays disk space usage for all mounted filesystems. Example: `df -h` shows human-readable output.
- **`du`**: Estimates file space usage for directories and files. Example: `du -sh /path/to/directory` gives a summary of the disk usage of a directory.

### Partitioning Disks
- **`fdisk`**: A command-line utility for managing disk partitions.
- **`parted`**: A more advanced disk partitioning tool that supports a wider range of partition types and sizes.

### Mounting and Unmounting Filesystems
- **`mount`**: Mounts a filesystem. Syntax: `mount /dev/sdXY /mnt/directory`.
- **`umount`**: Unmounts a filesystem. Syntax: `umount /mnt/directory`.

### Checking and Repairing Filesystems
- **`fsck`**: Checks and repairs Linux filesystems. Syntax: `fsck /dev/sdXY`.

### Creating and Managing Filesystem Types
- **`mkfs`**: Creates a filesystem on a partition. Example: `mkfs.ext4 /dev/sdXY` creates an ext4 filesystem.

## Security

### File Permissions
- **`chmod`**: Changes file permissions. Syntax: `chmod 755 filename` sets read, write, and execute permissions.
- **`chown`**: Changes file owner and group. Syntax: `chown user:group filename`.

### Firewall Management
- **`ufw`**: A user-friendly firewall management tool. Example: `ufw enable` enables the firewall.
- **`iptables`**: A more advanced firewall management tool for configuring packet filtering rules.

### User and Group Management
- **`useradd`**: Adds a new user.
- **`usermod`**: Modifies user attributes.
- **`groupadd`**: Adds a new group.

## Bash Scripting

### Basic Script Structure
```bash
#!/bin/bash
# This is a comment
echo "Hello, World!"
```

### Variables and Conditionals
```bash
#!/bin/bash
# Variables
name="John"
# Conditionals
if [ "$name" == "John" ]; then
  echo "Hello, John!"
else
  echo "Hello, stranger!"
fi
```

### Loops
```bash
#!/bin/bash
# For loop
for i in {1..5}; do
  echo "Welcome $i times"
done
```

### Functions
```bash
#!/bin/bash
# Function definition
greet() {
  echo "Hello, $1!"
}
# Function call
greet "Alice"
```

### Working with Files
```bash
#!/bin/bash
# Reading a file line by line
while read line; do
  echo $line
done < "file.txt"
```

### Error Handling
```bash
#!/bin/bash
# Error handling with exit codes
if [ -f "$1" ]; then
  echo "File exists."
else
  echo "File does not exist."
  exit 1
fi
```


 or modifications!
