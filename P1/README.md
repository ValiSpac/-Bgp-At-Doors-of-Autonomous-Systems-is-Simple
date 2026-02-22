# P1

## 1. Dependencies

Run the provided script:

```bash
./run.sh
```

This installs:
- Docker
- GNS3 (GUI + server)
- Required networking tools

Docker images:
- `alpine`
- `frrouting/frr`

Make sure Docker is running:

```bash
sudo systemctl start docker
```

---

## 2. Create the Project in GNS3

1. Open GNS3
2. Create a **New Blank Project**
3. Name it `P1`
4. Save it inside the `P1/` folder of the repository

---

## 3. Create Docker Templates

Go to: **Edit → Preferences → Docker**

Add the two Docker images:

### Host (Alpine)
| Field | Value |
|-------|-------|
| Image | `alpine` |
| Name | `host_<login>-1` |
| Start command | `/bin/sh` |

### Router (FRR)
| Field | Value |
|-------|-------|
| Image | `frrouting/frr` |
| Name | `router_<login>` |
| Start command | `/bin/bash` |

---

## 4. Build the Topology

1. Drag both containers from the left panel
2. Connect them using **Add a Link**
3. Use `eth0` on both sides

Resulting topology:
```
host_<login>-1  <->  router_<login>
```

---

## 5. Configure the Host

Start the host → open console.

**Set hostname:**
```sh
hostname host_<login>-1
echo "host_<login>-1" > /etc/hostname
```

**Assign IP address:**
```sh
ip addr add 192.168.10.2/24 dev eth0
ip link set eth0 up
```

**Add default route:**
```sh
ip route add default via 192.168.10.1
```

---

## 6. Configure the Router

Start the router → open console.

**Enable FRR daemons:**
```bash
sed -i 's/^#*zebra=.*/zebra=yes/' /etc/frr/daemons
sed -i 's/^#*bgpd=.*/bgpd=yes/' /etc/frr/daemons
sed -i 's/^#*ospfd=.*/ospfd=yes/' /etc/frr/daemons
/usr/lib/frr/docker-start
```

**Set hostname:**
```bash
hostname router_<login>
echo "router_<login>" > /etc/hostname
```

**Set FRR router name:**
```bash
vtysh
configure terminal
hostname router_<login>
end
write
exit
```

**Assign IP address:**
```bash
ip addr add 192.168.10.1/24 dev eth0
ip link set eth0 up
```

---

## 7. Test Connectivity

From **host:**
```sh
ping 192.168.10.1
```

From **router:**
```sh
ping 192.168.10.2
```

Both sides must reply

---

## 8. Expected Result

- Correct login-based naming
- Host and router running
- `eth0` configured
- Layer-3 connectivity working
- Project saved inside `P1/`
- Portable project exported (**File -> Export portable project**)

P1 is complete when ping works and the project structure matches:

```
P1/
 ├── P1.gns3project
 ├── _<login>-1_host
 ├── _<login>-2_router
 └── P1_export.zip
```

# Notice
Configuration is what is expected for p1, however, you must make sure that the config persists for the hostname and interface

- Host:
```echo "auto eth0
iface eth0 inet static
address 192.168.10.2
netmask 255.255.255.0
gateway 192.168.10.1" > /etc/network/interfaces```

- Router:
```vtysh
configure terminal
interface eth0
ip address 192.168.10.1/24
exit
end
write
exit```