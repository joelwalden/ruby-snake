
require 'gosu'

class Snake

attr_accessor :direction, :xpos, :ypos, :speed, :length, :segments, :ticker

	def initialize(window)
		@window = window
		@xpos = 200
		@ypos = 200
		@segments = []
		@direction = "right"
		@head_segment = Segment.new(self, @window, [@xpos, @ypos])
		@segments.push(@head_segment)
		@speed = 2
		@length = 1

		# Counts down to lengthen the snake each tick when it has eaten an apple
		@ticker = 0
  end

	def draw
		# Draw the segments
		@segments.each do |s|
			s.draw
		end
	end

	def update_position

		add_segment
		@segments.shift(1) unless @ticker > 0

	end

	def add_segment
		
		if @direction == "left"
			xpos = @head_segment.xpos - @speed
			ypos = @head_segment.ypos
			new_segment = Segment.new(self, @window, [xpos, ypos])
		end

		if @direction == "right"
			xpos = @head_segment.xpos + @speed
			ypos = @head_segment.ypos
			new_segment = Segment.new(self, @window, [xpos, ypos])
		end

		if @direction == "up"
			xpos = @head_segment.xpos
			ypos = @head_segment.ypos - @speed
			new_segment = Segment.new(self, @window, [xpos, ypos])
		end

		if @direction == "down"
			xpos = @head_segment.xpos
			ypos = @head_segment.ypos + @speed
			new_segment = Segment.new(self, @window, [xpos, ypos])
		end

		@head_segment = new_segment
		@segments.push(@head_segment)

	end

	def ate_apple?(apple)
		if Gosu::distance(@head_segment.xpos, @head_segment.ypos, apple.xpos, apple.ypos) < 10
			return true
		end
	end

	def hit_self?
		segments = Array.new(@segments)
		if segments.length > 21
			# Remove the head segment from consideration
			segments.pop((10 * @speed))
			segments.each do |s|
				if Gosu::distance(@head_segment.xpos, @head_segment.ypos, s.xpos, s.ypos) < 11
					puts "true, head: #{@head_segment.xpos}, #{@head_segment.ypos}; seg: #{s.xpos}, #{s.ypos}"
					return true
				else
					next
				end
			end
			return false
		end

	end

	def outside_bounds?
		if @head_segment.xpos < 0 or @head_segment.xpos > 630
			return true
		elsif @head_segment.ypos < 0 or @head_segment.ypos > 470
			return true
		else
			return false
		end
	end

end

class Segment

	attr_accessor :xpos, :ypos
	def initialize(snake, window, position)
		@window = window
		@xpos = position[0]
		@ypos = position[1]
	end

	def draw
		@window.draw_quad(@xpos,@ypos,Gosu::Color::GREEN,@xpos + 10,@ypos,Gosu::Color::GREEN,@xpos,@ypos + 10,Gosu::Color::GREEN,@xpos + 10,@ypos + 10,Gosu::Color::GREEN)
	end

end

class Apple

attr_reader :xpos, :ypos

	def initialize(window)
		@window = window
		@xpos = rand(10..630)
		# Must be 50 to make sure it doesn't overlap the score
		@ypos = rand(50..470)
	end

	def draw
		@window.draw_quad(@xpos,@ypos,Gosu::Color::RED,@xpos,@ypos + 10,Gosu::Color::RED,@xpos + 10,@ypos,Gosu::Color::RED,@xpos + 10,@ypos + 10, Gosu::Color::RED)
	end
end


class GameWindow < Gosu::Window
	def initialize
		super 640, 480, false
		self.caption = "Snake"
		@snake = Snake.new(self)
		@apple = Apple.new(self)
		@score = 0

		@text_object = Gosu::Font.new(self, 'Ubuntu Sans', 32)

	end

	def update

		# Change directions, but don't allow doubling back
		if button_down? Gosu::KbLeft and @snake.direction != "right"
			@snake.direction = "left"
		end
		if button_down? Gosu::KbRight and @snake.direction != "left"
			@snake.direction = "right"
		end
		if button_down? Gosu::KbUp and @snake.direction != "down"
			@snake.direction = "up"
		end
		if button_down? Gosu::KbDown and @snake.direction != "up"
			@snake.direction = "down"
		end

		if button_down? Gosu::KbEscape
			self.close
		end

		if @snake.ate_apple?(@apple)
			@apple = Apple.new(self)
			@score += 10
			@snake.length += 10
			
			# 11 because we subtract one at the end of the method anyway
			@snake.ticker += 11
			if @score % 100 == 0
				@snake.speed += 0.5
			end
		end

		if @snake.hit_self?
			@new_game = Gosu::Font.new(self, 'Ubuntu Sans', 32)
		end

		if @snake.outside_bounds?
			@new_game = Gosu::Font.new(self, 'Ubuntu Sans', 32)
		end

		if @new_game and button_down? Gosu::KbReturn
			@new_game = nil
			@score = 0
			@snake = Snake.new(self)
			@apple = Apple.new(self)
		end

		@snake.ticker -= 1 if @snake.ticker > 0
	end

	def draw

		if @new_game
			@new_game.draw("Your Score was #{@score}", 5, 200, 100)
			@new_game.draw("Press Return to Try Again", 5, 250, 100)
			@new_game.draw("Or Escape to Close", 5, 300, 100)
		else
			@snake.update_position
			@snake.draw
			@apple.draw
			@text_object.draw("Score: #{@score}",5,5,0)
		end
	end
end

window = GameWindow.new
window.show
