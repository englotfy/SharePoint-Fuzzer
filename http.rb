require "rubygems"
require "net/http"
require "net/https"
require "open-uri"
require 'fileutils'
require './util.rb'

module Crawler

 class NetHttp

def logs(log)

#puts log
file = File.open("output/#{$hostname}/logs.txt", "a")
 file.write(log + "\n")
file.close
end

$user_agent='Mozilla/5.0 (X11; Linux x86_64; rv:31.0) Gecko/20100101 Firefox/31.0 Iceweasel/22.8.0-Sharepointfuzzer'
$cookie=""
$res_body=nil
$redirect_always=nil

def initialize(*args)
	   if  args.size == 1 then
				@proxy_host =  args[0];
				@proxy_port=8080
		 elsif args.size ==2
			 @proxy_host =  args[0];
	     @proxy_port =  args[1];

	  elsif args.size ==3
		 
			 @proxy_host =  args[0];
	     @proxy_port =  8080;     
	     @proxy_user =  args[2];
	     @proxy_pass =  args[3];
		 
	  elsif args.size ==4
		 
	     @proxy_host =  args[0];
	     @proxy_port =  args[1];     
	     @proxy_user =  args[2];
	     @proxy_pass =  args[3];
	 
	 end
end
  
################################################################

def server_info(server,aspver,spver)
puts""
puts "=====================server info====================="
puts "Server: #{server}" unless server ==nil
puts "X-AspNet-Version: #{aspver}" unless aspver==nil
puts "Sharepoint Version: #{spver}" unless spver==nil
puts "====================================================="
puts ""
end

#############################################################

def check_base_url(uri_str, limit = 10)
begin
 	#http = Net::HTTP::Proxy(@proxy_host, @proxy_port, @proxy_user, @proxy_pass) 

	#Net::HTTP::Proxy(@proxy_host, @proxy_port, @proxy_user, @proxy_passs).start(uri) {|http|
  	# always connect to your.proxy.addr:8080}
  
	uri = URI(uri_str)

	Net::HTTP::Proxy(@proxy_host, @proxy_port, @proxy_user, @proxy_pass).start(uri.host, uri.port,:use_ssl => uri.scheme == 'https') do |http|
 	request = Net::HTTP::Get.new uri.request_uri
	request["User-Agent"]=$user_agent
	request["cookie"]=$cookie
  	response = http.request request # Net::HTTPResponse object
	
         
      # response = http.get_response(URI.parse(uri_str))             
       case response

       	 when Net::HTTPSuccess     then   
		server_info(response['Server'],response['X-AspNet-Version'], response['MicrosoftSharePointTeamServices'])
			 $res_body=response.body
			 return true
      	 when Net::HTTPRedirection then  
		 red_uri=URI(response['location'])
if red_uri.host!=nil && red_uri.host !=$host then
$host=red_uri.host
end
if red_uri.scheme!=nil and uri.scheme!=red_uri.scheme then
$scheme=red_uri.scheme
else
$scheme=uri.scheme
end
if $redirect_always==nil then
 puts "Base Url Redirect to '#{$scheme}://#{$host+red_uri.path}'"
puts "Choose Your Option: Continu_Redirect(C),No_Redirect(N),Always_Redirect(A),Exit(x):".brown.bold
STDOUT.flush  
red = gets.chomp 
if red=="C" or red=="c" then    

				org_url=uri_str
				red_u="#{$scheme}://"+$host+red_uri.path
				if org_url!=red_u then

				check_base_url("#{$scheme}://"+$host+red_uri.path, limit - 1)
				else
				puts "Found: #{uri_str}".bg_green
				logs "Found: #{uri_str}"
				result_file.write(uri_str+ "\n")
				end
				
			
elsif red=="N" or red=="n" then
   
        logs("Base Url redirect : "+ response['location'])
	logs("---------------------------------------------------------------------")
	
	
 return false

elsif red=="A" or red=="a" then
			$redirect_always="a"

				
				#http_request("#{$scheme}://"+$host+red_uri.path, limit - 1)
				org_url=uri_str
				red_u="#{$scheme}://"+$host+red_uri.path
				if org_url!=red_u then

				check_base_url("#{$scheme}://"+$host+red_uri.path, limit - 1)
				else
				puts "Found: #{uri_str}".bg_green
				logs "Found: #{uri_str}"
				result_file.write(uri_str+ "\n")
				end

elsif red=="x" or red=="X" then 

raise 'An error has occured'
ex
put "xxxxxxxxxxxxxxxx"
end
else
				puts "Base Url redirect to '#{$scheme}://#{$host+red_uri.path}'"

				#http_request("#{$scheme}://"+$host+red_uri.path, limit - 1)
				org_url=uri_str
				red_u="#{$scheme}://"+$host+red_uri.path
				if org_url!=red_u then

				check_base_url("#{$scheme}://"+$host+red_uri.path, limit - 1)
				else 
				puts "Found: #{uri_str}".bg_green
				logs "Found: #{uri_str}"
				result_file.write(uri_str+ "\n")
				end
		
    end      
      else
		   begin
		   # puts response.error!
		    logs("Error : "+  response.error!)	
			return false
			exit
		   end
   end

end

     rescue Exception => e
       # puts "EROOR : #{e.message}".bg_red 
	logs("Error : "+  e.message)
	logs("---------------------------------------------------------------------")
	puts "Error : #{e.message}".bg_red
	puts uri_str
	puts "\n"
        return false
	exit
     end

#End  http_reuest
end


#########################################################################
def redirect (response,uri_str)

uri = URI(uri_str)
	red_uri=URI(response['location'])

	if red_uri.host!=nil && red_uri.host !=$host then
		$host=red_uri.host
	end

	if red_uri.scheme!=nil and uri.scheme!=red_uri.scheme then
		$scheme=red_uri.scheme
	else
		$scheme=uri.scheme
	end

	red_url="#{$scheme}://"+$host+red_uri.path

	if $redirect_always==nil then
		puts "Url Redirect to '#{$scheme}://#{$host+red_uri.path}'"
		puts "Choose Your Option111: Continu_Redirect(C),No_Redirect(N),Always_Redirect(A),Exit(x):"
		STDOUT.flush  
		red = gets.chomp 

		if red=="CC" or red=="cc" then    
			if $notfound_url!= nil and $notfound_url!=red_url then
			logs "Url:#{uri_str} redirect  to :#{red_url}"+ "\n"
			#$result_file.write("Url:#{uri_str} redirect to :#{red_u}"+ "\n")

			elsif $notfound_url!= nil and $notfound_url==red_url
			logs "Url:#{uri_str} redirect to :#{red_url}"+ "\n"
			#$result_file.write("Url:#{uri_str} redirect to :#{red_u}"+ "\n")

			else
			logs "Url:#{uri_str} redirect  to :#{red_url}"+ "\n"
			#$result_file.write("Url:#{uri_str} redirect to :#{red_u}"+ "\n")
			end

			
		elsif red=="N" or red=="n" then
			
			logs("redirect : "+ response['location'])
			logs("---------------------------------------------------------------------")
		return false

		elsif red=="A" or red=="a" then
			$redirect_always="a"

			if $notfound_url!= nil and $notfound_url!=red_url then
			logs "Url:#{uri_str} redirect xxx to :#{red_url}"+ "\n"
			#$result_file.write("Url:#{uri_str} redirect to :#{red_u}"+ "\n")

			elsif $notfound_url!= nil and $notfound_url==red_url
			logs "Url:#{uri_str} redirect to :#{red_url}"+ "\n"
			#$result_file.write("Url:#{uri_str} redirect to :#{red_u}"+ "\n")

			else
			logs "Url:#{uri_str} redirect xxx to :#{red_url}"+ "\n"
			#$result_file.write("Url:#{uri_str} redirect to :#{red_u}"+ "\n")
			end

		elsif red=="x" or red=="X" then 

			raise 'An error has occured'
			ex
			put "xxxxxxxxxxxxxxxx"
	end # if red

	else #$redirect_always==ni

		if $notfound_url!= nil and $notfound_url!=red_url then
		logs "Url:#{uri_str} redirect xxx to :#{red_url}"+ "\n"
		#$result_file.write("Url:#{uri_str} redirect to :#{red_u}"+ "\n")

		elsif $notfound_url!= nil and $notfound_url==red_url
			puts "Not Found".bg_red
		logs "Url:#{uri_str} Not Found"+ "\n"
		#$result_file.write("Url:#{uri_str} redirect to :#{red_u}"+ "\n")

		else 
		logs "Url:#{uri_str} redirect xxx to :#{red_url}"+ "\n"
		#$result_file.write("Url:#{uri_str} redirect to :#{red_u}"+ "\n")
		end


	end #if $redirect_always==nil

	end #end redirect method
	
##########################################################
	
def http_request1(uri_str, limit = 10)
  
	uri = URI(uri_str)
	Net::HTTP::Proxy(@proxy_host, @proxy_port, @proxy_user, @proxy_pass).start(uri.host, uri.port,:use_ssl => uri.scheme == 'https') do |http|
 	request = Net::HTTP::Get.new uri.request_uri
	request["User-Agent"]=$user_agent
	request["cookie"]=$cookie
	response1 = http.request request # Net::HTTPResponse object

	case response1
			
		
		when Net::HTTPSuccess then 


			$res_body=response1.body
				return true

		when Net::HTTPNotFound then
			
			
			
			puts "404 Not Found".bg_red
			puts("---------------------------------------------------------------------")
			logs "404 Not Found"
			logs("---------------------------------------------------------------------")
			return false
		when Net::HTTPRedirection then  
			redirect(response1,uri_str)
		else


		   puts "#{response1.code}".bg_red
			 logs("---------------------------------------------------------------------")
			 return false

	end # end case



	end #end HTTPNET



	rescue Exception => e

		logs("Error : "+  e.message)
		logs("---------------------------------------------------------------------")
		puts "Error : "+  e.message
		puts uri_str.bg_red
		puts "\n"
		return false

end #End  http_reuest method

##########################################################




# end class + module
end
end
