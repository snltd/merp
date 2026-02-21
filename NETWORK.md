INTERNET
                            │
               ┌────────────┴────────────┐
               │  HOME: 192.168.1.1      │
               │  EC2:  VPC router+IGW   │
               └────────────┬────────────┘
                            │
                  ┌─────────┴─────────┐
                  │   physical NIC    │
                  │  HOME: e1000g0    │
                  │  EC2:  xnf0/ena0  │
                  └─────────┬─────────┘
                            │
                  vnic_router_ext
                            │
                   ┌────────┴────────┐
                   │   z-router      │  ip_forwarding=1
                   │─────────────────│
                   │ vnic0  real NIC │  DHCP/static
                   │ vnic1  stub1    │  10.99.0.1/24
                   │ vnic2  stub2    │  192.168.10.1/24
                   └────┬───────┬───┘
                        │       └──────────────────────────────┐
                        │ stub1                                 │ stub2
                        │ 10.99.0.0/24                         │ 192.168.10.0/24
           ┌────────────┼──────────┐                           │
           │            │          │          ┌────────────────┼──────────────────────┐
           │            │          │          │                │                      │
    ┌──────┴──┐   ┌──────┴──┐      │   ┌──────┴──────┐  ┌─────┴────┐          ┌──────┴──┐
    │  z-nat  │   │  z-web  │      │   │ z-gurp      │  │z-client  │          │z-bridge │
    │─────────│   │─────────│      │   │─────────────│  │──────────│          │─────────│
    │ipf+ipnat│   │nginx    │      │   │config server│  │test      │          │bridge   │
    │SNAT     │   │SMF svc  │      │   │serves ALL   │  │client    │          │peer     │
    │         │   │         │      │   │other zones  │  │          │          │         │
    │─────────│   │─────────│      │   │─────────────│  │──────────│          │─────────│
    │v0 stub1 │   │v0 stub1 │      │   │v0 stub2 ONLY│  │v0 stub2  │          │v0 stub2 │
    │10.99.0.2│   │10.99.0.10      │   │192.168.10.5 │  │.10.20    │          │.10.30   │
    │v1 stub2 │   │v1 stub2 │      │   │NO stub1     │  │v1 testbr │          │v1 testbr│
    │.10.2/24 │   │.10.10/24│      │   │NO stub0     │  │.50.2     │          │.50.3    │
    └─────────┘   └─────────┘      │   │NO ext NIC   │  └────┬─────┘          └────┬───┘
                                   │   └─────────────┘       │                     │
                                   │                 ╔════════╪═════════════════════╪════╗
                                   │                 ║  testbr0  [dladm bridge]         ║
                                   │                 ║  172.16.50.0/24  (L2)            ║
                                   │                 ╚═══════════════════════════════════╝
                                   │
                       ════════════╧═══════════════════════════════════════════════
                        stub2 bus — ALL zones have a VNIC here
                        z-gurp is stub2-only: reachable by everyone,
                        reachable from nowhere external
                       ═════════════════════════════════════════════════════════════


ZONE SUMMARY (6 zones)
──────────────────────────────────────────────────────────────────────
z-router    v0:real-NIC  v1:stub1  v2:stub2   ip_forwarding=1
z-nat       v0:stub1     v1:stub2             SNAT+DNAT, ipf rules
z-web       v0:stub1     v1:stub2             nginx, SMF service
z-gurp      v0:stub2     (ONLY)               config server ← NEW
z-client    v0:stub2     v1:testbr0           test client, default-gw→z-nat
z-bridge    v0:stub2     v1:testbr0           bridge peer, L2 tests


z-gurp SPECIFICS
──────────────────────────────────────────────────────────────────────
IP              192.168.10.5/24  (stub2 only)
gateway         192.168.10.1  (z-router, for DNS/NTP if needed)
reachable from  every zone via stub2 — no exceptions
reachable from  nowhere external (no stub1, no real NIC)
serves          whatever gurp uses: HTTP, custom port, doesn't matter
                all clients just hit 192.168.10.5:<port>

z-web   → 192.168.10.5   (via stub2 directly, same segment)
z-nat   → 192.168.10.5   (via stub2 directly)
z-client→ 192.168.10.5   (via stub2 directly)
z-bridge→ 192.168.10.5   (via stub2 directly)
z-router→ 192.168.10.5   (via stub2 directly)

No routing needed — they're all on the same etherstub.
One hop. Fast. Simple.


BOOT / SETUP ORDER (revised)
──────────────────────────────────────────────────────────────────────
1   dladm create-etherstub stub1
2   dladm create-etherstub stub2
3   dladm create-bridge -l stp testbr0
4   create all VNICs
5   install + boot z-router      (networking foundation)
6   install + boot z-gurp        (must be up before any other
                                  zone tries to fetch config)
7   install + boot z-nat         (fetches config from z-gurp)
8   install + boot z-web         (fetches config from z-gurp)
9   install + boot z-client      (fetches config from z-gurp)
10  install + boot z-bridge      (fetches config from z-gurp)
11  configure ipf/ipnat in z-nat
12  add testbr0 ports (z-client, z-bridge)
13  run test suite
14  teardown: zones → VNICs → stubs → bridge


NEW TEST CASES
──────────────────────────────────────────────────────────────────────
T11  all 5 zones can reach 192.168.10.5 (ping + config fetch)
T12  z-gurp cannot reach 10.99.0.x (no stub1 VNIC — verify isolation)
T13  z-gurp cannot reach internet (no path — verify isolation)
T14  config fetch succeeds before zone is otherwise networked
     (z-gurp reachable even if default route not yet set,
      since it's on the same stub2 segment — link-local reachable)
T15  z-gurp survives z-router going down (same-segment traffic
      doesn't traverse z-router at all)
