#!/usr/bin/scala

abstract class ChipHolder(id: Int)
object ChipHolder {
  def parse(typeStr: String, numStr: String): ChipHolder =
    typeStr match {
      case "bot" => Bot(numStr.toInt)
      case "output" => OutputBin(numStr.toInt)
    }
}
class Bot(id: Int) extends ChipHolder(id)
object Bot {
  private val id2bot = scala.collection.mutable.Map[Int, Bot]()
  def apply(id: Int) = id2bot.getOrElseUpdate(id, new Bot(id))
}
class OutputBin(id: Int) extends ChipHolder(id)
object OutputBin {
  private val id2bin = scala.collection.mutable.Map[Int, OutputBin]()
  def apply(id: Int) = id2bin.getOrElseUpdate(id, new OutputBin(id))
}

object BotFactory {

  val holder2chips = scala.collection.mutable.Map[ChipHolder, List[Int]]()
                     .withDefaultValue(List[Int]())
  val chip2bot = scala.collection.mutable.Map[Int, Bot]()

  def moveChip(chip: Int, whom: ChipHolder) {
    chip2bot.get(chip).foreach( oldBot =>
          holder2chips(oldBot) = holder2chips(oldBot).filter(_ != chip))
    holder2chips(whom) = chip :: holder2chips(whom)
    whom match {
      case bot: Bot => chip2bot(chip) = bot
      case _ => ()
    }
  }

  def giveChips(botSrc: Bot, outLow: ChipHolder, outHigh: ChipHolder) {
    val List(chip1, chip2) = holder2chips(botSrc)
    val (low, high) = if (chip1 < chip2) (chip1, chip2) else (chip2, chip1)
    moveChip(low, outLow)
    moveChip(high, outHigh)
  }

}

// BotFactory.moveChip(23, Bot(208))
// BotFactory.moveChip(24, Bot(209))
// BotFactory.moveChip(23, Bot(209))
// BotFactory.giveChips(Bot(209), OutputBin(0), Bot(208))

// BotFactory.holder2chips

val inLines = Array(
  "value 23 goes to bot 208",
  "bot 125 gives low to bot 58 and high to bot 57"
  )

val movePat = """value ([0-9]+) .* ([0-9]+)""".r
val givePat = """bot ([0-9]+) .* (bot|output) ([0-9]+) .* (bot|output) ([0-9]+)""".r

import scala.io.Source
for (line <- Source.fromFile("in", "UTF-8").getLines) {
// for (line <- inLines) {
  line match {
    case movePat(chip, bot) =>
      BotFactory.moveChip(chip.toInt, Bot(bot.toInt))
    case givePat(from, lowType, toLow, highType, toHigh) =>
      BotFactory.giveChips(Bot(from.toInt),
                           ChipHolder.parse(lowType, toLow),
                           ChipHolder.parse(highType, toHigh))
    case _ => println(s"no match: $line")
  }
}
