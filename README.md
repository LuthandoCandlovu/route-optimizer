<div align="center">

<img src="https://capsule-render.vercel.app/api?type=cylinder&color=0:1a1a2e,40:16213e,70:0f3460,100:533483&height=200&section=header&text=Route%20Optimization%20System&fontSize=40&fontColor=e94560&fontAlignY=55&desc=Intelligent%20Graph-Based%20Pathfinding%20%E2%80%94%20PowerShell&descAlignY=75&descColor=a8b2d8&animation=blinking&stroke=e94560&strokeWidth=2" width="100%" />

<br/>

<img src="https://readme-typing-svg.demolab.com?font=JetBrains+Mono&weight=700&size=18&duration=2500&pause=1200&color=E94560&background=00000000&center=true&vCenter=true&repeat=true&width=600&lines=Dijkstra+%7C+A*+%7C+Bellman-Ford+%7C+Floyd-Warshall;Real-Time+Traffic+Simulation+%F0%9F%9A%A6;Fuel+Cost+Optimization+Engine+%E2%9A%BD;Animated+Console+UI+%F0%9F%8E%A8;7+Locations+%C2%B7+Dynamic+Edge+Weights+%C2%B7+Path+Tracing" />

<br/><br/>

[![PowerShell](https://img.shields.io/badge/PowerShell-7.0+-5391FE?style=for-the-badge&logo=powershell&logoColor=white)](https://github.com/PowerShell/PowerShell)
[![Windows](https://img.shields.io/badge/Windows-0078D6?style=for-the-badge&logo=windows11&logoColor=white)]()
[![MIT License](https://img.shields.io/badge/License-MIT-22c55e?style=for-the-badge&logo=opensourceinitiative&logoColor=white)](LICENSE)
[![Graph Theory](https://img.shields.io/badge/Graph_Theory-CLRS-e94560?style=for-the-badge&logo=bookstack&logoColor=white)]()

<br/>

[![Dijkstra](https://img.shields.io/badge/Dijkstra-O((V%2BE)logV)-f59e0b?style=flat-square&logo=databricks&logoColor=white)]()
[![A*](https://img.shields.io/badge/A*-O(E)-ec4899?style=flat-square&logo=target&logoColor=white)]()
[![Bellman--Ford](https://img.shields.io/badge/Bellman--Ford-O(V·E)-3b82f6?style=flat-square&logo=buffer&logoColor=white)]()
[![Floyd--Warshall](https://img.shields.io/badge/Floyd--Warshall-O(V³)-8b5cf6?style=flat-square&logo=apachespark&logoColor=white)]()

</div>

---

## 📖 Introduction

**Route Optimization System** is a fully interactive, console-based pathfinding engine written in **PowerShell**. It models a city road network as a weighted undirected graph and exposes four classic shortest-path algorithms — letting you compare their behaviour live, with real-time traffic congestion and monetary fuel-cost optimization baked in.

<div align="center">
<img src="https://github.com/user-attachments/assets/a6108e04-3082-4dcc-b89a-2ae1c65cf188" width="540" alt="Route Optimizer Console Screenshot" style="border-radius:8px;box-shadow:0 4px 24px #0002"/>
</div>

Whether you're a student visualising graph theory, a developer prototyping logistics logic, or just curious how GPS routing software thinks — this project gives you a hands-on, algorithm-level view.

---

## ✨ Feature Highlights

| # | Feature | Detail |
|---|---|---|
| 🚀 | **Four algorithms** | Dijkstra · A\* · Bellman-Ford · Floyd-Warshall |
| 🗺️ | **Interactive menu** | Pick nodes by name **or** by number |
| 🚦 | **Live traffic sim** | Edge weights randomise each round |
| ⛽ | **Fuel optimizer** | Minimize cost, not just time |
| 📊 | **Side-by-side compare** | All single-source algorithms, one run |
| 🔮 | **All-pairs matrix** | Full V×V Floyd-Warshall table |
| 🎨 | **Animated CLI** | Coloured banners, live redraws |

---

## 🏗️ System Architecture

### High-Level Component Diagram

```mermaid
graph TB
    subgraph UI["🖥️  Presentation Layer"]
        MENU["Main Menu Loop"]
        LOC["ShowNumberedLocations()"]
        INPUT["GetLocationInput()"]
        RESULT["ShowRouteResult()"]
    end

    subgraph CORE["⚙️  Core Domain"]
        GRAPH["RouteGraph\n──────────────\n+ AdjacencyList\n+ Nodes[ ]\n+ NodeIndex\n+ AddEdge()"]
        EDGE["Edge\n──────────────\n+ From : string\n+ To : string\n+ Distance : float\n+ TrafficFactor : float\n+ FuelPricePerKm : float"]
    end

    subgraph ALGO["🧠  Algorithm Layer"]
        DIJ["Dijkstra\nO((V+E) log V)"]
        ASTAR["A*\nO(E) heuristic"]
        BF["Bellman-Ford\nO(V · E)"]
        FW["Floyd-Warshall\nO(V³)"]
    end

    subgraph SIM["🚦  Simulation Layer"]
        TRAFFIC["UpdateTraffic()"]
        PATH["GetPathFromPrev()"]
    end

    MENU --> LOC
    MENU --> INPUT
    MENU --> ALGO
    MENU --> SIM

    INPUT --> GRAPH
    GRAPH --> EDGE
    GRAPH --> ALGO

    DIJ --> PATH --> RESULT
    ASTAR --> PATH
    BF --> PATH
    FW --> RESULT

    TRAFFIC --> GRAPH
```

---

### Data Flow — Single Route Query

```mermaid
sequenceDiagram
    actor User
    participant Menu as Main Menu
    participant Input as GetLocationInput
    participant Graph as RouteGraph
    participant Algo as Algorithm
    participant Path as GetPathFromPrev
    participant UI as ShowRouteResult

    User->>Menu: Select option (e.g. "Find Path")
    Menu->>Input: Prompt for start & end
    Input-->>Menu: "CentralStation", "Northside"
    Menu->>Graph: Fetch adjacency list
    Graph-->>Menu: Weighted edges (distance × trafficFactor)
    Menu->>Algo: Run(graph, start, end)
    Algo->>Algo: Relax edges / priority queue
    Algo-->>Menu: distances[], prev[]
    Menu->>Path: Reconstruct(prev, start, end)
    Path-->>Menu: ["CentralStation","Downtown","Northside"]
    Menu->>UI: Display path + total cost
    UI-->>User: 🔹 Path: CentralStation → Downtown → Northside  Cost: 7.00
```

---

### Class Diagram

```mermaid
classDiagram
    class Edge {
        +string From
        +string To
        +float  Distance
        +float  TrafficFactor
        +float  FuelPricePerKm
        +TravelCost() float
        +FuelCost()   float
    }

    class RouteGraph {
        -Hashtable AdjacencyList
        -string[]  Nodes
        -Hashtable NodeIndex
        +AddEdge(from, to, dist, traffic, fuel)
        +GetNeighbours(node) Edge[]
        +GetAllNodes() string[]
        +NodeCount() int
    }

    class Algorithms {
        <<static>>
        +Dijkstra(graph, start)  Result
        +AStar(graph, start, end) Result
        +BellmanFord(graph, start) Result
        +FloydWarshall(graph)     Matrix
    }

    class Result {
        +Hashtable Distances
        +Hashtable Previous
    }

    class TrafficSimulator {
        +UpdateTraffic(graph)
        +RandomFactor() float
    }

    class PathHelper {
        +GetPathFromPrev(prev, start, end) string[]
        +FormatPath(nodes) string
    }

    RouteGraph "1" *-- "many" Edge : contains
    Algorithms ..> RouteGraph : reads
    Algorithms ..> Result : returns
    TrafficSimulator ..> RouteGraph : mutates
    PathHelper ..> Result : consumes
```

---

### State Machine — Menu Lifecycle

```mermaid
stateDiagram-v2
    [*] --> Startup

    Startup --> MainMenu : Banner drawn

    MainMenu --> SelectAlgorithm  : Option 1
    MainMenu --> CompareAll       : Option 2
    MainMenu --> TrafficUpdate    : Option 3
    MainMenu --> ShowTraffic      : Option 4
    MainMenu --> FloydWarshall    : Option 5
    MainMenu --> FuelOptimize     : Option 6
    MainMenu --> [*]              : Option 7 — Exit

    SelectAlgorithm --> PickNodes
    CompareAll      --> PickNodes
    FuelOptimize    --> PickNodes

    PickNodes --> RunAlgorithm
    RunAlgorithm --> ShowResult

    ShowResult --> MainMenu
    TrafficUpdate --> MainMenu : Weights randomised
    ShowTraffic   --> MainMenu
    FloydWarshall --> MainMenu : Matrix printed
```

---

### City Road Network

```mermaid
graph LR
    A(("✈️ Airport"))
    CS(("🚉 CentralStation"))
    DT(("🏙️ Downtown"))
    E(("🌆 Eastside"))
    N(("🌿 Northside"))
    S(("🌅 Southside"))
    W(("🌄 Westside"))

    A  -- "10 km" --- DT
    A  -- "8 km"  --- N
    DT -- "5 km"  --- E
    DT -- "7 km"  --- N
    DT -- "4 km"  --- CS
    CS -- "9 km"  --- W
    CS -- "6 km"  --- S
    N  -- "6 km"  --- W

    style A  fill:#e94560,color:#fff,stroke:#e94560
    style CS fill:#533483,color:#fff,stroke:#533483
    style DT fill:#0f3460,color:#fff,stroke:#0f3460
    style E  fill:#16213e,color:#fff,stroke:#16213e
    style N  fill:#1a5276,color:#fff,stroke:#1a5276
    style S  fill:#117a65,color:#fff,stroke:#117a65
    style W  fill:#784212,color:#fff,stroke:#784212
```

---

## 🧠 Algorithm Details

```mermaid
quadrantChart
    title Algorithm Selection Guide
    x-axis Low Complexity --> High Complexity
    y-axis Single Source --> All Pairs
    quadrant-1 Heavy but Complete
    quadrant-2 All-Pairs Power
    quadrant-3 Fast & Simple
    quadrant-4 Flexible
    Dijkstra: [0.20, 0.20]
    A*: [0.15, 0.25]
    Bellman-Ford: [0.55, 0.20]
    Floyd-Warshall: [0.90, 0.85]
```

| Algorithm | Complexity | Negative Weights | Negative Cycles | Best Use Case |
|:---:|:---:|:---:|:---:|:---|
| **Dijkstra** | `O((V+E) log V)` | ❌ | ❌ | Standard GPS routing |
| **A\*** | `O(E)` best case | ❌ | ❌ | Heuristic-guided large graphs |
| **Bellman-Ford** | `O(V·E)` | ✅ | Detects | Finance, arbitrage detection |
| **Floyd-Warshall** | `O(V³)` | ✅ | ❌ | Dense graphs, all-pairs view |

> **A\* Heuristic:** Currently `|indexA − indexB| × 0.5`. Replace with `Haversine(coordA, coordB)` for real geographic accuracy.

---

## 🚀 Getting Started

### Prerequisites

```
✅  Windows 10/11  or  Windows Server 2016+
✅  PowerShell 5.1+ (PowerShell 7.x recommended)
✅  Git (optional — for cloning)
```

### Installation

```powershell
# 1 · Clone
git clone https://github.com/LuthandoCandlovu/route-optimizer.git
cd route-optimizer

# 2 · Unblock execution for this session (if needed)
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

# 3 · Launch
.\RouteOptimizer.ps1
```

### Navigation Quick-Reference

```
[1] Find shortest path      →  choose one algorithm
[2] Compare ALL algorithms  →  Dijkstra + A* + Bellman-Ford side-by-side
[3] Simulate traffic update →  randomise all edge weights
[4] Show traffic & fuel     →  inspect current edge state
[5] Floyd-Warshall matrix   →  full V×V distance table
[6] Fuel optimization       →  minimize monetary cost
[7] Exit
```

---

## 🗺️ Roadmap

```mermaid
gantt
    title Route Optimizer — Development Roadmap
    dateFormat  YYYY-MM
    section ✅ Delivered
    Core Graph Engine           :done, 2024-01, 2024-02
    Dijkstra & A*               :done, 2024-02, 2024-03
    Bellman-Ford & Floyd-Warshall :done, 2024-03, 2024-04
    Traffic Simulation          :done, 2024-04, 2024-05
    Fuel Optimization Mode      :done, 2024-05, 2024-06
    section 🔧 In Progress
    Haversine Heuristic (GPS)   :active, 2024-07, 2024-09
    section 🔮 Planned
    WPF / Windows Forms GUI     :2024-09, 2024-12
    CSV Route Export            :2024-10, 2024-11
    Save & Load Traffic Scenarios :2024-11, 2025-01
    Multi-Modal Routing         :2025-01, 2025-04
    Web Dashboard               :2025-03, 2025-07
```

---

## 📄 License

Distributed under the **MIT License** — see [`LICENSE`](LICENSE) for details.

---

## 👤 Author

<div align="center">

<img src="https://github.com/LuthandoCandlovu.png" width="96" style="border-radius:50%" alt="Luthando Candlovu"/>

**Luthando Candlovu**

[![GitHub](https://img.shields.io/badge/GitHub-%40LuthandoCandlovu-181717?style=for-the-badge&logo=github)](https://github.com/LuthandoCandlovu)

</div>

---

## 🙏 Acknowledgements

- 📘 **CLRS** — *Introduction to Algorithms*, Cormen et al.
- 💻 **PowerShell Community** — scripting patterns and best practices
- 🗺️ **Leaflet.js** — conceptual inspiration for the map-routing interface

---

<div align="center">

<img src="https://capsule-render.vercel.app/api?type=shark&color=0:1a1a2e,50:0f3460,100:533483&height=100&section=footer&reversal=false" width="100%"/>

<br/>

*Found this useful? Drop a ⭐ — it genuinely helps!*

[![Stars](https://img.shields.io/github/stars/LuthandoCandlovu/route-optimizer?style=social)](https://github.com/LuthandoCandlovu/route-optimizer)
[![Forks](https://img.shields.io/github/forks/LuthandoCandlovu/route-optimizer?style=social)](https://github.com/LuthandoCandlovu/route-optimizer/fork)
[![Watchers](https://img.shields.io/github/watchers/LuthandoCandlovu/route-optimizer?style=social)](https://github.com/LuthandoCandlovu/route-optimizer)

</div>
