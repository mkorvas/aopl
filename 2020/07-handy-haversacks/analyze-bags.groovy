#!/usr/bin/env groovy

INNER_COLOUR = 'shiny gold'

// Read the grammar.
def fitsIn = [:]  // contained: {possible container}
System.in.eachLine { line ->
    def match = (line =~ /\b(\S+ \S+) bags?\b/)
    def container = match[0][1]
    def contained = (1..(match.count - 1)).
                     collect { match[it][1] }.
                     findAll { it != 'no other' }
    contained.each { containedOne ->
        fitsIn.get(containedOne, [] as Set) << container
    }
}

// Count outermost bags that fit "shiny gold".
def outerColours = [] as Set
def diff = [INNER_COLOUR] as Set
while (diff) {
    def newDiff = [] as Set
    diff.each { outer ->
        newDiff.addAll(fitsIn.get(outer, []))
    }
    newDiff.removeAll outerColours
    outerColours.addAll newDiff
    diff = newDiff
}

println(outerColours.size())
