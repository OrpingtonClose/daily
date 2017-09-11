package main
import (
  "fmt"
  "strconv"
)

type person struct {
  name string
  age int
}

func main() {
  var p = person{}
  var p2 = person{ "bob", 21 }
  var p3 = person{ name: "bob", age: 21 }
  var p4 = &person{}
  var p5 = &person{ "bob", 21 }
  var p6 = &person{ name: "bob", age: 21 }
  var format_string = "person named %d, age %d\n"
  fmt.Printf(format_string, p.name, strconv.Itoa(p.age))
  fmt.Printf(format_string, p2.name, strconv.Itoa(p.age))
  fmt.Printf(format_string, p3.name, strconv.Itoa(p.age))
  fmt.Printf(format_string, p4.name, strconv.Itoa(p.age))
  fmt.Printf(format_string, p5.name, strconv.Itoa(p.age))
  fmt.Printf(format_string, p6.name, strconv.Itoa(p.age))
}
