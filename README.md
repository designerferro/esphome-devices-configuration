# ESPHome Devices Configuration

Repository containing the ESPHome configurations I use to automate my home with Home Assistant.

This project centralizes firmware definitions, reusable templates, and device configurations for ESP8266 and ESP32-based devices, including Sonoff and Shelly hardware.

The repository reflects my practical migration from vendor firmware to ESPHome, giving me full local control, tighter Home Assistant integration, improved reliability, and greater flexibility for automations.

Part of this journey was documented in the article: https://pouparmelhor.com/praticas/automatizar-a-casa-com-esphome-desta-vez-com-shelly/

## Why ESPHome

I started using ESPHome to replace closed ecosystems and cloud-dependent integrations with a local-first approach.

Today, ESPHome powers several parts of my home automation stack, including:

- Lighting control
- Roller shutters
- Environmental sensors
- Energy monitoring
- Smart switches and relays
- OTA-managed IoT devices

Combined with Home Assistant, ESPHome provides a reliable and fully customizable smart home platform.

## Technologies

- ESPHome
- Home Assistant
- ESP8266 / ESP32
- Shelly
- Sonoff

## Devices

### Shelly

- Shelly 1
- Shelly 2.5
- Shelly Dimmer 2

### ESP8266

- ESP8266 with DHT22 sensor

## Repository Structure

```text
.
├── sonoff/
├── shelly/
├── esp8266/
├── common/
├── packages/
├── secrets.example.yaml
└── README.md

## Security Audit Script

This repository may include a helper script named `sec-audit.sh`.

The purpose of this script is to perform a lightweight security and hygiene audit of the repository, helping identify common issues before configurations are deployed to production devices.

Typical checks may include:

- Detection of hardcoded credentials
- Validation of `secrets.yaml` exposure
- Search for plaintext API keys or passwords
- Verification of ignored files
- Detection of unsafe Wi-Fi or OTA configurations
- Basic YAML consistency checks

### Usage

```bash
./sec-audit.sh

Recommended Usage

### Run the script before:

* committing changes
* publishing configurations
* flashing production devices
* opening pull requests

### Notes

The script is intended as a simple safeguard layer and does not replace:

* proper secret management
* network segmentation
* firewall rules
* Home Assistant hardening
* regular firmware updates

# Requirements

* Home Assistant
* ESPHome Add-on or ESPHome CLI
* Python 3.x (CLI usage)

# Installation

Clone repository:

git clone https://github.com/designerferro/esphome-devices-configuration.git
cd esphome-devices-configuration

## Create secretes.yaml

wifi_ssid: "SSID"
wifi_password: "PASSWORD"
api_encryption_key: "KEY"
ota_password: "PASSWORD"

## Compile firmware
esphome compile shelly/shelly25.yaml

## Upload firmware
esphome upload shelly/shelly25.yaml