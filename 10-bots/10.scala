#!/usr/bin/scala
# vim: set ft=scala et ts=2 sw=2 :

abstract class ChipHolder(val id: Int) {
  def receive(chip: Int)
}
object ChipHolder {
  def parse(typeStr: String, numStr: String): ChipHolder =
    typeStr match {
      case "bot" => Bot(numStr.toInt)
      case "output" => OutputBin(numStr.toInt)
    }
}
class Bot(id: Int) extends ChipHolder(id) {
  var chips: List[Int] = Nil
  var instructions: List[Tuple2[ChipHolder, ChipHolder]] = Nil
  override def receive(chip: Int) {
    chips = chips match {
      case Nil                           => List(chip)
      case List(larger) if larger > chip => List(chip, larger)
      case List(smaller)                 => List(smaller, chip)
    }
    if (chips == List(17, 61))
      println(s"Bot ${id} will compare 17 and 61.")
    if (chips.length == 2 && instructions.nonEmpty) doDistribute
  }
  def distribute(outLow: ChipHolder, outHigh: ChipHolder) {
    instructions :+= (outLow, outHigh)
    if (chips.length == 2) doDistribute
  }
  def doDistribute() {
    val ((outLow, outHigh) :: rest) = instructions
    instructions = rest
    outLow.receive(chips(0))
    outHigh.receive(chips(1))
    chips = Nil
  }
}
object Bot {
  private val id2bot = scala.collection.mutable.Map[Int, Bot]()
  def apply(id: Int) = id2bot.getOrElseUpdate(id, new Bot(id))
}
class OutputBin(id: Int) extends ChipHolder(id) {
  var chips: List[Int] = Nil
  def receive(chip: Int) { chips :+= chip }
}
object OutputBin {
  private val id2bin = scala.collection.mutable.Map[Int, OutputBin]()
  def apply(id: Int) = id2bin.getOrElseUpdate(id, new OutputBin(id))
  def outputMap = id2bin
}

val movePat = """value ([0-9]+) .* ([0-9]+)""".r
val givePat = """bot ([0-9]+) .* (bot|output) ([0-9]+) .* (bot|output) ([0-9]+)""".r

import scala.io.Source

for (line <- Source.fromFile("in", "UTF-8").getLines) {
  line match {
    case movePat(chip, bot) => Bot(bot.toInt).receive(chip.toInt)
    case givePat(from, lowType, toLow, highType, toHigh) =>
      Bot(from.toInt).distribute(ChipHolder.parse(lowType, toLow),
                                 ChipHolder.parse(highType, toHigh))
    case _ => println(s"no match: $line")
  }
}

OutputBin.outputMap.filterKeys(Set(0, 1, 2))
  .values.map(_.chips.last).product
