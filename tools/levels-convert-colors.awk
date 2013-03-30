function split_seps(str, arr) {
    delete arr
    begin = 1
    idx = 1
    for (k = 1; k <= length(str); ++k) {
        ch = substr(str,  k, 1)
        if (ch ~ "[=; ]") {
            arr[idx++] = substr(str, begin, k-begin)
            arr[idx++] = ch
            begin = k+1
            ++k
        } else if (k == length(str)) {
            arr[idx++] = substr(str, begin, k-begin+1)
        }
    }
    return idx-1
}

function conv_col(c) {
    n = 0 + c
    n = n / 255.0
    return sprintf("%.3f", n)
}

function conv_line(pattern) {
    i = 1
    num = split_seps($0, split_string)
    while (i <= num) {
        if (split_string[i] ~ pattern) {
            j = 0
            while (j < 4) {
                i++
                if (split_string[i] ~ "[=; ]") continue
                j++
                if (! (split_string[i] ~ /^[0-9]+/)) {
                    --i
                    break
                }
                split_string[i] = conv_col(split_string[i])
            }
        }
        ++i
    }

    $0 = ""
    for (i = 1; i <= num; ++i) {
        $0 = $0 split_string[i]
    }
}

/^AmbientColor/ || /^FogColor/ {
    conv_line("air|water")
}

/^VehicleColor/ || /^InsectColor/ || /^GreeneryColor/ {
    conv_line("color")
}

/^Background/ {
    conv_line("up|down|cloudUp|cloudDown")
}

/^TerrainWater/ {
    conv_line("diffuse|ambient|color")
}

/^TerrainCloud/ {
    conv_line("diffuse|ambient")
}

/^GroundSpot/ {
    conv_line("color")
}

/^MapColor/ {
    conv_line("floor|water")
}

# Don't change WaterAddColor, CreateSpot, CreateLight as they are OK

{ print }
