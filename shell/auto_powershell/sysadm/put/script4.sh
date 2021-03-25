
v1="level script"

foo () {
	v1="level function"
	pwd
	whoami
	echo from function foo: $v1 
}

echo from script before foo: $v1

foo

echo from script after foo: $v1
