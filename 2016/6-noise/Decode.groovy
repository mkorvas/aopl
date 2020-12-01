def columns = null
System.in.eachLine { line ->
	if (columns == null) {
		columns = []
		line.each { columns << [] }
	}
	line.eachWithIndex { ch, i ->
		columns[i] << ch
	}
}

println columns.collect { col ->
	col.countBy { it }.max { it.value }.key }
	.join('')
