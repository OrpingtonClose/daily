object conditionals {
  def conds(): Unit = {
    val x = 10
    if (x == 10)
      println("x is 10")
    val y: AnyVal = 11
    println(y)

    def herp = if (x == 10) "the condition was true"

    println(herp)

    if (x == 11) {
      println("the condition wa somehow true")
    } else {
      println("X is something else")
    }
  }
  def loops(): Unit = {
    for ( i <- 1 to 10 )
      println("i * " + i + " = " + i * 10)
    for ( i <- 10 to 12; j <- 1 to 2; k <- 20 to 21)
      println(i + " is paired with " + j + " and " + k)
  }

  def lists(): Unit = {
    val listOfValues = List(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
    for (i <- listOfValues) println(i)
    println("evens")
    for (i<-listOfValues) if (i % 2==0) println(i)
  }

  def main(args:Array[String]) = {
    conds
    loops
    lists
  }
}

