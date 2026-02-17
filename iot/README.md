# IoT / Home Automation Stack

Home sensors, MQTT broker, and automation.

## Services

**Docker** (docker-compose.yml):
- **Mosquitto** - MQTT broker (port 1883)
- **Zigbee2MQTT** - Zigbee coordinator (port 8080)

**Systemd** (native):
- **inkbird-monitor** - CO2 sensor (BLE)

## Deploy

```bash
cd /srv/selfhost/iot

# Create Mosquitto password file
mosquitto_passwd -c mosquitto/pwfile username

# Start services
docker compose up -d

# Install inkbird-monitor (if using)
cd inkbird-monitor && sudo ./install.sh
systemctl start inkbird-monitor
```

## Configuration

### Zigbee Adapter
Update `docker-compose.yml` device path:
```yaml
devices:
  - /dev/serial/by-id/YOUR-ADAPTER:/dev/ttyACM0
```

Find yours: `ls -la /dev/serial/by-id/`

### Mosquitto
Password file: `mosquitto/pwfile` (not in git)

## Storage

- Zigbee2MQTT: `/media/simple/zigbee2mqtt`

## TODO

- [ ] Add Home Assistant
- [ ] Add kostal2influx (solar inverter)
- [ ] Document MQTT topics structure
