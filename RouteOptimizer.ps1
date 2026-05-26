# ========== ROUTE OPTIMIZER - FULLY FIXED ==========
class Edge {
    [string]$From; [string]$To
    [double]$BaseDistance; [double]$TrafficFactor; [double]$FuelPricePerKm
    Edge([string]$f, [string]$t, [double]$d, [double]$tr, [double]$fu) {
        $this.From=$f; $this.To=$t; $this.BaseDistance=$d
        $this.TrafficFactor=$tr; $this.FuelPricePerKm=$fu
    }
    [double] GetTravelCost() { return $this.BaseDistance * $this.TrafficFactor }
    [double] GetFuelCost()   { return $this.BaseDistance * $this.FuelPricePerKm }
}

class RouteGraph {
    [System.Collections.Generic.Dictionary[string, System.Collections.Generic.List[Edge]]]$AdjList
    [string[]]$Nodes
    [System.Collections.Generic.Dictionary[string, int]]$NodeIndex
    RouteGraph() {
        $this.AdjList = [System.Collections.Generic.Dictionary[string, System.Collections.Generic.List[Edge]]]::new()
        $this.NodeIndex = [System.Collections.Generic.Dictionary[string, int]]::new()
    }
    [void] AddNode([string]$node) { 
        if(-not $this.AdjList.ContainsKey($node)) { 
            $this.AdjList[$node] = [System.Collections.Generic.List[Edge]]::new() 
        } 
    }
    [void] AddEdge([string]$f, [string]$t, [double]$d, [double]$tr, [double]$fu) {
        $this.AddNode($f); $this.AddNode($t)
        $this.AdjList[$f].Add([Edge]::new($f,$t,$d,$tr,$fu))
        $this.AdjList[$t].Add([Edge]::new($t,$f,$d,$tr,$fu))
    }
    [void] BuildNodeIndex() { 
        $this.Nodes = $this.AdjList.Keys | Sort-Object
        for($i=0; $i -lt $this.Nodes.Count; $i++) { 
            $this.NodeIndex[$this.Nodes[$i]] = $i 
        } 
    }
}

class Algorithms {
    static [System.Collections.Hashtable] Dijkstra([RouteGraph]$g, [string]$start) {
        $dist=@{}; $prev=@{}; $unvisited=[System.Collections.Generic.List[string]]::new()
        foreach($n in $g.Nodes){ $dist[$n]=[double]::PositiveInfinity; $prev[$n]=$null; $unvisited.Add($n) }
        $dist[$start]=0
        while($unvisited.Count -gt 0){
            $current=$null; $min=[double]::PositiveInfinity
            foreach($u in $unvisited){ if($dist[$u] -lt $min){ $min=$dist[$u]; $current=$u } }
            if(-not $current -or $dist[$current] -eq [double]::PositiveInfinity){ break }
            $unvisited.Remove($current)
            foreach($e in $g.AdjList[$current]){
                $alt=$dist[$current]+$e.GetTravelCost()
                if($alt -lt $dist[$e.To]){ $dist[$e.To]=$alt; $prev[$e.To]=$current }
            }
        }
        return @{distance=$dist; previous=$prev}
    }
    static [double] Heuristic([string]$a,[string]$b,[RouteGraph]$g){ 
        return [Math]::Abs($g.NodeIndex[$a]-$g.NodeIndex[$b])*0.5 
    }
    static [System.Collections.Hashtable] AStar([RouteGraph]$g, [string]$start, [string]$goal){
        $gScore=@{}; $fScore=@{}; $prev=@{}; $openSet=[System.Collections.Generic.List[string]]::new()
        foreach($n in $g.Nodes){ $gScore[$n]=[double]::PositiveInfinity; $fScore[$n]=[double]::PositiveInfinity; $prev[$n]=$null }
        $gScore[$start]=0; $fScore[$start]=[Algorithms]::Heuristic($start,$goal,$g); $openSet.Add($start)
        while($openSet.Count -gt 0){
            $current=$null; $lowest=[double]::PositiveInfinity
            foreach($n in $openSet){ if($fScore[$n] -lt $lowest){ $lowest=$fScore[$n]; $current=$n } }
            if($current -eq $goal){ break }
            $openSet.Remove($current)
            foreach($e in $g.AdjList[$current]){
                $tent=$gScore[$current]+$e.GetTravelCost()
                if($tent -lt $gScore[$e.To]){
                    $prev[$e.To]=$current; $gScore[$e.To]=$tent
                    $fScore[$e.To]=$tent+[Algorithms]::Heuristic($e.To,$goal,$g)
                    if(-not $openSet.Contains($e.To)){ $openSet.Add($e.To) }
                }
            }
        }
        $path=@()
        $c=$goal
        while($c){
            $path=,@($c)+$path
            $c=$prev[$c]
        }
        return @{path=$path; cost=$gScore[$goal]}
    }
    static [System.Collections.Hashtable] BellmanFord([RouteGraph]$g, [string]$start){
        $dist=@{}; $prev=@{}
        foreach($n in $g.Nodes){ $dist[$n]=[double]::PositiveInfinity; $prev[$n]=$null }
        $dist[$start]=0
        for($i=1; $i -lt $g.Nodes.Count; $i++){
            $updated=$false
            foreach($u in $g.Nodes){
                foreach($e in $g.AdjList[$u]){
                    if($dist[$u] -ne [double]::PositiveInfinity){
                        $new=$dist[$u]+$e.GetTravelCost()
                        if($new -lt $dist[$e.To]){ $dist[$e.To]=$new; $prev[$e.To]=$u; $updated=$true }
                    }
                }
            }
            if(-not $updated){ break }
        }
        return @{distance=$dist; previous=$prev}
    }
    static [System.Collections.Hashtable] FloydWarshall([RouteGraph]$g){
        $n=$g.Nodes.Count; $inf=[double]::PositiveInfinity
        $dist=[double[,]]::new($n,$n); $next=[int[,]]::new($n,$n)
        for($i=0;$i -lt $n;$i++){ for($j=0;$j -lt $n;$j++){ $dist[$i,$j]=$inf; $next[$i,$j]=-1 }; $dist[$i,$i]=0; $next[$i,$i]=$i }
        foreach($u in $g.Nodes){
            $iu=$g.NodeIndex[$u]
            foreach($e in $g.AdjList[$u]){
                $iv=$g.NodeIndex[$e.To]; $cost=$e.GetTravelCost()
                if($cost -lt $dist[$iu,$iv]){ $dist[$iu,$iv]=$cost; $next[$iu,$iv]=$iv }
            }
        }
        for($k=0;$k -lt $n;$k++){ for($i=0;$i -lt $n;$i++){ for($j=0;$j -lt $n;$j++){
            if($dist[$i,$k] -ne $inf -and $dist[$k,$j] -ne $inf -and $dist[$i,$k]+$dist[$k,$j] -lt $dist[$i,$j]){
                $dist[$i,$j]=$dist[$i,$k]+$dist[$k,$j]; $next[$i,$j]=$next[$i,$k]
            }
        }}}
        return @{distanceMatrix=$dist; nextMatrix=$next}
    }
    static [string[]] ReconstructPathFloyd([int[,]]$next, [int]$s, [int]$e, [string[]]$names){
        if($next[$s,$e] -eq -1){ return @() }
        $path=[System.Collections.Generic.List[int]]::new(); $path.Add($s)
        while($s -ne $e){ $s=$next[$s,$e]; $path.Add($s) }
        $result=@(); foreach($idx in $path){ $result+=$names[$idx] }
        return $result
    }
}

function BuildCityGraph {
    $g=[RouteGraph]::new()
    $g.AddNode("Downtown"); $g.AddNode("Airport"); $g.AddNode("Northside"); $g.AddNode("Southside")
    $g.AddNode("Eastside"); $g.AddNode("Westside"); $g.AddNode("CentralStation")
    $g.AddEdge("Downtown","Airport",12,1.3,0.25); $g.AddEdge("Downtown","Northside",5,1.0,0.20)
    $g.AddEdge("Downtown","Southside",6.5,1.1,0.22); $g.AddEdge("Downtown","CentralStation",2,0.9,0.18)
    $g.AddEdge("Airport","Northside",14,1.2,0.30); $g.AddEdge("Airport","Eastside",10,1.0,0.28)
    $g.AddEdge("Northside","Westside",8,0.8,0.21); $g.AddEdge("Southside","Eastside",7.5,1.4,0.24)
    $g.AddEdge("Southside","CentralStation",4,0.9,0.19); $g.AddEdge("Eastside","Westside",9,1.0,0.23)
    $g.AddEdge("Westside","CentralStation",3.5,1.0,0.20); $g.AddEdge("Airport","CentralStation",11,1.2,0.26)
    $g.AddEdge("Northside","Eastside",6,1.1,0.22)
    $g.BuildNodeIndex()
    return $g
}

function ShowNumberedLocations($nodes) {
    Write-Host "`nAvailable locations:" -ForegroundColor Cyan
    for($i=0; $i -lt $nodes.Count; $i++) {
        Write-Host "  $($i+1). $($nodes[$i])" -ForegroundColor White
    }
}

function GetLocationInput($prompt, $nodes) {
    while($true) {
        $input = Read-Host $prompt
        if($input -match '^\d+$') {
            $idx = [int]$input - 1
            if($idx -ge 0 -and $idx -lt $nodes.Count) {
                return $nodes[$idx]
            }
        } else {
            $match = $nodes | Where-Object { $_ -like $input }
            if($match) { return $match }
        }
        Write-Host "Invalid. Please enter a number (1-$($nodes.Count)) or one of: $($nodes -join ', ')" -ForegroundColor Red
        ShowNumberedLocations $nodes
    }
}

function ShowRouteResult($algoName, $path, $cost) {
    if ($cost -eq $null -or $cost -ge 1e9) {
        Write-Host "  No route found or cost infinite." -ForegroundColor Red
        return
    }
    if ($path.Count -eq 0) {
        Write-Host "  No path reconstructed." -ForegroundColor Red
        return
    }
    Write-Host "`n🔹 $algoName Result:" -ForegroundColor Magenta
    $pathStr = $path -join " → "
    Write-Host "  Path: $pathStr" -ForegroundColor Yellow
    Write-Host "  Travel Cost (distance×traffic): $([math]::Round($cost,2)) units" -ForegroundColor Green
}

function UpdateTraffic($g) {
    Write-Host "`n[Traffic Simulation] Updating..." -ForegroundColor Cyan
    foreach($node in $g.Nodes) {
        foreach($edge in $g.AdjList[$node]) {
            $newTraffic = [Math]::Round((0.7 + (Get-Random -Maximum 110)/100),2)
            $edge.TrafficFactor = $newTraffic
            $edge.FuelPricePerKm = [Math]::Round(0.18 + ($newTraffic-1)*0.08,3)
        }
    }
    Write-Host "Traffic updated!" -ForegroundColor Green
}

function GetPathFromPrev($prev, $start, $end) {
    $path = @()
    $c = $end
    while ($c -ne $null) {
        $path = ,$c + $path
        $c = $prev[$c]
    }
    if ($path[0] -ne $start) { return @() }
    return $path
}

$graph = BuildCityGraph
$nodes = $graph.Nodes
Write-Host "`n╔══════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║     ROUTE OPTIMIZATION SYSTEM - with numbered locations ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════╝" -ForegroundColor Cyan

while($true) {
    Write-Host "`n========== MAIN MENU ==========" -ForegroundColor Yellow
    Write-Host "1. Find shortest path (choose algorithm)"
    Write-Host "2. Compare ALL algorithms for same start/end"
    Write-Host "3. Simulate real-time traffic update"
    Write-Host "4. Show current traffic & fuel prices"
    Write-Host "5. Floyd-Warshall: All-pairs shortest paths"
    Write-Host "6. Fuel optimization (minimize fuel cost)"
    Write-Host "0. Exit"
    $choice = Read-Host "Select option"
    
    switch($choice) {
        "1" {
            ShowNumberedLocations $nodes
            $start = GetLocationInput "Start location (number or name)" $nodes
            $end   = GetLocationInput "End location (number or name)" $nodes
            Write-Host "`nAlgorithm: 1.Dijkstra 2.A* 3.Bellman-Ford" -ForegroundColor Cyan
            $algo = Read-Host "Choose"
            switch($algo) {
                "1" { 
                    $res = [Algorithms]::Dijkstra($graph, $start)
                    $cost = $res.distance[$end]
                    $path = GetPathFromPrev $res.previous $start $end
                    ShowRouteResult "Dijkstra" $path $cost
                }
                "2" {
                    $res = [Algorithms]::AStar($graph, $start, $end)
                    $cost = $res.cost
                    $path = $res.path
                    ShowRouteResult "A*" $path $cost
                }
                "3" {
                    $res = [Algorithms]::BellmanFord($graph, $start)
                    $cost = $res.distance[$end]
                    $path = GetPathFromPrev $res.previous $start $end
                    ShowRouteResult "Bellman-Ford" $path $cost
                }
                default { Write-Host "Invalid algorithm" }
            }
        }
        "2" {
            ShowNumberedLocations $nodes
            $start = GetLocationInput "Start location" $nodes
            $end   = GetLocationInput "End location" $nodes
            Write-Host "`n=== COMPARISON for $start → $end ===" -ForegroundColor Green
            $dij = [Algorithms]::Dijkstra($graph, $start)
            $dijCost = $dij.distance[$end]
            $dijPath = GetPathFromPrev $dij.previous $start $end
            ShowRouteResult "Dijkstra" $dijPath $dijCost
            $astar = [Algorithms]::AStar($graph, $start, $end)
            $astarCost = $astar.cost
            $astarPath = $astar.path
            ShowRouteResult "A*" $astarPath $astarCost
            $bf = [Algorithms]::BellmanFord($graph, $start)
            $bfCost = $bf.distance[$end]
            $bfPath = GetPathFromPrev $bf.previous $start $end
            ShowRouteResult "Bellman-Ford" $bfPath $bfCost
        }
        "3" { UpdateTraffic $graph }
        "4" {
            Write-Host "`nCurrent road conditions:" -ForegroundColor Cyan
            foreach($n in $nodes) {
                foreach($e in $graph.AdjList[$n]) {
                    if($n.CompareTo($e.To) -lt 0) {
                        Write-Host "  $($e.From) ↔ $($e.To) | Dist: $($e.BaseDistance)km | Traffic: $($e.TrafficFactor) | Fuel: $$($e.FuelPricePerKm)/km"
                    }
                }
            }
        }
        "5" {
            $fw = [Algorithms]::FloydWarshall($graph)
            Write-Host "Floyd-Warshall: enter start and end (or leave start empty to see full matrix)" -ForegroundColor Yellow
            $sInput = Read-Host "Start (number/name or Enter for all-pairs)"
            if([string]::IsNullOrWhiteSpace($sInput)) {
                $names = $graph.Nodes
                Write-Host "`nAll-pairs shortest travel costs:" -ForegroundColor Magenta
                $header = "      "
                foreach($nn in $names) { $header += "{0,12}" -f $nn.Substring(0,[Math]::Min(8,$nn.Length)) }
                Write-Host $header -ForegroundColor White
                for($i=0;$i -lt $names.Count;$i++) {
                    $line = "{0,8}" -f $names[$i]
                    for($j=0;$j -lt $names.Count;$j++) {
                        $val = $fw.distanceMatrix[$i,$j]
                        $line += if($val -ge 1e9) { "{0,12}" -f "INF" } else { "{0,12:F2}" -f $val }
                    }
                    Write-Host $line
                }
            } else {
                $start = $null
                if($sInput -match '^\d+$') {
                    $idx = [int]$sInput - 1
                    if($idx -ge 0 -and $idx -lt $nodes.Count) { $start = $nodes[$idx] }
                } else {
                    $match = $nodes | Where-Object { $_ -like $sInput }
                    if($match) { $start = $match }
                }
                if(-not $start) {
                    Write-Host "Invalid start location. Please try again." -ForegroundColor Red
                    $start = GetLocationInput "Start location" $nodes
                }
                $end = GetLocationInput "End location" $nodes
                $sIdx = $graph.NodeIndex[$start]; $eIdx = $graph.NodeIndex[$end]
                $dist = $fw.distanceMatrix[$sIdx,$eIdx]
                $path = [Algorithms]::ReconstructPathFloyd($fw.nextMatrix, $sIdx, $eIdx, $graph.Nodes)
                ShowRouteResult "Floyd-Warshall" $path $dist
            }
        }
        "6" {
            ShowNumberedLocations $nodes
            $start = GetLocationInput "Start location" $nodes
            $end   = GetLocationInput "End location" $nodes
            $fuelGraph = [RouteGraph]::new()
            foreach($n in $nodes) { $fuelGraph.AddNode($n) }
            foreach($u in $nodes) {
                foreach($e in $graph.AdjList[$u]) {
                    $fuelGraph.AddEdge($e.From, $e.To, $e.GetFuelCost(), 1.0, 0)
                }
            }
            $fuelGraph.BuildNodeIndex()
            $res = [Algorithms]::Dijkstra($fuelGraph, $start)
            $fuelCost = $res.distance[$end]
            $path = GetPathFromPrev $res.previous $start $end
            $travelCost=0
            for($i=0;$i -lt $path.Count-1;$i++){
                $from=$path[$i]; $to=$path[$i+1]
                foreach($ed in $graph.AdjList[$from]){ if($ed.To -eq $to){ $travelCost+=$ed.GetTravelCost(); break } }
            }
            Write-Host "`n🔹 Fuel Optimized Path:" -ForegroundColor Green
            $pathStr = $path -join " → "
            Write-Host "  Path: $pathStr" -ForegroundColor Yellow
            Write-Host "  Total Fuel Cost: $$([math]::Round($fuelCost,2))" -ForegroundColor Cyan
            Write-Host "  Travel Cost (time+traffic): $([math]::Round($travelCost,2)) units" -ForegroundColor Gray
        }
        "0" { Write-Host "Goodbye!" -ForegroundColor Green; break }
        default { Write-Host "Invalid option" }
    }
}
