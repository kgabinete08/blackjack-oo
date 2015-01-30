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

  def deal_card(player, faceup = true)
    card = @deck.pop
    card.faceup if faceup
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

  def calculate_hand
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
end

class Game
  BLACKJACK = 21
  attr_accessor :deck, :dealer, :player

  def initialize(player)
    @deck = Deck.new
    @dealer = Player.new("Dealer")
    @player = player
  end

  def winner?(total, player)
    if total == BLACKJACK
      puts "#{player} has Blackjack!, #{player} wins!"
      return true
    elsif total > BLACKJACK
      puts "#{player} busted!"
      return true
    else 
      return false
    end
  end

  def compare_hand(player_total, dealer_total)
    if player_total > dealer_total
      puts "#{@player.name}'s total is #{player_total}, #{@dealer.name}'s total is #{dealer_total}. #{@player.name} wins!"
    elsif player_total < dealer_total
      puts "#{@player.name}'s total is #{player_total}, #{@dealer.name}'s total is #{dealer_total}. #{@dealer.name} wins!"
    else
      puts "#{@player.name}'s total is #{player_total}, #{@dealer.name}'s total is #{dealer_total}. It's a tie!"
    end
  end

  def play
    # Game setup
    begin
      @deck.deal_card(@player)
      @deck.deal_card(@player)
      @deck.deal_card(@dealer, false)
      @deck.deal_card(@dealer)

      system 'clear'
      @player.show_cards
      @dealer.show_cards

      player_total = @player.calculate_hand
      dealer_total = @dealer.calculate_hand

      has_winner = false
      has_winner = winner?(player_total, "#{@player.name}")
      has_winner = winner?(dealer_total, "#{@dealer.name}")

      # Player turn
      begin
        puts "Please choose: 1) Hit 2) Stay"
        choice = gets.chomp.to_i
        if ![1, 2].include?(choice)
          puts "Please enter 1 or 2."
          has_winner = false
          next
        end

        if choice == 1
          @deck.deal_card(@player)
          system 'clear'
          @player.show_cards
          @dealer.show_cards
          player_total = @player.calculate_hand
        end
        has_winner = winner?(player_total, "#{@player.name}")
      end while has_winner == false && choice == 1

      # Dealer's turn
      if choice == 2
        @dealer.hand.first.faceup
        system 'clear'
        @player.show_cards
        @dealer.show_cards
        dealer_total = @dealer.calculate_hand
          if dealer_total < 17
            begin
              @deck.deal_card(@dealer)
              system 'clear'
              @player.show_cards
              @dealer.show_cards
              dealer_total = @dealer.calculate_hand
            end until dealer_total >= 17
          end
        has_winner = winner?(dealer_total, "#{@dealer.name}")
      end

      # Compare hands
      if !has_winner
        player_total = @player.calculate_hand
        dealer_total = @dealer.calculate_hand
        compare_hand(player_total, dealer_total)
        has_winner = true
      end

      # Play another hand
      begin
        puts "Would you like to play another hand? (Y/N)"
        answer = gets.chomp.upcase
      end while !['Y', 'N'].include?(answer)

      # Reset table and hand
      if answer == 'Y'
        system 'clear'
        @player.hand = []
        @dealer.hand = []
      end
    end while answer == 'Y'
    puts "Play again sometime!"
  end
end

puts "Welcome to Blackjack!"
puts "What is your name?"
name = gets.chomp
new_player = Player.new(name)

new_game = Game.new(new_player)
new_game.play
