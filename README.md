# Server Status Report Script (server_status_report.sh)

![GitHub forks](https://img.shields.io/github/forks/zuul/Server-Status-Reporter?style=social)
![GitHub Repo stars](https://img.shields.io/github/stars/zuul/Server-Status-Reporter?style=social)

## 🎯 Overview

`server_status_report.sh` is a simple, portable Bash shell script designed to quickly assess the health and load of a Linux server. It gathers key metrics for disk space, system uptime, CPU/RAM utilization, and the status of critical services, then compiles the data into a readable report that can be output to the console or sent via email.

## ✨ Features

* **System Load:** Reports CPU load averages (1m, 5m, 15m).

* **RAM Usage:** Reports Total, Used, and Free RAM, along with a visual progress bar indicating utilization percentage (calculated using pure integer shell math, requiring no external tools like `bc`).

* **Disk Space:** Reports total capacity, used space, and available space for the root filesystem (`/`).

* **Service Health:** Checks the active status of predefined core services (`postfix`, `dovecot`, `mysql`, `apache2`).

* **Flexible Output:** Supports output to the console or sending a plain-text email report.

* **Mailer Choice:** Supports both `mail` (via `mailx`) and `sendmail`.

## 🛠️ Dependencies

This script relies on standard Linux utilities that are typically pre-installed:

* `df`

* `free`

* `uptime`

* `awk`, `grep`, `sed`

* `systemctl` or `service` (for checking service status)

* **For email output:** `mail` (from `mailx` or equivalent) OR `sendmail` must be installed and configured.

## ⚙️ Installation and Setup

To use the script on your Linux server, follow these steps:

1. **Option A: Manual Copy/Paste**

   * Create a new file (e.g., `server_status_report.sh`) on your server.

   * Paste the script content into the file.

2. **Option B: CLI Download (Recommended)**

   * Download the raw file directly with [curl](https://man7.org/linux/man-pages/man1/curl.1.html):

     ```shell
     curl -LJO https://raw.githubusercontent.com/zuul/Server-Status-Reporter/main/server_status_report.sh
     ```
     OR using [wget](https://man7.org/linux/man-pages/man1/wget.1.html):
     ```shell
     wget https://raw.githubusercontent.com/zuul/Server-Status-Reporter/main/server_status_report.sh
     ```

3. **Make it executable:** Give the script the necessary permissions to run.

    ```shell
    chmod +x server_status_report.sh
    ```

4. **Optional: Install Mailer:** Ensure you have a Mail Transfer Agent (MTA) and a mail utility (`mailx` or `sendmail`) configured if you plan to use the email output mode.

## 🚀 Usage

### Execution Syntax

The script uses named arguments. `--recipient` is mandatory.

```shell
bash server_status_report.sh --recipient <email> [--output <mode>] [--mailer <program>]
```

### Arguments

##### `--recipient <email>` (Mandatory)
| Option | |
| :--- | :--- |
| Description | The email address where the report should be sent. |
| Options | *Email Address* |
| Default | None |

##### `--output <mode>` (Optional)
| Detail | |
| :--- | :--- |
| Description | Determines where the report is displayed. |
| Options | `email` (send via MTA), `console` (print to screen) |
| Default | `email` |

##### `--mailer <program>` (Optional)
| Detail | |
| :--- | :--- |
| Description | Specifies the email client/MTA to use for sending. |
| Options | `mail`, `sendmail` |
| Default | `sendmail` |

### Examples

1. Send a report to a system administrator (using default `sendmail`):

    ```shell
    bash server_status_report.sh --recipient sysadmin@mycompany.com
    ```

2. Print the report to the console for testing (useful for cron jobs):

    ```shell
    bash server_status_report.sh --recipient test@local.host --output console
    ```

3. Send a report using the `mailx` utility:

    ```shell
    bash server_status_report.sh --recipient alerts@mycompany.com --mailer mail
    ```

## ⚙️ Configuration

To customize the core services checked by the script, edit the following line near the top of the `server_status_report.sh` file:

```shell
SERVICES=("postfix" "dovecot" "mysql" "apache2")
```

Replace the service names with the exact names used by your distribution (e.g., `httpd` instead of `apache2`).