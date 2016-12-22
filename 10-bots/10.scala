#!/usr/bin/scala
# vim: set ft=scala et ts=2 sw=2 :

abstract class ChipHolder(val id: Int)
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

class Interval(val min: Option[Int], val max: Option[Int]) extends Comparable[Interval] {
  def compareTo(other: Interval) = {
    if (max.isDefined && other.min.isDefined && max.get < other.min.get) -1 else
    if (min.isDefined && other.max.isDefined && min.get > other.max.get)  1 else
                                                                  0
  }
}

// val ivals = Array(new Interval(None, None),
//                   new Interval(Some(41), None))
// 
// ivals.map(_.min).max.map(_ + 1)
// ivals.map(_.max).min.map(_ - 1)

class Chip extends Comparable[Chip] {
  private var _idRange = new Interval(None, None)
  private var _value: Option[Int] = None
  var lowerChips = Set[Chip]()
  var higherChips = Set[Chip]()
  
  def this(id: Int) {
    this()
    value = id
  }

  def this(id: Option[Int]) {
    this()
    if (id.isDefined)
      value = id.get
  }

  // Mark this chip as lower than another chip.
  def :<(higher: Chip) {
    higherChips += higher
    higher.lowerChips += this
  }

  def compareTo(other: Chip) = idRange.compareTo(other.idRange)

  def value = {
    if (!_value.isDefined)
      idRange()
    _value
  }

  def value_=(knownValue: Int) {
    if (!_value.isDefined) {
      Chip.id2chips(knownValue) += this
      _value = Some(knownValue)
      _idRange = new Interval(_value, _value)
    }
  }

  def idRange(): Interval = {
    if (!_value.isDefined) {
      val knownMin = if (lowerChips.nonEmpty) 
                        lowerChips.map(_._idRange.min).max.map(_ + 1)
                     else None
      val knownMax = if (higherChips.nonEmpty)
                        higherChips.map(_._idRange.max).min.map(_ - 1)
                     else None
      _idRange = new Interval(knownMin, knownMax)
      if (knownMin.isDefined && knownMin == knownMax)
        value = knownMin.get
    }
    _idRange
  }
}
object Chip {
  private val id2chips = scala.collection.mutable.Map[Int, Set[Chip]]()
                         .withDefaultValue(Set[Chip]())
  def apply(u: Unit) = new Chip()
  def apply(id: Int) = {
    id2chips.get(id) match {
      case chips: Some[Set[Chip]] => chips.get.head
      case None => new Chip(id)
    }
  }
}

object BotFactory {

  val holder2chips = scala.collection.mutable.Map[ChipHolder, List[Set[Chip]]]()
                     .withDefaultValue(Nil)
                     // .withDefaultValue(List[Set[Chip]]())
  val chip2bot = scala.collection.mutable.Map[Chip, Bot]()
  val chip2bots = scala.collection.mutable.Map[Chip, Set[Bot]]()
                     .withDefaultValue(Set[Bot]())

//   def moveChip(chip: Chip, whom: ChipHolder) {
//     chip2bot.get(chip).foreach( oldBot =>
//           holder2chips(oldBot) = holder2chips(oldBot).filter(_ != chip))
//     holder2chips(whom) = chip :: holder2chips(whom)
//     whom match {
//       case bot: Bot => chip2bot(chip) = bot
//       case _ => ()
//     }
//   }

  def copyChipset(chipset: Set[Chip], whom: ChipHolder) {
    holder2chips(whom) = chipset :: holder2chips(whom)
    if (chipset.size == 1) {
      whom match {
        case bot: Bot => chip2bot(chipset.head) = bot
        case _ => ()
      }
    }
  }

  def moveChipset(chipset: Set[Chip], whom: ChipHolder) {
    chipset.foreach( chip =>
      chip2bots(chip).foreach( holder =>
        holder2chips(holder) = holder2chips(holder)
          .map(_ - chip).filter(_.nonEmpty)
    ))
    copyChipset(chipset, whom)
  }

//   def giveChips(botSrc: Bot, outLow: ChipHolder, outHigh: ChipHolder) {
//     val List(chip1, chip2) = holder2chips(botSrc)
//     val (low, high) = if (chip1 < chip2) (chip1, chip2) else (chip2, chip1)
//     moveChip(low, outLow)
//     moveChip(high, outHigh)
//   }

  def fillInTwoChipsets(knownChipsets: List[Set[Chip]]) = {
    knownChipsets match {
      case List(first, second) => knownChipsets
      case List(first) => List(first, Set(Chip()))
      case Nil => List(Set(Chip()), Set(Chip()))
    }
  }

  def giveChips(botSrc: Bot, outLow: ChipHolder, outHigh: ChipHolder) {
    val List(chipset1, chipset2) = fillInTwoChipsets(holder2chips(botSrc))
    val comparisons =
      for (chip1 <- chipset1; chip2 <- chipset2)
        yield chip1.compareTo(chip2)
    if (comparisons.forall(_ < 0)) {
      moveChipset(chipset1, outLow)
      moveChipset(chipset2, outHigh)
    }
    else if (comparisons.forall(_ > 0)) {
      moveChipset(chipset2, outLow)
      moveChipset(chipset1, outHigh)
    }
    else {
      moveChipset(chipset1 | chipset2, outLow)
      copyChipset(chipset1 | chipset2, outHigh)
    }
  }

}

// for (i <- (1 to 5)) yield i + 1

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
      BotFactory.moveChipset(Set(Chip(chip.toInt)), Bot(bot.toInt))
    case givePat(from, lowType, toLow, highType, toHigh) =>
      BotFactory.giveChips(Bot(from.toInt),
                           ChipHolder.parse(lowType, toLow),
                           ChipHolder.parse(highType, toHigh))
    case _ => println(s"no match: $line")
  }
}

val hid2mins = for ((k, v) <- BotFactory.holder2chips)
  yield (k.id, (for (cs <- v)
                  yield (for (c <- cs)
                          yield c.idRange.min)))
