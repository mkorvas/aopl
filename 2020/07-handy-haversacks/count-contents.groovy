#!/usr/bin/env groovy

OUTER_COLOUR = 'shiny gold'

// Read the grammar.
def contains = [:]  // container: [contained, count]
System.in.eachLine { line ->
    def container = (line =~ /^\S+ \S+/)[0]
    def containedMatcher = (line =~ /\b([0-9]+) (\S+ \S+) bags?\b/)
    def contained = containedMatcher.
        findAll { it[2] != 'no other' }.
        collect { [it[1] as Integer, it[2]] }
    contains[container] = contained
}

// Count bags that must be inside "shiny gold", assuming no cycles.
def total = 0
def toAdd = [[1, OUTER_COLOUR]]
while (toAdd) {
    def (factor, colour) = toAdd.pop()
    total += factor
    toAdd += contains[colour].collect { [factor * it[0], it[1]] }
}
// Subtract the outermost bag.
total -= 1

println(total)
