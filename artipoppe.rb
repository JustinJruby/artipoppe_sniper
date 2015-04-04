require 'etsy'
require 'twilio-ruby'
require 'logger'

account_sid = ENV['TWILLIO_SID']
auth_token = ENV['TWILLIO_AUTH'] 
twillio_out_1 = ENV['TWILLIO_ONE'] 
twillio_out_2 = ENV['TWILLIO_TWO'] 
twillio_phone = ENV['TWILLIO_PHONE'] 

etsy_key = ENV['ETSY_KEY']
etsy_secret = ENV['ETSY_SECRET']
etsy_secret = ENV['ETSY_TOKEN']
Etsy.protocol = "https"
Etsy.api_key = etsy_key
Etsy.api_secret = etsy_secret
spotted_listings = {}

time_logger = Logger.new('time.log')
listing_logger = Logger.new('listing.log')

while(true) do
	sleep(15)
time_logger.info( Time.now )
@client = Twilio::REST::Client.new account_sid, auth_token 
access = {:access_token=>etsy_token, :access_secret=>etsy_secret}
artipoppe = nil; listings = nil;

begin
	Etsy.myself(access[:access_token], access[:access_secret])
	artipoppe = Etsy.user('artipoppe')
	listings = artipoppe.shop.listings
rescue Exception=>e
	puts Time.now.to_s
	puts(e.message)
	puts(e.backtrace)
	time_logger.error(e.message)
	time_logger.error(e.backtrace)
	exit;
end

time_logger.info listings.size.to_s
puts Time.now.to_s + " " + listings.size.to_s
if (listings !=[]) then
	sent = false
	listings.each do |listing|
		title = listing.title
		title = title.delete('0-9')
		title = title.delete('Size')
		listing_logger.info(Time.now.to_s+ "   "+title)
		if (spotted_listings[title] == nil) then
			spotted_listings[title] = Time.now

			listing_logger.info(Time.now.to_s+ "   "+"Texting")

			sent = true
			# Send message 
				@client.account.messages.create({
					:from => twillio_phone, :to=>twillio_out_1, :body=>"Artipoppe #{title}- https://www.etsy.com/ca/shop/Artipoppe"   
				})
				@client.account.messages.create({
					:from => twillio_phone, :to=>twillio_out_2, :body=>"Artipoppe  #{title}- https://www.etsy.com/ca/shop/Artipoppe"   
				})
		end
	end
end

end

