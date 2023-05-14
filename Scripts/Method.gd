class_name Method

var call_method
var data

# Constructor for Method
# @param instance The instance to call the method on
# @param call_method The method to call
# @param data The data to pass to the method
func _init(_call_method, _data):
	self.call_method = _call_method
	self.data = _data


func get_call_method():
	return call_method


func get_data():
	return data
