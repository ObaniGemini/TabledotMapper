extends Node

class Log:
	var previous
	var current
	
	func _init(p, c):
		previous = p
		current = c


var max_size := 10



var log := []
var index := -1


func push(l: Log):
	if index != (log.size() - 1): #we went backward
		log.resize(index + 1)
	
	log.append(l)
	if log.size() > max_size:
		log.pop_front()
	
	index = log.size() - 1
	

func go_back():
	if index == -1:
		return
	
	var previous = log[index].previous
	index -= 1
	return previous


func go_forward():
	if index == (max_size - 1):
		return
	
	index += 1
	return log[index].current
