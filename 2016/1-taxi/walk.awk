BEGIN { RS = ", "; FS = "\n" }
/L/   { dir = (dir + 3) % 4 }
/R/   { dir = (dir + 1) % 4 }
      { dist[dir] += substr($0, 2) }
END   { print gensub("-", "", "", dist[0] - dist[2]) + \
              gensub("-", "", "", dist[1] - dist[3]) }
