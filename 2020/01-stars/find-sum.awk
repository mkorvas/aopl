BEGIN {
	TOTAL = 2020;
	first = 1;
}
{
	if (first) {
		first = 0;
		nextIdx = 0;
	}
	else
		nextIdx = length(nums);
	nums[nextIdx] = $0;
}
END {
	asort(nums);
	for (aIdx = 1; aIdx <= length(nums); aIdx++) {
		for (bIdx = aIdx + 1; bIdx <= length(nums); bIdx++) {
			for (cIdx = bIdx + 1; cIdx <= length(nums); cIdx++) {
				if (nums[aIdx] + nums[bIdx] + nums[cIdx] == TOTAL)
					print nums[aIdx] * nums[bIdx] * nums[cIdx];
			}
		}
	}
}
