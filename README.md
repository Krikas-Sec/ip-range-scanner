# IP Range Scanner

A simple Bash script to scan an IP range for active hosts.

## Usage
### With Argument
Run the script with the base IP address as an argument:
```bash
./ip_range_scanner.sh 192.168.1
```
Interactive Mode
If no argument is provided, the script will prompt for the base IP address:

```bash
./ip_range_scanner.sh
```
Example Output
```bash
Scanning IP range: 192.168.1.1 - 192.168.1.254
192.168.1.1
192.168.1.10
192.168.1.20
...
Scan complete.
```
License
This project is licensed under the MIT License.
