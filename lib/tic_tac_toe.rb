# frozen_string_literal: true

def put_blank_line
  puts
end

module Validatable
  def input_int(message)
    valid_input = nil
    user_input = nil

    until valid_input
      if user_input
        puts "Invalid input: please enter an integer number."
        put_blank_line
      end

      print message
      user_input = gets.chomp
      int_input = user_input.to_i
      valid_input = int_input unless user_input != '0' && int_input == 0
    end

    valid_input
  end
end

class TicTacToe
  def initialize
    @player1 = Player.new(:X)
    @player2 = Player.new(:O)
    @board = Board.new
  end

  public

  def start_game
    turn = 0
    puts @board.current_layout
    while !@board.game_over?
      turn += 1
      current_player = turn % 2 != 0 ? @player1 : @player2

      valid_move = nil
      until valid_move
        put_blank_line
        valid_move = validate_move(current_player.move, @board.board)
      end

      @board.place(current_player.piece, valid_move)

      put_blank_line
      puts @board.current_layout

    end

    put_blank_line

    if @board.winner
      puts "#{@board.winner} wins!"
    else
      puts "Draw"
    end
  end

  private

  def validate_move(to_position, board)
    if to_position < 0 || to_position > 8
      puts "Not a valid square!"
      false
    elsif board[to_position] != Board::EMPTY
      puts "That square is already taken!"
      false
    else
      to_position
    end
  end
end

class Player
  include Validatable
  attr_reader :piece

  def initialize(piece)
    @piece = piece
  end

  def move
    puts "PLAYER #{piece}"
    input_int("Enter the index of the square you want to move to (0 to 8): ")
  end
end

class Board
  X = 'X'
  O = 'O'
  EMPTY = ' '
  LAYOUT = " %c | %c | %c \n" \
          "---|---|---\n" \
          " %c | %c | %c \n" \
          "---|---|---\n" \
          " %c | %c | %c \n" \

  def initialize
    @winner = nil
    @board = Array.new(9, EMPTY)
  end

  public

  attr_reader :board

  def winner
    @winner ||= check_winner
  end

  def game_over?
    !!winner || !places_left
  end

  def place(player, index)
    board[index] = player == :X ? X : O
  end

  def current_layout
    LAYOUT % board
  end

  private

  def check_winner
    pieces_at = Proc.new { |i| board[i] }

    [X, O].each do |piece|
      same_piece = Proc.new { |place| place == piece }
      # check winner horizontally
      [0, 3, 6].each do |start_index|
        return piece.to_sym if board[start_index, 3].all? same_piece
      end
      # check winner vertically
      [0, 1, 2].each do |start_index|
        return piece.to_sym if (start_index..start_index + 6).step(3)
          .map(&pieces_at)
          .all?(&same_piece)
      end
      # check winner both diagonals
      [0, 2].each do |start_index|
        difference = 4 - start_index
        return piece.to_sym if (start_index..start_index + 2 * difference)
          .step(difference)
          .map(&pieces_at)
          .all?(&same_piece)
      end
    end

    nil
  end

  def places_left
    board.include?(EMPTY)
  end

end

if __FILE__ == $PROGRAM_NAME
  TicTacToe.new.start_game
end
