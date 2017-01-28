node 'test01'{ // environments/dev/site.pp
require java8 
require tomcat8

} 
node 'test02', 'test03'{ //environments/qa/site..p
	require java7
	require tomcat8

} 
node 'test03' { //environment/productio/site.pp
} 
