require 'io/console'
require './Dealer.rb'
require './Opponent'

def change_turn(opponents, opp_index)
    print "Enter any key to continue: "
    get_char
    system "clear"
    opponents[opp_index].turn = false
    opponents[opp_index + 1].turn = true
    return opp_index + 1
end

def check_rank_and_change_turn(opponents, opp_index)
    opponent = opponents[opp_index] 
    if opponent.split
        if opponent.hand == "left" && (opponent.rank[0] != nil || opponent.stand[0])
            opponent.hand = "right"
            print "Enter any key to continue: "
            get_char
            system "clear"
            return check_rank_and_change_turn(opponents, opp_index)
        elsif opponent.hand == "right" && (opponent.rank[1] != nil || opponent.stand[1])
            return change_turn(opponents, opp_index)
        end
    elsif opponent.rank != nil || opponent.stand
        return change_turn(opponents, opp_index)
    end
    return opp_index
end


def play(dealer, opponents)
    players = opponents + [dealer]
    player_i = 0
    while player_i < players.count-1 do
        if !players[player_i].split && players[player_i].rank != nil
            players[player_i].turn = false
            players[player_i+1].turn = true
            player_i += 1
            next
        end

        players[player_i].play_turn(dealer)
        dealer.perform(players[player_i])
        player_i = check_rank_and_change_turn(players, player_i)
    end

    dealer.play_turn(opponents)
end

def get_char
    input = STDIN.getch
    control_c_code = "\u0003"
    exit(1) if input == control_c_code
    input
end  

def game

    players = []
    d = Dealer.new "Dealer"

    print "Enter No of Players(1-5): "
    player_count = gets.to_i
    until player_count>=1 && player_count<=5
        print "wrong input! please choose bet between (1-5): "
        player_count = gets.to_i
    end
    puts "\n"
    
    player_count.times do |i|
        print "Enter Name of Player#{i+1}: "
        name = gets.chomp
        players << Opponent.new(name) 
        players[i].bet
    end

    2.times do
        player_count.times do |i|
            d.pass_to_opponent(players[i])
        end
        d.pass_himself
    end
    
    system "clear"
    players[0].turn = true

    player_count.times do |i|
        d.check_black_jack(players[i])
        if players[i].rank != nil
            players[i].show
            print "Press any key to continue: "
            get_char
        end
    end

    system "clear"

    play(d, players)

    puts "Game Over"

end

game()



