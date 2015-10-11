#!/usr/bin/env ruby 

require 'optparse'  
require 'uri'
require 'open-uri'
require 'fileutils'
require './util.rb'
require './http'

$http = Crawler::NetHttp.new

def scan()
begin
	
options = {} 
	optparse = OptionParser.new do|opts|  
	# Set a banner, displayed at the top 
	# of the help screen.   
	opts.banner = "==============SharePoint Fuzzer Manual========================"   
	# Define the options, and what they do  

	#options[:verbose] = false

	opts.on('-u','--url ','[Mandatory] Base url') do |url|
	options[:url] = url
	end

	opts.on('-p','--proxy-url ','[Optional] Proxy url') do |proxy|
	options[:proxy] = proxy
	end

	opts.on('-o','--proxy-port ',"[Optional] Proxy port - default 8080") do |port|
	options[:port] = port
	end

	opts.on('','--proxy-user ','[Optional] Proxy user') do |proxyuser|
	options[:proxyuser] = proxyuser
	end

	opts.on("","--proxy-pass ","[Optional] Proxy  password") do |proxy_pass|
	options[:proxy_pass] = proxy_pass
	end

	opts.on( '', '--user-agent ', '[Optional] Set user agent' ) do |useragent|
	options[:useragent] = useragent   
	end

	opts.on( '-c', '--cookie ', '[Optional] Set cookie' ) do |cookie|
	options[:cookie] = cookie   
	end

	opts.on("","--not-found ","[Optional] Set keyword or Phrase to assume this page as not found and exculude it from results") do |notfound|
	options[:notfound] = notfound
	end


	opts.on( '', '--notfound-url ', '[Optional] Set url or page  to assume this url as not found and exculude it from results' ) do |notfoundurl|
	options[:notfoundurl] = notfoundurl   
	end

	opts.on("-e","--error ","[Optional] Set keyword or Phrase to assume this page as an error and exculude it from results") do |error|
	options[:error] = error
	end







	# This displays the help screen, all programs are 
	# assumed to have this option.  
	opts.on('-h','--help','Manual') do

	puts optparse 
puts "======================================================"
	#options[:verbose] = true
	exit
	end

	end 

	if ARGV.size == 0
	puts optparse 
puts "======================================================"
	exit
	end

	# Parse the command-line. Remember there are two forms

	optparse.parse!  




	if !options[:url]  then
	puts "Url Require to start scan".bg_red 
	puts optparse 
puts "======================================================"
	exit
	end

		 


	
	if options[:proxy] then   ## Set Proxy ARG

		if options[:proxy] && options[:port] then
			if options[:proxyuser] and options[:proxy_pass]
				$http = Crawler::NetHttp.new(options[:proxy],options[:port],options[:proxyuser],options[:proxy_pass])
			else
				$http = Crawler::NetHttp.new(options[:proxy],options[:port])
			end 


		else
			if options[:proxyuser] and options[:proxy_pass]
				$http = Crawler::NetHttp.new(options[:proxy],options[:proxyuser],options[:proxy_pass])
			else
				$http= Crawler::NetHttp.new(options[:proxy])
			end 

	 end


 else
	$http = Crawler::NetHttp.new

 end ## 

	
	if options[:useragent] then ## Set User_Agent ARG
		$user_agent=options[:useragent]
	end ##

	
	if options[:cookie] then ## Set Cookie ARG
		$cookie=options[:cookie]
	end ##

	
	if options[:notfoundurl] then ## Set Cookie ARG
		$notfound_url=options[:notfoundurl]
	end ##

## create output folder
	myUri = URI.parse( options[:url] )
	$host=myUri.host
	$hostname=$host
	dirname = "output/#{$host}"
	unless File.directory?(dirname)
	  FileUtils.mkdir_p(dirname)
	end
##

puts "-------------------AgreeMent Policy--------------------------".bold
puts "You are the owner of the target site or have the authority to do scanning.".brown.bold
puts "By accepting this policy, you take the responsibility of effect of using this tool".brown.bold
puts "Accept (y) , Not Accept (n):".bold
STDOUT.flush  
acc = gets.chomp 
if acc=="N" or acc=="n" then
exit

elsif  acc=="Y" or acc=="y" then

	puts "Checking Base Url availability : #{options[:url]}".bold

	if $http.check_base_url(options[:url]) then

		puts "/n---Scan Start...#{options[:url]}...#{Time.new.strftime("%Y-%m-%d %H:%M:%S")}".bold.blue.bg_gray
		$http.logs "**************************************************************"
		$http.logs("---Scan Start...#{options[:url]}...#{Time.new.strftime("%Y-%m-%d %H:%M:%S")}")
		$http.logs "\n"

		$result_file = File.open("output/#{$hostname}/result.txt", "a")
		$result_file.write("--------------------------------------------------------------------\n")
		$result_file.write("---Scan ...'#{options[:url]}'...#{Time.new.strftime("%Y-%m-%d %H:%M:%S")}"+"\n")

		## Loop Fuzz.txt
		File.open("fuzz.txt", "r").each_line do |line|
			$res_body=nil
			url1="#{$scheme}://"+ $host + line.gsub(' ', '').gsub(/\n+|\r+/, "\n").squeeze("\n").strip 
			puts "#{Time.new.strftime("%Y-%m-%d %H:%M:%S")}: Checking: "+url1
			$http.logs "#{Time.new.strftime("%Y-%m-%d %H:%M:%S")}: Checking: "+url1


			if $http.http_request1(url1) then
		 
				if options[:error] and options[:notfound] then
					if ($res_body != nil) && (! $res_body["#{options[:error]}"] and ! $res_body["#{options[:notfound]}"]) then
					puts "Found: #{url1}".bg_green
					$http.logs "Found: #{url1}"
					$result_file.write(url1+ "\n")
					else 
						puts "Not Fount url Or Error Page".bg_red
					end

				elsif options[:error] then 
					if ($res_body != nil) && (! $res_body["#{options[:error]}"])
						puts "Found: #{url1}".bg_green
						$result_file.write(url1 + "\n")
						puts "Error Page".bg_red
					end

				elsif options[:notfound] then 
					if ($res_body != nil) && (! $res_body["#{options[:notfound]}"])
					puts "Found: #{url1}".bg_green
					$result_file.write(url1 + "\n")
					else
						puts "Not Fount url".bg_red
					end

				else
					puts "Found: #{url1}".bg_green
					$http.logs "Found: #{url1}"
					$http.logs("--------------------------------------------------------------------------")
					$result_file.write(url1 + "\n")

				end

		  
			end

		## end of fuzz.txt
		end

	$http.logs "##########################################################################################"
	$http.logs "---Scan Finished...#{Time.new.strftime("%Y-%m-%d %H:%M:%S")}"
	$result_file.write "---Scan Finished...#{Time.new.strftime("%Y-%m-%d %H:%M:%S")}"
	puts "---Scan Finished...#{Time.new.strftime("%Y-%m-%d %H:%M:%S")}".bold.blue.bg_gray
	$result_file.close

	else

	end
end ## end agreement if
	## end of scan function
	rescue Exception => e
	 # puts "EROOR : #{e.message}".bg_red 
		$http.logs("Error : "+  e.message)
		$http.logs("---------------------------------------------------------------------")
		puts "Error : "+  e.message.bg_red
		puts "\n"
		return false
		exit
	end



end



scan

