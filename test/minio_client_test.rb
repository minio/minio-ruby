require 'minio'
require 'open-uri'
 

mc = MinioRuby::MinioClient.new(endPoint:"https://s3.amazonaws.com", accessKey:"" , secretKey:"", region: "us-east-1" )
puts mc.getObject("mybucket","myimage.png")

file = open("hello.txt").read
mc.putObject("mybucket", "tfile.txt", file, file.size, 'text/plain')

mc.getObject("mybucket","tfile.txt")

 
