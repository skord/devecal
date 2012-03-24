require 'rubygems'
require 'sinatra'
require 'nokogiri'
require 'open-uri'
require 'ri_cal'
require 'sanitize'

get '/' do
  # Five minute cache.
  cache_control :public, :max_age => 300
  erb :index, :layout => :application
end

get '/characters/:keyID/:vCode' do 
  # Five minute cache
  cache_control :public, :max_age => 300
  @key_id = params[:keyID]
  @v_code = params[:vCode]
  @characters = get_characters(params[:keyID], params[:vCode])
  erb :characters, :layout => :application
end

get '/characters' do
  erb :character_form, :layout => :application
end

post '/characters' do
  key_id = params[:keyID]
  v_code = params[:vCode]
  redirect to("/characters/#{key_id}/#{v_code}")
end

get '/calendar/:keyID/:vCode/:characterId' do
  # Cache for 15 minutes. Should be safe. 
  cache_control :public, :max_age => 900
  content_type 'text/calendar', :charset => 'utf-8'
  @calendar = calendar_events(params[:keyID], params[:vCode], params[:characterId])
  erb :calendar
end


def get_characters(keyId,vCode)
  doc = Nokogiri::XML(open("https://api.eveonline.com/account/apikeyinfo.xml.aspx?keyID=#{keyId}&vCode=#{vCode}"))
  toons = doc.xpath('/eveapi/result/key/rowset/row').collect {|x| {:character_id => x['characterID'], :name => x['characterName']}}    
end

def find_a_url(text)
  text.scan(/http\S{1,}/).flatten[0]
end

def calendar_events(keyId,vCode,characterId)
  doc = Nokogiri::XML(open("https://api.eveonline.com/char/UpcomingCalendarEvents.xml.aspx?keyID=#{keyId}&vCode=#{vCode}&characterID=#{characterId}"))
  happenings = doc.xpath('/eveapi/result/rowset/row')
  RiCal.Calendar do
    happenings.each do |happening|
      event do |event|
        event.summary happening['eventTitle']
        event.description Sanitize.clean(happening['eventText'])
        event.dtstart = Time.parse(happening['eventDate'] + 'Z')
        event.dtend = Time.parse(happening['eventDate'] + 'Z') + (happening['duration'].to_i * 60)
        event.add_attendee happening['ownerID']
        event.url = find_a_url(happening['eventText'])
      end
    end
  end
end