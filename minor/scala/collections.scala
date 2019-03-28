import java.security.MessageDigest

object listcomprehensions {
  def listcomps() ={
    val names: scala.collection.immutable.Set[String] = Set("Diego", "James", "John", "Sam", "Christopher")
    println(names)
    val brasilians = for {
      name <- names
      initial <- name.substring(0, 1)
    } yield if (name.contains("Die")) name
    //how to turn bytes into a hex string?
    val hashes = for {
      num <- 0 to 10
      hash <- List(new String(MessageDigest.getInstance("MD5").digest(num.toString().getBytes)))
    } yield hash

    println(brasilians)
    println(hashes)
  }
  def collections: Unit = {
    var ms: scala.collection.mutable.ListBuffer[Int] = scala.collection.mutable.ListBuffer(1, 2, 3)
    println(ms)
    ms += 4
    println(ms)
    ms += 5
    println(ms)
    ms += 6
    println(ms)
    println(ms(1))
    println(ms(5))
    ms -= 5
    println(ms)
    ms -= 6
    println(ms)
  }
  def collections_set: Unit ={
    var set:scala.collection.mutable.SortedSet[String] =
      scala.collection.mutable.SortedSet[String]("Diego", "Poletto", "Jackson")
    println(set)
    set += "Sam"
    val is_diego_there:Boolean = set("Diego")
    println(is_diego_there)
    set -= "Jackson"
    println(set)
  }
  def tuples: Unit = {
    val config = ("localhost", 8080)
    println(config)
    println(config._1)
    println(config._2)
  }
  def maps: Unit = {
    val numbers = scala.collection.immutable.Map("one" -> 1,
                                                 "two" -> 2,
                                                 "three" -> 3,
                                                 "four" -> 4,
                                                 "five" -> 5)
    println(numbers)
    println(numbers.keys)
    println(numbers.values)
    println(numbers("one"))
    println(Map("herp" -> "merp"))
  }
  def mutable_maps(): Unit = {
    val map = scala.collection.mutable.HashMap.empty[Int, String]
    println(map)
    map += (1 -> "one")
    println(map)
    map += (2 -> "two")
    println(map)
    map += (3 -> "three")
    println(map)
    map += (4 -> "mutable")
    println(map)
  }
  //another hex string printing attempt
  //https://stackoverflow.com/questions/2756166/what-is-are-the-scala-ways-to-implement-this-java-byte-to-hex-class
  def hex(): Unit = {
    for (b <- "herp".getBytes())
      println(b.toByte)
      //println(String.format("%02X", b & 0xff ))
  }
  def main(args:Array[String]) = {
    //listcomps
    //collections
    //collections_set
    //tuples
    //maps
    mutable_maps
    //hex
  }
}

