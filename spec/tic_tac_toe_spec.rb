# frozen_string_literal: true

require_relative '../lib/tic_tac_toe'
require 'stringio'

RSpec.describe "#put_blank_line" do
  it "prints a blank line" do
    expect { put_blank_line }.to output("\n").to_stdout
  end
end

RSpec.describe TicTacToe do
  pending "acceptance test"
end

RSpec.describe Validatable do

  describe "#input_int" do
    let(:dummy_class) { Class.new { extend Validatable } }
    let(:input) { StringIO.new }
    DEFAULT_NUMBER = 3
    before { $stdin = input }
    before { input.string = "#{DEFAULT_NUMBER}\n" }

    it "prints the message given" do
      message = "Enter integer: "
      expect { dummy_class.input_int(message) }.to output(message).to_stdout
    end

    shared_examples_for "accepting integer" do |number|
      before { input.string = "#{number}\n" }

      it "does not print error" do
        expect { dummy_class.input_int("") }.to_not output(
          "Invalid input: please enter an integer number."
        ).to_stdout
      end

      it "returns the integer" do
        expect(dummy_class.input_int("")).to eq(number.to_i);
      end
    end

    shared_examples_for "invalid input" do |input_value|
      REPEAT_BAD_INPUT_TIMES = 3
      ERROR_MESSAGE = "Invalid input: please enter an integer number.\n\n"
      before do
        input.string = "#{"#{input_value}\n" * REPEAT_BAD_INPUT_TIMES}" \
          "#{DEFAULT_NUMBER}\n"
      end

      it "prints error" do
        expect { dummy_class.input_int("") }.to output(
          /#{ERROR_MESSAGE}/
        ).to_stdout
      end

      it "reprompts for input until it receives a correct one" do
        expect { dummy_class.input_int("") }.to output(
          ERROR_MESSAGE * REPEAT_BAD_INPUT_TIMES
        ).to_stdout
      end

      it "returns the last input" do
        expect(dummy_class.input_int("")).to eq(DEFAULT_NUMBER)
      end
    end

    describe "given" do
      describe "positive integer" do
        it_behaves_like 'accepting integer', DEFAULT_NUMBER
      end

      describe "zero" do
        it_behaves_like 'accepting integer', 0
      end

      describe "negative integers" do
        it_behaves_like 'accepting integer', -120
      end

      describe "empty input" do
        it_behaves_like 'invalid input', ""
      end

      describe "other characters with leading digits" do
        it_behaves_like 'accepting integer', "123asdf"
      end

      describe "accept other characters without leading digits" do
        it_behaves_like 'invalid input', "edf"
      end
    end

  end
end

RSpec.describe Player do
  describe 'has a piece attached to it' do
    piece = :X
    let(:player) { described_class.new(piece) }

    it 'returns the piece it was given when initialised' do
      expect(player.piece).to eq(piece)
    end
  end

  describe '#move' do
    let(:input) { StringIO.new("8\n") }
    let(:player) { described_class.new(:X) }
    let(:output_mock) { double('IO') }
    before { $stdin = input }

    it 'prompts the user to enter a square index (0 to 8)' do
      expect { player.move }.to output(
        "PLAYER X\n" +
        "Enter the index of the square you want to move to (0 to 8): "
      ).to_stdout
    end

    it 'returns the square index in an array to move to' do
      allow(output_mock).to receive(:write)
      $stdout = output_mock  # suppress program output

      expect(player.move).to eql(8)
    end
  end
end

RSpec.describe Board do
  let(:board) { described_class.new }
  X = Board::X
  O = Board::O
  EMPTY = Board::EMPTY

  it 'can be filled with Os and Xs' do
    expect(described_class::LAYOUT % [
      'X', ' ', 'O', ' ', 'X', ' ', 'O', ' ', 'X'
    ]).to eq(
      " X |   | O \n" \
      "---|---|---\n" \
      "   | X |   \n" \
      "---|---|---\n" \
      " O |   | X \n" \
    )
  end

  it 'starts out blank' do
    expect(board.current_layout).to eq(
      "   |   |   \n" \
      "---|---|---\n" \
      "   |   |   \n" \
      "---|---|---\n" \
      "   |   |   \n" \
    )
  end

  it 'starts out with no winner' do
    expect(board.winner).to be_falsey
  end

  def set_board(positions)
    allow(board).to receive(:board).and_return(positions)
  end

  def x_wins_horizontally
    set_board([
      X, X, X,
      EMPTY, EMPTY, EMPTY,
      EMPTY, EMPTY, EMPTY,
    ])
  end

  def o_wins_horizontally
    set_board([
      EMPTY, EMPTY, EMPTY,
      O, O, O,
      EMPTY, EMPTY, EMPTY
    ])
  end

  def x_wins_vertically
    set_board([
      O, O, X,
      EMPTY, EMPTY, X,
      EMPTY, EMPTY, X
    ])
  end

  def o_wins_diagonally_top_left
    set_board([
      O, X, X,
      EMPTY, O, X,
      EMPTY, EMPTY, O
    ])
  end
  def o_wins_diagonally_top_right
    set_board([
      X, X, O,
      EMPTY, O, X,
      O, EMPTY, EMPTY
    ])
  end

  def draw
    set_board([
      X, O, X,
      O, O, X,
      O, X, O
    ])
  end

  describe "#winner" do
    it 'returns :X when X wins' do
      x_wins_horizontally()
      expect(board.winner).to eq(:X)
    end

    it 'returns :O when O wins' do
      o_wins_horizontally()
      expect(board.winner).to eq(:O)
    end

    it "returns EMPTY when there is no winner" do
      draw()
      expect(board.winner).to be nil
    end
  end

  describe "#game_over?" do
    def is_game_over
      expect(board.game_over?).to be true
    end

    def is_not_game_over
      expect(board.game_over?).to be false
    end

    it 'starts out as false' do
      is_not_game_over()
    end

    describe 'true when' do
      it 'X wins horizontally' do
        x_wins_horizontally()
        is_game_over()
      end

      it 'X wins vertically' do
        x_wins_vertically()
        is_game_over()
      end

      describe "O wins diagonally" do
        it "going top-left to bottom-right" do
          o_wins_diagonally_top_left()
          is_game_over()
        end

        it 'going top-right to bottom left' do
          o_wins_diagonally_top_right()
          is_game_over()
        end
      end

      it 'the game is a draw' do
        draw()
        is_game_over()
      end
    end

    describe "false when" do
      it "there is not winner yet and there are still empty spaces" do
        set_board([
          EMPTY, X, O,
          EMPTY, EMPTY, EMPTY,
          EMPTY, EMPTY, EMPTY
        ])
        is_not_game_over()
      end
    end

  end

  describe "#current_layout" do
    it "returns the graphical representation of a board" do
      set_board([
        X, O, X,
        O, O, X,
        O, X, O
      ])
      expect(board.current_layout).to eq(
        " X | O | X \n" \
        "---|---|---\n" \
        " O | O | X \n" \
        "---|---|---\n" \
        " O | X | O \n" \
      )
    end

    it "returns the graphical representation of a board with empty spaces" do
      set_board([
        EMPTY, X, O,
        EMPTY, EMPTY, EMPTY,
        EMPTY, EMPTY, EMPTY
      ])
      expect(board.current_layout).to eq(
        "   | X | O \n" \
        "---|---|---\n" \
        "   |   |   \n" \
        "---|---|---\n" \
        "   |   |   \n" \
      )
    end
  end

  describe "#place" do
    it "inserts a piece into the first index of the board" do
      board.place(:X, 0)
      expect(board.board).to eq([
        X, EMPTY, EMPTY,
        EMPTY, EMPTY, EMPTY,
        EMPTY, EMPTY, EMPTY
      ])
    end

    it "inserts a piece into the last index of the board" do
      board.place(:O, 8)
      expect(board.board).to eq([
        EMPTY, EMPTY, EMPTY,
        EMPTY, EMPTY, EMPTY,
        EMPTY, EMPTY, O
      ])
    end
  end
end
