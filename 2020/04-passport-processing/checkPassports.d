#!/usr/bin/env rdmd

import std.algorithm;
import std.array;
import std.conv;
import std.regex;
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

auto hclRegex = ctRegex!(`^#[0-9a-f]{6}$`);
auto eclRegex = ctRegex!(`^(amb|blu|brn|gry|grn|hzl|oth)$`);
auto pidRegex = ctRegex!(`^[0-9]{9}$`);

bool isFieldValid(const string field,
									const string[string] fields) {
	if ((field in fields) is null)
		return false;
	string value = fields[field];
	try {
		switch(field) {
			case "byr":
				return 1920 <= to!int(value) && to!int(value) <= 2002;
			case "iyr":
				return 2010 <= to!int(value) && to!int(value) <= 2020;
			case "eyr":
				return 2020 <= to!int(value) && to!int(value) <= 2030;
			case "hgt":
				auto suffix = value[$ - 2 .. $];
				int number = to!int(value[0 .. $ - 2]);
				return (suffix == "cm" && 150 <= number && number <= 193) ||
							 (suffix == "in" && 59 <= number && number <= 76);
			case "hcl":
				return cast(bool) matchFirst(value, hclRegex);
			case "ecl":
				return cast(bool) matchFirst(value, eclRegex);
			case "pid":
				return cast(bool) matchFirst(value, pidRegex);
			default:
				assert(0);
		}
	} catch (ConvException e) {
		return false;
	}
}

bool isParValid(const string[] par) {
	string[string] fields;
	foreach (line; par) {
		foreach (word; line.split) {
			auto parts = word.split(":");
			fields[parts[0]] = parts[1];
		}
	}
	return all!(reqField => isFieldValid(reqField, fields))
						 (requiredFields);
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
