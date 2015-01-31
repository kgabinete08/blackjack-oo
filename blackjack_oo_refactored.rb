class Card
  attr_reader :suit, :value, :facedown
  def initialize(suit, value, facedown)
    @suit = suit
    @value = value
    @facedown = facedown
  end

  def display_card
    @facedown ? "Card is face down" : "#{value} of #{suit}"
  end

  def faceup
    @facedown = false
  end
end

class Deck
  VALUES = ['A', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K']
  SUITS = ['Hearts', 'Diamonds', 'Spades', 'Clubs']

  def initialize
    @deck = []
    VALUES.each do |value|
      SUITS.each do |suit|
        @deck << Card.new(suit, value, true)
      end 
    end
    shuffle
  end

  def shuffle
    @deck.shuffle!
  end

  def deal_card(player, show = true)
    card = @deck.pop
    card.faceup if show
    player.hand << card
  end
end

class Player
  attr_accessor :name, :hand
  def initialize(name)
    @name = name
    @hand = []
  end

  def show_cards
    puts "#{self.name}'s cards:"
    @hand.each { |card| puts card.display_card }
  end

  def total
    total = 0

    @hand.each do |card|
      if card.value == 'A'
        total += 11
      elsif card.value.to_i == 0
        total += 10
      else
        total += card.value.to_i
      end
    end

    @hand.select { |card| card.value == 'A' }.count.times do
        total -= 10 if total > Game::BLACKJACK
    end
    total
  end

  def busted?
    total > Game::BLACKJACK
  end
end

class Dealer < Player
  attr_accessor :name, :hand
  def initialize(name)
    @name = name
    @hand = []
  end
end

class Game
  BLACKJACK = 21
  attr_accessor :deck, :dealer, :player

  def initialize(player)
    @deck = Deck.new
    @dealer = Dealer.new("Dealer")
    @player = player
  end

  def winner?
    if player.total > dealer.total
      puts "Congratulations #{player.name} won!"
    elsif player.total < dealer.total
      puts "Sorry #{dealer.name} won!"
    else
      puts "It's a tie."
    end
    play_again?
  end

  def calculate_hand(player_or_dealer)
    if player_or_dealer.total == BLACKJACK
      if player_or_dealer.is_a?(Dealer)
        puts "Sorry, #{dealer.name} has Blackjack!"
      else
        puts "Congratulations, #{player.name} has Blackjack!"
      end
      play_again?
    elsif player_or_dealer.busted?
      if player_or_dealer.is_a?(Dealer)
        puts "Congratulations, #{dealer.name} busted!"
      else
        puts "Sorry, #{player.name} busted!"
      end
      play_again?
    end
  end

  def deal_initial_hands
    deck.deal_card(player)
    deck.deal_card(dealer, false)
    deck.deal_card(player)
    deck.deal_card(dealer)
  end

  def show_hands
    system 'clear'
    puts "+-------------------+"
    player.show_cards
    puts "+-------------------+"
    dealer.show_cards
    puts "+-------------------+"
  end

  def player_turn
    calculate_hand(player)

    while !player.busted?
      puts "Please choose: 1) Hit 2) Stay"
      choice = gets.chomp.to_i
      if ![1, 2].include?(choice)
        puts "Please enter 1 or 2."
        next
      end

      if choice == 1
        deck.deal_card(player)
        show_hands
        calculate_hand(player)
      end
      
      if choice == 2
        dealer.hand.first.faceup
        break
      end
    end
  end

  def dealer_turn
    calculate_hand(dealer)
    dealer.hand.first.faceup
    show_hands

    while dealer.total < 17
      deck.deal_card(dealer)
      show_hands
      calculate_hand(dealer)
    end 
  end

  def play_again?
    begin
      puts "Would you like to play another hand? (Y/N)"
      answer = gets.chomp.upcase
    end while !['Y', 'N'].include?(answer)

    if answer == 'Y'
      system 'clear'
      deck = Deck.new
      @player.hand = []
      @dealer.hand = []
      play
    else
      puts "Play again sometime!"
      exit
    end
  end

  def play
    deal_initial_hands
    show_hands
    player_turn
    dealer_turn
    winner?
  end
end

puts "Welcome to Blackjack!"
puts "What is your name?"
name = gets.chomp
new_player = Player.new(name)

new_game = Game.new(new_player)
new_game.play
