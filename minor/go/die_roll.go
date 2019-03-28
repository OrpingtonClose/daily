package main
import (
  "math/rand"
  "time"
  "fmt"
  "strconv"
)

func dieRoll(size int) int {
  rand.Seed(time.Now().UnixNano())
  return rand.Intn(size) + 1
}

func rollTwo(size1 int, size2 int) (int, int) {
  return dieRoll(size1), dieRoll(size2)
}

func returnsNamed(input1 string, input2 int) (theResult string, err error) {
  theResult = "modified " + input1 + "." + strconv.Itoa(input2)
  return theResult, err
}

type dieRollFunc func(int) int

func fakeDieRoll(size int) int {
  return 42
}

func getDieRolls() []dieRollFunc {
  return []dieRollFunc{
    dieRoll,
    fakeDieRoll,
  }
}

func main() {
  fmt.Println("Rolled a die of size %d, result: %d\n", 6, dieRoll(6))
  res1, res2 := rollTwo(6, 10) 
  fmt.Printf("Rolled a pair of dice (%d, %d), results: %d, %d\n", 6, 10, res1, res2)
  named, err := returnsNamed("globule", 42)
  fmt.Printf("Named params returned: '%s', %v\n", named, err)
  fmt.Println("=======================================")
  var rolls = getDieRolls()
  for index, rollFunc := range rolls {
    fmt.Printf("Die Roll Attempt #%d, result: %d\n", index, rollFunc(10))
  }
}
