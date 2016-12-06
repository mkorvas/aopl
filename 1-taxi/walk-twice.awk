BEGIN { RS = ", "; FS = "\n"; x = 0; y = 0; pos[0, 0] = 1; }
/L/   { dir = (dir + 3) % 4 }
/R/   { dir = (dir + 1) % 4 }
      { walk(substr($0, 2)); }

function walk(step) {
  for (i = 0; i < 0 + step; i++) {
    switch (dir) {
      case 0: y++; break;
      case 1: x++; break;
      case 2: y--; break;
      case 3: x--;
    }
    checkpos();
  }
}

function checkpos() {
  if (pos[x, y]) {
    print gensub("-", "", "", x) + gensub("-", "", "", y);
    exit;
  }
  else
    pos[x, y] = 1;
}
