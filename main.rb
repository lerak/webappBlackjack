require 'rubygems'
require 'sinatra'

set :sessions, true

helpers do 
	def calculate_total(cards)
		arr = cards.map{|element| element[1]}

		total = 0
		arr.each do |a|
			if a == 'A'
				total += 11
			else
				total += a.to_i == 0 ? 10 : a.to_i
			end
		end

		arr.select{|element| element == 'A'}.count.times do
			break if total <= 21 
			total -= 10
		end
		return total

   end
   def card_image(card)
   	 suit = case card[0]
   	 when 'H' then 'hearts'
   	 when 'D' then 'diamonds'
   	 when 'C' then 'clubs'
   	 when 'S' then 'spades'   	 	
end
 value = card[1]
 if ['J','Q','K','A'].include?(value)
 	value = case card[1]
 	when 'J' then 'jack'
 	when 'Q' then 'queen'
 	when 'K' then 'king'
 	when 'A' then 'ace'
 	end
 end
 return "<img src='/images/cards/#{suit}_#{value}.jpg' class='card_image'>"
end
end
before do 
	@hit_stay_buttons = true
end


get '/' do
  if session[:player_name]
    redirect '/game'
  else
    redirect '/new_player'
  end
end

get '/new_player' do
  erb :new_player
end

post '/new_player' do
	if params[:player_name].empty?
		@error = "Name is required"
		halt erb(:new_player)
	end
  session[:player_name] = params[:player_name]
  redirect '/game'
end

get '/game' do
	suits = ['H','D','C','S']
	values =['2','3','4','5','6','7','8','9','10','J','Q','K','A']
	session[:deck] = suits.product(values).shuffle!

	session[:dealer_cards] =[]
	session[:player_cards] =[]
	session[:dealer_cards] << session[:deck].pop
	session[:player_cards] << session[:deck].pop
	session[:dealer_cards] << session[:deck].pop
	session[:player_cards] << session[:deck].pop
  
  erb :game
end
 
post '/game/player/hit' do
  session[:player_cards] << session[:deck].pop

  player_total = calculate_total(session[:player_cards])
  if player_total == 21
  	@success = "Congratulations you ve won !!"
  	@hit_stay_buttons = false
  elsif calculate_total(session[:player_cards]) > 21
  	@error = "you are busted !"
  	@hit_stay_buttons = false
  end
  erb :game
end

post '/game/player/stay' do
	@success = "You have chosen to stay !"
	@hit_stay_buttons = false
	redirect '/game/dealer'
end 

get '/game/dealer' do
  @hit_stay_buttons = false
  dealer_total = calculate_total(session[:dealer_cards]) 
  if dealer_total == 21
  	@error = "Sorry , Dealer hit BlackJack."
  elsif dealer_total > 21
  	@success = "Congratulations, Dealer Busted . you won !"
  elsif dealer_total >= 17 
  	redirect '/game/compare'
  else
  	### hits
  	@show_dealer_hit_button = true
  end
  erb :game
end

post '/game/dealer/hit' do 
   session[:dealer_cards] << session[:deck].pop
   redirect '/game/dealer'
end

get '/game/compare' do
	@hit_stay_buttons = false
   player_total = calculate_total(seesion[:player_cards])
   dealer_total = calculate_total(session[:dealer_cards])

   if player_total < dealer_total
   	@error = "Sorry you lost "
   elsif player_total > dealer_total
   	@success = "Congratulations,  you won!"
   else
   	@success = "its a tie"
   end
   erb :game
   		
end