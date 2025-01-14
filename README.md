# IP Range Scanner

A simple Bash script to scan an IP range for active hosts. This script supports base IP ranges, specific IP ranges, and CIDR notation, with optional concurrency settings and the ability to save results to a file.

## Features
- Scan using a Base IP (e.g., `192.168.1`) to check from `.1` to `.254`.
- Scan a specific IP range (e.g., `192.168.1.1-192.168.1.50`).
- Scan using CIDR notation (e.g., `192.168.1.0/24`).
- Adjustable concurrency to speed up scans.
- Option to save results to a file with a timestamped name.

## Usage

### With Argument
Provide a Base IP, an IP range, or a CIDR as an argument:

```bash
./ip_range_scanner.sh 192.168.1
./ip_range_scanner.sh 192.168.1.1-192.168.1.100
./ip_range_scanner.sh 192.168.1.0/24
```

### Interactive Mode
Run the script without arguments to be prompted for input:

```bash
./ip_range_scanner.sh
```

### Example Walkthrough
1. **Base IP**:
    ```bash
    ./ip_range_scanner.sh 192.168.1
    ```
    Output:
    ```text
    Scanning range: 192.168.1.1 to 192.168.1.254
    Starting scan at 10:00:00
    192.168.1.10 is reachable
    192.168.1.20 is reachable
    Scan complete at 10:02:30. Results saved to scan_results_20250114_100230.txt.
    ```

2. **Specific Range**:
    ```bash
    ./ip_range_scanner.sh 192.168.1.1-192.168.1.50
    ```
    Output:
    ```text
    Scanning range: 192.168.1.1 to 192.168.1.50
    Starting scan at 11:00:00
    192.168.1.5 is reachable
    192.168.1.15 is reachable
    Scan complete at 11:01:10. Results saved to scan_results_20250114_110110.txt.
    ```

3. **CIDR Notation**:
    ```bash
    ./ip_range_scanner.sh 192.168.1.0/24
    ```
    Output:
    ```text
    Scanning range: 192.168.1.1 to 192.168.1.254
    Starting scan at 12:00:00
    192.168.1.25 is reachable
    192.168.1.100 is reachable
    Scan complete at 12:02:30. Results saved to scan_results_20250114_120230.txt.
    ```

### Options
- **Concurrency**:
  Set the number of concurrent scans to improve performance. For example:
  ```text
  Enter max concurrent pings (default 50): 100
  ```
  Higher values reduce scan time but may overload your system.

- **Save Results**:
  Choose whether to save results to a file. If enabled, the script saves the output in the format:
  ```
  scan_results_YYYYMMDD_HHMMSS.txt
  ```

## License
This project is licensed under the MIT License. See the LICENSE file for details.