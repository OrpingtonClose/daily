//https://gobyexample.com/hello-world

package main

import "fmt"

func herp() func() {
	fmt.Println("this is excellent. An era of function over form is upon us")
	return func() {
		fmt.Println("let us celebrate!")
	}
}

func main() {
	fmt.Println("hello World")
	celebration := herp()
	celebration()
}

//go run 01_helloworld.go
//go build !$
//./01_helloworld
