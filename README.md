# Cloudflare Dynamic DNS (DDNS) Updater

This script facilitates the automatic updating of a DNS record on Cloudflare for users with a dynamic public IP address rather than a static one. Dynamic IPs change periodically, which can be problematic when you are hosting websites, applications, or services that rely on DNS. Using this script, you can ensure your domain always resolves to the correct IP address, making it ideal for home servers, IoT devices, or any instance where a fixed public IP is unavailable.

## Why Cloudflare?
Cloudflare provides an API that allows programmatic modifications to DNS records, making it an excellent option for automating DNS updates when your public IP changes.

## Features
- Checks if a DNS record exists for your domain; if not, it automatically creates one.
- Updates the DNS record only when the public IP changes, minimizing unnecessary API calls.
- Simple setup: configure the script initially with your API key, email address, and other necessary parameters.

## Getting Started

### Prerequisites
- A Cloudflare account and access to your DNS settings.
- Your API key, Zone ID, and the DNS record you wish to update.
- JQ installed on your system for processing JSON data.

### Install JQ
Before running the script, you need to install JQ, which is used to parse JSON data. You can install JQ on most Linux distributions via the package manager.

For Ubuntu/Debian:
```
sudo apt-get install jq
```

For Red Hat/CentOS:
```
sudo yum install jq
```

For MacOS, using Homebrew:
```brew install jq```

## Setup
Locate Your Zone ID:

Log in to your Cloudflare dashboard.
Select the site you want to manage.
The Zone ID is displayed on the right sidebar under the "API" section.

Configuration:
Run the script for the first time. You will be prompted to enter:

- Your Cloudflare API Key
- Your email address associated with Cloudflare
- The Zone ID for your domain
- The DNS name you wish to update (e.g., iot.example.com)


### Making the Script Executable
Ensure the script can be executed by running: <br>
```chmod +x CloudFlareUpdater.sh```

### Automate the Script
To check for a new IP address and update the DNS record if necessary, every minute, use crontab: <br>
``` crontab -e ```

Add the following line to run the script every minute: <br>
``` * * * * * /path/to/CloudFlareUpdater.sh ```


This will execute the script at the start of every minute, checking if your public IP address has changed and updating the DNS record accordingly.

## Conclusion

With this setup, your domain will always point to the correct IP, even when your ISP changes your public IP address. This automation not only saves time but also reduces the downtime that might be caused by IP changes.

For more information on using the Cloudflare API, refer to the Cloudflare API documentation.


