require 'ruby2d'
require 'csv'

# CONSTANTS
BACKGROUND_COLOR = 'black'
FOREGROUND_COLOR = 'white'
WINDOW_WIDTH = 640
WINDOW_HEIGHT = 480
DIFFICULTY = 1 # TODO
X_SPEED = 3 * DIFFICULTY
Y_SPEED = 2 * DIFFICULTY

# SETTINGS
set title: "Pong", background: BACKGROUND_COLOR, 
    width: WINDOW_WIDTH, height: WINDOW_HEIGHT

# CLASSES
class Border
  BORDER_SIZE = 10

  def initialize
    # Top
    Rectangle.new(
      x: 0, y: 0,
      width: WINDOW_WIDTH, height: BORDER_SIZE,
      color: FOREGROUND_COLOR
    )
  
    # Bottom
    Rectangle.new(
      x: 0, y: WINDOW_HEIGHT - BORDER_SIZE,
      width: WINDOW_WIDTH, height: BORDER_SIZE,
      color: FOREGROUND_COLOR
    )
  
    # Left
    Rectangle.new(
      x: 0, y: 0,
      width: BORDER_SIZE, height: WINDOW_HEIGHT,
      color: FOREGROUND_COLOR
    )
  end
end

class Paddle
  PADDLE_WIDTH = 10
  PADDLE_HEIGHT = 50

  def initialize
    @shape = Rectangle.new(
      x: (WINDOW_WIDTH - PADDLE_WIDTH), y: ((WINDOW_HEIGHT / 2) - (PADDLE_HEIGHT / 2)),
      width: PADDLE_WIDTH, height: PADDLE_HEIGHT,
      color: FOREGROUND_COLOR
    )
  end

  def up
    if not @shape.contains? (WINDOW_WIDTH - PADDLE_WIDTH), Border::BORDER_SIZE
      @shape.y = @shape.y - Y_SPEED
    end
  end

  def down
    if not @shape.contains? (WINDOW_WIDTH - PADDLE_WIDTH), (WINDOW_HEIGHT - Border::BORDER_SIZE)
      @shape.y = @shape.y + Y_SPEED
    end
  end

  def x
    @shape.x
  end

  def y
    @shape.y
  end
end

class Ball
  BALL_RADIUS = 5

  def initialize
    @shape = Circle.new(
      x: (WINDOW_HEIGHT / 2), y: (WINDOW_WIDTH / 2),
      radius: BALL_RADIUS,
      color: FOREGROUND_COLOR
    )
    @direction = {x: 1, y: -1}
  end

  def move(paddle)
    if @shape.contains? @shape.x, Border::BORDER_SIZE
      deflect(:up)
    end
    if @shape.contains? @shape.x, (WINDOW_HEIGHT - Border::BORDER_SIZE)
      deflect(:down)
    end
    if @shape.contains? Border::BORDER_SIZE, @shape.y
      deflect(:left)
    end
    if @shape.x == paddle.x and @shape.y >= paddle.y and @shape.y <= (paddle.y + Paddle::PADDLE_HEIGHT)
      deflect(:right)
    end

    @shape.x = @shape.x + (@direction[:x] * X_SPEED)
    @shape.y = @shape.y + (@direction[:y] * Y_SPEED)
  end

  def deflect(direction)
    case direction
    when :up, :down
      @direction = {x: @direction[:x], y: -@direction[:y]}
    when :left, :right
      @direction = {x: -@direction[:x], y: @direction[:y]}
    end
  end

  def x
    @shape.x
  end

  def y
    @shape.y
  end

  def direction
    @direction
  end
end

# OPENING CSV
fd = IO.sysopen("game.csv", "w")
a = IO.new(fd,"w")
csv = CSV.new(a)
csv << ['ball_x', 'ball_y', 'ball_direction_x', 'ball_direction_y', 'paddle_y']

# MAIN
border = Border.new

paddle = Paddle.new

ball = Ball.new

on :key_held do |event|
  case event.key
  when 'up'
    paddle.up
  when 'down'
    paddle.down
  end
end

update do
  ball.move(paddle)

  csv << [ball.x, ball.y, ball.direction[:x], ball.direction[:y], paddle.y]
  if ball.x > paddle.x
    close
  end
end

show
