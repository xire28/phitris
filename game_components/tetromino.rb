module Phitris
  class Tetromino < Chingu::BasicGameObject
    traits :simple_sprite, :timer
    include Chingu::Helpers::InputClient
    include Config
    
    config image: 'block.png', rotator: Phitris::Rotators.all.first, randomizer: Phitris::Randomizers.all.first
    
    attr_reader :board, :position
    
    def initialize(options = {})
      super(options = config.merge(options))
      
      extend options[:rotator]
      @board = options[:board]
      @position = Point.new(0,0)
    end
    
    def put_on_board_and_fall_at(fall_delay)
      place_on_board
      self.x, self.y = @board.origin.x, @board.origin.y
      
      every(fall_delay, :name => :falling) do
        unless fall
          stop_timer(:falling)
          board.fix(self, :fall_delay => fall_delay)
          destroy!
          game_state.place_new_tetromino
        end
      end
    end
    
    def hard_drop
      count = 0
      count += 1 while fall
      game_state.reward(:hard_drop, count)
    end

    def soft_drop
      fall
      game_state.reward(:soft_drop)
    end

    def shift_right
      try { position.x += 1 }
    end

    def shift_left
      try { position.x -= 1 }
    end

    def fall
      try { position.y += 1 }
    end
    
    # 
    def fit?
      board.fit?(self)
    end
    
    def name
      Chingu::Inflector.demodulize self.class
    end
    
    def width
      blocks.first.size*image.width
    end
    
    def height
      blocks.size*image.height
    end

    def draw_relative(x=0, y=0, zorder=0, factor_x=0, factor_y=0)
      blocks.each_with_index do |line, pos_y|
        next if position.y+pos_y < 0
        line.each_with_index do |block, pos_x|
          next unless block
          super(x+(position.x+pos_x)*image.width, y+(position.y+pos_y)*image.height, zorder, factor_x, factor_y)
        end
      end
    end
    alias_method :draw, :draw_relative
    
    class << self
      def all
        [I,O,J,L,S,Z,T]
      end
      
      def max_size
        all.inject(0) do |memo, tetromino_class|
          tetromino = tetromino_class.new
          [tetromino.blocks.max_by {|i| i.size}.size, tetromino.blocks.size, memo].max
        end
      end
      
    end
    
    protected
    
    def try
      previous_position = @position.dup
      yield
      @position = previous_position unless fitted = fit?
      fitted
    end
    
    class I < Tetromino
      config color: 0xFF00ffff
    end

    class O < Tetromino
      config color: 0xFFffff00
    end

    class J < Tetromino
      config color: 0xFF0000ff
    end

    class L < Tetromino
      config color: 0xFFff8800
    end

    class S < Tetromino
      config color: 0xFF00ff00
    end

    class Z < Tetromino
      config color: 0xFFff0000
    end

    class T < Tetromino
      config color: 0xFFff00ff
    end
  end
end