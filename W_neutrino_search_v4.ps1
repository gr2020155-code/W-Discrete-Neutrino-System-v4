# ============================================================
#   W-Neutrino Discretization Search v4.1
#   Framework: W-Structure | Author: Hrachya Danielyan
#   Purpose: Reproducible system-level discretization of ν2, ν3
#            using mp / (2^s · p · q)
# ============================================================

Write-Host "=== W-Discretization Search v4.1 (Neutrino system-level) ==="

# Proton mass (eV)
$mp_eV = 938272088.16

# Experimental mass targets
$nu2_target = 0.0086
$nu3_target = 0.05

# Δm^2 (experimental)
$dm2_target = 2.42604e-3   # atmospheric window

# Search ranges
$pMax = 200
$qMax = 200
$sMax = 40

Write-Host "Proton mass mp = $mp_eV"
Write-Host ("Target nu2     = {0}" -f $nu2_target)
Write-Host ("Target nu3     = {0}" -f $nu3_target)
Write-Host ("Target dm2     = {0:E6}" -f $dm2_target)
Write-Host ("Search range   = p 1..$pMax, q 1..$qMax, s 0..$sMax")
Write-Host ""

# ------------------------------------------------------------
# FUNCTION: build neutrino candidate
# ------------------------------------------------------------
function New-NeutrinoCandidate {
    param(
        [string]$Name,
        [double]$Target,
        [int]$p,
        [int]$q,
        [int]$s
    )

    $den = [math]::Pow(2,$s) * $p * $q
    if ($den -eq 0) { return $null }

    $m = $mp_eV / $den

    $relErr = [math]::Abs($m - $Target) / $Target

    # complexity score (minimal p,q,s preferred)
    $complexity = $s + [math]::Log10($p) + [math]::Log10($q)

    # primary score: accuracy dominates
    $score = $relErr * 1e6 + $complexity

    return [pscustomobject]@{
        name       = $Name
        target_eV  = $Target
        p          = $p
        q          = $q
        s          = $s
        mass_eV    = $m
        rel_error  = $relErr
        complexity = $complexity
        score      = $score
    }
}

# ------------------------------------------------------------
# SEARCH PER NEUTRINO
# ------------------------------------------------------------
function Search-Neutrino {
    param(
        [string]$Name,
        [double]$Target
    )

    Write-Host "Searching for $Name ..."

    $list = New-Object System.Collections.Generic.List[object]

    for ($p = 1; $p -le $pMax; $p++) {
        for ($q = 1; $q -le $qMax; $q++) {
            for ($s = 0; $s -le $sMax; $s++) {
                $cand = New-NeutrinoCandidate -Name $Name -Target $Target -p $p -q $q -s $s
                if ($cand) { $list.Add($cand) | Out-Null }
            }
        }
    }

    $sorted = $list | Sort-Object score
    $best   = $sorted[0]

    Write-Host ("  best rel_error = {0:E6}, p={1}, q={2}, s={3}" -f `
                $best.rel_error, $best.p, $best.q, $best.s)

    return @{
        Best  = $best
        Top10 = $sorted | Select-Object -First 10
    }
}

# ------------------------------------------------------------
# EXECUTE SEARCH FOR ν2 AND ν3
# ------------------------------------------------------------
$nu2 = Search-Neutrino -Name "nu2" -Target $nu2_target
$nu3 = Search-Neutrino -Name "nu3" -Target $nu3_target

Write-Host ""
Write-Host "=== Best candidates (per neutrino) ==="
Write-Host ""
$nu2.Best | Format-Table
Write-Host ""
$nu3.Best | Format-Table
Write-Host ""

# ------------------------------------------------------------
# SYSTEM-LEVEL match (pair ν2, ν3)
# Just compute Δm² and check closeness to experimental target
# ------------------------------------------------------------
Write-Host "=== System-level scan (TOP-K) ==="
Write-Host ""

$sysList = New-Object System.Collections.Generic.List[object]

foreach ($a in $nu2.Top10) {
    foreach ($b in $nu3.Top10) {

        $dm2 = [math]::Abs($b.mass_eV*$b.mass_eV - $a.mass_eV*$a.mass_eV)
        $dm2_rel = [math]::Abs($dm2 - $dm2_target) / $dm2_target

        $scoreSys = $dm2_rel * 1e6 + $a.complexity + $b.complexity

        $sysList.Add([pscustomobject]@{
            p2 = $a.p; q2 = $a.q; s2 = $a.s
            m2 = $a.mass_eV; rel2 = $a.rel_error
            p3 = $b.p; q3 = $b.q; s3 = $b.s
            m3 = $b.mass_eV; rel3 = $b.rel_error
            dm2 = $dm2; dm2_rel = $dm2_rel
            system_score = $scoreSys
        }) | Out-Null
    }
}

$sysSorted = $sysList | Sort-Object system_score
$bestSys   = $sysSorted[0]

Write-Host "=== Best system-level candidate ==="
Write-Host ""
$bestSys | Format-Table
Write-Host ""
Write-Host "=== Done. v4.1 ready. ==="
