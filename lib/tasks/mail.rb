require 'mandrill'  
m = Mandrill::API.new '31B7-zQlBMSJ6pZuaomjCg'
@recipients = Player.find(205)

@recipients.each do |person|
	message = {  
	 :subject=> "Hello from the Mandrill API",  
	 :from_name=> "Your name",  
	 :text=>"Hi message, how are you?",  
	 :to=>[  
	   {  
	     :email=> "jbhansen84@gmail.com",  
	     :name=> "Recipient1"  
	   }  
	 ],  
	 :html=>"<html><h1>Hi <strong>message</strong>, how are you?</h1></html>",  
	 :from_email=>"amateurdota2league@gmail.com"  
	}  
	sending = m.messages.send message  
	puts sending
end