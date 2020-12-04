#!/usr/bin/env rdmd

import std.algorithm;
import std.array;
import std.stdio;

immutable(string[]) requiredFields = [
	"byr",
	"iyr",
	"eyr",
	"hgt",
	"hcl",
	"ecl",
	"pid",
	// "cid",
];

bool isParValid(const string[] par) {
	bool[string] hasField;
	foreach (line; par) {
		foreach (word; line.split) {
			auto parts = word.split(":");
			hasField[parts[0]] = true;
		}
	}
	return all!(reqField => reqField in hasField)(requiredFields);
}

void main(const string[] args)
{
		auto inFile = File("input");
		string lineString;
		string[] par;
		int numValid;
		foreach (line; inFile.byLine()) {
			lineString = line.dup;
			if (lineString.empty) {
				numValid += isParValid(par);
				par = [];
			} else {
				par ~= lineString;
			}
		}
		if (!par.empty && isParValid(par))
			numValid++;
		writeln(numValid);
}
