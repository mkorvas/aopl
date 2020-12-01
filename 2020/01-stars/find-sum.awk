BEGIN {
	TOTAL = 2020
}
{
	numset[$0] = 1
	if (TOTAL / 2 == $0)
		half_twice = 1;
}
END {
	if (half_twice)
		print (TOTAL / 2) ^ 2;
	for (a = 0; a < TOTAL / 2; a++) {
		if (numset[a] && numset[TOTAL - a]) {
			print a * (TOTAL - a);
		}
	}
}
